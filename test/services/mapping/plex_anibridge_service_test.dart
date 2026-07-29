import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:miruryoiki/models/mappings/plex_mapping.dart';
import 'package:miruryoiki/services/mapping/plex_anibridge_service.dart';

import 'plex_anibridge_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('plex_anibridge_test');
    const MethodChannel('plugins.flutter.io/path_provider').setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') return tempDir.path;
      return null;
    });
  });

  tearDown(() async {
    const MethodChannel('plugins.flutter.io/path_provider').setMockMethodCallHandler(null);
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  group('PlexMapping.fromJson — parsing correctness (highest blast-radius surface)', () {
    test('extracts tvdbId and single season', () {
      final mapping = PlexMapping.fromJson('101', {
        'tvdb_id': 12345,
        'tvdb_mappings': {'s1': 'e1-e12'},
      });

      expect(mapping.anilistId, 101);
      expect(mapping.tvdbId, 12345);
      expect(mapping.tvdbSeasons, [1]);
    });

    test('extracts multiple seasons in declared order', () {
      final mapping = PlexMapping.fromJson('202', {
        'tvdb_id': 500,
        'tvdb_mappings': {'s1': 'e1-e12', 's2': 'e13-'},
      });

      expect(mapping.tvdbSeasons, containsAll([1, 2]));
      expect(mapping.tvdbSeasons.length, 2);
    });

    test('defaults to season 1 when tvdb_mappings is missing', () {
      final mapping = PlexMapping.fromJson('303', {'tvdb_id': 777});
      expect(mapping.tvdbSeasons, [1]);
    });

    test('defaults to season 1 when tvdb_mappings has no season-prefixed keys', () {
      final mapping = PlexMapping.fromJson('304', {
        'tvdb_id': 777,
        'tvdb_mappings': {'notASeasonKey': 'e1-e12'},
      });
      expect(mapping.tvdbSeasons, [1]);
    });

    test('defaults tvdbId to 0 when missing', () {
      final mapping = PlexMapping.fromJson('404', {});
      expect(mapping.tvdbId, 0);
    });

    test('parses optional tmdbShowId when present', () {
      final mapping = PlexMapping.fromJson('505', {
        'tvdb_id': 1,
        'tmdb_show_id': 999,
      });
      expect(mapping.tmdbShowId, 999);
    });

    test('tmdbShowId is null when absent', () {
      final mapping = PlexMapping.fromJson('606', {'tvdb_id': 1});
      expect(mapping.tmdbShowId, isNull);
    });
  });

  group('PlexAniBridgeService', () {
    late MockClient mockClient;
    late PlexAniBridgeService service;

    setUp(() {
      mockClient = MockClient();
      service = PlexAniBridgeService(client: mockClient);
    });

    test('forceRefresh populates the cache and writes it to disk on success', () async {
      final body = jsonEncode({
        '101': {
          'tvdb_id': 111,
          'tvdb_mappings': {'s1': 'e1-e12'},
        },
      });
      when(mockClient.get(any)).thenAnswer((_) async => http.Response(body, 200));

      await service.forceRefresh();

      final mapping = await service.getMapping(101);
      expect(mapping, isNotNull);
      expect(mapping!.tvdbId, 111);

      final cacheFile = File('${tempDir.path}/plex_mappings_cache.json');
      expect(await cacheFile.exists(), isTrue);
      expect(await cacheFile.readAsString(), body);
    });

    test('forceRefresh on a non-200 response leaves the mapping cache empty rather than stale/crashing', () async {
      when(mockClient.get(any)).thenAnswer((_) async => http.Response('Service Unavailable', 503));

      await service.forceRefresh();

      final mapping = await service.getMapping(101);
      expect(mapping, isNull);
    });

    test('forceRefresh on a network exception does not throw and leaves an empty cache', () async {
      when(mockClient.get(any)).thenThrow(const SocketException('no network'));

      await expectLater(service.forceRefresh(), completes);

      final mapping = await service.getMapping(101);
      expect(mapping, isNull);
    });

    test('getMapping loads from an existing local cache file without hitting the network', () async {
      final cacheFile = File('${tempDir.path}/plex_mappings_cache.json');
      await cacheFile.writeAsString(jsonEncode({
        '202': {
          'tvdb_id': 222,
          'tvdb_mappings': {'s1': 'e1-e24'},
        },
      }));

      final mapping = await service.getMapping(202);

      expect(mapping, isNotNull);
      expect(mapping!.tvdbId, 222);
      verifyNever(mockClient.get(any));
    });

    test('getMapping returns null for an AniList ID absent from the mappings', () async {
      when(mockClient.get(any)).thenAnswer((_) async => http.Response('{}', 200));

      final mapping = await service.getMapping(999999);

      expect(mapping, isNull);
    });
  });
}
