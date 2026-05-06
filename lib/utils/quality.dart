import 'package:fluent_ui/fluent_ui.dart';

/// Maps a release quality string (e.g. "1080p", "2160p") to a badge color
///
/// Falls back to a neutral grey for unknown values
Color qualityBadgeColor(String quality) {
  final lower = quality.toLowerCase();
  if (lower.contains('2160') || lower.contains('4k')) return const Color(0xFFFFD700); // gold
  if (lower.contains('1080')) return const Color(0xFF4CAF50); // green
  if (lower.contains('720')) return const Color(0xFF2196F3); // blue
  if (lower.contains('480')) return const Color(0xFFFF9800); // orange
  return Colors.grey[120];
}
