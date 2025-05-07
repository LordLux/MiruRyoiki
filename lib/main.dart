// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Icons, Material, MaterialPageRoute, ScaffoldMessenger;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluent_ui3/fluent_ui.dart' as fluent_ui3;
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_acrylic/window.dart' as flutter_acrylic;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:miruryoiki/dialogs/link_anilist.dart';
import 'package:miruryoiki/services/navigation/dialogs.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
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
import 'services/anilist/auth.dart';
import 'services/anilist/provider.dart';
import 'services/file_writer.dart';
import 'services/navigation/debug.dart';
import 'services/navigation/navigation.dart';
import 'services/registry.dart' as registry;
import 'services/navigation/shortcuts.dart';
import 'services/navigation/show_info.dart';
import 'theme.dart';
import 'utils/color_utils.dart';
import 'widgets/reverse_animation_flyout.dart' show ToggleableFlyoutContent, ToggleableFlyoutContentState;
import 'widgets/simple_flyout.dart' hide ToggleableFlyoutContent;
import 'widgets/window_buttons.dart';

final _appTheme = AppTheme();
final _navigationManager = NavigationManager();

// ignore: library_private_types_in_public_api
final GlobalKey<_AppRootState> homeKey = GlobalKey<_AppRootState>();
final GlobalKey<SeriesScreenState> seriesScreenKey = GlobalKey<SeriesScreenState>();
final GlobalKey<AccountsScreenState> accountsKey = GlobalKey<AccountsScreenState>();

