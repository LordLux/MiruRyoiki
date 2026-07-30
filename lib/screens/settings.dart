// import 'package:flutter/material.dart';
// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart' hide AnimatedSwitcher;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as mat hide AnimatedSwitcher;
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
// import '../models/formatter/action.dart';
import '../services/library/scanner/scanner_service.dart';
import '../services/anilist/episode_title_service.dart';
import '../services/data_storage_service.dart';
import '../services/downloads/torrent_manager.dart';
import '../services/lock_manager.dart';
import '../services/navigation/dialog_functions.dart';
import '../services/navigation/dialog_framework.dart';
import '../services/navigation/navigation.dart';
import '../services/navigation/shortcuts.dart';
import '../services/navigation/show_info.dart';
import '../widgets/dialogs/show_dialog.dart';
import '../settings.dart';
import '../utils/color.dart';
import '../utils/database_recovery.dart';
import '../utils/logging.dart';
import '../services/library/library_provider.dart';
import '../theme.dart';
import '../utils/path.dart';
import '../utils/screen.dart';
import '../utils/time.dart';
import '../viewmodels/library_screen_viewmodel.dart';
import '../widgets/animated_hider.dart';
import '../widgets/buttons/button.dart';
import '../widgets/buttons/hyperlink.dart';
import '../widgets/buttons/setting_category_button.dart';
import '../widgets/buttons/switch.dart';
import '../widgets/buttons/wrapper.dart';
import '../widgets/dialogs/database_recovery.dart';
import '../widgets/enum_toggle.dart';
import '../widgets/page/header_widget.dart';
import '../widgets/page/page_template.dart';
import '../widgets/tooltip_wrapper.dart';
import 'settings/players_settings_section.dart';
import 'settings/qbittorrent_settings_section.dart';
import 'settings/sonarr_settings_section.dart';

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

class SettingsScreenState extends State<SettingsScreen> with AutomaticKeepAliveClientMixin {
  FlyoutController controller = FlyoutController();
  Color tempColor = Colors.transparent;
  // List<SeriesFormatPreview> _issuesPreview = [];

  @override
  bool get wantKeepAlive => true;

  int _buildClicks = 0;
  Timer? _buildClickTimer;

  List<File> _availableBackups = [];
  final mat.ExpansionTileController expansionTileKey = mat.ExpansionTileController();
  bool _showBackupsList = false;
  bool _isRestoringBackup = false;

  // ignore: unused_field
  // bool _isFormatting = false;
  bool _isOpenFolderHovered = false;

  bool showAccentLibViewCol = false;

  double prevPos = 0;
  static double settingsInfoBarHeight = settingsList.length * 50 + ((settingsList.length - 1) * 8) + 16;

  bool _isSelectingFolder = false;
  bool _isClearingThumbnailCache = false;

  final FocusNode fontSizeFocusNode = FocusNode();
  final FocusNode transitionAnimationFocusNode = FocusNode();

  int _selectedSettingCategory = 0;

  void openPlayersCategory() {
    if (!mounted) return;
    const playersCategoryIndex = 3;
    setState(() => _selectedSettingCategory = playersCategoryIndex);
  }

