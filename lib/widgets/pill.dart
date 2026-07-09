// ignore_for_file: unnecessary_this

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;

import '../manager.dart';
import '../utils/color.dart';
import '../utils/time.dart';
import 'buttons/wrapper.dart';

class Pill extends StatelessWidget {
  final String text;
  final String tooltip;
  final VoidCallback? onTap;
  final bool isHovering;
  final IconData? icon;
  final double iconSize;
  final double spacing;
  final Color? textColor;
  final Color? selectedTextColor;
  final AccentColor backgroundColor;
  final AccentColor selectedBackgroundColor;
  final MouseCursor? cursor;

  Pill({
    super.key,
    required this.text,
    this.icon,
    AccentColor? backgroundColor,
    AccentColor? selectedBackgroundColor,
    this.textColor,
    this.selectedTextColor,
    String? tooltip,
    this.onTap,
    this.spacing = 2,
    this.iconSize = 14,
    this.isHovering = false,
    this.cursor,
  })  : tooltip = tooltip ?? text,
        this.backgroundColor = backgroundColor ?? Colors.white.toAccentColor(),
        this.selectedBackgroundColor = selectedBackgroundColor ?? Manager.currentDominantAccentColor ?? Manager.accentColor;

  @override
  Widget build(BuildContext context) {
    final textColor_ = textColor ?? Colors.white;
    final selectedTextColor_ = selectedTextColor ?? getTextColor(this.selectedBackgroundColor.light, preferBlack: 0.8);
    return MouseButtonWrapper(
      tooltip: tooltip,
      cursor: cursor,
      tooltipWaitDuration: const Duration(milliseconds: 350),
      child: (isHovering) => mat.InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
        child: AnimatedContainer(
          duration: shortDuration,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isHovering ? selectedBackgroundColor.light : backgroundColor.light.withOpacity(.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isHovering ? selectedBackgroundColor.dark : backgroundColor.dark.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: iconSize,
                  color: isHovering ? selectedTextColor_ : textColor_,
                ),
                SizedBox(width: spacing),
              ],
              Text(
                text,
                style: Manager.captionStyle.copyWith(
                  color: isHovering ? selectedTextColor_ : textColor_,
                  fontSize: 11 * Manager.fontSizeMultiplier,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget FluentPill({
  required String text,
  AccentColor? backgroundColor,
  AccentColor? selectedBackgroundColor,
  Color? textColor,
  Color? selectedTextColor,
  IconData? icon,
  double iconSize = 10,
  double spacing = 4,
  Function(String)? onTap,
  MouseCursor? cursor = SystemMouseCursors.click,
}) {
  return Pill(
    text: text,
    backgroundColor: backgroundColor,
    selectedBackgroundColor: selectedBackgroundColor,
    textColor: textColor,
    selectedTextColor: selectedTextColor,
    icon: icon,
    iconSize: iconSize,
    spacing: spacing,
    onTap: onTap != null ? () => onTap(text) : null,
    cursor: cursor,
  );
}
