import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/utils/time_utils.dart';
import 'package:miruryoiki/widgets/dialogs/splash/progress.dart';

import '../../../manager.dart';

/// Defines the visual style of the status bar
class StatusBarStyle {
  final TextStyle? textStyle;
  final Color? mainColor;
  final BoxDecoration? container;
  final Color? acrylic_color;
  final Duration animationDuration;
  final Color? iconColor;
  final IconData? icon;

  const StatusBarStyle({
    this.textStyle,
    this.container,
    this.mainColor,
    this.animationDuration = Duration.zero,
    this.iconColor,
    this.icon,
    this.acrylic_color,
  });

  /// Creates a copy of this style with the given fields replaced
  StatusBarStyle copyWith({
    TextStyle? textStyle,
    BoxDecoration? container,
    Duration? animationDuration,
    Color? iconColor,
    Color? acrylic_color,
    IconData? icon,
    Color? mainColor,
  }) {
    return StatusBarStyle(
      textStyle: textStyle ?? this.textStyle,
      acrylic_color: acrylic_color ?? this.acrylic_color,
      container: container ?? this.container,
      animationDuration: animationDuration ?? this.animationDuration,
      iconColor: iconColor ?? this.iconColor,
      icon: icon ?? this.icon,
      mainColor: mainColor ?? this.mainColor,
    );
  }
}

/// Manages the global status bar
class StatusBarManager {
  // Singleton boilerplate
  static final StatusBarManager _instance = StatusBarManager._internal();
  factory StatusBarManager() => _instance;
  StatusBarManager._internal();

  /// Notifier that tells widgets whether to show/hide the bar
  final ValueNotifier<bool> _isShowingNotifier = ValueNotifier<bool>(false);

  /// Notifier that carries the current text message
  final ValueNotifier _messageNotifier = ValueNotifier('');

