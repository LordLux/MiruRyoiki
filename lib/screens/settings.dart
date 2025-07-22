// import 'package:flutter/material.dart';
// ignore_for_file: use_build_context_synchronously

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:miruryoiki/widgets/gradient_mask.dart';
import 'package:miruryoiki/widgets/buttons/loading_button.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:toggle_switch/toggle_switch.dart' as toggle;
import 'dart:io';

import '../enums.dart';
import '../functions.dart';
import '../main.dart';
import '../manager.dart';
import '../models/formatter/action.dart';
import '../models/series.dart';
import '../services/navigation/dialogs.dart';
import '../services/navigation/shortcuts.dart';
import '../services/navigation/show_info.dart';
import '../settings.dart';
import '../utils/color_utils.dart';
import '../utils/logging.dart';
import '../services/library/library_provider.dart';
import '../theme.dart';
import '../utils/path_utils.dart';
import '../utils/screen_utils.dart';
import '../utils/time_utils.dart';
import '../widgets/buttons/button.dart';
import '../widgets/buttons/wrapper.dart';
import '../widgets/enum_toggle.dart';
import '../widgets/series_image.dart';

class SettingsScreen extends StatefulWidget {
  final ScrollController scrollController;

  const SettingsScreen({super.key, required this.scrollController});

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
  bool _isOpenFolderHovered = false;

  bool showAccentLibViewCol = false;

  double prevPos = 0;

  bool _isSelectingFolder = false;

  final FocusNode fontSizeFocusNode = FocusNode();

  Widget standard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Standard Format Structure:', style: Manager.bodyStrongStyle),
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
                      TextSpan(text: '📁 ', style: Manager.bodyStyle.copyWith(fontFamily: 'Segoe UI Emoji')),
                      TextSpan(text: 'Series Name: ', style: Manager.bodyStyle),
                      TextSpan(
                        text: '<any Windows compatible name>',
                        style: Manager.bodyStyle.copyWith(color: Manager.accentColor.lightest, fontWeight: FontWeight.bold),
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
                        TextSpan(text: '📁 ', style: Manager.bodyStyle.copyWith(fontFamily: 'Segoe UI Emoji')),
                        TextSpan(text: 'Season Folders: ', style: Manager.bodyStyle),
                        TextSpan(
                          text: 'Season XX',
                          style: Manager.bodyStyle.copyWith(color: Manager.accentColor.lightest, fontWeight: FontWeight.bold),
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
                        TextSpan(text: '🎬 ', style: Manager.bodyStyle.copyWith(fontFamily: 'Segoe UI Emoji')),
                        TextSpan(text: 'Episodes: ', style: Manager.bodyStyle),
                        TextSpan(
                          text: 'XX - Episode Title.ext',
                          style: Manager.bodyStyle.copyWith(color: Manager.accentColor.lightest, fontWeight: FontWeight.bold),
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
                        TextSpan(text: '📁 ', style: Manager.bodyStyle.copyWith(fontFamily: 'Segoe UI Emoji')),
                        TextSpan(text: 'Related Media', style: Manager.bodyStrongStyle),
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
                        TextSpan(text: '🎬 ', style: Manager.bodyStyle.copyWith(fontFamily: 'Segoe UI Emoji')),
                        TextSpan(text: 'Specials: ', style: Manager.bodyStyle),
                        TextSpan(
                          text: 'SPXX - Special Title.ext',
                          style: Manager.bodyStyle.copyWith(color: Manager.accentColor.lightest, fontWeight: FontWeight.bold),
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
                        TextSpan(text: '🎬 ', style: Manager.bodyStyle.copyWith(fontFamily: 'Segoe UI Emoji')),
                        TextSpan(text: 'Movies: ', style: Manager.bodyStyle),
                        TextSpan(
                          text: 'Movie Title.ext',
                          style: Manager.bodyStyle.copyWith(color: Manager.accentColor.lightest, fontWeight: FontWeight.bold),
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
        Text('Note: XX represents a 2 > digit number (01, 02, 100, etc.)', style: Manager.captionStyle),
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
                  TextSpan(text: 'not', style: Manager.bodyStrongStyle.copyWith(color: Colors.red, fontWeight: FontWeight.bold)),
                  TextSpan(text: ' modify any files until you confirm the changes in the next dialog.'),
                ],
              ),
              style: Manager.captionStyle,
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
          final Map<PathString, SeriesFormatPreview> results = await formatLibrary(
            seriesPaths: seriesPaths,
            progressCallback: (processed, total) {
              // You could update progress here if desired
              logTrace('Formatter progress: $processed/$total');
            },
          );

          // Process results
          _showFormatterResults(context, results);
        } catch (e, stackTrace) {
          Navigator.of(context).pop(); // Close loading dialog
          snackBar(
            'Error scanning library during series formatting: $e',
            severity: InfoBarSeverity.error,
            exception: e,
            stackTrace: stackTrace,
          );
        } finally {
          setState(() {
            _isFormatting = false;
          });
        }
      },
    );
  }

  // Show results dialog
  void _showFormatterResults(BuildContext context, Map<PathString, SeriesFormatPreview> results) {
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
        title: Text('Formatter Results', style: Manager.titleLargeStyle),
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
                        TextSpan(text: "Found ${results.length} series with $totalActions suggested changes.\n", style: Manager.subtitleStyle),
                        WidgetSpan(child: SizedBox(height: 16)),
                        TextSpan(text: "Don't worry about the big number of changes, the majority of them are just renaming files and folders to match the standard structure.  ", style: Manager.captionStyle),
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
                    style: Manager.bodyLargeStyle,
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
                              Text('Summary:', style: Manager.bodyStrongStyle),
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
                                  style: Manager.bodyStyle.copyWith(color: Colors.orange),
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
  Future<void> _applyFormatting(BuildContext context, Map<PathString, SeriesFormatPreview> results, {required bool skipIssues}) async {
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
              Text('Formatting your library...\nThis may take a moment.', style: Manager.bodyStyle),
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
          library.reloadLibrary(force: true);
        },
      );
    } catch (e, stackTrace) {
      Navigator.of(context).pop(); // Close loading dialog
      snackBar(
        'Error applying formatting: $e',
        severity: InfoBarSeverity.error,
        exception: e,
        stackTrace: stackTrace,
      );
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
          Text(value, style: Manager.bodyStrongStyle),
        ],
      ),
    );
  }

