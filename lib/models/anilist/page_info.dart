class AnilistPageInfo {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final bool hasNextPage;

  AnilistPageInfo({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    required this.hasNextPage,
  });

  factory AnilistPageInfo.fromJson(Map<String, dynamic> json) {
    return AnilistPageInfo(
      total: json['total'] as int? ?? 0,
      perPage: json['perPage'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 1,
      lastPage: json['lastPage'] as int? ?? 1,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
    );
  }
}

class AnilistSearchPage<T> {
  final AnilistPageInfo pageInfo;
  final List<T> results;

  AnilistSearchPage({
    required this.pageInfo,
    required this.results,
  });
}
