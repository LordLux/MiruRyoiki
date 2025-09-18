// Define a class for offline mutations
import '../../utils/time.dart';

class AnilistMutation {
  final String type; // 'progress', 'status', 'score', etc.
  final int mediaId;
  final Map<String, dynamic> changes;
  final DateTime createdAt;
  
  AnilistMutation({
    required this.type,
    required this.mediaId,
    required this.changes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? now;
  
  Map<String, dynamic> toJson() => {
    'type': type,
    'mediaId': mediaId,
    'changes': changes,
    'createdAt': createdAt.toIso8601String(),
  };
  
  factory AnilistMutation.fromJson(Map<String, dynamic> json) {
    return AnilistMutation(
      type: json['type'],
      mediaId: json['mediaId'],
      changes: Map<String, dynamic>.from(json['changes']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}