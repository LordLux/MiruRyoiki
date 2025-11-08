import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;

import '../manager.dart';
import '../utils/screen.dart';
import '../utils/time.dart';

class SpoilerBox extends StatefulWidget {
  final Widget child;
  final String id;
  final bool initiallyRevealed;
  final Function(bool)? onRevealChanged;

  const SpoilerBox({
    super.key,
    required this.child,
    required this.id,
    this.initiallyRevealed = false,
    this.onRevealChanged,
  });

  @override
  State<SpoilerBox> createState() => SpoilerBoxState();
}

class SpoilerBoxState extends State<SpoilerBox> {
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _revealed = widget.initiallyRevealed;
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ScreenUtils.kEpisodeCardBorderRadius),
        child: mat.InkWell(
          onTap: () {
            setState(() {
              _revealed = !_revealed;
              widget.onRevealChanged?.call(_revealed);
            });
          },
          borderRadius: BorderRadius.circular(ScreenUtils.kEpisodeCardBorderRadius),
          child: AnimatedContainer(
            duration: dimDuration,
            decoration: BoxDecoration(
              color: Manager.accentColor.darkest.withOpacity(_revealed ? 0.15 : 0.5),
              borderRadius: BorderRadius.circular(ScreenUtils.kEpisodeCardBorderRadius),
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
                        SelectionContainer.disabled(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              'Spoiler (tap to reveal)',
                              style: Manager.bodyStyle.copyWith(
                                color: Manager.accentColor.lightest,
                                fontStyle: FontStyle.italic,
                              ),
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
