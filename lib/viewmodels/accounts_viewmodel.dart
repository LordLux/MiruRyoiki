import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat show Colors;
import 'package:recase/recase.dart';

import '../models/anilist/user_data.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../services/library/library_provider.dart';
import '../services/navigation/show_info.dart';
import '../utils/logging.dart';

/// ViewModel for the Accounts screen.
///
/// Owns the screen's async action states (initial load, metadata/user refresh), the auth actions, the privacy-setting writes and presentation helpers.
///
/// Registered app-wide via `ChangeNotifierProxyProvider2<Library, AnilistProvider, AccountsViewModel>` in `main.dart`.
class AccountsViewModel extends ChangeNotifier {
  late Library _library;
  late AnilistProvider _anilist;
  bool _disposed = false;

  /// Called by the ChangeNotifierProxyProvider2 whenever [Library] or [AnilistProvider] notify
  void update(Library library, AnilistProvider anilist) {
    _library = library;
    _anilist = anilist;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  // Async action states

  bool _isInitialLoading = false;
  bool _isSeriesRefreshing = false;
  bool _isUserRefreshing = false;

  /// Initial user-data load (or an in-flight login)
  bool get isInitialLoading => _isInitialLoading;
  bool get isSeriesRefreshing => _isSeriesRefreshing;
  bool get isUserRefreshing => _isUserRefreshing;

  /// Loads detailed user data once after opening the screen, when logged in but the detailed data isn't cached yet
  Future<void> ensureUserDataLoaded() async {
    if (_anilist.isLoggedIn && _anilist.currentUser?.userData == null) {
      _isInitialLoading = true;
      _notify();

      try {
        await _anilist.refreshUserData();
        await _anilist.refreshUserLists();
      } catch (e, stackTrace) {
        logErr('Error refreshing user data', e, stackTrace);
        snackBar(
          'Failed to refresh user data. Please try again later.',
          severity: InfoBarSeverity.warning,
        );
      }
    }
    _isInitialLoading = false;
    _notify();
  }

  /// Starts the browser-based AniList login flow
  Future<void> login() async {
    _isInitialLoading = true;
    _notify();

    logInfo('User logging in to Anilist...');
    await _anilist.login();

    _isInitialLoading = false;
    _notify();
  }

  /// Cancels an in-flight login attempt
  void cancelLogin() {
    _anilist.cancelLogin();
    _isInitialLoading = false;
    _notify();
  }

  /// Logs out of AniList
  Future<void> logout() async {
    await _anilist.logout();
    _isInitialLoading = false;

    logInfo('User logged out of Anilist');
    _notify();
  }

  /// Refreshes all series metadata from AniList
  Future<void> refreshSeriesMetadata() async {
    if (_isSeriesRefreshing || _anilist.isLoading) return;
    _isSeriesRefreshing = true;
    _notify();

    await _library.refreshAllMetadata();

    _isSeriesRefreshing = false;
    _notify();
  }

  /// Refreshes the user's AniList lists
  Future<void> refreshUserLists() async {
    if (_isUserRefreshing || _anilist.isLoading) return;
    _isUserRefreshing = true;
    _notify();

    await _anilist.refreshUserLists();

    _isUserRefreshing = false;
    _notify();
  }

  // ─── Pure presentation helpers (unit-testable) ───────────────────────────

  /// Formats a minute count into the largest sensible unit:
  /// `(suffix, value)` — e.g. 3000 minutes → (' Days', 2).
  static (String, int) formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final days = hours ~/ 24;

    if (days > 0) return (' Days', days);
    if (hours > 0) return (' Hours', hours);
    return (' Minutes', minutes);
  }

  /// Maps an AniList profile color name to a [Color], with [fallback] for
  /// unknown values.
  static Color parseProfileColor(String color, {required Color fallback}) {
    switch (color.toLowerCase()) {
      case 'blue':
        return mat.Colors.blue;
      case 'purple':
        return mat.Colors.purple;
      case 'pink':
        return mat.Colors.pink;
      case 'orange':
        return mat.Colors.orange;
      case 'red':
        return mat.Colors.red;
      case 'green':
        return mat.Colors.green;
      case 'gray':
      case 'grey':
        return mat.Colors.grey;
      default:
        return fallback;
    }
  }

