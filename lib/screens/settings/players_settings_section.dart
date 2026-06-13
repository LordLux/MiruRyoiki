// ignore_for_file: use_build_context_synchronously

import 'package:fluent_ui/fluent_ui.dart' hide AnimatedSwitcher;
import 'package:flutter/material.dart' as mat hide AnimatedSwitcher;
import 'package:provider/provider.dart';

import '../../manager.dart';
import '../../services/navigation/show_info.dart';
import '../../services/players/media_player_monitor.dart';
import '../../services/players/player.dart';
import '../../settings.dart';
import '../../utils/time.dart';
import '../../widgets/animated_hider.dart';
import '../../widgets/buttons/loading_button.dart';
import '../../widgets/buttons/switch.dart';

/// Players category of the Settings screen.
///
/// Owns the MPC-HC executable-path controller and the "reload players" busy
/// flag. Reads/writes the [SettingsManager] singleton (injected for build
/// readability) and talks to [MediaPlayerMonitorService] via Provider.
class PlayersSettingsSection extends StatefulWidget {
  final SettingsManager settings;

  const PlayersSettingsSection({super.key, required this.settings});

  @override
  State<PlayersSettingsSection> createState() => _PlayersSettingsSectionState();
}

class _PlayersSettingsSectionState extends State<PlayersSettingsSection> {
  final TextEditingController _mpcHcPathController = TextEditingController();
  bool _isRefreshingPlayers = false;

  @override
  void initState() {
    super.initState();
    nextFrame(() {
      // empty = auto-detect
      _mpcHcPathController.text = widget.settings.mpcHcExecutablePath;
    });
  }

