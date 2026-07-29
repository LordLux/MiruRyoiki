import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:miruryoiki/services/mapping/custom_sonarr_mapping_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CustomSonarrMappingService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = CustomSonarrMappingService();
  });

  test('getCustomTvdbId returns null when no mapping was ever saved', () async {
    expect(await service.getCustomTvdbId(1), isNull);
  });

  test('saveCustomTvdbId then getCustomTvdbId round-trips the mapping', () async {
    await service.saveCustomTvdbId(101, 5551);

    expect(await service.getCustomTvdbId(101), 5551);
  });

  test('saving a mapping for one AniList ID does not affect another', () async {
    await service.saveCustomTvdbId(101, 5551);

    expect(await service.getCustomTvdbId(202), isNull);
  });

  test('saving a new mapping overwrites a stale one for the same AniList ID', () async {
    await service.saveCustomTvdbId(101, 5551);
    await service.saveCustomTvdbId(101, 9999);

    expect(await service.getCustomTvdbId(101), 9999);
  });

  test('multiple mappings persist independently across calls', () async {
    await service.saveCustomTvdbId(101, 5551);
    await service.saveCustomTvdbId(202, 6662);
    await service.saveCustomTvdbId(303, 7773);

    expect(await service.getCustomTvdbId(101), 5551);
    expect(await service.getCustomTvdbId(202), 6662);
    expect(await service.getCustomTvdbId(303), 7773);
  });

  test('mappings persist across separate service instances backed by the same prefs store', () async {
    await service.saveCustomTvdbId(101, 5551);

    final otherInstance = CustomSonarrMappingService();
    expect(await otherInstance.getCustomTvdbId(101), 5551);
  });
}
