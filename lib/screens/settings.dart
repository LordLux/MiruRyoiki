// import 'package:flutter/material.dart';
// ignore_for_file: use_build_context_synchronously

import 'dart:math' show min;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:miruryoiki/widgets/gradient_mask.dart';
import 'package:miruryoiki/widgets/loading_button.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:recase/recase.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:toggle_switch/toggle_switch.dart' as toggle;
import 'dart:io';

import '../enums.dart';
import '../main.dart';
import '../manager.dart';
import '../models/formatter/action.dart';
import '../models/series.dart';
import '../services/navigation/dialogs.dart';
import '../services/navigation/show_info.dart';
import '../settings.dart';
import '../utils/color_utils.dart';
import '../utils/logging.dart';
import '../utils/registry_utils.dart';
import '../models/library.dart';
import '../theme.dart';
import '../utils/screen_utils.dart';
import '../utils/time_utils.dart';
import '../widgets/enum_toggle.dart';
import '../widgets/trasformable_grid.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

// ignore: non_constant_identifier_names
List<WindowEffect> _WindowsWindowEffects = [
  WindowEffect.acrylic,
  WindowEffect.solid,
  WindowEffect.aero,
  WindowEffect.transparent,
  if (Manager.isWin11) WindowEffect.mica,
];

// ignore: non_constant_identifier_names
List<WindowEffect> get _PlatformWindowEffects => switch (defaultTargetPlatform) {
      TargetPlatform.windows => _WindowsWindowEffects,
      TargetPlatform.macOS => [WindowEffect.disabled, WindowEffect.solid],
      TargetPlatform.linux => [WindowEffect.disabled],
      _ => [WindowEffect.disabled],
    };

class _SettingsScreenState extends State<SettingsScreen> {
  FlyoutController controller = FlyoutController();
  Color tempColor = Colors.transparent;
  late double _headerHeight;
  List<SeriesFormatPreview> _issuesPreview = [];
  // ignore: unused_field
  bool _isFormatting = false;

  final ScrollController _scrollController = ScrollController();
  final ScrollController issueController = ScrollController();

  bool showAccentLibViewCol = false;

  double prevPos = 0;

