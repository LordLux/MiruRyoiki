import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/services/anilist/queries/anilist_service.dart';
import 'package:miruryoiki/database/database.dart';
import 'package:miruryoiki/database/daos/notifications_dao.dart';
import 'package:miruryoiki/models/notification.dart';
import 'package:mockito/mockito.dart';
import 'package:graphql/client.dart';
import 'package:miruryoiki/manager.dart';
import 'package:miruryoiki/settings.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:miruryoiki/services/connectivity/connectivity_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:miruryoiki/services/anilist/auth.dart';

// Alias to avoid conflict if necessary, though Notification is the Drift class here
// If Notification is ambiguous, we'll need to be specific.
// Usually flutter_test doesn't export Notification widget directly in a way that conflicts easily unless we use it.

// Mock Connectivity
class MockConnectivityStrategy implements ConnectivityStrategy {
  bool _isOffline = false;
  
  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => Stream.value([ConnectivityResult.wifi]);

  @override
  Future<bool> hasInternetAccess() async => !_isOffline;
  
  void setOffline(bool offline) => _isOffline = offline;
}

// Fake DAO
class FakeNotificationsDao extends Fake implements NotificationsDao {
  final List<AnilistNotification> _store = [];
  
  @override
  Future<List<NotificationsTableData>> getRecentNotifications({int limit = 25}) async {
    return _store.take(limit).map((n) => _toDbNotification(n)).toList();
  }
  
  @override
  Future<void> upsertNotifications(List<AnilistNotification> notifications) async {
    for (final n in notifications) {
      final index = _store.indexWhere((e) => e.id == n.id);
      if (index != -1) {
        _store[index] = n;
      } else {
        _store.add(n);
      }
    }
  }
  
  @override
  Future<List<NotificationsTableData>> getNotificationsByIds(List<int> ids) async {
    return _store
        .where((n) => ids.contains(n.id))
        .map((n) => _toDbNotification(n))
        .toList();
  }
  
  @override
  Future<int> getUnreadCount() async {
    return _store.where((n) => !n.isRead).length;
  }
  
  @override
  Future<int> markAsRead(int id) async {
    final index = _store.indexWhere((n) => n.id == id);
    if (index != -1) {
      _store[index] = _store[index].copyWith(isRead: true);
      return 1;
    }
    return 0;
  }
  
  @override
  Future<int> markAllAsRead() async {
    int count = 0;
    for (int i = 0; i < _store.length; i++) {
      if (!_store[i].isRead) {
        _store[i] = _store[i].copyWith(isRead: true);
        count++;
      }
    }
    return count;
  }
  
  @override
  Future<int> deleteOldNotifications({int keepCount = 200}) async {
    if (_store.length > keepCount) {
      final removed = _store.length - keepCount;
      _store.removeRange(keepCount, _store.length);
      return removed;
    }
    return 0;
  }

  NotificationsTableData _toDbNotification(AnilistNotification n) {
    // Default values for nullable fields
    int? animeId;
    int? episode;
    List<String>? contexts;
    int? mediaId;
    String? context;
    String? reason;
    List<String>? deletedMediaTitles;
    String? deletedMediaTitle;
    MediaInfo? mediaInfo;

    if (n is AiringNotification) {
      animeId = n.animeId;
      episode = n.episode;
      contexts = n.contexts;
      mediaInfo = n.media;
    } else if (n is RelatedMediaAdditionNotification) {
      mediaId = n.mediaId;
      context = n.context;
      mediaInfo = n.media;
    } else if (n is MediaDataChangeNotification) {
      mediaId = n.mediaId;
      context = n.context;
      reason = n.reason;
      mediaInfo = n.media;
    } else if (n is MediaMergeNotification) {
      mediaId = n.mediaId;
      context = n.context;
      reason = n.reason;
      deletedMediaTitles = n.deletedMediaTitles;
      mediaInfo = n.media;
    } else if (n is MediaDeletionNotification) {
      context = n.context;
      reason = n.reason;
      deletedMediaTitle = n.deletedMediaTitle;
    }

    return NotificationsTableData(
      id: n.id,
      type: n.type,
      createdAt: n.createdAt,
      isRead: n.isRead,
      animeId: animeId,
      episode: episode,
      contexts: contexts,
      format: null, // Not used in basic mapping for now
      mediaId: mediaId,
      context: context,
      reason: reason,
      deletedMediaTitles: deletedMediaTitles,
      deletedMediaTitle: deletedMediaTitle,
      mediaInfo: mediaInfo,
      localCreatedAt: DateTime.now(),
      localUpdatedAt: DateTime.now(),
    );
  }
}

