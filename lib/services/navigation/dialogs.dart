import 'package:fluent_ui/fluent_ui.dart' show Button, ContentDialog, ContentDialogThemeData;
import 'package:flutter/material.dart';
import 'package:miruryoiki/main.dart';
import 'package:provider/provider.dart';
import 'debug.dart';
import 'navigation.dart';

/// Helper for managing dialog navigation state
Future<T?> showManagedDialog<T>({
  required BuildContext context,
  required String id,
  required String title,
  required ManagedDialog Function(BuildContext) builder,
  Object? data,
  bool enableBarrierDismiss = false,
  bool Function()? barrierDismissCheck,
}) async {
  final navManager = Provider.of<NavigationManager>(rootNavigatorKey.currentContext!, listen: false);

  // Register in navigation stack
  navManager.pushDialog(id, title, data: data);

  // Show the dialog
  final result = await showDialog<T>(
    context: rootNavigatorKey.currentContext!,
    useRootNavigator: true,
    barrierDismissible: true, // disables esc and click outside to close
    builder: (context) {
      if (enableBarrierDismiss) {
        return _DismissibleWrapper(
          onBarrierTap: () {
            // Update our custom stack but don't pop - Flutter will do that
            print('custom navigation stack pop');
            navManager.popDialog();
          },
          barrierDismissCheck: barrierDismissCheck,
          child: builder(context),
        );
      } else {
        return builder(context);
      }
    },
  );

  return result;
}

// Wrapper that handles barrier dismissal callbacks
class _DismissibleWrapper extends StatelessWidget {
  final VoidCallback onBarrierTap;
  final Widget child;
  final bool Function()? barrierDismissCheck;

  const _DismissibleWrapper({
    required this.onBarrierTap,
    required this.child,
    this.barrierDismissCheck,
  });

  @override
  Widget build(BuildContext context) {
    // Listen for route pop signals
    return WillPopScope(
      onWillPop: () async {
        // Check if we should allow the barrier to dismiss
        if (barrierDismissCheck != null) {
          print('Barrier dismiss check: ${barrierDismissCheck!() ? "Popped!" : "Not popped"}');

          if (barrierDismissCheck!()) {
            onBarrierTap();
            return true; // Allow the barrier to dismiss
          }
          return false; // Prevent the barrier from dismissing
        }
        print('No barrier dismiss check provided, allowing pop');
        // Default behavior: allow the barrier to dismiss
        return true;
      },
      child: child,
    );
  }
}

class ManagedDialogButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final BuildContext popContext;

  const ManagedDialogButton({
    super.key,
    this.onPressed,
    this.text = 'Cancel',
    required this.popContext,
  });

  @override
  Widget build(BuildContext context) {
    return Button(
      child: Text(text),
      onPressed: () async {
        // Callbacks
        onPressed?.call();

        // Close the dialog
        closeDialog(popContext);
        closeDialog(popContext);
      },
    );
  }
}

void closeDialog<T>(BuildContext popContext, {T? result}) {
  final navManager = Provider.of<NavigationManager>(popContext, listen: false);

  // First check if Flutter's Navigator has a dialog to pop
  if (Navigator.of(popContext).canPop() && navManager.hasDialog) {
    // Update custom navigation stack if needed
    navManager.popDialog();

    // Pop the actual dialog
    Navigator.of(popContext).pop(result);
  } else {
    print('No dialog to pop in Flutter Navigator');
  }
}

class ManagedDialog extends StatefulWidget {
  final Widget title;
  final Widget Function(BuildContext, BoxConstraints)? contentBuilder;
  final List<Widget> Function(BuildContext)? actions;
  final BoxConstraints constraints;
  final ContentDialogThemeData? theme;
  final BuildContext popContext;

  const ManagedDialog({
    super.key,
    required this.title,
    this.contentBuilder,
    this.actions,
    this.constraints = const BoxConstraints(maxWidth: 500, minWidth: 300),
    this.theme,
    required this.popContext,
  });

  @override
  State<ManagedDialog> createState() => ManagedDialogState();
}

class ManagedDialogState extends State<ManagedDialog> {
  late BoxConstraints _currentConstraints;

  @override
  void initState() {
    super.initState();
    _currentConstraints = widget.constraints;
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

  @override
  Widget build(BuildContext context) {
    print('${widget.actions?.call(widget.popContext)}');
    return ContentDialog(
      style: widget.theme,
      title: widget.title,
      content: Material(
        color: Colors.transparent,
        child: Container(
          constraints: _currentConstraints,
          // duration: const Duration(milliseconds: 300),
          child: widget.contentBuilder != null ? widget.contentBuilder!(context, _currentConstraints) : null,
        ),
      ),
      actions: widget.actions != null ? widget.actions!.call(widget.popContext) : [ManagedDialogButton(popContext: widget.popContext, text: 'superclass default')],
      constraints: _currentConstraints,
    );
  }
}

// Add this extension to the same file
extension ManagedDialogExtensions on BuildContext {
  // Helper to access the dialog state from child widgets
  ManagedDialogState? get managedDialogState => findAncestorStateOfType<ManagedDialogState>();

  // Helper to resize the dialog
  void resizeManagedDialog({double? width, double? height, BoxConstraints? constraints}) {
    final state = managedDialogState;
    if (state != null) {
      state.resizeDialog(width: width, height: height, constraints: constraints);
    }
  }
}

void showDebugDialog(BuildContext context) {
  showManagedDialog(
    context: context,
    id: 'history:debug',
    title: 'Debug History',
    enableBarrierDismiss: true,
    barrierDismissCheck: () => true,
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
          text: 'debug',
        )
      ],
      contentBuilder: (_, __) => const NavigationHistoryDebug(),
      title: Text('Debug History'),
    ),
  );
}
