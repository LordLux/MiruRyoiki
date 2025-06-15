// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Material, MaterialPageRoute, ScaffoldMessenger;
import 'package:fluent_ui/fluent_ui.dart' hide ColorExtension;
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_acrylic/window.dart' as flutter_acrylic;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:miruryoiki/screens/home.dart';
import 'package:miruryoiki/widgets/svg.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'package:system_theme/system_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_single_instance/windows_single_instance.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'services/anilist/provider/anilist_provider.dart';
import 'services/navigation/dialogs.dart';
import 'services/navigation/statusbar.dart';
import 'services/window/service.dart';
import 'settings.dart';
import 'splash_screen.dart';
import 'utils/logging.dart';
import 'manager.dart';
import 'services/library/library_provider.dart';
import 'screens/accounts.dart';
import 'screens/library.dart';
import 'screens/series.dart';
import 'screens/settings.dart';
import 'services/anilist/auth.dart';
import 'services/file_system/cache.dart';
import 'services/navigation/navigation.dart';
import 'services/file_system/registry.dart' as registry;
import 'services/navigation/shortcuts.dart';
import 'services/window/listener.dart';
import 'theme.dart';
import 'utils/color_utils.dart';
import 'utils/path_utils.dart';
import 'utils/screen_utils.dart';
import 'utils/time_utils.dart';
import 'widgets/animated_indicator.dart';
import 'widgets/buttons/wrapper.dart';
import 'widgets/cursors.dart';
import 'widgets/dialogs/link_anilist_multi.dart';
import 'widgets/inverted_border_radius_clipper.dart';
import 'widgets/window_buttons.dart';

final _appTheme = AppTheme();
final _navigationManager = NavigationManager();
final _settings = SettingsManager();

// ignore: library_private_types_in_public_api
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<_MiruRyoikiState> homeKey = GlobalKey<_MiruRyoikiState>();
final GlobalKey<SeriesScreenState> seriesScreenKey = GlobalKey<SeriesScreenState>();
final GlobalKey<LibraryScreenState> libraryScreenKey = GlobalKey<LibraryScreenState>();
final GlobalKey<AccountsScreenState> accountsKey = GlobalKey<AccountsScreenState>();

