import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/database/database.dart';

void main() {
  test('a drift_schemas/ snapshot exists for the current schemaVersion', () {
    // SchemaVerifier only catches "the live schema drifted from the latest
    // committed snapshot" — it says nothing if schemaVersion was bumped and
    // the matching drift_schema_vN.json was never added at all (verifier_test
    // would keep comparing against a now-stale older snapshot number). This
    // check catches that gap directly: it fails loudly the moment a snapshot
    // file is missing, instead of migrations.dart's runtime migrate silently
    // producing an unverified schema for real users.
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final version = db.schemaVersion;

    final snapshot = File('drift_schemas/drift_schema_v$version.json');

    expect(
      snapshot.existsSync(),
      isTrue,
      reason: 'Missing drift_schemas/drift_schema_v$version.json for schemaVersion $version. '
          'Run: dart run drift_dev schema dump lib/database/database.dart drift_schemas/ '
          'then regenerate test/database/generated/ and update schema_verifier_test.dart.',
    );
  });
}