  static List<Map<String, dynamic>> get settingsList => [
        {
          "title": "Library",
          "icon": Icon(mat.Icons.library_books, color: Manager.accentColor.lighter, size: 23),
          "desc": "Manage your series library, scanning, and organization settings.",
        },
        {
          "title": "Appearance",
          "icon": Icon(mat.Icons.palette, color: Manager.accentColor.lighter, size: 23),
          "desc": "Edit how ${Manager.appTitle} looks and feels.",
        },
        {
          "title": "Behavior",
          "icon": Icon(mat.Icons.tune, color: Manager.accentColor.lighter, size: 23),
          "desc": "Adjust ${Manager.appTitle}'s behavior and interaction settings.",
        },
        {
          "title": "Players",
          "icon": Icon(mat.Icons.play_circle_outline, color: Manager.accentColor.lighter, size: 23),
          "desc": "Configure automatic detection and control of media players like VLC and MPC-HC.",
        },
        {
          "title": "Data & Storage",
          "icon": Icon(mat.Icons.storage, color: Manager.accentColor.lighter, size: 23),
          "desc": "Manage your application data, database backups, and storage settings.",
        },
        {
          "title": "Advanced",
          "icon": Icon(mat.Icons.settings, color: Manager.accentColor.lighter, size: 23),
          "desc": "Configure logging behavior for debugging and troubleshooting.",
        },
        {
          "title": "Torrents",
          "icon": Icon(mat.Icons.download, color: Manager.accentColor.lighter, size: 23),
          "desc": "Configure Sonarr and torrent client connections for automated downloads.",
        },
        {
          "title": "About ${Manager.appTitle}",
          "icon": Icon(mat.Icons.info, color: Manager.accentColor.lighter, size: 23),
          "desc": "View application version, licenses, and acknowledgements.",
        },
      ];

  static Future<void> setLibraryPath(BuildContext context) async {
    final scannerService = Provider.of<LibraryScannerService>(context, listen: false);
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Library Folder',
    );

