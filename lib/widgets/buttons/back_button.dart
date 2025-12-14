
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:miruryoiki/widgets/buttons/wrapper.dart';
import 'package:miruryoiki/widgets/tooltip_wrapper.dart';

class BackButton extends StatelessWidget {
  const BackButton({
    super.key,
    required this.onTap,
    required this.child,
    required this.label,
  });

  final void Function()? onTap;
  final Widget child;
  final String label;

  @override
  Widget build(BuildContext context) {
    return MouseButtonWrapper(
      child: (_) => TooltipWrapper(
        tooltip: label,
        child: (_) => Padding(
          padding: const EdgeInsets.all(2.0),
          child: IconButton(
            style: ButtonStyle(
              backgroundColor: ButtonState.resolveWith((states) {
                if (onTap == null) return Colors.transparent;
                if (states.contains(mat.MaterialState.pressed)) return Colors.white.withOpacity(0.125);
                if (states.contains(mat.MaterialState.hovered)) return Colors.white.withOpacity(0.075);
                return Colors.transparent;
              }),
              foregroundColor: ButtonState.all(Colors.white.withOpacity(onTap != null ? 1 : 0)),
              elevation: ButtonState.all(0),
              shape: ButtonState.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))),
            ),
            icon: Padding(
              padding: const EdgeInsets.all(6.0),
              child: child,
            ),
            onPressed: onTap,
          ),
        ),
      ),
    );
  }
}