
import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';

import '../manager.dart';

class SpoilerBox extends StatefulWidget {
  final Widget child;

  const SpoilerBox({super.key, required this.child});

  @override
  State<SpoilerBox> createState() => SpoilerBoxState();
}

class SpoilerBoxState extends State<SpoilerBox> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: ClipRect(
        child: GestureDetector(
          onTap: () => setState(() => _revealed = !_revealed),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Manager.accentColor.lightest.withOpacity(_revealed ? 0.15 : 0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: _revealed
                ? widget.child
                : Align(
                    alignment: Alignment.centerLeft,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Opacity(
                            opacity: 0.0,
                            child: widget.child,
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            'Spoiler (tap to reveal)',
                            style: Manager.bodyStyle.copyWith(
                              color: Manager.accentColor.darker,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