  Widget standard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Standard Format Structure:', style: FluentTheme.of(context).typography.bodyStrong),
        SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Root series folder
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: '📁 ', style: TextStyle(fontFamily: 'Segoe UI Emoji')),
                      TextSpan(text: 'Series Name: ', style: FluentTheme.of(context).typography.body),
                      TextSpan(
                        text: '<any Windows compatible name>',
                        style: TextStyle(color: Manager.accentColor.lightest, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),

                // Season folders
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: '📁 ', style: TextStyle(fontFamily: 'Segoe UI Emoji')),
                        TextSpan(text: 'Season Folders: ', style: FluentTheme.of(context).typography.body),
                        TextSpan(
                          text: 'Season XX',
                          style: TextStyle(color: Manager.accentColor.lightest, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                // Episode files
                Padding(
                  padding: EdgeInsets.only(left: 40),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: '🎬 ', style: TextStyle(fontFamily: 'Segoe UI Emoji')),
                        TextSpan(text: 'Episodes: ', style: FluentTheme.of(context).typography.body),
                        TextSpan(
                          text: 'XX - Episode Title.ext',
                          style: TextStyle(color: Manager.accentColor.lightest, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 8),

                // Related Media folder
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: '📁 ', style: TextStyle(fontFamily: 'Segoe UI Emoji')),
                        TextSpan(text: 'Related Media', style: FluentTheme.of(context).typography.bodyStrong),
                      ],
                    ),
                  ),
                ),

                // Specials files
                Padding(
                  padding: EdgeInsets.only(left: 40),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: '🎬 ', style: TextStyle(fontFamily: 'Segoe UI Emoji')),
                        TextSpan(text: 'Specials: ', style: FluentTheme.of(context).typography.body),
                        TextSpan(
                          text: 'SPXX - Special Title.ext',
                          style: TextStyle(color: Manager.accentColor.lightest, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                // Movie files
                Padding(
                  padding: EdgeInsets.only(left: 40),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: '🎬 ', style: TextStyle(fontFamily: 'Segoe UI Emoji')),
                        TextSpan(text: 'Movies: ', style: FluentTheme.of(context).typography.body),
                        TextSpan(
                          text: 'Movie Title.ext',
                          style: TextStyle(color: Manager.accentColor.lightest, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 4),
        Text('Note: XX represents a 2 > digit number (01, 02, 100, etc.)', style: FluentTheme.of(context).typography.caption),
      ],
    );
  }

  // Show dialog to confirm formatting action
  void _showSeriesFormatterDialog(BuildContext context) {
    final library = Provider.of<Library>(context, listen: false);

    if (library.series.isEmpty) {
      snackBar('No series found in the library', severity: InfoBarSeverity.warning);
      return;
    }

    showSimpleManagedDialog(
      context: context,
      id: 'formatSeriesConfirm',
      title: 'Format Series',
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('This will scan your library and suggest changes to organize folders and files into a standard structure. Continue?'),
            SizedBox(height: 16),
            standard(context),
            SizedBox(height: 16),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'This process will '),
                  TextSpan(text: 'not', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  TextSpan(text: ' modify any files until you confirm the changes in the next dialog.'),
                ],
              ),
              style: FluentTheme.of(context).typography.caption,
            ),
          ],
        );
      },
      isPositiveButtonPrimary: true,
      positiveButtonText: 'Scan Library and Preview Changes',
      constraints: BoxConstraints(maxWidth: 600),
      negativeButtonText: 'Cancel',
      onPositive: () async {
        setState(() {
          _isFormatting = true;
        });
        try {
          // Get all series paths
          final seriesPaths = library.series.map((s) => s.path).toList();

          // Run the formatter preview
          final Map<String, SeriesFormatPreview> results = await formatLibrary(
            seriesPaths: seriesPaths,
            progressCallback: (processed, total) {
              // You could update progress here if desired
              logTrace('Formatter progress: $processed/$total');
            },
          );

          // Process results
          _showFormatterResults(context, results);
        } catch (e, stackTrace) {
          logErr('Error during series formatting', e, stackTrace);
          Navigator.of(context).pop(); // Close loading dialog
          snackBar('Error scanning library: $e', severity: InfoBarSeverity.error);
        } finally {
          setState(() {
            _isFormatting = false;
          });
        }
      },
    );
  }

  // Show results dialog
  void _showFormatterResults(BuildContext context, Map<String, SeriesFormatPreview> results) {
    // Count total actions and issues
    int totalActions = 0;
    int seriesWithIssues = 0;
    List<SeriesFormatPreview> issuesList = [];

    for (final preview in results.values) {
      totalActions += preview.actions.length;
      if (preview.hasIssues) {
        seriesWithIssues++;
        issuesList.add(preview);
      }
    }

    if (totalActions == 0) {
      showSimpleOneButtonManagedDialog(
        context: context,
        id: 'formatterNoChanges',
        title: 'No Changes Needed',
        body: 'Your library is already well-organized! No changes are required.',
        positiveButtonText: 'OK',
      );
      return;
    }

    // Update list of series with issues
    setState(() {
      _issuesPreview = issuesList;
    });

    // Show results with options
    showManagedDialog(
      context: context,
      id: 'formatterResults',
      title: 'Formatter Results',
      dialogDoPopCheck: () => true,
      builder: (context) => ManagedDialog(
        popContext: context,
        title: Text('Formatter Results'),
        constraints: BoxConstraints(maxWidth: 900, maxHeight: 500),
        contentBuilder: (_, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: "Found ${results.length} series with $totalActions suggested changes.\n", style: FluentTheme.of(context).typography.subtitle),
                        WidgetSpan(child: SizedBox(height: 16)),
                        TextSpan(text: "Don't worry about the big number of changes, the majority of them are just renaming files and folders to match the standard structure.  ", style: FluentTheme.of(context).typography.caption),
                        WidgetSpan(
                          child: TooltipTheme(
                            data: TooltipThemeData(waitDuration: const Duration(milliseconds: 100), preferBelow: true),
                            child: Tooltip(
                              richMessage: WidgetSpan(
                                child: standard(context),
                              ),
                              child: Transform.translate(
                                offset: Offset(0, -2),
                                child: Icon(FluentIcons.info, size: 13, color: FluentTheme.of(context).resources.textFillColorPrimary.withOpacity(.5)),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    style: FluentTheme.of(context).typography.bodyLarge,
                  ),
                  SizedBox(height: 12),

                  // Summary of actions
                  Center(
                    child: SizedBox(
                      width: 500,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Summary:', style: FluentTheme.of(context).typography.bodyStrong),
                              SizedBox(height: 8),
                              _buildSummaryItem('Series to modify:', '${results.length}'),
                              _buildSummaryItem('Files to move:', '${_countActionType(results, ActionType.moveFile)}'),
                              _buildSummaryItem('Files to rename:', '${_countActionType(results, ActionType.renameFile)}'),
                              _buildSummaryItem('Folders to create:', '${_countActionType(results, ActionType.createFolder)}'),
                              _buildSummaryItem('Folders to rename:', '${_countActionType(results, ActionType.renameFolder)}'),
                              if (seriesWithIssues > 0) ...[
                                SizedBox(height: 12),
                                Text(
                                  'Warning: $seriesWithIssues series have potential issues that require your attention.',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        actions: (popContext) => [
          if (seriesWithIssues > 0) ...[
            // If there are issues, show three options
            ManagedDialogButton(
              popContext: popContext,
              text: 'Cancel',
              onPressed: () {
                // Do nothing, just close the dialog
              },
            ),
            ManagedDialogButton(
              popContext: popContext,
              text: 'Apply (Skip Issues)',
              onPressed: () {
                _applyFormatting(context, results, skipIssues: true);
              },
            ),
            ManagedDialogButton(
              popContext: popContext,
              text: 'Apply All',
              onPressed: () {
                _applyFormatting(context, results, skipIssues: false);
              },
            ),
          ] else ...[
            // If no issues, just Apply or Cancel
            ManagedDialogButton(
              popContext: popContext,
              text: 'Cancel',
              onPressed: () {
                // Do nothing, just close the dialog
              },
            ),
            ManagedDialogButton(
              popContext: popContext,
              text: 'Apply Changes',
              onPressed: () {
                _applyFormatting(context, results, skipIssues: false);
              },
            ),
          ],
        ],
      ),
    );
  }

  // Apply the formatting changes
  Future<void> _applyFormatting(BuildContext context, Map<String, SeriesFormatPreview> results, {required bool skipIssues}) async {
    // Show loading dialog
    showManagedDialog(
      context: context,
      id: 'applyingFormat',
      title: 'Applying Changes',
      dialogDoPopCheck: () => false,
      builder: (context) => ManagedDialog(
        popContext: context,
        title: Text('Applying Changes'),
        contentBuilder: (_, __) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProgressRing(),
              SizedBox(height: 16),
              Text('Formatting your library...\nThis may take a moment.'),
            ],
          ),
        ),
      ),
    );

    try {
      int processed = 0;
      int successful = 0;

      for (final preview in results.values) {
        processed++;

        // Skip if there are issues and we're skipping issues
        if (preview.hasIssues && skipIssues) {
          continue;
        }

        // Apply the formatting
        final success = await applySeriesFormatting(preview, skipIssues: skipIssues);
        if (success) successful++;
      }

      // Close loading dialog
      Navigator.of(context).pop();

      // Show completion dialog
      showSimpleManagedDialog(
        context: context,
        id: 'formattingComplete',
        title: 'Formatting Complete',
        body: 'Successfully formatted $successful out of $processed series.',
        positiveButtonText: 'OK',
        negativeButtonText: '',
        onPositive: () {
          // Refresh the library to show updated structure
          final library = Provider.of<Library>(context, listen: false);
          library.reloadLibrary();
        },
      );
    } catch (e, stackTrace) {
      logErr('Error applying formatting', e, stackTrace);
      Navigator.of(context).pop(); // Close loading dialog
      snackBar('Error applying formatting: $e', severity: InfoBarSeverity.error);
    }
  }

// Helper method to build a summary item
  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

// Helper method to count actions of a specific type
  int _countActionType(Map<String, SeriesFormatPreview> results, ActionType type) {
    int count = 0;
    for (final preview in results.values) {
      count += preview.actions.where((a) => a.type == type).length;
    }
    return count;
  }

// Build a list item for a series with issues
  Widget _buildSeriesIssueItem(BuildContext context, SeriesFormatPreview preview, Series? series, List previewSeries, int index) {
    return Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Series poster
          if (series != null)
            Container(
              width: 91 * 0.71,
              height: 91,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                image: series.effectivePosterPath != null
                    ? DecorationImage(
                        image: FileImage(File(series.effectivePosterPath!)),
                        fit: BoxFit.contain,
                      )
                    : null,
                color: FluentTheme.of(context).resources.controlStrokeColorDefault,
              ),
              child: series.effectivePosterPath == null ? Center(child: Icon(FluentIcons.picture, size: 24)) : null,
            )
          else
            Container(
              width: 91 * 0.71,
              height: 91,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: FluentTheme.of(context).resources.controlStrokeColorDefault,
              ),
              child: Center(child: Icon(FluentIcons.picture, size: 24)),
            ),
          SizedBox(width: 12),

          // Series name and issues
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  series?.name ?? preview.seriesName,
                  style: FluentTheme.of(context).typography.bodyStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '${preview.actions.length} changes recommended',
                  style: FluentTheme.of(context).typography.caption,
                ),
                SizedBox(height: 4),
                if (preview.issues.length == 1)
                  Text(
                    'Issue: ${preview.issues.take(1).join(", ")}',
                    style: TextStyle(color: Colors.orange),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (preview.issues.length > 1)
                  Expander(
                    header: Text('Issues (${preview.issues.length})', style: TextStyle(color: Colors.orange)),
                    onStateChanged: (isExpanded) async {
                      if (index == previewSeries.length - 1 && isExpanded) {
                        final int frameUpdateNumber = 30;
                        final int totalDuration = 150;
                        for (int i = 0; i < totalDuration; i += (totalDuration / frameUpdateNumber).round()) {
                          nextFrame(() => issueController.jumpTo(issueController.position.maxScrollExtent));

                          await Future.delayed(Duration(milliseconds: totalDuration ~/ frameUpdateNumber));
                        }
                      }
                    },
                    content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: preview.issues.map((issue) => Text(issue)).toList()),
                  ),
              ],
            ),
          ),

          // Action buttons
          Row(
            children: [
              Tooltip(
                message: 'View Series',
                child: IconButton(
                  icon: Icon(FluentIcons.view),
                  onPressed: () {
                    // Navigate to series
                    _navigateToSeries(context, preview.seriesPath);
                  },
                ),
              ),
              SizedBox(width: 8),
              Tooltip(
                message: 'Apply Formatting',
                child: IconButton(
                  icon: Icon(FluentIcons.accept),
                  onPressed: () {
                    // Apply formatting just for this series
                    _applyFormattingForSeries(context, preview);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Navigate to a series
  void _navigateToSeries(BuildContext context, String seriesPath) {
    // Get the AppRoot state via the global key
    final appState = homeKey.currentState;
    if (appState != null) {
      // Close any open dialogs
      Navigator.of(context).pop();

      // Use the navigateToSeries method from AppRoot
      appState.navigateToSeries(seriesPath);
    }
  }

// Apply formatting for a single series
  Future<void> _applyFormattingForSeries(BuildContext context, SeriesFormatPreview preview) async {
    try {
      final result = await applySeriesFormatting(preview, skipIssues: false);

      if (result) {
        // Remove from the list if successful
        setState(() {
          _issuesPreview.removeWhere((p) => p.seriesPath == preview.seriesPath);
        });

        snackBar('Formatting applied successfully', severity: InfoBarSeverity.success);

        // Refresh the library
        final library = Provider.of<Library>(context, listen: false);
        library.reloadLibrary();
      } else {
        snackBar('Failed to apply formatting', severity: InfoBarSeverity.error);
      }
    } catch (e) {
      logErr('Error applying formatting', e);
      snackBar('Error: $e', severity: InfoBarSeverity.error);
    }
  }

  void issueScrollMove() {
    // Get current position
    final currentPos = issueController.position.pixels;

    // Compare with previous position before updating
    if (currentPos != prevPos) //
      nextFrame(() => _scrollController.animateTo(380, duration: Duration(milliseconds: 300), curve: Curves.ease));

    // Update previous position after comparison
    prevPos = currentPos;
  }

  @override
  void initState() {
    super.initState();
    _headerHeight = ScreenUtils.minHeaderHeight;

    issueController.addListener(issueScrollMove);

    nextFrame(() {
      final settings = Provider.of<SettingsManager>(context, listen: false);
      tempColor = settings.accentColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final library = Provider.of<Library>(context);
    final settings = Provider.of<SettingsManager>(context);

    return ScaffoldPage(
      content: Padding(
        padding: const EdgeInsets.only(top: 15),
        child: Stack(
          children: [
            // Body
            Positioned(
              child: SizedBox(
                width: ScreenUtils.maxContentWidth - ScreenUtils.infoBarWidth,
                child: FadingEdgeScrollView(
                  fadeEdges: const EdgeInsets.only(top: 70, bottom: 32),
                  debug: false,
                  child: DynMouseScroll(
                    enableSmoothScroll: Manager.animationsEnabled,
                    scrollSpeed: 2.0,
                    controller: _scrollController,
                    durationMS: 300,
                    animationCurve: Curves.ease,
                    // ignore: no_leading_underscores_for_local_identifiers
                    builder: (context, _controller, physics) {
                      return ListView(
                        controller: _controller,
                        physics: physics,
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 80, bottom: 20),
                        children: [
                          // Library location section
                          SettingsCard(
                            children: [
                              Text(
                                'Library Location',
                                style: FluentTheme.of(context).typography.subtitle,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Select the folder that contains your media library. '
                                'The app will scan this folder for video files.',
                                style: FluentTheme.of(context).typography.body,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextBox(
                                      placeholder: 'No folder selected',
                                      controller: TextEditingController(text: library.libraryPath ?? ''),
                                      readOnly: true,
                                      enabled: false,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  LoadingButton(
                                    label: 'Scan Library',
                                    onPressed: () {
                                      library.reloadLibrary();
                                    },
                                    isLoading: library.isLoading,
                                    isSmall: true,
                                    isAlreadyBig: true,
                                  ),
                                  const SizedBox(width: 6),
                                  FilledButton(
                                    child: const Text('Browse'),
                                    onPressed: () async {
                                      final result = await FilePicker.platform.getDirectoryPath(
                                        dialogTitle: 'Select Library Folder',
                                      );

                                      if (result != null) library.setLibraryPath(result);
                                    },
                                  ),
                                ],
                              ),
                              if (library.libraryPath != null) ...[],

                              const SizedBox(height: 24),
                              Text(
                                'Series Formatter',
                                style: FluentTheme.of(context).typography.subtitle,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'The Series Formatter helps organize your media files into a standardized structure.',
                                style: FluentTheme.of(context).typography.body,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  FilledButton(
                                    child: Text('Format Library Series'),
                                    onPressed: () => _showSeriesFormatterDialog(context),
                                  ),
                                ],
                              ),

                              // This section will show series with formatting issues
                              if (_issuesPreview.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                Text('Last Scan: ', style: FluentTheme.of(context).typography.subtitle),
                                const SizedBox(height: 12),
                                Text(
                                  "Series that couldn't be automatically formatted (${_issuesPreview.length})",
                                  style: FluentTheme.of(context).typography.bodyStrong,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: min(500, _issuesPreview.length * 100),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: FluentTheme.of(context).resources.controlStrokeColorDefault,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DynMouseScroll(
                                    enableSmoothScroll: Manager.animationsEnabled,
                                    scrollAmount: 200,
                                    controller: issueController,
                                    durationMS: 300,
                                    animationCurve: Curves.ease,
                                    builder: (context, newIssueController, physics) {
                                      return ListView.builder(
                                        itemCount: _issuesPreview.length,
                                        controller: newIssueController,
                                        physics: physics,
                                        itemBuilder: (context, index) {
                                          final preview = _issuesPreview[index];
                                          final series = library.getSeriesByPath(preview.seriesPath);

                                          return _buildSeriesIssueItem(context, preview, series, _issuesPreview, index);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Appearance section
                          Builder(builder: (context) {
                            final appTheme = context.watch<AppTheme>();

                            return SettingsCard(
                              children: [
                                Text(
                                  'Appearance',
                                  style: FluentTheme.of(context).typography.subtitle,
                                ),
                                const SizedBox(height: 6),
                                // Theme and font effect settings
                                ...[
                                  Text('Edit how MiruRyoiki looks and feels.', style: FluentTheme.of(context).typography.body),
                                  const SizedBox(height: 24),
                                  // Row(children: [
                                  //   // Theme
                                  //   const Text('Theme:'),
                                  //   const SizedBox(width: 12),
                                  //   ComboBox<ThemeMode>(
                                  //     value: appTheme.mode,
                                  //     items: <ThemeMode>[ThemeMode.system, ThemeMode.light, ThemeMode.dark].map((ThemeMode value) {
                                  //       return ComboBoxItem<ThemeMode>(
                                  //         value: value,
                                  //         child: Text(value.name.titleCase),
                                  //       );
                                  //     }).toList(),
                                  //     onChanged: (ThemeMode? newValue) async {
                                  //       appTheme.mode = newValue!;
                                  //       appTheme.setEffect(appTheme.windowEffect, context);
                                  //       settings.set('themeMode', newValue.name_);

                                  //       await Future.delayed(const Duration(milliseconds: 300));
                                  //       appTheme.setEffect(appTheme.windowEffect, context);
                                  //     },
                                  //   ),
                                  // ]),
                                ],
                                // const SizedBox(height: 12),
                                // Effect
                                ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Text('Effect:'),
                                            const SizedBox(width: 12),
                                            ComboBox<WindowEffect>(
                                              value: appTheme.windowEffect,
                                              items: _PlatformWindowEffects.map((WindowEffect value) {
                                                return ComboBoxItem<WindowEffect>(
                                                  value: value,
                                                  child: Text(value.name_),
                                                );
                                              }).toList(),
                                              onChanged: (WindowEffect? newValue) {
                                                appTheme.windowEffect = newValue!;
                                                appTheme.setEffect(newValue, context);
                                                settings.set('windowEffect', newValue.name);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!Manager.isWin11)
                                        TooltipTheme(
                                          data: TooltipThemeData(waitDuration: const Duration(milliseconds: 100)),
                                          child: Tooltip(
                                            message: 'Mica Effect is unfortunately only available on Windows 11',
                                            child: Opacity(opacity: .5, child: Icon(FluentIcons.info)),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 12),
                                // Accent Color
                                ...[
                                  Row(
                                    children: [
                                      const Text('Accent Color:'),
                                      const SizedBox(width: 12),
                                      FlyoutTarget(
                                        controller: controller,
                                        child: GestureDetector(
                                          child: Container(
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(
                                              color: settings.accentColor,
                                              border: Border.all(
                                                color: settings.accentColor.lerpWith(Colors.black, .25),
                                                width: 1.25,
                                              ),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          onTapDown: (details) {
                                            final Offset offset = details.localPosition;
                                            final RenderBox renderBox = context.findRenderObject() as RenderBox;
                                            final Offset globalOffset = renderBox.localToGlobal(offset);
                                            final Offset flyoutOffset = Offset(globalOffset.dx, globalOffset.dy + renderBox.size.height/3);
                                            
                                            // ignore: avoid_single_cascade_in_expression_statements
                                            controller.showFlyout(
                                              autoModeConfiguration: FlyoutAutoConfiguration(
                                                preferredMode: FlyoutPlacementMode.right,
                                                horizontal: true,
                                              ),
                                              barrierDismissible: true,
                                              dismissOnPointerMoveAway: true,
                                              dismissWithEsc: true,
                                              navigatorKey: rootNavigatorKey.currentState,
                                              position: flyoutOffset,
                                              builder: (context) {
                                                return FlyoutContent(
                                                  child: ColorPicker(
                                                    color: settings.accentColor,
                                                    onChanged: (color) {
                                                      tempColor = color;
                                                    },
                                                    minValue: 100,
                                                    isAlphaSliderVisible: true,
                                                    colorSpectrumShape: ColorSpectrumShape.box,
                                                    isMoreButtonVisible: false,
                                                    isColorSliderVisible: false,
                                                    isColorChannelTextInputVisible: false,
                                                    isHexInputVisible: false,
                                                    isAlphaEnabled: false,
                                                  ),
                                                );
                                              },
                                            )..then((_) {
                                                settings.accentColor = tempColor;
                                                appTheme.color = settings.accentColor.toAccentColor();
                                                settings.set('accentColor', settings.accentColor.toHex(leadingHashSign: true));
                                              });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                // Extra dim for acrylic and mica
                                if (appTheme.windowEffect == WindowEffect.aero || appTheme.windowEffect == WindowEffect.acrylic || appTheme.windowEffect == WindowEffect.mica) //
                                  ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Text('Dim'),
                                      const SizedBox(width: 12),
                                      EnumToggle<Dim>(
                                        enumValues: Dim.values,
                                        labelExtractor: (value) => value.name_,
                                        currentValue: appTheme.dim,
                                        onChanged: (value) {
                                          appTheme.dim = value;
                                          settings.set('dim', value.name_.toLowerCase());
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 12),
                                // Font Size
                                ...[
                                  Row(
                                    children: [
                                      const Text('Font Size:'),
                                      const SizedBox(width: 12),
                                      ComboBox<double>(
                                        value: appTheme.fontSize,
                                        items: <double>[10, 12, 14, 16, 18, 20].map((double value) {
                                          return ComboBoxItem<double>(
                                            value: value,
                                            child: Text(value.toString()),
                                          );
                                        }).toList(),
                                        onChanged: (double? newValue) {
                                          appTheme.fontSize = newValue!;
                                          settings.set('fontSize', newValue);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 12),
                                // Disable Animations
                                ...[
                                  Row(
                                    children: [
                                      Text(
                                        'Disable Most Animations',
                                        style: FluentTheme.of(context).typography.body,
                                      ),
                                      const SizedBox(width: 12),
                                      ToggleSwitch(
                                        checked: settings.disableAnimations,
                                        content: settings.disableAnimations ? const Text('Animations Disabled') : const Text('Animations Enabled'),
                                        onChanged: (value) {
                                          settings.disableAnimations = value;
                                          settings.set('disableAnimations', value);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 12),
                                // Library colors
                                ...[
                                  Row(
                                    children: [
                                      Text(
                                        'Library Cards Colors',
                                        style: FluentTheme.of(context).typography.body,
                                      ),
                                      const SizedBox(width: 12),
                                      ToggleSwitch(
                                        checked: showAccentLibViewCol,
                                        onChanged: (value) => setState(() {
                                          showAccentLibViewCol = value;

                                          // Convert between equivalent modes when toggle changes
                                          switch (settings.libColView) {
                                            case LibraryColorView.alwaysAccent:
                                            case LibraryColorView.alwaysDominant:
                                              settings.libColView = value ? LibraryColorView.alwaysAccent : LibraryColorView.alwaysDominant;
                                              break;

                                            case LibraryColorView.hoverAccent:
                                            case LibraryColorView.hoverDominant:
                                              settings.libColView = value ? LibraryColorView.hoverAccent : LibraryColorView.hoverDominant;
                                              break;

                                            case LibraryColorView.none:
                                              settings.libColView = LibraryColorView.none;
                                              break;
                                          }
                                          settings.set('libColView', settings.libColView.name_);
                                        }),
                                      ),
                                      Builder(builder: (context) {
                                        final List<double> customWidths = [140.0, 130, 80.0];

                                        // Define the options based on current toggle state
                                        final options = showAccentLibViewCol ? [LibraryColorView.alwaysAccent, LibraryColorView.hoverAccent, LibraryColorView.none] : [LibraryColorView.alwaysDominant, LibraryColorView.hoverDominant, LibraryColorView.none];

                                        // Find the correct index in our filtered list
                                        int initialIndex = options.indexOf(settings.libColView);
                                        if (initialIndex < 0) initialIndex = 0; // Fallback

                                        return Flexible(
                                          child: toggle.ToggleSwitch(
                                            animate: true,
                                            multiLineText: true,
                                            animationDuration: getDuration(dimDuration).inMilliseconds,
                                            initialLabelIndex: initialIndex,
                                            totalSwitches: 3,
                                            activeFgColor: getPrimaryColorBasedOnAccent(),
                                            activeBgColor: [FluentTheme.of(context).accentColor.lighter],
                                            customWidths: customWidths,
                                            labels: options.map((opt) => opt.name_).toList(),
                                            onToggle: (int? value) {
                                              if (value != null && value >= 0 && value < options.length) {
                                                settings.libColView = options[value];
                                                settings.set('libColView', settings.libColView.name_);
                                              }
                                            },
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ],
                                ...[
                                  // Add this to the UI settings section
                                  const SizedBox(height: 12),
                                  Text('Dominant Color Source:'),
                                  const SizedBox(height: 12),
                                  EnumToggle<DominantColorSource>(
                                    enumValues: DominantColorSource.values,
                                    labelExtractor: (value) => value.name_,
                                    currentValue: settings.dominantColorSource,
                                    onChanged: (value) {
                                      showSimpleManagedDialog(
                                        context: context,
                                        id: 'dominantColorSource',
                                        title: 'Recalculate Colors?',
                                        body: 'Would you like to recalculate all dominant colors using the new source?',
                                        onPositive: () {
                                          settings.dominantColorSource = value;
                                          settings.set('dominantColorSource', value.name_);
                                          final library = Provider.of<Library>(context, listen: false);
                                          library.calculateDominantColors(forceRecalculate: true);

                                          snackBar(
                                            'Dominant colors recalculated using ${value.name_} source.',
                                            severity: InfoBarSeverity.info,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                                //
                              ],
                            );
                          }),
                          const SizedBox(height: 24),
                          // Behavior section
                          SettingsCard(
                            children: [
                              Text(
                                'Behavior',
                                style: FluentTheme.of(context).typography.subtitle,
                              ),
                              const SizedBox(height: 12),
                              // Text(
                              //   'Automatically load Anilist posters for series without local posters.',
                              //   style: FluentTheme.of(context).typography.body,
                              // ),
                              // const SizedBox(height: 12),
                              // ToggleSwitch(
                              //   checked: settings.autoLoadAnilistPosters,
                              //   content: const Text('Anilist posters will be automatically loaded for series without local images'),
                              //   onChanged: (value) {
                              //     settings.autoLoadAnilistPosters = value;
                              //     settings.set('autoLoadAnilistPosters', value);
                              //   },
                              // ),
                              // //
                              // const SizedBox(height: 24),
                              Row(
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        'Default Poster source for series.',
                                        style: FluentTheme.of(context).typography.body,
                                      ),
                                      const SizedBox(height: 12),
                                      ToggleSwitch(
                                        checked: Manager.defaultPosterSource == ImageSource.autoAnilist,
                                        content: Manager.defaultPosterSource == ImageSource.autoAnilist ? Text('Prefer Anilist Posters') : Text('Prefer Local Posters'),
                                        onChanged: (value) {
                                          settings.defaultPosterSource = value ? ImageSource.autoAnilist : ImageSource.autoLocal;
                                          settings.set('defaultPosterSource', settings.defaultPosterSource.name_);
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 24),
                                  Column(
                                    children: [
                                      Text(
                                        'Default Banner source for series.',
                                        style: FluentTheme.of(context).typography.body,
                                      ),
                                      const SizedBox(height: 12),
                                      ToggleSwitch(
                                        checked: Manager.defaultBannerSource == ImageSource.autoAnilist,
                                        content: Manager.defaultBannerSource == ImageSource.autoAnilist ? Text('Prefer Anilist Banners') : Text('Prefer Local Banners'),
                                        onChanged: (value) {
                                          settings.defaultBannerSource = value ? ImageSource.autoAnilist : ImageSource.autoLocal;
                                          settings.set('defaultBannerSource', settings.defaultBannerSource.name_);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // About section
                          SettingsCard(
                            children: [
                              Text(
                                'About ${Manager.appTitle}',
                                style: FluentTheme.of(context).typography.subtitle,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                '${Manager.appTitle} is a video tracking application that integrates with '
                                'Media Player Classic: Home Cinema to track your watched videos.',
                              ),
                              const SizedBox(height: 24),
                              const InfoBar(
                                title: Text('MPC-HC Integration'),
                                content: Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    'This app reads data from the Windows Registry to detect videos played in MPC-HC. '
                                    'Please ensure MPC-HC is installed and configured properly.',
                                  ),
                                ),
                                severity: InfoBarSeverity.info,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            // Sticky header
            Positioned.fill(
              top: 0,
              child: AnimatedContainer(
                height: _headerHeight,
                width: double.infinity,
                duration: stickyHeaderDuration,
                curve: Curves.ease,
                alignment: Alignment.topCenter,
                child: PageHeader(title: const Text('Settings')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card with vertically distributed children
Widget SettingsCard({required List<Widget> children}) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    ),
  );
}
