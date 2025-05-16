import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Material;
import 'package:miruryoiki/main.dart';
import 'package:provider/provider.dart';
import '../../utils/logging.dart';
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
            logDebug('Custom navigation stack pop');
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
    barrierDismissCheck: () => true,
    enableBarrierDismiss: true,
    builder: (context) {
      return ManagedDialog(
        popContext: context,
        title: Text(title),
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
            onPressed: () {
              onNegative?.call();
            },
          ),
          ManagedDialogButton(
            isPrimary: isPositiveButtonPrimary,
            popContext: popContext,
            text: positiveButtonText,
            onPressed: () {
              onPositive?.call();
            },
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
  required String body,
  BoxConstraints? constraints,
  String positiveButtonText = 'OK',

  /// Callback for the positive button, automatically closes the dialog
  Function()? onPositive,
}) async =>
    showManagedDialog(
      context: context,
      id: id,
      title: title,
      barrierDismissCheck: () => true,
      enableBarrierDismiss: true,
      builder: (context) {
        return ManagedDialog(
          popContext: context,
          title: Text(title),
          contentBuilder: (_, __) => Text(body),
          constraints: constraints ??
              const BoxConstraints(
                maxWidth: 500,
                minWidth: 300,
              ),
          actions: (popContext) => [
            ManagedDialogButton(
              popContext: popContext,
              text: positiveButtonText,
              onPressed: () {
                onPositive?.call();
              },
            ),
          ],
        );
      },
    );

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
          logTrace('Barrier dismiss check: ${barrierDismissCheck!() ? "Popped!" : "Not popped"}');

          if (barrierDismissCheck!()) {
            onBarrierTap();
            return true; // Allow the barrier to dismiss
          }
          return false; // Prevent the barrier from dismissing
        }
        logTrace('No barrier dismiss check provided, allowing pop');
        // Default behavior: allow the barrier to dismiss
        return true;
      },
      child: child,
    );
  }
}

class ManagedDialogButton extends StatelessWidget {
  /// Callback to be executed when the button is pressed, the closing of the dialog is handled by the widget itself
  final VoidCallback? onPressed;
  final String text;
  final BuildContext popContext;
  final bool isPrimary;

  const ManagedDialogButton({
    super.key,
    this.onPressed,
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
      closeDialog(popContext);
    }

    if (isPrimary)
      return FilledButton(
        style: FluentTheme.of(context).buttonTheme.filledButtonStyle,
        onPressed: finalOnPressed,
        child: Text(text),
      );

    return Button(
      onPressed: finalOnPressed,
      child: Text(text),
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
    logDebug('No dialog to pop in Flutter Navigator');
  }
}

class ManagedDialog extends StatefulWidget {
  final Widget title;
  final Widget Function(BuildContext, BoxConstraints)? contentBuilder;
  final List<Widget> Function(dynamic)? actions;
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
    return ContentDialog(
      style: widget.theme,
      title: widget.title,
      content: Material(
        color: Colors.transparent,
        child: Container(
          constraints: _currentConstraints,
          child: widget.contentBuilder != null ? widget.contentBuilder!(context, _currentConstraints) : null,
        ),
      ),
      actions: widget.actions?.call(widget.popContext),
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
