import 'package:fluent_ui3/fluent_ui.dart';
import 'package:miruryoiki/theme.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = Provider.of<AppTheme>(context, listen: false);

    return SizedBox(
      width: 138,
      height: 40,
      child: WindowCaption(
        brightness: appTheme.mode == ThemeMode.dark
            ? Brightness.dark
            : Brightness.light,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
