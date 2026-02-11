// ignore_for_file: unnecessary_this

import 'package:fluent_ui/fluent_ui.dart';

import '../../services/navigation/dialogs2.dart';
import '../../services/navigation/navigation.dart';

/// Calculates the barrier color based on the provided [color] and [exactColor] flag.
///
/// If [exactColor] is true and [color] is not null, returns [color] as is.
/// Otherwise, it calculates a color based on a base black color and the provided [color].
Color getBarrierColor(Color? color, {bool exactColor = false}) {
  if (exactColor && color != null) return color;

  final Color baseColor = const Color(0xFF000000);
  if (color == null) return baseColor.withAlpha(0x84);

  // If no color is provided, use the default barrier color
  return (baseColor.lerpWith(color, .025)).withAlpha(0x84);
}

/// A dialog route with a barrier that supports padding.
///
/// This route is used by [showPaddedDialog] to display dialogs with custom barriers.
class PaddedDialogRoute extends FluentDialogRoute {
  /// Callback when the dialog is dismissed.
  final VoidCallback? onDismiss;

  /// The navigation item associated with this dialog.
  final DialogNavigationItem item;

  /// The barrier options for this dialog.
  final PaddedBarrierOptions options;

  /// Creates a [PaddedDialogRoute].
  PaddedDialogRoute({
    required PaddedDialog Function(BuildContext, DialogNavigationItem, PaddedBarrierOptions) contentBuilder,
    required super.context,
    required this.item,
    PaddedBarrierOptions? options,
    super.themes,
    super.transitionDuration,
    super.transitionBuilder,
    super.barrierLabel,
    super.settings,
  })  : this.options = options ?? const PaddedBarrierOptions(),
        onDismiss = item.onDismiss,
        super(
          dismissWithEsc: false,
          barrierDismissible: options?.userDismissable ?? true,
          barrierColor: getBarrierColor(
            options?.barrierColor,
            exactColor: options?.exactColor ?? false,
          ),
          builder: (BuildContext context) => contentBuilder(
            context,
            item,
            options ?? const PaddedBarrierOptions(),
          ),
        );

  @override
  Widget buildModalBarrier() {
    Widget barrier = ModalBarrier(
      color: Colors.transparent,
      dismissible: barrierDismissible,
      semanticsLabel: barrierLabel,
      barrierSemanticsDismissible: barrierDismissible,
      onDismiss: onDismiss,
    );

    if (!options.transluscentBarrier)
      return Stack(
        children: [
          AnimatedBuilder(
            animation: animation!,
            builder: (context, child) {
              final animValue = animation!.value;
              return Padding(
                padding: options.barrierPadding,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [barrierColor!.withOpacity(.8), barrierColor!, barrierColor!.withOpacity(.0)],
                      stops: [0.0, animValue, animValue + 0.3],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcIn,
                  child: Container(
                    color: Colors.black.withOpacity(barrierColor?.opacity ?? 1),
                    child: child,
                  ),
                ),
              );
            },
          ),
          Padding(
            // Padded area that allows interactions
            padding: options.barrierPadding,
            // ModalBarrier to block interactions
            child: barrier,
          ),
        ],
      );
    return Padding(
      // Padded area that allows interactions
      padding: options.barrierPadding,
      // If translucent, use a Listener to allow interactions to pass through
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) {
          onDismiss?.call();
          closeDialog();
        },
        child: IgnorePointer(
          child: Container(color: barrierColor),
        ),
      ),
    );
  }
}
