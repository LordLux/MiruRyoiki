import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_desktop_context_menu/flutter_desktop_context_menu.dart';

/// A controller for managing desktop context menu interactions.
///
/// Provides an API for opening context menus
///
/// Example usage:
/// ```dart
/// class _MyWidgetState extends State<MyWidget> {
///   late final DesktopContextMenuController _menuController;
///
///   @override
///   void initState() {
///     super.initState();
///     _menuController = DesktopContextMenuController();
///   }
///
///   @override
///   void dispose() {
///     _menuController.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return MyContextMenu(
///       controller: _menuController,
///       child: GestureDetector(
///         onSecondaryTap: _menuController.open,
///         child: MyContent(),
///       ),
///     );
///   }
/// }
/// ```
class DesktopContextMenuController extends ChangeNotifier {
  VoidCallback? _openCallback; // Callback to open the menu
  void Function(Offset?, Placement)? _openAtCallback; // Callback to open at specific position
  Object? _attachedWidget;  // Track which widget is currently attached

  /// Whether this controller is attached to a context menu widget.
  bool get isAttached => _openCallback != null;

  /// Opens the context menu at the default position (bottom-right).
  ///
  /// Returns true if the menu was opened successfully, false if not attached.
  bool open() {
    if (_openCallback != null) {
      _openCallback!();
      return true;
    }
    return false;
  }

  /// Opens the context menu at a specific position with a specific placement.
  ///
  /// - [position]: Optional screen coordinates where the menu should appear.
  ///   If null, uses the default cursor position.
  /// - [placement]: The placement strategy for the menu (default: bottomRight).
  ///
  /// Returns true if the menu was opened successfully, false if not attached.
  bool openAt({Offset? position, Placement placement = Placement.bottomRight}) {
    if (_openAtCallback != null) {
      _openAtCallback!(position, placement);
      return true;
    }
    return false;
  }

  void attach(VoidCallback openCallback, void Function(Offset?, Placement) openAtCallback, Object attachedWidget) {
    _openCallback = openCallback;
    _openAtCallback = openAtCallback;
    _attachedWidget = attachedWidget;
  }

  void detach(Object attachedWidget) {
    // Only detach if this is the widget that's currently attached
    if (_attachedWidget == attachedWidget) {
      _openCallback = null;
      _openAtCallback = null;
      _attachedWidget = null;
    }
  }

  @override
  void dispose() {
    _openCallback = null;
    _openAtCallback = null;
    super.dispose();
  }
}
