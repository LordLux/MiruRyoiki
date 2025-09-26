import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;

import '../manager.dart';
import 'tooltip_wrapper.dart';

Widget _defaultContentBuilder(BuildContext context, Widget child) => child;

class NotificationListTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final String timestamp;
  final Widget Function(BuildContext, Widget) contentBuilder;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isTileColored;
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
    this.isTileColored = false,
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
          color: widget.isTileColored ? Manager.accentColor.lighter.withOpacity(.1) : Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: MouseRegion(
            cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
            child: mat.InkWell(
              borderRadius: BorderRadius.circular(8),
              splashFactory: mat.InkSparkle.constantTurbulenceSeedSplashFactory,
              highlightColor: Manager.accentColor.light.withOpacity(.2), // splash body
              splashColor: Colors.white.withOpacity(.2), // splash crest
              hoverColor: Manager.accentColor.lighter.withOpacity(.2), // hover
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    // Leading
                    if (widget.leading != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: widget.leading!,
                      ),
                    if (widget.leading != null) SizedBox(width: 12),
                    // Content (flexible to shrink when needed)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
                        child: widget.contentBuilder(
                          context,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TooltipWrapper(
                                message: widget.title,
                                child: (message) => Text(
                                  message,
                                  style: Manager.smallSubtitleStyle.copyWith(fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TooltipWrapper(
                                    message: widget.subtitle,
                                    preferBelow: true,
                                    child: (message) => Text(
                                      message,
                                      style: Manager.bodyStyle.copyWith(color: Manager.accentColor.lightest),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  TooltipWrapper(
                                    message: widget.timestamp,
                                    preferBelow: true,
                                    style: TooltipThemeData(preferBelow: true),
                                    child: (message) => Text(
                                      message,
                                      style: Manager.miniBodyStyle.copyWith(color: Colors.white.withOpacity(.5)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Trailing
                    if (widget.trailing != null) ...[
                      SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: widget.trailing!,
                      ),
                    ],
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
