<a title="Made with Fluent Design" href="https://github.com/bdlukaa/fluent_ui">
  <img
    src="https://img.shields.io/badge/fluent-design-blue?style=flat-square&color=gray&labelColor=0078D7"
  >
</a>

# MiruRyoiki

MiruRyoiki is a Flutter desktop application (Windows-first, macOS planned) that helps you track and manage your local anime library, keeping your watch progress seamlessly in sync with AniList.

## Features

### Local Library Management

- Scans your media folders, detects series, seasons, and episodes (powered by an Anitomy filename parser), and survives file renames/moves without losing watch state.
- Dominant-color theming: posters and banners tint the UI per series.
- Advanced library browsing: sorting, grouping, filtering, custom sort orders, and hidden series.

### Manual & Automatic Episode Tracking

- Mark episodes watched manually, or let the app detect playback automatically from your media player.
- Currently supported players: **MPC-HC** and **VLC** (via their web interfaces), plus user-configurable custom players. More players (e.g. mpv) are in the works.
- When MPC-HC is your default player, the app launches it in **slave mode**: push-based tracking (no polling) that can follow multiple player windows at once.
- Episodes are auto-marked as watched near the end of playback, and progress is saved continuously.

### AniList Integration

- OAuth login, list management (status, score, progress), notifications, and a release calendar for airing series.
- Offline-first: progress updates are queued locally and synced when you're back online.
- Browse/search AniList (trending, popular, genres) directly inside the app.

### Downloads (optional)

- Optional integration with **Sonarr** + **qBittorrent** and **Knaben** torrent search for automated episode downloads, with a dedicated downloads screen (speeds, graphs, per-series views).
- Completely opt-in: the app works fully without any of these configured. Setup happens in Settings (Sonarr URL/API key, qBittorrent credentials).

### Non-Anime Support

- Non-anime media can be tracked locally too; it simply won't sync with AniList.

## Upcoming

- Expanded player support (mpv).
- Guided setup for the optional download stack (Docker-based Sonarr + qBittorrent provisioning).
- MyAnimeList sync, after AniList support is fully complete.

## Development

See `ARCHITECTURE.md` for a system map.

Requires:
- **Flutter 3.32.8** (via FVM — see `.fvmrc`)
- **`.env` file** — copy `.env.example` to `.env` and set `ANILIST_CLIENT_ID` to your AniList application's client ID. This file is declared as a Flutter asset and must exist before building. No client secret is needed: the app uses AniList's implicit grant, which is the documented flow for clients that cannot store a secret. Sonarr and qBittorrent credentials are entered in Settings at runtime, not here.
- **pubversion** (global Dart tool) — used by `build.ps1` to increment the version number

### Sibling packages

Several dependencies are forks maintained alongside this project. They resolve from
GitHub via pinned `git:` refs in `pubspec.yaml`, so a plain clone needs no extra setup.

If you have them checked out locally and want your edits picked up without a
commit + push + ref bump each time, copy `pubspec_overrides.yaml.example` to
`pubspec_overrides.yaml` (gitignored) and point the paths at your checkouts.

> Do **not** add `dependency_overrides:` to `pubspec.yaml` itself — an absolute
> path committed there breaks `pub get` for everyone else, including CI.

### Building a Release

```powershell
# On Windows:
powershell -File build.ps1

# Manually (without incrementing build number):
fvm flutter build windows --release --no-pub
```

The release build runs `flutter analyze` and all tests before compiling, to catch issues early.
