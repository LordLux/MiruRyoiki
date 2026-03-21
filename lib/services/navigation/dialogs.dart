import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Material, MaterialState;

import '../../manager.dart';
import '../../widgets/buttons/wrapper.dart';
import '../../widgets/dialogs/show_dialog.dart';
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
          PaddedDialogButton(
            text: negativeButtonText,
            onPressed: () => onNegative?.call(),
          ),
          PaddedDialogButton(
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
          PaddedDialogButton(
            text: negativeButtonText,
            onPressed: () => onNegative?.call(localTickboxValue),
          ),
          PaddedDialogButton(
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
          PaddedDialogButton(
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

class PaddedDialogButton extends StatelessWidget {
  /// Callback to be executed when the button is pressed, the closing of the dialog is handled by the widget itself
  final VoidCallback? onPressed;
  final String text;
  final bool isPrimary;
  final bool isDisabled;
  final String? tooltip;
  final bool isLoading;
  final bool closeDialogAfterPress;

  const PaddedDialogButton({
    super.key,
    this.onPressed = kEmptyVoidCallBack,
    this.text = 'Cancel',
    this.isPrimary = false,
    this.isDisabled = false,
    this.isLoading = false,
    this.tooltip,
    this.closeDialogAfterPress = true,
  });

  static Widget pair({
    required PaddedDialogButton button1,
    required PaddedDialogButton button2,
    double? width1,
    double? width2,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: width1,
          child: button1,
        ),
        SizedBox(
          width: width2,
          child: button2,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    finalOnPressed() async {
      // Callbacks
      onPressed?.call();

      // Close the dialog
      if (closeDialogAfterPress) closeDialog();
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

extension PaddedDialogExtensions on BuildContext {
  // Helper to access the dialog state from child widgets
  PaddedDialogState? get managedDialogState => findAncestorStateOfType<PaddedDialogState>();

  // Helper to resize the dialog
  void resizeManagedDialog({double? width, double? height, BoxConstraints? constraints}) {
    final state = managedDialogState;

    if (state != null) state.resizeDialog(width: width, height: height, constraints: constraints);
  }

  void positionManagedDialog(Position alignment) {
    final state = managedDialogState;

    if (state != null) state.positionDialog(alignment);
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
