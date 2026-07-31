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
import 'package:miruryoiki/models/anilist/user_list.dart';
import 'package:miruryoiki/models/anilist/anime.dart';
import 'package:miruryoiki/models/series.dart';
import 'package:miruryoiki/services/anilist/provider/anilist_provider.dart';
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
  Color? posterColor,
}) {
  return Series(
    name: name,
    path: PathString(path),
    collections: const [],
    isHidden: isHidden,
    anilistMappings: anilistMappings,
    posterColor: posterColor,
  );
}

/// Verifies `vm.displayData()` returns [namesAscending] in that exact order,
/// then toggles sort direction and verifies the exact reverse.
void expectSortedBothDirections(LibraryScreenViewModel vm, List<String> namesAscending) {
  final ascending = vm.displayData().$1.map((s) => s.name).toList();
  expect(ascending, namesAscending, reason: 'ascending order');

  vm.onSortDirectionChanged();
  final descending = vm.displayData().$1.map((s) => s.name).toList();
  expect(descending, namesAscending.reversed.toList(), reason: 'descending order should be the exact reverse');
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

  group('_sortSeries', () {
    test('sorts by score ascending and descending', () async {
      await library.addSeries(_makeSeries(
        name: 'A',
        path: r'M:\A',
        anilistMappings: [_makeMapping(1, anilistData: AnilistAnime(id: 1, title: AnilistTitle(), meanScore: 50))],
      ));
      await library.addSeries(_makeSeries(
        name: 'B',
        path: r'M:\B',
        anilistMappings: [_makeMapping(2, anilistData: AnilistAnime(id: 2, title: AnilistTitle(), meanScore: 90))],
      ));
      vm.update(library, anilist);
      vm.onSortOrderChanged(SortOrder.score);

      expectSortedBothDirections(vm, ['A', 'B']);
    });

    test('sorts by progress ascending and descending', () async {
      await library.addSeries(_makeSeries(
        name: 'A',
        path: r'M:\A',
        anilistMappings: [_makeMapping(1, anilistData: AnilistAnime(id: 1, title: AnilistTitle(), episodes: 10))],
      ));
      await library.addSeries(_makeSeries(
        name: 'B',
        path: r'M:\B',
        anilistMappings: [_makeMapping(2, anilistData: AnilistAnime(id: 2, title: AnilistTitle(), episodes: 10))],
      ));
      anilist.setTestUserLists({
        AnilistListApiStatus.CURRENT.name_: AnilistUserList(
          name: 'Watching',
          entries: [
            _makeListEntry(anilistId: 1, progress: 2), // 20%
            _makeListEntry(anilistId: 2, progress: 8), // 80%
          ],
        ),
      });
      vm.update(library, anilist);
      vm.onSortOrderChanged(SortOrder.progress);

      expectSortedBothDirections(vm, ['A', 'B']);
    });

    test('sorts by lastModified ascending and descending', () async {
      await library.addSeries(_makeSeries(name: 'A', path: r'M:\A', anilistMappings: [_makeMapping(1)]));
      await library.addSeries(_makeSeries(name: 'B', path: r'M:\B', anilistMappings: [_makeMapping(2)]));
      anilist.setTestUserLists({
        AnilistListApiStatus.CURRENT.name_: AnilistUserList(
          name: 'Watching',
          entries: [
            _makeListEntry(anilistId: 1, updatedAt: 100),
            _makeListEntry(anilistId: 2, updatedAt: 200),
          ],
        ),
      });
      vm.update(library, anilist);
      vm.onSortOrderChanged(SortOrder.lastModified);

      expectSortedBothDirections(vm, ['A', 'B']);
    });

    test('sorts by dateAdded ascending and descending', () async {
      await library.addSeries(_makeSeries(name: 'A', path: r'M:\A', anilistMappings: [_makeMapping(1)]));
      await library.addSeries(_makeSeries(name: 'B', path: r'M:\B', anilistMappings: [_makeMapping(2)]));
      anilist.setTestUserLists({
        AnilistListApiStatus.CURRENT.name_: AnilistUserList(
          name: 'Watching',
          entries: [
            _makeListEntry(anilistId: 1, createdAt: 100),
            _makeListEntry(anilistId: 2, createdAt: 200),
          ],
        ),
      });
      vm.update(library, anilist);
      vm.onSortOrderChanged(SortOrder.dateAdded);

      expectSortedBothDirections(vm, ['A', 'B']);
    });

    test('sorts by startDate ascending and descending', () async {
      await library.addSeries(_makeSeries(name: 'A', path: r'M:\A', anilistMappings: [_makeMapping(1)]));
      await library.addSeries(_makeSeries(name: 'B', path: r'M:\B', anilistMappings: [_makeMapping(2)]));
      anilist.setTestUserLists({
        AnilistListApiStatus.CURRENT.name_: AnilistUserList(
          name: 'Watching',
          entries: [
            _makeListEntry(anilistId: 1, startedAt: DateValue(year: 2020, month: 1, day: 1)),
            _makeListEntry(anilistId: 2, startedAt: DateValue(year: 2021, month: 1, day: 1)),
          ],
        ),
      });
      vm.update(library, anilist);
      vm.onSortOrderChanged(SortOrder.startDate);

      expectSortedBothDirections(vm, ['A', 'B']);
    });

    test('sorts by completedDate ascending and descending (no nulls)', () async {
      await library.addSeries(_makeSeries(name: 'A', path: r'M:\A', anilistMappings: [_makeMapping(1)]));
      await library.addSeries(_makeSeries(name: 'B', path: r'M:\B', anilistMappings: [_makeMapping(2)]));
      anilist.setTestUserLists({
        AnilistListApiStatus.CURRENT.name_: AnilistUserList(
          name: 'Watching',
          entries: [
            _makeListEntry(anilistId: 1, completedAt: DateValue(year: 2020, month: 1, day: 1)),
            _makeListEntry(anilistId: 2, completedAt: DateValue(year: 2021, month: 1, day: 1)),
          ],
        ),
      });
      vm.update(library, anilist);
      vm.onSortOrderChanged(SortOrder.completedDate);

      expectSortedBothDirections(vm, ['A', 'B']);
    });

    // Priority case (see final report): completedDate's null-handling
    // (lib/viewmodels/library_screen_viewmodel.dart:478-487) is byte-for-byte
    // identical to startDate's (:465-474) - both push a null date to the far
    // side via `if (aDate == null) return 1; if (bDate == null) return -1;`.
    // There is no completedDate-specific asymmetry against startDate.
    //
    // What this test actually pins down is a different, real behavior shared
    // by every nullable date branch (startDate, completedDate, releaseDate):
    // descending order is implemented by swapping the comparator's arguments
    // (line ~525: `comparator(b, a)`), which also flips which side a null
    // lands on. A series with no date sorts last in ascending order but FIRST
    // in descending order, instead of staying pinned to one end.
    test('completedDate: a null completion date should sort last in both directions', () async {
      await library.addSeries(_makeSeries(name: 'HasDate', path: r'M:\HasDate', anilistMappings: [_makeMapping(1)]));
      await library.addSeries(_makeSeries(name: 'NoDate', path: r'M:\NoDate', anilistMappings: [_makeMapping(2)]));
      anilist.setTestUserLists({
        AnilistListApiStatus.CURRENT.name_: AnilistUserList(
          name: 'Watching',
          entries: [
            _makeListEntry(anilistId: 1, completedAt: DateValue(year: 2020, month: 1, day: 1)),
            _makeListEntry(anilistId: 2), // completedAt left null
          ],
        ),
      });
      vm.update(library, anilist);
      vm.onSortOrderChanged(SortOrder.completedDate);

      final ascending = vm.displayData().$1.map((s) => s.name).toList();
      expect(ascending, ['HasDate', 'NoDate'], reason: 'ascending: null completion date sorts last');

      vm.onSortDirectionChanged();
      final descending = vm.displayData().$1.map((s) => s.name).toList();
      // Expected/correct behavior per the audit: a series with no completion
      // date should stay last regardless of direction (matching how nulls are
      // pushed to the end in ascending mode). Actual behavior: the swap-args
      // reversal flips it to the front instead. This assertion is expected to
      // fail - see the note above; do not "fix" this by editing the
      // production comparator, that decision belongs to the user.
      expect(descending, ['HasDate', 'NoDate'], reason: 'descending: null completion date should still sort last, but the swap-arguments reversal flips it to the front instead');
    });

    test('sorts by averageScore ascending and descending', () async {
      await library.addSeries(_makeSeries(
        name: 'A',
        path: r'M:\A',
        anilistMappings: [_makeMapping(1, anilistData: AnilistAnime(id: 1, title: AnilistTitle(), averageScore: 60))],
      ));
      await library.addSeries(_makeSeries(
        name: 'B',
        path: r'M:\B',
        anilistMappings: [_makeMapping(2, anilistData: AnilistAnime(id: 2, title: AnilistTitle(), averageScore: 95))],
      ));
      vm.update(library, anilist);
      vm.onSortOrderChanged(SortOrder.averageScore);

      expectSortedBothDirections(vm, ['A', 'B']);
    });

    test('sorts by releaseDate ascending and descending', () async {
      await library.addSeries(_makeSeries(
        name: 'A',
        path: r'M:\A',
        anilistMappings: [_makeMapping(1, anilistData: AnilistAnime(id: 1, title: AnilistTitle(), startDate: DateValue(year: 2020, month: 1, day: 1)))],
      ));
      await library.addSeries(_makeSeries(
        name: 'B',
        path: r'M:\B',
        anilistMappings: [_makeMapping(2, anilistData: AnilistAnime(id: 2, title: AnilistTitle(), startDate: DateValue(year: 2021, month: 6, day: 1)))],
      ));
      vm.update(library, anilist);
      vm.onSortOrderChanged(SortOrder.releaseDate);

      expectSortedBothDirections(vm, ['A', 'B']);
    });

    test('sorts by popularity ascending and descending', () async {
      await library.addSeries(_makeSeries(
        name: 'A',
        path: r'M:\A',
        anilistMappings: [_makeMapping(1, anilistData: AnilistAnime(id: 1, title: AnilistTitle(), popularity: 100))],
      ));
      await library.addSeries(_makeSeries(
        name: 'B',
        path: r'M:\B',
        anilistMappings: [_makeMapping(2, anilistData: AnilistAnime(id: 2, title: AnilistTitle(), popularity: 500))],
      ));
      vm.update(library, anilist);
      vm.onSortOrderChanged(SortOrder.popularity);

      expectSortedBothDirections(vm, ['A', 'B']);
    });

    test('custom sort order falls back to alphabetical before per-group ordering is applied', () async {
      await library.addSeries(_makeSeries(name: 'Zebra', path: r'M:\Z'));
      await library.addSeries(_makeSeries(name: 'Apple', path: r'M:\Ap'));
      vm.update(library, anilist);
      vm.onSortOrderChanged(SortOrder.custom);

      expectSortedBothDirections(vm, ['Apple', 'Zebra']);
    });
  });

  group('_buildGroupedData', () {
    test('a series in multiple standard lists resolves to the highest-priority one', () async {
      await library.addSeries(_makeSeries(name: 'S', anilistMappings: [_makeMapping(1), _makeMapping(2)]));
      anilist.setTestUserLists({
        AnilistListApiStatus.PAUSED.name_: AnilistUserList(name: 'On Hold', entries: [_makeListEntry(anilistId: 1, status: AnilistListApiStatus.PAUSED)]),
        AnilistListApiStatus.CURRENT.name_: AnilistUserList(name: 'Watching', entries: [_makeListEntry(anilistId: 2, status: AnilistListApiStatus.CURRENT)]),
      });
      vm.setCustomListOrder(['CURRENT', 'PAUSED']);
      vm.onShowGroupedChanged(true);
      vm.update(library, anilist);

      final grouped = vm.displayData().$2!;

      expect(grouped['Watching']?.map((s) => s.name), ['S'], reason: 'CURRENT outranks PAUSED in the priority order');
      expect(grouped['On Hold'] ?? [], isEmpty);
    });

    test('a series fully in COMPLETED short-circuits before the custom-list pass runs', () async {
      await library.addSeries(_makeSeries(name: 'S', anilistMappings: [_makeMapping(1)]));
      anilist.setTestUserLists({
        AnilistListApiStatus.COMPLETED.name_: AnilistUserList(name: 'Completed', entries: [_makeListEntry(anilistId: 1, status: AnilistListApiStatus.COMPLETED)]),
        'custom_Favorites': AnilistUserList(name: 'Favorites', entries: [_makeListEntry(anilistId: 1)]),
      });
      vm.setCustomListOrder(['COMPLETED', 'custom_Favorites']);
      vm.onShowGroupedChanged(true);
      vm.update(library, anilist);

      final grouped = vm.displayData().$2!;

      expect(grouped['Completed']?.map((s) => s.name), ['S']);
      // A series only reaches the custom-list pass if the allCompleted
      // short-circuit's `continue` did NOT fire. Since every mapping here is
      // in COMPLETED, the short-circuit should fire and 'Favorites' should
      // stay empty - if it doesn't, the short-circuit isn't actually running.
      expect(grouped['Favorites'] ?? [], isEmpty, reason: 'the allCompleted short-circuit should continue before the custom-list membership pass runs');
    });

    test('a series in one standard list and one custom list appears in both groups', () async {
      await library.addSeries(_makeSeries(name: 'S', anilistMappings: [_makeMapping(1)]));
      anilist.setTestUserLists({
        AnilistListApiStatus.CURRENT.name_: AnilistUserList(name: 'Watching', entries: [_makeListEntry(anilistId: 1, status: AnilistListApiStatus.CURRENT)]),
        'custom_Favorites': AnilistUserList(name: 'Favorites', entries: [_makeListEntry(anilistId: 1)]),
      });
      vm.setCustomListOrder(['CURRENT', 'custom_Favorites']);
      vm.onShowGroupedChanged(true);
      vm.update(library, anilist);

      final grouped = vm.displayData().$2!;

      expect(grouped['Watching']?.map((s) => s.name), ['S']);
      expect(grouped['Favorites']?.map((s) => s.name), ['S'], reason: 'custom-list membership is non-exclusive with standard-list membership');
    });

    test('a series satisfying two custom lists appears in both, exactly once each', () async {
      await library.addSeries(_makeSeries(name: 'S', anilistMappings: [_makeMapping(1)]));
      anilist.setTestUserLists({
        // Also give it a standard-list match so highestPriorityList isn't
        // null - see the dedicated red test below for what happens when a
        // linked series has no standard-list match at all.
        AnilistListApiStatus.CURRENT.name_: AnilistUserList(name: 'Watching', entries: [_makeListEntry(anilistId: 1, status: AnilistListApiStatus.CURRENT)]),
        'custom_A': AnilistUserList(name: 'A', entries: [_makeListEntry(anilistId: 1)]),
        'custom_B': AnilistUserList(name: 'B', entries: [_makeListEntry(anilistId: 1)]),
      });
      vm.setCustomListOrder(['CURRENT', 'custom_A', 'custom_B']);
      vm.onShowGroupedChanged(true);
      vm.update(library, anilist);

      final grouped = vm.displayData().$2!;

      expect(grouped['A']?.length, 1);
      expect(grouped['B']?.length, 1);
    });

    // Bug found incidentally while writing the test above (its first draft
    // omitted the CURRENT membership and failed with grouped['A'].length==2
    // instead of 1). Not one of the four gaps originally assigned - reporting
    // it separately rather than folding it in silently.
    //
    // lib/viewmodels/library_screen_viewmodel.dart:625-637: a LINKED series
    // that isn't found in any *standard* AniList list (only custom_ ones)
    // falls through `highestPriorityList == null` into the branch commented
    // "Add to Unlinked if not found in any standard list". That branch does
    // `groups.keys.firstWhere((k) => k == 'Unlinked', orElse: () =>
    // groups.keys.first)` - but this whole code path is nested inside
    // `if (series.isLinked)`, and the groups map is seeded from
    // customListOrder, which has no reason to contain an 'Unlinked' entry for
    // a linked series. So `orElse` fires and the series gets dumped into
    // whichever group happens to be `groups.keys.first` - here, 'A', purely
    // because it's first in customListOrder - in addition to its correct
    // custom-list groups.
    test('a linked series with no standard-list match does not get dumped into an unrelated group', () async {
      await library.addSeries(_makeSeries(name: 'S', anilistMappings: [_makeMapping(1)]));
      anilist.setTestUserLists({
        // No standard list (CURRENT/PLANNING/etc.) contains id 1 - only
        // custom_A does, so highestPriorityList stays null. custom_B exists
        // purely as an innocent bystander group the series has no business
        // being in.
        'custom_A': AnilistUserList(name: 'A', entries: [_makeListEntry(anilistId: 1)]),
        'custom_B': AnilistUserList(name: 'B', entries: []),
      });
      // 'B' seeded before 'A', so groups.keys.first == 'B' - if the fallback
      // bug fires, the series lands in 'B' as well as its correct group 'A'.
      vm.setCustomListOrder(['custom_B', 'custom_A']);
      vm.onShowGroupedChanged(true);
      vm.update(library, anilist);

      final grouped = vm.displayData().$2!;

      expect(grouped['A']?.map((s) => s.name), ['S'], reason: 'S belongs in A via custom-list membership');
      // Expected/correct behavior: B has no relation to this series and
      // should stay empty. Actual behavior: highestPriorityList is null (no
      // standard-list match), so the "Add to Unlinked if not found" branch
      // fires; since groups has no 'Unlinked' key, it falls back to
      // `groups.keys.first`, which is 'B' here - not because of anything to
      // do with B, purely because of customListOrder's iteration order.
      expect(grouped['B'] ?? [], isEmpty, reason: 'B should stay empty; do not "fix" this by editing the production code, that decision belongs to the user');
    });

    test('an unlinked series lands in Unlinked', () async {
      await library.addSeries(_makeSeries(name: 'S')); // no anilistMappings -> unlinked
      vm.onShowGroupedChanged(true);
      vm.update(library, anilist);

      final grouped = vm.displayData().$2!;

      expect(grouped['Unlinked']?.map((s) => s.name), ['S']);
    });

    test('empty groups are removed from the output', () async {
      await library.addSeries(_makeSeries(name: 'S', anilistMappings: [_makeMapping(1)]));
      anilist.setTestUserLists({
        AnilistListApiStatus.CURRENT.name_: AnilistUserList(name: 'Watching', entries: [_makeListEntry(anilistId: 1, status: AnilistListApiStatus.CURRENT)]),
      });
      // Seed a group (DROPPED -> 'Dropped') that will end up with zero members.
      vm.setCustomListOrder(['CURRENT', 'DROPPED']);
      vm.onShowGroupedChanged(true);
      vm.update(library, anilist);

      final grouped = vm.displayData().$2!;

      expect(grouped.containsKey('Watching'), isTrue);
      expect(grouped.containsKey('Dropped'), isFalse, reason: 'a group with zero members after filtering should not appear in the output map');
    });
  });

  group('_filterSeries', () {
    test('showHiddenSeries excludes forced-hidden series when off, includes when on', () async {
      await library.addSeries(_makeSeries(name: 'Visible', path: r'M:\V'));
      await library.addSeries(_makeSeries(name: 'Hidden', path: r'M:\H', isHidden: true));
      vm.update(library, anilist);

      Manager.settings.showHiddenSeries = false;
      expect(vm.displayData().$1.map((s) => s.name).toSet(), {'Visible'});

      Manager.settings.showHiddenSeries = true;
      expect(vm.displayData().$1.map((s) => s.name).toSet(), {'Visible', 'Hidden'});
    });

    test('showAnilistHiddenSeries excludes anilist-hidden series when off, includes when on', () async {
      await library.addSeries(_makeSeries(name: 'Visible', path: r'M:\V', anilistMappings: [_makeMapping(1)]));
      await library.addSeries(_makeSeries(name: 'AnilistHidden', path: r'M:\AH', anilistMappings: [_makeMapping(2)]));
      anilist.setTestUserLists({
        AnilistListApiStatus.CURRENT.name_: AnilistUserList(
          name: 'Watching',
          entries: [
            _makeListEntry(anilistId: 1),
            _makeListEntry(anilistId: 2, hiddenFromStatusLists: true),
          ],
        ),
      });
      vm.update(library, anilist);

      Manager.settings.showAnilistHiddenSeries = false;
      expect(vm.displayData().$1.map((s) => s.name).toSet(), {'Visible'});

      Manager.settings.showAnilistHiddenSeries = true;
      expect(vm.displayData().$1.map((s) => s.name).toSet(), {'Visible', 'AnilistHidden'});
    });

    test('onlyLinked (LibraryView.linked) excludes unlinked series', () async {
      await library.addSeries(_makeSeries(name: 'Linked', path: r'M:\L', anilistMappings: [_makeMapping(1)]));
      await library.addSeries(_makeSeries(name: 'Unlinked', path: r'M:\U'));
      vm.update(library, anilist);

      expect(vm.displayData().$1.map((s) => s.name).toSet(), {'Linked', 'Unlinked'}, reason: 'LibraryView.all shows both');

      vm.onViewChanged(LibraryView.linked);
      expect(vm.displayData().$1.map((s) => s.name).toSet(), {'Linked'});
    });

    test('composes the hidden-series filter and a genre filter together', () async {
      await library.addSeries(_makeSeries(
        name: 'VisibleAction',
        path: r'M:\VA',
        anilistMappings: [_makeMapping(1, anilistData: AnilistAnime(id: 1, title: AnilistTitle(), genres: ['Action']))],
      ));
      await library.addSeries(_makeSeries(
        name: 'HiddenAction',
        path: r'M:\HA',
        isHidden: true,
        anilistMappings: [_makeMapping(2, anilistData: AnilistAnime(id: 2, title: AnilistTitle(), genres: ['Action']))],
      ));
      await library.addSeries(_makeSeries(
        name: 'VisibleComedy',
        path: r'M:\VC',
        anilistMappings: [_makeMapping(3, anilistData: AnilistAnime(id: 3, title: AnilistTitle(), genres: ['Comedy']))],
      ));
      vm.update(library, anilist);

      Manager.settings.showHiddenSeries = false;
      vm.addGenre('Action');

      expect(vm.displayData().$1.map((s) => s.name).toSet(), {'VisibleAction'}, reason: 'the hidden-series filter and the genre filter should both apply, neither should short-circuit the other');
    });
  });

  group('_applyCustomGroupOrdering', () {
    test('an item outside the custom order should consistently sort after one that is in it', () {
      // _applyCustomGroupOrdering's sort comparator
      // (lib/viewmodels/library_screen_viewmodel.dart:670-678) is a private
      // closure on the ViewModel and Dart's library-privacy is per-file, so it
      // can't be called directly from this test file. This mirrors the
      // comparator's logic verbatim to test it in isolation, in both argument
      // orders, the way List.sort actually invokes a Comparator.
      int comparator(String aPath, String bPath, List<String> customOrder, String aName, String bName) {
        final aIndex = customOrder.indexOf(aPath);
        final bIndex = customOrder.indexOf(bPath);
        if (aIndex == -1 && bIndex == -1) return aName.compareTo(bName);
        if (aIndex == -1) return 1;
        if (bIndex == -1) return 1; // mirrors the production code as written
        return aIndex.compareTo(bIndex);
      }

      const order = [r'M:\InOrder'];

      final inOrderVsNotInOrder = comparator(r'M:\InOrder', r'M:\NotInOrder', order, 'InOrder', 'NotInOrder');
      final notInOrderVsInOrder = comparator(r'M:\NotInOrder', r'M:\InOrder', order, 'NotInOrder', 'InOrder');

      // Expected/correct behavior: for two distinct items, comparator(a, b)
      // and comparator(b, a) must have opposite signs - the item outside the
      // custom order should sort after the one that's in it regardless of
      // which argument order it's called with. Do not "fix" this by editing
      // the production comparator; that decision belongs to the user.
      expect(inOrderVsNotInOrder, lessThan(0), reason: 'InOrder should sort before NotInOrder');
      expect(notInOrderVsInOrder, greaterThan(0), reason: 'NotInOrder should sort after InOrder, but the production code returns 1 (not -1) for this branch, so both calls currently return a positive number');
    });
  });
}
