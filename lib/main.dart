// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Material, MaterialPageRoute, ScaffoldMessenger;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_acrylic/window.dart' as flutter_acrylic;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:miruryoiki/models/anilist/anime_card.dart';
import 'package:miruryoiki/widgets/frosted_noise.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'package:system_theme/system_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:flutter_single_instance/flutter_single_instance.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:win32_registry/win32_registry.dart';

import 'database/database.dart';
import 'enums.dart';
import 'services/players/media_player_monitor.dart';
import 'services/library/scanner/scanner_service.dart';
import 'screens/downloads_screen.dart';
import 'screens/search.dart';
import 'screens/searched_series.dart';
import 'services/downloads/torrent_manager.dart';
import 'screens/home.dart';
import 'screens/release_calendar.dart';
import 'services/isolates/thumbnail_manager.dart';
import 'widgets/dialogs/padded_dialog_route.dart';
import 'widgets/dialogs/splash/status.dart';
import 'widgets/reassemble_widget.dart';
import 'widgets/route_transition_builders.dart';
import 'widgets/sidebar_opener_detector.dart';
import 'widgets/player.dart';
import 'widgets/release_notification.dart';
import 'widgets/svg.dart';
import 'services/anilist/provider/anilist_provider.dart';
import 'viewmodels/release_calendar_viewmodel.dart';
import 'services/connectivity/connectivity_service.dart';
import 'services/navigation/statusbar.dart';
import 'settings.dart';
import 'widgets/animated_account_avatar.dart';
import 'widgets/dialogs/splash/splash_screen.dart';
import 'utils/logging.dart';
import 'manager.dart';
import 'services/library/hidden_series_service.dart';
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
import 'utils/color.dart';
import 'utils/path.dart';
import 'utils/screen.dart';
import 'utils/time.dart';
import 'widgets/animated_indicator.dart';
import 'widgets/cursors.dart';
import 'widgets/window_buttons.dart';

final _appTheme = AppTheme();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final _navigationManager = NavigationManager(navigatorKey);
final _settings = SettingsManager();
RootIsolateToken? rootIsolateToken;

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<_MiruRyoikiState> homeKey = GlobalKey<_MiruRyoikiState>();
final GlobalKey<SeriesScreenState> seriesScreenKey = GlobalKey<SeriesScreenState>();
final GlobalKey<LibraryScreenState> libraryScreenKey = GlobalKey<LibraryScreenState>();
final GlobalKey<ReleaseCalendarScreenState> releaseCalendarScreenKey = GlobalKey<ReleaseCalendarScreenState>();
final GlobalKey<DownloadsScreenState> torrentScreenKey = GlobalKey<DownloadsScreenState>();
final GlobalKey<AccountsScreenState> accountsKey = GlobalKey<AccountsScreenState>();
final GlobalKey<SettingsScreenState> settingsScreenKey = GlobalKey<SettingsScreenState>();

final GlobalKey<State<StatefulWidget>> paletteOverlayKey = GlobalKey<State<StatefulWidget>>();

