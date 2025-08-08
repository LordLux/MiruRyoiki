import '../../models/mkv_metadata.dart';
import '../../utils/logging.dart';
import 'dart:io';

import '../../utils/path_utils.dart';

class MediaInfo {
  static Future<MkvMetadata?> getMkvMetadata(PathString filepath) async {
    try {
      final result = await Process.run('MediaInfo.exe', ['--fullscan', filepath.path], runInShell: true);

      if (result.exitCode != 0) throw Exception('MediaInfo failed: ${result.stderr}');

      final metadataString = result.stdout.toString();
      if (metadataString.isEmpty) throw Exception('No metadata extracted by MediaInfo');

      final metadataJson = _parseMediaInfoCliOutput(metadataString);
      return MkvMetadata.fromJson(metadataJson);
    } catch (e, st) {
      logErr('Error extracting MKV metadata with MediaInfo', e, st);
      return null;
    }
  }

  static Map<String, dynamic> _parseMediaInfoCliOutput(String cliOutput) {
    // Normalize input: remove excess whitespace and blank lines
    final normalizedOutput = cliOutput.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).join('\n');

    // Helper to extract all values for a key in a section
    List<String> extractAllValues(List<String> lines, String key) {
      final prefix = key;
      return lines.where((line) => line.startsWith(prefix)).map((line) => line.substring(prefix.length).trim().replaceFirst(": ", "")).where((v) => v.isNotEmpty).toList();
    }

    int parseInt(String? s) {
      if (s == null) return 0;

      final digits = RegExp(r'[\d,]+').firstMatch(s.replaceAll(' ', ''));
      return int.tryParse(digits?.group(0)?.replaceAll(',', '') ?? '0') ?? 0;
    }

    double parseDouble(String? s) {
      if (s == null) return 0.0;

      final match = RegExp(r'[\d.]+').firstMatch(s.replaceAll(' ', ''));
      return double.tryParse(match?.group(0) ?? '0') ?? 0.0;
    }

    Map<String, int> parseAspectRatio(String? s) {
      if (s == null) return {'width': 0, 'height': 0};

      final colon = RegExp(r'(\d+)\s*:\s*(\d+)').firstMatch(s);
      if (colon != null) return {'width': int.tryParse(colon.group(1)!) ?? 0, 'height': int.tryParse(colon.group(2)!) ?? 0};

      final floatVal = double.tryParse(s.replaceAll(' ', ''));
      if (floatVal != null && floatVal > 0) return {'width': (floatVal).round(), 'height': 1};

      return {'width': 0, 'height': 0};
    }

    // Section regex
    final videoMatches = RegExp(r'^Video(?: #\d+)?\n([\s\S]*?)(?=^General\n|^Video(?: #\d+)?\n|^Audio(?: #\d+)?\n|^Text(?: #\d+)?\n|^Menu\n|\Z)', multiLine: true).allMatches(normalizedOutput);
    final audioMatches = RegExp(r'^Audio(?: #\d+)?\n([\s\S]*?)(?=^General\n|^Video(?: #\d+)?\n|^Audio(?: #\d+)?\n|^Text(?: #\d+)?\n|^Menu\n|\Z)', multiLine: true).allMatches(normalizedOutput);
    final textMatches = RegExp(r'^Text(?: #\d+)?\n([\s\S]*?)(?=^General\n|^Video(?: #\d+)?\n|^Audio(?: #\d+)?\n|^Text(?: #\d+)?\n|^Menu\n|\Z)', multiLine: true).allMatches(normalizedOutput);
    final generalMatch = RegExp(r'^General\n([\s\S]*?)(?=^Video(?: #\d+)?\n|^Audio(?: #\d+)?\n|^Text(?: #\d+)?\n|^Menu\n|\Z)', multiLine: true).firstMatch(normalizedOutput);

    String format = '';
    int bitrate = 0;
    List<String> attachments = [];
    List<Map<String, dynamic>> videoStreams = [];
    List<Map<String, dynamic>> audioStreams = [];
    List<Map<String, dynamic>> textStreams = [];

    // --- General section ---
    if (generalMatch != null) {
      final lines = generalMatch.group(1)!.split('\n');
      // Pick the first non-empty Format
      final formats = extractAllValues(lines, 'Format');
      format = formats.isNotEmpty ? formats.first : '';
      // Pick the first valid Overall bit rate
      final bitrates = extractAllValues(lines, 'Overall bit rate');
      bitrate = bitrates.map(parseInt).firstWhere((v) => v > 0, orElse: () => 0);
      // Pick the first non-empty Attachments
      final atts = extractAllValues(lines, 'Attachments');
      if (atts.isNotEmpty) attachments = atts.first.split(' / ').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }

    // --- Video section(s) ---
    for (final match in videoMatches) {
      final lines = match.group(1)!.split('\n');
      final formats = extractAllValues(lines, 'Format');
      final vFormat = formats.isNotEmpty ? formats.first : '';
      final widths = extractAllValues(lines, 'Width');
      final width = widths.isNotEmpty ? parseInt(widths.first) : 0;
      final heights = extractAllValues(lines, 'Height');
      final height = heights.isNotEmpty ? parseInt(heights.first) : 0;
      final aspectRatios = extractAllValues(lines, 'Display aspect ratio');
      final aspectRatio = aspectRatios.isNotEmpty ? parseAspectRatio(aspectRatios[1]) : {'width': 0, 'height': 0};
      final fpss = extractAllValues(lines, 'Frame rate');
      final fps = fpss.isNotEmpty ? parseDouble(fpss[2]) : 0.0;
      final bitrates = extractAllValues(lines, 'Bit rate');
      final vBitrate = bitrates.map(parseInt).firstWhere((v) => v > 0, orElse: () => 0);
      final bitDepths = extractAllValues(lines, 'Bit depth');
      final bitDepth = bitDepths.map(parseInt).firstWhere((v) => v > 0, orElse: () => 0);

      videoStreams.add({
        'format': vFormat,
        'size': {'width': width, 'height': height},
        'aspectRatio': aspectRatio,
        'fps': fps,
        'bitrate': vBitrate,
        'bitDepth': bitDepth,
      });
    }

    // --- Audio section(s) ---
    for (final match in audioMatches) {
      final lines = match.group(1)!.split('\n');
      final formats = extractAllValues(lines, 'Format');
      final aFormat = formats.isNotEmpty ? formats.first : '';
      final bitrates = extractAllValues(lines, 'Bit rate');
      final aBitrate = bitrates.map(parseInt).firstWhere((v) => v > 0, orElse: () => 0);
      final channelsList = extractAllValues(lines, 'Channel(s)');
      final channels = channelsList.isNotEmpty ? parseInt(channelsList.first) : 0;
      final language = extractAllValues(lines, 'Language').firstOrNull ?? '';

      audioStreams.add({'format': aFormat, 'bitrate': aBitrate, 'channels': channels, 'language': language});
    }

    // --- Text section(s) ---
    for (final match in textMatches) {
      final lines = match.group(1)!.split('\n');
      final formats = extractAllValues(lines, 'Format');
      final tFormat = formats.isNotEmpty ? formats.first : '';
      final languages = extractAllValues(lines, 'Language');
      final language = languages.isNotEmpty ? languages.first : '';
      final titles = extractAllValues(lines, 'Title');
      final title = titles.isNotEmpty ? titles.first : null;

      textStreams.add({'format': tFormat, 'language': language, 'title': title});
    }

    return {
      'format': format,
      'bitrate': bitrate,
      'attachments': attachments,
      'videoStreams': videoStreams,
      'audioStreams': audioStreams,
      'textStreams': textStreams,
    };
  }
}
