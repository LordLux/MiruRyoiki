import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Material, MaterialState;
import 'package:glossy/glossy.dart';

import '../../utils/screen.dart';
import '../../manager.dart';
import '../../widgets/buttons/wrapper.dart';
import '../../widgets/dialogs/show_dialog.dart';
import '../../widgets/frosted_noise.dart';
import 'debug.dart';
import 'dialogs2.dart';
import 'navigation.dart';

bool kReturnTrueCallback() => true;
bool kReturnFalseCallback() => false;

Future showSimpleManagedDialog(
  BuildContext context, {
  /// Unique identifier for the dialog
  required String id,

  /// Title of the dialog
  required String title,

  /// Body text of the dialog, if not provided, builder will be used
  String body = '',

  /// Content builder for the dialog, used if body is not provided
  Widget Function(BuildContext)? builder,

  /// Constraints for the dialog
  BoxConstraints? constraints,

  /// Text to display on the positive button
  String positiveButtonText = 'OK',

  /// Text to display on the negative button
  String negativeButtonText = 'Cancel',

  /// Whether the positive button is styled as primary
  bool isPositiveButtonPrimary = false,

  /// Whether to hide the title of the dialog
  bool hideTitle = false,

  /// Optional custom title widget, overrides the title string if provided
  Widget? titleWidget,

  /// Callback for the positive button, automatically closes the dialog
  Function()? onPositive,

  /// Callback for the negative button, automatically closes the dialog
  Function()? onNegative,

  /// A function that checks whether the dialog can be popped at the moment of non-barrier dismissal
  bool Function()? dialogDoPopCheck,

  /// Theme for the ContentDialog
  ContentDialogThemeData? theme,

  /// Additional data associated with the dialog
  Object? data,
}) async {
  assert(body.isNotEmpty || builder != null, 'Either body or builder must be provided for the dialog content');

  return showPaddedDialog(
    context,
    navigationItem: DialogNavigationItem(
      id: id,
      title: title,
      data: data,
      dialogDoPopCheck: dialogDoPopCheck,
    ),
    builder: (context, item, options) {
      return PaddedDialog.simple(
        navigationItem: item,
        barrierOptions: options,
        theme: theme,
        title: hideTitle ? null : titleWidget ?? Text(title),
        content: builder != null ? builder(context) : Text(body, style: Manager.bodyStyle),
        constraints: constraints,
        actions: [
          ManagedDialogButton(
            text: negativeButtonText,
            onPressed: () => onNegative?.call(),
          ),
          ManagedDialogButton(
            isPrimary: isPositiveButtonPrimary,
            text: positiveButtonText,
            onPressed: () => onPositive?.call(),
          ),
        ],
      );
    },
  );
}

Future showSimpleTickboxManagedDialog(
  BuildContext context, {
  /// Unique identifier for the dialog
  required String id,

  /// Title of the dialog
  required String title,

  /// Body text of the dialog, if not provided, builder will be used
  String body = '',

  /// Content builder for the dialog, used if body is not provided
  Widget Function(BuildContext)? builder,

  /// Constraints for the dialog
  BoxConstraints? constraints,

  /// Text to display on the positive button
  String positiveButtonText = 'OK',

  /// Text to display on the negative button
  String negativeButtonText = 'Cancel',

  /// Whether the positive button is styled as primary
  bool isPositiveButtonPrimary = false,

  /// Whether to hide the title of the dialog
  bool hideTitle = false,

  /// Optional custom title widget, overrides the title string if provided
  Widget? titleWidget,

  /// Callback for the positive button, automatically closes the dialog
  Function(bool)? onPositive,

  /// Callback for the negative button, automatically closes the dialog
  Function(bool)? onNegative,

  /// A function that checks whether the dialog can be popped at the moment of non-barrier dismissal
  bool Function()? dialogDoPopCheck,

  /// Theme for the ContentDialog
  ContentDialogThemeData? theme,

  /// Additional data associated with the dialog
  Object? data,

  /// Callback when the tickbox value changes
  ValueChanged<bool>? onTickboxChanged,

  /// Label for the tickbox
  String tickboxLabel = 'Do not show this again',

  /// Initial value for the tickbox
  bool tickboxValue = false,
}) async {
  assert(body.isNotEmpty || builder != null, 'Either body or builder must be provided for the dialog content');

  bool localTickboxValue = tickboxValue;
  return showPaddedDialog(
    context,
    navigationItem: DialogNavigationItem(
      id: id,
      title: title,
      data: data,
      dialogDoPopCheck: dialogDoPopCheck,
    ),
    builder: (context, item, options) {
      return PaddedDialog.simple(
        navigationItem: item,
        barrierOptions: options,
        theme: theme,
        title: hideTitle ? null : titleWidget ?? Text(title, style: Manager.subtitleStyle),
        content: Expanded(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
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
        ),
        constraints: constraints ?? const BoxConstraints(maxWidth: 500, minWidth: 300),
        actions: [
          ManagedDialogButton(
            text: negativeButtonText,
            onPressed: () => onNegative?.call(localTickboxValue),
          ),
          ManagedDialogButton(
            isPrimary: isPositiveButtonPrimary,
            text: positiveButtonText,
            onPressed: () => onPositive?.call(localTickboxValue),
          ),
        ],
      );
    },
  );
}