  @override
  void dispose() {
    _mpcHcPathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enable Media Player Integration
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enable Media Player Integration',
                    style: Manager.bodyStrongStyle,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Automatically detect and connect to supported media players for playback control and progress tracking.',
                    style: Manager.bodyStyle.copyWith(color: Colors.white.withOpacity(.5)),
                  ),
                ],
              ),
            ),
            SizedBox(width: 24),
            NormalSwitch(
              ToggleSwitch(
                checked: settings.enableMediaPlayerIntegration,
                content: Text(settings.enableMediaPlayerIntegration ? 'Enabled' : 'Disabled', style: Manager.bodyStyle),
                onChanged: (value) async {
                  setState(() => settings.enableMediaPlayerIntegration = value);

                  final monitor = context.read<MediaPlayerMonitorService>();
                  if (value) {
                    await monitor.start();
                  } else {
                    await monitor.stop();
                  }
                  // start() ran player discovery; rebuild so the path field's
                  // placeholder reflects the freshly-detected MPC-HC path.
                  if (mounted) setState(() {});
                },
              ),
            ),
          ],
        ),

        // MPC-HC Slave Mode
        AnimatedHider(
          duration: dimDuration,
          shouldShowChild: settings.enableMediaPlayerIntegration,
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MPC-HC Slave Mode',
                            style: Manager.bodyStrongStyle,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'When MPC-HC is your default video player, launch it in slave mode for push-based control (no polling) and correct tracking of multiple windows. Externally-opened players still use polling.',
                            style: Manager.bodyStyle.copyWith(color: Colors.white.withOpacity(.5)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 24),
                    NormalSwitch(
                      ToggleSwitch(
                        checked: settings.enableMpcHcSlaveMode,
                        content: Text(settings.enableMpcHcSlaveMode ? 'Enabled' : 'Disabled', style: Manager.bodyStyle),
                        onChanged: (value) => setState(() => settings.enableMpcHcSlaveMode = value),
                      ),
                    ),
                  ],
                ),
                // Optional exe-path override (auto-detected from the default app otherwise)
                AnimatedHider(
                  duration: dimDuration,
                  shouldShowChild: settings.enableMpcHcSlaveMode,
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        SizedBox(width: 100, child: Text('MPC-HC path', style: Manager.bodyStyle)),
                        SizedBox(width: 14),
                        Expanded(
                          child: TextBox(
                            controller: _mpcHcPathController,
                            placeholder: settings.mpcHcDetectedPath.isNotEmpty ? settings.mpcHcDetectedPath : 'MPC-HC not detected. Please enter the mpc-hc executable path manually',
                            placeholderStyle: Manager.bodyStyle.copyWith(color: Colors.white.withValues(alpha: .5), fontStyle: FontStyle.italic),
                            onChanged: (value) => settings.mpcHcExecutablePath = value.trim(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Connection Status
        AnimatedHider(
          duration: dimDuration,
          shouldShowChild: settings.enableMediaPlayerIntegration,
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              Divider(),
              SizedBox(height: 12),
              Text(
                'Connection Status',
                style: Manager.bodyStrongStyle,
              ),
              SizedBox(height: 12),
              Consumer<MediaPlayerMonitorService>(
                builder: (context, monitor, child) {
                  final connectedPlayer = monitor.currentConnectedPlayer;
                  final detectedPlayers = monitor.detectedPlayers;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (connectedPlayer != null)
                            Row(
                              children: [
                                Icon(mat.Icons.check_circle, color: Colors.green, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'Connected to: $connectedPlayer',
                                  style: Manager.bodyStyle.copyWith(color: Colors.green),
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                Icon(mat.Icons.error, color: Colors.orange, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'No players connected',
                                  style: Manager.bodyStyle.copyWith(color: Colors.orange),
                                ),
                              ],
                            ),
                          SizedBox(height: 12),
                          if (detectedPlayers.isNotEmpty) ...[
                            Text(
                              'Installed Players:',
                              style: Manager.bodyStyle.copyWith(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 4),
                            ...detectedPlayers.map((player) => Padding(
                                  padding: EdgeInsets.only(left: 16, bottom: 4),
                                  child: Card(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          height: 25,
                                          width: 25,
                                          child: getPlayerFromId(player.id)?.iconWidget,
                                        ),
                                        SizedBox(width: 8),
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(text: player.name, style: Manager.bodyStrongStyle),
                                              TextSpan(text: ' (${player.detectionMethod})', style: Manager.bodyStyle),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                          ] else
                            Padding(
                              padding: EdgeInsets.only(left: 16),
                              child: Text(
                                'No media players detected\nPlease ensure VLC or MPC-HC is installed.',
                                style: Manager.bodyStyle.copyWith(fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                      LoadingButton(
                        onPressed: () async {
                          setState(() => _isRefreshingPlayers = true);

                          final monitor = context.read<MediaPlayerMonitorService>();
                          await monitor.refreshMediaPlayers();
                          await monitor.playerManager?.disconnect();
                          await monitor.playerManager?.autoConnect();

                          snackBar('Video Players Reloaded', severity: InfoBarSeverity.success);
                          setState(() => _isRefreshingPlayers = false);
                        },
                        isLoading: _isRefreshingPlayers,
                        isFilled: true,
                        hoverColor: Manager.accentColor.lighter,
                        backgroundColor: Manager.accentColor.light,
                        tooltip: 'Refresh Players list and Player configs',
                        tooltipWaitDuration: dimDuration,
                        label: 'Reload Players',
                        isBigEvenWithoutLoading: true,
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 24),
            ],
          ),
        ),

        // Player Priority Order
        AnimatedHider(
          duration: dimDuration,
          shouldShowChild: settings.enableMediaPlayerIntegration,
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Player Priority Order',
                style: Manager.bodyStrongStyle,
              ),
              SizedBox(height: 4),
              Text(
                'Drag to reorder. The app will try to connect to players in this order of preference.',
                style: Manager.bodyStyle.copyWith(color: Colors.white.withOpacity(.5)),
              ),
              SizedBox(height: 12),
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: settings.mediaPlayerPriority.length,
                buildDefaultDragHandles: false,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) newIndex -= 1;

                    final item = settings.mediaPlayerPriority.removeAt(oldIndex);
                    if (!settings.mediaPlayerPriority.contains(item)) settings.mediaPlayerPriority.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final playerId = settings.mediaPlayerPriority[index];
                  final playerName = playerId == 'vlc'
                      ? 'VLC Media Player'
                      : playerId == 'mpc-hc'
                          ? 'MPC-HC'
                          : playerId;

                  // Get the player instance for this ID
                  MediaPlayer? player = getPlayerFromId(playerId);

                  return Container(
                    key: ValueKey('player_priority_${playerId}_$index'),
                    margin: EdgeInsets.only(bottom: 8),
                    child: Card(
                      child: ListTile(
                        leading: settings.enableMediaPlayerIntegration //
                            ? ReorderableDragStartListener(index: index, child: Icon(mat.Icons.drag_handle, color: Colors.white.withOpacity(.5)))
                            : null,
                        title: Row(
                          children: [
                            if (player?.iconWidget != null)
                              Opacity(
                                opacity: 0.85,
                                child: SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: player!.iconWidget,
                                ),
                              )
                            else
                              Icon(mat.Icons.play_arrow, size: 20, color: Manager.accentColor),
                            SizedBox(width: 12),
                            Text(playerName),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
