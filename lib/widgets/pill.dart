import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;

import '../manager.dart';
import '../utils/time.dart';
import 'buttons/wrapper.dart';

class Pill extends StatelessWidget {
  final String text;
  final String tooltip;
  final VoidCallback? onTap;
  final bool isSelected;
  final IconData icon;
  final double iconSize;
  final double spacing;
  final Color Function(bool isSelected) color;

  const Pill({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    String? tooltip,
    this.onTap,
    this.spacing = 2,
    this.iconSize = 14,
    this.isSelected = false,
  }) : tooltip = tooltip ?? text;

  @override
  Widget build(BuildContext context) {
    return MouseButtonWrapper(
      tooltip: tooltip,
      tooltipWaitDuration: const Duration(milliseconds: 350),
      child: (_) => mat.InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
        child: AnimatedContainer(
          duration: shortDuration,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? (Manager.currentDominantAccentColor ?? Manager.accentColor).light : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? (Manager.currentDominantAccentColor ?? Manager.accentColor).dark : Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: iconSize,
                color: color(isSelected),
              ),
              SizedBox(width: spacing),
              Text(
                text,
                style: Manager.captionStyle.copyWith(
                  color: color(isSelected),
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