// Fake Database
class FakeAppDatabase extends Fake implements AppDatabase {
  final FakeNotificationsDao _notificationsDao = FakeNotificationsDao();
  
  @override
  NotificationsDao get notificationsDao => _notificationsDao;
}

// Fake GraphQL Client
class FakeGraphQLClient extends GraphQLClient {
  FakeGraphQLClient() : super(link: Link.function((request, [forward]) => const Stream.empty()), cache: GraphQLCache());
  
  Map<String, dynamic>? responseData;
  
  @override
  Future<QueryResult<T>> query<T>(QueryOptions<T> options) async {
    return QueryResult(
      options: options,
      source: QueryResultSource.network,
      data: responseData ?? {'Page': {'pageInfo': {'hasNextPage': false}, 'notifications': []}},
    );
  }
}

// Mock Auth Service
class MockAnilistAuthService extends Mock implements AnilistAuthService {
  @override
  bool get isAuthenticated => true;
}

void main() {
  late AnilistService service;
  late FakeAppDatabase fakeDb;
  late FakeGraphQLClient fakeClient;
  late MockConnectivityStrategy mockConnectivity;
  late MockAnilistAuthService mockAuthService;

  setUpAll(() async {
    dotenv.testLoad(fileInput: 'ANILIST_CLIENT_ID=dummy\nANILIST_CLIENT_SECRET=dummy');
  });

  setUp(() {
    fakeDb = FakeAppDatabase();
    fakeClient = FakeGraphQLClient();
    mockConnectivity = MockConnectivityStrategy();
    mockAuthService = MockAnilistAuthService();
    
    ConnectivityService().setStrategy(mockConnectivity);
    
    service = AnilistService();
    service.resetCache();
    service.client = fakeClient;
    service.authService = mockAuthService;
    Manager.mockSettings = SettingsManager();
  });

  test('syncNotifications fetches from API and saves to DB', () async {
    // Setup API response
    fakeClient.responseData = {
      '__typename': 'Query',
      'Page': {
        '__typename': 'Page',
        'pageInfo': {
          '__typename': 'PageInfo',
          'hasNextPage': false,
          'total': 1,
          'currentPage': 1,
          'lastPage': 1,
          'perPage': 25
        },
        'notifications': [
          {
            '__typename': 'AiringNotification',
            'id': 1,
            'type': 'AIRING',
            'createdAt': 1234567890,
            'animeId': 100,
            'episode': 1,
            'contexts': ['Episode 1 aired'],
            'media': {
              '__typename': 'Media',
              'id': 100, 
              'type': 'ANIME',
              'format': 'TV',
              'title': {
                '__typename': 'MediaTitle',
                'romaji': 'Test Anime',
                'english': 'Test Anime',
                'native': 'Test Anime'
              },
              'coverImage': {
                '__typename': 'MediaCoverImage',
                'large': 'url',
                'medium': 'url'
              },
              'episodes': 12
            }
          }
        ]
      }
    };

    final result = await service.syncNotifications(database: fakeDb);

    expect(result.length, 1);
    expect(result.first.id, 1);
    expect(result.first, isA<AiringNotification>());
    
    // Verify DB was updated
    final dbNotifications = await fakeDb.notificationsDao.getRecentNotifications();
    expect(dbNotifications.length, 1);
    expect(dbNotifications.first.id, 1);
  });

  test('syncNotifications respects existing read status', () async {
    // 1. Insert a read notification into DB
    final existing = AiringNotification(id: 1, type: NotificationType.AIRING, createdAt: 1000, isRead: true, animeId: 100, episode: 1, contexts: []);
    await fakeDb.notificationsDao.upsertNotifications([existing]);

    // 2. API returns the same notification (which comes as unread by default from API usually)
    fakeClient.responseData = {
      '__typename': 'Query',
      'Page': {
        '__typename': 'Page',
        'pageInfo': {
          '__typename': 'PageInfo',
          'hasNextPage': false,
          'total': 1,
          'currentPage': 1,
          'lastPage': 1,
          'perPage': 25
        },
        'notifications': [
          {
            '__typename': 'AiringNotification',
            'id': 1,
            'type': 'AIRING',
            'createdAt': 1000,
            'animeId': 100,
            'episode': 1,
            'contexts': [],
            'media': {
              '__typename': 'Media',
              'id': 100, 
              'type': 'ANIME',
              'format': 'TV',
              'title': {
                '__typename': 'MediaTitle',
                'romaji': 'Test Anime',
                'english': 'Test Anime',
                'native': 'Test Anime'
              },
              'coverImage': {
                '__typename': 'MediaCoverImage',
                'large': 'url',
                'medium': 'url'
              },
              'episodes': 12
            }
          }
        ]
      }
    };

    final result = await service.syncNotifications(database: fakeDb);

    expect(result.first.isRead, true);
  });

  test('getUnreadCount returns correct count', () async {
    await fakeDb.notificationsDao.upsertNotifications([
      AiringNotification(id: 1, type: NotificationType.AIRING, createdAt: 1000, isRead: false, animeId: 100, episode: 1, contexts: []),
      AiringNotification(id: 2, type: NotificationType.AIRING, createdAt: 1000, isRead: true, animeId: 100, episode: 1, contexts: []),
    ]);

    final count = await service.getUnreadCount(fakeDb);
    expect(count, 1);
  });

  test('markAsRead updates DB', () async {
    await fakeDb.notificationsDao.upsertNotifications([
      AiringNotification(id: 1, type: NotificationType.AIRING, createdAt: 1000, isRead: false, animeId: 100, episode: 1, contexts: []),
    ]);

    await service.markAsRead(fakeDb, 1);

    final notifications = await fakeDb.notificationsDao.getRecentNotifications();
    expect(notifications.first.isRead, true);
  });

  test('syncNotifications filters out non-anime notifications', () async {
    fakeClient.responseData = {
      '__typename': 'Query',
      'Page': {
        '__typename': 'Page',
        'pageInfo': {
          '__typename': 'PageInfo',
          'hasNextPage': false,
          'total': 2,
          'currentPage': 1,
          'lastPage': 1,
          'perPage': 25
        },
        'notifications': [
          {
            '__typename': 'AiringNotification',
            'id': 1,
            'type': 'AIRING',
            'createdAt': 1234567890,
            'animeId': 100,
            'episode': 1,
            'contexts': ['Episode 1 aired'],
            'media': {
              '__typename': 'Media',
              'id': 100, 
              'type': 'ANIME',
              'format': 'TV',
              'title': {
                '__typename': 'MediaTitle',
                'romaji': 'Anime Title', 
                'english': 'Anime Title', 
                'native': 'Anime Title'
              },
              'coverImage': {
                '__typename': 'MediaCoverImage',
                'large': 'url', 
                'medium': 'url'
              },
              'episodes': 12
            }
          },
          {
            '__typename': 'AiringNotification',
            'id': 2,
            'type': 'AIRING',
            'createdAt': 1234567891,
            'animeId': 101,
            'episode': 1,
            'contexts': ['Chapter 1 released'],
            'media': {
              '__typename': 'Media',
              'id': 101, 
              'type': 'MANGA',
              'format': 'MANGA',
              'title': {
                '__typename': 'MediaTitle',
                'romaji': 'Manga Title', 
                'english': 'Manga Title', 
                'native': 'Manga Title'
              },
              'coverImage': {
                '__typename': 'MediaCoverImage',
                'large': 'url', 
                'medium': 'url'
              },
              'episodes': null
            }
          }
        ]
      }
    };

    final result = await service.syncNotifications(database: fakeDb);

    expect(result.length, 1);
    expect(result.first.id, 1);
    expect(result.first, isA<AiringNotification>());
    expect((result.first as AiringNotification).media?.title, 'Anime Title');
  });
}
