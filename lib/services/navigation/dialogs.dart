
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Material;
import 'package:provider/provider.dart';
import 'package:glossy/glossy.dart';

import '../../utils/screen.dart';
import '../../manager.dart';
import '../../utils/logging.dart';
import '../../utils/time.dart';
import '../../widgets/buttons/wrapper.dart';
import '../../widgets/dialogs/show_dialog.dart';
import '../../main.dart';
import '../../widgets/frosted_noise.dart';
import 'debug.dart';
import 'navigation.dart';

bool kReturnTrueCallback() => true;
bool kReturnFalseCallback() => false;

Color getBarrierColor(Color? color, {bool override = false}) {
  if (override && color != null) return color;

  final Color baseColor = const Color(0xFF000000);
  if (color == null) return baseColor.withAlpha(0x84);
  // If no color is provided, use the default barrier color
  return (baseColor.lerpWith(color, .025)).withAlpha(0x84);
}

/// Helper for managing dialog navigation state
Future<T?> showManagedDialog<T>({
  required BuildContext context,
  required String id,
  required String title,
  required ManagedDialog Function(BuildContext) builder,
  Color? barrierColor = const Color(0x8A000000),

  /// Whether to use the exact barrier color or a lerped version of it
  bool overrideColor = false,
  Object? data,
  bool canUserPopDialog = true,

  /// Whether the barrier should let interactions through or not
  bool transparentBarrier = false,
  bool Function() dialogDoPopCheck = kReturnFalseCallback,
  bool closeExistingDialogs = false,
  VoidCallback? onDismiss,
  RouteTransitionsBuilder? transitionBuilder,
}) async {
  final navManager = Manager.navigation;

  // Register in navigation stack
  navManager.pushDialog(id, title, data: data);

  // Show the dialog
  final result = await showPaddedDialog<T>(
    context: rootNavigatorKey.currentContext!,
    barrierColor: getBarrierColor(barrierColor, override: overrideColor),
    useRootNavigator: true,
    transitionBuilder: transitionBuilder,
    dismissWithEsc: false, // DO NOT allow ESC to close the dialog, as esc already triggers normal pop (wtf flutter?)
    barrierDismissible: canUserPopDialog, // allow barrier to dismiss if no check provided
    barrierPadding: EdgeInsets.only(top: ScreenUtils.kTitleBarHeight),
    closeExistingDialogs: closeExistingDialogs,
    transparentBarrier: transparentBarrier,
    onDismiss: onDismiss,
    builder: (context) => PopScope(
      canPop: false, // Prevent popping from the dialog itself
      onPopInvoked: (didPop) async {
        if (didPop) return; // If the pop was invoked, do nothing

        if (dialogDoPopCheck()) {
          logTrace('Dialog pop invoked, closing dialog');
          Navigator.of(context).pop(); // Close the dialog
        }
      },
      child: builder(context),
    ),
  ).then((_) {
    navManager.popDialog();
    Manager.canPopDialog = true; // Reset dialog pop state
    nextFrame(Manager.setState);
  });

  return result;
}

Future<T?> showSimpleManagedDialog<T>({
  required BuildContext context,
  required String id,
  required String title,

  /// Body text of the dialog, if not provided, builder will be used
  String body = '',
  BoxConstraints? constraints,

  /// Builder for the dialog content, if not provided, defaults to a Text widget
  Widget Function(BuildContext)? builder,
  String positiveButtonText = 'OK',
  String negativeButtonText = 'Cancel',
  bool isPositiveButtonPrimary = false,
  bool hideTitle = false,

  /// Optional custom title widget, overrides the title string if provided
  Widget? titleWidget,

  /// Callback for the positive button, automatically closes the dialog
  Function()? onPositive,

  /// Callback for the negative button, automatically closes the dialog
  Function()? onNegative,
}) async {
  assert(
    body.isNotEmpty || builder != null,
    'Either body or builder must be provided for the dialog content',
  );
  return showManagedDialog(
    context: context,
    id: id,
    title: title,
    dialogDoPopCheck: () => true,
    builder: (context) {
      return ManagedDialog(
        popContext: context,
        title: hideTitle ? null : titleWidget ?? Text(title),
        contentBuilder: (context, __) => builder != null ? builder(context) : Text(body),
        constraints: constraints ??
            const BoxConstraints(
              maxWidth: 500,
              minWidth: 300,
            ),
        actions: (popContext) => [
          ManagedDialogButton(
            popContext: popContext,
            text: negativeButtonText,
            onPressed: () => onNegative?.call(),
          ),
          ManagedDialogButton(
            isPrimary: isPositiveButtonPrimary,
            popContext: popContext,
            text: positiveButtonText,
            onPressed: () => onPositive?.call(),
          ),
        ],
      );
    },
  );
}

