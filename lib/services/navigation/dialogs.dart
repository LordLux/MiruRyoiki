import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show MaterialState;

import '../../manager.dart';
import '../../widgets/buttons/wrapper.dart';
import '../../widgets/dialogs/show_dialog.dart';
import 'debug.dart';
import 'dialogs2.dart';
import 'navigation.dart';

bool kReturnTrueCallback() => true;

/// Core managed dialog function. All simple dialog variants delegate to this.
Future showManagedDialog(
  BuildContext context, {
  required String id,
  required String title,
  String body = '',
  Widget Function(BuildContext)? builder,
  BoxConstraints? constraints,
  bool hideTitle = false,
  Widget? titleWidget,
  bool Function()? dialogDoPopCheck,
  ContentDialogThemeData? theme,
  Object? data,
  VoidCallback? onDismiss,
  List<PaddedDialogButton> buttons = const [],
}) async {
  assert(body.isNotEmpty || builder != null, 'Either body or builder must be provided for the dialog content');

  return showPaddedDialog(
    context,
    navigationItem: DialogNavigationItem(
      id: id,
      title: title,
      data: data,
      dialogDoPopCheck: dialogDoPopCheck,
      onDismiss: onDismiss,
    ),
    builder: (context, item, options) {
      return PaddedDialog.simple(
        navigationItem: item,
        barrierOptions: options,
        theme: theme,
        title: hideTitle ? null : titleWidget ?? Text(title),
        content: builder != null ? builder(context) : Text(body, style: Manager.bodyStyle),
        constraints: constraints,
        actions: buttons,
      );
    },
  );
}

/// Two-button dialog (Cancel + OK).
Future showSimpleManagedDialog(
  BuildContext context, {
  required String id,
  required String title,
  String body = '',
  Widget Function(BuildContext)? builder,
  BoxConstraints? constraints,
  String positiveButtonText = 'OK',
  String negativeButtonText = 'Cancel',
  bool isPositiveButtonPrimary = false,
  bool hideTitle = false,
  Widget? titleWidget,
  Function()? onPositive,
  Function()? onNegative,
  bool Function()? dialogDoPopCheck,
  ContentDialogThemeData? theme,
  Object? data,
}) {
  return showManagedDialog(
    context,
    id: id,
    title: title,
    body: body,
    builder: builder,
    constraints: constraints,
    hideTitle: hideTitle,
    titleWidget: titleWidget,
    dialogDoPopCheck: dialogDoPopCheck,
    theme: theme,
    data: data,
    buttons: [
      PaddedDialogButton(text: negativeButtonText, onPressed: () => onNegative?.call()),
      PaddedDialogButton(isPrimary: isPositiveButtonPrimary, text: positiveButtonText, onPressed: () => onPositive?.call()),
    ],
  );
}

/// Two-button dialog with a tickbox (e.g. "Do not show again").
Future showSimpleTickboxManagedDialog(
  BuildContext context, {
  required String id,
  required String title,
  String body = '',
  Widget Function(BuildContext)? builder,
  BoxConstraints? constraints,
  String positiveButtonText = 'OK',
  String negativeButtonText = 'Cancel',
  bool isPositiveButtonPrimary = false,
  bool hideTitle = false,
  Widget? titleWidget,
  Function(bool)? onPositive,
  Function(bool)? onNegative,
  bool Function()? dialogDoPopCheck,
  ContentDialogThemeData? theme,
  Object? data,
  ValueChanged<bool>? onTickboxChanged,
  String tickboxLabel = 'Do not show this again',
  bool tickboxValue = false,
}) async {
  assert(body.isNotEmpty || builder != null, 'Either body or builder must be provided for the dialog content');

  bool localTickboxValue = tickboxValue;
  return showManagedDialog(
    context,
    id: id,
    title: title,
    body: body,
    hideTitle: hideTitle,
    titleWidget: titleWidget ?? Text(title, style: Manager.subtitleStyle),
    dialogDoPopCheck: dialogDoPopCheck,
    theme: theme,
    data: data,
    constraints: constraints ?? const BoxConstraints(maxWidth: 500, minWidth: 300),
    builder: (context) {
      final content = builder != null ? builder(context) : Text(body, style: Manager.bodyStyle);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
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
                      setState(() => localTickboxValue = value);
                    }
                  },
                  content: Text(tickboxLabel, style: Manager.bodyStyle),
                ),
              ),
            );
          }),
        ],
      );
    },
    buttons: [
      PaddedDialogButton(text: negativeButtonText, onPressed: () => onNegative?.call(localTickboxValue)),
      PaddedDialogButton(isPrimary: isPositiveButtonPrimary, text: positiveButtonText, onPressed: () => onPositive?.call(localTickboxValue)),
    ],
  );
}

/// Single-button dialog (OK only).
Future showSimpleOneButtonManagedDialog(
  BuildContext context, {
  required String id,
  required String title,
  String body = '',
  Widget Function(BuildContext)? builder,
  BoxConstraints? constraints,
  String positiveButtonText = 'OK',
  bool isPositiveButtonPrimary = false,
  bool hideTitle = false,
  Widget? titleWidget,
  Function()? onPositive,
  bool Function()? dialogDoPopCheck,
  ContentDialogThemeData? theme,
  Object? data,
}) {
  return showManagedDialog(
    context,
    id: id,
    title: title,
    body: body,
    builder: builder,
    constraints: constraints,
    hideTitle: hideTitle,
    titleWidget: titleWidget,
    dialogDoPopCheck: dialogDoPopCheck,
    theme: theme,
    data: data,
    buttons: [
      PaddedDialogButton(isPrimary: isPositiveButtonPrimary, text: positiveButtonText, onPressed: () => onPositive?.call()),
    ],
  );
}

/// No-button dialog (content only, dismissible via barrier/Esc).
Future showSimpleNoButtonManagedDialog(
  BuildContext context, {
  required String id,
  required String title,
  String body = '',
  Widget Function(BuildContext)? builder,
  BoxConstraints? constraints,
  bool hideTitle = false,
  Widget? titleWidget,
  bool Function()? dialogDoPopCheck,
  Object? data,
}) {
  return showManagedDialog(
    context,
    id: id,
    title: title,
    body: body,
    builder: builder,
    constraints: constraints,
    hideTitle: hideTitle,
    titleWidget: titleWidget,
    dialogDoPopCheck: dialogDoPopCheck,
    data: data,
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

  void positionManagedDialog(Alignment alignment) {
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
