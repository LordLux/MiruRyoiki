// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import '../manager.dart';
import '../models/anilist/anime_card.dart';
import '../models/anilist/mapping.dart';
import '../models/anilist/user_list.dart';
import '../models/series.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../services/downloads/torrent_manager.dart';
import '../services/library/library_provider.dart';
import '../services/navigation/dialogs2.dart';
import '../services/navigation/navigation.dart';
import '../services/navigation/show_info.dart';
import '../settings.dart';
import '../utils/logging.dart';
import '../utils/path.dart';
import '../widgets/dialogs/add_to_library_chooser.dart';
import '../widgets/dialogs/entry_editor.dart';
import '../widgets/dialogs/existing_series_picker.dart';
import '../widgets/dialogs/folder_confirm_dialog.dart';
import '../widgets/dialogs/link_anilist.dart';
import '../widgets/dialogs/show_dialog.dart';
import '../widgets/dialogs/sonarr_manual_link_dialog.dart';
import '../widgets/file_explorer.dart';

/// Open the AniList entry editor for [series]
void openEntryEditor(BuildContext context, AnimeCard series, {AnilistMediaListEntry? existing, String? bannerImage}) {
  final displayTitle = series.title.userPreferred ?? series.title.romaji ?? series.title.english ?? 'Unknown';
  showEntryEditorDialog(
    context,
    mediaId: series.id,
    title: displayTitle,
    totalEpisodes: series.episodes,
    bannerImage: bannerImage,
    coverImage: series.coverImage,
    isFavourite: series.isFavourite,
    entry: existing,
  );
}

/// Open the AniList entry editor for a local [mapping], looking up the user's
/// existing list entry. Shared by the series/mapping context menus and the
/// series screen so the lookup + dialog args stay in one place.
void openEntryEditorForMapping(BuildContext context, AnilistMapping mapping) {
  final anime = mapping.anilistData;
  if (anime == null) {
    snackBar('No AniList data available for this mapping', severity: InfoBarSeverity.warning);
    return;
  }

  final displayTitle = mapping.preferredTitle ?? anime.title.userPreferred ?? anime.title.romaji ?? anime.title.english ?? 'Unknown';

  // Look up the user's existing list entry for this media, if any.
  final anilist = Provider.of<AnilistProvider>(context, listen: false);
  AnilistMediaListEntry? existing;
  for (final list in anilist.userLists.values) {
    for (final entry in list.entries) {
      if (entry.mediaId == mapping.anilistId) {
        existing = entry;
        break;
      }
    }
    if (existing != null) break;
  }

  showEntryEditorDialog(
    context,
    mediaId: mapping.anilistId,
    title: displayTitle,
    totalEpisodes: anime.episodes,
    bannerImage: anime.bannerImage,
    coverImage: anime.posterImage,
    isFavourite: anime.isFavourite ?? false,
    entry: existing,
  );
}

/// Navigate to the local library series page for [anilistId]
void goToLibrarySeries(BuildContext context, int anilistId) {
  final library = Provider.of<Library>(context, listen: false);
  final s = library.getSeriesByAnilistId(anilistId);
  if (s == null) {
    snackBar('Series not found in library', severity: InfoBarSeverity.error);
    return;
  }
  navigateToLibrarySeries(context, s);
}

/// Navigate to a local library series page (switches to Library pane + pushes page)
void navigateToLibrarySeries(BuildContext context, Series series) {
  context.read<NavigationManager>().pushPane(NavigationManager.LibraryPane);
  context.read<NavigationManager>().pushPage(
    '/series:${series.path.path}',
    series.name,
    data: series.path,
  );
}

/// Start the "Add to Library" flow for [series]
/// 
/// Opens the chooser dialog letting the user register the AniList entry under a new series or attach it to an existing library series
Future<void> startAddToLibraryFlow(BuildContext context, AnimeCard series) async {
  showPaddedDialog(
    context,
    navigationItem: DialogNavigationItem(
      id: 'add-to-library:chooser:${series.id}',
      title: 'Add to Library',
    ),
    builder: (_, item, opts) => PaddedDialog.simple(
      navigationItem: item,
      barrierOptions: opts,
      title: Text('Add to Library', style: Manager.titleStyle),
      constraints: const BoxConstraints(maxWidth: 560, maxHeight: 280),
      content: AddToLibraryChooserDialog(
        onNewSeries: () {
          closeDialog();
          _startNewSeriesFlow(context, series);
        },
        onExistingSeries: () {
          closeDialog();
          _startExistingSeriesFlow(context, series);
        },
      ),
    ),
  );
}

// NEW-SERIES