void main(List<String> args) async {
  // runZonedGuarded(
  //   () async {
  WidgetsFlutterBinding.ensureInitialized();

  Manager.parseArgs();

  // Ensures there's only one instance of the program
  _ensureSingleInstance();

  // Only run on Windows and MacOS
  if (!(Platform.isWindows || Platform.isMacOS)) throw UnimplementedError('This app is only supported on Windows (for now).');

  // Initializes the MiruRyoiki save directory
  await initializeMiruRyoikiSaveDirectory();

  // Initialize database
  final db = AppDatabase();

  // Initialize settings
  await _settings.init(db);

  // Initialize session-based error logging
  await initializeLoggingSession();

  Manager.init();

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

  TorrentManager.initialize();

  // Initialize image cache
  final imageCache = ImageCacheService();
  await imageCache.init();

  await initializeSVGs();

  // Pre-initialize the Thumbnail Manager isolate
  ThumbnailManager();

  final anilistProvider = AnilistProvider();
  HiddenSeriesService().setAnilistProvider(anilistProvider);

  // Run the app
  runApp(
    ReassembleListener(
      onReassemble: () {
        if (kDebugMode) {
          if (Manager.isHotRestart) {
            // Hot restart: skip scanning and keep monitoring processes, since the process monitor should survive hot reloads and we don't want to interrupt it
            if (!Manager.doSkipDebugHotRestartInitialization) {
              logInfo('Hot restart detected, skipping library scan and keeping process monitor running');
              Manager.skipScan = true;
              nextFrame(delay: 10000, () => Manager.skipScan = false);
            }
          } else {
            // Hot reload
          }
        }
      },
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: anilistProvider),
          ChangeNotifierProvider(create: (_) => Library(_settings, db), lazy: false),
          ChangeNotifierProxyProvider<Library, MediaPlayerMonitorService>(
            create: (context) => MediaPlayerMonitorService(_settings, context.read<Library>()),
            update: (context, library, previous) => previous ?? MediaPlayerMonitorService(_settings, library),
            lazy: false,
          ),
          ChangeNotifierProxyProvider<Library, LibraryScannerService>(
            create: (context) => LibraryScannerService(_settings)..update(context.read<Library>()),
            update: (context, library, previous) {
              final service = previous ?? LibraryScannerService(_settings);
              service.update(library);
              return service;
            },
            lazy: false,
          ),
          // Per-screen ViewModels
          ChangeNotifierProxyProvider2<Library, AnilistProvider, ReleaseCalendarViewModel>(
            create: (context) => ReleaseCalendarViewModel()..update(context.read<Library>(), context.read<AnilistProvider>()),
            update: (context, library, anilist, previous) {
              final vm = previous ?? ReleaseCalendarViewModel();
              vm.update(library, anilist);
              return vm;
            },
          ),
          ChangeNotifierProvider(create: (_) => ConnectivityService(), lazy: false),
          ChangeNotifierProvider.value(value: _appTheme),
          ChangeNotifierProvider.value(value: _settings),
          ChangeNotifierProvider.value(value: _navigationManager),
        ],
        child: const MyApp(),
      ),
    ),
  );
}
//     ,
//     (error, stackTrace) => logErr('Uncaught error in main isolate', error, stackTrace),
//   );
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    final shortcuts = Map.of(WidgetsApp.defaultShortcuts)..removeWhere((key, value) => key.triggers!.contains(LogicalKeyboardKey.escape)); // Remove default escape key behavior to prevent it from interfering with our custom dialog handling
    return ScaffoldMessenger(
      child: CustomKeyboardListener(
        child: FluentApp(
          shortcuts: shortcuts,
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

    return ValueListenableBuilder<bool>(
      valueListenable: Manager.renderingEnabled,
      builder: (context, enabled, child) => TickerMode(enabled: enabled, child: child!),
      child: FluentTheme(
        data: FluentTheme.of(ctx).copyWith(
          cursorOpacityAnimates: true,
          typography: scaleTypography(
            FluentTheme.of(ctx).typography,
            Manager.fontSizeMultiplier,
          ),
          buttonTheme: FluentTheme.of(ctx).buttonTheme.merge(
                ButtonThemeData(
                  defaultButtonStyle: ButtonStyle(
                    padding: ButtonState.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 8)),
                  ),
                  filledButtonStyle: ButtonStyle(
                    padding: ButtonState.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 8)),
                  ),
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
      onInitComplete: () => Future.delayed(splashScreenFadeAnimationIn, () => setState(() => _initialized = true)),
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
      duration: getAnimationDuration(const Duration(milliseconds: 500)),
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
  Widget build(BuildContext context) => MiruRyoiki(key: homeKey);
}

class MiruRyoiki extends StatefulWidget {
  const MiruRyoiki({super.key});

  @override
  State<MiruRyoiki> createState() => _MiruRyoikiState();
}

ValueNotifier<int?> previousGridColumnCount = ValueNotifier<int?>(null);

class _MiruRyoikiState extends State<MiruRyoiki> {
  // UI State
  int _selectedIndex = 0;

  bool _isCompactView = false;
  bool seriesWasModified = false;
  bool _isNavigationPaneCollapsed = false;

  final ScrollController libraryController = ScrollController();
  final ScrollController homeController = ScrollController();
  final ScrollController calendarController = ScrollController();
  final ScrollController searchController = ScrollController();
  final ScrollController torrentController = ScrollController();
  final ScrollController accountsController = ScrollController();
  final ScrollController settingsController = ScrollController();

  late final LibraryScreen _libraryScreen;

  DeferredPointerHandlerLink? deferredPointerLink;

  /// Stable key so the account avatar keeps its animation state across pane rebuilds.
  final GlobalKey _accountAvatarKey = GlobalKey();

  /// Whether we're currently viewing a series
  bool get isSeriesView {
    final navManager = Provider.of<NavigationManager>(context, listen: false);
    final id = navManager.currentView?.id;
    return navManager.hasPage && (id?.startsWith('/series:') == true || id?.startsWith('/mapping:') == true || (id?.startsWith('/searched_series:') == true));
  }

  /// Currently selected series path
  PathString? get selectedSeriesPath {
    if (!isSeriesView) return null;
    final navManager = Provider.of<NavigationManager>(context, listen: false);
    return navManager.currentView?.data as PathString?;
  }

  final GlobalKey<NavigationViewState> _paneKey = GlobalKey<NavigationViewState>();

  Widget anilistIcon(bool offline) {
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
      duration: dimDuration,
      turns: _selectedIndex == NavigationManager.SettingsIndex ? 0.5 : 0.0,
      child: const Icon(FluentIcons.settings, size: 18),
    );
  }

  // Reset scroll position to top
  void _resetScrollPosition(int index, {bool animate = false}) {
    final controller = NavigationManager.getScrollController(index);
    if (controller.hasClients) {
      if (animate)
        controller.animateTo(0.0, duration: dimDuration, curve: Curves.easeInOut);
      else
        controller.jumpTo(0.0);
    }
  }

  bool _isCurrentIdSelected(int index) => _selectedIndex == index;

  set setCompactView(bool value) => setState(() => _isCompactView = value);
  bool get isCompactView => _isCompactView;

  void openSettings() => onChangedPane(NavigationManager.SettingsIndex);

  void onChangedPane(int index) {
    final pane = NavigationManager.getPane(index);
    setState(() {
      _selectedIndex = index;
      _isCompactView = false;
      Manager.currentDominantColor = null;

      if (pane != null) context.read<NavigationManager>().pushPane(pane);
    });
  }

  @override
  void initState() {
    super.initState();
    NavigationManager.setScrollController(NavigationManager.HomeIndex, homeController);
    NavigationManager.setScrollController(NavigationManager.LibraryIndex, libraryController);
    NavigationManager.setScrollController(NavigationManager.CalendarIndex, calendarController);
    NavigationManager.setScrollController(NavigationManager.BrowseIndex, searchController);
    NavigationManager.setScrollController(NavigationManager.TorrentIndex, torrentController);
    NavigationManager.setScrollController(NavigationManager.AccountsIndex, accountsController);
    NavigationManager.setScrollController(NavigationManager.SettingsIndex, settingsController);
    _libraryScreen = LibraryScreen(
      key: libraryScreenKey,
      onSeriesSelected: navigateToSeries,
      scrollController: NavigationManager.getScrollController(NavigationManager.LibraryIndex),
    );

    deferredPointerLink = DeferredPointerHandlerLink();

    NavigationManager.instance.addListener(_onNavigationChanged);

    nextFrame(() async => context.read<NavigationManager>().pushPane(NavigationManager.HomePane));
  }

  @override
  void dispose() {
    NavigationManager.instance.removeListener(_onNavigationChanged);
    final navManager = Provider.of<NavigationManager>(context, listen: false);
    navManager.dispose();
    deferredPointerLink?.dispose();
    super.dispose();
  }

  void _onNavigationChanged() {
    final current = NavigationManager.instance.currentView;
    if (current == null) return;

    // Handle Pane Selection
    if (current.level == NavigationLevel.pane) {
      final paneData = NavigationManager.getPaneById(current.id);
      if (paneData != null) {
        // Find index
        int index = NavigationManager.getIndexById(current.id) ?? -1;
        if (index != -1 && _selectedIndex != index) {
          setState(() {
            _selectedIndex = index;
          });
        }
      }
    }

    // Handle Compact View & Colors
    final shouldBeCompact = NavigationManager.instance.isTherePage;
    if (_isCompactView != shouldBeCompact) setState(() => _isCompactView = shouldBeCompact);

    if (current.id.startsWith('/series:')) {
      // Entering Series View
      if (previousGridColumnCount.value == null) //
        previousGridColumnCount.value = ScreenUtils.crossAxisCount(ScreenUtils.libraryContentWidthWithoutPadding);

      final path = current.data as PathString?;
      if (path != null) {
        // Load color asynchronously
        Provider.of<Library>(context, listen: false) //
            .getSeriesByPath(path) //
            ?.effectivePrimaryColor() //
            .then(
          (color) {
            if (mounted && color != null) {
              Manager.setState(() {
                Manager.currentDominantColor = color;
                Manager.seriesDominantColor = color;
              });
            }
          },
        );
      }
    } else if (current.level == NavigationLevel.pane) {
      // Exiting to Pane
      if (previousGridColumnCount.value != null) previousGridColumnCount.value = null;

      if (Manager.currentDominantColor != null) {
        Manager.setState(() {
          Manager.currentDominantColor = null;
          Manager.seriesDominantColor = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);

    return AnimatedContainer(
      duration: dimDuration,
      color: getDimmableBlack(context),
      child: FrostedNoise(
        intensity: 0.25,
        child: Stack(
          children: [
            // Actual Window Content
            Positioned.fill(
              child: AnimatedPadding(
                duration: shortDuration,
                padding: EdgeInsets.only(
                  top: ScreenUtils.kTitleBarHeight,
                  bottom: 0,
                ),
                child: AnimatedContainer(
                  duration: dimDuration,
                  color: getDimmableBlack(context),
                  child: DeferredPointerHandler(
                    key: ValueKey('root'),
                    link: deferredPointerLink,
                    child: NavigationView(
                      onDisplayModeChanged: (value) => nextFrame(() => setState(() {
                            _isNavigationPaneCollapsed = _paneKey.currentState?.displayMode == PaneDisplayMode.compact;
                          })),
                      key: _paneKey,
                      paneBodyBuilder: (item, _) {
                        return Column(
                          children: [
                            // Page Content
                            Expanded(
                              child: Navigator(
                                key: navigatorKey,
                                initialRoute: '/',
                                onGenerateRoute: _onGenerateRoute,
                              ),
                            ),
                            // Status Bar
                            StatusBar()
                          ],
                        );
                      },
                      pane: NavigationPane(
                        menuButton: _isCompactView ? const SizedBox.shrink() : null,
                        selected: _selectedIndex,
                        onItemPressed: (index) {
                          previousGridColumnCount.value = null;

                          if (isSeriesView) {
                            // If in series view, reset to pane first
                            context.read<NavigationManager>().resetCurrentPane();
                          }

                          if (_selectedIndex == index) {
                            // If clicking the same tab, reset its scroll position
                            _resetScrollPosition(index, animate: true);
                            // releaseCalendarScreenKey.currentState?.toggleFilter(false);
                            releaseCalendarScreenKey.currentState?.focusToday();
                          }
                        },
                        onChanged: onChangedPane,
                        displayMode: _isCompactView ? PaneDisplayMode.compact : PaneDisplayMode.auto,
                        indicator: AnimatedNavigationIndicator(
                          targetColor: Manager.currentDominantColor ?? Manager.accentColor,
                          indicatorBuilder: (color) => StickyNavigationIndicator(color: color),
                        ),
                        items: [
                          buildPaneItem(
                            NavigationManager.HomeIndex,
                            mouseCursorClick: !_isCurrentIdSelected(NavigationManager.HomeIndex),
                            icon: movedPaneItemIcon(const Icon(FluentIcons.home)),
                          ),
                          buildPaneItem(
                            NavigationManager.LibraryIndex,
                            mouseCursorClick: !_isCurrentIdSelected(NavigationManager.LibraryIndex), // || _isSeriesView,
                            icon: movedPaneItemIcon(const Icon(Symbols.newsstand)),
                          ),
                          buildPaneItem(
                            NavigationManager.CalendarIndex,
                            mouseCursorClick: !_isCurrentIdSelected(NavigationManager.CalendarIndex),
                            icon: movedPaneItemIcon(const Icon(FluentIcons.calendar)),
                          ),
                          buildPaneItem(
                            NavigationManager.BrowseIndex,
                            mouseCursorClick: !_isCurrentIdSelected(NavigationManager.BrowseIndex),
                            icon: movedPaneItemIcon(const Icon(FluentIcons.search)),
                          ),
                          buildPaneItem(
                            NavigationManager.TorrentIndex,
                            mouseCursorClick: !_isCurrentIdSelected(NavigationManager.TorrentIndex),
                            icon: movedPaneItemIcon(const Icon(FluentIcons.download)),
                          ),
                        ],
                        footerItems: [
                          PaneItemSeparator(),
                          buildPaneItem(
                            NavigationManager.AccountsIndex,
                            mouseCursorClick: !_isCurrentIdSelected(NavigationManager.AccountsIndex),
                            icon: anilistIcon(anilistProvider.isOffline),
                            extra: (isHovered) {
                              final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);
                              final user = anilistProvider.currentUser;

                              if (user == null || user.avatar == null) return null;

                              return AnimatedAccountAvatar(
                                key: _accountAvatarKey,
                                avatarUrl: user.avatar!,
                                isSelected: _isCurrentIdSelected(NavigationManager.AccountsIndex),
                                onTap: () => onChangedPane(NavigationManager.AccountsIndex),
                                link: deferredPointerLink,
                              );
                            },
                          ),
                          buildPaneItem(
                            NavigationManager.SettingsIndex,
                            mouseCursorClick: !_isCurrentIdSelected(NavigationManager.SettingsIndex),
                            icon: movedPaneItemIcon(const Icon(FluentIcons.settings)),
                          ),
                        ],
                      ),
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
                height: ScreenUtils.kTitleBarHeight,
                child: _buildTitleBar(),
              ),
            ),
            const StatusBarWidget(), // ep/series name, zoom, etc.
            Player(),
            SidebarOpenerDetector(
              onHover: () => setCompactView = false,
              onExit: () => setCompactView = true,
              enabled: isSeriesView,
              shouldExpand: !_isCompactView,
            )
          ],
        ),
      ),
    );
  }

  /// Generates routes for the inner Navigator
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final String routeName = settings.name ?? '/';

    log("route name: $routeName");

    // Determine which page to show
    Widget page;

    switch (routeName) {
      case '/${NavigationManager.HomeId}':
        page = HomeScreen(
          onSeriesSelected: navigateToSeries,
          scrollController: NavigationManager.getScrollController(NavigationManager.HomeIndex),
        );
      case '/${NavigationManager.LibraryId}':
        page = _libraryScreen;
      case '/series':
      case String() when routeName.startsWith('/series:'):
        // Series view with custom transition
        final seriesPath = settings.arguments as PathString?;
        page = SeriesScreen(
          key: seriesScreenKey,
          seriesPath: seriesPath,
          onBack: () => context.read<NavigationManager>().goBack(),
        );
      case String() when routeName.startsWith('/mapping:'):
        // A folder node (sub-folder) of a series, opened as its own page. Each
        // nesting level pushes a distinct route, so this uses a per-path ValueKey
        // rather than a single shared GlobalKey (which can't back a deep stack).
        final args = settings.arguments as Map<String, dynamic>;
        final seriesPath = args['seriesPath'] as PathString?;
        final nodePath = args['nodePath'] as PathString?;

        if (seriesPath == null || nodePath == null) {
          logWarn('Failed to open folder view: seriesPath - $seriesPath | nodePath - $nodePath');
          // Bad/missing arguments — fall back to Home instead of a dead folder screen
          page = HomeScreen(
            onSeriesSelected: navigateToSeries,
            scrollController: NavigationManager.getScrollController(NavigationManager.HomeIndex),
          );
        } else {
          page = SeriesScreen(
            key: ValueKey('/node:$nodePath'),
            seriesPath: seriesPath,
            onBack: () => context.read<NavigationManager>().goBack(),
            nodePath: nodePath,
          );
        }
      case '/${NavigationManager.CalendarId}':
        page = ReleaseCalendarScreen(
          key: releaseCalendarScreenKey,
          onSeriesSelected: navigateToSeries,
          scrollController: NavigationManager.getScrollController(NavigationManager.CalendarIndex),
        );
      case '/${NavigationManager.BrowseId}':
        page = BrowseScreen(
          scrollController: NavigationManager.getScrollController(NavigationManager.BrowseIndex),
        );
      case '/${NavigationManager.TorrentId}':
        page = DownloadsScreen(
          key: torrentScreenKey,
          controller: TorrentManager.downloadController,
          sonarrRepo: TorrentManager.sonarrRepository,
          scrollController: NavigationManager.getScrollController(NavigationManager.TorrentIndex),
        );
      case '/${NavigationManager.AccountsId}':
        page = AccountsScreen(
          key: accountsKey,
          scrollController: NavigationManager.getScrollController(NavigationManager.AccountsIndex),
        );
      case '/${NavigationManager.SettingsId}':
        page = SettingsScreen(
          key: settingsScreenKey,
          scrollController: NavigationManager.getScrollController(NavigationManager.SettingsIndex),
        );
      case String() when routeName.startsWith('/searched_series:'):
        page = SearchedSeriesScreen(
          anilistUrl: "https://anilist.co/anime/${(settings.arguments as AnimeCard).id}",
          onBack: () => context.read<NavigationManager>().goBack(),
        );
      default:
        // Default to home
        page = HomeScreen(
          onSeriesSelected: navigateToSeries,
          scrollController: NavigationManager.getScrollController(NavigationManager.HomeIndex),
        );
    }

    // Use custom page route with fade transition for series view
    if (routeName.startsWith('/series:') || routeName.startsWith('/mapping:') || routeName.startsWith('/searched_series:')) {
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) => fadeTransitionsBuilder(context, animation, secondaryAnimation, child),
        transitionDuration: mediumDuration,
        reverseTransitionDuration: mediumDuration,
        maintainState: true,
      );
    }

    // based on previous index and current index, detect if we went upwards or downwards in the panes indexes
    final previous = NavigationManager.instance.previousView;
    final previousIndex = previous != null ? NavigationManager.getIndexById(previous.id) ?? 0 : 0;

    final current = NavigationManager.instance.currentView;
    final currentIndex = current != null ? NavigationManager.getIndexById(current.id) ?? 0 : 0;
    final direction = currentIndex - previousIndex;

    // Standard route for other pages
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Custom fade transition
        return switch (Manager.settings.pageTransitionMode) {
          PageTransitionMode.none => noneTransitionsBuilder(context, animation, secondaryAnimation, child),
          PageTransitionMode.fade => fadeTransitionsBuilder(context, animation, secondaryAnimation, child),
          PageTransitionMode.slide => slideTransitionsBuilder(context, animation, secondaryAnimation, child, direction),
        };
      },
      transitionDuration: Manager.settings.pageTransitionMode == PageTransitionMode.none ? Duration.zero : mediumDuration,
      reverseTransitionDuration: Manager.settings.pageTransitionMode == PageTransitionMode.none ? Duration.zero : mediumDuration,
      maintainState: true,
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
    bool? mouseCursorClick,
    Widget? Function(bool isHovered)? extra,
  }) {
    final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);
    final item = NavigationManager.getPane(id)!;
    final title = item.title;
    mouseCursorClick ??= _selectedIndex != id;

    if (id == NavigationManager.AccountsIndex && anilistProvider.isOffline) {
      final msg = 'You are Offline';
      icon = Tooltip(
        style: TooltipThemeData(waitDuration: Duration(milliseconds: 200)),
        message: msg,
        child: icon,
      );
    }

    final bool isEnabled = !((id == NavigationManager.CalendarIndex || id == NavigationManager.BrowseIndex || id == NavigationManager.TorrentIndex) && !anilistProvider.isLoggedIn);

    return PaneItem(
      enabled: isEnabled,
      key: ValueKey("pane_item_$id"),
      mouseCursor: mouseCursorClick && isEnabled ? SystemMouseCursors.click : MouseCursor.defer,
      title: Text("  $title", style: Manager.bodyStyle.copyWith(color: Colors.white.withOpacity(isEnabled ? 1 : .5))),
      icon: icon,
      infoBadge: !anilistProvider.isLoggedIn && id == NavigationManager.AccountsIndex
          ? InfoBadge(
              // source: Icon(Icons.priority_high, size: 20),
              foregroundColor: Colors.white,
              color: Manager.accentColor.lighter,
            )
          : null,
      body: const SizedBox.shrink(),
      trailing: SizedBox(
        height: ScreenUtils.kDefaultPaneTileHeight,
        child: extra?.call(true),
      ),
    );
  }

  /// Custom title bar with menu bar and window buttons
  Widget _buildTitleBar({bool isSecondary = false}) {
    double winButtonsWidth = 128;
    return ValueListenableBuilder<bool>(
        valueListenable: NavigationManager.instance.stackNotifier,
        builder: (context, _, __) {
          final titleBarBGColor = (NavigationManager.instance.darkenTitleBar ? getBarrierColor(Manager.currentDominantColor).withOpacity(.25) : Colors.transparent);
          return AnimatedContainer(
            duration: dimDuration,
            color: titleBarBGColor,
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
                                  File(iconPath32),
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
                        offset: const Offset(7, 2),
                        child: SizedBox(
                          width: winButtonsWidth + 71 + 13,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Flexible(
                                child: Text(
                                  Manager.appTitle,
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w300,
                                    color: FluentTheme.of(context).typography.body!.color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Transform.translate(
                                offset: const Offset(0, 1),
                                child: Text(
                                  'Preview',
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: FluentTheme.of(context).inactiveColor.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Notification area, before window buttons
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ReleaseNotificationWidget(
                              onMorePressed: (ctx) async {
                                // Navigate to calendar screen
                                closeDialog();
                                if (_selectedIndex == NavigationManager.CalendarIndex) return;

                                await Future.delayed(const Duration(milliseconds: 100));
                                setState(() {
                                  if (isSeriesView) context.read<NavigationManager>().resetCurrentPane();

                                  _selectedIndex = NavigationManager.CalendarIndex;
                                  Manager.currentDominantColor = null;

                                  context.read<NavigationManager>().pushPane(NavigationManager.CalendarPane);
                                });

                                // Refresh the release calendar after navigation
                                nextFrame(() => releaseCalendarScreenKey.currentState?.loadReleaseData());
                              },
                            ),
                          ),
                          SizedBox(
                            height: ScreenUtils.kTitleBarHeight,
                            child: WindowButtons(isSecondary: isSecondary),
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
    // First, ensure we're on the library pane if not already
    if (_selectedIndex != NavigationManager.LibraryIndex) {
      logTrace('Navigating to library pane before opening series view');
      // We just push the pane. The listener will handle the UI updates.
      context.read<NavigationManager>().pushPane(NavigationManager.LibraryPane);

      // Small delay to allow UI to update to library pane first
      await Future.delayed(const Duration(milliseconds: 50));
    }

    final series = Provider.of<Library>(context, listen: false).getSeriesByPath(seriesPath);
    final seriesName = series?.name ?? 'Series';

    // Update navigation stack with the series page
    context.read<NavigationManager>().pushPage('/series:$seriesPath', seriesName, data: seriesPath);
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
    final listener = MyWindowListener();
    windowManager.addListener(listener);
    trayManager.addListener(listener);
    await listener.initSystemTray();
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

void setIcon() async => await windowManager.setIcon(iconPath);

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

// TODO update notification icon badge when reading notifications from notification dialog
// TODO scanning library progress indicator in status bar in Browse page is bugged visually with background cards
// TODO add 'random entry' button to top right corner of library
// TODO add 'play episode' button on continue watching series card -> click on card simply opens series
// TODO cache images smaller to be displayed without using too much memory
// TODO create widget for Smooth scrolling scroll controllers
// TODO create superclass for series type cards (continue watching, library series, search results, etc.) to share code between them and avoid duplication
// TODO add 'notify me' button to upcoming episodes on home screen
// TODO change text 'wait while library is getting indexed' to 'scanning' when library scan is in progress
// TODO move hidden series switches to settings
// TODO check that saved window position is within screen bounds
// TODO fix seriescards use dominant color for text regardless of setting
// TODO 'no episodes found for this season' should be 'no episodes found for this series' when there are no episodes in any season
// TODO when view is linkedOnly, hideFromUserList series automatically get added to Watching -> add category for them
// TODO released section in homepage to show released but not yet downloaded
// TODO view settings to choose what to show on homepage
// TODO fix settings players order not actually changing + add cursor to reordering handles
// TODO add dialog after clicking random entry to choose between confirm or pick another random entry
// TODO intercept esc key when focused on rename file in file explorer to unfocus instead of closing the dialog
// TODO disable 'Add to Anilist'/'Add to Library' button until fetch is complete
// TODO fix back mouse button not working on multi-state dialogs

// TODO cache Anilist lists to be able to work offline

// beta
// TODO add 'see log' dialog with timestamps and episode names, and ability to export it to a file

// TODO add marquee to notification titles
// TODO add 'state' and 'stateString' to MediaStatus
// TODO remove hardcoded filtering for only the local series for scheduled releases notifications as we'll have the ability to download them
// TODO add ctrl + tab navigation
// TODO Local 'Unlinked' auto connect to Anilist 'About to Watch' (allow custom name to search for)
// TODO add group traversal policies to app
// TODO detect custom players
// TODO create autolinker
// TODO change FORMATTER format for specials (allow specials inside season, OVA/ONAs in separate folder if not alone)

// would be nice
// TODO 'video player process monitoring failed to start' because already open, after a hot restart -> detect with ReassembleListener
// TODO show 'downloading' status on UIEpisode cards when episode is being downloaded by qbittorrent
