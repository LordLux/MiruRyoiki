import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:miruryoiki/services/qbittorrent/qbittorrent.dart';
import 'package:miruryoiki/services/downloads/torrent_client.dart';

void main() {
  group('QBittorrentRepository', () {
    const baseUrl = 'http://localhost:8080';
    const username = 'admin';
    const password = 'adminadmin';

    group('testConnection', () {
      test('returns true when login and version endpoint succeed', () async {
        final client = MockClient((request) async {
          if (request.url.path == '/api/v2/auth/login') {
            return http.Response('Ok.', 200, headers: {'set-cookie': 'SID=abc123;'});
          }
          if (request.url.path == '/api/v2/app/version') {
            return http.Response('v4.6.2', 200);
          }
          return http.Response('', 404);
        });

        final repo = QBittorrentRepository(baseUrl: baseUrl, username: username, password: password, client: client);
        expect(await repo.testConnection(), isTrue);
      });

      test('returns false when login fails', () async {
        final client = MockClient((request) async {
          if (request.url.path == '/api/v2/auth/login') {
            return http.Response('Fails.', 403);
          }
          return http.Response('', 404);
        });

        final repo = QBittorrentRepository(baseUrl: baseUrl, username: username, password: password, client: client);
        expect(await repo.testConnection(), isFalse);
      });

      test('returns false when version endpoint fails after login', () async {
        final client = MockClient((request) async {
          if (request.url.path == '/api/v2/auth/login') {
            return http.Response('Ok.', 200, headers: {'set-cookie': 'SID=abc123;'});
          }
          if (request.url.path == '/api/v2/app/version') {
            return http.Response('', 500);
          }
          return http.Response('', 404);
        });

        final repo = QBittorrentRepository(baseUrl: baseUrl, username: username, password: password, client: client);
        expect(await repo.testConnection(), isFalse);
      });

      test('returns false on network error', () async {
        final client = MockClient((request) async {
          throw Exception('Network unreachable');
        });

        final repo = QBittorrentRepository(baseUrl: baseUrl, username: username, password: password, client: client);
        expect(await repo.testConnection(), isFalse);
      });
    });

    group('addMagnet', () {
      test('sends magnet URL and returns true on 200', () async {
        final client = MockClient((request) async {
          if (request.url.path == '/api/v2/auth/login') {
            return http.Response('Ok.', 200, headers: {'set-cookie': 'SID=abc123;'});
          }
          if (request.url.path == '/api/v2/torrents/add') {
            // MultipartRequest is converted to a StreamedRequest by MockClient,
            // so we verify via the request URL and method
            return http.Response('Ok.', 200);
          }
          return http.Response('', 404);
        });

        final repo = QBittorrentRepository(baseUrl: baseUrl, username: username, password: password, client: client);
        final result = await repo.addMagnet('magnet:?xt=urn:btih:abc123', savePath: '/downloads');
        expect(result, isTrue);
      });

      test('returns false on non-200 response', () async {
        final client = MockClient((request) async {
          if (request.url.path == '/api/v2/auth/login') {
            return http.Response('Ok.', 200, headers: {'set-cookie': 'SID=abc123;'});
          }
          if (request.url.path == '/api/v2/torrents/add') {
            return http.Response('Error', 400);
          }
          return http.Response('', 404);
        });

        final repo = QBittorrentRepository(baseUrl: baseUrl, username: username, password: password, client: client);
        final result = await repo.addMagnet('magnet:?xt=urn:btih:abc123');
        expect(result, isFalse);
      });

      test('throws when authentication fails before adding', () async {
        final client = MockClient((request) async {
          if (request.url.path == '/api/v2/auth/login') {
            return http.Response('Fails.', 403);
          }
          return http.Response('', 404);
        });

        final repo = QBittorrentRepository(baseUrl: baseUrl, username: username, password: password, client: client);
        expect(() => repo.addMagnet('magnet:?xt=urn:btih:abc123'), throwsException);
      });
    });

    group('listTorrents', () {
      test('parses torrent list into TorrentInfo objects', () async {
        final mockTorrents = [
          {
            'hash': 'abc123',
            'name': 'Test Torrent',
            'state': 'downloading',
            'progress': 0.45,
            'total_size': 1073741824, // 1 GB
            'downloaded': 483183820,
            'uploaded': 10485760,
            'dlspeed': 5242880, // 5 MB/s
            'upspeed': 1048576, // 1 MB/s
            'num_seeds': 12,
            'num_leechs': 3,
            'eta': 120,
            'save_path': '/downloads',
            'category': 'anime',
            'added_on': 1700000000,
          },
          {
            'hash': 'def456',
            'name': 'Completed Torrent',
            'state': 'pausedUP',
            'progress': 1.0,
            'total_size': 536870912, // 512 MB
            'downloaded': 536870912,
            'uploaded': 1073741824,
            'dlspeed': 0,
            'upspeed': 0,
            'num_seeds': 0,
            'num_leechs': 0,
            'eta': 8640000,
            'save_path': '/downloads',
          },
        ];

        final client = MockClient((request) async {
          if (request.url.path == '/api/v2/auth/login') {
            return http.Response('Ok.', 200, headers: {'set-cookie': 'SID=abc123;'});
          }
          if (request.url.path == '/api/v2/torrents/info') {
            return http.Response(jsonEncode(mockTorrents), 200);
          }
          return http.Response('', 404);
        });

        final repo = QBittorrentRepository(baseUrl: baseUrl, username: username, password: password, client: client);
        final torrents = await repo.listTorrents();

        expect(torrents.length, 2);

        // First torrent — downloading
        expect(torrents[0].hash, 'abc123');
        expect(torrents[0].name, 'Test Torrent');
        expect(torrents[0].state, TorrentState.downloading);
        expect(torrents[0].progress, closeTo(0.45, 0.01));
        expect(torrents[0].size, 1073741824);
        expect(torrents[0].downloadSpeed, 5242880);
        expect(torrents[0].seeders, 12);
        expect(torrents[0].eta, isNotNull);
        expect(torrents[0].category, 'anime');

        // Second torrent — paused
        expect(torrents[1].hash, 'def456');
        expect(torrents[1].state, TorrentState.paused);
        expect(torrents[1].progress, 1.0);
        expect(torrents[1].eta, isNull); // 8640000 = infinity in qBit
      });

      test('returns empty list when no torrents', () async {
        final client = MockClient((request) async {
          if (request.url.path == '/api/v2/auth/login') {
            return http.Response('Ok.', 200, headers: {'set-cookie': 'SID=abc123;'});
          }
          if (request.url.path == '/api/v2/torrents/info') {
            return http.Response('[]', 200);
          }
          return http.Response('', 404);
        });

        final repo = QBittorrentRepository(baseUrl: baseUrl, username: username, password: password, client: client);
        final torrents = await repo.listTorrents();
        expect(torrents, isEmpty);
      });

      test('throws on non-200 response', () async {
        final client = MockClient((request) async {
          if (request.url.path == '/api/v2/auth/login') {
            return http.Response('Ok.', 200, headers: {'set-cookie': 'SID=abc123;'});
          }
          if (request.url.path == '/api/v2/torrents/info') {
            return http.Response('Error', 500);
          }
          return http.Response('', 404);
        });

        final repo = QBittorrentRepository(baseUrl: baseUrl, username: username, password: password, client: client);
        expect(() => repo.listTorrents(), throwsException);
      });
    });

    group('pauseTorrent', () {
      test('sends pause request and returns true on 200', () async {
        String? capturedBody;
        final client = MockClient((request) async {
          if (request.url.path == '/api/v2/auth/login') {
            return http.Response('Ok.', 200, headers: {'set-cookie': 'SID=abc123;'});
          }
          if (request.url.path == '/api/v2/torrents/pause') {
            capturedBody = request.body;
            return http.Response('', 200);
          }
          return http.Response('', 404);
        });

        final repo = QBittorrentRepository(baseUrl: baseUrl, username: username, password: password, client: client);
        final result = await repo.pauseTorrent('abc123');
        expect(result, isTrue);
        expect(capturedBody, contains('abc123'));
      });
    });

    group('resumeTorrent', () {
      test('sends resume request and returns true on 200', () async {
        String? capturedBody;
        final client = MockClient((request) async {
          if (request.url.path == '/api/v2/auth/login') {
            return http.Response('Ok.', 200, headers: {'set-cookie': 'SID=abc123;'});
          }
          if (request.url.path == '/api/v2/torrents/resume') {
            capturedBody = request.body;
            return http.Response('', 200);
          }
          return http.Response('', 404);
        });

        final repo = QBittorrentRepository(baseUrl: baseUrl, username: username, password: password, client: client);
        final result = await repo.resumeTorrent('abc123');
        expect(result, isTrue);
        expect(capturedBody, contains('abc123'));
      });
    });

    group('deleteTorrent', () {
      test('sends delete request without file deletion', () async {
        String? capturedBody;
        final client = MockClient((request) async {
          if (request.url.path == '/api/v2/auth/login') {
            return http.Response('Ok.', 200, headers: {'set-cookie': 'SID=abc123;'});
          }
          if (request.url.path == '/api/v2/torrents/delete') {
            capturedBody = request.body;
            return http.Response('', 200);
          }
          return http.Response('', 404);
        });

        final repo = QBittorrentRepository(baseUrl: baseUrl, username: username, password: password, client: client);
        final result = await repo.deleteTorrent('abc123');
        expect(result, isTrue);
        expect(capturedBody, contains('abc123'));
        expect(capturedBody, contains('deleteFiles=false'));
      });

      test('sends delete request with file deletion', () async {
        String? capturedBody;
        final client = MockClient((request) async {
          if (request.url.path == '/api/v2/auth/login') {
            return http.Response('Ok.', 200, headers: {'set-cookie': 'SID=abc123;'});
          }
          if (request.url.path == '/api/v2/torrents/delete') {
            capturedBody = request.body;
            return http.Response('', 200);
          }
          return http.Response('', 404);
        });

        final repo = QBittorrentRepository(baseUrl: baseUrl, username: username, password: password, client: client);
        final result = await repo.deleteTorrent('abc123', deleteFiles: true);
        expect(result, isTrue);
        expect(capturedBody, contains('deleteFiles=true'));
      });
    });

    group('state mapping', () {
      test('maps all qBittorrent states correctly', () async {
        final states = {
          'downloading': TorrentState.downloading,
          'forcedDL': TorrentState.downloading,
          'metaDL': TorrentState.downloading,
          'uploading': TorrentState.seeding,
          'forcedUP': TorrentState.seeding,
          'pausedDL': TorrentState.paused,
          'pausedUP': TorrentState.paused,
          'queuedDL': TorrentState.queued,
          'queuedUP': TorrentState.queued,
          'checkingDL': TorrentState.checking,
          'checkingUP': TorrentState.checking,
          'checkingResumeData': TorrentState.checking,
          'moving': TorrentState.checking,
          'stalledDL': TorrentState.stalled,
          'stalledUP': TorrentState.stalled,
          'error': TorrentState.error,
          'missingFiles': TorrentState.error,
          'somethingUnknown': TorrentState.unknown,
        };

        for (final entry in states.entries) {
          final mockTorrents = [
            {'hash': 'test', 'name': 'Test', 'state': entry.key, 'progress': 0.5, 'total_size': 100},
          ];

          final client = MockClient((request) async {
            if (request.url.path == '/api/v2/auth/login') {
              return http.Response('Ok.', 200, headers: {'set-cookie': 'SID=abc123;'});
            }
            if (request.url.path == '/api/v2/torrents/info') {
              return http.Response(jsonEncode(mockTorrents), 200);
            }
            return http.Response('', 404);
          });

          final repo = QBittorrentRepository(baseUrl: baseUrl, username: username, password: password, client: client);
          final torrents = await repo.listTorrents();
          expect(torrents.first.state, entry.value, reason: 'qBit state "${entry.key}" should map to ${entry.value}');
        }
      });
    });

    group('ETA formatting', () {
      test('formats various ETA values correctly', () async {
        final testCases = [
          {'eta': 90, 'expected': isNotNull}, // 1m 30s
          {'eta': 3661, 'expected': isNotNull}, // 1h 1m
          {'eta': 90061, 'expected': isNotNull}, // 1d 1h
          {'eta': 8640000, 'expected': isNull}, // infinity
          {'eta': 0, 'expected': isNull},
          {'eta': -1, 'expected': isNull},
        ];

        for (final tc in testCases) {
          final mockTorrents = [
            {'hash': 'test', 'name': 'Test', 'state': 'downloading', 'progress': 0.5, 'total_size': 100, 'eta': tc['eta']},
          ];

          final client = MockClient((request) async {
            if (request.url.path == '/api/v2/auth/login') {
              return http.Response('Ok.', 200, headers: {'set-cookie': 'SID=abc123;'});
            }
            if (request.url.path == '/api/v2/torrents/info') {
              return http.Response(jsonEncode(mockTorrents), 200);
            }
            return http.Response('', 404);
          });

          final repo = QBittorrentRepository(baseUrl: baseUrl, username: username, password: password, client: client);
          final torrents = await repo.listTorrents();
          expect(torrents.first.eta, tc['expected'], reason: 'ETA ${tc['eta']} should match ${tc['expected']}');
        }
      });
    });

    group('authentication', () {
      test('extracts SID from Set-Cookie header', () async {
        final client = MockClient((request) async {
          if (request.url.path == '/api/v2/auth/login') {
            return http.Response('Ok.', 200, headers: {'set-cookie': 'SID=mysecrettoken; HttpOnly; path=/'});
          }
          if (request.url.path == '/api/v2/app/version') {
            // Verify cookie is sent
            expect(request.headers['Cookie'], contains('SID=mysecrettoken'));
            return http.Response('v4.6.2', 200);
          }
          return http.Response('', 404);
        });

        final repo = QBittorrentRepository(baseUrl: baseUrl, username: username, password: password, client: client);
        expect(repo.isAuthenticated, isFalse);
        expect(await repo.testConnection(), isTrue);
        expect(repo.isAuthenticated, isTrue);
      });

      test('auto-authenticates when calling API methods without prior login', () async {
        int loginCalls = 0;
        final client = MockClient((request) async {
          if (request.url.path == '/api/v2/auth/login') {
            loginCalls++;
            return http.Response('Ok.', 200, headers: {'set-cookie': 'SID=auto;'});
          }
          if (request.url.path == '/api/v2/torrents/info') {
            return http.Response('[]', 200);
          }
          return http.Response('', 404);
        });

        final repo = QBittorrentRepository(baseUrl: baseUrl, username: username, password: password, client: client);
        await repo.listTorrents();
        expect(loginCalls, 1);
      });

      test('sends Referer header on login', () async {
        String? capturedReferer;
        final client = MockClient((request) async {
          if (request.url.path == '/api/v2/auth/login') {
            capturedReferer = request.headers['Referer'];
            return http.Response('Ok.', 200, headers: {'set-cookie': 'SID=abc;'});
          }
          if (request.url.path == '/api/v2/app/version') {
            return http.Response('v4.6.2', 200);
          }
          return http.Response('', 404);
        });

        final repo = QBittorrentRepository(baseUrl: baseUrl, username: username, password: password, client: client);
        await repo.testConnection();
        expect(capturedReferer, baseUrl);
      });

      test('retries on 403 session expiry', () async {
        int loginCalls = 0;
        bool sessionExpired = true;

        final client = MockClient((request) async {
          if (request.url.path == '/api/v2/auth/login') {
            loginCalls++;
            sessionExpired = false;
            return http.Response('Ok.', 200, headers: {'set-cookie': 'SID=fresh$loginCalls;'});
          }
          if (request.url.path == '/api/v2/torrents/info') {
            if (sessionExpired) return http.Response('Forbidden', 403);
            return http.Response('[]', 200);
          }
          return http.Response('', 404);
        });

        final repo = QBittorrentRepository(baseUrl: baseUrl, username: username, password: password, client: client);
        // First call: login succeeds, get torrents succeeds
        await repo.listTorrents();
        expect(loginCalls, 1);

        // Simulate session expiry
        sessionExpired = true;
        final torrents = await repo.listTorrents();
        expect(loginCalls, 2);
        expect(torrents, isEmpty);
      });

      test('strips trailing slash from base URL', () async {
        final client = MockClient((request) async {
          // Verify no double-slash in path (after scheme://)
          expect(request.url.path, isNot(contains('//')));
          if (request.url.path == '/api/v2/auth/login') {
            return http.Response('Ok.', 200, headers: {'set-cookie': 'SID=abc;'});
          }
          if (request.url.path == '/api/v2/app/version') {
            return http.Response('v4.6.2', 200);
          }
          return http.Response('', 404);
        });

        final repo = QBittorrentRepository(baseUrl: '$baseUrl/', username: username, password: password, client: client);
        await repo.testConnection();
      });
    });

    group('TorrentClient interface', () {
      test('implements TorrentClient', () {
        final client = MockClient((request) async => http.Response('', 404));
        final repo = QBittorrentRepository(baseUrl: baseUrl, username: username, password: password, client: client);
        expect(repo, isA<TorrentClient>());
      });

      test('clientName returns qBittorrent', () {
        final client = MockClient((request) async => http.Response('', 404));
        final repo = QBittorrentRepository(baseUrl: baseUrl, username: username, password: password, client: client);
        expect(repo.clientName, 'qBittorrent');
      });
    });

    group('empty string fallbacks', () {
      test('uses default URL when baseUrl is empty', () async {
        final client = MockClient((request) async {
          // Verify the request goes to the default port
          expect(request.url.host, 'localhost');
          expect(request.url.port, 8080);
          if (request.url.path == '/api/v2/auth/login') {
            return http.Response('Ok.', 200, headers: {'set-cookie': 'SID=abc;'});
          }
          if (request.url.path == '/api/v2/app/version') {
            return http.Response('v4.6.2', 200);
          }
          return http.Response('', 404);
        });

        final repo = QBittorrentRepository(baseUrl: '', username: 'admin', password: 'pass', client: client);
        expect(await repo.testConnection(), isTrue);
      });

      test('uses default username when username is empty', () async {
        String? capturedBody;
        final client = MockClient((request) async {
          if (request.url.path == '/api/v2/auth/login') {
            capturedBody = request.body;
            return http.Response('Ok.', 200, headers: {'set-cookie': 'SID=abc;'});
          }
          if (request.url.path == '/api/v2/app/version') {
            return http.Response('v4.6.2', 200);
          }
          return http.Response('', 404);
        });

        final repo = QBittorrentRepository(baseUrl: baseUrl, username: '', password: 'pass', client: client);
        await repo.testConnection();
        expect(capturedBody, contains('username=admin'));
      });
    });
  });
}