Future<void> _startNewSeriesFlow(BuildContext context, AnimeCard series) async {
  final sonarrEnabled = TorrentManager.sonarrRepository != null;
  final controller = TorrentManager.downloadController;

  int? existingTvdbId;
  if (sonarrEnabled && controller != null) {
    existingTvdbId = await controller.customMappings.getCustomTvdbId(series.id);
  }

  if (sonarrEnabled && existingTvdbId == null) {
    showPaddedDialog(
      context,
      navigationItem: DialogNavigationItem(id: 'add-to-library:sonarr:${series.id}', title: 'Link to Sonarr'),
      builder: (_, item, opts) => PaddedDialog.custom(
        navigationItem: item,
        barrierOptions: opts,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
        contentBuilder: (_, __) => SonarrManualLinkDialog(
          animeId: series.id,
          animeTitle: series.title,
          onLinked: () => _continueAfterSonarrLinkNew(context, series),
        ),
      ),
    );
    return;
  }

  await _continueAfterSonarrLinkNew(context, series);
}

Future<void> _continueAfterSonarrLinkNew(BuildContext context, AnimeCard series) async {
  final sonarrEnabled = TorrentManager.sonarrRepository != null;
  final controller = TorrentManager.downloadController;
  final settings = SettingsManager();

  int? sonarrSeriesId;
  String? sonarrLookupTitle;

  if (sonarrEnabled && controller != null) {
    final tvdbId = await controller.customMappings.getCustomTvdbId(series.id);
    if (tvdbId == null) {
      snackBar('No Sonarr link found. Please link the series first.', severity: InfoBarSeverity.error);
      return;
    }

    int qualityProfileId = settings.sonarrQualityProfileId;
    if (qualityProfileId == 0) {
      try {
        final profiles = await TorrentManager.sonarrRepository!.getQualityProfiles();
        if (profiles.isNotEmpty) {
          qualityProfileId = profiles.first.id;
        } else {
          snackBar('No quality profiles found. Configure Sonarr in Settings.', severity: InfoBarSeverity.error);
          return;
        }
      } catch (e) {
        snackBar('Could not fetch quality profiles: $e', severity: InfoBarSeverity.error);
        return;
      }
    }

    final rootFolderPath = settings.sonarrRootFolderPath.isNotEmpty ? settings.sonarrRootFolderPath : Provider.of<Library>(context, listen: false).libraryDockerPath ?? '';

    if (rootFolderPath.isEmpty) {
      snackBar('No Sonarr root folder configured. Check Settings.', severity: InfoBarSeverity.error);
      return;
    }

    try {
      final preferredTitle = series.title.userPreferred ?? series.title.romaji ?? series.title.english ?? 'Unknown';
      sonarrSeriesId = await TorrentManager.sonarrRepository!.ensureSeriesExists(
        tvdbId: tvdbId,
        title: preferredTitle,
        rootFolderPath: rootFolderPath,
        qualityProfileId: qualityProfileId,
      );
      if (sonarrSeriesId != null) {
        final sJson = await TorrentManager.sonarrRepository!.getSeriesById(sonarrSeriesId);
        sonarrLookupTitle = sJson['title'] as String?;
      }
    } catch (e) {
      snackBar('Sonarr error: $e', severity: InfoBarSeverity.error);
      return;
    }
  }

  if (!context.mounted) return;
  _openFolderConfirm(context, series, sonarrSeriesId, sonarrLookupTitle);
}

void _openFolderConfirm(BuildContext context, AnimeCard series, int? sonarrSeriesId, String? sonarrTitle) {
  final library = Provider.of<Library>(context, listen: false);
  final libraryPath = library.libraryPath;
  if (libraryPath == null) {
    snackBar('No library path configured. Set one in Settings.', severity: InfoBarSeverity.error);
    return;
  }

  showPaddedDialog(
    context,
    navigationItem: DialogNavigationItem(id: 'add-to-library:folder:${series.id}', title: 'Confirm Folder'),
    builder: (_, item, opts) => PaddedDialog.simple(
      navigationItem: item,
      barrierOptions: opts,
      constraints: const BoxConstraints(maxWidth: 700, maxHeight: 520),
      title: Text('Confirm Folder', style: Manager.titleStyle),
      content: FolderConfirmDialog(
        anilistId: series.id,
        sonarrTitle: sonarrTitle,
        sonarrSeriesId: sonarrSeriesId,
        libraryRootPath: libraryPath,
        romajiTitle: series.title.romaji ?? '',
        englishTitle: series.title.english ?? '',
        userPreferredTitle: series.title.userPreferred ?? series.title.romaji ?? series.title.english ?? 'Unknown',
        onConfirm: (finalLocalPath) => _finalizeAddToLibrary(context, series, sonarrSeriesId, finalLocalPath),
      ),
    ),
  );
}

