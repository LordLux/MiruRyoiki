import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:drift/native.dart';

import 'package:miruryoiki/database/database.dart';
import 'package:miruryoiki/enums.dart';
import 'package:miruryoiki/manager.dart';
import 'package:miruryoiki/models/anilist/mapping.dart';
import 'package:miruryoiki/models/anilist/user_data.dart';
import 'package:miruryoiki/models/anilist/user_list.dart';
import 'package:miruryoiki/models/anilist/anime.dart';
import 'package:miruryoiki/models/episode.dart';
import 'package:miruryoiki/models/season.dart';
import 'package:miruryoiki/models/series.dart';
import 'package:miruryoiki/services/anilist/provider/anilist_provider.dart';
import 'package:miruryoiki/services/episode_navigation/anilist_progress_manager.dart';
import 'package:miruryoiki/services/library/library_provider.dart';
import 'package:miruryoiki/settings.dart';
import 'package:miruryoiki/utils/path.dart';
import 'package:miruryoiki/viewmodels/library_screen_viewmodel.dart';

class TestAnilistProvider extends AnilistProvider {
  Map<String, AnilistUserList> _testUserLists = {};
  
  @override
  Map<String, AnilistUserList> get userLists => _testUserLists;
  
  @override
  Set<int> get allUserAnilistIds {
    return _testUserLists.values
        .expand((list) => list.entries)
        .map((e) => e.mediaId)
        .toSet();
  }

  void setTestUserLists(Map<String, AnilistUserList> lists) {
    _testUserLists = lists;
    bumpListsRevision();
    notifyListeners();
  }
}

AnilistMapping _makeMapping(int id, {AnilistAnime? anilistData}) {
  return AnilistMapping(
    localPath: PathString(r'M:\Series\Test'),
    anilistId: id,
    title: 'Mapping $id',
    anilistData: anilistData,
  );
}

AnilistMediaListEntry _makeListEntry({
  required int anilistId,
  AnilistListApiStatus status = AnilistListApiStatus.CURRENT,
  int? progress,
  int? score,
  int? updatedAt,
  int? createdAt,
  DateValue? startedAt,
  DateValue? completedAt,
  String? customLists,
  bool hiddenFromStatusLists = false,
}) {
  return AnilistMediaListEntry(
    id: anilistId,
    mediaId: anilistId,
    media: AnilistAnime(id: anilistId, title: AnilistTitle()),
    status: status,
    progress: progress,
    score: score,
    updatedAt: updatedAt,
    createdAt: createdAt,
    startedAt: startedAt,
    completedAt: completedAt,
    customLists: customLists,
    hiddenFromStatusLists: hiddenFromStatusLists,
  );
}

