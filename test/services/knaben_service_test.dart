import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:miruryoiki/services/knaben/knaben_service.dart';

void main() {
  group('KnabenRepository.searchEpisode', () {
    test('Standard S01E05 query works instantly and skips fallbacks', () async {
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body);
        if (body['query'] == 'Test Anime S01E05') {
          return http.Response(
              jsonEncode({
                "status": "success",
                "data": [
                  {"title": "[Subs] Test Anime S01E05 1080p.mkv", "magnetUrl": "magnet:?xt=urn:btih:123", "seeders": 150}
                ]
              }),
              200);
        }
        return http.Response('{"status": "success", "data": []}', 200);
      });

      final repo = KnabenRepository(client: mockClient);
      final results = await repo.searchEpisode('Test Anime', season: 1, episode: 5);

      expect(results.length, 1);
      expect(results.first.title, "[Subs] Test Anime S01E05 1080p.mkv");
    });

    test('Anime-specific numbering fallback is triggered if strict fails', () async {
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body);
        final query = body['query'];
        if (query == 'Test Anime S02E10') {
          return http.Response('{"status": "success", "data": []}', 200);
        }
        if (query == 'Test Anime - 10') {
          return http.Response(
              jsonEncode({
                "status": "success",
                "data": [
                  {"title": "Test Anime - 10 [1080p]", "magnetUrl": "magnet:?xt=urn:btih:abc", "seeders": 50}
                ]
              }),
              200);
        }
        return http.Response('{"status": "success", "data": []}', 200);
      });

      final repo = KnabenRepository(client: mockClient);
      final results = await repo.searchEpisode('Test Anime', season: 2, episode: 10);

      expect(results.length, 1);
      expect(results.first.title, "Test Anime - 10 [1080p]");
    });

    test('Loose score fallback excludes false positives like 1080p when searching for ep 10', () async {
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body);
        final query = body['query'];
        if (query == 'Test Anime S02E10' || query == 'Test Anime - 10' || query == 'Test Anime - 10') {
          return http.Response('{"status": "success", "data": []}', 200);
        }

        if (query == 'Test Anime 10') {
          return http.Response(
              jsonEncode({
                "status": "success",
                "data": [
                  {"title": "Test Anime Episode 10 720p", "magnetUrl": "magnet:?1", "seeders": 10},
                  {"title": "Test Anime S02 1080p Batch", "magnetUrl": "magnet:?2", "seeders": 5},
                  {"title": "[Group] Test Anime 10 [x264]", "magnetUrl": "magnet:?3", "seeders": 6},
                  {"title": "Test Anime E10.mkv", "magnetUrl": "magnet:?4", "seeders": 6}
                ]
              }),
              200);
        }
        return http.Response('{"status": "success", "data": []}', 200);
      });

      final repo = KnabenRepository(client: mockClient);
      final results = await repo.searchEpisode('Test Anime', season: 2, episode: 10);

      expect(results.length, 3);
      expect(results.any((r) => r.title.contains('Batch')), false);
    });
  });

  group('KnabenRepository.searchSeason', () {
    test('Season query maps nicely to S01', () async {
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body);
        if (body['query'] == 'Test Anime S01') {
          return http.Response(
              jsonEncode({
                "status": "success",
                "data": [
                  {"title": "Test Anime S01 Complete Batch", "magnetUrl": "magnet:?xt=urn:btih:season", "seeders": 1500}
                ]
              }),
              200);
        }
        return http.Response('{"status": "success", "data": []}', 200);
      });

      final repo = KnabenRepository(client: mockClient);
      final results = await repo.searchSeason('Test Anime', season: 1);

      expect(results.length, 1);
      expect(results.first.title, "Test Anime S01 Complete Batch");
      expect(results.first.isLikelyBatch, isTrue);
    });
  });
}
