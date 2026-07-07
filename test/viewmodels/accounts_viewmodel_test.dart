import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat show Colors;
import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/models/anilist/user_data.dart';
import 'package:miruryoiki/viewmodels/accounts_viewmodel.dart';

/// Pure-logic tests for [AccountsViewModel]'s static presentation helpers.
void main() {
  group('formatMinutes', () {
    test('picks the largest sensible unit', () {
      expect(AccountsViewModel.formatMinutes(30), (' Minutes', 30));
      expect(AccountsViewModel.formatMinutes(120), (' Hours', 2));
      expect(AccountsViewModel.formatMinutes(3000), (' Days', 2)); // 50h → 2 days
      expect(AccountsViewModel.formatMinutes(0), (' Minutes', 0));
    });
  });

  group('parseProfileColor', () {
    const fallback = Color(0xFF123456);

    test('maps known AniList color names', () {
      expect(AccountsViewModel.parseProfileColor('blue', fallback: fallback), mat.Colors.blue);
      expect(AccountsViewModel.parseProfileColor('Purple', fallback: fallback), mat.Colors.purple);
      expect(AccountsViewModel.parseProfileColor('GRAY', fallback: fallback), mat.Colors.grey);
      expect(AccountsViewModel.parseProfileColor('grey', fallback: fallback), mat.Colors.grey);
    });

    test('unknown values fall back', () {
      expect(AccountsViewModel.parseProfileColor('#ffcc00', fallback: fallback), fallback);
      expect(AccountsViewModel.parseProfileColor('', fallback: fallback), fallback);
    });
  });

  group('distributions', () {
    test('formatDistribution aggregates counts and total', () {
      final (data, total) = AccountsViewModel.formatDistribution([
        FormatStatistic(format: 'TV', count: 80),
        FormatStatistic(format: 'MOVIE', count: 15),
        FormatStatistic(format: null, count: 5),
      ]);

      expect(data, {'TV': 80.0, 'Movie': 15.0, 'Unknown': 5.0});
      expect(total, 100);
    });

    test('null/empty input yields empty data', () {
      expect(AccountsViewModel.formatDistribution(null), (<String, double>{}, 0));
      expect(AccountsViewModel.statusDistribution(null), (<String, double>{}, 0));
    });
  });

  group('convertMarkupToHtml', () {
    test('youtube() becomes an iframe embed', () {
      final html = AccountsViewModel.convertMarkupToHtml('youtube(https://youtu.be/abc123)', 400);
      expect(html, contains('<iframe'));
      expect(html, contains('https://www.youtube.com/embed/abc123'));
      expect(html, contains('width="400.0"'));
    });

    test('img220() becomes a bounded img tag', () {
      final html = AccountsViewModel.convertMarkupToHtml('img220(https://x/y.png)', 400);
      expect(html, '<img src="https://x/y.png" style="max-width:220px;" />');
    });

    test('markdown links, bold, italic, strikethrough, spoiler', () {
      expect(
        AccountsViewModel.convertMarkupToHtml('[AniList](https://anilist.co)', 400),
        '<a href="https://anilist.co">AniList</a>',
      );
      expect(AccountsViewModel.convertMarkupToHtml('__bold__', 400), '<b>bold</b>');
      expect(AccountsViewModel.convertMarkupToHtml('_italic_', 400), '<i>italic</i>');
      expect(AccountsViewModel.convertMarkupToHtml('~~gone~~', 400), '<s>gone</s>');
      expect(AccountsViewModel.convertMarkupToHtml('~!secret!~', 400), '<spoiler>secret</spoiler>');
    });

    test('webm() is replaced with an unsupported notice', () {
      final html = AccountsViewModel.convertMarkupToHtml('webm(https://x/v.webm)', 400);
      expect(html, contains('<unsupported>'));
    });

    test('quote blocks become code blocks and newlines become <br>', () {
      final html = AccountsViewModel.convertMarkupToHtml('> line1\n> line2\nplain', 400);
      expect(html, contains('<code>line1<br>line2</code>'));
      expect(html, contains('<br>plain'));
    });
  });
}
