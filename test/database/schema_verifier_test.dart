import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/database/database.dart';

import 'generated/schema.dart';

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('onCreate schema matches the v13 snapshot in drift_schemas/', () async {
    // Opens a brand-new in-memory database (no prior schema, so AppDatabase's
    // migration strategy runs onCreate for real) and diffs the resulting
    // sqlite_schema against the committed v13 snapshot. If someone edits a
    // table without bumping schemaVersion and adding a matching
    // drift_schemas/ snapshot, this fails instead of the mismatch surfacing
    // later as silent corruption for a real user's library.
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 13);
  });
}
