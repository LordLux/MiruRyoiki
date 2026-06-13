// ignore_for_file: use_build_context_synchronously

import 'package:fluent_ui/fluent_ui.dart' hide AnimatedSwitcher;
import 'package:flutter/material.dart' as mat hide AnimatedSwitcher;

import '../../manager.dart';
import '../../services/downloads/speed_graph_service.dart';
import '../../services/downloads/torrent_manager.dart';
import '../../services/qbittorrent/qbittorrent.dart';
import '../../settings.dart';
import '../../utils/screen.dart';
import '../../utils/time.dart';
import '../../widgets/buttons/button.dart';
import '../../widgets/svg.dart' as svg;

/// qBittorrent connection + speed-graph section of the Torrents settings
/// category.
///
/// Owns its own connection text controllers, test/loading flags, and the
/// speed-graph metrics flyout controller. Re-initializes [TorrentManager]
/// after a successful connection test.
class QbitSettingsSection extends StatefulWidget {
  final SettingsManager settings;

  const QbitSettingsSection({super.key, required this.settings});

  @override
  State<QbitSettingsSection> createState() => _QbitSettingsSectionState();
}

class _QbitSettingsSectionState extends State<QbitSettingsSection> {
  final TextEditingController _qbitUrlController = TextEditingController();
  final TextEditingController _qbitUsernameController = TextEditingController();
  final TextEditingController _qbitPasswordController = TextEditingController();
  bool _isQbitTesting = false;
  bool? _qbitTestResult;
  bool _isQbitEditing = false;
  final FlyoutController _graphMetricsFlyoutController = FlyoutController();

  @override
  void initState() {
    super.initState();
    nextFrame(() {
      final settings = widget.settings;
      _qbitUrlController.text = settings.qbitBaseUrl; // empty = placeholder shown
      _qbitUsernameController.text = settings.qbitUsername; // empty = placeholder shown
      _qbitPasswordController.text = settings.qbitPassword;

      // Restore verified qBittorrent connection state
      if (settings.qbitConnectionVerified && settings.isQbitConfigured) {
        setState(() => _qbitTestResult = true);
      }
    });
  }

  @override
  void dispose() {
    _qbitUrlController.dispose();
    _qbitUsernameController.dispose();
    _qbitPasswordController.dispose();
    _graphMetricsFlyoutController.dispose();
    super.dispose();
  }

