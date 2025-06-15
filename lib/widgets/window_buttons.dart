import 'package:fluent_ui/fluent_ui.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:miruryoiki/services/window/service.dart';
import 'package:miruryoiki/theme.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class WindowButtons extends StatelessWidget {
  final bool isSecondary;

  const WindowButtons({super.key, this.isSecondary = false});

  @override
  Widget build(BuildContext context) {
    final appTheme = Provider.of<AppTheme>(context, listen: false);

    return SizedBox(
      width: 138,
      height: 40,
      child: WindowCaption(
        key: Key('window_caption_${isSecondary ? 'secondary' : 'primary'}'),
        brightness: appTheme.mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
