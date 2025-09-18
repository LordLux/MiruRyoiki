import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:miruryoiki/utils/screen.dart';

import '../../../utils/time.dart';
import '../../../manager.dart';
import '../../../services/lock_manager.dart';

/// Manages the global status bar
class LibraryScanProgressManager {
  // Singleton boilerplate
  static final LibraryScanProgressManager _instance = LibraryScanProgressManager._internal();
  factory LibraryScanProgressManager() => _instance;
  LibraryScanProgressManager._internal();

  /// Minimum initial progress value to show the bar (to show the dot)
  static final double kMinInitialProgressValue = 0.015;

  /// Notifier that carries the current progress value (0.0 to 1.0)
  final ValueNotifier<double> _progress = ValueNotifier<double>(kMinInitialProgressValue);

  /// Notifier that tells widgets whether to show/hide the bar
  final ValueNotifier<bool> _isShowingNotifier = ValueNotifier<bool>(false);

  /// Notifier that carries the current style
  final ValueNotifier<Color> _styleNotifier = ValueNotifier<Color>(Manager.currentDominantColor ?? Colors.white);

  bool get isShowing => _isShowingNotifier.value;
  Color get style => _styleNotifier.value;
  double get progress => _progress.value;
  
  bool showInLibraryBottom = true;

  /// Expose the notifiers for widgets to listen to
  ValueNotifier<bool> get showingNotifier => _isShowingNotifier;
  ValueNotifier<Color> get styleNotifier => _styleNotifier;
  ValueNotifier<double> get progressNotifier => _progress;

  /// Resets the progress (without animation)
  void resetProgress() => _progress.value = kMinInitialProgressValue;

  /// Shows the status bar immediately, with given message/style.
  void show(
    double amount, {
    Color? style,
    bool replaceExisting = true,
  }) {
    assert(amount >= 0 && amount <= 1, 'Status bar progress must be between 0 and 1');

    _progress.value = amount;

    if (style != null) _styleNotifier.value = style;

    if (!isShowing) _isShowingNotifier.value = true;
  }

  /// Updates only the style of the status bar (without changing the message or visibility)
  void updateColor(Color color) => _styleNotifier.value = color;

  /// Hides the status bar immediately.
  void hide() => _isShowingNotifier.value = false;
}

/// Widget that displays the current status of active operations
class LibraryScanProgressIndicator extends StatelessWidget {
  final bool showText;

  const LibraryScanProgressIndicator({
    super.key,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final libraryScanProgressManager = LibraryScanProgressManager();
    final lockManager = LockManager();

    return ListenableBuilder(
      listenable: Listenable.merge([
        libraryScanProgressManager.showingNotifier,
        lockManager,
      ]),
      builder: (context, _) {
        final isShowing = libraryScanProgressManager.showingNotifier.value;
        final operationName = lockManager.currentOperationDescription ?? 'Indexing library...';
    
        return AnimatedOpacity(
          opacity: isShowing ? 1.0 : 0.0,
          duration: getDuration(const Duration(milliseconds: 200)),
          child: SizedBox(
            height: ScreenUtils.kStatusBarHeight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (showText) ...[
                  Text(operationName, style: Manager.captionStyle.copyWith(fontSize: 11 * Manager.fontSizeMultiplier)),
                  const SizedBox(width: 12),
                ],
                SizedBox(
                  width: 250,
                  child: AnimatedProgressIndicator(progressNotifier: libraryScanProgressManager.progressNotifier),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AnimatedProgressIndicator extends StatefulWidget {
  final ValueNotifier<double> progressNotifier;

  const AnimatedProgressIndicator({
    super.key,
    required this.progressNotifier,
  });

  @override
  State<AnimatedProgressIndicator> createState() => _AnimatedProgressIndicatorState();
}

class _AnimatedProgressIndicatorState extends State<AnimatedProgressIndicator> {
  double _previousValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: widget.progressNotifier,
      builder: (context, progress, _) {
        final beginValue = _previousValue;
        _previousValue = progress;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: progress == 0.0 ? 0.0 : beginValue, end: progress),
          duration: progress == 0.0 ? Duration.zero : const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          builder: (context, animatedValue, _) {
            return mat.LinearProgressIndicator(
              value: animatedValue,
              trackGap: 2.5,
              backgroundColor: Colors.white.withOpacity(.15),
              year2023: false,
              stopIndicatorRadius: 0,
              valueColor: AlwaysStoppedAnimation<Color>(Manager.currentDominantColor ?? Manager.accentColor.normal),
            );
          },
        );
      },
    );
  }
}
