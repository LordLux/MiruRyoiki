// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Material, MaterialPageRoute, ScaffoldMessenger;
import 'package:fluent_ui/fluent_ui.dart' hide ColorExtension;
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_acrylic/window.dart' as flutter_acrylic;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'package:system_theme/system_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_single_instance/flutter_single_instance.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:win32_registry/win32_registry.dart';

import 'screens/home.dart';
import 'screens/release_calendar.dart';
import 'widgets/dialogs/splash/progress.dart';
import 'widgets/release_notification.dart';
import 'widgets/svg.dart';
import 'widgets/connectivity_indicator.dart';
import 'services/anilist/provider/anilist_provider.dart';
import 'services/connectivity/connectivity_service.dart';
import 'services/navigation/dialogs.dart';
import 'services/navigation/statusbar.dart';
import 'services/window/service.dart';
import 'settings.dart';
import 'widgets/dialogs/splash/splash_screen.dart';
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
import 'services/navigation/shortcuts.dart';
import 'services/window/listener.dart';
import 'theme.dart';
import 'utils/color_utils.dart';
import 'utils/path_utils.dart';
import 'utils/screen_utils.dart';
import 'utils/time_utils.dart';
import 'widgets/animated_indicator.dart';
import 'widgets/cursors.dart';
import 'widgets/dialogs/link_anilist_multi.dart';
import 'widgets/window_buttons.dart';

final _appTheme = AppTheme();
final _navigationManager = NavigationManager();
final _settings = SettingsManager();
RootIsolateToken? rootIsolateToken;

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<_MiruRyoikiState> homeKey = GlobalKey<_MiruRyoikiState>();
final GlobalKey<SeriesScreenState> seriesScreenKey = GlobalKey<SeriesScreenState>();
final GlobalKey<SeriesScreenState> librarySeriesScreenKey = GlobalKey<SeriesScreenState>();
final GlobalKey<LibraryScreenState> libraryScreenKey = GlobalKey<LibraryScreenState>();
final GlobalKey<ReleaseCalendarScreenState> releaseCalendarScreenKey = GlobalKey<ReleaseCalendarScreenState>();
final GlobalKey<AccountsScreenState> accountsKey = GlobalKey<AccountsScreenState>();

final GlobalKey<State<StatefulWidget>> paletteOverlayKey = GlobalKey<State<StatefulWidget>>();

