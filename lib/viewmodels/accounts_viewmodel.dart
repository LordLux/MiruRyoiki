import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat show Colors;
import 'package:recase/recase.dart';

import '../models/anilist/user_data.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../services/library/library_provider.dart';
import '../services/navigation/show_info.dart';
import '../utils/logging.dart';
import 'disposable_view_model.dart';

/// ViewModel for the Accounts screen.
///
/// Owns the screen's async action states (initial load, metadata/user refresh), the auth actions, the privacy-setting writes and presentation helpers.
///
/// Registered app-wide via `ChangeNotifierProxyProvider2<Library, AnilistProvider, AccountsViewModel>` in `main.dart`.
class AccountsViewModel extends DisposableViewModel {
  late Library _library;
  late AnilistProvider _anilist;

  /// Called by the ChangeNotifierProxyProvider2 whenever [Library] or [AnilistProvider] notify
  void update(Library library, AnilistProvider anilist) {
    _library = library;
    _anilist = anilist;
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
      notifySafe();

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
    notifySafe();
  }

  /// Starts the browser-based AniList login flow
  Future<void> login() async {
    _isInitialLoading = true;
    notifySafe();

    logInfo('User logging in to Anilist...');
    await _anilist.login();

    _isInitialLoading = false;
    notifySafe();
  }

  /// Cancels an in-flight login attempt
  void cancelLogin() {
    _anilist.cancelLogin();
    _isInitialLoading = false;
    notifySafe();
  }

  /// Logs out of AniList
  Future<void> logout() async {
    await _anilist.logout();
    _isInitialLoading = false;

    logInfo('User logged out of Anilist');
    notifySafe();
  }

  /// Refreshes all series metadata from AniList
  Future<void> refreshSeriesMetadata() async {
    if (_isSeriesRefreshing || _anilist.isLoading) return;
    _isSeriesRefreshing = true;
    notifySafe();

    await _library.refreshAllMetadata();

    _isSeriesRefreshing = false;
    notifySafe();
  }

  /// Refreshes the user's AniList lists
  Future<void> refreshUserLists() async {
    if (_isUserRefreshing || _anilist.isLoading) return;
    _isUserRefreshing = true;
    notifySafe();

    await _anilist.refreshUserLists();

    _isUserRefreshing = false;
    notifySafe();
  }

  // Pure presentation helpers

  /// Formats a minute count into the largest sensible unit:
  /// `(suffix, value)` — e.g. 3000 minutes → (' Days', 2).
  static (String, int) formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final days = hours ~/ 24;

    if (days > 0) return (' Days', days);
    if (hours > 0) return (' Hours', hours);
    return (' Minutes', minutes);
  }

  /// Maps an AniList profile color name to a [Color], with [fallback] for unknown values
  static Color parseProfileColor(String color, {required Color fallback}) {
    return switch (color.toLowerCase()) {
      'blue'   => mat.Colors.blue,
      'purple' => mat.Colors.purple,
      'pink'   => mat.Colors.pink,
      'orange' => mat.Colors.orange,
      'red'    => mat.Colors.red,
      'green'  => mat.Colors.green,
      'gray' || 'grey' => mat.Colors.grey,
      _ => fallback,
    };
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
