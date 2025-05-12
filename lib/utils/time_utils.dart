import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/utils/logging.dart';

import '../manager.dart';

DateTime get now => DateTime.now();

Duration getDuration(Duration duration) {
  if (Manager.animationsEnabled) {
    logTrace('Animation duration: ${duration.inMilliseconds} ms');
    return duration;
  }
  logTrace('Animations (disabled)');
  return Duration(milliseconds: 1);
}

void nextFrame(VoidCallback function) {
  WidgetsBinding.instance.addPostFrameCallback((_) => function());
}
