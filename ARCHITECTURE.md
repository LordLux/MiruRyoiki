# MiruRyoiki Architecture and System Map

## Index

1. [Summary](#summary)
2. [Analysis Targets & Root Files](#1-analysis-targets--root-files)
3. [Models & AniList API Mapping](#2-models--anilist-api-mapping)
4. [Service Layer Architecture](#3-service-layer-architecture)
5. [Screens & Provider Consumption](#4-screens--provider-consumption)

## Summary

MiruRyoiki is a local anime media management desktop app built with Flutter and Provider. It bridges the gap between local filesystem media (grouped into `Series` and `EpisodeCollection`) and remote AniList metadata (AniList API v2 `Media`). The central architecture pattern heavily utilizes `ChangeNotifierProvider` for global state (`Library`, `AnilistProvider`, `SettingsManager`, `AppTheme`). Metadata, images, and progress are synced asynchronously using an offline-first mutation queue.

---

## 1. Analysis Targets & Root Files

- `lib/main.dart`: Central initialization (DB, window manager, system tray). Sets up the dependency injection tree via `MultiProvider` and houses the root router and deep linking (`mRyoikiAnilistScheme`).
- `lib/manager.dart`: Global service locator exposing standard providers statically (e.g., `Manager.settings`, `Manager.db`) and global state.
- `lib/functions.dart`: Global utility functions (clipboard, file opening).
- `lib/enums.dart`: Application-wide enumerations with string mapping extensions (`ThemeMode`, `WindowEffect`, `ImageSource`).
- `lib/settings.dart`: `SettingsManager` singleton backed by `SettingsDao`. Handles all preferences.
- `lib/theme.dart`: `AppTheme` class managing dynamic theming and accent colors.

---

## 2. Models & AniList API Mapping

The app's core domains bridge local files and AniList representations.

- `Series` (`lib/models/series.dart`): The core domain model representing a local franchise folder. **AniList API Mapping:** No direct 1:1 equivalent. A `Series` groups multiple AniList entries using `AnilistMapping`.
- `EpisodeCollection` & `Season` (`lib/models/season.dart`): Represents a numbered season (e.g., "S01") or folder. Purely a local filesystem grouping structure.
- `Episode` (`lib/models/episode.dart`): A single video file, tracking metadata and watch progress. **AniList API Mapping:** Maps to updating `progress` on a `MediaList` object when watched.
- `AnilistAnime` (`lib/models/anilist/anime.dart`): **AniList API Mapping:** Maps directly to the `Media` object (type: ANIME). Contains `bannerImage`, `title`, `meanScore`, `nextAiringEpisode`, etc.
- `AnimeCard` (`lib/models/anilist/anime_card.dart`): Lighter version of `Media` used in search results.
- `AnilistMapping` (`lib/models/anilist/mapping.dart`): The bridge entity mapping a local `Series` directory to an AniList `Media` ID.

---

## 3. Service Layer Architecture

### A. AniList Service Layer (`lib/services/anilist/`)

**Responsibilities:**

- **OAuth2 Authentication & User Data:** Manages login and caches user lists (Watching, Completed, etc.) using disk persistence.
- **Anime Caching & Mutation Queue:** Offline-first caching of anime details (posters, genres). Queues watch progress updates to disk, syncing asynchronously when online.
- **Background Sync:** 30-minute periodic refresh and connectivity-based on-demand sync.
**Data Consumption:** Consumed by `Library` and UI screens. Depends on `ConnectivityService` and GraphQL.

### B. Library Service Layer (`lib/services/library/`)

**Responsibilities:**

- **Filesystem Scanning:** Non-blocking isolate worker scans directories, using Anitomy to extract episode numbers and titles.
- **Persistence & Integration:** Manages SQLite (Drift) via `SeriesDao`. Fetches AniList posters/banners for mapped series.
- **Media Player Integration:** Monitors MPCHC playback state via named pipes to automatically save watch progress to `Episode`s based on video timestamps.
**Data Consumption:** Heavily consumed by all screens via `Provider.watch<Library>()`.

### C. Episode Navigation Service Layer (`lib/services/episode_navigation/`)

**Responsibilities:**

- **Progress Calculation:** Aggregates watched episodes across AniList mappings and calculates series completion percentage.
- **Episode Lookup:** Checks bounds (first/last episode) and bridges AniList absolute episode numbers to local season-based numbering.
**Data Consumption:** Stateless singleton services called by UI to calculate next episodes and progress bars.

---

## 4. Screens & Provider Consumption

### Accounts (`lib/screens/accounts.dart`)

- **Summary:** User profile, sync settings, and watch progress stats.
- **Providers:** `AnilistProvider` (login status, lists), `Library` (triggers global metadata refresh).

### AniList Settings (`lib/screens/anilist_settings.dart`)

- **Summary:** AniList configuration inside settings.
- **Providers:** `AnilistProvider` (user info), `Library`.

### Downloads Screen (`lib/screens/downloads_screen.dart`)

- **Summary:** Real-time torrent management interface.
- **Providers:** `TorrentManager` (singleton), `NavigationManager` (scroll state).

### Home (`lib/screens/home.dart`)

- **Summary:** Dashboard highlighting "continue watching", upcoming releases, and smart random picks.
- **Providers:** `Library` (series list, playback), `AnilistProvider` (progress tracking), `SettingsManager`, `EpisodeNavigator`.

### Library (`lib/screens/library.dart`)

- **Summary:** Main grid/list browser with advanced sorting, grouping, and filtering.
- **Providers:** `Library` (core data, sort logic), `AnilistProvider` (user list categorizations), `SearchService`.

### Release Calendar (`lib/screens/release_calendar.dart`)

- **Summary:** Airing schedule for mapped series.
- **Providers:** `Library` (metadata lookups), `AnilistProvider` (determines airing dates).

### Search / Browse (`lib/screens/search.dart`)

- **Summary:** Discovery interface showing trending/popular anime and genre search.
- **Providers:** `AnilistService` (GraphQL fetching), `ConnectivityService`.

### Search Results (`lib/screens/search_results.dart`)

- **Summary:** Paginated anime cards acting on browse queries.
- **Providers:** `AnilistService` (pagination).

### Searched Series (`lib/screens/searched_series.dart`)

- **Summary:** Detailed view for a remote AniList entry (prior to local library addition).
- **Providers:** `AnilistProvider` (score formatting).

### Series (`lib/screens/series.dart`)

- **Summary:** Deep view of a single local series, mapping info, local folder structure, and Sonarr merged data.
- **Providers:** `Library` (episode playback, update data), `AnilistProvider` (AniList data fetches), `CustomSonarrMappingService`.

### Settings (`lib/screens/settings.dart`)

- **Summary:** Comprehensive configuration panel (Appearance, Players, Torrents).
- **Providers:** `SettingsManager` (persistence), `AppTheme` (live UI changes), `SonarrService` & `QBittorrentClient` (connection testing).