final GlobalKey<State<StatefulWidget>> paletteOverlayKey = GlobalKey<State<StatefulWidget>>();
final GlobalKey<ToggleableFlyoutContentState> reverseAnimationPaletteKey = GlobalKey<ToggleableFlyoutContentState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Platform.isWindows) throw UnimplementedError('This app is only supported on Windows (for now).');

  // Load .env file
  await dotenv.load(fileName: '.env');

  await registry.register(mRyoikiAnilistScheme);

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
        ChangeNotifierProvider.value(value: _navigationManager),
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
  // Create an instance of AppLinks
  late final AppLinks _appLinks;
  bool _initialUriHandled = false;

  @override
  void initState() {
    super.initState();
    // Initialize providers
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Initialize AppLinks
      _appLinks = AppLinks();

      // Handle initial deep link (if app was started from a link)
      _handleInitialUri();

      // Listen for deep links while app is running
      _handleIncomingLinks();

      // Assign settings loaded from cache
      SettingsManager.assignSettings(context);

      // Providers initialization
      final libraryProvider = Provider.of<Library>(context, listen: false);
      final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);

      await libraryProvider.scanLibrary();
      await anilistProvider.initialize();

      await Future.delayed(const Duration(milliseconds: kDebugMode ? 52 : 252));
      final appTheme = Provider.of<AppTheme>(context, listen: false);
      appTheme.setEffect(appTheme.windowEffect, rootNavigatorKey.currentContext!);
    });
  }

  Future<void> _handleInitialUri() async {
    if (!_initialUriHandled) {
      _initialUriHandled = true;
      try {
        // Get the initial uri that opened the app
        final initialUri = await _appLinks.getInitialLink();
        if (initialUri != null) {
          _handleDeepLink(initialUri);
        }
      } catch (e) {
        debugPrint('Error handling initial uri: $e');
      }
    }
  }

  void _handleIncomingLinks() {
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    }, onError: (err) {
      debugPrint('Error handling incoming links: $err');
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
                    padding: ButtonState.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 8)),
                  ),
                  filledButtonStyle: ButtonStyle(
                    padding: ButtonState.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 8)),
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

  final SimpleFlyoutController flyoutController = SimpleFlyoutController();

  void showDialog() {
    Manager.flyout?.showFlyout(
      barrierColor: Colors.black.withOpacity(0.125),
      barrierDismissible: true,
      dismissWithEsc: true,
      barrierBlocking: false,
      barrierMargin: EdgeInsets.only(top: Manager.titleBarHeight),
      dismissOnPointerMoveAway: false,
      closingDuration: Duration(milliseconds: 150),
      transitionDuration: Duration(milliseconds: 100),
      onBarrierDismiss: () => Manager.closeFlyout(true),
      margin: 0,
      // position: Offset(MediaQuery.of(context).size.width / 2 - flyoutWidth / 2 + 3.5, 4),
      builder: (context) {
        return SizedBox.expand(
          child: StatefulBuilder(
              key: paletteOverlayKey,
              builder: (context, setState) {
                return ToggleableFlyoutContent(
                  key: reverseAnimationPaletteKey,
                  duration: const Duration(milliseconds: 100),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [],
                  ),
                );
              }),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navManager = Provider.of<NavigationManager>(context, listen: false);
      navManager.pushPane('library', 'Library');
    });
  }

  @override
  void dispose() {
    flyoutController.dispose();
    final navManager = Provider.of<NavigationManager>(context, listen: false);
    navManager.dispose();
    super.dispose();
  }

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
                child: SimpleFlyoutTarget(
                  controller: flyoutController,
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

                        // Register in navigation stack - add this code
                        final navManager = Provider.of<NavigationManager>(context, listen: false);

                        // Clear everything before adding a new pane
                        navManager.clearStack();

                        // Register the selected pane
                        switch (index) {
                          case 0:
                            navManager.pushPane('library', 'Library');
                            break;
                          case 1: // Assuming this is Account
                            navManager.pushPane('accounts', 'Account');
                            break;
                          case 2: // Assuming this is Settings
                            navManager.pushPane('settings', 'Settings');
                            break;
                          default:
                            navManager.pushPane('unknown', 'Unknown Pane');
                        }
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
                        // if (Manager.accounts.length <= 1)
                        PaneItem(
                          icon: SizedBox(
                              height: 25,
                              width: 18,
                              child: Transform.translate(
                                offset: const Offset(1.5, 0),
                                child: Transform.scale(scale: 1.45, child: AnilistLogo()),
                              )),
                          title: const Text('Account'),
                          body: AccountsScreen(key: accountsKey),
                        ),
                        // if (Manager.accounts.length >= 2)
                        //   PaneItemExpander(
                        //     icon: Padding(
                        //       padding: const EdgeInsets.only(left: 2.5),
                        //       child: Icon(FluentIcons.people),
                        //     ),
                        //     title: const Text('Account'),
                        //     body: const AccountsScreen(),
                        //     items: [
                        //       if (Manager.accounts.contains('Anilist'))
                        //         PaneItem(
                        //           icon: Padding(padding: const EdgeInsets.only(left: 2.5), child: AnilistLogo()),
                        //           title: Text('Anilist'),
                        //           body: const Anilist(),
                        //         ),
                        //     ],
                        //   ),
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
                  width: winButtonsWidth + 71 + 13,
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
                          text: const Text('Debug History'),
                          onPressed: () {
                            showDebugDialog(context);
                          },
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

  // Update navigateToSeries method:
  void navigateToSeries(String seriesPath) {
    final series = Provider.of<Library>(context, listen: false).getSeriesByPath(seriesPath);
    final seriesName = series?.name ?? 'Series';

    // Update navigation stack
    Provider.of<NavigationManager>(context, listen: false).pushPage('series:$seriesPath', seriesName, data: seriesPath);

    setState(() {
      _selectedSeriesPath = seriesPath;
      _isSeriesView = true;
    });
  }

  // Update exitSeriesView method:
  void exitSeriesView() {
    final navManager = Provider.of<NavigationManager>(context, listen: false);

    if (navManager.currentView?.level == NavigationLevel.page) {
      navManager.goBack();
    }

    setState(() {
      lastSelectedSeriesPath = _selectedSeriesPath ?? lastSelectedSeriesPath;
      _selectedSeriesPath = null;
      _isSeriesView = false;
    });
  }

  // Add this helper method
  bool handleBackNavigation() {
    final navManager = Provider.of<NavigationManager>(context, listen: false);

    if (navManager.hasDialog) {
      // Find active dialogs and close them
      // This assumes dialogs are managed through Flutter's dialog system
      // and will be removed from stack using the showManagedDialog helper
      // closeDialog(context);
      return true;
    } else if (_isSeriesView) {
      exitSeriesView();
      return true;
    } else if (navManager.canGoBack) {
      final previousItem = navManager.goBack();

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
              _selectedSeriesPath = currentItem.data as String;
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
    switch (id) {
      case 'library':
        return 0;
      case 'accounts':
        return 1;
      case 'settings':
        return 2;
      default:
        return null;
    }
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
