// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/main.dart';
import 'package:miruryoiki/manager.dart';
import 'package:miruryoiki/services/library/library_provider.dart';
import 'package:miruryoiki/settings.dart';
import 'package:miruryoiki/utils/logging.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';

import 'utils/path_utils.dart';

class EasySplashScreen extends StatefulWidget {
  /// Actual Content of the splash
  final Widget content;

  final Duration waitBeforeFutureNavigator;

  /// A function that returns a Future<Widget>
  /// When this future completes, it will navigate to the returned widget
  final Future<Widget> Function() futureNavigator;

  final Function? onNavigate;

  const EasySplashScreen({
    super.key,
    required this.futureNavigator,
    required this.content,
    this.waitBeforeFutureNavigator = const Duration(seconds: 0),
    this.onNavigate,
  });

  @override
  _EasySplashScreenState createState() => _EasySplashScreenState();
}

class _EasySplashScreenState extends State<EasySplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.waitBeforeFutureNavigator).then((_) {
      widget.futureNavigator().then((route) {
        if (mounted) {
          Navigator.of(context).pushReplacement(FluentPageRoute(builder: (context) => route));
          if (widget.onNavigate != null) widget.onNavigate!();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) => widget.content;
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _splashOpacityController;
  late Animation<double> _opacityAnimation;
  final Duration animationDuration = const Duration(milliseconds: 800);

  // AppLinks for deep linking
  late final AppLinks _appLinks;
  bool _initialUriHandled = false;

  @override
  void initState() {
    super.initState();

    _splashOpacityController = AnimationController(
      duration: animationDuration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_splashOpacityController);

    // Animate opacity out
    _splashOpacityController.forward();
  }

  Future<Widget> _initializeApp() async {
    try {
      // Initialize AppLinks
      _appLinks = AppLinks();

      // Handle initial deep link
      logTrace('Handling initial deep link');
      await _handleInitialUri();

      // Get providers
      final settings = Provider.of<SettingsManager>(context, listen: false);
      final libraryProvider = Provider.of<Library>(context, listen: false);

      // Initialize settings
      settings.applySettings(context);

      // Initialize library
      logTrace('Initializing library provider');
      await libraryProvider.initialize(context);
      //
    } catch (e, st) {
      logErr('Error during app initialization', e, st);
    }
    // Navigate to main app
    return AppRoot();
  }

  Future<void> _handleInitialUri() async {
    if (!_initialUriHandled) {
      _initialUriHandled = true;
      try {
        // Get the initial uri that opened the app
        final initialUri = await _appLinks.getInitialLink();
        if (initialUri != null) {
          // Store for later handling by main app
          Manager.initialDeepLink = initialUri;
        }
      } catch (e, st) {
        logErr('Error handling initial uri', e, st);
      }
    }
  }

  @override
  void dispose() {
    _splashOpacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EasySplashScreen(
      waitBeforeFutureNavigator: animationDuration,
      futureNavigator: _initializeApp,
      content: AnimatedBuilder(
        animation: _splashOpacityController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: FluentTheme.of(context).micaBackgroundColor,
            ),
            child: Opacity(
              opacity: 1 - _opacityAnimation.value,
              child: Center(
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: Image.file(
                    File(iconPath),
                    errorBuilder: (_, __, ___) => const Icon(FluentIcons.picture, size: 100),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