Future<T?> showSimpleTickboxManagedDialog<T>({
  required BuildContext context,
  required String id,
  required String title,

  /// Body text of the dialog, if not provided, builder will be used
  String body = '',
  BoxConstraints? constraints,

  /// Builder for the dialog content, if not provided, defaults to a Text widget
  Widget Function(BuildContext)? builder,
  String positiveButtonText = 'OK',
  String negativeButtonText = 'Cancel',
  bool isPositiveButtonPrimary = false,
  bool hideTitle = false,
  bool tickboxValue = false,

  /// Callback when the tickbox value changes
  ValueChanged<bool>? onTickboxChanged,
  String tickboxLabel = 'Do not show this again',

  /// Optional custom title widget, overrides the title string if provided
  Widget? titleWidget,

  /// Callback for the positive button, automatically closes the dialog
  Function(bool tickboxValue)? onPositive,

  /// Callback for the negative button, automatically closes the dialog
  Function()? onNegative,
}) async {
  assert(
    body.isNotEmpty || builder != null,
    'Either body or builder must be provided for the dialog content',
  );
  bool localTickboxValue = tickboxValue;
  return showManagedDialog(
    context: context,
    id: id,
    title: title,
    dialogDoPopCheck: () => true,
    builder: (context) {
      return ManagedDialog(
        popContext: context,
        title: hideTitle ? null : titleWidget ?? Text(title, style: Manager.subtitleStyle),
        contentBuilder: (context, __) => Column(mainAxisSize: MainAxisSize.min, children: [
          builder != null ? builder(context) : Text(body, style: Manager.bodyStyle),
          const SizedBox(height: 24),
          StatefulBuilder(builder: (context, setState) {
            return Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 20,
                child: Checkbox(
                  checked: localTickboxValue,
                  onChanged: (value) {
                    if (value != null) {
                      onTickboxChanged?.call(value);
                      setState(() {
                        localTickboxValue = value;
                      });
                    }
                  },
                  content: Text(tickboxLabel, style: Manager.bodyStyle),
                ),
              ),
            );
          }),
        ]),
        constraints: constraints ??
            const BoxConstraints(
              maxWidth: 500,
              minWidth: 300,
            ),
        actions: (popContext) => [
          ManagedDialogButton(
            popContext: popContext,
            text: negativeButtonText,
            onPressed: () => onNegative?.call(),
          ),
          ManagedDialogButton(
            isPrimary: isPositiveButtonPrimary,
            popContext: popContext,
            text: positiveButtonText,
            onPressed: () => onPositive?.call(localTickboxValue),
          ),
        ],
      );
    },
  );
}

Future<T?> showSimpleOneButtonManagedDialog<T>({
  required BuildContext context,
  required String id,
  required String title,
  String? body,
  Widget Function(BuildContext)? builder,
  BoxConstraints? constraints,
  String positiveButtonText = 'OK',

  /// Callback for the positive button, automatically closes the dialog
  Function()? onPositive,
}) async {
  assert(
    (body == null && builder != null) || (body != null && builder == null),
    'Only one of body or builder should be provided',
  );
  return showManagedDialog(
    context: context,
    id: id,
    title: title,
    dialogDoPopCheck: () => true,
    builder: (context) {
      return ManagedDialog(
        popContext: context,
        title: Text(title),
        contentBuilder: (context, __) => builder != null ? builder(context) : Text(body!),
        constraints: constraints ??
            const BoxConstraints(
              maxWidth: 500,
              minWidth: 300,
            ),
        actions: (popContext) => [
          ManagedDialogButton(
            popContext: popContext,
            text: positiveButtonText,
            onPressed: () => onPositive?.call(),
          ),
        ],
      );
    },
  );
}

void kEmptyVoidCallBack() {}

class ManagedDialogButton extends StatelessWidget {
  /// Callback to be executed when the button is pressed, the closing of the dialog is handled by the widget itself
  final VoidCallback? onPressed;
  final String text;
  final BuildContext popContext;
  final bool isPrimary;

