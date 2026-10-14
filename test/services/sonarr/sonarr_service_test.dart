import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'dart:io';
import 'dart:async';
import 'package:miruryoiki/models/sonarr/sonarr_episode.dart';
import 'package:miruryoiki/services/sonarr/sonarr_exceptions.dart';
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

    test('1.3 Missing Statistics Block', () {
      final json = {
        'id': 100,
        'title': 'Test Anime',
        'tvdbId': 12345,
        'statistics': null // Or missing completely
      };
      
      final series = SonarrSeries.fromJson(json);
      expect(series.seasonCount, 0);
      expect(series.episodeCount, 0);
      expect(series.episodeFileCount, 0);
      expect(series.isComplete, isFalse);
    });

    test('1.4 Partial Data Handling', () {
      final json = {
        'id': 101,
      };
      
      final series = SonarrSeries.fromJson(json);
      expect(series.id, 101);
      expect(series.title, 'Unknown');
      expect(series.status, 'unknown');
      expect(series.qualityProfileId, 0);
    });

    test('1.1 & 1.4 SonarrEpisode Partial Data', () {
      final json = {
        'id': 99,
        // Missing overview, airDateUtc, etc.
      };
      final episode = SonarrEpisode.fromJson(json);
      expect(episode.id, 99);
      expect(episode.episodeNumber, 0);
      expect(episode.title, 'Unknown');
      expect(episode.hasFile, false);
      expect(episode.monitored, true); // fallback default is true
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
      expect(service.lookupSeries('Anime'), throwsA(isA<SonarrServerException>()));
    });

    test('2.1 Fetch Root Folders', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async => http.Response(
        '[{"id": 1, "path": "/data/media/anime"}]',
        200
      ));

      final results = await service.getRootFolders();
      
      final verifyResult = verify(mockClient.get(captureAny, headers: captureAnyNamed('headers')));
      final Uri uri = verifyResult.captured[0] as Uri;
      
      expect(uri.path, '/api/v3/rootfolder');
      expect(results.length, 1);
      expect(results.first.id, 1);
      expect(results.first.path, '/data/media/anime');
    });

    test('2.2 Fetch Quality Profiles', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async => http.Response(
        '[{"id": 1, "name": "Any"}]',
        200
      ));

      final results = await service.getQualityProfiles();
      
      final verifyResult = verify(mockClient.get(captureAny, headers: captureAnyNamed('headers')));
      final Uri uri = verifyResult.captured[0] as Uri;
      
      expect(uri.path, '/api/v3/qualityprofile');
      expect(results.length, 1);
      expect(results.first.id, 1);
      expect(results.first.name, 'Any');
    });

    test('2.3 Fetch Episodes by Series', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async => http.Response(
        '[{"id": 500, "seasonNumber": 1, "episodeNumber": 1, "title": "Pilot"}]',
        200
      ));

      final results = await service.getEpisodes(123);
      
      final verifyResult = verify(mockClient.get(captureAny, headers: captureAnyNamed('headers')));
      final Uri uri = verifyResult.captured[0] as Uri;
      final Map<String, String>? headers = verifyResult.captured[1] as Map<String, String>?;
      
      expect(uri.path, '/api/v3/episode');
      expect(uri.queryParameters['seriesId'], '123');
      // 5.1 & 5.3 Idempotency of GETs and Header check
      expect(headers?['X-Api-Key'], 'test-api-key');
      
      expect(results.length, 1);
      expect(results.first.id, 500);
      expect(results.first.seasonNumber, 1);
      expect(results.first.episodeNumber, 1);
    });

    test('4.1 401 Unauthorized', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async => http.Response('Unauthorized', 401));
      
      expect(service.lookupSeries('Anime'), throwsA(isA<SonarrUnauthorizedException>()));
    });

    test('4.2 400 Bad Request extracts error message', () async {
      when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response(
          '[{"errorMessage": "Path is already configured for another series"}]',
          400
        ));
      
      // We force a POST by making the GET return empty
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async => http.Response('[]', 200));

      try {
        await service.ensureSeriesExists(tvdbId: 1, title: 'Test', rootFolderPath: '/path', qualityProfileId: 1);
        fail('Should have thrown');
      } catch (e) {
        expect(e, isA<SonarrBadRequestException>());
        expect((e as SonarrBadRequestException).message, 'Path is already configured for another series');
      }
    });

    test('4.3 404 Not Found', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async => http.Response('Not Found', 404));
      
      expect(service.getEpisodes(999), throwsA(isA<SonarrNotFoundException>()));
    });

    test('4.4 500 Internal Server Error', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async => http.Response('Server Error', 500));
      
      expect(service.getEpisodes(999), throwsA(isA<SonarrServerException>()));
    });

    test('4.5 Socket/Timeout Exception', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenThrow(SocketException('Failed to connect'));
      expect(service.getEpisodes(999), throwsA(isA<SonarrConnectionException>()));

      when(mockClient.get(any, headers: anyNamed('headers'))).thenThrow(TimeoutException('Timed out'));
      expect(service.getEpisodes(999), throwsA(isA<SonarrConnectionException>()));

      when(mockClient.get(any, headers: anyNamed('headers'))).thenThrow(http.ClientException('Connection closed'));
      expect(service.getEpisodes(999), throwsA(isA<SonarrConnectionException>()));
    });

    test('4.6 Non-JSON 200 body (e.g. reverse proxy login page)', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async => http.Response('<html>Login</html>', 200));

      expect(service.getEpisodes(999), throwsA(isA<SonarrException>()));
    });

    test('5.2 Content-Type for POSTs', () async {
      when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('', 201));

      await service.manualImport(files: []);

      final verifyResult = verify(mockClient.post(
        captureAny,
        headers: captureAnyNamed('headers'),
        body: captureAnyNamed('body'),
      ));

      final Map<String, String>? headers = verifyResult.captured[1] as Map<String, String>?;
      expect(headers?['Content-Type'], 'application/json');
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

    test('manualImport posts the explicit Sonarr ManualImport payload', () async {
      when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('', 201));

      await service.manualImport(
        files: [
          {
            'path': '/absolute/path/to/the/file.mkv',
            'folder': '/absolute/path/to/the/folder/',
            'seriesId': 123,
            'episodeIds': [456],
            'quality': {
              'quality': {'id': 7, 'name': 'Bluray-1080p'},
              'revision': {'version': 1, 'real': 0},
            },
          },
        ],
      );

      final verifyResult = verify(mockClient.post(
        captureAny,
        headers: captureAnyNamed('headers'),
        body: captureAnyNamed('body'),
      ));

      final Map<String, String>? headers = verifyResult.captured[1] as Map<String, String>?;
      final String body = verifyResult.captured[2] as String;
      final Map<String, dynamic> payload = json.decode(body);

      expect(headers?['X-Api-Key'], 'test-api-key');
      expect(payload['name'], 'ManualImport');
      expect(payload['importMode'], 'Copy');
      expect(payload['files'][0]['path'], '/absolute/path/to/the/file.mkv');
      expect(payload['files'][0]['folder'], '/absolute/path/to/the/folder/');
      expect(payload['files'][0]['seriesId'], 123);
      expect(payload['files'][0]['episodeIds'], [456]);
      expect(payload['files'][0]['quality'], {
        'quality': {'id': 7, 'name': 'Bluray-1080p'},
        'revision': {'version': 1, 'real': 0},
      });
    });
  });
}
