import 'package:fluent_ui/fluent_ui.dart';

import 'package:flutter/material.dart' show Material;

import '../../utils/time_utils.dart';

class ContextMenuOverlay extends StatefulWidget {
  final Widget child;
  final List<ContextMenuItemData> items;
  final bool Function()? onBeforeShow;
  final VoidCallback? onTap;

  static _ContextMenuOverlayState? _currentOpenMenu;

  const ContextMenuOverlay({
    super.key,
    required this.child,
    required this.items,
    this.onBeforeShow,
    this.onTap,
  });

  @override
  State<ContextMenuOverlay> createState() => _ContextMenuOverlayState();

  static void closeAnyOpenMenu() {
    _currentOpenMenu?._removeOverlay();
    _currentOpenMenu = null;
  }
}

class _ContextMenuOverlayState extends State<ContextMenuOverlay> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;

  @override
  void dispose() {
    _removeOverlay();
    // Clear static reference if this instance is being disposed
    if (ContextMenuOverlay._currentOpenMenu == this) {
      ContextMenuOverlay._currentOpenMenu = null;
    }
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isMenuOpen = false;

    // Clear the static reference when this menu is closed
    if (ContextMenuOverlay._currentOpenMenu == this) {
      ContextMenuOverlay._currentOpenMenu = null;
    }
  }

  void _showContextMenu(BuildContext context, Offset position) {
    // Check if we should show the menu
    if (widget.onBeforeShow != null && !widget.onBeforeShow!()) //
      return;

    ContextMenuOverlay.closeAnyOpenMenu();

    ContextMenuOverlay._currentOpenMenu = this;
    _isMenuOpen = true;

    // Create the overlay
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Invisible fullscreen button to dismiss
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _removeOverlay,
              onSecondaryTap: () => _removeOverlay(),
              child: Container(color: Colors.transparent),
            ),
          ),
          // The actual menu
          Positioned(
            left: position.dx,
            top: position.dy,
            child: Material(
              elevation: 4.0,
              child: FlyoutContent(
                color: FluentTheme.of(context).resources.cardBackgroundFillColorDefault,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.items.map((item) {
                    return _buildMenuItem(context, item);
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildMenuItem(BuildContext context, ContextMenuItemData item) {
    if (item.isDivider) return Divider();

    return HoverButton(
      onPressed: () async {
        _removeOverlay();
        nextFrame(() => item.onPressed?.call());
      },
      builder: (context, states) {
        return Container(
          width: 200,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          color: states.isHovering ? FluentTheme.of(context).resources.controlFillColorSecondary : Colors.transparent,
          child: Row(
            children: [
              if (item.icon != null) ...[
                Icon(item.icon, size: 16),
                SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  item.label,
                  style: FluentTheme.of(context).typography.body,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onSecondaryTapDown: (details) {
          _showContextMenu(context, details.globalPosition);
        },
        onTap: () {
          // If there's any menu open, close it
          if (ContextMenuOverlay._currentOpenMenu != null) {
            ContextMenuOverlay.closeAnyOpenMenu();

            // If this is the series card that was clicked, call the onTap handler
            if (widget.onTap != null) {
              widget.onTap!();
            }
          } else if (widget.onTap != null) {
            // No menu open, just call the onTap handler
            widget.onTap!();
          }
        },
        child: widget.child,
      ),
    );
  }
}

class ContextMenuItemData {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isDivider;

  const ContextMenuItemData({
    required this.label,
    this.icon,
    this.onPressed,
    this.isDivider = false,
  });

  static ContextMenuItemData divider() {
    return const ContextMenuItemData(label: '', isDivider: true);
  }
}
