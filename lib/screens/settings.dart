// import 'package:flutter/material.dart';
// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as mat;
import 'package:flutter_acrylic/window_effect.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:miruryoiki/widgets/buttons/loading_button.dart';
import 'package:miruryoiki/widgets/page/infobar.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:toggle_switch/toggle_switch.dart' as toggle;
import 'dart:io';

import '../enums.dart';
import '../functions.dart';
import '../main.dart';
import '../manager.dart';
import '../models/formatter/action.dart';
import '../models/series.dart';
import '../services/data_storage_service.dart';
import '../services/lock_manager.dart';
import '../services/navigation/dialogs.dart';
import '../services/navigation/shortcuts.dart';
import '../services/navigation/show_info.dart';
import '../settings.dart';
import '../utils/color.dart';
import '../utils/database_recovery.dart';
import '../utils/logging.dart';
import '../services/library/library_provider.dart';
import '../theme.dart';
import '../utils/path.dart';
import '../utils/screen.dart';
import '../utils/time.dart';
import '../widgets/buttons/button.dart';
import '../widgets/buttons/hyperlink.dart';
import '../widgets/buttons/setting_category_button.dart';
import '../widgets/buttons/switch.dart';
import '../widgets/buttons/wrapper.dart';
import '../widgets/dialogs/database_recovery.dart';
import '../widgets/enum_toggle.dart';
import '../widgets/page/header_widget.dart';
import '../widgets/page/page.dart';
import '../widgets/series_image.dart';
import '../widgets/widget_image_provider.dart';

import '../services/players/player.dart';
import '../services/players/players/vlc_player.dart';
import '../services/players/players/mpc_hc_player.dart';

class SettingsScreen extends StatefulWidget {
  final ScrollController scrollController;

  const SettingsScreen({super.key, required this.scrollController});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

// ignore: non_constant_identifier_names
List<WindowEffect> _WindowsWindowEffects = [
  WindowEffect.acrylic,
  WindowEffect.solid,
  WindowEffect.aero,
  WindowEffect.transparent,
  if (Manager.isWin11) WindowEffect.mica,
];

List<WindowEffect> _MacOsWindowEffects = [
  WindowEffect.disabled,
  WindowEffect.solid,
  WindowEffect.titlebar, // macOS translucent titlebar
  WindowEffect.sidebar, // Finder-like sidebar effect
  WindowEffect.windowBackground, // Native macOS window background
  WindowEffect.contentBackground, // Content area background
];

// ignore: non_constant_identifier_names
List<WindowEffect> get _PlatformWindowEffects => switch (defaultTargetPlatform) {
      TargetPlatform.windows => _WindowsWindowEffects,
      TargetPlatform.macOS => _MacOsWindowEffects,
      _ => [WindowEffect.disabled],
    };

class SettingsScreenState extends State<SettingsScreen> {
  FlyoutController controller = FlyoutController();
  Color tempColor = Colors.transparent;
  List<SeriesFormatPreview> _issuesPreview = [];

  int _buildClicks = 0;
  Timer? _buildClickTimer;

  List<File> _availableBackups = [];
  final mat.ExpansionTileController expansionTileKey = mat.ExpansionTileController();
  bool _showBackupsList = false;
  bool _isRestoringBackup = false;

  // ignore: unused_field
  bool _isFormatting = false;
  bool _isOpenFolderHovered = false;

  bool showAccentLibViewCol = false;

  double prevPos = 0;

  bool _isSelectingFolder = false;
  bool _isClearingThumbnailCache = false;

  final FocusNode fontSizeFocusNode = FocusNode();

  int _selectedSettingCategory = 0;
  int _rotationCounter = 0;

