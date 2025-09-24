
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;

import '../manager.dart';

Widget _defaultContentBuilder(BuildContext context, Widget child) => child;

class NotificationListTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final String timestamp;
  final Widget Function(BuildContext, Widget) contentBuilder;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isRead;
  final bool lowOpacity;

  const NotificationListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.leading,
    this.contentBuilder = _defaultContentBuilder,
    this.trailing,
    this.onTap,
    this.isRead = false,
    this.lowOpacity = false,
  });

  @override
  State<NotificationListTile> createState() => _NotificationListTileState();
}

class _NotificationListTileState extends State<NotificationListTile> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80 * Manager.fontSizeMultiplier,
      child: Opacity(
        opacity: widget.lowOpacity ? 0.7 : 1.0,
        child: mat.Material(
          color: widget.isRead ? Colors.transparent : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: MouseRegion(
            cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
            child: mat.InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Leading
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: widget.leading,
                    ),
                    SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
                      child: widget.contentBuilder(
                        context,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.title,
                              style: Manager.smallSubtitleStyle.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.subtitle,
                                  style: Manager.bodyStyle.copyWith(color: Manager.accentColor.lightest),
                                ),
                                Text(
                                  widget.timestamp,
                                  style: Manager.miniBodyStyle.copyWith(color: Colors.white.withOpacity(.5)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Spacer(),
                    if (widget.trailing != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: widget.trailing!,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
