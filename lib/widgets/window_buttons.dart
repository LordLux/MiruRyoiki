
import 'package:fluent_ui3/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = FluentTheme.maybeOf(context)?.brightness ?? Brightness.dark;

    return SizedBox(
      width: 138,
      height: 40,
      child: WindowCaption(
        brightness: brightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
