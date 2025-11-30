// ignore_for_file: invalid_use_of_protected_member

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:glossy/glossy.dart';

import '../../enums.dart';
import '../../main.dart';
import '../../manager.dart';
import '../../services/anilist/queries/anilist_service.dart';
import '../../services/navigation/dialogs.dart';
import '../../utils/color.dart';
import '../../utils/screen.dart';
import '../../utils/time.dart';
import '../buttons/button.dart';
import '../buttons/wrapper.dart';
import '../frosted_noise.dart';
import '../pill.dart';

final GlobalKey<GenresFilterContentState> genresFilterContentKey = GlobalKey<GenresFilterContentState>();

class GenresFilterDialog extends ManagedDialog {
  GenresFilterDialog({
    super.key,
    required super.popContext,
  }) : super(
          title: null, // Remove the static title
          constraints: const BoxConstraints(maxWidth: 250, maxHeight: 400),
          contentBuilder: (context, constraints) => _GenresFilterContent(
            key: genresFilterContentKey,
            constraints: constraints,
          ),
          alignment: Alignment.topRight,
        );

  @override
  State<ManagedDialog> createState() => _GenresFilterDialogState();
}

class _GenresFilterDialogState extends GenresFilterManagedDialogState {
  @override
  void initState() {
    super.initState();
    Manager.canPopDialog = true;
  }
}

class _GenresFilterContent extends StatefulWidget {
  final BoxConstraints constraints;

  const _GenresFilterContent({super.key, required this.constraints});

  @override
  GenresFilterContentState createState() => GenresFilterContentState();
}

class GenresFilterContentState extends State<_GenresFilterContent> {
  final GlobalKey<AutoSuggestBoxState<String>> asgbKey = GlobalKey<AutoSuggestBoxState<String>>();
  List<String> genres = [];
  List<String> selectedGenres = [];
  final TextEditingController genres_controller = TextEditingController();
  final FocusNode genre_focus_node = FocusNode();

  @override
  void initState() {
    super.initState();
    genres = Manager.settings.genres;
    selectedGenres = List.from(libraryScreenKey.currentState?.selectedGenres ?? []);
    _fetchGenres();
    genre_focus_node.addListener(() {
      if (genre_focus_node.hasFocus) asgbKey.currentState?.showOverlay();
    });
  }

  Future<void> _fetchGenres() async {
    final fetchedGenres = await AnilistService().getGenres();
    if (mounted) setState(() => genres = fetchedGenres);
  }

  void _addGenre(String genre) {
    if (!selectedGenres.contains(genre)) {
      setState(() => selectedGenres.add(genre));
      libraryScreenKey.currentState?.addGenre(genre);
    }
  }

