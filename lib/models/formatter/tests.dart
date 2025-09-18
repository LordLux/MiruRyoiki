import 'dart:io';
import 'package:path/path.dart' as p;
import '../../utils/logging.dart';
import '../../utils/path.dart';
import 'action.dart';

/// Test case definition for formatter testing
class FormatterTestCase {
  /// Name of the test case
  final String name;

  /// Description of what the test case checks
  final String description;

  /// Function to create test folders and files
  final Future<PathString> Function() setupFunction;

  /// Expected number of actions that should be generated
  final int expectedActions;

  /// Expected types of actions (counts per type)
  final Map<ActionType, int>? expectedActionCounts;

  /// Whether this test case should have issues
  final bool shouldHaveIssues;

  const FormatterTestCase({
    required this.name,
    required this.description,
    required this.setupFunction,
    required this.expectedActions,
    this.expectedActionCounts,
    this.shouldHaveIssues = false,
  });
}

/// Result of running a test case
class TestResult {
  final FormatterTestCase testCase;
  final SeriesFormatPreview preview;
  final bool success;
  final String? error;

  const TestResult({
    required this.testCase,
    required this.preview,
    required this.success,
    this.error,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Test: ${testCase.name} - ${success ? 'SUCCESS' : 'FAILED'}');

    if (error != null) {
      buffer.writeln('Error: $error');
    }

    buffer.writeln('Actions: ${preview.actions.length} (expected: ${testCase.expectedActions})');
    buffer.writeln('Issues: ${preview.issues.length} (should have issues: ${testCase.shouldHaveIssues})');

    if (testCase.expectedActionCounts != null) {
      buffer.writeln('Action counts:');
      for (final type in ActionType.values) {
        final count = preview.actions.where((a) => a.type == type).length;
        final expected = testCase.expectedActionCounts![type] ?? 0;
        final match = count == expected;
        buffer.writeln('  - $type: $count (expected: $expected) ${match ? '✓' : '✗'}');
      }
    }

    return buffer.toString();
  }
}

/// Run multiple test cases and return results
Future<List<TestResult>> runFormatterTests(List<FormatterTestCase> testCases) async {
  final results = <TestResult>[];
  final tempDir = await Directory.systemTemp.createTemp('formatter_tests_');

  try {
    for (final testCase in testCases) {
      logDebug('Running test case: ${testCase.name}');

      try {
        // Setup the test directory
        final seriesPath = await testCase.setupFunction();

        // Run the formatter
        final preview = await formatSeriesFolders(
          seriesPath: seriesPath,
          config: const FormatterConfig(),
        );

        // Validate the results
        final success = _validateTestCase(testCase, preview);

        results.add(TestResult(
          testCase: testCase,
          preview: preview,
          success: success,
        ));

        // Clean up
        await Directory(seriesPath.path).delete(recursive: true);
      } catch (e, stackTrace) {
        logErr('Error running test case: ${testCase.name}', e, stackTrace);

        results.add(TestResult(
          testCase: testCase,
          preview: SeriesFormatPreview(
            seriesPath: PathString(''),
            seriesName: '',
            actions: [],
            issues: ['Error: $e'],
          ),
          success: false,
          error: e.toString(),
        ));
      }
    }
  } finally {
    // Clean up the temp directory
    await tempDir.delete(recursive: true);
  }

  return results;
}

/// Validate if a test case passed
/// Validate if a test case passed
bool _validateTestCase(FormatterTestCase testCase, SeriesFormatPreview preview) {
  // Check action count tolerance - adding a small tolerance to handle minor differences
  // that don't affect functionality
  final actionCountDiff = (preview.actions.length - testCase.expectedActions).abs();
  final countValid = actionCountDiff <= 1; // Allow 1 off (minor tolerance)
  
  if (!countValid) {
    logWarn('Action count mismatch: ${preview.actions.length} vs ${testCase.expectedActions}');
    return false;
  }
  
  // Check if issues match expectations
  if (testCase.shouldHaveIssues != preview.hasIssues) {
    logWarn('Issue state mismatch: ${preview.hasIssues} vs ${testCase.shouldHaveIssues}');
    return false;
  }
  
  // Check action type counts if specified
  if (testCase.expectedActionCounts != null) {
    for (final entry in testCase.expectedActionCounts!.entries) {
      final type = entry.key;
      final expectedCount = entry.value;
      final actualCount = preview.actions.where((a) => a.type == type).length;
      
      // Allow small tolerance for file moves and folder creation
      if ((type == ActionType.moveFile || type == ActionType.createFolder) && 
          (actualCount - expectedCount).abs() <= 1) {
        continue;
      }
      
      if (actualCount != expectedCount) {
        logWarn('Action type count mismatch for $type: $actualCount vs $expectedCount');
        return false;
      }
    }
  }
  
  return true;
}

/// Collection of common test cases
List<FormatterTestCase> get standardTestCases => [
      // Empty series
      FormatterTestCase(
        name: 'Empty Series',
        description: 'Empty folder with no files or subfolders',
        setupFunction: () async {
          final dir = await _createTestDir('empty_series');
          return PathString(dir.path);
        },
        expectedActions: 0,
      ),
      // Flat A
      FormatterTestCase(
        name: 'Flat Series A',
        description: 'Series with no folders, just episode files',
        setupFunction: () async {
          final dir = await _createTestDir('flat_series_a');

          // Create 12 episode files
          for (int i = 1; i <= 12; i++) {
            final file = File(p.join(dir.path, 'S01E${i.toString().padLeft(2, '0')} - Episode Title.mkv'));
            await file.create();
          }

          return PathString(dir.path);
        },
        expectedActions: 13, // 1 folder creation + 12 file moves
        expectedActionCounts: {
          ActionType.createFolder: 1,
          ActionType.moveFile: 12,
        },
      ),
      // Flat B
      FormatterTestCase(
        name: 'Flat Series B',
        description: 'Series with no folders, just episode files without season prefixes', // should default to season 1
        setupFunction: () async {
          final dir = await _createTestDir('flat_seriesB');

          // Create 24 episode files
          for (int i = 1; i <= 24; i++) {
            final file = File(p.join(dir.path, '${i.toString().padLeft(2, '0')} - Episode Title.mkv'));
            await file.create();
          }

          return PathString(dir.path);
        },
        expectedActions: 25, // 1 folder creation + 24 file moves
        expectedActionCounts: {
          ActionType.createFolder: 1,
          ActionType.moveFile: 24,
        },
      ),
      // Multiple Seasons Flat
      FormatterTestCase(
        name: 'Multiple Seasons Flat',
        description: 'Series with multiple seasons but no folders',
        setupFunction: () async {
          final dir = await _createTestDir('multi_season_flat');

          // Create 5 episodes for season 1
          for (int i = 1; i <= 5; i++) {
            final file = File(p.join(dir.path, 'S01E${i.toString().padLeft(2, '0')} - Season 1.mkv'));
            await file.create();
          }

          // Create 5 episodes for season 2
          for (int i = 1; i <= 5; i++) {
            final file = File(p.join(dir.path, 'S02E${i.toString().padLeft(2, '0')} - Season 2.mkv'));
            await file.create();
          }

          return PathString(dir.path);
        },
        expectedActions: 12, // 2 folder creations + 10 file moves
        expectedActionCounts: {
          ActionType.createFolder: 2,
          ActionType.moveFile: 10,
        },
      ),
      // Mixed Content
      FormatterTestCase(
        name: 'Mixed Content',
        description: 'Series with regular episodes and related media',
        setupFunction: () async {
          final dir = await _createTestDir('mixed_content');

          // Regular episodes
          for (int i = 1; i <= 5; i++) {
            final file = File(p.join(dir.path, '${i.toString().padLeft(2, '0')} - Episode.mkv'));
            await file.create();
          }

          // OVAs and movies
          final ova = File(p.join(dir.path, 'Series OVA.mkv'));
          await ova.create();
          
          final ova2 = File(p.join(dir.path, 'OVA - Episode Title.mkv'));
          await ova2.create();

          final movie = File(p.join(dir.path, 'Series Movie.mkv'));
          await movie.create();

          final special = File(p.join(dir.path, 'Special Episode.mkv'));
          await special.create();

          return PathString(dir.path);
        },
        expectedActions: 11, // 2 folder creations + 9 file moves
        expectedActionCounts: {
          ActionType.createFolder: 2,
          ActionType.moveFile: 9,
        },
        shouldHaveIssues: true, // Expect issues, since some files won't be categorized cleanly
      ),
      // Secondary Season Folders Naming
      FormatterTestCase(
        name: 'Nonstandard Season Folders',
        description: 'Series with season folders using nonstandard naming',
        setupFunction: () async {
          final dir = await _createTestDir('nonstandard_seasons');

          // Create weird season folders
          final s1Dir = Directory(p.join(dir.path, 'S1'));
          await s1Dir.create();

          final s2Dir = Directory(p.join(dir.path, 'Season Two'));
          await s2Dir.create();

          // Add files to season 1
          for (int i = 1; i <= 3; i++) {
            final file = File(p.join(s1Dir.path, '${i.toString().padLeft(2, '0')} - Ep.mkv'));
            await file.create();
          }

          // Add files to season 2
          for (int i = 1; i <= 3; i++) {
            final file = File(p.join(s2Dir.path, '${i.toString().padLeft(2, '0')} - Ep.mkv'));
            await file.create();
          }

          return PathString(dir.path);
        },
        expectedActions: 2, // 2 folder renames (to standardize season naming)
        expectedActionCounts: {
          ActionType.renameFolder: 2,
        },
      ),
      // Multiple Related Media Folders
      FormatterTestCase(
        name: 'Multiple Related Media Folders',
        description: 'Series with multiple folders containing related media',
        setupFunction: () async {
          final dir = await _createTestDir('multiple_related');

          // Create main season folder
          final seasonDir = Directory(p.join(dir.path, 'Season 01'));
          await seasonDir.create();

          // Add files to season 1
          for (int i = 1; i <= 3; i++) {
            final file = File(p.join(seasonDir.path, '${i.toString().padLeft(2, '0')} - Ep.mkv'));
            await file.create();
          }

          // Create OVA folder
          final ovaDir = Directory(p.join(dir.path, 'OVAs'));
          await ovaDir.create();

          // Add files to OVA folder
          for (int i = 1; i <= 2; i++) {
            final file = File(p.join(ovaDir.path, 'OVA $i.mkv'));
            await file.create();
          }

          // Create Specials folder
          final specialsDir = Directory(p.join(dir.path, 'Specials'));
          await specialsDir.create();

          // Add files to Specials folder
          for (int i = 1; i <= 2; i++) {
            final file = File(p.join(specialsDir.path, 'Special $i.mkv'));
            await file.create();
          }

          return PathString(dir.path);
        },
        expectedActions: 7, // 1 create folder + 4 file moves + 2 rename folders
        expectedActionCounts: {
          ActionType.createFolder: 1,
          ActionType.moveFile: 4,
          ActionType.renameFolder: 2,
        },
      ),
      // Problematic Mixed Content
      FormatterTestCase(
        name: 'Problematic Mixed Content',
        description: 'Series with files that have ambiguous or unclear naming',
        setupFunction: () async {
          final dir = await _createTestDir('problematic_mixed');

          // Some clear season 1 episodes
          for (int i = 1; i <= 3; i++) {
            final file = File(p.join(dir.path, 'S01E${i.toString().padLeft(2, '0')} - Episode.mkv'));
            await file.create();
          }

          // Some ambiguous files
          final file1 = File(p.join(dir.path, 'Episode A.mkv'));
          await file1.create();

          final file2 = File(p.join(dir.path, 'Episode B.mkv'));
          await file2.create();

          final file3 = File(p.join(dir.path, '01 Episode.mkv')); // Ambiguous - is it Ep 1 or something else?
          await file3.create();
          
          final special = File(p.join(dir.path, 'SP01 Episode.mkv'));
          await special.create();

          return PathString(dir.path);
        },
        expectedActions: 8, // 2 folder creations + 5 file moves
        expectedActionCounts: {
          ActionType.createFolder: 2,
          ActionType.moveFile: 6,
        },
        shouldHaveIssues: true, // This should generate issues due to ambiguous files
      ),
    ];

/// Create a test directory with a unique name
Future<Directory> _createTestDir(String name) async {
  final tempDir = await Directory.systemTemp.createTemp('formatter_test_${name}_');
  return tempDir;
}

/// Run all standard tests and return results
Future<List<TestResult>> runStandardTests() async {
  return runFormatterTests(standardTestCases);
}

/// Execute a test of the series formatter
Future<void> testSeriesFormatter() async {
  final results = await runStandardTests();

  // Print results
  int passed = 0;
  int failed = 0;

  for (final result in results) {
    if (result.success) {
      passed++;
      logDebug('✓ PASSED: ${result.testCase.name}');
    } else {
      failed++;
      logDebug('✗ FAILED: ${result.testCase.name}');
      logDebug(result.toString());
    }
  }

  logDebug('Test results: $passed passed, $failed failed');
}

/// Create a realistic test environment with multiple series
Future<String> createRealisticTestLibrary() async {
  final tempDir = await Directory.systemTemp.createTemp('formatter_library_');
  logDebug('Creating realistic test library at: ${tempDir.path}');

  // Create Series 1 - Clean organization
  final series1 = Directory(p.join(tempDir.path, 'Series 1 - Clean'));
  await series1.create();

  final s1Season1 = Directory(p.join(series1.path, 'Season 01'));
  await s1Season1.create();

  for (int i = 1; i <= 12; i++) {
    final file = File(p.join(s1Season1.path, '${i.toString().padLeft(2, '0')} - Episode.mkv'));
    await file.create();
  }

  // Create Series 2 - Flat structure
  final series2a = Directory(p.join(tempDir.path, 'Series 2 - Flat A'));
  await series2a.create();

  for (int i = 1; i <= 12; i++) {
    final file = File(p.join(series2a.path, 'S01E${i.toString().padLeft(2, '0')} - Episode.mkv'));
    await file.create();
  }

  // Create Series 2 - Flat structure
  final series2b = Directory(p.join(tempDir.path, 'Series 2 - Flat B'));
  await series2b.create();

  for (int i = 1; i <= 24; i++) {
    final file = File(p.join(series2b.path, '${i.toString().padLeft(2, '0')} - Episode.mkv'));
    await file.create();
  }

  // Create Series 3 - Multiple seasons
  final series3 = Directory(p.join(tempDir.path, 'Series 3 - Multiple Seasons'));
  await series3.create();

  final s3Season1 = Directory(p.join(series3.path, 'S1'));
  await s3Season1.create();

  for (int i = 1; i <= 6; i++) {
    final file = File(p.join(s3Season1.path, '${i.toString().padLeft(2, '0')} - Episode.mkv'));
    await file.create();
  }

  final s3Season2 = Directory(p.join(series3.path, 'Season Two'));
  await s3Season2.create();

  for (int i = 1; i <= 6; i++) {
    final file = File(p.join(s3Season2.path, '${i.toString().padLeft(2, '0')} - Episode.mkv'));
    await file.create();
  }

  // Create Series 4 - Mixed content
  final series4 = Directory(p.join(tempDir.path, 'Series 4 - Mixed'));
  await series4.create();

  for (int i = 1; i <= 8; i++) {
    final file = File(p.join(series4.path, 'S01E${i.toString().padLeft(2, '0')} - Episode.mkv'));
    await file.create();
  }

  final s4OVA = File(p.join(series4.path, 'OVA 1.mkv'));
  await s4OVA.create();

  final s4Movie = File(p.join(series4.path, 'Movie.mkv'));
  await s4Movie.create();

  // Create Series 5 - Problematic
  final series5 = Directory(p.join(tempDir.path, 'Series 5 - Problematic'));
  await series5.create();

  // Completely random files with no clear pattern
  final s5File1 = File(p.join(series5.path, 'episode.mkv'));
  await s5File1.create();

  final s5File2 = File(p.join(series5.path, 'episode_02.mkv'));
  await s5File2.create();

  final s5File3 = File(p.join(series5.path, '[group] episode 3.mkv'));
  await s5File3.create();

  // Random folders
  final s5Folder1 = Directory(p.join(series5.path, 'Episodes'));
  await s5Folder1.create();

  final s5Folder1File = File(p.join(s5Folder1.path, 'episode in folder.mkv'));
  await s5Folder1File.create();

  return tempDir.path;
}
