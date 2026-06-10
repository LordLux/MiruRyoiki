import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/services/players/slave/mpc_slave_payload.dart';

/// Exercises the REAL slave-API parsing used in production
/// (`mpc_slave_payload.dart`) so the test breaks if the protocol handling
/// changes. No FFI or running player involved.
void main() {
  group('splitMpcFields', () {
    test('splits a plain pipe-delimited payload', () {
      expect(
        splitMpcFields('Title|Author|Desc|C:\\v.mkv|1234'),
        ['Title', 'Author', 'Desc', 'C:\\v.mkv', '1234'],
      );
    });

    test('always returns at least one field', () {
      expect(splitMpcFields(''), ['']);
      expect(splitMpcFields('solo'), ['solo']);
    });

    test('preserves empty fields', () {
      expect(splitMpcFields('a||c'), ['a', '', 'c']);
      expect(splitMpcFields('|'), ['', '']);
    });

    test(r'treats \| as a literal pipe, not a separator', () {
      expect(splitMpcFields(r'Foo \| Bar|next'), ['Foo | Bar', 'next']);
    });

    test(r'treats \\ as a literal backslash', () {
      expect(splitMpcFields(r'a\\b|c'), [r'a\b', 'c']);
    });

    test('a trailing lone backslash is kept verbatim', () {
      expect(splitMpcFields('a\\'), ['a\\']);
    });
  });

  group('parseMpcSeconds', () {
    test('parses integer and fractional seconds', () {
      expect(parseMpcSeconds('12'), const Duration(seconds: 12));
      expect(parseMpcSeconds('12.345'), const Duration(milliseconds: 12345));
      expect(parseMpcSeconds(' 5 '), const Duration(seconds: 5));
    });

    test('returns zero for empty, malformed, or negative input', () {
      expect(parseMpcSeconds(''), Duration.zero);
      expect(parseMpcSeconds('abc'), Duration.zero);
      expect(parseMpcSeconds('-3'), Duration.zero);
    });
  });

  group('MpcNowPlaying.parse', () {
    test('maps the five fields and parses the duration', () {
      final np = MpcNowPlaying.parse('Ep 1|Studio|A show|M:\\anime\\ep1.mkv|1440.5');
      expect(np.title, 'Ep 1');
      expect(np.author, 'Studio');
      expect(np.description, 'A show');
      expect(np.file, 'M:\\anime\\ep1.mkv');
      expect(np.duration, const Duration(milliseconds: 1440500));
    });

    test('tolerates missing trailing fields', () {
      final np = MpcNowPlaying.parse('Just a title');
      expect(np.title, 'Just a title');
      expect(np.file, '');
      expect(np.duration, Duration.zero);
    });

    test(r'keeps an escaped pipe inside a title', () {
      final np = MpcNowPlaying.parse(r'A \| B|Studio|d|f.mkv|10');
      expect(np.title, 'A | B');
      expect(np.file, 'f.mkv');
    });
  });

  group('MpcLoadState.fromCode', () {
    test('maps native indices', () {
      expect(MpcLoadState.fromCode(0), MpcLoadState.closed);
      expect(MpcLoadState.fromCode(2), MpcLoadState.loaded);
      expect(MpcLoadState.fromCode(4), MpcLoadState.failing);
    });

    test('returns null for out-of-range codes', () {
      expect(MpcLoadState.fromCode(-1), isNull);
      expect(MpcLoadState.fromCode(99), isNull);
    });
  });

  group('MpcPlayState', () {
    test('maps native indices', () {
      expect(MpcPlayState.fromCode(0), MpcPlayState.play);
      expect(MpcPlayState.fromCode(1), MpcPlayState.pause);
      expect(MpcPlayState.fromCode(2), MpcPlayState.stop);
      expect(MpcPlayState.fromCode(3), MpcPlayState.unused);
    });

    test('isPlaying is true only for PS_PLAY', () {
      expect(MpcPlayState.play.isPlaying, isTrue);
      expect(MpcPlayState.pause.isPlaying, isFalse);
      expect(MpcPlayState.stop.isPlaying, isFalse);
    });

    test('returns null for out-of-range codes', () {
      expect(MpcPlayState.fromCode(7), isNull);
    });
  });

  group('command code values match MpcApi.h', () {
    test('notifications', () {
      expect(MpcCommand.connect, 0x50000000);
      expect(MpcCommand.state, 0x50000001);
      expect(MpcCommand.playMode, 0x50000002);
      expect(MpcCommand.nowPlaying, 0x50000003);
      expect(MpcCommand.currentPosition, 0x50000007);
      expect(MpcCommand.notifySeek, 0x50000008);
      expect(MpcCommand.notifyEndOfStream, 0x50000009);
      expect(MpcCommand.disconnect, 0x5000000B);
    });

    test('host commands', () {
      expect(MpcCommand.openFile, 0xA0000000);
      expect(MpcCommand.stop, 0xA0000001);
      expect(MpcCommand.playPause, 0xA0000003);
      expect(MpcCommand.play, 0xA0000004);
      expect(MpcCommand.pause, 0xA0000005);
      expect(MpcCommand.setPosition, 0xA0002000);
      expect(MpcCommand.getCurrentPosition, 0xA0003004);
      expect(MpcCommand.jumpOfNSeconds, 0xA0003005);
    });
  });
}