final GlobalKey<State<StatefulWidget>> paletteOverlayKey = GlobalKey<State<StatefulWidget>>();

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  await WindowsSingleInstance.ensureSingleInstance(
    args,
    "miruryoioki",
    onSecondWindow: (args) => log(args),
  );

  // Only run on Windows
  if (!Platform.isWindows) throw UnimplementedError('This app is only supported on Windows (for now).');

  // Load custom mouse cursors
  await initSystemMouseCursor();
  await disposeSystemMouseCursor();
  await initSystemMouseCursor();

  await initializeMiruRyoiokiSaveDirectory();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Register custom URL scheme for deep linking
  await registry.register(mRyoikiAnilistScheme);

  // Load system theme color
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) SystemTheme.accentColor.load();

  // Initialize Window Manager
  _initializeSplashScreenWindow();

  // Initialize image cache
  final imageCache = ImageCacheService();
  await imageCache.init();

  await initializeSVGs();

  // Initialize settings
  await _settings.init();

  // Run the app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Library(_settings), lazy: false),
        ChangeNotifierProvider(create: (_) => AnilistProvider()),
        ChangeNotifierProvider.value(value: _appTheme),
        ChangeNotifierProvider.value(value: _settings),
        ChangeNotifierProvider.value(value: _navigationManager),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    return CustomKeyboardListener(
      child: ScaffoldMessenger(
        child: FluentApp(
          navigatorKey: rootNavigatorKey,
          title: Manager.appTitle,
          theme: FluentThemeData(accentColor: appTheme.color, brightness: Brightness.light),
          darkTheme: FluentThemeData(accentColor: appTheme.color, brightness: Brightness.dark),
          color: appTheme.color,
          themeMode: appTheme.mode,
          home: AppContainer(),
          builder: (context, child) => _rootBuilder(context, child, appTheme),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }

  Widget _rootBuilder(BuildContext ctx, Widget? child, AppTheme appTheme) {
    TextStyle scaleTextStyle(TextStyle style, double scaleFactor) {
      return style.copyWith(fontSize: (style.fontSize ?? kDefaultFontSize) * scaleFactor);
    }

    Typography scaleTypography(Typography typography, double scaleFactor) {
      return Typography.raw(
        display: scaleTextStyle(typography.display!, scaleFactor),
        bodyLarge: scaleTextStyle(typography.bodyLarge!, scaleFactor),
        bodyStrong: scaleTextStyle(typography.bodyStrong!, scaleFactor),
        subtitle: scaleTextStyle(typography.subtitle!, scaleFactor),
        titleLarge: scaleTextStyle(typography.titleLarge!, scaleFactor),
        title: scaleTextStyle(typography.title!, scaleFactor),
        body: scaleTextStyle(typography.body!, scaleFactor),
        caption: scaleTextStyle(typography.caption!, scaleFactor),
      );
    }

    return FluentTheme(
      data: FluentTheme.of(ctx).copyWith(
        cursorOpacityAnimates: true,
        typography: scaleTypography(
          FluentTheme.of(ctx).typography,
          Manager.fontSizeMultiplier,
        ),
        buttonTheme: ButtonThemeData(
          defaultButtonStyle: ButtonStyle(
            padding: ButtonState.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 8)),
          ),
          filledButtonStyle: ButtonStyle(
            padding: ButtonState.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 8)),
          ),
        ),
      ),
      child: Navigator(
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (context) => Directionality(
            textDirection: appTheme.textDirection,
            child: NavigationPaneTheme(
              data: NavigationPaneThemeData(
                backgroundColor: appTheme.windowEffect != WindowEffect.disabled ? Colors.transparent : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: child!,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppContainer extends StatefulWidget {
  const AppContainer({super.key});

  @override
  State<AppContainer> createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    disposeSystemMouseCursor();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize AppLinks
      final appLinks = AppLinks();

      // Handle initial deep link
      final initialUri = await appLinks.getInitialLink();
      if (initialUri != null) {
        Manager.initialDeepLink = initialUri;
      }

      nextFrame(() {
        final appTheme = Provider.of<AppTheme>(context, listen: false);
        appTheme.setEffect(appTheme.windowEffect, context);
      });

      // Get providers
      final settings = Provider.of<SettingsManager>(context, listen: false);
      final libraryProvider = Provider.of<Library>(context, listen: false);

      // Initialize settings
      settings.applySettings(context);

      // Initialize library
      await libraryProvider.initialize(context);
    } catch (e, st) {
      logErr('Error during app initialization', e, st);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _initialized
          ? MiruRyoikiRoot()
          : SplashScreen(
              key: ValueKey('splash'),
              onInitComplete: () {
                setState(() {
                  _initialized = true;
                });
              },
            ),
    );
  }
}

class MiruRyoikiRoot extends StatefulWidget {
  const MiruRyoikiRoot({super.key});

  @override
  State<MiruRyoikiRoot> createState() => _MiruRyoikiRootState();
}

class _MiruRyoikiRootState extends State<MiruRyoikiRoot> {
  // Create an instance of AppLinks
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();

    // Listen for future deep links
    _appLinks = AppLinks();
    _handleIncomingLinks();
  }

  void _handleIncomingLinks() {
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    }, onError: (err) {
      logErr('Error handling incoming links', err);
    });
  }

  void _handleDeepLink(Uri uri) async {
    // Handle Anilist auth callback
    if (uri.toString().startsWith(redirectUrl)) {
      final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);
      await anilistProvider.handleAuthCallback(uri);
    }
  }

  @override
  Widget build(BuildContext context) => MiruRyoiki(key: homeKey);
}

class MiruRyoiki extends StatefulWidget {
  const MiruRyoiki({super.key});

  @override
  State<MiruRyoiki> createState() => _MiruRyoikiState();
}

ValueNotifier<int?> previousGridColumnCount = ValueNotifier<int?>(null);

class _MiruRyoikiState extends State<MiruRyoiki> {
  int _selectedIndex = 0;
  PathString? _selectedSeriesPath;
  PathString? lastSelectedSeriesPath;
  bool _isSeriesView = false;
  bool _showAnilistRedirectToProfile = false;

  final ScrollController libraryController = ScrollController();
  final ScrollController homeController = ScrollController();
  final ScrollController accountsController = ScrollController();
  final ScrollController settingsController = ScrollController();

  late final LibraryScreen _libraryScreen;

  bool _isFinishedTransitioning = false;
  bool _isSecondaryTitleBarVisible = false;

