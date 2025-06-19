import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AnimatedStatCounter<T extends num> extends StatefulWidget {
  final T targetValue;
  final String suffix;
  final TextStyle textStyle;
  final T initialValue;
  final bool isDouble;

  const AnimatedStatCounter({
    super.key,
    required this.targetValue,
    required this.textStyle,
    this.suffix = '',
    this.isDouble = false,
    initialValue,
  }) : initialValue = 0.0 as T;

  @override
  _AnimatedStatCounterState<T> createState() => _AnimatedStatCounterState<T>();
}

class _AnimatedStatCounterState<T extends num> extends State<AnimatedStatCounter<T>> {
  late T currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.initialValue;
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => currentValue = widget.targetValue);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedFlipCounter(
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 1000),
      value: currentValue,
      suffix: widget.suffix,
      fractionDigits: widget.isDouble ? 1 : 0,
      decimalSeparator: '.',
      textStyle: widget.textStyle,
    );
  }
}