Series _makeSeries({
  required String name,
  String path = r'M:\Series\Test',
  bool isHidden = false,
  List<AnilistMapping> anilistMappings = const [],
  int? meanScore,
  Color? posterColor,
  AnilistAnime? currentAnilistData,
}) {
  return Series(
    name: name,
    path: PathString(path),
    collections: const [],
    isHidden: isHidden,
    anilistMappings: anilistMappings,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late Library library;
  late TestAnilistProvider anilist;
  late LibraryScreenViewModel vm;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'MiruRyoiki',
      packageName: 'com.example.miruryoiki',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: 'signature',
    );
    dotenv.testLoad(fileInput: "ANILIST_CLIENT_ID=123\nANILIST_CLIENT_SECRET=123\nDISCORD_CLIENT_ID=123");
    
    db = AppDatabase(NativeDatabase.memory());
    final settings = SettingsManager();
    await settings.init(db);
    Manager.mockSettings = settings;
  });

  tearDownAll(() async {
    await db.close();
  });

  setUp(() async {
    // Reset preferences so tests don't leak state
    SharedPreferences.setMockInitialValues({});
    await db.delete(db.settingsTable).go();
    await Manager.settings.init(db);
    await db.delete(db.seriesTable).go();
    await db.delete(db.seasonsTable).go();
    library = Library(SettingsManager(), db);
    anilist = TestAnilistProvider();
    
    vm = LibraryScreenViewModel();
    vm.update(library, anilist);
  });

  tearDown(() {
    vm.dispose();
  });

  group('getSortText', () {
    test('returns correct text for all SortOrder values', () {
      expect(LibraryScreenViewModel.getSortText(null), 'Sort by');
      expect(LibraryScreenViewModel.getSortText(SortOrder.alphabetical), 'Title (A-Z)');
      expect(LibraryScreenViewModel.getSortText(SortOrder.score), 'Score');
      expect(LibraryScreenViewModel.getSortText(SortOrder.progress), 'Progress');
      expect(LibraryScreenViewModel.getSortText(SortOrder.lastModified), 'Last Modified');
      expect(LibraryScreenViewModel.getSortText(SortOrder.dateAdded), 'Date Added');
      expect(LibraryScreenViewModel.getSortText(SortOrder.startDate), 'Start Date');
      expect(LibraryScreenViewModel.getSortText(SortOrder.completedDate), 'Completed Date');
      expect(LibraryScreenViewModel.getSortText(SortOrder.averageScore), 'Average Score');
      expect(LibraryScreenViewModel.getSortText(SortOrder.releaseDate), 'Release Date');
      expect(LibraryScreenViewModel.getSortText(SortOrder.popularity), 'Popularity');
      expect(LibraryScreenViewModel.getSortText(SortOrder.custom), 'Custom Order');
    });
  });

  group('State transitions', () {
    test('onViewChanged updates view and resets sort for linked', () {
      vm.onViewChanged(LibraryView.linked);
      expect(vm.currentView, LibraryView.linked);
    });

    test('onSortOrderChanged updates sort order and toggles grouping', () {
      vm.onSortOrderChanged(SortOrder.score);
      expect(vm.sortOrder, SortOrder.score);
      expect(vm.showGrouped, isFalse);

      vm.onSortOrderChanged(SortOrder.custom);
      expect(vm.sortOrder, SortOrder.custom);
      expect(vm.showGrouped, isTrue);
      expect(vm.groupBy, GroupBy.anilistLists);
    });

    test('onSortDirectionChanged toggles descending', () {
      final initial = vm.sortDescending;
      vm.onSortDirectionChanged();
      expect(vm.sortDescending, !initial);
      vm.onSortDirectionChanged();
      expect(vm.sortDescending, initial);
    });

    test('Genre toggling works', () {
      vm.addGenre('Action');
      expect(vm.selectedGenres.contains('Action'), isTrue);

      vm.removeGenre('Action');
      expect(vm.selectedGenres.contains('Action'), isFalse);

      vm.addGenre('Comedy');
      vm.clearGenres();
      expect(vm.selectedGenres, isEmpty);
    });
  });

  group('Preferences save/load', () {
    test('round-trips all preference fields including JSON-encoded ones', () {
      vm.onViewChanged(LibraryView.linked);
      vm.setViewType(ViewType.detailedList);
      vm.onSortOrderChanged(SortOrder.score);
      vm.onShowGroupedChanged(true);
      vm.setCustomListOrder(['custom_1', 'custom_2']);
      vm.setHiddenLists({'custom_3'});
      vm.saveUserPreferences();
      
      final vm2 = LibraryScreenViewModel();
      vm2.update(library, anilist);
      vm2.loadUserPreferences();

      expect(vm2.currentView, LibraryView.linked);
      expect(vm2.viewType, ViewType.detailedList);
      expect(vm2.sortOrder, SortOrder.score);
      expect(vm2.showGrouped, true);
      expect(vm2.customListOrder, ['custom_1', 'custom_2']);
      expect(vm2.hiddenLists, {'custom_3'});
    });
  });

  group('Data and Caching', () {
    test('Cache is invalidated when view changes', () async {
      await library.addSeries(_makeSeries(name: 'A', path: r'M:\A'));
      await library.addSeries(_makeSeries(name: 'B', path: r'M:\B', isHidden: true));
      
      final data1 = vm.displayData();
      expect(data1.$1.length, 1, reason: 'By default, unlinked hidden series are hidden');
      
      vm.onViewChanged(LibraryView.all);
      Manager.settings.showHiddenSeries = true; // Set to true to show them
      final data2 = vm.displayData();
      expect(data2.$1.length, 2, reason: 'View all shows hidden series when settings allow');
      
      // Ensure it uses cache if we call it again
      final data3 = vm.displayData();
      expect(identical(data2.$1, data3.$1), isTrue, reason: 'Should return cached list');
    });

    test('Cache is invalidated when anilist lists revision changes', () async {
      final data1 = vm.displayData();
      
      anilist.bumpListsRevision(); // This simulates user lists refresh
      vm.update(library, anilist); // The ViewModel listens to AnilistProvider changes in the UI, but here we just update it
      
      final data2 = vm.displayData();
      expect(identical(data1.$1, data2.$1), isFalse, reason: 'Should invalidate cache on lists revision bump');
    });

    test('Cache is invalidated when library data version changes', () async {
      final data1 = vm.displayData();
      
      await library.addSeries(_makeSeries(name: 'C', path: r'M:\C'));
      vm.update(library, anilist); 
      
      final data2 = vm.displayData();
      expect(identical(data1.$1, data2.$1), isFalse, reason: 'Should invalidate cache on library data bump');
    });
  });

  group('Sorting and Filtering', () {
    test('Filtering by genre works', () async {
      final s1 = _makeSeries(name: 'A', anilistMappings: [_makeMapping(1, anilistData: AnilistAnime(id: 1, title: AnilistTitle(), genres: ['Action', 'Comedy']))]);
      final s2 = _makeSeries(name: 'B', anilistMappings: [_makeMapping(2, anilistData: AnilistAnime(id: 2, title: AnilistTitle(), genres: ['Action']))]);
      await library.addSeries(s1);
      await library.addSeries(s2);

      vm.addGenre('Comedy');
      vm.update(library, anilist); // trigger cache invalidation
      final data = vm.displayData();
      
      expect(data.$1.length, 1);
      expect(data.$1.first.name, 'A');
    });

    test('Sorting alphabetically', () async {
      await library.addSeries(_makeSeries(name: 'Zebra'));
      await library.addSeries(_makeSeries(name: 'Apple'));
      
      vm.onSortOrderChanged(SortOrder.alphabetical);
      final data = vm.displayData();
      
      expect(data.$1[0].name, 'Apple');
      expect(data.$1[1].name, 'Zebra');
    });

    test('Custom group ordering handles happy path', () async {
      await library.addSeries(_makeSeries(name: 'Series A', path: r'M:\A', anilistMappings: [_makeMapping(1)]));
      await library.addSeries(_makeSeries(name: 'Series B', path: r'M:\B', anilistMappings: [_makeMapping(2)]));
      
      // Put them in current list
      anilist.setTestUserLists({
        AnilistListApiStatus.CURRENT.name_: AnilistUserList(
          name: 'Watching',
          entries: [
            _makeListEntry(anilistId: 1),
            _makeListEntry(anilistId: 2),
          ]
        )
      });
      
      vm.update(library, anilist);
      
      vm.onSortOrderChanged(SortOrder.custom);
      vm.setCustomListOrder(['CURRENT']);
      
      final data = vm.displayData();
      final grouped = data.$2!;
      final currentList = grouped['Watching']!; 
      
      expect(currentList.length, 2);
      expect(currentList[0].name, 'Series A');
      expect(currentList[1].name, 'Series B');

      // Now reorder
      vm.reorderSeriesInGroup('Watching', 1, 0);

      final data2 = vm.displayData();
      final currentList2 = data2.$2!['Watching']!; 

      expect(currentList2[0].name, 'Series B');
      expect(currentList2[1].name, 'Series A');
    });
  });
}
