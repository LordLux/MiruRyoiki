import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import '../widgets/smooth_scroll.dart';
import '../main.dart';
import '../manager.dart';
import '../models/anilist/anime_card.dart';
import '../services/anilist/anilist_availability.dart';
import '../services/connectivity/connectivity_service.dart';
import '../utils/screen.dart';
import '../widgets/cards/search_series_card.dart';

import '../widgets/page/page_template.dart';
import '../widgets/page/header_widget.dart';
import '../widgets/buttons/button.dart';
import '../widgets/service_unavailable_banner.dart';
import '../viewmodels/search_viewmodel.dart';
import 'package:provider/provider.dart';

class SearchResultsScreen extends StatefulWidget {
  final String queryType; // 'trending', 'popular', 'upcoming', 'top100', 'search'
  final String title;
  final String? searchQuery;
  final Map<String, dynamic>? filters;
  final VoidCallback onBack;
  final void Function(AnimeCard anime) onSeriesOpen;

  const SearchResultsScreen({
    super.key,
    required this.queryType,
    required this.title,
    this.searchQuery,
    this.filters,
    required this.onBack,
    required this.onSeriesOpen,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<SearchViewModel>().initGenericSearch(widget.queryType, widget.searchQuery, widget.filters);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final vm = context.read<SearchViewModel>();
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !vm.genericIsLoading && vm.genericHasNextPage) {
      vm.fetchGenericData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchViewModel>();

    return MiruRyoikiTemplatePage(
      hideInfoBar: true,
      headerWidget: HeaderWidget(
        title: (style, constraints) => Row(
          children: [
            StandardButton.icon(
              icon: const Icon(mat.Icons.arrow_back),
              onPressed: widget.onBack,
            ),
            const SizedBox(width: 16),
            Text(widget.title, style: style),
          ],
        ),
      ),
      scrollableContent: false,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: _buildContent(vm),
      ),
    );
  }

  Widget _buildContent(SearchViewModel vm) {
    if (vm.genericErrorMessage != null && vm.genericResultsList.isEmpty) {
      if (ConnectivityService().isOffline || AnilistAvailabilityService().isUnavailable) 
        return ServiceUnavailableBanner(onRetry: vm.fetchGenericData);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(vm.genericErrorMessage!, style: const TextStyle(color: mat.Colors.red)),
            const SizedBox(height: 16),
            Button(
              onPressed: vm.fetchGenericData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (vm.genericResultsList.isEmpty && vm.genericIsLoading) return const Center(child: ProgressRing());

    if (vm.genericResultsList.isEmpty) return const Center(child: Text('No results found.'));

    return LayoutBuilder(builder: (context, constraints) {
      return SmoothScroll(
        controller: _scrollController,
        enableSmoothScroll: Manager.animationsEnabled,
        builder: (context, controller, physics) {
          return ValueListenableBuilder(
            valueListenable: previousGridColumnCount,
            builder: (context, columns, __) {
              return GridView.builder(
                controller: controller,
                physics: physics,
                padding: const EdgeInsets.only(bottom: 8),
                addAutomaticKeepAlives: true,
                addRepaintBoundaries: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns ?? ScreenUtils.crossAxisCount(constraints.maxWidth),
                  childAspectRatio: ScreenUtils.kDefaultAspectRatio,
                  crossAxisSpacing: ScreenUtils.cardPadding,
                  mainAxisSpacing: ScreenUtils.cardPadding,
                ),
                itemCount: vm.genericResultsList.length + (vm.genericHasNextPage ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == vm.genericResultsList.length) {
                    // Loading indicator or error message
                    if (vm.genericErrorMessage != null) {
                      return Center(
                        child: Button(
                          onPressed: vm.fetchGenericData,
                          child: const Text('Retry'),
                        ),
                      );
                    }
                    return const Center(child: ProgressRing());
                  }

                  final anime = vm.genericResultsList[index];
                  return AspectRatio(
                    aspectRatio: ScreenUtils.kDefaultAspectRatio,
                    child: SearchSeriesCard(
                      series: anime,
                      number: null, // not showing top100 number
                      onTap: () => widget.onSeriesOpen(anime),
                    ),
                  );
                },
              );
            },
          );
        },
      );
    });
  }
}