    if (result != null) scannerService.setLibraryPath(result);
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
      // Sonarr / qBittorrent / media-player connection state is now restored
      // inside their respective section widgets' initState.
    });
  }

  void _loadAvailableBackups() => setState(() => _availableBackups = DatabaseRecovery.getAvailableBackups());

  void _restoreBackup(File backupFile) async {
    try {
      bool confirmed = false;
      await showSimpleManagedDialog(
        context,
        id: 'settings:restore-backup',
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

      if (backupPath != null) snackBar('Database restored successfully. Please restart the app.', severity: InfoBarSeverity.success, autoHide: false);
    } catch (e) {
      snackBar('Failed to restore backup: $e', severity: InfoBarSeverity.error);
    } finally {
      setState(() => _isRestoringBackup = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // for AutomaticKeepAliveClientMixin

    final library = Provider.of<Library>(context);
    final settings = Provider.of<SettingsManager>(context);

    return MiruRyoikiTemplatePage(
      scrollRestorationId: 'settings',
      headerWidget: HeaderWidget(
        titleLeftAligned: true,
        title: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text.rich(
            TextSpan(
              children: [
                WidgetSpan(child: SizedBox(width: ScreenUtils.kInfoBarWidth, child: Transform.translate(offset: Offset(0, 3), child: Text("Settings", style: Manager.titleLargeStyle)))),
                WidgetSpan(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(settingsList[_selectedSettingCategory]['title'], style: Manager.bodyLargeStyle),
                      Text(settingsList[_selectedSettingCategory]['desc'], style: Manager.miniBodyStyle.copyWith(fontWeight: FontWeight.normal, color: FluentTheme.of(context).resources.textFillColorSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      infobarHeight: settingsInfoBarHeight,
      contentHeight: settingsInfoBarHeight,
      infobar: (noHeaderBanner) => _buildInfoBar(noHeaderBanner),
      content: _buildContent(library, settings),
      hideInfoBar: false,
      headerMinHeight: ScreenUtils.kMinHeaderHeight + 90,
      headerMaxHeight: ScreenUtils.kMinHeaderHeight + 90,
      // headerMaxHeight: ScreenUtils.kMaxHeaderHeight, // TODO maybe use this?
      noHeaderBanner: true,
      wrapContentWithCard: true,
      cardPadding: EdgeInsets.symmetric(horizontal: 16.0),
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
                onCategoryPressed: (index) => setState(() => _selectedSettingCategory = index),
              )
          ],
        ),
      ),
      setStateCallback: () => setState(() {}),
      contentPadding: (_) => EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );
  }

  Widget _buildContent(Library library, SettingsManager settings) {
    final appTheme = context.watch<AppTheme>();
    final List<Widget> list = switch (_selectedSettingCategory) {
      // Library
      0 => [
          Text(
            'Select the folder that contains your media library.',
            style: Manager.bodyStyle,
          ),
          VDiv(24),
          Row(
            children: [
              ReadonlyTextBoxWithShiftAltButton(
                isDisabled: library.libraryPath == null,
                library.libraryPath,
                disabledTooltip: 'Library path not set, please select a folder.',
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
              if (library.libraryPath != null) const SizedBox(width: 6),
              if (library.libraryPath != null)
                ValueListenableBuilder(
                    valueListenable: KeyboardState.shiftPressedNotifier,
                    builder: (context, isShiftPressed, _) {
                      final scannerService = Provider.of<LibraryScannerService>(context);
                      return LoadingButton(
                        tooltip: isShiftPressed //
                            ? 'Clear Cache and Scan Library'
                            : 'Scan Library',
                        isButtonDisabled: scannerService.isIndexing,
                        label: isShiftPressed ? 'Clear Cache and Scan Library' : 'Scan Library',
                        onPressed: () => isShiftPressed
                            ? library.reloadLibrary(force: true, showSnackBar: false).then((_) {
                                // Refetch AniList data after reload completes
                                library.clearAnilistCaches(refetchAfterClear: true).then((_) {
                                  snackBar('Cleared caches, reloaded, and refetched AniList data!', severity: InfoBarSeverity.success);
                                }).catchError((error, stacktrace) {
                                  snackBar('Error refetching AniList data after reload', severity: InfoBarSeverity.error, exception: error, stackTrace: stacktrace);
                                });
                              })
                            : library.reloadLibrary(force: true),
                        isLoading: scannerService.isIndexing,
                        isSmall: true,
                        isBigEvenWithoutLoading: true,
                      );
                    }),
              const SizedBox(width: 6),
              StandardButton.label(
                label: 'Browse',
                isFilled: true,
                isSmall: true,
                tooltip: 'Select Library Folder',
                isLoading: _isSelectingFolder,
                onPressed: () async {
                  setState(() => _isSelectingFolder = true);

                  await setLibraryPath(context);

                  setState(() => _isSelectingFolder = false);
                },
              ),
              const SizedBox(width: 6),
              StandardButton.label(
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
            'Privacy',
            style: Manager.subtitleStyle,
          ),
          VDiv(12),

          // Toggle for showing hidden series
          NormalSwitch(
            ToggleSwitch(
              checked: Manager.settings.showHiddenSeries,
              content: Flexible(
                child: Text('Show hidden series', style: Manager.bodyStyle),
              ),
              onChanged: (value) {
                setState(() => Manager.settings.showHiddenSeries = value);
                context.read<LibraryScreenViewModel>().invalidateSortCache();
              },
            ),
          ),

          // Toggle for showing series hidden from AniList status lists
          NormalSwitch(
            ToggleSwitch(
              checked: Manager.settings.showAnilistHiddenSeries,
              content: Flexible(
                child: Text('Show series hidden from status lists', style: Manager.bodyStyle),
              ),
              onChanged: (value) {
                setState(() => Manager.settings.showAnilistHiddenSeries = value);
                context.read<LibraryScreenViewModel>().invalidateSortCache();
              },
            ),
            tooltip: 'Show series hidden from status lists (these will only be visible in custom lists)',
          ),

          // VDiv(24),
          // Text(
          //   'Series Formatter',
          //   style: Manager.subtitleStyle,
          // ),
          // VDiv(12),
          // Text(
          //   'The Series Formatter helps organize your media files into a standardized structure.',
          //   style: Manager.bodyStyle,
          // ),
          // VDiv(16),
          // StandardButton.label(
          //   label: 'Format Series',
          //   isLoading: _isFormatting,
          //   isFilled: true,
          //   onPressed: () => _showSeriesFormatterDialog(context),
          // ),

          // // This section will show series with formatting issues
          // if (_issuesPreview.isNotEmpty) ...[
          //   VDiv(24),
          //   Text('Last Scan: ', style: Manager.subtitleStyle),
          //   VDiv(12),
          //   Expander(
          //     header: Text(
          //       "Series that couldn't be automatically parsed (${_issuesPreview.length})",
          //       style: Manager.bodyStrongStyle,
          //     ),
          //     initiallyExpanded: true,
          //     content: SizedBox(
          //       height: 117.0 * _issuesPreview.length,
          //       child: SingleChildScrollView(
          //         child: Column(
          //           mainAxisSize: MainAxisSize.min,
          //           children: _issuesPreview.map((preview) {
          //             final series = library.getSeriesByPath(preview.seriesPath);
          //             return _buildSeriesIssueItem(context, preview, series, _issuesPreview, _issuesPreview.indexOf(preview));
          //           }).toList(),
          //         ),
          //       ),
          //     ),
          //   ),
          // ],
        ],
      // Appearance
      1 => [
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
                    child: TooltipWrapper(
                      tooltip: 'Mica Effect is unfortunately only available on Windows 11',
                      child: (_) => Opacity(opacity: .5, child: Icon(FluentIcons.info)),
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
                        final Offset globalOffset = details.globalPosition;
                        // final Offset globalOffset = renderBox.localToGlobal(offset);
                        final Offset flyoutOffset = Offset(globalOffset.dx + 10, globalOffset.dy);

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
                                onChanged: (color) => tempColor = color,
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
                            Manager.setState(() {
                              settings.accentColor = tempColor.saturate(300);
                              appTheme.color = settings.accentColor.toAccentColor();
                              settings.accentColor = settings.accentColor;
                            });
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
                    Manager.setState(() {
                      appTheme.dim = value;
                      settings.dim = value;
                    });
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
                    onChanged: (value) => setState(() => settings.disableAnimations = value),
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
                      context,
                      id: 'settings:recalculate-colors',
                      title: 'Recalculate Colors?',
                      body: 'Would you like to recalculate all dominant colors using the new source?\n\nThis may take some time depending on the size of your library.',
                      onPositive: () async {
                        settings.dominantColorSource = value;
                        final scannerService = Provider.of<LibraryScannerService>(context, listen: false);

                        snackBar('Recalculating dominant colors using ${value.name_} source...', severity: InfoBarSeverity.info, autoHide: false);
                        await scannerService.calculateDominantColors(forceRecalculate: true);
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
                          onChanged: (value) => setState(() => settings.showAiringIndicator = value),
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
          VDiv(12),
          // Squiggly Slider
          ...[
            Row(
              children: [
                Text(
                  'Squiggly Video Progress Slider',
                  style: Manager.bodyStyle,
                ),
                const SizedBox(width: 12),
                NormalSwitch(
                  ToggleSwitch(
                    checked: settings.squigglySliderEnabled,
                    content: Text(settings.squigglySliderEnabled ? 'Enabled' : 'Disabled', style: Manager.bodyStyle),
                    onChanged: (value) => setState(() => settings.squigglySliderEnabled = value),
                  ),
                  tooltip: 'When enabled, the video progress slider will have a squiggly animation effect when the video is playing.\nWhen disabled, the slider will appear like a normal line.',
                ),
              ],
            ),
          ],
          VDiv(12),
          // Transition Animations
          ...[
            Row(
              children: [
                Text('Transition Animations', style: Manager.bodyStyle),
                const SizedBox(width: 12),
                MouseButtonWrapper(
                  tooltip: 'Select the type of transition animations used during pane changes throughout the app.',
                  child: (_) => ComboBox<PageTransitionMode>(
                    focusNode: transitionAnimationFocusNode,
                    value: settings.pageTransitionMode,
                    items: PageTransitionMode.values.map((PageTransitionMode value) {
                      return ComboBoxItem<PageTransitionMode>(
                        value: value,
                        child: Text(value.name_),
                      );
                    }).toList(),
                    onChanged: (PageTransitionMode? newValue) {
                      settings.pageTransitionMode = newValue!;
                    },
                  ),
                ),
              ],
            ),
          ],
          VDiv(12),
          // Acrylic Tooltips
          ...[
            Row(
              children: [
                Text(
                  'Acrylic Tooltips',
                  style: Manager.bodyStyle,
                ),
                const SizedBox(width: 12),
                NormalSwitch(
                  ToggleSwitch(
                    checked: settings.useAcrylicTooltips,
                    content: Text(settings.useAcrylicTooltips ? 'Enabled' : 'Disabled', style: Manager.bodyStyle),
                    onChanged: (value) => setState(() => settings.useAcrylicTooltips = value),
                  ),
                  tooltip: 'When enabled, acrylic tooltips will be used throughout the application.\nWhen disabled, standard tooltips will be used.',
                ),
              ],
            ),
          ],
          //
        ],
      // Behavior
      2 => [
          Text(
            'Default Poster source for series.',
            style: Manager.bodyStyle,
          ),
          VDiv(12),
          NormalSwitch(
            ToggleSwitch(
              checked: Manager.defaultPosterSource == ImageSource.autoAnilist,
              content: Text(Manager.defaultPosterSource == ImageSource.autoAnilist ? 'Prefer Anilist Posters' : 'Prefer Local Posters', style: Manager.bodyStyle),
              onChanged: (value) => setState(() => settings.defaultPosterSource = value ? ImageSource.autoAnilist : ImageSource.autoLocal),
            ),
            disabled: LockManager().hasActiveOperations,
            tooltip: LockManager().hasActiveOperations ? 'Cannot change while library operations are active' : 'When enabled, Anilist posters will be used when available.\nOtherwise, local posters will be used.',
          ),
          HDiv(24),
          Text(
            'Default Banner source for series.',
            style: Manager.bodyStyle,
          ),
          VDiv(12),
          NormalSwitch(
            ToggleSwitch(
              checked: Manager.defaultBannerSource == ImageSource.autoAnilist,
              content: Text(Manager.defaultBannerSource == ImageSource.autoAnilist ? 'Prefer Anilist Banners' : 'Prefer Local Banners', style: Manager.bodyStyle),
              onChanged: (value) => setState(() => settings.defaultBannerSource = value ? ImageSource.autoAnilist : ImageSource.autoLocal),
            ),
            disabled: LockManager().hasActiveOperations,
            tooltip: LockManager().hasActiveOperations ? 'Cannot change while library operations are active' : 'When enabled, Anilist banners will be used when available.\nOtherwise, local banners will be used.',
          ),
          HDiv(24),
          Text(
            'Fetch the episode titles from AniList. (Beta)',
            style: Manager.bodyStyle,
          ),
          VDiv(12),
          NormalSwitch(
            ToggleSwitch(
              checked: Manager.enableAnilistEpisodeTitles,
              content: Text(Manager.enableAnilistEpisodeTitles ? 'AniList Episode Titles Enabled' : 'AniList Episode Titles Disabled', style: Manager.bodyStyle),
              onChanged: (value) => setState(() {
                settings.enableAnilistEpisodeTitles = value;
                // If disabling, also clear cached titles
                if (!value) {
                  // Clear episode title cache
                  EpisodeTitleService.instance.clearCache();
                }
              }),
            ),
            disabled: LockManager().hasActiveOperations,
            tooltip: LockManager().hasActiveOperations ? 'Cannot change while library operations are active' : 'When enabled, ${Manager.appTitle} will try to fetch the episode titles from AniList. (This depends only on the availability of the titles on AniList)\nOtherwise, only local episode titles (if available) will be used.',
          ),
          VDiv(24),
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
          VDiv(12),
          Row(
            children: [
              Text('First Day of Week', style: Manager.bodyStyle),
              const SizedBox(width: 12),
              TooltipWrapper(
                tooltip: 'Set which day appears first in the release calendar.',
                child: (_) {
                  final list = FirstDayOfWeek.values.sublist(1);
                  list.add(FirstDayOfWeek.values.first);

                  return ComboBox<FirstDayOfWeek>(
                    value: settings.firstDayOfWeek,
                    items: list.map((FirstDayOfWeek value) {
                      return ComboBoxItem<FirstDayOfWeek>(
                        value: value,
                        child: Text(value.displayName),
                      );
                    }).toList(),
                    onChanged: (FirstDayOfWeek? newValue) {
                      if (newValue != null) settings.firstDayOfWeek = newValue;
                    },
                  );
                },
              ),
            ],
          ),

          // TODO when upgrading to fluent_ui 4.15+:
          // VDiv(24),
          // Row(
          //   children: [
          //     Text('Date Picker Type', style: Manager.bodyStyle),
          //     const SizedBox(width: 12),
          //     TooltipWrapper(
          //       tooltip: 'Select the style of date picker (Calendar or Spinner).',
          //       child: (_) {
          //         return ComboBox<DatePickerType>(
          //           value: settings.datePickerType,
          //           items: DatePickerType.values.map((DatePickerType value) {
          //             return ComboBoxItem<DatePickerType>(
          //               value: value,
          //               child: Text(value.name_),
          //             );
          //           }).toList(),
          //           onChanged: (DatePickerType? newValue) {
          //             if (newValue != null) setState(() => settings.datePickerType = newValue);
          //           },
          //         );
          //       },
          //     ),
          //   ],
          // ),
          VDiv(24),
          Text(
            'Suppress Close Warning',
            style: Manager.bodyStyle,
          ),
          VDiv(12),
          NormalSwitch(
            ToggleSwitch(
              checked: settings.suppressCloseWarning,
              content: Text(settings.suppressCloseWarning ? 'Warning Suppressed' : 'Warning Enabled', style: Manager.bodyStyle),
              onChanged: (value) => setState(() => settings.suppressCloseWarning = value),
            ),
            tooltip: 'When enabled, the application will not warn you when you try to close it multiple times in quick succession.',
          ),
          VDiv(24),
          Text(
            'Search Infinite Scroll',
            style: Manager.bodyStyle,
          ),
          VDiv(12),
          NormalSwitch(
            ToggleSwitch(
              checked: settings.useInfiniteScroll,
              content: Text(settings.useInfiniteScroll ? 'Infinite Scroll Enabled' : 'Infinite Scroll Disabled', style: Manager.bodyStyle),
              onChanged: (value) => setState(() => settings.useInfiniteScroll = value),
            ),
            tooltip: 'When enabled, search results will automatically load as you scroll down.\nWhen disabled, a "Load More" button will appear at the bottom of search results',
          ),
        ],
      // Media Players
      3 => [
          PlayersSettingsSection(settings: settings),
        ],
      // Data & Storage
      4 => [
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
          AnimatedHider(
            duration: dimDuration,
            shouldShowChild: _showBackupsList,
            child: AbsorbPointer(
              absorbing: !_showBackupsList,
              child: IgnorePointer(
                ignoring: !_showBackupsList,
                child: mat.ExpansionTile(
                  trailing: StandardButton.iconLabel(
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
              onPressed: () => showDatabaseRecoveryDialog(context),
              isLoading: false,
              isSmall: false,
            ),
          ),
        ],
      // Advanced
      5 => [
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
                            LoggingConfig.doLogTrace = true;
                          else
                            LoggingConfig.doLogTrace = false;
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
      // Torrents (Sonarr + Torrent Client)
      6 => [
          SonarrSettingsSection(settings: settings),
          VDiv(32),
          Divider(),
          VDiv(24),
          QbitSettingsSection(settings: settings),
        ],
      // About
      7 => [
          MouseButtonWrapper(
            child: (_) => GestureDetector(
              onTap: () => carpaccio(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Version', style: Manager.smallSubtitleStyle),
                  Text('${Manager.appVersion} (${Manager.buildNumber})', style: Manager.bodyStyle),
                ],
              ),
            ),
          ),
          VDiv(8),
          MouseButtonWrapper(
            child: (_) => GestureDetector(
              onTap: () {
                copyToClipboard(Manager.lastUpdate.pretty());
                snackBar('Date copied to clipboard', severity: InfoBarSeverity.success);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Last Update', style: Manager.smallSubtitleStyle.copyWith(fontWeight: FontWeight.normal)),
                  Text(Manager.lastUpdate.pretty(), style: Manager.bodyStyle),
                ],
              ),
            ),
          ),
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
          if (kDebugMode) ...[
            VDiv(32),
            Divider(),
            VDiv(24),
            Text('Debug', style: Manager.smallSubtitleStyle),
            VDiv(12),
            StandardButton.label(
              label: 'Reset Torrent/Download Config',
              backgroundColor: mat.Colors.red,
              onPressed: () {
                showPaddedDialog(
                  context,
                  navigationItem: DialogNavigationItem(id: 'settings:reset-torrent-config', title: 'Reset Torrent Config'),
                  builder: (context, item, options) {
                    return PaddedDialog.custom(
                      navigationItem: item,
                      barrierOptions: options,
                      constraints: const BoxConstraints(maxWidth: 500, maxHeight: 300, minWidth: 300),
                      contentBuilder: (_, __) => ContentDialog(
                        title: const Text('Reset Torrent Config'),
                        content: const Text(
                          'This will clear all qBittorrent, Sonarr, and Knaben settings '
                          '(URLs, credentials, connection status).\n\n'
                          'Sonarr episode link mappings will NOT be affected.',
                        ),
                        actions: [
                          Button(child: const Text('Cancel'), onPressed: () => closeDialog()),
                          FilledButton(
                            style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(mat.Colors.red)),
                            child: const Text('Reset'),
                            onPressed: () async {
                              closeDialog();
                              final settings = SettingsManager();
                              await settings.resetTorrentConfig();
                              TorrentManager.reinitialize();
                              if (mounted) {
                                setState(() {});
                                snackBar('Torrent config reset', severity: InfoBarSeverity.success);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ],
      _ => <Widget>[],
    };

    return Padding(
      padding: EdgeInsets.only(top: 32, right: 32, bottom: 32, left: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list,
      ),
    );
  }

  Expanded ReadonlyTextBoxWithShiftAltButton(
    String? textboxText, {
    String unshiftTooltip = "",
    String shiftTooltip = "",
    Function(bool)? onPressed,
    bool isDisabled = false,
    String disabledTooltip = 'No folder selected',
  }) {
    return Expanded(
      child: SizedBox(
        height: 34,
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            //TODO make this go above if the horizontal space is too small
            TextBox(
              placeholder: disabledTooltip,
              controller: TextEditingController(text: textboxText ?? ''),
              readOnly: true,
              enabled: false,
            ),
            if (!isDisabled)
              Padding(
                padding: const EdgeInsets.all(3),
                child: ValueListenableBuilder(
                    valueListenable: KeyboardState.shiftPressedNotifier,
                    builder: (context, isShiftPressed, _) {
                      return MouseButtonWrapper(
                        tooltip: isDisabled ? disabledTooltip : (isShiftPressed ? shiftTooltip : unshiftTooltip),
                        isButtonDisabled: isDisabled,
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
                                  duration: getAnimationDuration(const Duration(milliseconds: 40)),
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
  EdgeInsets? padding,
  double? minHeight,
}) {
  return Card(
    borderRadius: BorderRadius.circular(8.0),
    padding: EdgeInsets.zero,
    child: ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight ?? 0),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(32.0),
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
    ),
  );
}
