import 'package:fluent_ui/fluent_ui.dart';
import '../models/episode.dart';
import '../models/series.dart';
import 'episode_card.dart';

class EpisodeGrid extends StatefulWidget {
  final List<Episode> episodes;
  final Series series;
  final String? title;
  final Function(Episode) onTap;
  final bool collapsable;
  final bool initiallyExpanded;
  final GlobalKey<ExpanderState>? expanderKey;

  const EpisodeGrid({
    super.key,
    required this.episodes,
    required this.series,
    this.title,
    this.collapsable = true,
    this.initiallyExpanded = true,
    required this.onTap,
    this.expanderKey,
  });
  
  @override
  State<EpisodeGrid> createState() => _EpisodeGridState();
}

class _EpisodeGridState extends State<EpisodeGrid> {

  @override
  Widget build(BuildContext context) {
    if (widget.episodes.isEmpty) {
      return Center(
        child: Text(
          'No episodes found',
          style: FluentTheme.of(context).typography.body,
        ),
      );
    }

    return Expander(
      key: widget.expanderKey,
      enabled: widget.collapsable,
      initiallyExpanded: widget.initiallyExpanded,
      header: Builder(builder: (context) {
        if (widget.title != null) {
          return MouseRegion(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Text(
                widget.title!,
                style: FluentTheme.of(context).typography.subtitle,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      }),
      headerBackgroundColor: WidgetStatePropertyAll<Color>(Colors.black.withOpacity(0.1)),
      contentPadding: EdgeInsets.zero,
      contentBackgroundColor: Colors.transparent,
      content: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          borderRadius: BorderRadius.only(
            bottomLeft: const Radius.circular(8.0),
            bottomRight: const Radius.circular(8.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
          child: LayoutBuilder(builder: (context, constraints) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: (constraints.maxWidth ~/ 200).clamp(1, 10),
                childAspectRatio: 16 / 12,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: widget.episodes.length,
              itemBuilder: (context, index) {
                final episode = widget.episodes[index];
                return _buildEpisodeTile(context, episode, widget.series);
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEpisodeTile(BuildContext context, Episode episode, Series series) {
    return HoverableEpisodeTile(
      episode: episode,
      onTap: () => widget.onTap(episode),
      series: series,
    );
  }
}