  static List<Map<String, dynamic>> get settingsList => [
        {
          "title": "Library",
          "icon": Icon(mat.Icons.library_books, color: lighten(Manager.accentColor), size: 23),
        },
        {
          "title": "Appearance",
          "icon": Icon(mat.Icons.palette, color: lighten(Manager.accentColor), size: 23),
        },
        {
          "title": "Behavior",
          "icon": Icon(mat.Icons.tune, color: lighten(Manager.accentColor), size: 23),
        },
        {
          "title": "Players",
          "icon": Icon(mat.Icons.play_circle_outline, color: lighten(Manager.accentColor), size: 23),
        },
        {
          "title": "Data & Storage",
          "icon": Icon(mat.Icons.storage, color: lighten(Manager.accentColor), size: 23),
        },
        {
          "title": "Advanced",
          "icon": Icon(mat.Icons.settings, color: lighten(Manager.accentColor), size: 23),
        },
        {
          "title": "About ${Manager.appTitle}",
          "icon": Icon(mat.Icons.info, color: lighten(Manager.accentColor), size: 23),
        },
      ];

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
              // TODO make this button UI better
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

  Future<void> _toggleExpanderTile() async {
    setState(() => _showBackupsList = !_showBackupsList);
    nextFrame(() {
      if (mounted) {
        if (expansionTileKey.isExpanded)
          expansionTileKey.collapse();
        else
          expansionTileKey.expand();
      }
    });
  }