  const ManagedDialogButton({
    super.key,
    this.onPressed = kEmptyVoidCallBack,
    this.text = 'Cancel',
    this.isPrimary = false,
    required this.popContext,
  });

  @override
  Widget build(BuildContext context) {
    finalOnPressed() async {
      // Callbacks
      onPressed?.call();

      // Close the dialog
      closeDialog(popContext);
    }

    return MouseButtonWrapper(
      child: (_) => Builder(builder: (context) {
        if (isPrimary)
          return FilledButton(
            style: FluentTheme.of(context).buttonTheme.filledButtonStyle,
            onPressed: onPressed != null ? finalOnPressed : null,
            child: Text(text),
          );
        return Button(
          onPressed: onPressed != null ? finalOnPressed : null,
          child: Text(text),
        );
      }),
    );
  }
}

void closeDialog<T>(BuildContext popContext, {T? result}) {
  final navManager = Provider.of<NavigationManager>(popContext, listen: false);

  // First check if Flutter's Navigator has a dialog to pop
  if (Navigator.of(popContext, rootNavigator: true).canPop() && navManager.hasDialog) {
    // Update custom navigation stack if needed
    navManager.popDialog();

    // Pop the actual dialog
    Navigator.of(popContext, rootNavigator: true).pop(result);
  } else {
    logWarn('No dialog to pop in Flutter Navigator');
  }
}

class ManagedDialog extends StatefulWidget {
  final Widget? title;
  final Widget Function(BuildContext, BoxConstraints)? contentBuilder;
  final List<Widget> Function(dynamic)? actions;
  final BoxConstraints constraints;
  final Alignment alignment;
  final ContentDialogThemeData? theme;
  final BuildContext popContext;

  const ManagedDialog({
    super.key,
    required this.title,
    required this.popContext,
    this.contentBuilder,
    this.actions,
    this.constraints = const BoxConstraints(maxWidth: 500, minWidth: 300),
    this.theme,
    this.alignment = Alignment.center,
  });

  @override
  State<ManagedDialog> createState() => ManagedDialogState();
}

class ManagedDialogState extends State<ManagedDialog> {
  late BoxConstraints _currentConstraints;
  late Alignment alignment;

  @override
  void initState() {
    super.initState();
    _currentConstraints = widget.constraints;
    alignment = widget.alignment;
  }

  // Method to resize the dialog
  void resizeDialog({double? width, double? height, BoxConstraints? constraints}) {
    setState(() {
      if (constraints != null) {
        _currentConstraints = constraints;
      } else {
        _currentConstraints = BoxConstraints(
          minWidth: width ?? _currentConstraints.minWidth,
          maxWidth: width ?? _currentConstraints.maxWidth,
          minHeight: height ?? _currentConstraints.minHeight,
          maxHeight: height ?? _currentConstraints.maxHeight,
        );
      }
    });
  }

  /// Position the dialog on screen
  void positionDialog(Alignment alignment) {
    setState(() {
      this.alignment = alignment;
    });
  }

  Positioned AlignmentWidget({required Widget child}) {
    return switch (alignment) {
      Alignment.topLeft => Positioned(
          top: 0,
          left: 0,
          child: child,
        ),
      Alignment.topCenter => Positioned(
          top: 0,
          child: child,
        ),
      Alignment.topRight => Positioned(
          top: 0,
          right: 0,
          child: child,
        ),
      Alignment.centerRight => Positioned(
          right: 0,
          child: child,
        ),
      Alignment.bottomRight => Positioned(
          bottom: 0,
          right: 0,
          child: child,
        ),
      Alignment.bottomCenter => Positioned(
          bottom: 0,
          child: child,
        ),
      Alignment.bottomLeft => Positioned(
          bottom: 0,
          left: 0,
          child: child,
        ),
      Alignment.centerLeft => Positioned(
          left: 0,
          child: child,
        ),
      _ => Positioned(
          child: child,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AlignmentWidget(
          child: Padding(
            padding: const EdgeInsets.only(top: ScreenUtils.kTitleBarHeight - 5),
            child: ContentDialog(
              style: widget.theme,
              title: widget.title,
              content: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: _currentConstraints,
                  child: widget.contentBuilder != null ? widget.contentBuilder!(context, _currentConstraints) : null,
                ),
              ),
              // ignore: prefer_null_aware_operators
              actions: widget.actions != null ? widget.actions!.call(widget.popContext) : null,
              constraints: _currentConstraints,
            ),
          ),
        ),
      ],
    );
  }

  void popDialog() => closeDialog(widget.popContext);
}

