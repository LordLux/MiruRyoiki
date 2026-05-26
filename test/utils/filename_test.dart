import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/utils/filename.dart';

void main() {
  group('FilenameUtils.sanitize', () {
    test('replaces forbidden Windows chars with dash', () {
      expect(FilenameUtils.sanitize('a<b>c:d"e/f\\g|h?i*j'), 'a-b-c-d-e-f-g-h-i-j');
    });

    test('preserves safe characters', () {
      expect(FilenameUtils.sanitize('Re-ZERO -Starting Life-'), 'Re-ZERO -Starting Life-');
    });

    test('replaces colon with dash', () {
      expect(FilenameUtils.sanitize('Re:ZERO'), 'Re-ZERO');
    });

    test('trims and collapses whitespace', () {
      expect(FilenameUtils.sanitize('  hello   world  '), 'hello world');
    });

    test('strips trailing dots', () {
      expect(FilenameUtils.sanitize('Hello...'), 'Hello');
    });

    test('empty string returns empty', () {
      expect(FilenameUtils.sanitize(''), '');
    });

    test('only punctuation returns empty after strip', () {
      expect(FilenameUtils.sanitize('...'), '');
    });
  });

  group('FilenameUtils.sanitizeForFolder', () {
    test('Frieren: Beyond Journey\'s End — strips after last colon-space', () {
      expect(FilenameUtils.sanitizeForFolder("Frieren: Beyond Journey's End"), "Frieren");
    });

    test('Bleach: Sennen Kessen-hen - Part 2 — strips subtitle and part', () {
      expect(FilenameUtils.sanitizeForFolder('Bleach: Sennen Kessen-hen - Part 2'), 'Bleach');
    });

    test('Attack on Titan Season 3 Part 2 — strips season and part', () {
      expect(FilenameUtils.sanitizeForFolder('Attack on Titan Season 3 Part 2'), 'Attack on Titan');
    });

    test('Kaguya-sama: Love is War - Ultra Romantic — strips after last colon-space', () {
      expect(FilenameUtils.sanitizeForFolder('Kaguya-sama: Love is War - Ultra Romantic'), 'Kaguya-sama');
    });

    test('Re:ZERO - Season 2 — strips season, sanitizes colon', () {
      expect(FilenameUtils.sanitizeForFolder('Re:ZERO -Starting Life in Another World- Season 2'), 'Re-ZERO -Starting Life in Another World-');
    });

    test('No subtitle — title unchanged (modulo sanitize)', () {
      expect(FilenameUtils.sanitizeForFolder('Fullmetal Alchemist'), 'Fullmetal Alchemist');
    });

    test('(TV) stripped', () {
      expect(FilenameUtils.sanitizeForFolder('Hunter x Hunter (TV)'), 'Hunter x Hunter');
    });

    test('Final Season stripped', () {
      expect(FilenameUtils.sanitizeForFolder('Attack on Titan Final Season'), 'Attack on Titan');
    });

    test('Cour 2 stripped', () {
      expect(FilenameUtils.sanitizeForFolder('My Hero Academia Cour 2'), 'My Hero Academia');
    });

    test('Part One stripped', () {
      expect(FilenameUtils.sanitizeForFolder('Something Part One'), 'Something');
    });

    test('2nd Season stripped', () {
      expect(FilenameUtils.sanitizeForFolder('Sword Art Online 2nd Season'), 'Sword Art Online');
    });

    test('empty input', () {
      expect(FilenameUtils.sanitizeForFolder(''), '');
    });

    test('kaguya-sama hyphen preserved', () {
      final result = FilenameUtils.sanitizeForFolder('Kaguya-sama');
      expect(result, 'Kaguya-sama');
    });
  });
}
