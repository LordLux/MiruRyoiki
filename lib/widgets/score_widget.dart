import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:flutter_animated_fluent_emoji/flutter_animated_fluent_emoji.dart';
import 'package:miruryoiki/utils/time.dart';

import '../manager.dart';
import '../models/anilist/user_data.dart';
import 'buttons/button.dart';

/// A score widget that renders and (optionally) edits a score value using the
/// user's preferred AniList score format.
///
/// Internally, scores are always stored as POINT_100 (0-100 integer) — the
/// format-independent canonical value that the AniList API calls `scoreRaw`.
/// This widget converts to/from the user's preferred display format.
///
/// When [editable] is false, it only renders the score. When [editable] is
/// true, it provides interactive controls and calls [onChanged] with the new
/// POINT_100 value.
///
/// A score of `0` is treated as "unrated" — it renders as empty stars, neutral
/// smileys, etc.
class ScoreWidget extends StatelessWidget {
  /// The score value in POINT_100 (0-100). `0` or `null` means unrated.
  final int? score;

  /// The format to use for display and editing.
  final AnilistScoreFormat format;

  /// If true, the widget can be interacted with to change the score.
  final bool editable;

  /// Called with the new score in POINT_100 (0-100) when the user changes it.
  final ValueChanged<int>? onChanged;

  /// Icon size for star/smiley formats. Ignored for numeric formats.
  final double iconSize;

  /// Optional fixed color override for icons. When null, the widget uses the
  /// theme's accent / resource colors.
  final Color? iconColor;

  /// Whether to append the max value (e.g. " / 10") when rendering a numeric
  /// score in non-editable mode. Ignored for star/smiley formats.
  final bool showMax;

  /// Text style for numeric display.
  final TextStyle? textStyle;

  const ScoreWidget({
    super.key,
    required this.score,
    required this.format,
    this.editable = false,
    this.onChanged,
    this.iconSize = 16,
    this.iconColor,
    this.showMax = true,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final value = score ?? 0;
    final accentColor = Manager.currentDominantAccentColor ?? Manager.accentColor;
    final selectionColor = accentColor.withOpacity(0.2);

    return FluentTheme(
        data: FluentTheme.of(context).copyWith(
          accentColor: accentColor,
          selectionColor: selectionColor,
        ),
        child: Builder(builder: (context) {
          switch (format) {
            case AnilistScoreFormat.POINT_100:
              return _buildNumeric(
                context,
                displayValue: value,
                min: 0,
                max: 100,
                toPoint100: (v) => v,
                formatLabel: (v) => v.toString(),
              );
            case AnilistScoreFormat.POINT_10_DECIMAL:
              return _buildDecimalNumeric(context, value: value);
            case AnilistScoreFormat.POINT_10:
              return _buildNumeric(
                context,
                displayValue: value ~/ 10,
                min: 0,
                max: 10,
                toPoint100: (v) => v * 10,
                formatLabel: (v) => v.toString(),
              );
            case AnilistScoreFormat.POINT_5:
              return _buildStars(context, value);
            case AnilistScoreFormat.POINT_3:
              return _buildSmileys(context, value);
          }
        }));
  }


  // Numeric formats

  Widget _buildNumeric(
    BuildContext context, {
    required int displayValue,
    required int min,
    required int max,
    required int Function(int) toPoint100,
    required String Function(int) formatLabel,
  }) {
    if (!editable) {
      final displayed = displayValue == 0 ? '–' : formatLabel(displayValue);
      final suffix = (showMax && displayValue != 0) ? ' / $max' : '';
      return Text('$displayed$suffix', style: textStyle);
    }
    return NumberBox<int>(
      value: displayValue,
      min: min,
      max: max,
      onChanged: (v) {
        if (v == null) return;
        final clamped = v.clamp(min, max).toInt();
        onChanged?.call(toPoint100(clamped));
      },
    );
  }

  Widget _buildDecimalNumeric(BuildContext context, {required int value}) {
    // value is POINT_100 (0-100); display as 0.0-10.0 with 1 decimal place.
    // POINT_10_DECIMAL allows 0.5 increments (e.g. 8.5 = POINT_100 85).
    if (!editable) {
      final displayVal = value / 10;
      final displayed = value == 0 ? '–' : displayVal.toStringAsFixed(1);
      final suffix = (showMax && value != 0) ? ' / 10.0' : '';
      return Text('$displayed$suffix', style: textStyle);
    }
    return NumberBox<double>(
      value: value / 10,
      min: 0,
      max: 10,
      smallChange: 0.5,
      onChanged: (v) {
        if (v == null) return;
        final clamped = v.clamp(0.0, 10.0);
        // Multiply by 10 and round to get POINT_100 (e.g. 8.5 → 85).
        onChanged?.call((clamped * 10).round());
      },
    );
  }


// POINT_5: stars

  /// Converts a POINT_100 value (0-100) into the number of filled stars (0–5).
  /// Matches AniList's mapping: 1-20 = 1★, 21-40 = 2★, 41-60 = 3★, 61-80 = 4★, 81-100 = 5★.
  int _point100ToStars(int v) {
    if (v <= 0) return 0;
    return ((v + 19) ~/ 20).clamp(1, 5);
  }

  /// Converts a star count (1-5) back into a POINT_100 value.
  int _starsToPoint100(int stars) => stars <= 0 ? 0 : (stars * 20).clamp(20, 100);

  Widget _buildStars(BuildContext context, int value) {
    final theme = FluentTheme.of(context);
    final filledColor = iconColor ?? theme.accentColor.defaultBrushFor(theme.brightness);
    final emptyColor = (iconColor ?? theme.resources.textFillColorSecondary).withOpacity(0.6);

    final filled = _point100ToStars(value);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (idx) {
        final isFilled = idx < filled;
        final isLastFilled = idx == filled - 1;
        final icon = Icon(
          isFilled ? mat.Icons.star : mat.Icons.star_outline_outlined,
          size: iconSize + 3,
          color: isFilled ? filledColor : emptyColor,
        );

        return StandardButton(
          onPressed: editable ? () => onChanged?.call(_starsToPoint100(idx + 1)) : null,
          label: icon,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          tooltip: isLastFilled || !editable ? '${idx + 1} star${idx == 0 ? '' : 's'}' : 'Click to set score to ${idx + 1} star${idx == 0 ? '' : 's'}',
          hoverColor: filledColor.withOpacity(0.15),
        );
      }),
    );
  }


