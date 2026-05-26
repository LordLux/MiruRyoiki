import 'path.dart';

class FilenameUtils {
  /// Replace Windows-forbidden characters and control chars with `-`; strip reserved
  /// device names and trailing dots/spaces.
  ///
  /// Collapses internal whitespace and trims
  static String sanitize(String input) {
    if (input.isEmpty) return input;
    final dashed = input.replaceAll(
      RegExp(PathString.forbiddenWindowsCharsPattern, caseSensitive: false),
      '-',
    );
    final stripped = dashed.replaceAll(
      RegExp(PathString.reservedWindowsNameOrTrailingPattern, caseSensitive: false),
      '',
    );
    return stripped.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Sanitize and also strip common season/part/cour suffixes
  ///
  /// Applied in this order, end of string only, case-insensitive:
  /// 1. If the title has a `: ` , strip from the LAST occurrence onward (keep earlier ones, sanitized)
  /// 2. Strip media-type parens: (`TV`), (`Movie`), (`OVA`), (`ONA`), (`Special`), (`Dub`), (`Sub`), (`Uncut`)
  /// 3. Strip season keywords: `Season N`, `S\d+`, `N(st|nd|rd|th) Season`, `Final Season`
  /// 4. Strip part/cour: `Part N`, `Part (One|Two|Three|Four)`, `Cour N`
  /// 5. Strip ` - SUBTITLE` only when the subtitle itself contains a season/part keyword
  static String sanitizeForFolder(String input) {
    if (input.isEmpty) return input;

    var s = input.trim();

    // 1. Handle "colon space" pattern — strip from last ": " onward
    final colonIdx = s.lastIndexOf(': ');
    if (colonIdx > 0) {
      // Keep the part before the last ": " and sanitize any earlier colons
      s = s.substring(0, colonIdx);
    }

    // 2. Strip media-type parens
    s = s.replaceAll(RegExp(r'\s*\((TV|Movie|OVA|ONA|Special|Dub|Sub|Uncut)\)\s*$', caseSensitive: false), '').trim();

    // 3 & 4. Strip season/part/cour suffixes in a loop (handles "Season 3 Part 2" cases)
    final seasonPattern = RegExp(
      r'\s*(?:Final\s+Season|\d+(?:st|nd|rd|th)\s+Season|Season\s+\d+|S\d+)\s*$',
      caseSensitive: false,
    );
    final partPattern = RegExp(
      r'\s*(?:Part\s+(?:\d+|One|Two|Three|Four)|Cour\s+\d+)\s*$',
      caseSensitive: false,
    );
    String prev;
    do {
      prev = s;
      s = s.replaceAll(seasonPattern, '').trim();
      s = s.replaceAll(partPattern, '').trim();
    } while (s != prev);

    // 5. Strip " - subtitle" only when the subtitle contains a season/part keyword
    final dashPattern = RegExp(
      r'\s+-\s+(?:.*?(?:Season|Part|Cour|Final).*?)$',
      caseSensitive: false,
    );
    s = s.replaceAll(dashPattern, '').trim();

    // Strip trailing " -" or "- " artifacts
    s = s.replaceAll(RegExp(r'\s+-\s*$'), '').trim();

    return sanitize(s);
  }
}
