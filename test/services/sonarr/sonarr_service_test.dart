import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:miruryoiki/models/sonarr/sonarr_series.dart';
import 'package:miruryoiki/services/sonarr/sonarr_service.dart';

import 'sonarr_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;
  late SonarrRepository service;

  setUp(() {
    mockClient = MockClient();
    service = SonarrRepository(
      baseUrl: 'http://localhost:8989',
      apiKey: 'test-api-key',
      client: mockClient,
    );
  });

  group('SonarrSeries Model', () {
    test('Parses from full JSON', () {
      final json = {
        'id': 100,
        'title': 'Test Anime',
        'tvdbId': 12345,
        'status': 'ended',
        'monitored': true,
        'qualityProfileId': 1,
        'statistics': {
          'seasonCount': 2,
          'episodeCount': 24,
          'episodeFileCount': 10,
        }
      };
      
      final series = SonarrSeries.fromJson(json);
      expect(series.id, 100);
      expect(series.title, 'Test Anime');
      expect(series.tvdbId, 12345);
      expect(series.status, 'ended');
      expect(series.monitored, isTrue);
      expect(series.qualityProfileId, 1);
      expect(series.seasonCount, 2);
      expect(series.episodeCount, 24);
      expect(series.episodeFileCount, 10);
      expect(series.isComplete, isFalse);
    });

    test('Parses Skyhook Lookup JSON without ids gracefully', () {
      final json = {
        'title': 'Frieren',
        'tvdbId': 54321,
        'seasonCount': 1,
      };
      
      final series = SonarrSeries.fromJson(json);
      expect(series.id, 0); // Skyhook lookup results don't have Sonarr IDs until added; default should be 0 here
      expect(series.title, 'Frieren');
      expect(series.tvdbId, 54321);
      expect(series.monitored, isFalse);
    });

    test('Identifies completion correctly', () {
      expect(SonarrSeries.fromJson({'statistics': {'episodeCount': 10, 'episodeFileCount': 10}}).isComplete, isTrue);
      expect(SonarrSeries.fromJson({'statistics': {'episodeCount': 10, 'episodeFileCount': 5}}).isComplete, isFalse);
      expect(SonarrSeries.fromJson({'statistics': {'episodeCount': 0, 'episodeFileCount': 0}}).isComplete, isFalse);
    });
  });

  group('SonarrRepository Logic', () {
    test('lookupSeries fetches and parses properly', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async => http.Response(
        '[{"title": "Lookup Anime", "tvdbId": 123}]',
        200
      ));

      final results = await service.lookupSeries('Anime');
      
      final verifyResult = verify(mockClient.get(captureAny, headers: captureAnyNamed('headers')));
      final Uri uri = verifyResult.captured[0] as Uri;
      final Map<String, String>? headers = verifyResult.captured[1] as Map<String, String>?;

      expect(uri.toString(), 'http://localhost:8989/api/v3/series/lookup?term=Anime');
      expect(headers?['X-Api-Key'], 'test-api-key');

      expect(results.length, 1);
      expect(results.first.title, 'Lookup Anime');
      expect(results.first.tvdbId, 123);
      expect(results.first.id, 0);
    });

    test('lookupSeries throws on error', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async => http.Response('Error', 500));
      expect(service.lookupSeries('Anime'), throwsException);
    });

    test('ensureSeriesExists returns ID if series already exists', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async => http.Response('[{"id": 99, "tvdbId": 123}]', 200));

      final id = await service.ensureSeriesExists(tvdbId: 123, title: 'Anime', rootFolderPath: '/path', qualityProfileId: 1);
      expect(id, 99);
      
      // Post should never be called
      verifyNever(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')));
    });

    test('ensureSeriesExists posts and returns ID if series does not exist', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async => http.Response('[]', 200));
      when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('{"id": 42}', 201));

      final id = await service.ensureSeriesExists(tvdbId: 123, title: 'Anime', rootFolderPath: '/path', qualityProfileId: 2);
      expect(id, 42);
      
      final verifyResult = verify(mockClient.post(
        captureAny,
        headers: captureAnyNamed('headers'),
        body: captureAnyNamed('body'),
      ));
      
      final Uri postUri = verifyResult.captured[0] as Uri;
      final Map<String, String>? postHeaders = verifyResult.captured[1] as Map<String, String>?;
      final String postBodyStr = verifyResult.captured[2] as String;
      final Map<String, dynamic> postBody = json.decode(postBodyStr);
      
      expect(postUri.toString(), 'http://localhost:8989/api/v3/series');
      expect(postHeaders?['X-Api-Key'], 'test-api-key');
      expect(postBody['tvdbId'], 123);
      expect(postBody['title'], 'Anime');
      expect(postBody['rootFolderPath'], '/path');
      expect(postBody['qualityProfileId'], 2);
      expect(postBody['seriesType'], 'anime');
    });
  });
}