Future<void> _finalizeAddToLibrary(
  BuildContext context,
  AnimeCard series,
  int? sonarrSeriesId,
  String finalLocalPath,
) async {
  final library = Provider.of<Library>(context, listen: false);
  final controller = TorrentManager.downloadController;

  // Sync Sonarr path if needed
  if (sonarrSeriesId != null && controller != null) {
    try {
      final sonarrPath = controller.toSonarrPath(finalLocalPath);
      await TorrentManager.sonarrRepository!.updateSeriesPath(sonarrSeriesId, sonarrPath);
    } catch (e) {
      logDebug('Failed to update Sonarr series path: $e');
    }
  }

  try {
    await Directory(finalLocalPath).create(recursive: true);
  } catch (e) {
    snackBar('Failed to create folder', severity: InfoBarSeverity.error, longMessage: e.toString());
    return;
  }

  // Register the series with empty anilistMappings
  final newSeries = Series(
    name: p.basename(finalLocalPath),
    path: PathString(finalLocalPath),
    collections: [],
    anilistMappings: [],
    primaryAnilistId: series.id,
  );

  await library.addSeries(newSeries);

  // Close the folder-confirm dialog before opening the link dialog so the nav stack stays clean.
  closeDialog();

  if (!context.mounted) return;
  _openLinkDialog(context, newSeries, series.id);
}

// EXISTING-SERIES BRANCH

void _startExistingSeriesFlow(BuildContext context, AnimeCard series) {
  showPaddedDialog(
    context,
    navigationItem: DialogNavigationItem(
      id: 'add-to-library:existing:${series.id}',
      title: 'Select Series',
    ),
    builder: (_, item, opts) => PaddedDialog.simple(
      navigationItem: item,
      barrierOptions: opts,
      title: const Text(
        'Select an existing series',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
      content: ExistingSeriesPickerDialog(
        onSelected: (existing) {
          closeDialog();
          _resolveSonarrForExisting(context, series, existing);
        },
      ),
    ),
  );
}

Future<void> _resolveSonarrForExisting(BuildContext context, AnimeCard series, Series existing) async {
  final controller = TorrentManager.downloadController;
  final sonarrEnabled = TorrentManager.sonarrRepository != null;

  if (!sonarrEnabled || controller == null) {
    _openLinkDialog(context, existing, series.id);
    return;
  }

  // If the new AniList ID already has its own known tvdb link (custom or official), no Sonarr step is needed — Sonarr can resolve it the same way
  final newIdKnownTvdb = await controller.resolveKnownTvdbId(series.id);
  if (newIdKnownTvdb != null) {
    if (!context.mounted) return;
    _openLinkDialog(context, existing, series.id);
    return;
  }

  // Otherwise, check the existing series. If any of its mappings resolve to a tvdbId, share that tvdbId with the new AniList ID via a custom mapping
  final existingSeriesTvdb = await controller.firstKnownTvdbForSeries(existing);
  if (existingSeriesTvdb != null) {
    await controller.customMappings.saveCustomTvdbId(series.id, existingSeriesTvdb);
    if (!context.mounted) return;
    _openLinkDialog(context, existing, series.id);
    return;
  }

  // Neither the new AniList ID nor the existing series has a tvdb link 
  // Show the Sonarr manual-link dialog for the new AniList ID
  if (!context.mounted) return;
  showPaddedDialog(
    context,
    navigationItem: DialogNavigationItem(
      id: 'add-to-library:existing:sonarr:${series.id}',
      title: 'Link to Sonarr',
    ),
    builder: (_, item, opts) => PaddedDialog.custom(
      navigationItem: item,
      barrierOptions: opts,
      constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
      contentBuilder: (_, __) => SonarrManualLinkDialog(
        animeId: series.id,
        animeTitle: series.title,
        onLinked: () => _openLinkDialog(context, existing, series.id),
      ),
    ),
  );
}

// SHARED LINK DIALOG

void _openLinkDialog(BuildContext context, Series target, int anilistId) {
  linkWithAnilist(
    context,
    target,
    (_) async {},
    (_) {},
    requireLocalFirst: true,
    initialAnilistId: anilistId,
    lockAnilist: true,
    startInAddMode: true,
    explorerOptions: const FileExplorerOptions(
      allowFiles: true,
      allowCurrentFolder: true,
      allowCreateFolder: true,
      allowRename: true,
    ),
  );
}
