// Source - https://stackoverflow.com/a
// Posted by Rémi Rousselet
// Retrieved 2025-12-12, License - CC BY-SA 4.0

import 'package:fluent_ui/fluent_ui.dart';

class ReassembleListener extends StatefulWidget {
  const ReassembleListener({
    super.key,
    this.onReassemble,
    required this.child,
  });

  final VoidCallback? onReassemble;
  final Widget child;

  @override
  _ReassembleListenerState createState() => _ReassembleListenerState();
}

class _ReassembleListenerState extends State<ReassembleListener> {
  @override
  void reassemble() {
    super.reassemble();
    widget.onReassemble?.call();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
