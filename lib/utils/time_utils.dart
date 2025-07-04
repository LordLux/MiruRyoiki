import 'package:fluent_ui/fluent_ui.dart';

import '../manager.dart';

DateTime get now => DateTime.now();

String get nowFormatted => '${now.hour}:${now.minute}:${now.second}.${now.millisecond.toString().padLeft(3, '0')}';

Duration getDuration(Duration duration) {
  if (Manager.animationsEnabled) {
    // logTrace('Animation duration: ${duration.inMilliseconds} ms');
    return duration;
  }
  // logTrace('Animations (disabled)');
  return Duration(milliseconds: 1);
}

Duration get gradientChangeDuration => getDuration(const Duration(milliseconds: 1300));

Duration get stickyHeaderDuration => getDuration(const Duration(milliseconds: 430));

Duration get shortStickyHeaderDuration => Duration(milliseconds: stickyHeaderDuration.inMilliseconds ~/ 3);

Duration get dimDuration => getDuration(const Duration(milliseconds: 200));

Duration get shortDuration => getDuration(const Duration(milliseconds: 150));

final Duration splashScreenFadeAnimation = const Duration(milliseconds: 800); // hardcoded

/// Runs a function after the current frame is rendered.
///
/// This is useful for ensuring that the UI is fully built before executing
void nextFrame(
  /// a function, optionally with a delay.
  VoidCallback function, {
  /// delay in milliseconds before running the function 
  int delay = 0,
}) {
  if (delay > 0)
    Future.delayed(Duration(milliseconds: delay), () => _runAfterFrame(function));
  else
    _runAfterFrame(function);
}

void _runAfterFrame(VoidCallback function) => WidgetsBinding.instance.addPostFrameCallback((_) => function());
