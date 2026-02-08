import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/theme.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'tooltip_wrapper.dart';

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
        isSecondary: isSecondary,
      ),
    );
  }
}

class WindowCaption extends StatefulWidget {
  const WindowCaption({
    super.key,
    this.title,
    this.backgroundColor,
    this.brightness,
    this.isSecondary = false,
  });

  final Widget? title;
  final Color? backgroundColor;
  final Brightness? brightness;
  final bool isSecondary;

  @override
  State<WindowCaption> createState() => _WindowCaptionState();
}

class _WindowCaptionState extends State<WindowCaption> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? (widget.brightness == Brightness.dark ? const Color(0xff1C1C1C) : Colors.transparent),
      ),
      child: TooltipTheme(
        data: TooltipThemeData(
          decoration: BoxDecoration(
            color: Color.lerp(FluentTheme.of(context).micaBackgroundColor, Colors.white, 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
          waitDuration: const Duration(milliseconds: 1000),
          preferBelow: true,
        ),
        child: Row(
          children: [
            Expanded(
              child: DragToMoveArea(
                child: SizedBox(
                  height: double.infinity,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 16),
                        child: DefaultTextStyle(
                          style: TextStyle(
                            color: widget.brightness == Brightness.light ? Colors.black.withOpacity(0.8956) : Colors.white,
                            fontSize: 14,
                          ),
                          child: widget.title ?? Container(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (!widget.isSecondary)
              TooltipWrapper(
                tooltip: 'Minimize',
                child: (_) => WindowCaptionButton.minimize(
                  brightness: widget.brightness,
                  onPressed: () async {
                    bool isMinimized = await windowManager.isMinimized();
                    if (isMinimized) {
                      windowManager.restore();
                    } else {
                      windowManager.minimize();
                    }
                  },
                ),
              ),
            if (!widget.isSecondary)
              FutureBuilder<bool>(
                future: windowManager.isMaximized(),
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.data == true) {
                    return TooltipWrapper(
                      tooltip: 'Unmaximize',
                      child: (_) => WindowCaptionButton.unmaximize(
                        brightness: widget.brightness,
                        onPressed: () {
                          windowManager.unmaximize();
                        },
                      ),
                    );
                  }
                  return TooltipWrapper(
                    tooltip: 'Maximize',
                    child: (_) => WindowCaptionButton.maximize(
                      brightness: widget.brightness,
                      onPressed: () {
                        windowManager.maximize();
                      },
                    ),
                  );
                },
              ),
            TooltipWrapper(
              tooltip: 'Close',
              child: (_) => WindowCaptionButton.close(
                brightness: widget.brightness,
                onPressed: () {
                  windowManager.close();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onWindowMaximize() => setState(() {});

  @override
  void onWindowUnmaximize() => setState(() {});
}
