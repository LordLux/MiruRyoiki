import 'package:fluent_ui/fluent_ui.dart' show Button, ContentDialog;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigation.dart';

/// Helper for managing dialog navigation state
Future<T?> showManagedDialog<T>({
  required BuildContext context,
  required String id,
  required String title,
  required ManagedDialog Function(BuildContext) builder,
  Object? data,
}) async {
  final navManager = Provider.of<NavigationManager>(context, listen: false);

  // Register in navigation stack
  navManager.pushDialog(id, title, data: data);

  // Show the dialog
  final result = await showDialog<T>(
    context: context,
    builder: builder,
  );

  // Make sure we remove from navigation stack when closed
  if (navManager.currentView?.level == NavigationLevel.dialog) {
    navManager.goBack();
  }

  return result;
}

class ManagedDialogButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Future<VoidCallback>? onPressedWait;
  final String? text;

  const ManagedDialogButton({
    super.key,
    this.onPressed,
    this.onPressedWait,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Button(
      child: Text(onPressed == null ? 'Cancel' : text ?? '/'),
      onPressed: () async {
        // Callbacks
        onPressed?.call();
        if (onPressedWait != null) (await onPressedWait!)();

        // Close the dialog
        closeDialog(context);
      },
    );
  }
}

void closeDialog(BuildContext context) {
  final navManager = Provider.of<NavigationManager>(context, listen: false);
  
  if (!navManager.popDialog()) //
    Navigator.maybePop(context);
}

class ManagedDialog extends StatefulWidget {
  final Widget title;
  final Widget? content;
  final List<ManagedDialogButton> actions;
  final BoxConstraints constraints;

  const ManagedDialog({
    super.key,
    required this.title,
    this.content,
    this.actions = const [ManagedDialogButton()],
    this.constraints = const BoxConstraints(maxWidth: 500, minWidth: 300),
  });

  @override
  State<ManagedDialog> createState() => _ManagedDialogState();
}

class _ManagedDialogState extends State<ManagedDialog> {
  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: widget.title,
      content: widget.content,
      actions: widget.actions,
      constraints: widget.constraints,
    );
  }
}
