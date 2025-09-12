import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/utils/screen_utils.dart';
import 'package:miruryoiki/utils/time_utils.dart';

import '../manager.dart';
import '../models/series.dart';
import 'hidden.dart';

class CardIndicators extends StatelessWidget {
  final Series series;
  final bool isListView;

  const CardIndicators({
    super.key,
    required this.series,
    this.isListView = false,
  });

  static List<Widget> indicators(Series series, {bool isListView = false}) => [
        // Anilist hidden indicator
        if (series.isAnilistHidden) AnilistHidden(),
        // LOCAL hidden indicator
        if (series.isForcedHidden) LocalHidden(),
      ];

  @override
  Widget build(BuildContext context) {
    final indicatorsList = indicators(series);
    if (indicatorsList.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: isListView ? EdgeInsets.all(12.0) : const EdgeInsets.all(16.0),
      child: LayoutBuilder(builder: (context, constraints) {
        final indicatorSize = isListView ? 28.0 : 25.0;
        final padding = 6.0;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: isListView
              ? SizedBox(
                  height: indicatorSize,
                  width: indicatorsList.length * (indicatorSize + padding) - padding,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: indicatorsList.length,
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.only(left: indicatorsList.length - 1 == index ? 0 : padding),
                      child: SizedBox(
                        width: indicatorSize,
                        child: indicatorsList[index],
                      ),
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                )
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: (constraints.maxWidth.isInfinite || constraints.maxWidth.isNaN ? ScreenUtils.width - ScreenUtils.kInfoBarWidth - 32 : constraints.maxWidth / (indicatorSize + 8)).floor(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: indicatorsList.length,
                  itemBuilder: (context, index) => indicatorsList[index],
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                ),
        );
      }),
    );
  }
}

class AiringIndicator extends StatefulWidget {
  final Series series;
  final bool isHovered;

  const AiringIndicator({
    super.key,
    required this.series,
    required this.isHovered,
  });

  @override
  State<AiringIndicator> createState() => _AiringIndicatorState();
}

class _AiringIndicatorState extends State<AiringIndicator> {
  @override
  Widget build(BuildContext context) {
    final bool isAiring = widget.series.anilistMappings.any((mapping) => mapping.anilistData?.status == 'RELEASING');
    final bool isUpcoming = widget.series.anilistMappings.any((mapping) => mapping.anilistData?.status == 'NOT_YET_RELEASED');
    final bool isLocal = !widget.series.isLinked;
    final double size = 12 * Manager.fontSizeMultiplier;
    double expanded = 0;
    Color color = Colors.transparent;
    String text = '';

    if (isAiring) {
      expanded = 50;
      color = Color(0xFF7BD555);
      text = 'Airing';
    } else if (isUpcoming) {
      expanded = 70;
      color = Color(0xFFfA7A7A);
      text = 'Upcoming';
    } else if (isLocal) {
      expanded = 50;
      color = Colors.grey;
      text = 'Local';
    } // else we don't show the indicator

    if (isAiring || isUpcoming || isLocal) {
      return Positioned(
        top: 8,
        left: 8,
        child: AnimatedContainer(
          duration: shortDuration,
          width: (Manager.settings.hoverShowAiringIndicator && widget.isHovered ? expanded * Manager.fontSizeMultiplier : size),
          height: size,
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size / 2),
            color: color, // if an entry is airing and another one is upcoming, airing has priority
            boxShadow: [
              BoxShadow(
                color: color,
                spreadRadius: 2.5,
                blurRadius: 4,
                offset: Offset(0, 0),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(.3),
                spreadRadius: 2.5,
                blurRadius: 7,
                offset: Offset(0, 0),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(.2),
                spreadRadius: 3.5,
                blurRadius: 7,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: AnimatedOpacity(
            opacity: Manager.settings.hoverShowAiringIndicator && widget.isHovered ? 1 : 0,
            duration: shortDuration,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: Manager.miniBodyStyle.copyWith(
                color: Colors.white,
                height: 1.1,
              ),
            ),
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }
}
