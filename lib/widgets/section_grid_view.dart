import '../viewmodels/search_viewmodel.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Colors, IconButton;
// import 'package:miruryoiki/screens/search.dart';
import 'package:miruryoiki/utils/screen.dart';
import 'package:miruryoiki/widgets/cards/search_series_card.dart';

import '../models/anilist/anime_card.dart';

class SectionGridView extends StatelessWidget {
  final SearchSectionData manager;
  final Function(AnimeCard) onSeriesOpen;

  const SectionGridView({
    super.key,
    required this.manager,
    required this.onSeriesOpen,
  });

  @override
  Widget build(BuildContext context) {
    final items = manager.items;

    if (items.isEmpty && manager.isLoading) return const SizedBox(height: 200, child: Center(child: ProgressRing()));
    if (items.isEmpty) return const SizedBox(height: 200, child: Center(child: Text('No results found.')));

    return LayoutBuilder(builder: (context, constraints) {
      final int count = ScreenUtils.crossAxisCount(constraints.maxWidth);
      return Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: count,
              childAspectRatio: ScreenUtils.kDefaultAspectRatio,
              crossAxisSpacing: ScreenUtils.cardPadding,
              mainAxisSpacing: ScreenUtils.cardPadding,
            ),
            padding: const EdgeInsets.only(top: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return SearchSeriesCard(
                series: item,
                number: index + 1,
                onTap: () => onSeriesOpen(item),
              );
            },
          ),
          if (manager.isLoading) const Padding(padding: EdgeInsets.all(16.0), child: Center(child: ProgressRing())),
          const SizedBox(height: 40),
        ],
      );
    });
  }
}
