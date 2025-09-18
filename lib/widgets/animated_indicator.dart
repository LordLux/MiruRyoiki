import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/manager.dart';
import 'package:miruryoiki/utils/time.dart';

class AnimatedNavigationIndicator extends StatefulWidget {
  final Widget Function(Color? color) indicatorBuilder;
  final Color? targetColor;

  const AnimatedNavigationIndicator({
    super.key,
    required this.indicatorBuilder,
    this.targetColor,
  });

  @override
  State<AnimatedNavigationIndicator> createState() => _AnimatedNavigationIndicatorState();
}

class _AnimatedNavigationIndicatorState extends State<AnimatedNavigationIndicator> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  Color? _previousColor;
  Color? _currentColor;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: getDuration(const Duration(milliseconds: 300)),
      vsync: this,
    );
    
    _previousColor = Manager.accentColor.lighter;
    _currentColor = widget.targetColor ?? Manager.accentColor.lighter;
    _updateColorAnimation();
  }
  
  @override
  void didUpdateWidget(AnimatedNavigationIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetColor != widget.targetColor) {
      _previousColor = _currentColor;
      _currentColor = widget.targetColor ?? Manager.accentColor.lighter;
      _updateColorAnimation();
      _controller.reset();
      _controller.forward();
    }
  }
  
  void _updateColorAnimation() {
    _colorAnimation = ColorTween(
      begin: _previousColor,
      end: _currentColor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return widget.indicatorBuilder(_colorAnimation.value);
      },
    );
  }
}