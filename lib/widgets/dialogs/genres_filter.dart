// ignore_for_file: invalid_use_of_protected_member

import 'package:fluent_ui/fluent_ui.dart';

import 'package:provider/provider.dart';

import '../../enums.dart';
import '../../manager.dart';
import '../../services/anilist/queries/anilist_service.dart';
import '../../services/navigation/dialog_framework.dart';
import '../../utils/screen.dart';
import '../../utils/time.dart';
import '../../viewmodels/library_screen_viewmodel.dart';
import '../buttons/button.dart';
import '../buttons/wrapper.dart';
import '../pill.dart';

class GenresFilterContent extends StatefulWidget {
  const GenresFilterContent({super.key});

  @override
  GenresFilterContentState createState() => GenresFilterContentState();
}

class GenresFilterContentState extends State<GenresFilterContent> {
  final GlobalKey<AutoSuggestBoxState<String>> asgbKey = GlobalKey<AutoSuggestBoxState<String>>();
  final GlobalKey _columnKey = GlobalKey();
  List<String> genres = [];
  List<String> selectedGenres = [];
  final TextEditingController genres_controller = TextEditingController();
  final FocusNode genre_focus_node = FocusNode();

  /// Library view/sort/filter state lives in the app-scoped ViewModel
  LibraryScreenViewModel get _vm => context.read<LibraryScreenViewModel>();

  @override
  void initState() {
    super.initState();
    genres = Manager.settings.genres;
    selectedGenres = List.from(_vm.selectedGenres);
    _fetchGenres();
    genre_focus_node.addListener(() {
      if (genre_focus_node.hasFocus) asgbKey.currentState?.showOverlay();
    });
    _updateHeight();
  }

  void _updateHeight() {
    nextFrame(delay: 2, () {
      if (!mounted) return;
      final renderBox = _columnKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final height = renderBox.size.height;
        context.findAncestorStateOfType<PaddedDialogState>()?.resizeDialog(height: height + 24); // 24 padding
      }
    });
  }

  Future<void> _fetchGenres() async {
    final fetchedGenres = await AnilistService().getGenres();
    if (mounted) {
      setState(() => genres = fetchedGenres);
      _updateHeight();
    }
  }

  void _addGenre(String genre) {
    if (!selectedGenres.contains(genre)) {
      setState(() => selectedGenres.add(genre));
      _vm.addGenre(genre);
      _updateHeight();
    }
  }

  void _removeGenre(String genre) {
    if (selectedGenres.contains(genre)) {
      setState(() => selectedGenres.remove(genre));
      _vm.removeGenre(genre);
      _updateHeight();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: OverflowBox(
        minHeight: 0,
        maxHeight: double.infinity,
        alignment: Alignment.topCenter,
        child: Column(
          key: _columnKey,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InfoLabel(
              label: 'Sort by',
              labelStyle: Manager.smallSubtitleStyle.copyWith(color: Manager.pastelAccentColor),
              child: Row(
                children: [
                  Expanded(
                    child: MouseButtonWrapper(
                      tooltip: _vm.sortOrder.name_,
                      child: (_) => ComboBox<SortOrder>(
                        isExpanded: true,
                        value: _vm.sortOrder,
                        placeholder: const Text('Sort By'),
                        items: SortOrder.values.map((order) => ComboBoxItem(value: order, child: Text(LibraryScreenViewModel.getSortText(order)))).toList(),
                        onChanged: (p0) => setState(() => _vm.onSortOrderChanged(p0)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 34,
                    width: 34,
                    child: StandardButton(
                      tooltip: 'Sort results in ${!_vm.sortDescending ? "Ascending" : "Descending"} order',
                      tooltipWaitDuration: Duration(milliseconds: 150),
                      padding: EdgeInsets.zero,
                      label: Center(
                        child: AnimatedRotation(
                          duration: shortStickyHeaderDuration,
                          turns: _vm.sortDescending ? 0 : 1,
                          child: Icon(_vm.sortDescending ? FluentIcons.sort_lines : FluentIcons.sort_lines_ascending, color: Manager.pastelAccentColor),
                        ),
                      ),
                      onPressed: () => setState(() => _vm.onSortDirectionChanged()),
                    ),
                  ),
                ],
              ),
            ),
            VDiv(24),

            // Genre Filter
            InfoLabel(
              label: 'Filter by Genre',
              labelStyle: Manager.smallSubtitleStyle.copyWith(color: Manager.pastelAccentColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSuggestBox<String>(
                    key: asgbKey,
                    placeholder: 'Select Genre',
                    clearButtonEnabled: false,
                    cursorColor: Manager.pastelAccentColor,
                    decoration: ButtonState.all(
                      BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                    noResultsFoundBuilder: (context) => const Padding(padding: EdgeInsets.all(8.0), child: Text('No genres found')),
                    controller: genres_controller,
                    items: genres.where((g) => !selectedGenres.contains(g)).map((genre) {
                      return AutoSuggestBoxItem<String>(
                        value: genre,
                        label: genre,
                      );
                    }).toList(),
                    focusNode: genre_focus_node,
                    onSelected: (item) {
                      if (item.value != null) _addGenre(item.value!);

                      // Clear the controller after a short delay to ensure it overrides the default behavior
                      Future.microtask(() {
                        genres_controller.clear();
                        (asgbKey.currentWidget as AutoSuggestBox<String>?)?.controller?.clear();
                      });
                    },
                  ),
                  if (selectedGenres.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedGenres.map((genre) {
                        return FluentPill(
                          text: genre,
                          icon: FluentIcons.clear,
                          onTap: (g) => _removeGenre(g),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            VDiv(24),
            InfoLabel(
              label: 'Display',
              labelStyle: Manager.smallSubtitleStyle.copyWith(color: Manager.pastelDominantColor),
              child: MouseButtonWrapper(
                tooltip: _vm.currentView == LibraryView.all ? 'Show all series' : 'Show only series linked to AniList',
                child: (_) => ComboBox<LibraryView>(
                  isExpanded: true,
                  value: _vm.currentView,
                  items: [
                    ComboBoxItem(value: LibraryView.all, child: Text('All Series')),
                    ComboBoxItem(value: LibraryView.linked, child: Text('Linked Series Only')),
                  ],
                  onChanged: (view) => setState(() => _vm.onViewChanged(view)),
                ),
              ),
            ),
            VDiv(16),

            // Grouping Toggle
            MouseButtonWrapper(
              tooltip: _vm.showGrouped ? 'Display series grouped by AniList lists' : 'Display series in a flat list',
              child: (_) => ToggleSwitch(
                checked: _vm.showGrouped,
                content: Expanded(child: Text('Group by AniList Lists', style: Manager.bodyStyle, maxLines: 2, overflow: TextOverflow.ellipsis)),
                onChanged: (value) => setState(() => _vm.onShowGroupedChanged(value)),
              ),
            ),
            VDiv(24),
          ],
        ),
      ),
    );
  }
}
