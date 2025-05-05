// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Icons, MaterialPageRoute, ScaffoldMessenger;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_acrylic/window.dart' as flutter_acrylic;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import 'package:system_theme/system_theme.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:window_manager/window_manager.dart';

import 'manager.dart';
import 'models/library.dart';
import 'screens/accounts.dart';
import 'screens/home.dart';
import 'screens/series.dart';
import 'screens/settings.dart';
import 'services/anilist/provider.dart';
import 'services/file_writer.dart';
import 'services/shortcuts.dart';
import 'services/show_info.dart';
import 'theme.dart';
import 'utils/color_utils.dart';
import 'widgets/window_buttons.dart';

bool _initialUriHandled = false;
final _appTheme = AppTheme();

// ignore: library_private_types_in_public_api
GlobalKey<_AppRootState> homeKey = GlobalKey<_AppRootState>();
final GlobalKey<SeriesScreenState> seriesScreenKey = GlobalKey<SeriesScreenState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Platform.isWindows) throw UnimplementedError('This app is only supported on Windows (for now).');

  // Load .env file
  await dotenv.load(fileName: '.env');

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) SystemTheme.accentColor.load();

  _initializeWindowManager();

  SettingsManager.settings = await SettingsManager.loadSettings();

  print(getRfeHash(r"M:\Videos\Series\Your Lie in April\21 - Snow.mkv"));

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
      SettingsManager.assignSettings(context);

      final libraryProvider = Provider.of<Library>(context, listen: false);
      final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);

      // Handle initial deep link (if app was started from a link)
      // TODO _handleInitialUri();

      // Listen for deep links while app is running
      // TODO _handleIncomingLinks();

      await Future.delayed(const Duration(milliseconds: 100));

      await libraryProvider.scanLibrary();
      await anilistProvider.initialize();

      await Future.delayed(const Duration(milliseconds: 2));
      final appTheme = Provider.of<AppTheme>(context, listen: false);
      appTheme.setEffect(appTheme.windowEffect, rootNavigatorKey.currentContext!);
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
          title: Manager.appTitle,
          theme: FluentThemeData(
            accentColor: appTheme.color,
            brightness: Brightness.light,
            cardColor: Colors.white.withOpacity(0.25),
            scaffoldBackgroundColor: Colors.white.withOpacity(0.25), // default background
            acrylicBackgroundColor: Colors.white,
          ),
          darkTheme: FluentThemeData(
            accentColor: appTheme.color,
            brightness: Brightness.dark,
            acrylicBackgroundColor: Colors.transparent,
            micaBackgroundColor: Colors.transparent,
            scaffoldBackgroundColor: getDimmableWhite(context), // default background
          ),
          color: appTheme.color,
          themeMode: appTheme.mode,
          home: AppRoot(key: homeKey),
          builder: (context, child) {
            return FluentTheme(
              data: FluentTheme.of(context).copyWith(
                buttonTheme: ButtonThemeData(
                  defaultButtonStyle: ButtonStyle(
                    padding: ButtonState.all(const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    )),
                  ),
                ),
              ),
              child: Navigator(
                onGenerateRoute: (_) => MaterialPageRoute(
                  builder: (context) => Overlay(
                    initialEntries: [
                      OverlayEntry(
                        builder: (context) => ValueListenableBuilder(
                          valueListenable: overlayEntry,
                          builder: (context, overlay, _) {
                            return Container(
                              color: Colors.black.withOpacity(0.5),
                              child: GestureDetector(
                                behavior: overlay != null ? HitTestBehavior.opaque : HitTestBehavior.translucent,
                                onTap: () {
                                  removeOverlay();
                                },
                                child: Directionality(
                                  textDirection: appTheme.textDirection,
                                  child: NavigationPaneTheme(
                                    data: NavigationPaneThemeData(
                                      backgroundColor: appTheme.windowEffect != WindowEffect.disabled ? Colors.transparent : null,
                                    ),
                                    child: child ?? const SizedBox.shrink(),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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

const Duration dimDuration = Duration(milliseconds: 200);

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
    return AnimatedContainer(
      duration: dimDuration,
      color: getDimmableBlack(context),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: Manager.titleBarHeight), // Adjust for title bar height
              child: AnimatedContainer(
                duration: dimDuration,
                color: getDimmableBlack(context),
                child: NavigationView(
                  key: _paneKey,
                  pane: NavigationPane(
                    menuButton: _isLibraryView
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 11.0),
                            child: _appTitle(),
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
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              child: const Icon(Icons.ondemand_video_outlined, size: 18),
                            ),
                            // divider, discarted
                            // Positioned(
                            //   left: -9,
                            //   bottom: 34,
                            //   child: Container(
                            //     width: 307,
                            //     height: 1,
                            //     decoration: BoxDecoration(
                            //       color: FluentTheme.of(context).resources.dividerStrokeColorDefault,
                            //       shape: BoxShape.rectangle,
                            //     ),
                            //   ),
                            // ),
                          ],
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
                        title: const Text('Account'),
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
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: Manager.titleBarHeight, // Adjust for title bar height
            child: _buildTitleBar(),
          ),
        ],
      ),
    );
  }

  /// Custom title bar with menu bar and window buttons
  Widget _buildTitleBar() {
    double winButtonsWidth = 128;
    return AnimatedContainer(
      duration: dimDuration,
      color: getDimmableBlack(context),
      height: Manager.titleBarHeight,
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
                          offset: const Offset(1, 2),
                          child: Image.file(
                            File(iconPath),
                            width: 19,
                            height: 19,
                            errorBuilder: (_, __, ___) => const Icon(Icons.icecream_outlined, size: 19),
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
                SizedBox(
                  width: winButtonsWidth + 71 + 10,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 35 + 10),
                    child: MenuBar(key: ValueKey('mainMenuBar'), items: [
                      MenuBarItem(title: 'File', items: [
                        MenuFlyoutItem(
                          text: const Text('New Window'),
                          onPressed: () {},
                        ),
                        MenuFlyoutItem(
                          text: const Text('Exit'),
                          leading: Icon(FluentIcons.calculator_multiply, color: Colors.red),
                          onPressed: null,
                          // onPressed: () => windowManager.close(),
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
                SizedBox(
                  height: Manager.titleBarHeight,
                  child: WindowButtons(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _appTitle() {
    return SizedBox(
      height: 24,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Transform.translate(
          offset: const Offset(-5, 0),
          child: Text(
            Manager.appTitle,
            overflow: TextOverflow.clip,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: GoogleFonts.sora(
              fontSize: 15,
              fontWeight: FontWeight.w300,
              color: FluentTheme.of(context).typography.body!.color,
            ),
          ),
        ),
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
  await flutter_acrylic.Window.hideWindowControls();
  await WindowManager.instance.ensureInitialized();

  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(1116.5, 700);
    win.minSize = Size(700, 400);
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = Manager.appTitle;
    win.show();
  });
  WindowOptions windowOptions = WindowOptions(
    size: const Size(1116.5, 700),
    minimumSize: const Size(700, 400),
    center: true,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: Manager.appTitle,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setPreventClose(false);
    await windowManager.setSkipTaskbar(false);
    await windowManager.setTitleBarStyle(
      TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );

    setIcon();
  });
}

void setIcon() async {
  if (await File(iconPath).exists()) {
    // await windowManager.setIcon(iconPath);
  } else {
    debugPrint('Icon file does not exist: $iconPath');
  }
}

// String get assets => "${(Platform.resolvedExecutable.split(ps)..removeLast()).join(ps)}$ps${kDebugMode ? 'assets' : 'data${ps}flutter_assets${ps}assets'}";
String get assets => "${(Platform.resolvedExecutable.split(ps)..removeLast()).join(ps)}${ps}data${ps}flutter_assets${ps}assets";
String get iconPath => '$assets${ps}system${ps}icon.ico';
String get iconPng => '$assets${ps}system${ps}icon.png';
String get ps => Platform.pathSeparator;

// TODO check if sidebar is autoclosed -> set menu icon to null
