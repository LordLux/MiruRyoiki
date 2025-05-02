import 'package:flutter/material.dart' show Icons;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:io';

import 'models/library.dart';
import 'screens/accounts.dart';
import 'screens/home.dart';
import 'screens/series.dart';
import 'screens/settings.dart';
import 'services/anilist/provider.dart';

bool _initialUriHandled = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  await dotenv.load(fileName: '.env');

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('MiruRyoiki');
    setWindowMinSize(const Size(800, 600));
    setWindowMaxSize(Size.infinite);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Library()),
        ChangeNotifierProvider(create: (context) => AnilistProvider()),
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

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final libraryProvider = Provider.of<Library>(context, listen: false);
      final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);

      libraryProvider.scanLibrary();
      anilistProvider.initialize();

      // Handle initial deep link (if app was started from a link)
      _handleInitialUri();

      // Listen for deep links while app is running
      _handleIncomingLinks();
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
    return FluentApp(
      title: 'MiruRyoiki',
      theme: FluentThemeData(
        accentColor: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: FluentThemeData(
        accentColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const AppRoot(),
      debugShowCheckedModeBanner: false,
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

  bool get _isLibraryView => !(_isSeriesView && _selectedSeriesPath != null);

  final GlobalKey<NavigationViewState> _paneKey = GlobalKey<NavigationViewState>();

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: _isLibraryView ? NavigationAppBar(automaticallyImplyLeading: false, title: _logoTitle()) : null,
      key: _paneKey,
      pane: NavigationPane(
        selected: _selectedIndex,
        onChanged: (index) => setState(() {
          _selectedIndex = index;
          // Reset series view when changing navigation items
          _selectedSeriesPath = null;
          _isSeriesView = false;
        }),
        displayMode: _isSeriesView ? PaneDisplayMode.compact : PaneDisplayMode.auto,
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
                      key: ValueKey('series-$_selectedSeriesPath'),
                      seriesPath: _selectedSeriesPath!,
                      onBack: _exitSeriesView,
                    )
                  : HomeScreen(
                      key: const ValueKey('home'),
                      onSeriesSelected: _navigateToSeries,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoTitle() {
    return Row(
      children: [
        const Icon(FluentIcons.video, size: 24),
        const SizedBox(width: 8),
        const Text('MiruRyoiki'),
      ],
    );
  }

  void _navigateToSeries(String seriesPath) {
    setState(() {
      _selectedSeriesPath = seriesPath;
      _isSeriesView = true;
    });
  }

  void _exitSeriesView() {
    setState(() {
      _selectedSeriesPath = null;
      _isSeriesView = false;
    });
  }
}
