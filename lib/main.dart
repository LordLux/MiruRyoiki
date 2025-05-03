import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show Icons, MaterialPageRoute, ScaffoldMessenger;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluent_ui3/fluent_ui.dart' as menu;
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

import 'functions.dart';
import 'manager.dart';
import 'models/library.dart';
import 'screens/accounts.dart';
import 'screens/home.dart';
import 'screens/series.dart';
import 'screens/settings.dart';
import 'services/anilist/provider.dart';
import 'services/shortcuts.dart';
import 'theme.dart';
import 'widgets/window_buttons.dart';

bool _initialUriHandled = false;
final _appTheme = AppTheme();

// ignore: library_private_types_in_public_api
GlobalKey<_AppRootState> homeKey = GlobalKey<_AppRootState>();
final GlobalKey<SeriesScreenState> seriesScreenKey = GlobalKey<SeriesScreenState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Platform.isWindows) throw UnimplementedError('This app is only supported on Windows.');

  // Load .env file
  await dotenv.load(fileName: '.env');

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) SystemTheme.accentColor.load();

  _initializeWindowManager();

  SettingsManager.settings = await SettingsManager.loadSettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Library()),
        ChangeNotifierProvider(create: (context) => AnilistProvider()),
        ChangeNotifierProvider.value(value: _appTheme),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize providers
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      flutter_acrylic.Window.setEffect(
        effect: flutter_acrylic.WindowEffect.acrylic,
        color: Colors.black.withValues(alpha: 0.05),
      );
      // FluentTheme.of(context).micaBackgroundColor.withValues(alpha: 0.05);

      final libraryProvider = Provider.of<Library>(context, listen: false);
      final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);

      // Handle initial deep link (if app was started from a link)
      // TODO _handleInitialUri();

      // Listen for deep links while app is running
      // TODO _handleIncomingLinks();

      await Future.delayed(const Duration(milliseconds: 100));

      await libraryProvider.scanLibrary();
      await anilistProvider.initialize();
    });
  }

  Future<void> _handleInitialUri() async {
    if (!_initialUriHandled) {
      _initialUriHandled = true;
      try {
        final initialUri = await getInitialUri();
        if (initialUri != null) {
          _handleDeepLink(initialUri);
        }
      } catch (e) {
        debugPrint('Error handling initial uri: $e');
      }
    }
  }

  void _handleIncomingLinks() {
    uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    }, onError: (err) {
      debugPrint('Error handling incoming links: $err');
    });
  }

  void _handleDeepLink(Uri uri) async {
    // Handle Anilist auth callback
    if (uri.toString().startsWith('miruryoiki://auth-callback')) {
      final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);
      await anilistProvider.handleAuthCallback(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    return CustomKeyboardListener(
      child: ScaffoldMessenger(
        child: FluentApp(
          title: 'MiruRyoiki',
          theme: FluentThemeData(
            accentColor: appTheme.color,
            brightness: Brightness.light,
            acrylicBackgroundColor: Colors.transparent,
            scaffoldBackgroundColor: Colors.transparent,
            micaBackgroundColor: Colors.transparent,
            navigationPaneTheme: NavigationPaneThemeData(backgroundColor: Colors.transparent),
          ),
          darkTheme: FluentThemeData(
            accentColor: appTheme.color,
            brightness: Brightness.dark,
            acrylicBackgroundColor: Colors.transparent,
            micaBackgroundColor: Colors.transparent,
            scaffoldBackgroundColor: Colors.white.withOpacity(0.03), // default background
            navigationPaneTheme: NavigationPaneThemeData(backgroundColor: Colors.transparent),
          ),
          color: Colors.transparent,
          themeMode: appTheme.mode,
          home: AppRoot(key: homeKey),
          builder: (context, child) {
            return Navigator(
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (context) => Overlay(
                  initialEntries: [
                    OverlayEntry(
                      builder: (context) => ValueListenableBuilder(
                          valueListenable: overlayEntry,
                          builder: (context, overlay, _) {
                            return Container(
                              color: Colors.black.withOpacity(.5),
                              child: GestureDetector(
                                behavior: overlay != null ? HitTestBehavior.opaque : HitTestBehavior.translucent,
                                onTap: () {
                                  removeOverlay();
                                },
                                child: Directionality(
                                  textDirection: appTheme.textDirection,
                                  child: NavigationPaneTheme(
                                    data: NavigationPaneThemeData(
                                      backgroundColor: appTheme.windowEffect != flutter_acrylic.WindowEffect.disabled ? Colors.transparent : null,
                                    ),
                                    child: child ?? const SizedBox.shrink(),
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
          },
          navigatorKey: rootNavigatorKey,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  int _selectedIndex = 0;
  String? _selectedSeriesPath;
  bool _isSeriesView = false;
  String? lastSelectedSeriesPath;

  bool get _isLibraryView => !(_isSeriesView && _selectedSeriesPath != null);
  bool get isSeriesView => _isSeriesView;

  final GlobalKey<NavigationViewState> _paneKey = GlobalKey<NavigationViewState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(top: Manager.titleBarHeight), // Adjust for title bar height
            child: NavigationView(
              // appBar: _isLibraryView ? NavigationAppBar(automaticallyImplyLeading: false, title: _logoTitle()) : null,
              key: _paneKey,
              pane: NavigationPane(
                menuButton: _isLibraryView
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 11.0),
                        child: _logoTitle(),
                      )
                    : null,
                selected: _selectedIndex,
                onChanged: (index) => setState(() {
                  _selectedIndex = index;
                  lastSelectedSeriesPath = _selectedSeriesPath;
                  _selectedSeriesPath = null;
                  _isSeriesView = false;
                }),
                displayMode: _isSeriesView ? PaneDisplayMode.compact : PaneDisplayMode.auto,
                items: [
                  PaneItem(
                    icon: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      child: const Icon(Icons.ondemand_video_outlined, size: 18),
                    ),
                    title: const Text('Library'),
                    body: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isSeriesView && _selectedSeriesPath != null
                          ? SeriesScreen(
                              key: seriesScreenKey,
                              seriesPath: _selectedSeriesPath!,
                              onBack: exitSeriesView,
                            )
                          : HomeScreen(
                              onSeriesSelected: navigateToSeries,
                            ),
                    ),
                  ),
                ],
                footerItems: [
                  PaneItemSeparator(),
                  PaneItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 2.5),
                      child: Icon(FluentIcons.people),
                    ),
                    title: const Text('Accounts'),
                    body: const AccountsScreen(),
                  ),
                  PaneItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 2.5),
                      child: const Icon(FluentIcons.settings),
                    ),
                    title: const Text('Settings'),
                    body: const SettingsScreen(),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: Manager.titleBarHeight, // Adjust for title bar height
          child: _buildTitleBar(),
        ),
      ],
    );
  }

  /// Custom title bar with menu bar and window buttons
  Widget _buildTitleBar() {
    double winButtonsWidth = 128;
    return DragToMoveArea(
      child: SizedBox(
        height: Manager.titleBarHeight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Menu bar
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 20,
                      child: Transform.translate(
                        offset: const Offset(0, -1),
                        child: Image.file(
                          File(iconPath),
                          width: 19,
                          height: 19,
                          errorBuilder: (_, __, ___) => const Icon(Icons.icecream_outlined, size: 19),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: winButtonsWidth + 37,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 1),
                      child: MenuBar(key: ValueKey('mainMenuBar'), items: [
                        MenuBarItem(title: 'File', items: [
                          MenuFlyoutItem(
                            text: const Text('New Window'),
                            onPressed: () {},
                          ),
                          MenuFlyoutItem(
                            text: const Text('Exit'),
                            leading: Icon(FluentIcons.calculator_multiply, color: Colors.red),
                            onPressed: () => windowManager.close(),
                          ),
                        ]),
                        MenuBarItem(title: 'View', items: [
                          MenuFlyoutItem(
                            text: const Text('New Window'),
                            onPressed: () {},
                          ),
                          MenuFlyoutItem(
                            text: const Text('Plain Text Documents'),
                            onPressed: () {},
                          ),
                        ]),
                        MenuBarItem(title: 'Help', items: [
                          MenuFlyoutItem(
                            text: const Text('Plain Text Documents'),
                            onPressed: () {},
                          ),
                        ]),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: Manager.titleBarHeight,
              child: WindowButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoTitle() {
    return SizedBox(
      width: 180, // Adjust this value as needed
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(FluentIcons.video, size: 24),
          const SizedBox(width: 8),
          const Text('MiruRyoiki', overflow: TextOverflow.clip, maxLines: 1),
        ],
      ),
    );
  }

  void navigateToSeries(String seriesPath) {
    setState(() {
      _selectedSeriesPath = seriesPath;
      _isSeriesView = true;
    });
  }

  void exitSeriesView() {
    setState(() {
      lastSelectedSeriesPath = _selectedSeriesPath ?? lastSelectedSeriesPath;
      _selectedSeriesPath = null;
      _isSeriesView = false;
    });
  }
}

Future<void> _initializeWindowManager() async {
  await flutter_acrylic.Window.initialize();
  await WindowManager.instance.ensureInitialized();
  if (Platform.isWindows) await flutter_acrylic.Window.hideWindowControls();
  WindowOptions windowOptions = WindowOptions(
    size: const Size(1116.5, 700),
    minimumSize: const Size(700, 400),
    center: true,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'MiruRyoiki',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setPreventClose(true);
    await windowManager.setSkipTaskbar(false);
    await windowManager.setTitleBarStyle(
      TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );

    if (await File(iconPath).exists())
      await windowManager.setIcon(iconPath);
    else
      debugPrint('Icon file does not exist: $iconPath');
  });
}

String get iconPath => '${(Platform.resolvedExecutable.split(Platform.pathSeparator)..removeLast()).join(Platform.pathSeparator)}data${ps}flutter_assets${ps}assets${ps}system${ps}icon.ico';
String get ps => Platform.pathSeparator;