  /// Aggregates AniList format statistics into a pie-chart data map + total.
  static (Map<String, double>, int) formatDistribution(List<FormatStatistic>? formats) {
    final data = <String, double>{};
    var total = 0;
    for (final format in formats ?? const <FormatStatistic>[]) {
      data[format.formatPretty ?? 'Unknown'] = (format.count ?? 0).toDouble();
      total += format.count ?? 0;
    }
    return (data, total);
  }

  /// Aggregates AniList status statistics into a pie-chart data map + total.
  static (Map<String, double>, int) statusDistribution(List<StatusStatistic>? statuses) {
    final data = <String, double>{};
    var total = 0;
    for (final status in statuses ?? const <StatusStatistic>[]) {
      data[status.statusPretty?.titleCase ?? 'Unknown'] = (status.count ?? 0).toDouble();
      total += status.count ?? 0;
    }
    return (data, total);
  }

  /// Converts AniList "about" markup (a markdown-ish dialect with youtube(),
  /// img220(), spoilers, etc.) into HTML for flutter_html rendering.
  static String convertMarkupToHtml(String text, double maxWidth) {
    // Replace YouTube links
    text = RegExp(r'youtube\(([^)]+)\)').allMatches(text).fold(
          text,
          (t, match) => t.replaceRange(
            match.start,
            match.end,
            '<iframe width="$maxWidth" height="${maxWidth * 0.5625}" src="https://www.youtube.com/embed/${match.group(1)?.split("/").last}" frameborder="0" allow="accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>',
          ),
        );

    // Replace images
    text = RegExp(r'img220\(([^)]+)\)').allMatches(text).fold(
          text,
          (t, match) => t.replaceRange(
            match.start,
            match.end,
            '<img src="${match.group(1)}" style="max-width:220px;" />',
          ),
        );

    // Replace markdown links [text](url)
    text = RegExp(r'\[([^\]]+)\]\(([^)]+)\)').allMatches(text).fold(
          text,
          (t, match) => t.replaceRange(
            match.start,
            match.end,
            '<a href="${match.group(2)}">${match.group(1)}</a>',
          ),
        );

    // Replace webm videos
    text = RegExp(r'webm\(([^)]+)\)').allMatches(text).fold(
          text,
          (t, match) => t.replaceRange(
            match.start,
            match.end,
            '<unsupported>Unfortunately, webm videos are not supported on Flutter Windows</unsupported>',
          ),
        );

    // Replace code blocks with HTML
    text = text.replaceAllMapped(
      RegExp(r'`([\s\S]*?)`', dotAll: true),
      (match) => match.group(1)!,
    );

    // Bold text
    text = text.replaceAllMapped(
      RegExp(r'__([^_]+)__'),
      (match) => '<b>${match.group(1)}</b>',
    );

    // Italic text
    text = text.replaceAllMapped(
      RegExp(r'_([^_]+)_'),
      (match) => '<i>${match.group(1)}</i>',
    );

    // Strikethrough text
    text = text.replaceAllMapped(
      RegExp(r'~~([^~]+)~~'),
      (match) => '<s>${match.group(1)}</s>',
    );

    // Spoiler text
    text = text.replaceAllMapped(
      RegExp(r'~!([^~]+)!~'),
      (match) => '<spoiler>${match.group(1)}</spoiler>',
    );

    // Code blocks
    final codeBlockPattern = RegExp(r'(^> .+$\n?)+', multiLine: true);
    text = text.replaceAllMapped(codeBlockPattern, (match) {
      final codeContent = match.group(0)!.split('\n').where((line) => line.trim().isNotEmpty).map((line) => line.startsWith('> ') ? line.substring(2) : line).join('<br>'); // Use <br> directly for code block newlines
      return '<code>$codeContent</code>';
    });

    // Preserve newlines (convert to HTML line breaks)
    text = text.replaceAll('\n', '<br>');

    return text;
  }
}
