class Episode {
  final String path;
  final String name;
  final String? thumbnailPath;
  bool watched;
  double watchedPercentage;
  
  Episode({
    required this.path,
    required this.name,
    this.thumbnailPath,
    this.watched = false,
    this.watchedPercentage = 0.0,
  });
  
  // For JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'name': name,
      'thumbnailPath': thumbnailPath,
      'watched': watched,
      'watchedPercentage': watchedPercentage,
    };
  }
  
  // For JSON deserialization
  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      path: json['path'],
      name: json['name'],
      thumbnailPath: json['thumbnailPath'],
      watched: json['watched'] ?? false,
      watchedPercentage: json['watchedPercentage'] ?? 0.0,
    );
  }
}