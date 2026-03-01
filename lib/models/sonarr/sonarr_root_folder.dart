/// Typed model for a Sonarr v3 root folder.
///
/// See: https://sonarr.tv/docs/api/#/RootFolder/get_api_v3_rootfolder
class SonarrRootFolder {
  final int id;
  final String path;
  final int freeSpace; // bytes

  const SonarrRootFolder({
    required this.id,
    required this.path,
    required this.freeSpace,
  });

  factory SonarrRootFolder.fromJson(Map<String, dynamic> json) {
    return SonarrRootFolder(
      id: json['id'] as int,
      path: json['path'] as String? ?? '',
      freeSpace: json['freeSpace'] as int? ?? 0,
    );
  }

  @override
  String toString() => 'SonarrRootFolder($id: "$path")';
}