  void _showMetricsFlyout(BuildContext context, SettingsManager settings) {
    _graphMetricsFlyoutController.showFlyout(
      barrierDismissible: true,
      dismissOnPointerMoveAway: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setFlyoutState) {
            return FlyoutContent(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: SpeedMetric.values.map((metric) {
                  final isEnabled = settings.graphMetrics.contains(metric.name);
                  return Checkbox(
                    checked: isEnabled,
                    onChanged: (v) {
                      final metrics = Set<String>.from(settings.graphMetrics);
                      if (v == true) {
                        metrics.add(metric.name);
                      } else {
                        metrics.remove(metric.name);
                      }
                      settings.graphMetrics = metrics;
                      setFlyoutState(() {});
                      setState(() {});
                    },
                    content: Text(metric.label, style: Manager.bodyStyle),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: 44, height: 44, child: svg.qbittorrent),
            SizedBox(width: 12),
            Text('qBittorrent', style: Manager.titleStyle),
          ],
        ),
        VDiv(8),
        Text('Connection', style: Manager.subtitleStyle),
        VDiv(4),
        Text(
          'Configure your torrent client for downloading.',
          style: Manager.bodyStyle.copyWith(color: Colors.white.withValues(alpha: .5)),
        ),
        VDiv(16),

        // Base URL
        Row(
          children: [
            SizedBox(width: 100, child: Text('Base URL', style: Manager.bodyStyle)),
            SizedBox(width: 12),
            Expanded(
              child: TextBox(
                controller: _qbitUrlController,
                placeholder: 'http://localhost:8080',
                placeholderStyle: Manager.bodyStyle.copyWith(color: Colors.white.withValues(alpha: .5), fontStyle: FontStyle.italic),
                onSubmitted: (value) {
                  settings.qbitBaseUrl = value.trim();
                  _qbitTestResult = null;
                },
                onChanged: (value) {
                  setState(() {
                    _isQbitEditing = _isQbitEditing || value.trim() != settings.qbitBaseUrl;
                  });
                },
              ),
            ),
          ],
        ),
        VDiv(12),

        // Username
        Row(
          children: [
            SizedBox(width: 100, child: Text('Username', style: Manager.bodyStyle)),
            SizedBox(width: 12),
            Expanded(
              child: TextBox(
                controller: _qbitUsernameController,
                placeholder: 'admin',
                placeholderStyle: Manager.bodyStyle.copyWith(color: Colors.white.withValues(alpha: .5), fontStyle: FontStyle.italic),
                onSubmitted: (value) {
                  settings.qbitUsername = value.trim();
                  _qbitTestResult = null;
                },
                onChanged: (value) {
                  setState(() {
                    _isQbitEditing = _isQbitEditing || value.trim() != settings.qbitUsername;
                  });
                },
              ),
            ),
          ],
        ),
        VDiv(12),

        // Password
        Row(
          children: [
            SizedBox(width: 100, child: Text('Password', style: Manager.bodyStyle)),
            SizedBox(width: 12),
            Expanded(
              child: PasswordBox(
                controller: _qbitPasswordController,
                onSubmitted: (value) {
                  settings.qbitPassword = value.trim();
                  _qbitTestResult = null;
                },
                onChanged: (value) {
                  setState(() {
                    _isQbitEditing = _isQbitEditing || value.trim() != settings.qbitPassword;
                  });
                },
              ),
            ),
          ],
        ),
        VDiv(16),

        // Test Connection button
        Row(
          children: [
            StandardButton(
              cursor: (_qbitPasswordController.text.isNotEmpty && !_isQbitTesting) ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isQbitTesting)
                    SizedBox(width: 16, height: 16, child: RepaintBoundary(child: mat.CircularProgressIndicator(strokeWidth: 2)))
                  else
                    Icon(
                      _qbitTestResult == null
                          ? mat.Icons.wifi_find
                          : _qbitTestResult!
                              ? mat.Icons.check_circle
                              : mat.Icons.error,
                      size: 18,
                      color: _qbitTestResult == null
                          ? null
                          : _qbitTestResult!
                              ? Colors.green
                              : Colors.red,
                    ),
                  SizedBox(width: 8),
                  Text(
                    _isQbitTesting
                        ? 'Testing...'
                        : _qbitTestResult == null || _isQbitEditing
                            ? 'Test Connection'
                            : _qbitTestResult!
                                ? 'Connected'
                                : 'Failed',
                    style: Manager.bodyStyle,
                  ),
                ],
              ),
              onPressed: _isQbitTesting || _qbitPasswordController.text.isEmpty
                  ? null
                  : () async {
                      // Save current values before testing
                      settings.qbitBaseUrl = _qbitUrlController.text.trim();
                      settings.qbitUsername = _qbitUsernameController.text.trim();
                      settings.qbitPassword = _qbitPasswordController.text.trim();

                      setState(() {
                        _isQbitTesting = true;
                        _qbitTestResult = null;
                        _isQbitEditing = false;
                      });
                      try {
                        final testClient = QBittorrentRepository(
                          baseUrl: settings.qbitBaseUrl,
                          username: settings.qbitUsername,
                          password: settings.qbitPassword,
                        );
                        final ok = await testClient.testConnection();
                        if (mounted) {
                          setState(() {
                            _qbitTestResult = ok;
                            _isQbitTesting = false;
                          });
                          if (ok) {
                            settings.qbitConnectionVerified = true;
                            TorrentManager.reinitialize();
                          }
                        }
                      } catch (_) {
                        if (mounted)
                          setState(() {
                            _qbitTestResult = false;
                            _isQbitTesting = false;
                          });
                      }
                    },
              tooltip: _qbitPasswordController.text.isEmpty ? 'Enter a password to enable testing' : null,
            ),
            if (_qbitTestResult == false) ...[
              SizedBox(width: 12),
              Text('Could not reach qBittorrent. Check URL and credentials.', style: Manager.bodyStyle.copyWith(color: Colors.red)),
            ],
          ],
        ),

