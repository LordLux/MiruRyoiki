# mpv — Event-Driven Integration (Design Brief)

**Status:** Not yet implemented. This file documents everything a future session needs to add push-based mpv control alongside the MPC-HC slave implementation in `../slave/`. Nothing here is wired up yet; `playEpisode` falls back to the OS default open for mpv today.

## Goal

Replace HTTP polling with mpv's JSON IPC so status arrives by push and commands are sent over a per-instance channel. Implement either:
- A `MediaPlayer` facade like `players/mpc_hc_slave_player.dart`, driven by an `MpvIpcManager` modeled on `slave/mpc_slave_manager.dart`, or
- A direct `MediaPlayer` if you don't need multi-instance.

mpv is the cleanest of the three players: it supports true push AND absolute volume + mute (unlike MPC-HC slave), and each instance gets its own pipe, so multi-instance tracking is essentially free.

## Mechanism — JSON IPC over a Windows named pipe

### Launch
```
mpv.exe --input-ipc-server=\\.\pipe\miruryoiki-mpv-<uniqueId> "<file>"
```
Use a unique pipe name per launch so multiple instances don't collide (this is the mpv analogue of MPC-HC reporting its own HWND on CMD_CONNECT).

### Protocol (newline-delimited JSON, UTF-8)

**Send commands:**
```json
{"command": ["set_property", "pause", true]}
{"command": ["set_property", "volume", 70]}
{"command": ["set_property", "mute", true]}
{"command": ["seek", 30, "absolute"]}
{"command": ["playlist-next"]}
```

**Subscribe (PUSH, no polling):**
```json
{"command": ["observe_property", 1, "time-pos"]}
```

Then mpv emits:
```json
{"event":"property-change","id":1,"name":"time-pos","data":12.3}
```

Observe these properties: `time-pos`, `duration`, `pause`, `volume`, `mute`, `path`, `media-title`, `eof-reached`. Each change is pushed — there is no need to poll.

**Lifecycle events:**
```json
{"event":"file-loaded"}
{"event":"end-file"}
{"event":"shutdown"}
```
(The CMD_DISCONNECT analogue.)

### Mapping mpv → MediaStatus

From `models/players/mediastatus.dart`:
- `filePath` ← `"path"`
- `currentPosition` ← `"time-pos"` (seconds, double)
- `totalDuration` ← `"duration"` (seconds, double)
- `isPlaying` ← `!"pause"`
- `volumeLevel` ← `"volume"` (already 0–100)
- `isMuted` ← `"mute"`

## Transport on Windows — the main gotcha

`dart:io` Sockets **CANNOT** open a Windows named pipe (`\\.\pipe\...`). Use Dart FFI (win32) just like `slave/mpc_slave_bridge.dart`:
- `CreateFileW(pipeName, GENERIC_READ|GENERIC_WRITE, 0, null, OPEN_EXISTING, 0, 0)`
- After launching mpv, retry the open for ~1–2 s (the pipe appears slightly after the process starts; `WaitNamedPipe` helps).
- `WriteFile` to send a JSON line; `ReadFile` in a loop to receive.
- Run the blocking `ReadFile` loop on a dedicated background isolate and forward parsed events to the main isolate via `SendPort` — exactly the pattern `MpcSlaveBridge` uses for its `GetMessage` loop.
- Pipe EOF / `ReadFile` failure == instance closed → prune it (cf. `MpcSlaveManager.pruneDeadInstances` / `_onDisconnect`).

(If a maintained pub package for mpv IPC on Windows exists, prefer it, but as of writing the FFI named-pipe route is the reliable option.)

## Codebase integration anchors

- **Routing:** `media_player_monitor.dart` `tryLaunchViaSlave` — add an `if (resolved.kind == DefaultPlayerKind.mpv)` branch (or generalize the method) that launches mpv and connects an `MpvPlayer` facade via `PlayerManager.connectToPushPlayer(player, PlayerType.mpv?)`. You'll need a new `PlayerType` or reuse `custom`.
- **Exe path:** `utils/default_player.dart` already resolves and classifies mpv (`mpv.exe` / `mpvnet.exe`). Reuse `DefaultPlayer.executablePath`.
- **Facade shape:** Copy `players/mpc_hc_slave_player.dart` (set `isPushBased=true`; delegate commands to the manager). Because mpv reports volume/mute, mpv instances should report `activePlayerSupportsVolumeRead == true` always (unlike MPC-HC's owner-only readback) — wire that through `media_player_monitor.activePlayerSupportsVolumeRead`.
- **Manager shape:** Copy `slave/mpc_slave_manager.dart` (instances keyed by pipe id, last-active tracking, `statusStream` of the active instance).
- **Progress saving:** Needs no changes — it keys off `MediaStatus.filePath`.

## First three steps

1. Prove the transport: launch mpv with `--input-ipc-server`, open the pipe via FFI, send `{"command":["get_property","mpv-version"]}`, print the reply.
2. Add `observe_property` for the fields above; map to `MediaStatus`; log them.
3. Build the facade + manager + routing branch; reuse the player widget and progress pipeline unchanged.

## References

- [mpv JSON IPC](https://mpv.io/manual/stable/#json-ipc)
- Source: `DOCS/man/ipc.rst` in [mpv-player/mpv](https://github.com/mpv-player/mpv)