Future showSimpleOneButtonManagedDialog(
  BuildContext context, {
  /// Unique identifier for the dialog
  required String id,

  /// Title of the dialog
  required String title,

  /// Body text of the dialog, if not provided, builder will be used
  String body = '',

  /// Content builder for the dialog, used if body is not provided
  Widget Function(BuildContext)? builder,

  /// Constraints for the dialog
  BoxConstraints? constraints,

  /// Text to display on the positive button
  String positiveButtonText = 'OK',

  /// Whether the positive button is styled as primary
  bool isPositiveButtonPrimary = false,

  /// Whether to hide the title of the dialog
  bool hideTitle = false,

  /// Optional custom title widget, overrides the title string if provided
  Widget? titleWidget,

  /// Callback for the positive button, automatically closes the dialog
  Function()? onPositive,

  /// A function that checks whether the dialog can be popped at the moment of non-barrier dismissal
  bool Function()? dialogDoPopCheck,

  /// Theme for the ContentDialog
  ContentDialogThemeData? theme,

  /// Additional data associated with the dialog
  Object? data,
}) async {
  assert(body.isNotEmpty || builder != null, 'Either body or builder must be provided for the dialog content');

  return showPaddedDialog(
    context,
    navigationItem: DialogNavigationItem(
      id: id,
      title: title,
      data: data,
      dialogDoPopCheck: dialogDoPopCheck,
    ),
    builder: (context, item, options) {
      return PaddedDialog.simple(
        navigationItem: item,
        barrierOptions: options,
        theme: theme,
        title: hideTitle ? null : titleWidget ?? Text(title),
        content: builder != null ? builder(context) : Text(body, style: Manager.bodyStyle),
        constraints: constraints,
        actions: [
          ManagedDialogButton(
            isPrimary: isPositiveButtonPrimary,
            text: positiveButtonText,
            onPressed: () => onPositive?.call(),
          ),
        ],
      );
    },
  );
}

Future showSimpleNoButtonManagedDialog(
  BuildContext context, {
  /// Unique identifier for the dialog
  required String id,

  /// Title of the dialog
  required String title,

  /// Body text of the dialog, if not provided, builder will be used
  String body = '',

  /// Content builder for the dialog, used if body is not provided
  Widget Function(BuildContext)? builder,

  /// Constraints for the dialog
  BoxConstraints? constraints,

  /// Whether to hide the title of the dialog
  bool hideTitle = false,

  /// Optional custom title widget, overrides the title string if provided
  Widget? titleWidget,

  /// A function that checks whether the dialog can be popped at the moment of non-barrier dismissal
  bool Function()? dialogDoPopCheck,

  /// Additional data associated with the dialog
  Object? data,
}) async {
  assert(body.isNotEmpty || builder != null, 'Either body or builder must be provided for the dialog content');

  return showPaddedDialog(
    context,
    navigationItem: DialogNavigationItem(
      id: id,
      title: title,
      data: data,
      dialogDoPopCheck: dialogDoPopCheck,
    ),
    builder: (context, item, options) {
      return PaddedDialog.simple(
        navigationItem: item,
        barrierOptions: options,
        title: hideTitle ? null : titleWidget ?? Text(title),
        content: builder != null ? builder(context) : Text(body, style: Manager.bodyStyle),
        constraints: constraints,
        actions: [],
      );
    },
  );
}

void kEmptyVoidCallBack() {}

class ManagedDialogButton extends StatelessWidget {
  /// Callback to be executed when the button is pressed, the closing of the dialog is handled by the widget itself
  final VoidCallback? onPressed;
  final String text;
  final bool isPrimary;
  final bool isDisabled;
  final String? tooltip;
  final bool isLoading;

