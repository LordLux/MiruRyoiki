import 'package:fluent_ui/fluent_ui.dart' hide Colors, IconButton;
import 'package:flutter/material.dart' hide TextBox, Slider, BackButton;
import 'package:glossy/glossy.dart';
import 'package:miruryoiki/enums.dart';
import 'package:miruryoiki/models/anilist/anime.dart';
import 'package:miruryoiki/screens/search.dart';
import 'package:miruryoiki/widgets/buttons/wrapper.dart';
import 'package:miruryoiki/widgets/frosted_noise.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:recase/recase.dart';

import '../manager.dart';
import '../utils/color.dart';
import '../utils/time.dart';

class Top100List extends StatefulWidget {
  final SectionDataManager manager;
  final Function(AnilistAnime) onSeriesOpen;
  final VoidCallback? onExpand;

  const Top100List({
    super.key,
    required this.manager,
    required this.onSeriesOpen,
    this.onExpand,
  });

  @override
  State<Top100List> createState() => _Top100ListState();
}

class _Top100ListState extends State<Top100List> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.manager,
      builder: (context, child) {
        final displayItems = widget.manager.items;

        if (displayItems.isEmpty && widget.manager.isLoading) return const SizedBox(height: 200, child: Center(child: ProgressRing()));
        if (displayItems.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOP 100 ANIME',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (widget.onExpand != null)
                    GestureDetector(
                      onTap: widget.onExpand,
                      child: const Text("View All", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayItems.length,
              itemBuilder: (context, index) {
                final anime = displayItems[index];
                return _buildItem(anime, index + 1);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildItem(AnilistAnime anime, int rank) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: MouseButtonWrapper(
        cursor: SystemMouseCursors.click,
        child: (isHovering) {
          final col = isHovering ? anime.dominantColor?.fromHex() ?? Colors.white : Colors.white;
          return GestureDetector(
            onTap: () => widget.onSeriesOpen(anime),
            child: AnimatedContainer(
              duration: dimDuration,
              decoration: BoxDecoration(
                color: col.withOpacity(.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: col.withOpacity(0.1), width: 1.5),
              ),
              child: GlossyContainer(
                height: 100,
                width: double.infinity,
                borderRadius: BorderRadius.circular(12),
                strengthX: 20,
                strengthY: 20,
                color: Colors.transparent,
                opacity: 0.1,
                child: FrostedNoise(
                  intensity: 0.5,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Rank
                        SizedBox(
                          width: 40,
                          child: Padding(
                            padding: EdgeInsets.only(left: rank == 10 ? 2.0 : 8.0),
                            child: Text(
                              '#$rank',
                              style: TextStyle(
                                color: (anime.dominantColor?.fromHex())?.lighten(0.2) ?? Colors.grey,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Poster
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: AspectRatio(
                            aspectRatio: 2 / 3,
                            child: FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image: anime.posterImage ?? '',
                              fit: BoxFit.cover,
                              imageErrorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[800]),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Title and Genres
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                anime.title.userPreferred ?? 'Unknown Title',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: anime.genres
                                    .take(3)
                                    .map((genre) => _buildGenreChip(
                                          genre,
                                          col,
                                          getTextColor(
                                            col,
                                            lightColor: lighten(col, 0.8),
                                            darkColor: darken(col, 0.5),
                                            preferBlack: 0.9,
                                            preferWhite: 0.1,
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        // Stats Columns
                        Expanded(
                          flex: 4,
                          child: Row(
                            children: [
                              // Score
                              Expanded(
                                child: _buildInfoColumn(
                                  top: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(FluentIcons.emoji, size: 16, color: Color(0xFF4CAF50)),
                                      const SizedBox(width: 4),
                                      Text('${anime.averageScore ?? 0}%', style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  bottom: '${anime.popularity ?? 0} users',
                                ),
                              ),
                              // Format
                              Expanded(
                                child: _buildInfoColumn(
                                  top: Text(anime.format?.replaceAll('_', ' ') ?? 'TV Show', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  bottom: '${anime.episodes ?? '?'} episodes',
                                ),
                              ),
                              // Season/Status
                              Expanded(
                                child: _buildInfoColumn(
                                  top: Text('${anime.season ?? ''} ${anime.seasonYear ?? ''}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  bottom: anime.status?.toAnimeStatus()?.name_ ?? 'Finished',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGenreChip(String label, Color bgColor, Color labelColor) {
    return AnimatedContainer(
      duration: dimDuration,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: lighten(bgColor)),
      ),
      child: Transform.translate(
        offset: const Offset(0, -0.9),
        child: Text(
          label.toLowerCase(),
          style: Manager.bodyStyle.copyWith(color: labelColor, fontSize: 10, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildInfoColumn({required Widget top, required String bottom}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        top,
        const SizedBox(height: 4),
        Text(
          bottom,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ],
    );
  }
}
