import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:miruryoiki/services/window/service.dart';
import 'package:miruryoiki/theme.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../services/navigation/shortcuts.dart';

class WindowButtons extends StatelessWidget {
  final bool isSecondary;
  final VoidCallback? onFullScreenOpen;

  const WindowButtons({super.key, this.isSecondary = false, this.onFullScreenOpen});

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
    this.onFullScreenOpen,
  });

  final Widget? title;
  final Color? backgroundColor;
  final Brightness? brightness;
  final bool isSecondary;
  final VoidCallback? onFullScreenOpen;

  @override
  State<WindowCaption> createState() => _WindowCaptionState();
}

class _WindowCaptionState extends State<WindowCaption> with WindowListener {
  bool _isHoveringOnMaximize = false;

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
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
        child: ValueListenableBuilder(
            valueListenable: KeyboardState.shiftPressedNotifier,
            builder: (context, shiftPressed, child) {
              return Row(
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
                    Tooltip(
                      message: 'Minimize',
                      child: WindowCaptionButton.minimize(
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
                  MouseRegion(
                    onEnter: (_) => setState(() => _isHoveringOnMaximize = true),
                    onExit: (_) => setState(() => _isHoveringOnMaximize = false),
                    child: Builder(builder: (context) {
                      if (widget.isSecondary || (shiftPressed && _isHoveringOnMaximize))
                        return FutureBuilder<bool>(
                          future: windowManager.isFullScreen(),
                          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                            if (snapshot.data == true) {
                              return Tooltip(
                                message: 'Exit Fullscreen',
                                child: WindowCaptionButtonFullScreen(
                                  brightness: widget.brightness,
                                  icon: (Color iconColor) => Icon(Symbols.close_fullscreen, color: iconColor, size: 16),
                                  onPressed: () {
                                    WindowStateService.toggleFullScreen();
                                  },
                                ),
                              );
                            }
                            return Tooltip(
                              message: 'Enter Fullscreen',
                              child: WindowCaptionButtonFullScreen(
                                brightness: widget.brightness,
                                icon: (Color iconColor) => Icon(Symbols.open_in_full, color: iconColor, size: 16),
                                onPressed: () {
                                  WindowStateService.toggleFullScreen();
                                  widget.onFullScreenOpen?.call();
                                },
                              ),
                            );
                          },
                        );
                      return FutureBuilder<bool>(
                        future: windowManager.isMaximized(),
                        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                          if (snapshot.data == true) {
                            return Tooltip(
                              message: 'Unmaximize',
                              child: WindowCaptionButton.unmaximize(
                                brightness: widget.brightness,
                                onPressed: () {
                                  windowManager.unmaximize();
                                },
                              ),
                            );
                          }
                          return Tooltip(
                            message: 'Maximize',
                            child: WindowCaptionButton.maximize(
                              brightness: widget.brightness,
                              onPressed: () {
                                windowManager.maximize();
                              },
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  Tooltip(
                    message: 'Close',
                    child: WindowCaptionButton.close(
                      brightness: widget.brightness,
                      onPressed: () {
                        windowManager.close();
                      },
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  @override
  void onWindowMaximize() {
    WindowStateService.saveWindowState();
    setState(() {});
  }

  @override
  void onWindowUnmaximize() {
    WindowStateService.saveWindowState();
    setState(() {});
  }
}

class WindowCaptionButtonFullScreen extends StatefulWidget {
  WindowCaptionButtonFullScreen({
    super.key,
    this.brightness,
    this.icon,
    required this.onPressed,
  });

  final Brightness? brightness;
  final Widget Function(Color)? icon;
  final VoidCallback? onPressed;

  final _ButtonBgColorScheme _lightButtonBgColorScheme = _ButtonBgColorScheme(
    normal: Colors.transparent,
    hovered: Colors.black.withOpacity(0.0373),
    pressed: Colors.black.withOpacity(0.0241),
  );
  final _ButtonIconColorScheme _lightButtonIconColorScheme = _ButtonIconColorScheme(
    normal: Colors.black.withOpacity(0.8956),
    hovered: Colors.black.withOpacity(0.8956),
    pressed: Colors.black.withOpacity(0.6063),
    disabled: Colors.black.withOpacity(0.3614),
  );
  final _ButtonBgColorScheme _darkButtonBgColorScheme = _ButtonBgColorScheme(
    normal: Colors.transparent,
    hovered: Colors.white.withOpacity(0.0605),
    pressed: Colors.white.withOpacity(0.0419),
  );
  final _ButtonIconColorScheme _darkButtonIconColorScheme = _ButtonIconColorScheme(
    normal: Colors.white,
    hovered: Colors.white,
    pressed: Colors.white.withOpacity(0.786),
    disabled: Colors.black.withOpacity(0.3628),
  );

  _ButtonBgColorScheme get buttonBgColorScheme => brightness != Brightness.dark ? _lightButtonBgColorScheme : _darkButtonBgColorScheme;

  _ButtonIconColorScheme get buttonIconColorScheme => brightness != Brightness.dark ? _lightButtonIconColorScheme : _darkButtonIconColorScheme;

  @override
  State<WindowCaptionButtonFullScreen> createState() => _WindowCaptionButtonState();
}

class _WindowCaptionButtonState extends State<WindowCaptionButtonFullScreen> {
  bool _isHovering = false;
  bool _isPressed = false;

  void _onEntered({required bool hovered}) {
    setState(() => _isHovering = hovered);
  }

  void _onActive({required bool pressed}) {
    setState(() => _isPressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = widget.buttonBgColorScheme.normal;
    Color iconColor = widget.buttonIconColorScheme.normal;

    if (_isHovering) {
      bgColor = widget.buttonBgColorScheme.hovered;
      iconColor = widget.buttonIconColorScheme.hovered;
    }
    if (_isPressed) {
      bgColor = widget.buttonBgColorScheme.pressed;
      iconColor = widget.buttonIconColorScheme.pressed;
    }

    return MouseRegion(
      onExit: (value) => _onEntered(hovered: false),
      onHover: (value) => _onEntered(hovered: true),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _onActive(pressed: true),
        onTapCancel: () => _onActive(pressed: false),
        onTapUp: (_) => _onActive(pressed: false),
        onTap: widget.onPressed,
        child: Container(
          constraints: const BoxConstraints(minWidth: 46, minHeight: 32),
          decoration: BoxDecoration(
            color: bgColor,
          ),
          child: Center(child: widget.icon?.call(iconColor)),
        ),
      ),
    );
  }
}

class _ButtonBgColorScheme {
  _ButtonBgColorScheme({
    required this.normal,
    required this.hovered,
    required this.pressed,
  });
  final Color normal;
  final Color hovered;
  final Color pressed;
}

class _ButtonIconColorScheme {
  _ButtonIconColorScheme({
    required this.normal,
    required this.hovered,
    required this.pressed,
    required this.disabled,
  });
  final Color normal;
  final Color hovered;
  final Color pressed;
  final Color disabled;
}