class NotificationManagedDialogState extends State<ManagedDialog> {
  late BoxConstraints _currentConstraints;
  late Alignment alignment;

  @override
  void initState() {
    super.initState();
    _currentConstraints = widget.constraints;
    alignment = widget.alignment;
  }

  // Method to resize the dialog
  void resizeDialog({double? width, double? height, BoxConstraints? constraints}) {
    setState(() {
      if (constraints != null) {
        _currentConstraints = constraints;
      } else {
        _currentConstraints = BoxConstraints(
          minWidth: width ?? _currentConstraints.minWidth,
          maxWidth: width ?? _currentConstraints.maxWidth,
          minHeight: height ?? _currentConstraints.minHeight,
          maxHeight: height ?? _currentConstraints.maxHeight,
        );
      }
    });
  }

  /// Position the dialog on screen
  void positionDialog(Alignment alignment) {
    setState(() {
      this.alignment = alignment;
    });
  }

  Positioned AlignmentWidget({required Widget child}) {
    return switch (alignment) {
      Alignment.topLeft => Positioned(
          top: 0,
          left: 0,
          child: child,
        ),
      Alignment.topCenter => Positioned(
          top: 0,
          child: child,
        ),
      Alignment.topRight => Positioned(
          top: 0,
          right: 0,
          child: child,
        ),
      Alignment.centerRight => Positioned(
          right: 0,
          child: child,
        ),
      Alignment.bottomRight => Positioned(
          bottom: 0,
          right: 0,
          child: child,
        ),
      Alignment.bottomCenter => Positioned(
          bottom: 0,
          child: child,
        ),
      Alignment.bottomLeft => Positioned(
          bottom: 0,
          left: 0,
          child: child,
        ),
      Alignment.centerLeft => Positioned(
          left: 0,
          child: child,
        ),
      _ => Positioned(
          child: child,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: alignment,
      children: [
        AlignmentWidget(
          child: Padding(
            padding: const EdgeInsets.only(top: ScreenUtils.kTitleBarHeight + 16, right: 16, bottom: 16),
            child: GlossyContainer(
              width: _currentConstraints.maxWidth,
              height: _currentConstraints.maxHeight,
              color: Colors.black,
              opacity: 0.4,
              strengthX: 20,
              strengthY: 20,
              blendMode: BlendMode.src,
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  FrostedNoise(
                    intensity: 0.7,
                    child: ContentDialog(
                      style: ContentDialogThemeData(decoration: BoxDecoration(color: Colors.transparent)),
                      title: widget.title,
                      content: Material(
                        color: Colors.transparent,
                        child: Container(
                          constraints: _currentConstraints,
                          child: widget.contentBuilder != null ? widget.contentBuilder!(context, _currentConstraints) : null,
                        ),
                      ),
                      // ignore: prefer_null_aware_operators
                      actions: widget.actions != null ? widget.actions!.call(widget.popContext) : null,
                      constraints: _currentConstraints,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void popDialog() => closeDialog(widget.popContext);
}

extension ManagedDialogExtensions on BuildContext {
  // Helper to access the dialog state from child widgets
  ManagedDialogState? get managedDialogState => findAncestorStateOfType<ManagedDialogState>();

  // Helper to resize the dialog
  void resizeManagedDialog({double? width, double? height, BoxConstraints? constraints}) {
    final state = managedDialogState;
    if (state != null) //
      state.resizeDialog(width: width, height: height, constraints: constraints);
  }

  void positionManagedDialog(Alignment alignment) {
    final state = managedDialogState;
    if (state != null) //
      state.positionDialog(alignment);
  }
}

void showDebugDialog(BuildContext context) {
  showManagedDialog(
    context: context,
    id: 'history:debug',
    title: 'Debug History',
    dialogDoPopCheck: () => true,
    builder: (context) => ManagedDialog(
      popContext: context,
      theme: ContentDialogThemeData(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      actions: (popContext) => [
        ManagedDialogButton(
          popContext: popContext,
          text: 'Close History Debug',
        )
      ],
      contentBuilder: (_, __) => const NavigationHistoryDebug(),
      title: Text('Debug History'),
    ),
  );
}
