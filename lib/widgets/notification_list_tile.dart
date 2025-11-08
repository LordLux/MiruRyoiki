import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:miruryoiki/enums.dart';

import '../manager.dart';
import 'tooltip.dart' as tp;
import 'tooltip_wrapper.dart';

Widget _defaultContentBuilder(BuildContext context, Widget child) => child;

class NotificationListTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? timestamp;
  final Widget Function(BuildContext, Widget) contentBuilder;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isTileColored;
  final bool lowOpacity;
  final DateTime? subtitleTooltip;
  final bool isRead;

  const NotificationListTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.timestamp,
    this.leading,
    this.contentBuilder = _defaultContentBuilder,
    this.trailing,
    this.onTap,
    this.isTileColored = false,
    this.lowOpacity = false,
    this.subtitleTooltip,
    this.isRead = false,
  });

  @override
  State<NotificationListTile> createState() => _NotificationListTileState();
}

class _NotificationListTileState extends State<NotificationListTile> {
  final color = (Manager.currentDominantColor?.toAccentColor() ?? Manager.accentColor);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (80 - (widget.subtitleTooltip != null ? 10 : 0)) * Manager.fontSizeMultiplier,
      child: Opacity(
        opacity: widget.lowOpacity ? 0.7 : 1.0,
        child: mat.Material(
          color: widget.isTileColored ? color.lighter.withOpacity(.1) : Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: MouseRegion(
            cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
            child: mat.InkWell(
              borderRadius: BorderRadius.circular(8),
              splashFactory: mat.InkSparkle.constantTurbulenceSeedSplashFactory,
              highlightColor: color.light.withOpacity(.2), // splash body
              splashColor: Colors.white.withOpacity(.2), // splash crest
              hoverColor: color.lighter.withOpacity(.2), // hover
              onTap: widget.onTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
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
                                Padding(
                                  padding: EdgeInsets.only(top: widget.timestamp != null ? 0 : 3.0),
                                  child: TooltipWrapper(
                                    tooltip: widget.title,
                                    child: (message) => Text(
                                      message,
                                      style: widget.subtitleTooltip != null ? Manager.smallSubtitleStyle.copyWith(fontWeight: FontWeight.w400) : Manager.smallSubtitleStyle.copyWith(fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TooltipWrapper(
                                      tooltip: widget.subtitleTooltip != null ? widget.subtitleTooltip!.pretty(time: true) : widget.subtitle,
                                      preferBelow: true,
                                      child: (_) => Text(
                                        widget.subtitle,
                                        style: Manager.bodyStyle.copyWith(color: widget.isRead ? Colors.white.withOpacity(.7) : color.lightest),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (widget.timestamp != null)
                                      TooltipWrapper(
                                        tooltip: widget.timestamp,
                                        preferBelow: true,
                                        style: tp.TooltipThemeData(preferBelow: true),
                                        child: (message) => Text(
                                          message,
                                          style: Manager.miniBodyStyle.copyWith(color: Colors.white.withOpacity(.5)),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    else
                                      SizedBox(height: 4), // bottom padding
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
      ),
    );
  }
}
