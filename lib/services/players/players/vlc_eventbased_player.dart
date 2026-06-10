// ============================================================================
// VLC — reduced-polling / event-ish integration (NOT YET IMPLEMENTED — briefing)
// ============================================================================
//
// This file is intentionally a stub. The CURRENT, working VLC integration is
// `players/vlc_player.dart` (HTTP polling of /requests/status.json every 1 s),
// and it stays as-is. This file documents the options for a future session that
// wants to move VLC off polling, the way MPC-HC moved to slave mode.
//
// Read this honestly: unlike MPC-HC (WM_COPYDATA push) and mpv (JSON IPC
// observe_property push), **VLC has no clean push/observe mechanism** over its
// external interfaces. So "event-driven VLC" is a compromise, not a clear win.
//
// ----------------------------------------------------------------------------
// 1. Options (pick per the trade-offs)
// ----------------------------------------------------------------------------
// (A) Keep HTTP polling (status quo). Simplest, already implemented. The only
//     real downsides are the 1 s cadence and the single-port multi-instance
//     limitation (same class of problem MPC-HC had before slave mode). If you
//     only care about removing MPC-HC's polling, you can legitimately leave VLC
//     on this path.
//
// (B) RC ("remote control") interface over TCP. Launch:
//         vlc.exe --extraintf rc --rc-host 127.0.0.1:<port> "<file>"
//     Then connect with a normal `dart:io` Socket (TCP works here — no FFI
//     needed, unlike mpv's named pipe). You get a text command shell:
//         get_time / get_length / is_playing / status   (query)
//         pause / play / stop / volume <0-256> / seek <n> / next / prev (control)
//     Pros: a persistent connection, instant command delivery, no HTTP. Cons:
//     it is still REQUEST/RESPONSE — there is no unsolicited "position changed"
//     event, so you must still poll get_time/status on a timer for progress.
//     Net effect vs (A): lower command latency and a cleaner control channel,
//     but status polling does not actually go away.
//
// (C) HTTP interface (what vlc_player.dart uses) with multi-instance handled by
//     launching each VLC with a distinct --http-port. This fixes the
//     "only first instance visible" problem without changing the transport.
//
// Recommendation: if the goal is parity with the MPC-HC work, (C) (per-instance
// HTTP ports + the same last-active manager pattern) buys correct multi-instance
// with the least new machinery; (B) is worth it only if command latency matters.
// True push is not available — set expectations accordingly.
//
// ----------------------------------------------------------------------------
// 2. Launch args / auth / scales
// ----------------------------------------------------------------------------
//   HTTP:  vlc.exe --extraintf http --http-host 127.0.0.1 --http-port <port>
//                  --http-password <pw> "<file>"
//          (the app already uses Basic auth with an empty user; see vlc_player.dart)
//   RC:    vlc.exe --extraintf rc --rc-host 127.0.0.1:<port> "<file>"
//   Volume scale is 0–256, NOT 0–100. Reuse VLCPlayer.percentToVlc /
//   vlcToPercent (players/vlc_player.dart) for conversion.
//   Exe path: utils/default_player.dart already resolves + classifies vlc.exe.
//
// ----------------------------------------------------------------------------
// 3. Codebase integration anchors
// ----------------------------------------------------------------------------
//   * Routing: media_player_monitor.dart `tryLaunchViaSlave` (generalize it, or
//     add a sibling) — branch on DefaultPlayerKind.vlc to launch with the chosen
//     interface and connect a facade via PlayerManager.connectToPushPlayer (or
//     keep the existing autoConnect poll path for option A).
//   * If you implement multi-instance, mirror slave/mpc_slave_manager.dart
//     (instances + last-active + statusStream) and players/mpc_hc_slave_player.dart
//     (the MediaPlayer facade). For RC, isPushBased should stay FALSE (you still
//     poll), so PlayerManager keeps a (slower) status timer for it.
//   * MediaStatus mapping already exists in vlc_player.dart `_fetchStatus`
//     (filename/time/length/state/volume/muted) — reuse it.
//   * VLC reports real volume/mute, so report activePlayerSupportsVolumeRead ==
//     true for VLC (full slider, every instance).
//   * Progress saving needs no changes — it keys off MediaStatus.filePath.
//
// ----------------------------------------------------------------------------
// 4. First three steps (if doing RC)
// ----------------------------------------------------------------------------
//   1. Launch VLC with --extraintf rc --rc-host; open a Socket; send "status";
//      parse the reply lines.
//   2. Map status/get_time/get_length to MediaStatus on a modest poll timer;
//      send play/pause/volume/seek/next/prev as RC commands.
//   3. For multi-instance, give each launch its own --rc-host port and adopt the
//      manager/facade/last-active pattern from the MPC-HC slave implementation.
//
// Docs: RC interface — https://wiki.videolan.org/documentation:modules/rc/
//       Alt interfaces — https://wiki.videolan.org/Documentation:Alternative_Interfaces/
// ============================================================================
