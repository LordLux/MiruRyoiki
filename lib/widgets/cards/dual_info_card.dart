import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import '../../manager.dart';

class DualInfoCard extends StatelessWidget {
  final String nameLeft;
  final String descLeft;
  final String imageLeft;
  final String? nameRight;
  final String? descRight;
  final String? imageRight;
  final VoidCallback? onTap;

  const DualInfoCard({
    super.key,
    required this.nameLeft,
    required this.descLeft,
    required this.imageLeft,
    this.nameRight,
    this.descRight,
    this.imageRight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      decoration: BoxDecoration(
        color: FluentTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // Left Image
          imageLeft.isNotEmpty
              ? CachedNetworkImage(
                  key: ValueKey(imageLeft),
                  imageUrl: imageLeft,
                  width: 60,
                  memCacheHeight: 150,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    width: 60,
                    color: Colors.grey,
                    child: const Center(child: Icon(FluentIcons.error)),
                  ),
                )
              : Container(
                  width: 60,
                  color: Colors.grey,
                  child: const Center(child: Icon(FluentIcons.error)),
                ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  // Left Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          nameLeft,
                          style: Manager.bodyStrongStyle.copyWith(fontSize: 12 * Manager.fontSizeMultiplier),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          descLeft,
                          style: Manager.bodyStyle.copyWith(color: Colors.white.withOpacity(0.7), fontSize: 11 * Manager.fontSizeMultiplier),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Right Info
                  if (nameRight != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            nameRight!,
                            style: Manager.bodyStrongStyle.copyWith(fontSize: 12 * Manager.fontSizeMultiplier),
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (descRight != null)
                            Text(
                              descRight!,
                              style: Manager.bodyStyle.copyWith(color: Colors.white.withOpacity(0.7), fontSize: 11 * Manager.fontSizeMultiplier),
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Right Image
          if (imageRight != null && imageRight!.isNotEmpty)
            CachedNetworkImage(
              key: ValueKey(imageRight),
              imageUrl: imageRight!,
              width: 60,
              memCacheHeight: 150,
              height: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                width: 60,
                color: Colors.grey,
                child: const Center(child: Icon(FluentIcons.error)),
              ),
            ),
        ],
      ),
    );

    if (onTap != null) {
      return mat.InkWell(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: card,
        ),
      );
    }
    return card;
  }
}
