import 'package:fluent_ui/fluent_ui.dart';

import '../manager.dart';

DateTime get now => DateTime.now();

String get nowFormatted => '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${now.millisecond.toString().padLeft(3, '0')}';

Duration getAnimationDuration(Duration duration) {
  if (Manager.animationsEnabled) {
    // logTrace('Animation duration: ${duration.inMilliseconds} ms');
    return duration;
  }
  // logTrace('Animations (disabled)');
  return Duration(milliseconds: 1);
}

Duration get gradientChangeDuration => getAnimationDuration(const Duration(milliseconds: 1300));

Duration get stickyHeaderDuration => getAnimationDuration(const Duration(milliseconds: 430));

Duration get shortStickyHeaderDuration => Duration(milliseconds: stickyHeaderDuration.inMilliseconds ~/ 3);

Duration get mediumDuration => getAnimationDuration(const Duration(milliseconds: 300));

Duration get longDuration => getAnimationDuration(const Duration(milliseconds: 700));

Duration get dimDuration => getAnimationDuration(const Duration(milliseconds: 200));

Duration get shortDuration => getAnimationDuration(const Duration(milliseconds: 150));

final Duration splashScreenFadeAnimationIn = const Duration(milliseconds: 400); // hardcoded
final Duration splashScreenFadeAnimationOut = const Duration(milliseconds: 400); // hardcoded

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

void _runAfterFrame(VoidCallback function) => nextFrame(function);

extension DurationArithmetic on Duration {
  Duration operator +(Duration other) => Duration(milliseconds: inMilliseconds + other.inMilliseconds);
  Duration operator -(Duration other) => Duration(milliseconds: inMilliseconds - other.inMilliseconds);
  Duration operator *(double factor) => Duration(milliseconds: (inMilliseconds * factor).round());
  Duration operator /(double divisor) => Duration(milliseconds: (inMilliseconds / divisor).round());
}

/// Display style for relative time formatters.
///
/// `short` produces compact unit suffixes (`5m`, `3h`, `2d`).
/// `long` produces full unit names with pluralization (`5 minutes`, `3 hours`, `2 days`).
enum TimeUnitStyle { short, long }

const _shortUnits = <String>['y', 'mo', 'w', 'd', 'h', 'm', 's'];
const _longUnitsSingular = <String>['year', 'month', 'week', 'day', 'hour', 'minute', 'second'];

/// Returns a human-readable representation of [duration] as one or more
/// magnitude/unit pairs, in descending order from largest non-zero unit.
///
/// `formatTimeMagnitude(Duration(days: 2, hours: 3))` → `"2d"` (default `maxUnits: 1`)
/// `formatTimeMagnitude(Duration(days: 2, hours: 3), maxUnits: 2)` → `"2d 3h"`
/// `formatTimeMagnitude(Duration(minutes: 5), style: TimeUnitStyle.long)` → `"5 minutes"`
///
/// Negative durations are treated as their absolute value — direction is the
/// caller's concern. Returns an empty string when the duration rounds to zero
/// in every supported unit.
String formatTimeMagnitude(
  Duration duration, {
  TimeUnitStyle style = TimeUnitStyle.short,
  int maxUnits = 1,
}) {
  assert(maxUnits >= 1);
  final abs = duration.abs();
  final totalSeconds = abs.inSeconds;

  // Decompose into [years, months, weeks, days, hours, minutes, seconds]
  // using the same approximations the existing call sites used.
  final years = totalSeconds ~/ (365 * 86400);
  var rem = totalSeconds - years * 365 * 86400;
  final months = rem ~/ (30 * 86400);
  rem -= months * 30 * 86400;
  final weeks = rem ~/ (7 * 86400);
  rem -= weeks * 7 * 86400;
  final days = rem ~/ 86400;
  rem -= days * 86400;
  final hours = rem ~/ 3600;
  rem -= hours * 3600;
  final minutes = rem ~/ 60;
  final seconds = rem - minutes * 60;

  final parts = <int>[years, months, weeks, days, hours, minutes, seconds];

  // Find the first non-zero unit and emit up to [maxUnits] consecutive non-zero units.
  // Find the first non-zero unit and emit up to [maxUnits] non-zero units,
  // skipping zero-valued units that may appear between them.
  final pieces = <String>[];
  var startedAt = -1;
  for (var i = 0; i < parts.length && pieces.length < maxUnits; i++) {
    if (parts[i] == 0) {
      continue;
    }
    if (startedAt == -1) startedAt = i;
    pieces.add(_renderUnit(parts[i], i, style));
  }
  return pieces.join(' ');
}

String _renderUnit(int value, int index, TimeUnitStyle style) {
  if (style == TimeUnitStyle.short) return '$value${_shortUnits[index]}';
  final base = _longUnitsSingular[index];
  return '$value $base${value == 1 ? '' : 's'}';
}

/// Returns a human-readable relative time string for [when] compared to
/// [reference] (defaults to [now]).
///
/// Past:    `"5m ago"`  / `"5 minutes ago"`
/// Future:  `"in 5m"`   / `"in 5 minutes"`
/// Within ~1 minute either side: `"just now"`
///
/// Pass [maxUnits] > 1 to combine units (e.g. `"2d 3h"` / `"in 2d 3h"`).
String formatRelativeTime(
  DateTime when, {
  DateTime? reference,
  TimeUnitStyle style = TimeUnitStyle.short,
  int maxUnits = 1,
}) {
  final ref = reference ?? now;
  final diff = ref.difference(when);
  if (diff.inSeconds.abs() < 60) return 'just now';

  final magnitude = formatTimeMagnitude(diff, style: style, maxUnits: maxUnits);
  return diff.isNegative ? 'in $magnitude' : '$magnitude ago';
}