  const ManagedDialogButton({
    super.key,
    this.onPressed = kEmptyVoidCallBack,
    this.text = 'Cancel',
    this.isPrimary = false,
    this.isDisabled = false,
    this.isLoading = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    finalOnPressed() async {
      // Callbacks
      onPressed?.call();

      // Close the dialog
      closeDialog();
    }

    return MouseButtonWrapper(
      isButtonDisabled: isDisabled,
      isLoading: isLoading,
      tooltip: tooltip,
      child: (_) => Builder(builder: (context) {
        if (isPrimary)
          return FilledButton(
            style: FluentTheme.of(context).buttonTheme.filledButtonStyle?.copyWith(backgroundColor: WidgetStateColor.resolveWith(
              (states) {
                if (states.contains(MaterialState.hovered)) return (Manager.currentDominantColor ?? Manager.accentColor).toAccentColor().light;
                if (states.contains(MaterialState.pressed)) return (Manager.currentDominantColor ?? Manager.accentColor).toAccentColor().lighter;
                return Manager.currentDominantColor ?? Manager.accentColor;
              },
            )),
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
  late BoxConstraints currentConstraints;
  late Alignment alignment;

  @override
  void initState() {
    super.initState();
    currentConstraints = widget.constraints;
    alignment = widget.alignment;
  }

  // Method to resize the dialog
  void resizeDialog({double? width, double? height, BoxConstraints? constraints}) {
    setState(() {
      if (constraints != null) {
        currentConstraints = constraints;
      } else {
        currentConstraints = BoxConstraints(
          minWidth: width ?? currentConstraints.minWidth,
          maxWidth: width ?? currentConstraints.maxWidth,
          minHeight: height ?? currentConstraints.minHeight,
          maxHeight: height ?? currentConstraints.maxHeight,
        );
      }
    });
  }

  /// Position the dialog on screen
  void positionDialog(Alignment alignment) => setState(() => this.alignment = alignment);

  Positioned AlignmentWidget({required Widget child, Positioned? Function({required Widget child})? customPositioning}) {
    if (customPositioning != null) return customPositioning(child: child)!;

    return switch (alignment) {
      Alignment.topLeft => Positioned(top: 0, left: 0, child: child),
      Alignment.topCenter => Positioned(top: 0, child: child),
      Alignment.topRight => Positioned(top: 0, right: 0, child: child),
      Alignment.centerRight => Positioned(right: 0, child: child),
      Alignment.bottomRight => Positioned(bottom: 0, right: 0, child: child),
      Alignment.bottomCenter => Positioned(bottom: 0, child: child),
      Alignment.bottomLeft => Positioned(bottom: 0, left: 0, child: child),
      Alignment.centerLeft => Positioned(left: 0, child: child),
      _ => Positioned(child: child),
    };
  }

  Widget BuildPositionerBuilder({
    required BuildContext context,
    required Widget Function(Widget? customChild) child,
    Positioned? Function({required Widget child})? customPositioning,
  }) {
    return AlignmentWidget(child: child(null), customPositioning: customPositioning);
  }

  Widget buildDialog(BuildContext context, Widget content) {
    return ContentDialog(
      style: widget.theme,
      title: widget.title,
      content: Material(
        color: Colors.transparent,
        child: Container(
          constraints: currentConstraints,
          child: content,
        ),
      ),
      // ignore: prefer_null_aware_operators
      actions: widget.actions != null ? widget.actions!.call(widget.popContext) : null,
      constraints: currentConstraints,
    );
  }

  Widget buildContent(BuildContext context, Widget? customChild) {
    return Padding(
      padding: const EdgeInsets.only(top: ScreenUtils.kTitleBarHeight, right: 16, bottom: 16, left: 16),
      child: buildDialog(
        context,
        customChild ?? (widget.contentBuilder != null ? widget.contentBuilder!(context, currentConstraints) : const SizedBox()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      //TODO maybe see if `alignment` param of stack needs to be set as well
      // alignment: alignment,
      children: [
        BuildPositionerBuilder(
          context: context,
          child: (customChild) => buildContent(context, customChild),
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
  showSimpleOneButtonManagedDialog(
    context,
    id: 'history:debug',
    title: 'Debug History',
    dialogDoPopCheck: () => true,
    theme: ContentDialogThemeData(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    positiveButtonText: 'Close History Debug',
    constraints: BoxConstraints(maxHeight: 1200, maxWidth: 400, minHeight: 300),
    builder: (_) => NavigationHistoryDebug(),
  );
}