  // bool get _isLibraryView => !(_isSeriesView && _selectedSeriesPath != null);
  bool get isSeriesView => _isSeriesView;

  // ignore: unused_field
  bool _isNavigationPaneCollapsed = false;

  final GlobalKey<NavigationViewState> _paneKey = GlobalKey<NavigationViewState>();

  Widget anilistIcon(bool offline) => SizedBox(
        height: 25,
        width: 18,
        child: Transform.translate(
          offset: const Offset(2.5, 4),
          child: Transform.scale(
            scale: 1.45,
            child: Stack(
              children: [
                if (!offline) anilistLogo,
                if (offline) offlineLogo,
              ],
            ),
          ),
        ),
      );

  Widget get settingsIcon => AnimatedRotation(
        duration: getDuration(const Duration(milliseconds: 200)),
        turns: _selectedIndex == settingsIndex ? 0.5 : 0.0,
        child: const Icon(FluentIcons.settings, size: 18),
      );

  // Controllers will be added in initState
  // Define static consts for navigation indices to avoid duplication
  static const int homeIndex = 0;
  static const int libraryIndex = 1;
  static const int accountsIndex = 2;
  static const int settingsIndex = 3;

  final Map<int, Map<String, dynamic>> _navigationMap = {
    homeIndex: {'id': 'home', 'title': 'Home', 'controller': null},
    libraryIndex: {'id': 'library', 'title': 'Library', 'controller': null},
    accountsIndex: {'id': 'accounts', 'title': 'Account', 'controller': null},
    settingsIndex: {'id': 'settings', 'title': 'Settings', 'controller': null},
  };

  Map<String, dynamic> get _homeMap => _navigationMap[homeIndex]!;
  Map<String, dynamic> get _libraryMap => _navigationMap[libraryIndex]!;
  Map<String, dynamic> get _accountsMap => _navigationMap[accountsIndex]!;
  Map<String, dynamic> get _settingsMap => _navigationMap[settingsIndex]!;