// POINT_3: smileys

  /// Converts POINT_100 to a POINT_3 bucket: 0 = unrated, 1 = sad, 2 = neutral,
  /// 3 = happy. Matches AniList's mapping (1-30 sad, 31-60 neutral, 61-100 happy).
  int _point100ToSmiley(int v) {
    if (v <= 0) return 0;
    if (v <= 30) return 1;
    if (v <= 60) return 2;
    return 3;
  }

  /// Converts a smiley bucket (1-3) back to POINT_100.
  int _smileyToPoint100(int s) {
    switch (s) {
      case 1:
        return 30;
      case 2:
        return 50;
      case 3:
        return 80;
      default:
        return 0;
    }
  }

  Widget _buildSmileys(BuildContext context, int value) {
    final theme = FluentTheme.of(context);
    final activeColor = Manager.currentDominantAccentColor ?? Manager.accentColor;
    final inactiveColor = (iconColor ?? theme.resources.textFillColorSecondary).withOpacity(0.1);

    final selected = _point100ToSmiley(value);
    final icons = [
      ('assets/icons/faces/frowning_face_3d.png', 'assets/icons/faces/frowning_face_animated.gif', 2880), // :(
      ('assets/icons/faces/neutral_face_3d.png', 'assets/icons/faces/neutral_face_animated.gif', 1480), // :|
      ('assets/icons/faces/grinning_face_with_smiling_eyes_3d.png', 'assets/icons/faces/grinning_face_with_smiling_eyes_animated.gif', 2880), // :)
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(3, (i) {
        final idx = i + 1;
        final isSelected = idx == selected;

        return FluentAnimatedIconButton(
          selected: isSelected,
          semanticLabel: 'User Score',
          enabled: editable,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          builder: (context, state, renderedIcon) {
            if (editable) {
              return StandardButton(
                label: renderedIcon,
                onPressed: null,
                tooltip: isSelected || !editable //
                    ? ['Unrated', 'Sad', 'Neutral', 'Happy'][idx]
                    : 'Click to set score to ${format == AnilistScoreFormat.POINT_3 ? ['Unrated', 'Sad', 'Neutral', 'Happy'][idx] : _smileyToPoint100(idx).toString()}',
                hoverColor: activeColor.withOpacity(0.15),
                backgroundColor: isSelected && state.selected ? activeColor : inactiveColor,
                isFilled: isSelected && state.selected,
                isSelected: isSelected,
                background: AnimatedContainer(
                  duration: mediumDuration,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: isSelected //
                          ? [Colors.transparent, Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.25)]
                          : [Colors.transparent, Colors.transparent, Colors.transparent],
                      stops: [0.2, 0.5, 1],
                      focal: Alignment.center,
                      focalRadius: 1,
                    ),
                  ),
                ),
              );
            }
            return StandardButton(
              label: renderedIcon,
              onPressed: null,
              tooltip: format == AnilistScoreFormat.POINT_3 ? ['Unrated', 'Sad', 'Neutral', 'Happy'][idx] : _smileyToPoint100(idx).toString(),
              cursor: SystemMouseCursors.basic,
              hoverColor: Colors.transparent,
              backgroundColor: isSelected ? activeColor : Colors.transparent,
              isSelected: isSelected,
              background: AnimatedContainer(
                duration: mediumDuration,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: isSelected //
                        ? [Colors.transparent, Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.25)]
                        : [Colors.transparent, Colors.transparent, Colors.transparent],
                    stops: [0.2, 0.5, 1],
                    focal: Alignment.center,
                    focalRadius: 1,
                  ),
                ),
              ),
            );
          },
          onTap: (_) => onChanged?.call(isSelected ? 0 : _smileyToPoint100(idx)),
          icon: FluentAnimatedIcon.image(
            staticIcon: FluentAnimationStaticIcon.png(icons[i].$1),
            animatedIcon: FluentAnimationAnimatedIcon.gif(icons[i].$2, totalDuration: Duration(milliseconds: icons[i].$3)),
            size: 26,
          ),
        );
      }),
    );
  }
}

/// Minimal tap wrapper so stars / smileys feel clickable without an oversized
/// Button wrapper.
class _TapIcon extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _TapIcon({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: child,
      ),
    );
  }
}