  /// Notifier that carries the current style
  final ValueNotifier<StatusBarStyle> _styleNotifier = ValueNotifier<StatusBarStyle>(
    StatusBarStyle(
      textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      container: BoxDecoration(
        color: const Color.fromARGB(255, 22, 22, 22).withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      mainColor: Manager.currentDominantColor,
      acrylic_color: Manager.accentColor.lightest,
    ),
  );

  /// Timer that automatically hides the bar after it appears
  Timer? _hideTimer;

  /// Timer that delays the initial show (i.e. “hover delay”)
  Timer? _delayTimer;

  /// If we just finished a delayed show, we open an “immediate window” so that subsequent calls to showDelayed come up instantly.
  Timer? _immediateWindowTimer;
  bool _isInImmediateWindow = false;

  /// Length of that “immediate window” after a delayed show completes
  static const Duration _defaultImmediateWindowDuration = Duration(milliseconds: 500);

  bool get isShowing => _isShowingNotifier.value;
  dynamic get message => _messageNotifier.value;
  StatusBarStyle get style => _styleNotifier.value;

  /// Expose the notifiers for widgets to listen to
  ValueNotifier<bool> get showingNotifier => _isShowingNotifier;
  ValueNotifier get messageNotifier => _messageNotifier;
  ValueNotifier<StatusBarStyle> get styleNotifier => _styleNotifier;

  /// Shows the status bar immediately, with given message/style.
  ///
  /// - If a bar is already visible and [replaceExisting] is false, do nothing.
  /// - Cancels any existing auto-hide timer and replaces it with a new one,
  ///   if [autoHideDuration] != Duration.zero.
  void show(
    dynamic message, {
    StatusBarStyle? style,
    Duration autoHideDuration = const Duration(seconds: 3),
    bool replaceExisting = true,
  }) {
    assert(message != null, 'Status bar message cannot be null');
    assert(message is String || message is Widget, 'Status bar message must be a String or Widget');

    // 1) Cancel any existing auto-hide timer
    _hideTimer?.cancel();
    _hideTimer = null;

    // 2) If we are already visible and do NOT want to replace, bail out
    if (isShowing && !replaceExisting) {
      return;
    }

    // 3) Update the message & style
    _messageNotifier.value = message;
    if (style != null) {
      _styleNotifier.value = style;
    }

    // 4) Make the bar visible if not already
    if (!isShowing) {
      _isShowingNotifier.value = true;
    }

    // 5) If an auto-hide duration was requested, schedule it
    if (autoHideDuration != Duration.zero) {
      _hideTimer = Timer(autoHideDuration, hide);
    }
  }

  /// Shows the status bar after a short [delay], unless hide() was called in the meantime.
  ///
  /// - If we're in the “immediate window,” show instantly by delegating to show(...)
  /// - Otherwise, schedule a [_delayTimer] that calls show(...) after [delay].
  /// - If hide() is called before [delay] expires, the delay is canceled.
  void showDelayed(
    dynamic message, {
    StatusBarStyle? style,
    Duration autoHideDuration = const Duration(seconds: 3),
    bool replaceExisting = true,
    Duration delay = const Duration(milliseconds: 500),
  }) {
    assert(message != null, 'Status bar message cannot be null');
    assert(message is String || message is Widget, 'Status bar message must be a String or Widget');

    // Cancel any existing timers
    _hideTimer?.cancel();
    _hideTimer = null;
    _delayTimer?.cancel();
    _delayTimer = null;

    // If already showing & we don't want to replace it, do nothing.
    if (isShowing && !replaceExisting) {
      return;
    }

    // If we're in the “immediate window,” bypass delay entirely:
    if (_isInImmediateWindow) {
      show(
        message,
        style: style,
        autoHideDuration: autoHideDuration,
        replaceExisting: replaceExisting,
      );
      return;
    }

    // Otherwise, schedule a new “delay timer” that calls show(...) after [delay].
    //
    //    Because hide() also cancels _delayTimer, if the user moves away
    //    before [delay] ends, the callback never runs.
    _delayTimer = Timer(delay, () {
      // When the delay completes, call show(...) and start an immediate window
      show(
        message,
        style: style,
        autoHideDuration: autoHideDuration,
        replaceExisting: replaceExisting,
      );

      // Now that the delayed show happened, open the immediate window
      _startImmediateWindow();
    });
  }

  /// Internal helper: once a “delayed show” finally appears, open a short window
  /// during which any further showDelayed(...) calls bypass the delay.
  void _startImmediateWindow() {
    _isInImmediateWindow = true;

    // Cancel any old immediate‐window timer, then schedule a new one
    _immediateWindowTimer?.cancel();
    _immediateWindowTimer = Timer(_defaultImmediateWindowDuration, () {
      _isInImmediateWindow = false;
    });
  }

  /// Updates only the style of the status bar (without changing the message or visibility)
  void updateStyle(StatusBarStyle style) {
    _styleNotifier.value = style;
  }

  /// Hides the status bar immediately and cancels any pending timers.
  ///
  /// This method should also trigger the start of an "immediate window."
  void hide() {
    // Cancel both the “auto-hide” and “delay” timers
    _hideTimer?.cancel();
    _hideTimer = null;
    _delayTimer?.cancel();
    _delayTimer = null;

    // Start the immediate window when hide() is called
    _startImmediateWindow();

    // Finally, flip the showing state to false
    _isShowingNotifier.value = false;
  }
}

/// Widget that actually displays the status bar in the lower right corner
class StatusBarWidget extends StatelessWidget {
  const StatusBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBarManager = StatusBarManager();

    return ValueListenableBuilder<bool>(
      valueListenable: statusBarManager.showingNotifier,
      builder: (context, isShowing, _) {
        return Positioned(
          right: 8,
          bottom: LibraryScanProgressManager().isShowing ? 28 : 8,
          child: AnimatedOpacity(
            opacity: isShowing ? 1.0 : 0.0,
            duration: getDuration(const Duration(milliseconds: 200)),
            child: ValueListenableBuilder<StatusBarStyle>(
              valueListenable: statusBarManager.styleNotifier,
              builder: (context, style, _) {
                return AnimatedContainer(
                  decoration: style.container,
                  duration: style.animationDuration,
                  child: ValueListenableBuilder(
                    valueListenable: statusBarManager.messageNotifier,
                    builder: (context, message, _) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (style.icon != null) ...[
                              Icon(
                                style.icon,
                                size: 14,
                                color: style.iconColor ?? style.textStyle?.color,
                              ),
                              const SizedBox(width: 6),
                            ],
                            message is String
                                ? Text(
                                    message,
                                    style: style.textStyle,
                                  )
                                : message
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
