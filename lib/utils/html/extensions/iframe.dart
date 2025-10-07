import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:webview_windows/webview_windows.dart';
import 'dart:async';

import '../../logging.dart';
import '../html_utils.dart';

class WindowsIframeHtmlExtension extends HtmlExtension {
  const WindowsIframeHtmlExtension();

  @override
  Set<String> get supportedTags => {"iframe"};

  @override
  InlineSpan build(ExtensionContext context) {
    // Extract src attribute from the iframe
    final src = context.attributes['src'];

    if (src == null) return TextSpan(text: "[iframe missing src]");

    // Get width and height attributes with defaults
    final width = double.tryParse(context.attributes['width'] ?? '') ?? 300.0;
    final height = double.tryParse(context.attributes['height'] ?? '') ?? 150.0;

    // Use a unique key based on the URL to maintain widget identity
    final key = ValueKey(src);

    return WidgetSpan(
      child: WindowsIframeWidget(
        key: key,
        src: src,
        width: width,
        height: height,
      ),
    );
  }
}

class WindowsIframeWidget extends StatefulWidget {
  final String src;
  final double width;
  final double height;

  const WindowsIframeWidget({
    super.key,
    required this.src,
    required this.width,
    required this.height,
  });

  @override
  State<WindowsIframeWidget> createState() => _WindowsIframeWidgetState();
}

class _WindowsIframeWidgetState extends State<WindowsIframeWidget> with AutomaticKeepAliveClientMixin {
  late WebviewController _controller;
  bool _isWebViewReady = false;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewControllerCache().getController(widget.src);
    _initWebView();
  }

  Future<void> _initWebView() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _isWebViewReady = false;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      // Add a timeout to prevent hanging indefinitely
      final cache = WebViewControllerCache();

      await cache.ensureInitialized(widget.src, _controller).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('WebView initialization timed out');
      });

      // logTrace('WebView initialized for ${widget.src}');

      // Load URL after initialization
      try {
        await _controller.loadUrl(widget.src).timeout(const Duration(seconds: 10), onTimeout: () {
          throw TimeoutException('URL loading timed out');
        });
        // logTrace('URL loaded successfully: ${widget.src}');
      } catch (urlError) {
        logErr('Error loading URL ${widget.src}', urlError);
        // Still mark as ready but with an error state
        if (mounted) {
          setState(() {
            _isWebViewReady = true; // We'll show the webview even if URL failed
            _isLoading = false;
            _hasError = true;
            _errorMessage = 'Failed to load content: $urlError';
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _isWebViewReady = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      logErr('Error initializing WebView for ${widget.src}', e);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to initialize: $e';
        });
      }
    }
  }

  @override
  void didUpdateWidget(WindowsIframeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only reload if the source URL changed
    if (oldWidget.src != widget.src) {
      _controller = WebViewControllerCache().getController(widget.src);
      _initWebView();
    }
  }

  // Don't dispose the controller here - it's managed by the cache

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return RepaintBoundary(
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          children: [
            if (_isWebViewReady)
              Webview(
                _controller,
                width: widget.width,
                height: widget.height,
              ),
            if (_isLoading)
              Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: ProgressRing(
                    strokeWidth: 2,
                  ),
                ),
              ),
            if (_hasError)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FluentIcons.error, color: Colors.warningPrimaryColor),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load iframe content:\n$_errorMessage',
                        style: FluentTheme.of(context).typography.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