        VDiv(24),
        InfoBar(
          title: Text('Tip', style: Manager.bodyStrongStyle),
          content: Row(
            children: [
              Text(
                'You can find your Username and Password in qBittorrent under Settings → WebUI → Authentication',
                style: Manager.bodyStyle,
              ),
            ],
          ),
          severity: InfoBarSeverity.info,
        ),

        VDiv(32),
        Divider(),
        VDiv(24),
        Text('Speed Graph', style: Manager.subtitleStyle),
        VDiv(4),
        Text(
          'Configure the transfer speed graph shown on the Downloads screen.',
          style: Manager.bodyStyle.copyWith(color: Colors.white.withValues(alpha: 0.5)),
        ),
        VDiv(16),

        // Timeframe
        Row(
          children: [
            SizedBox(width: 140, child: Text('Timeframe', style: Manager.bodyStyle)),
            HDiv(12),
            ComboBox<int>(
              value: settings.graphTimeframeMinutes,
              items: const [
                ComboBoxItem(value: 1, child: Text('1 minute')),
                ComboBoxItem(value: 5, child: Text('5 minutes')),
                ComboBoxItem(value: 10, child: Text('10 minutes')),
                ComboBoxItem(value: 30, child: Text('30 minutes')),
                ComboBoxItem(value: 60, child: Text('1 hour')),
              ],
              onChanged: (v) {
                if (v != null) {
                  setState(() => settings.graphTimeframeMinutes = v);
                  TorrentManager.speedGraphService?.setDisplayTimeframeMinutes(v);
                }
              },
            ),
          ],
        ),
        VDiv(12),

        // Update frequency
        Row(
          children: [
            SizedBox(width: 140, child: Text('Update every', style: Manager.bodyStyle)),
            HDiv(12),
            ComboBox<int>(
              value: settings.graphUpdateFrequencySeconds,
              items: const [
                ComboBoxItem(value: 1, child: Text('1 second')),
                ComboBoxItem(value: 2, child: Text('2 seconds')),
                ComboBoxItem(value: 5, child: Text('5 seconds')),
                ComboBoxItem(value: 10, child: Text('10 seconds')),
              ],
              onChanged: (v) {
                if (v != null) {
                  setState(() => settings.graphUpdateFrequencySeconds = v);
                  TorrentManager.speedGraphService?.setUpdateFrequency(v);
                }
              },
            ),
          ],
        ),
        VDiv(12),

        // Metrics selection
        Row(
          children: [
            SizedBox(width: 140, child: Text('Metrics', style: Manager.bodyStyle)),
            HDiv(12),
            FlyoutTarget(
              controller: _graphMetricsFlyoutController,
              child: Builder(
                builder: (context) => StandardButton.label(
                  label: '${settings.graphMetrics.length} metric${settings.graphMetrics.length == 1 ? '' : 's'} selected',
                  onPressed: () => _showMetricsFlyout(context, settings),
                ),
              ),
            ),
          ],
        ),
        VDiv(8),
        Text(
          'Payload, Overhead, DHT, and Tracker metrics may not be available in all qBittorrent versions.',
          style: Manager.miniBodyStyle.copyWith(color: Colors.white.withValues(alpha: 0.4)),
        ),
      ],
    );
  }
}
