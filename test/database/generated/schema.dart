// dart format width=80
// GENERATED CODE, DO NOT EDIT BY HAND.
// ignore_for_file: type=lint
import 'package:drift/drift.dart';
import 'package:drift/internal/migrations.dart';
import 'schema_v13.dart' as v13;

class GeneratedHelper implements SchemaInstantiationHelper {
  @override
  GeneratedDatabase databaseForVersion(QueryExecutor db, int version) {
    switch (version) {
      case 13:
        return v13.DatabaseAtV13(db);
      default:
        throw MissingSchemaException(version, versions);
    }
  }

  static const versions = const [13];
}
