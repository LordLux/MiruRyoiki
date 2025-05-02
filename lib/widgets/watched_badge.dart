// import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart';

class WatchedBadge extends StatelessWidget {
  final bool isWatched;
  final double size;
  
  const WatchedBadge({
    super.key,
    this.isWatched = false,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isWatched ? Colors.green : Colors.transparent,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: isWatched ? Colors.green : Colors.grey,
          width: 2,
        ),
      ),
      child: isWatched
          ? Icon(
              FluentIcons.check_mark,
              size: size * 0.6,
              color: Colors.white,
            )
          : null,
    );
  }
}