// Helper method to count actions of a specific type
  int _countActionType(Map<PathString, SeriesFormatPreview> results, ActionType type) {
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
            SeriesImageBuilder.poster(
              series,
              width: 91 * ScreenUtils.kDefaultAspectRatio,
              height: 91,
              fit: BoxFit.contain,
              alignment: Alignment.center,
              skipLoadingIndicator: true,
            )
          else
            Container(
              width: 91 * ScreenUtils.kDefaultAspectRatio,
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
                  style: Manager.bodyStrongStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '${preview.actions.length} changes recommended',
                  style: Manager.captionStyle,
                ),
                SizedBox(height: 4),
                if (preview.issues.length == 1)
                  Text(
                    'Issue: ${preview.issues.take(1).join(", ")}',
                    style: Manager.bodyStyle.copyWith(color: Colors.orange),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (preview.issues.length > 1)
                  Expander(
                    header: Text('Issues (${preview.issues.length})', style: Manager.bodyStyle.copyWith(color: Colors.orange)),
                    content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: preview.issues.map((issue) => Text(issue, style: Manager.bodyStyle.copyWith(color: Colors.orange))).toList()),
                  ),
              ],
            ),
          ),

          // Action buttons
          Row(
            children: [
              // TODO
              MouseButtonWrapper(
                tooltip: 'View Series',
                child: (_) => IconButton(
                  icon: Icon(FluentIcons.view),
                  onPressed: () {
                    // Navigate to series
                    _navigateToSeries(context, preview.seriesPath);
                  },
                ),
              ),
              SizedBox(width: 8),
              MouseButtonWrapper(
                tooltip: 'Apply Formatting',
                child: (_) => IconButton(
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
  void _navigateToSeries(BuildContext context, PathString seriesPath) {
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
    } catch (e, stackTrace) {
      snackBar(
        'Error: $e',
        severity: InfoBarSeverity.error,
        exception: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _headerHeight = ScreenUtils.kMinHeaderHeight;

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
                width: ScreenUtils.kMaxContentWidth - ScreenUtils.kInfoBarWidth,
                child: FadingEdgeScrollView(
                  fadeEdges: const EdgeInsets.only(top: 70, bottom: 32),
                  debug: false,
                  child: ValueListenableBuilder(
                      valueListenable: KeyboardState.ctrlPressedNotifier,
                      builder: (context, isCtrlPressed, _) {
                        return DynMouseScroll(
                          stopScroll: KeyboardState.ctrlPressedNotifier,
                          enableSmoothScroll: Manager.animationsEnabled,
                          scrollSpeed: 2.0,
                          controller: widget.scrollController,
                          durationMS: 300,
                          animationCurve: Curves.ease,
                          // ignore: no_leading_underscores_for_local_identifiers
                          builder: (context, _controller, physics) {
                            return ListView(
                              controller: _controller,
                              physics: isCtrlPressed ? const NeverScrollableScrollPhysics() : physics,
                              padding: const EdgeInsets.only(left: 20, right: 20, top: 80, bottom: 20),
                              children: [
                                // Library location section
                                SettingsCard(
                                  children: [
                                    Text(
                                      'Library Location',
                                      style: Manager.subtitleStyle,
                                    ),
                                    VDiv(12),
                                    Text(
                                      'Select the folder that contains your media library. '
                                      'The app will scan this folder for video files.',
                                      style: Manager.bodyStyle,
                                    ),
                                    VDiv(24),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            height: 34,
                                            child: Stack(
                                              alignment: Alignment.centerRight,
                                              children: [
                                                TextBox(
                                                  placeholder: 'No folder selected',
                                                  controller: TextEditingController(text: library.libraryPath ?? ''),
                                                  readOnly: true,
                                                  enabled: false,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(3),
                                                  child: ValueListenableBuilder(
                                                      valueListenable: KeyboardState.shiftPressedNotifier,
                                                      builder: (context, isShiftPressed, _) {
                                                        return MouseButtonWrapper(
                                                          tooltip: isShiftPressed ? 'Copy Library Folder Path' : 'Open Library Folder',
                                                          child: (_) => SizedBox(
                                                            height: 28,
                                                            child: MouseRegion(
                                                              onEnter: (_) => setState(() => _isOpenFolderHovered = true),
                                                              onExit: (_) => setState(() => _isOpenFolderHovered = false),
                                                              child: IconButton(
                                                                icon: Transform.translate(
                                                                  offset: isShiftPressed ? Offset(-.5, -.5) : Offset(0, -1),
                                                                  child: AnimatedRotation(
                                                                    turns: isShiftPressed ? -0.125 : 0,
                                                                    duration: getDuration(const Duration(milliseconds: 40)),
                                                                    child: Icon(
                                                                      isShiftPressed ? Symbols.link : (_isOpenFolderHovered ? Symbols.folder_open : Symbols.folder),
                                                                      size: 18,
                                                                      color: FluentTheme.of(context).resources.textFillColorPrimary,
                                                                    ),
                                                                  ),
                                                                ),
                                                                onPressed: library.libraryPath == null
                                                                    ? null
                                                                    : () {
                                                                        if (isShiftPressed) {
                                                                          // Copy path to clipboard
                                                                          snackBar('Library path copied to clipboard', severity: InfoBarSeverity.success);
                                                                          copyToClipboard(library.libraryPath!);
                                                                          return;
                                                                        }
                                                                        // Open path in file explorer
                                                                        try {
                                                                          Process.run('explorer', [library.libraryPath!]);
                                                                        } catch (e, stackTrace) {
                                                                          snackBar(
                                                                            'Failed to open library folder: $e',
                                                                            severity: InfoBarSeverity.error,
                                                                            exception: e,
                                                                            stackTrace: stackTrace,
                                                                          );
                                                                        }
                                                                      },
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        LoadingButton(
                                          label: 'Scan Library',
                                          onPressed: () => library.reloadLibrary(force: true),
                                          isLoading: library.isLoading,
                                          isSmall: true,
                                          isAlreadyBig: true,
                                        ),
                                        const SizedBox(width: 6),
                                        NormalButton(
                                          label: 'Browse',
                                          isFilled: true,
                                          isSmall: true,
                                          tooltip: 'Select Library Folder',
                                          isLoading: _isSelectingFolder,
                                          onPressed: () async {
                                            setState(() => _isSelectingFolder = true);

                                            final result = await FilePicker.platform.getDirectoryPath(
                                              dialogTitle: 'Select Library Folder',
                                            );

                                            setState(() => _isSelectingFolder = false);

                                            if (result != null) library.setLibraryPath(result);
                                          },
                                        ),
                                      ],
                                    ),
                                    if (library.libraryPath != null) ...[],

                                    VDiv(24),
                                    Text(
                                      'Series Formatter',
                                      style: Manager.subtitleStyle,
                                    ),
                                    VDiv(12),
                                    Text(
                                      'The Series Formatter helps organize your media files into a standardized structure.',
                                      style: Manager.bodyStyle,
                                    ),
                                    VDiv(16),
                                    NormalButton(
                                      label: 'Format Series',
                                      isLoading: _isFormatting,
                                      isFilled: true,
                                      onPressed: () => _showSeriesFormatterDialog(context),
                                    ),

                                    // This section will show series with formatting issues
                                    if (_issuesPreview.isNotEmpty) ...[
                                      VDiv(24),
                                      Text('Last Scan: ', style: Manager.subtitleStyle),
                                      VDiv(12),
                                      Expander(
                                        header: Text(
                                          "Series that couldn't be automatically parsed (${_issuesPreview.length})",
                                          style: Manager.bodyStrongStyle,
                                        ),
                                        initiallyExpanded: true,
                                        content: SizedBox(
                                          height: 117.0 * _issuesPreview.length,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: _issuesPreview.map((preview) {
                                                final series = library.getSeriesByPath(preview.seriesPath);
                                                return _buildSeriesIssueItem(context, preview, series, _issuesPreview, _issuesPreview.indexOf(preview));
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                VDiv(24),
                                // Appearance section
                                Builder(builder: (context) {
                                  final appTheme = context.watch<AppTheme>();

                                  return SettingsCard(
                                    children: [
                                      Text(
                                        'Appearance',
                                        style: Manager.subtitleStyle,
                                      ),
                                      VDiv(6),
                                      // Theme and font effect settings
                                      ...[
                                        Text('Edit how MiruRyoiki looks and feels.', style: Manager.bodyStyle),
                                        VDiv(24),
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
                                        //       settings.themeMode = newValue;

                                        //       await Future.delayed(const Duration(milliseconds: 300));
                                        //       appTheme.setEffect(appTheme.windowEffect, context);
                                        //     },
                                        //   ),
                                        // ]),
                                      ],
                                      // VDiv(12),
                                      // Effect
                                      ...[
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Text('Effect:', style: Manager.bodyStyle),
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
                                                      settings.windowEffect = newValue;
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
                                      VDiv(12),
                                      // Accent Color
                                      ...[
                                        Row(
                                          children: [
                                            Text('Accent Color:', style: Manager.bodyStyle),
                                            const SizedBox(width: 12),
                                            FlyoutTarget(
                                              controller: controller,
                                              child: GestureDetector(
                                                child: Container(
                                                  width: 34,
                                                  height: 34,
                                                  decoration: BoxDecoration(
                                                    color: settings.accentColor.toAccentColor().light,
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
                                                  final Offset flyoutOffset = Offset(globalOffset.dx, globalOffset.dy + renderBox.size.height / 3);

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
                                                          isAlphaSliderVisible: false,
                                                          colorSpectrumShape: ColorSpectrumShape.ring,
                                                          isMoreButtonVisible: false,
                                                          isColorSliderVisible: false,
                                                          isColorChannelTextInputVisible: false,
                                                          isHexInputVisible: false,
                                                          minSaturation: 80,
                                                          maxSaturation: 80,
                                                          isAlphaEnabled: false,
                                                        ),
                                                      );
                                                    },
                                                  )..then((_) {
                                                      settings.accentColor = tempColor.saturate(300);
                                                      appTheme.color = settings.accentColor.toAccentColor();
                                                      settings.accentColor = settings.accentColor;
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
                                        VDiv(12),
                                        Row(
                                          children: [
                                            Text('Dim', style: Manager.bodyStyle),
                                            const SizedBox(width: 12),
                                            EnumToggle<Dim>(
                                              enumValues: Dim.values,
                                              labelExtractor: (value) => value.name_,
                                              currentValue: appTheme.dim,
                                              onChanged: (value) {
                                                appTheme.dim = value;
                                                settings.dim = value;
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                      VDiv(12),
                                      // Font Size
                                      ...[
                                        Row(
                                          children: [
                                            Text('Font Size:', style: Manager.bodyStyle),
                                            const SizedBox(width: 12),
                                            ComboBox<double>(
                                              focusNode: fontSizeFocusNode,
                                              value: appTheme.fontSize,
                                              items: <double>[for (double i = ScreenUtils.kMinFontSize; i <= ScreenUtils.kMaxFontSize; i += 2) i].map((double value) {
                                                return ComboBoxItem<double>(
                                                  value: value,
                                                  child: Text(value.toString()),
                                                );
                                              }).toList(),
                                              onChanged: (double? newValue) {
                                                appTheme.fontSize = newValue!;
                                                settings.fontSize = newValue;
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                      VDiv(16),
                                      // Disable Animations
                                      ...[
                                        Row(
                                          children: [
                                            Text(
                                              'Disable Most Animations',
                                              style: Manager.bodyStyle,
                                            ),
                                            const SizedBox(width: 12),
                                            ToggleSwitch(
                                              checked: settings.disableAnimations,
                                              content: Text(settings.disableAnimations ? 'Animations Disabled' : 'Animations Enabled', style: Manager.bodyStyle),
                                              onChanged: (value) {
                                                settings.disableAnimations = value;
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                      VDiv(12),
                                      // Library colors
                                      ...[
                                        Row(
                                          children: [
                                            Text(
                                              'Library Cards Colors',
                                              style: Manager.bodyStyle,
                                            ),
                                            const SizedBox(width: 12),
                                            ToggleSwitch(
                                              checked: showAccentLibViewCol,
                                              content: Text(showAccentLibViewCol ? 'Accent' : 'Dominant', style: Manager.bodyStyle),
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
                                              }),
                                            ),
                                            const SizedBox(width: 12),
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
                                                  animationDuration: dimDuration.inMilliseconds,
                                                  initialLabelIndex: initialIndex,
                                                  totalSwitches: 3,
                                                  customTextStyles: [
                                                    for (var i = 0; i < options.length; i++) Manager.bodyStyle.copyWith(color: initialIndex == i ? getPrimaryColorBasedOnAccent() : null),
                                                  ],
                                                  activeFgColor: getPrimaryColorBasedOnAccent(),
                                                  activeBgColor: [FluentTheme.of(context).accentColor.lighter],
                                                  customWidths: customWidths,
                                                  labels: options.map((opt) => opt.name_).toList(),
                                                  onToggle: (int? value) {
                                                    if (value != null && value >= 0 && value < options.length) {
                                                      settings.libColView = options[value];
                                                    }
                                                  },
                                                ),
                                              );
                                            }),
                                          ],
                                        ),
                                      ],
                                      VDiv(6),
                                      ...[
                                        Row(
                                          children: [
                                            Text('Dominant Color Source', style: Manager.bodyStyle),
                                            const SizedBox(width: 12),
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
                                        ),
                                      ],
                                      //
                                    ],
                                  );
                                }),
                                VDiv(24),
                                // Behavior section
                                SettingsCard(
                                  children: [
                                    Text(
                                      'Behavior',
                                      style: Manager.subtitleStyle,
                                    ),
                                    VDiv(12),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              'Default Poster source for series.',
                                              style: Manager.bodyStyle,
                                            ),
                                            VDiv(12),
                                            ToggleSwitch(
                                              checked: Manager.defaultPosterSource == ImageSource.autoAnilist,
                                              content: Text(Manager.defaultPosterSource == ImageSource.autoAnilist ? 'Prefer Anilist Posters' : 'Prefer Local Posters', style: Manager.bodyStyle),
                                              onChanged: (value) {
                                                settings.defaultPosterSource = value ? ImageSource.autoAnilist : ImageSource.autoLocal;
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 24),
                                        Column(
                                          children: [
                                            Text(
                                              'Default Banner source for series.',
                                              style: Manager.bodyStyle,
                                            ),
                                            VDiv(12),
                                            ToggleSwitch(
                                              checked: Manager.defaultBannerSource == ImageSource.autoAnilist,
                                              content: Text(Manager.defaultBannerSource == ImageSource.autoAnilist ? 'Prefer Anilist Banners' : 'Prefer Local Banners', style: Manager.bodyStyle),
                                              onChanged: (value) {
                                                settings.defaultBannerSource = value ? ImageSource.autoAnilist : ImageSource.autoLocal;
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 24),
                                // Logging section
                                SettingsCard(
                                  children: [
                                    Text(
                                      'Logging & Debugging',
                                      style: Manager.subtitleStyle,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Configure logging behavior for debugging and troubleshooting.',
                                      style: Manager.bodyStyle,
                                    ),
                                    SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'File log level',
                                                style: Manager.bodyStrongStyle,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Choose which log messages are written to file. Higher levels include all lower levels.',
                                                style: Manager.bodyStyle,
                                              ),
                                              SizedBox(height: 12),
                                              EnumToggle<LogLevel>(
                                                enumValues: LogLevel.values,
                                                labelExtractor: (level) => level.displayName,
                                                currentValue: settings.fileLogLevel,
                                                onChanged: (LogLevel newLevel) {
                                                  settings.fileLogLevel = newLevel;
                                                  setState(() {
                                                    if (newLevel == LogLevel.trace)
                                                      doLogTrace = true;
                                                    else
                                                      doLogTrace = false;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 32),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Log retention',
                                                style: Manager.bodyStrongStyle,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Number of days to keep log files. (0 to disable)\nOlder files are automatically deleted.',
                                                style: Manager.bodyStyle,
                                              ),
                                              SizedBox(height: 12),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Expanded(
                                                    child: NumberBox<int>(
                                                      value: settings.logRetentionDays,
                                                      onChanged: (int? value) {
                                                        if (value != null && value >= 0) settings.logRetentionDays = value;
                                                      },
                                                      min: 0,
                                                      max: 365,
                                                      mode: SpinButtonPlacementMode.inline,
                                                    ),
                                                  ),
                                                  HDiv(8),
                                                  Text(
                                                    'days',
                                                    style: Manager.bodyStyle.copyWith(
                                                      color: FluentTheme.of(context).resources.textFillColorSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    InfoBar(
                                      title: Text('Log Files Location', style: Manager.bodyStrongStyle),
                                      content: Padding(
                                        padding: EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          'Log files are stored in the application data directory. Each session creates a unique log file.',
                                          style: Manager.bodyStyle,
                                        ),
                                      ),
                                      severity: InfoBarSeverity.info,
                                    ),
                                    if (Manager.args.isNotEmpty) SizedBox(height: 16),
                                    if (Manager.args.isNotEmpty)
                                      InfoBar(
                                        title: Text('Command Line Arguments', style: Manager.bodyStrongStyle),
                                        content: Padding(
                                          padding: EdgeInsets.only(right: 8.0),
                                          child: Text(
                                            'Current session arguments: ${Manager.args.join(', ')}',
                                            style: Manager.bodyStyle,
                                          ),
                                        ),
                                        severity: InfoBarSeverity.info,
                                        isLong: Manager.args.isNotEmpty && Manager.args.join(', ').length > 50,
                                      )
                                  ],
                                ),
                                SizedBox(height: 24),
                                // About section
                                SettingsCard(
                                  children: [
                                    Text(
                                      'About ${Manager.appTitle}',
                                      style: Manager.subtitleStyle,
                                    ),
                                    VDiv(12),
                                    Text(
                                      '${Manager.appTitle} is a video tracking application that integrates with '
                                      'Media Player Classic: Home Cinema to track your watched videos.',
                                      style: Manager.bodyStyle,
                                    ),
                                    VDiv(24),
                                    InfoBar(
                                      title: Text('MPC-HC Integration', style: Manager.bodyStrongStyle),
                                      content: Padding(
                                        padding: EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          'This app reads data from the Windows Registry to detect videos played in MPC-HC. '
                                          'Please ensure MPC-HC is installed and configured properly.',
                                          style: Manager.bodyStyle,
                                        ),
                                      ),
                                      severity: InfoBarSeverity.info,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      }),
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
                child: PageHeader(title: Text('Settings', style: Manager.titleLargeStyle)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card with vertically distributed children
Widget SettingsCard({
  required List<Widget> children,
  EdgeInsets padding = const EdgeInsets.all(32.0),
}) {
  return Card(
    borderRadius: BorderRadius.circular(8.0),
    padding: EdgeInsets.zero,
    child: Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    ),
  );
}