  void carpaccio() {
    _buildClicks++;
    if (_buildClicks == 1) {
      _buildClickTimer = Timer(Duration(seconds: 1), () {
        _buildClicks = 0;
      });
    } else if (_buildClicks >= 5) {
      _buildClickTimer?.cancel();
      _buildClicks = 0;
      snackBar('Carpaccio Sardo!', severity: InfoBarSeverity.info);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAvailableBackups();

    nextFrame(() {
      final settings = Provider.of<SettingsManager>(context, listen: false);
      tempColor = settings.accentColor;
    });
  }

  void _loadAvailableBackups() => setState(() => _availableBackups = DatabaseRecovery.getAvailableBackups());

  void _restoreBackup(File backupFile) async {
    try {
      bool confirmed = false;
      await showSimpleManagedDialog<bool>(
        context: context,
        id: 'restoreBackup',
        title: 'Restore Database',
        body: 'This will replace your current database with the selected backup.\n'
            'Your current database will be backed up first. Continue?',
        positiveButtonText: 'Restore Backup',
        isPositiveButtonPrimary: true,
        negativeButtonText: 'Cancel',
        onPositive: () => confirmed = true,
      );

      if (!confirmed) return;

      setState(() => _isRestoringBackup = true);
      final backupPath = await DataStorageService.restoreFromBackup(backupFile);

      if (backupPath != null) snackBar('Database restored successfully. Please restart the app.', severity: InfoBarSeverity.success);
    } catch (e) {
      snackBar('Failed to restore backup: $e', severity: InfoBarSeverity.error);
    } finally {
      setState(() => _isRestoringBackup = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final library = Provider.of<Library>(context);
    final settings = Provider.of<SettingsManager>(context);

    return MiruRyoikiTemplatePage(
      headerWidget: HeaderWidget(
        title: (_, __) => PageHeader(title: Transform.translate(offset: Offset(-5, 0), child: Text('Settings', style: Manager.titleLargeStyle))),
        headerPadding: EdgeInsets.zero,
      ),
      infobar: (noHeaderBanner) => _buildInfoBar(noHeaderBanner),
      content: _buildContent(library, settings),
      hideInfoBar: false,
      noHeaderBanner: true,
    );
  }

  MiruRyoikiInfobar _buildInfoBar(bool noHeaderBanner) {
    return MiruRyoikiInfobar(
      noHeaderBanner: noHeaderBanner,
      content: SizedBox(
        width: ScreenUtils.kInfoBarWidth,
        child: Column(
          children: [
            for (int i = 0; i < settingsList.length; i++)
              SettingCategoryButton(
                i,
                isSelected: _selectedSettingCategory == i,
                onCategoryPressed: (index) => setState(() {
                  _selectedSettingCategory = index;
                  _rotationCounter++;
                }),
              )
          ],
        ),
      ),
      setStateCallback: () => setState(() {}),
      isProfilePicture: true,
      getPosterImage: Future.value(WidgetImageProvider(
        SizedBox(),
        size: Size(32, 32),
      )),
      poster: ({required double width, required double height, required double offset, required double squareness, required ImageProvider<Object>? imageProvider}) => Container(
        width: width,
        height: height,
        color: Colors.transparent,
        child: Center(
            child: AnimatedRotation(
          turns: _rotationCounter.toDouble(),
          duration: const Duration(milliseconds: 200),
          child: Transform.scale(scale: 4, child: settingsList[_selectedSettingCategory]["icon"] as Widget),
        )),
      ),
      contentPadding: (_) => EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );
  }

  Widget _buildContent(Library library, SettingsManager settings) {
    final list = switch (_selectedSettingCategory) {
      // Library
      0 => [
          SettingsCard(
            children: [
              Text(
                settingsList[0]['title'],
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
                  ReadonlyTextBoxWithShiftAltButton(
                    library.libraryPath,
                    unshiftTooltip: 'Open Library Folder',
                    shiftTooltip: 'Copy Library Path',
                    onPressed: library.libraryPath == null
                        ? null
                        : (isShiftPressed) {
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
                  const SizedBox(width: 6),
                  LoadingButton(
                    label: 'Scan Library',
                    onPressed: () => library.reloadLibrary(force: true),
                    isLoading: library.isIndexing,
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
                  const SizedBox(width: 6),
                  NormalButton(
                    label: 'Clear Thumbnails',
                    tooltip: 'Clear all thumbnail cache to regenerate episode thumbnails',
                    isSmall: true,
                    isLoading: _isClearingThumbnailCache,
                    onPressed: () async {
                      setState(() => _isClearingThumbnailCache = true);

                      try {
                        // Clear all thumbnail cache using library method
                        await library.clearAllThumbnailCache();

                        // Also clear Flutter's image cache
                        imageCache.clear();
                        imageCache.clearLiveImages();

                        snackBar('Thumbnail cache cleared successfully', severity: InfoBarSeverity.success);
                      } catch (e, st) {
                        snackBar('Error clearing thumbnail cache: $e', severity: InfoBarSeverity.error, exception: e, stackTrace: st);
                      } finally {
                        setState(() => _isClearingThumbnailCache = false);
                      }
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
        ],
      // Appearance
      1 => [
          Builder(builder: (context) {
            final appTheme = context.watch<AppTheme>();

            return SettingsCard(
              children: [
                Text(
                  settingsList[1]["title"],
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
                            MouseButtonWrapper(
                              tooltip: 'Choose a style for the window background.',
                              child: (_) => ComboBox<WindowEffect>(
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
                        child: MouseButtonWrapper(
                          tooltip: 'Select an accent color for the app theme. When changed, updates the interface highlighting and accent elements.',
                          child: (_) => GestureDetector(
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
                        tooltip: 'Adjust the dimming level of the background when using acrylic or mica effects.',
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
                      MouseButtonWrapper(
                        tooltip: 'Adjust the font size throughout the app.',
                        child: (_) => ComboBox<double>(
                          focusNode: fontSizeFocusNode,
                          value: appTheme.fontSize,
                          items: <double>[for (double i = ScreenUtils.kMinFontSize; i <= ScreenUtils.kMaxFontSize; i += 2) i].map((double value) {
                            return ComboBoxItem<double>(
                              value: value,
                              child: Text('$value'),
                            );
                          }).toList(),
                          onChanged: (double? newValue) {
                            appTheme.fontSize = newValue!;
                            settings.fontSize = newValue;
                          },
                        ),
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
                      NormalSwitch(
                        ToggleSwitch(
                          checked: settings.disableAnimations,
                          content: Text(settings.disableAnimations ? 'Animations Disabled' : 'Animations Enabled', style: Manager.bodyStyle),
                          onChanged: (value) {
                            setState(() => settings.disableAnimations = value);
                          },
                        ),
                        tooltip: 'When enabled, most UI animations will be disabled for a more static experience.',
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
                      NormalSwitch(
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
                        tooltip: 'When enabled, the library cards will use the accent color for their background.\nOtherwise, they will use the dominant color extracted from the series poster.',
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
                          child: MouseButtonWrapper(
                            tooltip: 'Choose way the library Series cards\' background color looks.\n\n- Always: Always show the color in the card.\n- Hover: Show the color only when hovering over the card.\n- None: Never show any color on the card.',
                            child: (_) => toggle.ToggleSwitch(
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
                        disabled: LockManager().hasActiveOperations,
                        tooltip: LockManager().hasActiveOperations ? 'Cannot change while library operations are active' : 'Choose the source for calculating dominant colors. Changing this will allow you to recalculate all dominant colors using the new source.',
                        enumValues: DominantColorSource.values,
                        labelExtractor: (value) => value.name_,
                        currentValue: settings.dominantColorSource,
                        onChanged: (value) {
                          showSimpleManagedDialog(
                            context: context,
                            id: 'dominantColorSource',
                            title: 'Recalculate Colors?',
                            body: 'Would you like to recalculate all dominant colors using the new source?\n\nThis may take some time depending on the size of your library.',
                            onPositive: () async {
                              settings.dominantColorSource = value;
                              final library = Provider.of<Library>(context, listen: false);

                              snackBar('Recalculating dominant colors using ${value.name_} source...', severity: InfoBarSeverity.info);
                              await library.calculateDominantColors(forceRecalculate: true);
                              snackBar('Dominant colors recalculated successfully!', severity: InfoBarSeverity.success);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
                VDiv(12),
                // Airing indicator
                ...[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Series Airing Status Indicator',
                        style: Manager.bodyStyle,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Row(
                          children: [
                            Text('Show Indicator:', style: Manager.bodyStyle),
                            const SizedBox(width: 12),
                            NormalSwitch(
                              ToggleSwitch(
                                checked: settings.showAiringIndicator,
                                content: Text(settings.showAiringIndicator ? 'Enabled' : 'Disabled', style: Manager.bodyStyle),
                                onChanged: (value) {
                                  setState(() => settings.showAiringIndicator = value);
                                },
                              ),
                              tooltip: 'When enabled, an indicator will be shown on series cards if the series is currently airing or if the series is local.\nOtherwise, no indicator is shown.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (settings.showAiringIndicator)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Row(
                            children: [
                              Text('Expand Indicator:', style: Manager.bodyStyle),
                              const SizedBox(width: 12),
                              NormalSwitch(
                                ToggleSwitch(
                                  checked: settings.hoverExpandAiringIndicator,
                                  content: Text(settings.hoverExpandAiringIndicator ? 'Enabled' : 'Disabled', style: Manager.bodyStyle),
                                  onChanged: (value) {
                                    settings.hoverExpandAiringIndicator = value;
                                  },
                                ),
                                tooltip: 'When enabled, hovering over a series card will display an indicator if the series is currently airing.\nOtherwise, no indicator is shown.',
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
                //
              ],
            );
          }),
          VDiv(24),
        ],
      // Behavior
      2 => [
          SettingsCard(
            children: [
              Text(
                settingsList[2]["title"],
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
                      NormalSwitch(
                        ToggleSwitch(
                          checked: Manager.defaultPosterSource == ImageSource.autoAnilist,
                          content: Text(Manager.defaultPosterSource == ImageSource.autoAnilist ? 'Prefer Anilist Posters' : 'Prefer Local Posters', style: Manager.bodyStyle),
                          onChanged: (value) {
                            settings.defaultPosterSource = value ? ImageSource.autoAnilist : ImageSource.autoLocal;
                          },
                        ),
                        disabled: LockManager().hasActiveOperations,
                        tooltip: LockManager().hasActiveOperations ? 'Cannot change while library operations are active' : 'When enabled, Anilist posters will be used when available.\nOtherwise, local posters will be used.',
                      ),
                    ],
                  ),
                  HDiv(24),
                  Column(
                    children: [
                      Text(
                        'Default Banner source for series.',
                        style: Manager.bodyStyle,
                      ),
                      VDiv(12),
                      NormalSwitch(
                        ToggleSwitch(
                          checked: Manager.defaultBannerSource == ImageSource.autoAnilist,
                          content: Text(Manager.defaultBannerSource == ImageSource.autoAnilist ? 'Prefer Anilist Banners' : 'Prefer Local Banners', style: Manager.bodyStyle),
                          onChanged: (value) {
                            settings.defaultBannerSource = value ? ImageSource.autoAnilist : ImageSource.autoLocal;
                          },
                        ),
                        disabled: LockManager().hasActiveOperations,
                        tooltip: LockManager().hasActiveOperations ? 'Cannot change while library operations are active' : 'When enabled, Anilist banners will be used when available.\nOtherwise, local banners will be used.',
                      ),
                    ],
                  ),
                ],
              ),
              VDiv(24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Return to Library after exiting Series Screen from a different Tab',
                    style: Manager.bodyStyle,
                  ),
                  VDiv(12),
                  NormalSwitch(
                    ToggleSwitch(
                      checked: settings.returnToLibraryAfterSeriesScreen,
                      content: Text(settings.returnToLibraryAfterSeriesScreen ? 'Enabled' : 'Disabled', style: Manager.bodyStyle),
                      onChanged: (value) {
                        settings.returnToLibraryAfterSeriesScreen = value;
                      },
                    ),
                    tooltip: 'When enabled, exiting a series screen (e.g., by pressing back) will return you to the main library view, even if you navigated from a different tab.',
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),
        ],
      // Media Players
      3 => [
          SettingsCard(
            children: [
              Text(
                settingsList[3]["title"],
                style: Manager.subtitleStyle,
              ),
              SizedBox(height: 12),
              Text(
                'Configure automatic detection and control of media players like VLC and MPC-HC.',
                style: Manager.bodyStyle,
              ),
              SizedBox(height: 24),

              // Enable Media Player Integration
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enable Media Player Integration',
                          style: Manager.bodyStrongStyle,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Automatically detect and connect to supported media players for playback control and progress tracking.',
                          style: Manager.bodyStyle.copyWith(color: Colors.white.withOpacity(.5)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 24),
                  NormalSwitch(
                    ToggleSwitch(
                      checked: settings.enableMediaPlayerIntegration,
                      content: Text(settings.enableMediaPlayerIntegration ? 'Enabled' : 'Disabled', style: Manager.bodyStyle),
                      onChanged: (value) {
                        setState(() {
                          settings.enableMediaPlayerIntegration = value;
                          if (value) {
                            library.initializeMediaPlayerIntegration();
                          } else {
                            library.disposeMediaPlayerIntegration();
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Player Priority
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (settings.enableMediaPlayerIntegration) ...[
                    Row(
                      children: [
                        Text(
                          'Player Priority Order',
                          style: Manager.bodyStrongStyle,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Drag to reorder. The app will try to connect to players in this order of preference.',
                          style: Manager.bodyStyle.copyWith(color: Colors.white.withOpacity(.5)),
                        ),
                        StandardButton(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(mat.Icons.refresh, size: 16),
                              SizedBox(width: 8),
                              Text('Reload'),
                            ],
                          ),
                          onPressed: () async {
                            // Reload player configuration and detection
                            await library.playerManager?.disconnect();
                            await library.playerManager?.autoConnect();

                            // Show confirmation
                            snackBar('Player configuration reloaded', severity: InfoBarSeverity.success);
                          },
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 12),
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: settings.mediaPlayerPriority.length,
                    buildDefaultDragHandles: false,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) newIndex -= 1;

                        final item = settings.mediaPlayerPriority.removeAt(oldIndex);
                        if (!settings.mediaPlayerPriority.contains(item)) settings.mediaPlayerPriority.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final playerId = settings.mediaPlayerPriority[index];
                      final playerName = playerId == 'vlc'
                          ? 'VLC Media Player'
                          : playerId == 'mpc-hc'
                              ? 'MPC-HC'
                              : playerId;

                      // Get the player instance for this ID
                      MediaPlayer? player;
                      if (playerId == 'vlc') {
                        player = VLCPlayer();
                      } else if (playerId == 'mpc-hc') {
                        player = MPCHCPlayer();
                      } else {
                        // For custom, you may want to load config from file or settings
                        // Here we just show a fallback icon
                        player = null;
                      }

                      return Container(
                        key: ValueKey('player_priority_${playerId}_$index'),
                        margin: EdgeInsets.only(bottom: 8),
                        child: Card(
                          child: ListTile(
                            leading: settings.enableMediaPlayerIntegration //
                                ? ReorderableDragStartListener(index: index, child: Icon(mat.Icons.drag_handle, color: Colors.white.withOpacity(.5)))
                                : null,
                            title: Row(
                              children: [
                                player?.iconWidget ?? Icon(mat.Icons.play_arrow, size: 20, color: Manager.accentColor),
                                SizedBox(width: 8),
                                Text(playerName),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // Connection Status
              if (settings.enableMediaPlayerIntegration) ...[
                SizedBox(height: 24),
                Divider(),
                SizedBox(height: 12),
                Text(
                  'Connection Status',
                  style: Manager.bodyStrongStyle,
                ),
                SizedBox(height: 12),
                Consumer<Library>(
                  builder: (context, lib, child) {
                    final connectedPlayer = lib.currentConnectedPlayer;
                    final detectedPlayers = lib.detectedPlayers;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (connectedPlayer != null)
                          Row(
                            children: [
                              Icon(mat.Icons.check_circle, color: Colors.green, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Connected to: $connectedPlayer',
                                style: Manager.bodyStyle.copyWith(color: Colors.green),
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Icon(mat.Icons.error, color: Colors.orange, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'No players connected',
                                style: Manager.bodyStyle.copyWith(color: Colors.orange),
                              ),
                            ],
                          ),
                        SizedBox(height: 8),
                        if (detectedPlayers.isNotEmpty) ...[
                          Text(
                            'Detected Players:',
                            style: Manager.bodyStyle.copyWith(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 4),
                          ...detectedPlayers.map((player) => Padding(
                                padding: EdgeInsets.only(left: 16, bottom: 4),
                                child: Text(
                                  '• ${player.name} (${player.detectionMethod})',
                                  style: Manager.bodyStyle.copyWith(fontSize: 12),
                                ),
                              )),
                        ] else
                          Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Text(
                              'No media players detected',
                              style: Manager.bodyStyle.copyWith(fontSize: 12),
                            ),
                          ),
                        SizedBox(height: 12),
                        FilledButton(
                          onPressed: () {
                            library.refreshMediaPlayers();
                          },
                          child: Text('Refresh Players'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ],
          ),
          SizedBox(height: 24),
        ],
      // Data & Storage
      4 => [
          SettingsCard(
            children: [
              Text(
                settingsList[4]['title'],
                style: Manager.subtitleStyle,
              ),
              VDiv(12),
              Text(
                'Manage your application data, database backups, and storage settings.',
                style: Manager.bodyStyle,
              ),
              VDiv(24),

              // App Data Location Section
              Text('App Data Location', style: Manager.bodyStrongStyle),
              VDiv(8),
              Row(
                children: [
                  ReadonlyTextBoxWithShiftAltButton(
                    DataStorageService.getAppDataPath(),
                    onPressed: (isShiftPressed) {
                      if (isShiftPressed) {
                        // Copy path to clipboard
                        snackBar('App Data path copied to clipboard', severity: InfoBarSeverity.success);
                        copyToClipboard(DataStorageService.getAppDataPath());
                        return;
                      }
                      // Open path in file explorer
                      try {
                        Process.run('explorer', [DataStorageService.getAppDataPath()]);
                      } catch (e, stackTrace) {
                        snackBar(
                          'Failed to open app data folder: $e',
                          severity: InfoBarSeverity.error,
                          exception: e,
                          stackTrace: stackTrace,
                        );
                      }
                    },
                  ),
                ],
              ),
              VDiv(4),
              Text(
                'Database size: ${DataStorageService.getDatabaseSize()} • '
                'Total app data: ${DataStorageService.getAppDataSize()}',
                style: Manager.miniBodyStyle,
              ),
              VDiv(8),
              InfoBar(
                title: SizedBox.shrink(),
                content: Text('This is where automatic backups, cache files, and application data are stored. '),
                severity: InfoBarSeverity.info,
              ),
              VDiv(24),

              // Backup and Restore Section
              Text('Backup and Restore', style: Manager.bodyStrongStyle),
              VDiv(12),
              Row(
                children: [
                  Expanded(
                    child: LoadingButton(
                      label: 'Create Backup',
                      onPressed: () async {
                        try {
                          final backupPath = await DataStorageService.createBackup();
                          if (backupPath != null) {
                            snackBar('Backup created successfully', severity: InfoBarSeverity.success);
                          }
                        } catch (e) {
                          snackBar('Failed to create backup: $e', severity: InfoBarSeverity.error);
                        }
                      },
                      isLoading: false,
                      isSmall: true,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: LoadingButton(
                      label: 'Restore Backup',
                      onPressed: () => _toggleExpanderTile(),
                      isLoading: false,
                      isSmall: true,
                    ),
                  ),
                ],
              ),
              VDiv(12),
              AnimatedSwitcher(
                duration: dimDuration,
                transitionBuilder: (child, animation) => SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: !_showBackupsList ? const SizedBox.shrink() : AbsorbPointer(
                  absorbing: !_showBackupsList,
                  child: IgnorePointer(
                    ignoring: !_showBackupsList,
                    child: mat.ExpansionTile(
                      trailing: StandardButton.icon(
                        isFilled: true,
                        label: Text('Select Backup from files', style: Manager.bodyStyle.copyWith(color: getPrimaryColorBasedOnAccent())),
                        icon: Icon(mat.Icons.folder_open, size: 16, color: getPrimaryColorBasedOnAccent()),
                        onPressed: () async {
                          // Open file picker to select backup file (default to app data folder)
                          final FilePickerResult? result = await FilePicker.platform.pickFiles(
                            dialogTitle: 'Select Backup to Restore',
                            lockParentWindow: true,
                            type: FileType.custom,
                            allowedExtensions: ['db', 'bak'],
                            initialDirectory: miruRyoikiSaveDirectory.path,
                          );
                          if (result == null || result.files.isEmpty || result.files.first.path == null) return; // User cancelled
                                
                          final File backupFile = File(result.files.first.path!);
                          _restoreBackup(backupFile);
                        },
                      ),
                      controller: expansionTileKey,
                      title: Text('Available Backups', style: Manager.bodyStyle),
                      enabled: false,
                      children: _availableBackups.take(10).map((backup) {
                        final modified = backup.statSync().modified;
                        return mat.ListTile(
                          dense: true,
                          leading: const Icon(mat.Icons.backup),
                          title: Text(backup.path.split(Platform.pathSeparator).last),
                          subtitle: Text('Modified: ${modified.pretty(time: true)}', style: Manager.miniBodyStyle),
                          trailing: StandardButton(
                            onPressed: _isRestoringBackup ? null : () => _restoreBackup(backup),
                            label: Text('Restore', style: Manager.bodyStyle.copyWith(color: Colors.white)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              VDiv(24),

              // Database Recovery Section
              if (DataStorageService.isDatabaseLocked()) ...[
                InfoBar(
                  title: Text('Database Lock Detected!', style: Manager.bodyStrongStyle),
                  content: Text('Your database appears to be locked. This usually happens when the app is force-closed during a save operation.', style: Manager.bodyStyle),
                  severity: InfoBarSeverity.warning,
                ),
                VDiv(12),
              ],

              Text('Database Recovery', style: Manager.bodyStrongStyle),
              VDiv(8),
              Text(
                'If you experience database lock issues, use this tool to recover access to your data.',
                style: Manager.bodyStyle,
              ),
              VDiv(12),
              SizedBox(
                width: double.infinity,
                child: LoadingButton(
                  label: 'Database Recovery Tool',
                  onPressed: () async {
                    final result = await showDatabaseRecoveryDialog(context);
                    if (result == true) {
                      snackBar('Database recovery completed successfully', severity: InfoBarSeverity.success);
                      setState(() {}); // Refresh the UI
                    }
                  },
                  isLoading: false,
                  isSmall: false,
                ),
              ),
            ],
          ),
        ],
      // Advanced
      5 => [
          SettingsCard(
            children: [
              Text(
                settingsList[3]["title"],
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
                          tooltip: 'Select the minimum log level for file logging. When set to higher levels, more detailed messages are logged.\nOtherwise, only important messages (like errors) are captured.',
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
                              child: MouseButtonWrapper(
                                tooltip: 'Set the number of days to keep log files. When enabled, automatically deletes older log files.\nOtherwise, logs are kept indefinitely.',
                                child: (_) => NumberBox<int>(
                                  value: settings.logRetentionDays,
                                  onChanged: (int? value) {
                                    if (value != null && value >= 0) settings.logRetentionDays = value;
                                  },
                                  min: 0,
                                  max: 365,
                                  mode: SpinButtonPlacementMode.inline,
                                ),
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
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Log files are stored in the ',
                    style: Manager.bodyStyle,
                  ),
                  Transform.translate(
                    offset: Offset(10, .5),
                    child: WrappedHyperlinkButton(
                      text: 'application data directory',
                      url: "file:///${miruRyoikiSaveDirectory.path}/logs",
                      icon: Icon(mat.Icons.folder_outlined, size: 19),
                      style: Manager.bodyStyle,
                    ),
                  ),
                  Text(
                    '. Each session creates a unique log file.',
                    style: Manager.bodyStyle,
                  ),
                ],
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
        ],
      // About
      6 => [
          SettingsCard(
            children: [
              Text(settingsList[6]["title"], style: Manager.subtitleStyle),
              VDiv(12),
              Text('Version: ${Manager.appVersion}', style: Manager.bodyStyle),
              MouseButtonWrapper(
                child: (_) => GestureDetector(
                  onTap: () => carpaccio(),
                  child: Text('Build Number: ${Manager.buildNumber}', style: Manager.bodyStyle),
                ),
              ),
              VDiv(6),
              Text('Last Update: ${Manager.lastUpdate.pretty()}', style: Manager.bodyStyle),
              VDiv(24),
              Text(
                '${Manager.appTitle} is a video tracking application that integrates with '
                'various media players to track your watched videos.',
                style: Manager.bodyStyle,
              ),
              VDiv(24),
              InfoBar(
                title: Text('MPC-HC Integration', style: Manager.bodyStrongStyle),
                content: Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Text(
                    'This app listens for playback events from various media players to track your watched videos. '
                    'Please ensure your media player is installed and the Web Interface is enabled and configured properly.',
                    style: Manager.bodyStyle,
                  ),
                ),
                severity: InfoBarSeverity.info,
              ),
            ],
          ),
        ],
      _ => <Widget>[],
    };

    return Column(children: list);
  }

  Expanded ReadonlyTextBoxWithShiftAltButton(
    String? textboxText, {
    String unshiftTooltip = "",
    String shiftTooltip = "",
    Function(bool)? onPressed,
  }) {
    return Expanded(
      child: SizedBox(
        height: 34,
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            //TODO make this go above if the horizontal space is too small
            TextBox(
              placeholder: 'No folder selected',
              controller: TextEditingController(text: textboxText ?? ''),
              readOnly: true,
              enabled: false,
            ),
            Padding(
              padding: const EdgeInsets.all(3),
              child: ValueListenableBuilder(
                  valueListenable: KeyboardState.shiftPressedNotifier,
                  builder: (context, isShiftPressed, _) {
                    return MouseButtonWrapper(
                      tooltip: isShiftPressed ? shiftTooltip : unshiftTooltip,
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
                            onPressed: () => onPressed?.call(isShiftPressed),
                          ),
                        ),
                      ),
                    );
                  }),
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