/// Get the currently active SeriesScreenState based on which tab is selected
SeriesScreenState? getActiveSeriesScreenState() {
  final miruRyoikiState = homeKey.currentState;
  if (miruRyoikiState == null) return null;

  // Check which tab is currently selected
  if (miruRyoikiState.selectedIndex == _MiruRyoikiState.homeIndex) {
    return seriesScreenKey.currentState;
  } else if (miruRyoikiState.selectedIndex == _MiruRyoikiState.libraryIndex) {
    return librarySeriesScreenKey.currentState;
  }

  return null;
}

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensures there's only one instance of the program
  _ensureSingleInstance();

  // Only run on Windows and MacOS
  if (!(Platform.isWindows || Platform.isMacOS)) throw UnimplementedError('This app is only supported on Windows (for now).');

  // Initializes the MiruRyoiki save directory
  await initializeMiruRyoikiSaveDirectory();

  // Initialize session-based error logging
  await initializeLoggingSession();

  Manager.init();

  Manager.parseArgs();

  // Gets the root isolate token
  rootIsolateToken = ServicesBinding.rootIsolateToken;

  // Load custom mouse cursors
  await initSystemMouseCursor();
  await disposeSystemMouseCursor();
  await initSystemMouseCursor();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Register custom URL scheme for deep linking
  await _registerUrlScheme(mRyoikiAnilistScheme);

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
        ChangeNotifierProvider(create: (_) => ConnectivityService(), lazy: false),
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
    return ScaffoldMessenger(
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
      child: DefaultTextStyle(
        style: FluentTheme.of(ctx).typography.body!,
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
  late final MiruRyoikiRoot _miruRyoikiRoot;
  late final SplashScreen _splashScreen;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _miruRyoikiRoot = MiruRyoikiRoot();
    _splashScreen = SplashScreen(
      key: ValueKey('splash'),
      onInitComplete: () => Future.delayed(Duration(milliseconds: 400), () => setState(() => _initialized = true)),
    );
  }

  @override
  void dispose() {
    disposeSystemMouseCursor();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      // transitionBuilder: (_, Animation<double> animation) => FadeTransition(opacity: animation, child: _),
      child: _initialized ? _miruRyoikiRoot : _splashScreen,
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

  @override
  void dispose() {
    super.dispose();
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
  Widget build(BuildContext context) => CustomKeyboardListener(child: MiruRyoiki(key: homeKey));
}

class MiruRyoiki extends StatefulWidget {
  const MiruRyoiki({super.key});

  @override
  State<MiruRyoiki> createState() => _MiruRyoikiState();
}

ValueNotifier<int?> previousGridColumnCount = ValueNotifier<int?>(null);

class _MiruRyoikiState extends State<MiruRyoiki> {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex; // Public getter for helper function
  int _previousIndex = 0;
  PathString? _selectedSeriesPath;
  PathString? lastSelectedSeriesPath;
  bool _isSeriesView = false;
  bool isStartedTransitioning = false;
  
  /// Whether the transition animation to the series screen has fully completed
  bool _isFinishedTransitioningToSeries = false;

  /// Whether the transition animation back to the library screen has fully completed
  bool _isFinishedTransitioningToLibrary = true;
  bool _isSecondaryTitleBarVisible = false;
  bool seriesWasModified = false;
  // ignore: unused_field
  bool _isNavigationPaneCollapsed = false;

  final ScrollController libraryController = ScrollController();
  final ScrollController homeController = ScrollController();
  final ScrollController calendarController = ScrollController();
  final ScrollController accountsController = ScrollController();
  final ScrollController settingsController = ScrollController();

  late final LibraryScreen _libraryScreen;

  // bool get _isLibraryView => !(_isSeriesView && _selectedSeriesPath != null);
  bool get isSeriesView => _isSeriesView;

  PathString? get selectedSeriesPath => _selectedSeriesPath;

  final GlobalKey<NavigationViewState> _paneKey = GlobalKey<NavigationViewState>();

  Widget anilistIcon(bool offline) {
    homeKey.currentState?.isSeriesView;
    return SizedBox(
      height: 25,
      width: 18,
      child: Transform.translate(
        offset: const Offset(2.5, 4),
        child: Transform.scale(
          scale: 1.45,
          child: ValueListenableBuilder<bool>(
            valueListenable: ConnectivityService().isOnlineNotifier,
            builder: (context, isOnline, child) {
              return Stack(
                children: [
                  if (isOnline) anilistLogo,
                  if (!isOnline) offlineLogo,
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget get settingsIcon {
    return AnimatedRotation(
      duration: getDuration(const Duration(milliseconds: 200)),
      turns: _selectedIndex == settingsIndex ? 0.5 : 0.0,
      child: const Icon(FluentIcons.settings, size: 18),
    );
  }

  // Controllers will be added in initState
  // Define static consts for navigation indices to avoid duplication
  static const int homeIndex = 0;
  static const int libraryIndex = 1;
  static const int calendarIndex = 2;
  static const int accountsIndex = 3;
  static const int settingsIndex = 4;

  final Map<int, Map<String, dynamic>> _navigationMap = {
    homeIndex: {'id': 'home', 'title': 'Home', 'controller': null},
    libraryIndex: {'id': 'library', 'title': 'Library', 'controller': null},
    calendarIndex: {'id': 'calendar', 'title': 'Releases', 'controller': null},
    accountsIndex: {'id': 'accounts', 'title': 'Account', 'controller': null},
    settingsIndex: {'id': 'settings', 'title': 'Settings', 'controller': null},
  };

  Map<String, dynamic> get _homeMap => _navigationMap[homeIndex]!;
  Map<String, dynamic> get _libraryMap => _navigationMap[libraryIndex]!;
  Map<String, dynamic> get _calendarMap => _navigationMap[calendarIndex]!;
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

  void openSettings() => _onChanged(settingsIndex);

  void _onChanged(int index) {
    setState(() {
      _selectedIndex = index;
      lastSelectedSeriesPath = _selectedSeriesPath;
      _selectedSeriesPath = null;
      _isSeriesView = false;
      Manager.currentDominantColor = null;

      // Reset scroll when directly navigating to library
      _resetScrollPosition(index);

      // Register in navigation stack - add this code
      final navManager = Provider.of<NavigationManager>(context, listen: false);

      // Clear everything before adding a new pane
      navManager.clearStack();

      // Register the selected pane
      final item = _navigationMap[index]!;
      navManager.pushPane(item['id'], item['title']);

      if (index == calendarIndex) {
        nextFrame(() {
          // releaseCalendarScreenKey.currentState?.scrollToToday(animated: false);
          // Refresh notifications and release data when navigating to calendar
          releaseCalendarScreenKey.currentState?.loadReleaseData();
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _homeMap['controller'] = homeController;
    _libraryMap['controller'] = libraryController;
    _calendarMap['controller'] = calendarController;
    _accountsMap['controller'] = accountsController;
    _settingsMap['controller'] = settingsController;

    _libraryScreen = LibraryScreen(
      key: libraryScreenKey,
      onSeriesSelected: navigateToSeries,
      scrollController: _libraryMap['controller'] as ScrollController,
    );

    nextFrame(() async {
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
                    bottom: 0,
                  ),
                  child: AnimatedContainer(
                    duration: dimDuration,
                    color: getDimmableBlack(context),
                    child: NavigationView(
                      onDisplayModeChanged: (value) => nextFrame(() => setState(() {
                            _isNavigationPaneCollapsed = _paneKey.currentState?.displayMode == PaneDisplayMode.compact;
                          })),
                      key: _paneKey,
                      paneBodyBuilder: (item, body) {
                        return Column(
                          children: [
                            // Offline banner
                            Expanded(child: body!),
                            const OfflineBanner(),
                            ValueListenableBuilder(
                              valueListenable: LibraryScanProgressManager().showingNotifier,
                              builder: (context, isShowing, child) {
                                return AnimatedContainer(
                                  duration: shortDuration,
                                  color: getDimmableWhite(context),
                                  height: !isShowing ? 0 : ScreenUtils.kStatusBarHeight,
                                );
                              },
                            )
                          ],
                        );
                      },
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
                            // releaseCalendarScreenKey.currentState?.toggleFilter(false);
                            releaseCalendarScreenKey.currentState?.focusToday();
                          }
                        },
                        onChanged: _onChanged,
                        displayMode: _isSeriesView ? PaneDisplayMode.compact : PaneDisplayMode.auto,
                        indicator: AnimatedNavigationIndicator(
                          targetColor: Manager.currentDominantColor,
                          indicatorBuilder: (color) => StickyNavigationIndicator(color: color),
                        ),
                        items: [
                          buildPaneItem(
                            homeIndex,
                            icon: movedPaneItemIcon(const Icon(FluentIcons.home)),
                            body: HomeScreen(
                              onSeriesSelected: navigateToSeries,
                              scrollController: _homeMap['controller'] as ScrollController,
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
                                  offstage: _isSeriesView && _selectedSeriesPath != null && _isFinishedTransitioningToSeries,
                                  child: AnimatedOpacity(
                                    duration: getDuration(const Duration(milliseconds: 330)),
                                    opacity: _isSeriesView ? 0.0 : 1.0,
                                    curve: Curves.ease,
                                    child: AbsorbPointer(
                                      absorbing: _isSeriesView,
                                      child: _libraryScreen,
                                    ),
                                  ),
                                ),

                                // Animated container for the SeriesScreen
                                // will hide only after fade out animation finishes
                                  AbsorbPointer(
                                    absorbing: !_isSeriesView,
                                    child: AnimatedOpacity(
                                      duration: getDuration(const Duration(milliseconds: 300)),
                                      opacity: _isSeriesView ? 1.0 : 0.0,
                                      curve: Curves.ease,
                                      onEnd: onEndTransitionSeriesScreen,
                                      child: _isFinishedTransitioningToLibrary ? const SizedBox.shrink() : SeriesScreen(
                                        key: librarySeriesScreenKey,
                                        seriesPath: _selectedSeriesPath,
                                        onBack: exitSeriesView,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (anilistProvider.isLoggedIn)
                            buildPaneItem(
                              calendarIndex,
                              icon: movedPaneItemIcon(const Icon(FluentIcons.calendar)),
                              body: ReleaseCalendarScreen(
                                key: releaseCalendarScreenKey,
                                onSeriesSelected: navigateToSeries,
                                scrollController: _calendarMap['controller'] as ScrollController,
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
                                  child: SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                                      child: Builder(builder: (context) {
                                        if (user.avatar == null) return CircleAvatar(backgroundColor: Manager.accentColor.withOpacity(0.25));

                                        return CircleAvatar(
                                          backgroundImage: CachedNetworkImageProvider(
                                            user.avatar!,
                                            errorListener: (error) {
                                              logWarn('Failed to load Anilist avatar image: $error');
                                            },
                                          ),
                                          backgroundColor: Manager.accentColor.withOpacity(0.25),
                                          radius: 17,
                                        );
                                      }),
                                    ),
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
                child: SizedBox(
                  height: _isSecondaryTitleBarVisible
                      ? ScreenUtils.kTitleBarHeight - getTitleBarHeight(isFullscreen)
                      : isFullscreen
                          ? 5
                          : 0,
                  child: MouseRegion(
                    hitTestBehavior: HitTestBehavior.translucent,
                    onEnter: (_) => setState(() => _isSecondaryTitleBarVisible = true),
                    onExit: (_) => setState(() => _isSecondaryTitleBarVisible = false),
                  ),
                ),
              ),
              const StatusBarWidget(),
              const LibraryScanProgressIndicator(),
            ],
          ),
        );
      },
    );
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

  double getTitleBarHeight(bool isFullscreen) => isFullscreen ? 0.0 : ScreenUtils.kTitleBarHeight;

  /// Custom title bar with menu bar and window buttons
  Widget _buildTitleBar({bool isSecondary = false}) {
    double winButtonsWidth = 128;
    return ValueListenableBuilder<bool>(
        valueListenable: Manager.navigation.stackNotifier,
        builder: (context, _, __) {
          return AnimatedContainer(
            duration: dimDuration,
            color: Manager.navigation.hasDialog && Manager.navigation.currentView?.id != "notifications" ? getBarrierColor(Manager.currentDominantColor) : Colors.transparent,
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
                      // Notification area - before window buttons
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ValueListenableBuilder(
                                valueListenable: WindowStateService.isFullscreenNotifier,
                                builder: (context, isFullscreen, child) {
                                  return AnimatedSlide(
                                    duration: shortDuration,
                                    offset: isFullscreen ? const Offset(1.5, 0) : const Offset(0, 0),
                                    child: ReleaseNotificationWidget(
                                      onMorePressed: (ctx) async {
                                        // Navigate to calendar screen
                                        closeDialog(ctx);
                                        await Future.delayed(const Duration(milliseconds: 100));
                                        setState(() {
                                          if (_isSeriesView && _selectedSeriesPath != null) exitSeriesView();

                                          _selectedIndex = calendarIndex;
                                          _resetScrollPosition(calendarIndex);

                                          final navManager = Manager.navigation;

                                          final item = _navigationMap[calendarIndex]!;
                                          navManager.clearAndPushPane(item['id'], item['title']);
                                        });

                                        // Refresh the release calendar after navigation
                                        nextFrame(() {
                                          releaseCalendarScreenKey.currentState?.loadReleaseData();
                                        });
                                      },
                                    ),
                                  );
                                }),
                          ),
                          SizedBox(
                            height: ScreenUtils.kTitleBarHeight,
                            child: WindowButtons(isSecondary: isSecondary, onFullScreenOpen: () => setState(() => _isSecondaryTitleBarVisible = true)),
                          ),
                        ],
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
  void navigateToSeries(PathString seriesPath) async {
    _previousIndex = _selectedIndex;
    // First, ensure we're on the library pane if not already
    if (_selectedIndex != libraryIndex || _isSeriesView) {
      logTrace('Navigating to library pane before opening series view');
      setState(() {
        _selectedIndex = libraryIndex;
        lastSelectedSeriesPath = _selectedSeriesPath;
        _selectedSeriesPath = null;
        _isSeriesView = false;
        Manager.currentDominantColor = null;

        // Reset scroll when directly navigating to library
        _resetScrollPosition(libraryIndex);

        // Register in navigation stack
        final navManager = Provider.of<NavigationManager>(context, listen: false);
        navManager.clearStack();

        // Register the library pane
        final item = _navigationMap[libraryIndex]!;
        navManager.pushPane(item['id'], item['title']);
      });

      // Small delay to allow UI to update to library pane first
      await Future.delayed(const Duration(milliseconds: 50));
    }

    isStartedTransitioning = true;

    previousGridColumnCount.value = ScreenUtils.crossAxisCount(ScreenUtils.libraryContentWidthWithoutPadding);

    final series = Provider.of<Library>(context, listen: false).getSeriesByPath(seriesPath);
    final seriesName = series?.name ?? 'Series';

    // Update navigation stack with the series page
    Provider.of<NavigationManager>(context, listen: false).pushPage('series:$seriesPath', seriesName, data: seriesPath);

    setState(() {
      _selectedSeriesPath = seriesPath;
      Manager.currentDominantColor = series?.dominantColor;
      _isSeriesView = true;
      _isFinishedTransitioningToLibrary = false;
    });

    Manager.setState();
  }

  /// Called immediately when exiting the series view
  void exitSeriesView() {
    previousGridColumnCount.value = ScreenUtils.crossAxisCount(ScreenUtils.libraryContentWidthWithoutPadding);

    final navManager = Provider.of<NavigationManager>(context, listen: false);

    if (navManager.currentView?.level == NavigationLevel.page) //
      navManager.goBack();

    if (!Manager.settings.returnToLibraryAfterSeriesScreen) {
      navManager.navigateToPane(_navigationMap[_previousIndex]!['id']);
      _selectedIndex = _previousIndex;
    }

    setState(() {
      Manager.currentDominantColor = null;
      lastSelectedSeriesPath = _selectedSeriesPath ?? lastSelectedSeriesPath;
      _isSeriesView = false;
      _isFinishedTransitioningToLibrary = false;
      _isFinishedTransitioningToSeries = false;
    });

    if (seriesWasModified) {
      // Use the key to access the library screen state
      libraryScreenKey.currentState?.invalidateSortCache();
      seriesWasModified = false;
      Manager.setState();
    }
  }

  /// Called when the transition to the library view ends
  void onEndTransitionSeriesScreen() {
    setState(() {
      // When going from series view to library
      if (_isSeriesView) {
        _isFinishedTransitioningToSeries = true;
      } else {
        _selectedSeriesPath = null;
        _isFinishedTransitioningToLibrary = true;
        _isFinishedTransitioningToSeries = false;
        Manager.currentDominantColor = null;
      }
      isStartedTransitioning = false;
      previousGridColumnCount.value = null;
    });
  }

  // Add this helper method
  bool handleBackNavigation({bool isEsc = false}) {
    final navManager = Provider.of<NavigationManager>(context, listen: false);

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
    // alwaysOnTop: true,
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
    // await windowManager.setAlwaysOnTop(true); keep commented
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

void _ensureSingleInstance() async {
  if (!(await FlutterSingleInstance().isFirstInstance())) {
    if (kDebugMode) print("App is already running");

    final err = await FlutterSingleInstance().focus();

    // ignore: avoid_print
    if (err != null) print("Error focusing running instance: $err");
    exit(0);
  }
}

/// Registers a custom URL scheme for deep linking
/// - Windows: Registers in Windows Registry
/// - macOS: Handled by Info.plist (no runtime registration needed)
/// - Other platforms: No-op
Future<void> _registerUrlScheme(String scheme) async {
  if (Platform.isWindows) await _registerWindowsUrlScheme(scheme);
  // MacOS URL schemes are registered via Info.plist
}

Future<void> _registerWindowsUrlScheme(String scheme) async {
  try {
    String appPath = Platform.resolvedExecutable;
    String protocolRegKey = 'Software\\Classes\\$scheme';

    RegistryValue protocolRegValue = RegistryValue.string('URL Protocol', '');
    String protocolCmdRegKey = 'shell\\open\\command';
    RegistryValue protocolCmdRegValue = RegistryValue.string('', '"$appPath" "%1"');

    final regKey = Registry.currentUser.createKey(protocolRegKey);
    regKey.createValue(protocolRegValue);
    regKey.createKey(protocolCmdRegKey).createValue(protocolCmdRegValue);
  } catch (e) {
    logErr('Warning: Could not register URL scheme: $e');
  }
}

// TODO move hidden series switches to settings
// TODO add ctrl + tab navigation
// TODO cache anime info
// TODO view settings to choose what to show on homepage

// TODO cache Anilist lists to be able to work offline
// TODO anilist grouping for 'About to Watch'
// TODO Local 'Unlinked' auto connect to Anilist 'About to Watch' (allow custom name to search for)
// TODO create autolinker
// TODO change FORMATTER format for specials (allow specials inside season, OVA/ONAs in separate folder if not alone)
// TODO fix back mouse button navigation
// TODO understand what makes 'scan library' button smooth on rescale
// TODO add group traversal policies to app
