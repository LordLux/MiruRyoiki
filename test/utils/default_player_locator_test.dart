// ignore_for_file: avoid_print
@TestOn('windows')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/utils/default_player.dart';

/// Contract test for [DefaultPlayerResolver.locateMpcHc]: it must return either
/// `null` (not installed) or a path that actually exists and looks like MPC-HC.
/// Intentionally does not hard-code a path, so it isn't machine-brittle.
void main() {
  test('locateMpcHc returns an existing MPC-HC path, or null', () {
    final path = DefaultPlayerResolver.locateMpcHc();
    print('locateMpcHc() -> $path');

    if (path != null) {
      expect(File(path).existsSync(), isTrue, reason: 'a discovered path must exist on disk');
      expect(path.toLowerCase(), contains('mpc-hc'), reason: 'should be an MPC-HC executable');
    }
  });
}
