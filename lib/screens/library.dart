import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/manager.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import '../models/library.dart';
import '../models/series.dart';
import '../services/anilist/provider.dart';
import '../utils/logging.dart';
import '../widgets/gradient_mask.dart';
import '../widgets/series_card.dart';

enum LibraryView { all, linked }

enum SortOrder { alphabetical, dateAdded, lastModified, custom }

enum GroupBy { none, anilistLists, customLists }

class LibraryScreen extends StatefulWidget {
  final ScrollController? scrollController;
  final Function(String) onSeriesSelected;
  final int? fixedColumnCount;

  const LibraryScreen({
    super.key,
    required this.onSeriesSelected,
    this.scrollController,
    this.fixedColumnCount,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  LibraryView _currentView = LibraryView.all;
  SortOrder _sortOrder = SortOrder.alphabetical;
  GroupBy _groupBy = GroupBy.none;

  @override
  Widget build(BuildContext context) {
    final library = context.watch<Library>();

    if (library.isLoading) return const Center(child: ProgressRing());

    if (library.libraryPath == null) return _buildLibrarySelector();

    if (library.series.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              FluentIcons.folder_open,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text('No series found in your library'),
            const SizedBox(height: 16),
            Button(
              onPressed: _selectLibraryFolder,
              child: const Text('Change Library Folder'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: _buildLibraryView(library),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            // View selector
            ToggleSwitch(
              checked: _currentView == LibraryView.linked,
              content: Text(_currentView == LibraryView.linked ? 'Linked Series' : 'All Series'),
              onChanged: (value) {
                setState(() {
                  _currentView = value ? LibraryView.linked : LibraryView.all;
                });
              },
            ),

            SizedBox(width: 16),

            // Sort dropdown
            Text('Sort:'),
            SizedBox(width: 8),
            ComboBox<SortOrder>(
              value: _sortOrder,
              items: SortOrder.values
                  .map((order) => ComboBoxItem(
                        value: order,
                        child: Text(_getSortText(order)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _sortOrder = value);
                }
              },
            ),

            SizedBox(width: 16),

            // Group dropdown
            Text('Group:'),
            SizedBox(width: 8),
            ComboBox<GroupBy>(
              value: _groupBy,
              items: GroupBy.values
                  .map((group) => ComboBoxItem(
                        value: group,
                        child: Text(_getGroupText(group)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _groupBy = value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibrarySelector() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FluentIcons.folder_open,
            size: 48,
            color: Colors.purple,
          ),
          const SizedBox(height: 16),
          const Text(
            'Select your media library folder to get started',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          Button(
            style: ButtonStyle(
              padding: ButtonState.all(const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              )),
            ),
            onPressed: _selectLibraryFolder,
            child: const Text('Select Library Folder'),
          ),
        ],
      ),
    );
  }
  // double singleChildHeight(int count) =>

  static const double maxCardWidth = 200;
  static const double cardPadding = 16;

  int crossAxisCount(BoxConstraints constraints) => widget.fixedColumnCount != null ? widget.fixedColumnCount! : (constraints.maxWidth ~/ maxCardWidth).clamp(1, 10);

  double cardWidth(BoxConstraints constraints) => (constraints.maxWidth / (crossAxisCount(constraints) + cardPadding * (crossAxisCount(constraints) - 1))).clamp(0, maxCardWidth);
  
  double cardHeight(BoxConstraints constraints) => ((cardWidth(constraints) / 0.71) + cardPadding) * 8.15; // based on the aspect ratio of the series card

  Widget _buildLibraryView(Library library) {
    final displayedSeries = _currentView == LibraryView.all //
        ? library.series.toList()
        : library.series.where((s) => s.isLinked).toList();

    _sortSeries(displayedSeries);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _currentView == LibraryView.linked ? 'Linked Series' : 'Your Media Library',
                  style: FluentTheme.of(context).typography.title,
                ),
                Button(
                  child: const Text('Refresh'),
                  onPressed: () => library.reloadLibrary(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Path: ${library.libraryPath}',
              style: FluentTheme.of(context).typography.caption,
            ),
            Expanded(
              child: FadingEdgeScrollView(
                fadeEdges: const EdgeInsets.symmetric(vertical: 10),
                child: _buildSeriesGrid(displayedSeries, constraints),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSeriesGrid(List<Series> series, BoxConstraints constraints) {
    // if the currently dispalyed library is empty
    if (series.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(FluentIcons.warning, size: 48, color: Colors.warningPrimaryColor),
            const SizedBox(height: 16),
            Text(_currentView == LibraryView.linked ? 'No linked series found. Link your series with Anilist first.' : 'No series found in your library'),
          ],
        ),
      );
    }

    Widget episodesGrid(List<Series> list, ScrollController controller, ScrollPhysics physics, bool includePadding) => GridView.builder(
          padding: includePadding ? const EdgeInsets.only(top: 16, bottom: 8, right: 12) : EdgeInsets.zero,
          cacheExtent: cardHeight(constraints) * 2,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount(constraints),
            childAspectRatio: 0.71,
            crossAxisSpacing: cardPadding,
            mainAxisSpacing: cardPadding,
          ),
          controller: controller,
          physics: physics,
          itemCount: list.length,
          itemBuilder: (context, index) {
            final Series series_ = list[index % list.length]; // just to ensure we don't run out of bounds

            return SeriesCard(
              key: ValueKey('${series_.path}:${series_.effectivePosterPath ?? 'none'}'),
              series: series_,
              onTap: () => _navigateToSeries(series_),
            );
          },
        );

    // If grouping is enabled, show grouped view
    if (_groupBy != GroupBy.none) return _buildGroupedView(series, constraints, episodesGrid);

    return DynMouseScroll(
      enableSmoothScroll: Manager.animationsEnabled,
      scrollAmount: cardHeight(constraints),
      controller: widget.scrollController,
      durationMS: 300,
      animationCurve: Curves.ease,
      builder: (context, controller, physics) => episodesGrid(series, controller, physics, true),
    );
  }

  void _sortSeries(List<Series> series) {
    switch (_sortOrder) {
      case SortOrder.dateAdded:
      // series.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      case SortOrder.lastModified:
      // series.sort((a, b) => b.lastModified.compareTo(a.lastModified));
      case SortOrder.custom:
      // TODO Implement custom order logic here
      case SortOrder.alphabetical:
        series.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
  }

  Widget _buildGroupedView(
    List<Series> allSeries,
    BoxConstraints constraints,
    Widget Function(List<Series>, ScrollController, ScrollPhysics, bool) episodesGrid,
  ) {
    // Create the groupings based on selected grouping type
    Map<String, List<Series>> groups = {};

    switch (_groupBy) {
      case GroupBy.anilistLists:
        // Get all Anilist lists
        final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);
        final userLists = anilistProvider.userLists;

        // Initialize groups with all Anilist lists
        for (var listName in userLists.keys) {
          groups[_formatListName(listName)] = [];
        }

        // Add "Other" group for series not in any list
        groups['Not in List'] = [];

        // Sort series into groups
        for (final series in allSeries) {
          if (series.isLinked) {
            bool foundInList = false;

            // Check each Anilist mapping against each list
            for (final mapping in series.anilistMappings) {
              for (final entry in userLists.entries) {
                final listName = entry.key;
                final list = entry.value;

                // Check if this series appears in this list
                if (list.entries.any((listEntry) => listEntry.mediaId == mapping.anilistId)) {
                  groups[_formatListName(listName)]!.add(series);
                  foundInList = true;
                  break; // Found in this list, no need to check others
                }
              }
              if (foundInList) break; // No need to check other mappings
            }

            // If not found in any list, add to "Not in List"
            if (!foundInList) {
              groups['Not in List']!.add(series);
            }
          }
        }
        break;

      case GroupBy.customLists:
        // Implement custom lists grouping here
        // This would need a data model for custom lists
        break;

      default:
        return ListView(children: [Text('No grouping selected')]);
    }

    // Remove empty groups
    groups.removeWhere((_, series) => series.isEmpty);

    // Build the grouped ListView
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: DynMouseScroll(
        enableSmoothScroll: Manager.animationsEnabled,
        scrollAmount: cardHeight(constraints),
        controller: widget.scrollController,
        durationMS: 300,
        animationCurve: Curves.ease,
        builder: (context, controller, physics) => ListView.builder(
          controller: controller,
          physics: physics,
          itemCount: groups.length,
          itemBuilder: (context, groupIndex) {
            final groupName = groups.keys.elementAt(groupIndex);
            final seriesInGroup = groups[groupName]!;
      
            return Expander(
              initiallyExpanded: true,
              headerBackgroundColor: WidgetStatePropertyAll(FluentTheme.of(context).resources.cardBackgroundFillColorDefault.withOpacity(0.025)),
              contentBackgroundColor: FluentTheme.of(context).resources.cardBackgroundFillColorSecondary.withOpacity(0),
              header: Text(groupName, style: FluentTheme.of(context).typography.subtitle),
              trailing: Text('${seriesInGroup.length} series'),
              content: Container(
                height: cardHeight(constraints) * (seriesInGroup.length / crossAxisCount(constraints)).ceil() * 0.95,
                child: episodesGrid(seriesInGroup, ScrollController(), NeverScrollableScrollPhysics(), false),
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper method to format list names for display
  String _formatListName(String listName) {
    // Handle the standard Anilist list names which are in uppercase
    switch (listName) {
      case 'CURRENT':
        return 'Watching';
      case 'COMPLETED':
        return 'Completed';
      case 'PLANNING':
        return 'Plan to Watch';
      case 'DROPPED':
        return 'Dropped';
      case 'PAUSED':
        return 'On Hold';
      case 'REPEATING':
        return 'Rewatching';
      default:
        // Custom lists already have proper formatting
        if (listName.startsWith('custom_')) //
          return listName.substring(7); // Remove 'custom_' prefix
        return listName;
    }
  }

  String _getSortText(SortOrder order) {
    switch (order) {
      case SortOrder.alphabetical:
        return 'A-Z';
      case SortOrder.dateAdded:
        return 'Date Added';
      case SortOrder.lastModified:
        return 'Last Modified';
      case SortOrder.custom:
        return 'Custom Order';
    }
  }

  String _getGroupText(GroupBy group) {
    switch (group) {
      case GroupBy.none:
        return 'No Grouping';
      case GroupBy.anilistLists:
        return 'Anilist Lists';
      case GroupBy.customLists:
        return 'Custom Lists';
    }
  }

  void _selectLibraryFolder() async {
    final String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Media Library Folder',
    );

    if (selectedDirectory != null) {
      // ignore: use_build_context_synchronously
      final library = context.read<Library>();
      await library.setLibraryPath(selectedDirectory);
    }
  }

  void _navigateToSeries(Series series) => widget.onSeriesSelected(series.path);
}
