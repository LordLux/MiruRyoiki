import 'package:fluent_ui/fluent_ui.dart';

import '../utils/logging.dart';

class LoadingButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;
  final bool isButtonDisabled;

  const LoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.isLoading,
    this.isButtonDisabled = false,
  });

  @override
  _LoadingButtonState createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool isLocalLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Button(
      style: ButtonStyle(
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(
            vertical: 12,
            horizontal: widget.isLoading ? 24 : 32,
          ),
        ),
      ),
      onPressed: widget.isButtonDisabled
          ? null
          : widget.onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.label),
          if (widget.isLoading) ...[
            const SizedBox(width: 8),
            const SizedBox(
              width: 25,
              height: 25,
              child: ProgressRing(),
            )
          ],
        ],
      ),
    );
  }
}