  void _removeGenre(String genre) {
    if (selectedGenres.contains(genre)) {
      setState(() => selectedGenres.remove(genre));
      libraryScreenKey.currentState?.removeGenre(genre);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
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
                    tooltip: libraryScreenKey.currentState?.sortOrder.name_,
                    child: (_) => ComboBox<SortOrder>(
                      isExpanded: true,
                      value: libraryScreenKey.currentState?.sortOrder,
                      placeholder: const Text('Sort By'),
                      items: SortOrder.values.map((order) => ComboBoxItem(value: order, child: Text(libraryScreenKey.currentState?.getSortText(order) ?? ''))).toList(),
                      onChanged: (p0) => setState(() => libraryScreenKey.currentState?.onSortOrderChanged(p0)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 34,
                  width: 34,
                  child: StandardButton(
                    tooltip: 'Sort results in ${!(libraryScreenKey.currentState?.sortDescending ?? false) ? "Ascending" : "Descending"} order',
                    tooltipWaitDuration: Duration(milliseconds: 150),
                    padding: EdgeInsets.zero,
                    label: Center(
                      child: AnimatedRotation(
                        duration: shortStickyHeaderDuration,
                        turns: libraryScreenKey.currentState?.sortDescending ?? false ? 0 : 1,
                        child: Icon(libraryScreenKey.currentState?.sortDescending ?? false ? FluentIcons.sort_lines : FluentIcons.sort_lines_ascending, color: Manager.pastelAccentColor),
                      ),
                    ),
                    onPressed: () => setState(() => libraryScreenKey.currentState?.onSortDirectionChanged()),
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
                      return MouseButtonWrapper(
                        child: (isHovered) => Pill(
                          text: genre,
                          color: (isSelected) => isSelected ? getTextColor(Manager.currentDominantColor ?? Manager.accentColor) : Colors.white,
                          icon: FluentIcons.clear,
                          iconSize: 10,
                          spacing: 4,
                          onTap: () => _removeGenre(genre),
                          isSelected: isHovered,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          VDiv(24),
          InfoLabel(
            label: 'View',
            labelStyle: Manager.smallSubtitleStyle.copyWith(color: Manager.pastelDominantColor),
            child: MouseButtonWrapper(
              tooltip: libraryScreenKey.currentState?.currentView == LibraryView.all ? 'Show all series' : 'Show only series linked to AniList',
              child: (_) => ComboBox<LibraryView>(
                isExpanded: true,
                value: libraryScreenKey.currentState?.currentView,
                items: [
                  ComboBoxItem(value: LibraryView.all, child: Text('All Series')),
                  ComboBoxItem(value: LibraryView.linked, child: Text('Linked Series Only')),
                ],
                onChanged: (view) => setState(() => libraryScreenKey.currentState?.onViewChanged(view)),
              ),
            ),
          ),
          VDiv(16),

          // Grouping Toggle
          MouseButtonWrapper(
            tooltip: (libraryScreenKey.currentState?.showGrouped ?? false) ? 'Display series grouped by AniList lists' : 'Display series in a flat list',
            child: (_) => ToggleSwitch(
              checked: libraryScreenKey.currentState?.showGrouped ?? false,
              content: Expanded(child: Text('Group by AniList Lists', style: Manager.bodyStyle, maxLines: 2, overflow: TextOverflow.ellipsis)),
              onChanged: (value) => setState(() => libraryScreenKey.currentState?.onShowGroupedChanged(value)),
            ),
          ),
          VDiv(24),
        ],
      ),
    );
  }
}

class GenresFilterManagedDialogState extends State<ManagedDialog> {
  late BoxConstraints _currentConstraints;
  late Alignment alignment;
  bool lowerOpacity = false;
  bool _exitScheduled = false;

  @override
  void initState() {
    super.initState();
    _currentConstraints = widget.constraints;
    alignment = widget.alignment;
  }

  @override
  void dispose() {
    _exitScheduled = false;
    super.dispose();
  }

  // Method to resize the dialog
  void resizeDialog({double? width, double? height, BoxConstraints? constraints}) {
    setState(() {
      if (constraints != null) {
        _currentConstraints = constraints;
      } else {
        _currentConstraints = BoxConstraints(
          minWidth: width ?? _currentConstraints.minWidth,
          maxWidth: width ?? _currentConstraints.maxWidth,
          minHeight: height ?? _currentConstraints.minHeight,
          maxHeight: height ?? _currentConstraints.maxHeight,
        );
      }
    });
  }

  /// Position the dialog on screen
  void positionDialog(Alignment alignment) => setState(() => this.alignment = alignment);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: alignment,
      children: [
        Positioned(
          top: 142,
          right: 450,
          child: AnimatedOpacity(
            duration: dimDuration,
            opacity: lowerOpacity ? 0.5 : 1,
            child: Padding(
              padding: const EdgeInsets.only(top: ScreenUtils.kTitleBarHeight + 16, right: 16, bottom: 16),
              child: GlossyContainer(
                width: _currentConstraints.maxWidth,
                height: _currentConstraints.maxHeight,
                color: Colors.black,
                opacity: 0.1,
                strengthX: 20,
                strengthY: 20,
                blendMode: BlendMode.src,
                borderRadius: BorderRadius.circular(12),
                child: MouseRegion(
                  onEnter: (event) {
                    // Cancel any scheduled opacity lowering and restore full opacity immediately
                    if (_exitScheduled) _exitScheduled = false;
                    if (lowerOpacity) setState(() => lowerOpacity = false);
                  },
                  onExit: (_) {
                    // Start a 1s timer to lower opacity; if onEnter occurs before it completes, cancel it.
                    if (!lowerOpacity && !_exitScheduled) {
                      _exitScheduled = true;
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (!mounted) return;
                        if (_exitScheduled) {
                          setState(() => lowerOpacity = true);
                        }
                        _exitScheduled = false;
                      });
                    }
                  },
                  child: Stack(
                    children: [
                      FrostedNoise(
                        intensity: 0.7,
                        child: ContentDialog(
                          style: ContentDialogThemeData(decoration: BoxDecoration(color: Colors.transparent)),
                          title: widget.title,
                          content: mat.Material(
                            color: Colors.transparent,
                            child: Container(
                              constraints: _currentConstraints,
                              child: widget.contentBuilder != null ? widget.contentBuilder!(context, _currentConstraints) : null,
                            ),
                          ),
                          // ignore: prefer_null_aware_operators
                          actions: widget.actions != null ? widget.actions!.call(widget.popContext) : null,
                          constraints: _currentConstraints,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void popDialog() => closeDialog(widget.popContext);
}