  ScrollController _scrollController(int index) => _navigationMap[index]?['controller'] as ScrollController;

// Reset scroll position to top
  void _resetScrollPosition(int index, {bool animate = false}) {
    final controller = _scrollController(index);
    if (controller.hasClients) {
      if (animate)
        controller.animateTo(0.0, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
      else
        controller.jumpTo(0.0);
    }
  }

  @override
  void initState() {
    super.initState();
    _homeMap['controller'] = homeController;
    _libraryMap['controller'] = libraryController;
    _accountsMap['controller'] = accountsController;
    _settingsMap['controller'] = settingsController;

    _libraryScreen = LibraryScreen(
      key: libraryScreenKey,
      onSeriesSelected: navigateToSeries,
      scrollController: _libraryMap['controller'] as ScrollController,
    );

    nextFrame(() {
      final navManager = Provider.of<NavigationManager>(context, listen: false);
      final pane = _navigationMap[homeIndex]!;
      navManager.pushPane(pane['id'], pane['title']);
    });
  }

  @override
  void dispose() {
    final navManager = Provider.of<NavigationManager>(context, listen: false);
    navManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);

    return ValueListenableBuilder(
        valueListenable: WindowStateService.isFullscreenNotifier,
        builder: (context, isFullscreen, child) {
          return AnimatedContainer(
            duration: dimDuration,
            color: getDimmableBlack(context),
            child: Stack(
              children: [
                // Actual Window Content
                Positioned.fill(
                  child: AnimatedPadding(
                    duration: shortDuration,
                    padding: EdgeInsets.only(
                      top: _isSecondaryTitleBarVisible ? ScreenUtils.kTitleBarHeight : getTitleBarHeight(isFullscreen),
                      bottom: anilistProvider.isOffline ? 0 : 0,
                    ),
                    child: AnimatedContainer(
                      duration: dimDuration,
                      color: getDimmableBlack(context),
                      child: NavigationView(
                        onDisplayModeChanged: (value) => nextFrame(() => setState(() {
                              _isNavigationPaneCollapsed = _paneKey.currentState?.displayMode == PaneDisplayMode.compact;
                            })),
                        key: _paneKey,
                        pane: NavigationPane(
                          menuButton: const SizedBox.shrink(), //_appTitle(),
                          selected: _selectedIndex,
                          onItemPressed: (index) {
                            if (_isSeriesView && _selectedSeriesPath != null) {
                              // If in series view, exit series view first
                              exitSeriesView();
                            }
                            if (_selectedIndex == index) {
                              // If clicking the same tab, reset its scroll position
                              _resetScrollPosition(index, animate: true);
                            }
                          },
                          onChanged: (index) => setState(() {
                            _selectedIndex = index;
                            lastSelectedSeriesPath = _selectedSeriesPath;
                            _selectedSeriesPath = null;
                            _isSeriesView = false;

                            // Reset scroll when directly navigating to library
                            _resetScrollPosition(index);

                            // Register in navigation stack - add this code
                            final navManager = Provider.of<NavigationManager>(context, listen: false);

                            // Clear everything before adding a new pane
                            navManager.clearStack();

                            // Register the selected pane
                            final item = _navigationMap[index]!;
                            navManager.pushPane(item['id'], item['title']);
                          }),
                          displayMode: _isSeriesView ? PaneDisplayMode.compact : PaneDisplayMode.auto,
                          indicator: AnimatedNavigationIndicator(
                            targetColor: Manager.currentDominantColor,
                            indicatorBuilder: (color) => StickyNavigationIndicator(color: color),
                          ),
                          items: [
                            buildPaneItem(
                              homeIndex,
                              icon: movedPaneItemIcon(const Icon(FluentIcons.home)),
                              body: Stack(
                                children: [
                                  // Always keep LibraryScreen in the tree with Offstage
                                  Offstage(
                                    offstage: _isSeriesView && _selectedSeriesPath != null && _isFinishedTransitioning,
                                    child: AnimatedOpacity(
                                      duration: getDuration(const Duration(milliseconds: 230)),
                                      opacity: _isSeriesView ? 0.0 : 1.0,
                                      curve: Curves.easeInOut,
                                      child: AbsorbPointer(
                                        absorbing: _isSeriesView,
                                        child: HomeScreen(
                                          key: seriesScreenKey,
                                          onSeriesSelected: navigateToSeries,
                                          scrollController: _homeMap['controller'] as ScrollController,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Animated container for the SeriesScreen
                                  if (_selectedSeriesPath != null)
                                    AnimatedOpacity(
                                      duration: getDuration(const Duration(milliseconds: 300)),
                                      opacity: _isSeriesView ? 1.0 : 0.0,
                                      curve: Curves.easeInOut,
                                      onEnd: onEndTransitionToLibrary,
                                      child: AbsorbPointer(
                                        absorbing: !_isSeriesView,
                                        child: SeriesScreen(
                                          key: seriesScreenKey,
                                          seriesPath: _selectedSeriesPath!,
                                          onBack: exitSeriesView,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            buildPaneItem(
                              libraryIndex,
                              mouseCursorClick: _selectedIndex != libraryIndex || _isSeriesView,
                              icon: movedPaneItemIcon(const Icon(Symbols.newsstand)),
                              body: Stack(
                                children: [
                                  // Always keep LibraryScreen in the tree with Offstage
                                  Offstage(
                                    offstage: _isSeriesView && _selectedSeriesPath != null && _isFinishedTransitioning,
                                    child: AnimatedOpacity(
                                      duration: getDuration(const Duration(milliseconds: 230)),
                                      opacity: _isSeriesView ? 0.0 : 1.0,
                                      curve: Curves.easeInOut,
                                      child: AbsorbPointer(
                                        absorbing: _isSeriesView,
                                        child: _libraryScreen,
                                      ),
                                    ),
                                  ),

                                  // Animated container for the SeriesScreen
                                  if (_selectedSeriesPath != null)
                                    AnimatedOpacity(
                                      duration: getDuration(const Duration(milliseconds: 300)),
                                      opacity: _isSeriesView ? 1.0 : 0.0,
                                      curve: Curves.easeInOut,
                                      onEnd: onEndTransitionToLibrary,
                                      child: AbsorbPointer(
                                        absorbing: !_isSeriesView,
                                        child: SeriesScreen(
                                          key: seriesScreenKey,
                                          seriesPath: _selectedSeriesPath!,
                                          onBack: exitSeriesView,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                          footerItems: [
                            PaneItemSeparator(),
                            buildPaneItem(
                              accountsIndex,
                              icon: anilistIcon(anilistProvider.isOffline),
                              body: AccountsScreen(
                                key: accountsKey,
                                scrollController: _accountsMap['controller'] as ScrollController,
                              ),
                              extra: (isHovered) {
                                final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);
                                final user = anilistProvider.currentUser;

                                if (user == null) return null;

                                return Flexible(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Stack(
                                      alignment: Alignment.centerRight,
                                      children: [
                                        // PFP
                                        if (user.avatar != null)
                                          SizedBox(
                                            height: 50,
                                            width: 50,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                                              child: CircleAvatar(
                                                backgroundImage: NetworkImage(user.avatar!),
                                                backgroundColor: Manager.accentColor.withOpacity(0.25),
                                                radius: 17,
                                              ),
                                            ),
                                          ),
                                        // USERNAME
                                        Padding(
                                          padding: const EdgeInsets.only(right: 4.0),
                                          child: SizedBox(
                                            width: 40,
                                            height: 40,
                                            child: AnimatedOpacity(
                                              duration: getDuration(const Duration(milliseconds: 200)),
                                              opacity: _showAnilistRedirectToProfile ? 1 : 0,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(200),
                                                child: MouseButtonWrapper(
                                                  tooltip: 'Open Anilist Profile',
                                                  child: (_) => SizedBox(
                                                    height: 22,
                                                    child: MouseRegion(
                                                      onEnter: (_) {
                                                        if (!_showAnilistRedirectToProfile) setState(() => _showAnilistRedirectToProfile = true);
                                                      },
                                                      onExit: (_) {
                                                        if (_showAnilistRedirectToProfile) setState(() => _showAnilistRedirectToProfile = false);
                                                      },
                                                      child: IconButton(
                                                        icon: Icon(
                                                          Symbols.open_in_new,
                                                          size: 18,
                                                          color: FluentTheme.of(context).resources.textFillColorPrimary,
                                                        ),
                                                        onPressed: !_showAnilistRedirectToProfile //
                                                            ? null
                                                            : () {
                                                                // open profile page on anilist
                                                                launchUrlString('https://anilist.co/user/${user.name}');
                                                              },
                                                      ),
                                                    ),
                                                  ),
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
                            ),
                            buildPaneItem(
                              settingsIndex,
                              icon: movedPaneItemIcon(const Icon(FluentIcons.settings)),
                              body: SettingsScreen(
                                scrollController: _settingsMap['controller'] as ScrollController,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Title Bar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedContainer(
                    duration: shortDuration,
                    color: getDimmableBlack(context),
                    height: getTitleBarHeight(isFullscreen),
                    child: AnimatedOpacity(
                      duration: shortDuration,
                      opacity: isFullscreen ? 0 : 1,
                      child: _buildTitleBar(),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedContainer(
                    color: getDimmableBlack(context),
                    duration: shortDuration,
                    height: _isSecondaryTitleBarVisible ? ScreenUtils.kTitleBarHeight - getTitleBarHeight(isFullscreen) : 0,
                    child: AnimatedOpacity(
                      duration: shortDuration,
                      opacity: _isSecondaryTitleBarVisible && isFullscreen ? 1 : 0,
                      child: _buildTitleBar(isSecondary: true),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedContainer(
                    duration: shortDuration,
                    height: _isSecondaryTitleBarVisible ? ScreenUtils.kTitleBarHeight - getTitleBarHeight(isFullscreen) : 5,
                    child: MouseRegion(
                      hitTestBehavior: HitTestBehavior.translucent,
                      onEnter: (_) {
                        setState(() => _isSecondaryTitleBarVisible = true);
                        nextFrame(delay: 100, () {
                          Manager.setState();
                        });
                      },
                      onExit: (_) => setState(() => _isSecondaryTitleBarVisible = false),
                    ),
                  ),
                ),
                const StatusBarWidget(),
                //TODO add timer for when we are back online, to hide this after a few seconds
                // AnimatedPositioned(
                //   duration: dimDuration,
                //   bottom: offline ? 0 : -20,
                //   child: Container(
                //     height: ScreenUtils.kOfflineBarMaxHeight,
                //     width: _paneKey.currentState?.displayMode == PaneDisplayMode.compact ? 50 : 320,
                //     color: (offline ? Colors.red : Colors.green).withOpacity(.5),
                //     child: Center(
                //       child: Text(
                //         offline ? 'Offline' : 'Online',
                //         style: Manager.bodyStyle,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          );
        });
  }

  Widget movedPaneItemIcon(Widget icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: icon,
    );
  }

  PaneItem buildPaneItem(
    int id, {
    required Widget icon,
    required Widget body,
    bool? mouseCursorClick,
    Widget? Function(bool isHovered)? extra,
  }) {
    final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);
    final item = _navigationMap[id]!;
    final title = item['title'];
    mouseCursorClick ??= _selectedIndex != id;

    if (id == accountsIndex && anilistProvider.isOffline) {
      final msg = 'You are Offline';
      icon = TooltipTheme(
        data: TooltipThemeData(
          waitDuration: const Duration(milliseconds: 100),
        ),
        child: Tooltip(
          message: msg,
          child: icon,
        ),
      );
    }

    return PaneItem(
      key: ValueKey("pane_item_$id"),
      mouseCursor: mouseCursorClick ? SystemMouseCursors.click : MouseCursor.defer,
      title: Text(title, style: Manager.bodyStyle),
      icon: icon,
      body: body,
      trailing: extra?.call(true),
    );
  }

  double getTitleBarHeight(bool isFullscreen) {
    return isFullscreen ? 0.0 : ScreenUtils.kTitleBarHeight;
  }

  /// Custom title bar with menu bar and window buttons
  Widget _buildTitleBar({bool isSecondary = false}) {
    double winButtonsWidth = 128;
    return ValueListenableBuilder<bool>(
        valueListenable: Manager.navigation.stackNotifier,
        builder: (context, _, __) {
          return AnimatedContainer(
            duration: dimDuration,
            color: Manager.navigation.hasDialog ? getBarrierColor(Manager.currentDominantColor) : Colors.transparent,
            child: Stack(
              children: [
                Positioned.fill(
                  child: WindowTitleBarBox(
                    child: MoveWindow(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 30,
                              child: Transform.translate(
                                offset: const Offset(2.5, 2),
                                child: Image.file(
                                  File(iconPath),
                                  width: 19,
                                  height: 19,
                                  errorBuilder: (_, __, ___) => Icon(Symbols.animated_images, size: 19),
                                ),
                              ),
                            ),
                          ),
                          SizedBox.shrink(),
                          // Windows Window Buttons
                          SizedBox(width: winButtonsWidth),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Menu bar
                      Transform.translate(
                        offset: const Offset(-19, 1.75),
                        child: SizedBox(
                          width: winButtonsWidth + 71 + 13,
                          child: Text(
                            Manager.appTitle,
                            overflow: TextOverflow.clip,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.raleway(
                              fontSize: 15,
                              fontWeight: FontWeight.w300,
                              color: FluentTheme.of(context).typography.body!.color,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtils.kTitleBarHeight,
                        child: WindowButtons(isSecondary: isSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  /// Called immediately when a series is selected from the library or home screen
  void navigateToSeries(PathString seriesPath) {
    previousGridColumnCount.value = ScreenUtils.crossAxisCount();

    final series = Provider.of<Library>(context, listen: false).getSeriesByPath(seriesPath);
    final seriesName = series?.name ?? 'Series';

    // Update navigation stack
    Provider.of<NavigationManager>(context, listen: false).pushPage('series:$seriesPath', seriesName, data: seriesPath);

    _selectedSeriesPath = seriesPath;
    Manager.currentDominantColor = series?.dominantColor;
    _isSeriesView = true;
    Manager.setState();
  }

  /// Called immediately when exiting the series view
  void exitSeriesView() {
    previousGridColumnCount.value = ScreenUtils.crossAxisCount();

    final navManager = Provider.of<NavigationManager>(context, listen: false);

    if (navManager.currentView?.level == NavigationLevel.page) //
      navManager.goBack();

    setState(() {
      lastSelectedSeriesPath = _selectedSeriesPath ?? lastSelectedSeriesPath;
      _isSeriesView = false;
      _isFinishedTransitioning = false;
    });
  }

  /// Called when the transition to the library view ends
  void onEndTransitionToLibrary() {
    setState(() {
      if (_isSeriesView) _isFinishedTransitioning = true;
      _selectedSeriesPath = null;
      previousGridColumnCount.value = null;
      Manager.currentDominantColor = null;
    });
  }

  // Add this helper method
  bool handleBackNavigation({bool isEsc = false}) {
    final navManager = Provider.of<NavigationManager>(context, listen: false);
    libraryScreenKey.currentState?.toggleFiltersSidebar(value: false);

    if (navManager.hasDialog && !isEsc) {
      logTrace('$nowFormatted | Back Mouse Button Pressed: Closing dialog');
      // Find active dialogs and close them
      // This assumes dialogs are managed through Flutter's dialog system
      // and will be removed from stack using the showManagedDialog helper
      // TODO
      // closeDialog(rootNavigatorKey.currentContext!);
      return true;
    } else if (_isSeriesView) {
      if (!navManager.hasDialog) {
        // Coming back from series view
        logTrace('Going back in navigation stack! -> Library');
        exitSeriesView();
      } else {
        if (!Manager.canPopDialog) {
          if (navManager.currentView?.id.startsWith('linkAnilist') ?? false) {
            logTrace('Link Anilist dialog is open, switching to view mode');
            nextFrame(() => linkMultiDialogKey.currentState?.switchToViewMode());
          }
        }
      }
      return true;
    } else if (navManager.canGoBack) {
      logDebug('Going back in navigation stack -> ${navManager.stack[navManager.stack.length - 2].title}');
      // navManager.goBack();

      // Navigate based on the new current item
      final currentItem = navManager.currentView;
      if (currentItem != null) {
        if (currentItem.level == NavigationLevel.pane) {
          // Switch to appropriate pane
          final index = _getPaneIndexFromId(currentItem.id);
          if (index != null && index != _selectedIndex) {
            setState(() {
              _selectedIndex = index;
            });
          }
        } else if (currentItem.level == NavigationLevel.page) {
          // Check if it's a series page
          if (currentItem.id.startsWith('series:') && currentItem.data is String) {
            setState(() {
              _selectedSeriesPath = currentItem.data as PathString;
              _isSeriesView = true;
            });
          }
        }
      }
      return true;
    }

    return false;
  }

// Helper method to determine pane index from ID
  int? _getPaneIndexFromId(String id) {
    // check dynamically inside the _navigationMap
    for (final entry in _navigationMap.entries) {
      if (entry.value['id'] == id) return entry.key;
    }
    return null; // Not found
  }
}

Future<void> _initializeSplashScreenWindow() async {
  await flutter_acrylic.Window.initialize();
  await flutter_acrylic.Window.hideWindowControls();
  await WindowManager.instance.ensureInitialized();

  final Size initialSize = Size(ScreenUtils.kDefaultSplashScreenWidth, ScreenUtils.kDefaultSplashScreenHeight);

  // only for UI
  doWhenWindowReady(() {
    final win = appWindow;
    win.size = initialSize;
    win.minSize = initialSize;
    win.maxSize = initialSize;
    win.alignment = Alignment.center;
    win.title = Manager.appTitle;
    win.show();
  });

  WindowOptions windowOptions = WindowOptions(
    size: initialSize,
    minimumSize: initialSize,
    maximumSize: initialSize,
    center: true,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: Manager.appTitle,
    alwaysOnTop: true,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    windowManager.addListener(MyWindowListener());
    await windowManager.setPreventClose(true);
    await windowManager.setSkipTaskbar(false);
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden, windowButtonVisibility: false);
    await windowManager.setMinimumSize(initialSize);
    await windowManager.setMaximumSize(initialSize);
    await windowManager.setSize(initialSize);
    await windowManager.setResizable(false);
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setTitle(Manager.appTitle);
    await windowManager.setIgnoreMouseEvents(true);
    await windowManager.show();
    await windowManager.focus();
    setIcon();
  });
}

void setIcon() async {
  if (await File(iconPath).exists()) {
    await windowManager.setIcon(iconPath);
  } else {
    logDebug('Icon file does not exist: $iconPath');
  }
}

// TODO add Anilist sync status and internet connection status to the status bar
// TODO edit view options for library to separate sort and view (grid, list etc) from filters
// TODO homepage title inside header like in library + view options to choose what to show on homepage
// TODO understand what makes 'scan library' button smooth on rescale

// TODO cache Anilist lists to be able to work offline
// TODO anilist grouping for 'About to Watch'
// TODO Local 'Unlinked' auto connect to Anilist 'About to Watch' (allow custom name to search for)
// TODO add folder/file metadata to series
// TODO create autolinker
// TODO change FORMATTER format for specials (allow specials inside season, OVA/ONAs in separate folder if not alone)
// TODO fix back mouse button navigation
// TODO add group traversal policies to app
