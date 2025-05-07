import 'dart:convert';

class AnilistMapping {
  String localPath; // Can be folder or file path
  int anilistId;
  String? title; // Optional: Store Anilist title for easier display
  DateTime? lastSynced;
  
  AnilistMapping({
    required this.localPath, 
    required this.anilistId, 
    this.title,
    this.lastSynced,
  });
  
  Map<String, dynamic> toJson() => {
    'localPath': localPath,
    'anilistId': anilistId,
    'title': title,
    'lastSynced': lastSynced?.toIso8601String(),
  };
  
  factory AnilistMapping.fromJson(Map<String, dynamic> json) => AnilistMapping(
    localPath: json['localPath'],
    anilistId: json['anilistId'],
    title: json['title'],
    lastSynced: json['lastSynced'] != null ? DateTime.parse(json['lastSynced']) : null,
  );
  
  
    @override
    String toString() {
      return 'AnilistMapping(localPath: $localPath, anilistId: $anilistId, title: $title, lastSynced: $lastSynced)';
    }
    
    // For easier debugging and logging
    String toJsonString() => jsonEncode(toJson());
    
    static AnilistMapping fromJsonString(String jsonString) {
      return AnilistMapping.fromJson(jsonDecode(jsonString));
    }
}