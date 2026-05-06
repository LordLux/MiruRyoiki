import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import '../../enums.dart';
import '../../main.dart';
import '../../manager.dart';
import '../../models/series.dart';
import '../../services/library/library_provider.dart';
import '../../services/navigation/shortcuts.dart';
import '../../settings.dart';
import '../../utils/screen.dart';
import '../cards/series_card.dart';
import '../series_image.dart';
import '../styled_scrollbar.dart';

class ExistingSeriesPickerDialog extends StatefulWidget {
  final void Function(Series series) onSelected;

  const ExistingSeriesPickerDialog({
    super.key,
    required this.onSelected,
  });

  @override
  State<ExistingSeriesPickerDialog> createState() => _ExistingSeriesPickerDialogState();
}

class _ExistingSeriesPickerDialogState extends State<ExistingSeriesPickerDialog> {
  final _searchController = TextEditingController();
  String _query = '';
  late ViewType _viewType;

  @override
  void initState() {
    super.initState();
    final viewTypeString = SettingsManager().get(
      'library_view_type',
      defaultValue: ViewType.grid.toString(),
    );
    _viewType = ViewType.values.firstWhere(
      (v) => v.toString() == viewTypeString,
      orElse: () => ViewType.grid,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Series> _filter(List<Series> all) {
    final q = _query.trim().toLowerCase();
    final list = [...all]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    if (q.isEmpty) return list;
    return list.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<Library>();
    final series = _filter(library.series);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextBox(
          controller: _searchController,
          placeholder: 'Search series by name...',
          prefix: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(FluentIcons.search, size: 14),
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: series.isEmpty
              ? const Center(child: Text('No series match your search.'))
              : LayoutBuilder(
                builder: (context, constraints) {
                  return _viewType == ViewType.grid
                      ? _buildGrid(series, constraints.maxWidth)
                      : _buildList(series);
                }
              ),
        ),
      ],
    );
  }
  

  final ScrollController _controller = ScrollController(
    debugLabel: 'LibraryScreen Scroll Controller',
    keepScrollOffset: true,
  );

  Widget _buildGrid(List<Series> series, double maxWidth) {
    final scrollContent = DynMouseScroll(
      controller: _controller,
      stopScroll: KeyboardState.ctrlPressedNotifier,
      scrollSpeed: 1.0,
      enableSmoothScroll: Manager.animationsEnabled,
      durationMS: 350,
      animationCurve: Curves.easeOutQuint,
      builder: (context, controller, physics) {
        return ValueListenableBuilder(
          valueListenable: KeyboardState.ctrlPressedNotifier,
          builder: (context, isCtrlPressed, _) {
            return ValueListenableBuilder(
              valueListenable: previousGridColumnCount,
              builder: (context, columns, __) {
                return GridView.builder(
                  controller: controller,
                  physics: physics,
                  padding: const EdgeInsets.only(bottom: 8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns ?? ScreenUtils.crossAxisCount(maxWidth),
                    childAspectRatio: ScreenUtils.kDefaultAspectRatio,
                    crossAxisSpacing: ScreenUtils.cardPadding,
                    mainAxisSpacing: ScreenUtils.cardPadding,
                  ),
                  itemCount: series.length,
                  itemBuilder: (context, index) {
                    final serieItem = series[index];
                    return SeriesCard(
                      key: ValueKey('${serieItem.path}:${serieItem.effectivePosterPath ?? 'none'}'),
                      series: serieItem,
                      onTap: () => widget.onSelected(serieItem),
                      options: SeriesCardOptions(
                        disableContextMenu: true,
                        hideEpisodeProgress: true,
                        hideProgressBar: true,
                        hideProgressPercentage: true,
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
    return buildStyledScrollbar(scrollContent, _controller);
  }

  Widget _buildList(List<Series> series) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: series.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, i) => _ListTile(
        series: series[i],
        onTap: () => widget.onSelected(series[i]),
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  final Series series;
  final VoidCallback onTap;

  const _ListTile({required this.series, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Button(
      onPressed: onTap,
      style: ButtonStyle(padding: WidgetStatePropertyAll(const EdgeInsets.all(6))),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 56,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SeriesImageBuilder.poster(series),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              series.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
