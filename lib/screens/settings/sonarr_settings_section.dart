// ignore_for_file: use_build_context_synchronously

import 'package:fluent_ui/fluent_ui.dart' hide AnimatedSwitcher;
import 'package:flutter/material.dart' as mat hide AnimatedSwitcher;

import '../../manager.dart';
import '../../models/sonarr/sonarr_quality_profile.dart';
import '../../services/downloads/torrent_manager.dart';
import '../../services/navigation/show_info.dart';
import '../../services/sonarr/sonarr_service.dart';
import '../../settings.dart';
import '../../utils/color.dart';
import '../../utils/screen.dart';
import '../../utils/text.dart';
import '../../utils/time.dart';
import '../../widgets/buttons/button.dart';
import '../../widgets/buttons/hyperlink.dart';
import '../../widgets/svg.dart' as svg;

/// Sonarr connection + defaults section of the Torrents settings category.
///
/// Owns its own connection text controllers, test/loading flags, and the
/// quality-profile / root-folder dropdown data. Re-initializes
/// [TorrentManager] after a successful connection test.
class SonarrSettingsSection extends StatefulWidget {
  final SettingsManager settings;

  const SonarrSettingsSection({super.key, required this.settings});

  @override
  State<SonarrSettingsSection> createState() => _SonarrSettingsSectionState();
}

class _SonarrSettingsSectionState extends State<SonarrSettingsSection> {
  final TextEditingController _sonarrUrlController = TextEditingController();
  final TextEditingController _sonarrApiKeyController = TextEditingController();
  bool _isSonarrTesting = false;
  bool? _sonarrTestResult; // null = not tested, true = ok, false = failed
  bool _isEditing = false; // Whether we're currently editing Sonarr settings
  List<Map<String, dynamic>> _sonarrQualityProfiles = [];
  List<Map<String, dynamic>> _sonarrRootFolders = [];
  bool _isSonarrLoading = false;
  bool _sonarrDropdownsLoaded = false;

  @override
  void initState() {
    super.initState();
    nextFrame(() {
      final settings = widget.settings;
      _sonarrUrlController.text = settings.sonarrBaseUrl; // empty = placeholder shown
      _sonarrApiKeyController.text = settings.sonarrApiKey;

      // Restore verified Sonarr connection state
      if (settings.sonarrConnectionVerified && settings.isSonarrConfigured) {
        setState(() => _sonarrTestResult = true);
        TorrentManager.reinitialize();
        _loadSonarrDropdowns();
      }
    });
  }

  @override
  void dispose() {
    _sonarrUrlController.dispose();
    _sonarrApiKeyController.dispose();
    super.dispose();
  }

  void _loadSonarrDropdowns() async {
    final settings = widget.settings;
    if (!settings.isSonarrConfigured) return;
    setState(() => _isSonarrLoading = true);
    try {
      // Use TorrentManager repo if available, otherwise create a temporary one
      final repo = TorrentManager.sonarrRepository ??
          SonarrRepository(
            baseUrl: settings.sonarrBaseUrl,
            apiKey: settings.sonarrApiKey,
          );
      final profiles = await repo.getQualityProfiles();
      final folders = await repo.getRootFolders();
      if (mounted) {
        setState(() {
          _sonarrQualityProfiles = profiles.map((p) => {'id': p.id, 'name': p.name}).toList();
          _sonarrRootFolders = folders.map((f) => {'id': f.id, 'path': f.path}).toList();
          _isSonarrLoading = false;
          _sonarrDropdownsLoaded = true;

          // Auto-select quality profile if not yet chosen
          if (settings.sonarrQualityProfileId == 0 && profiles.isNotEmpty) {
            // Prefer a profile containing "1080" in the name
            final match = profiles.cast<SonarrQualityProfile?>().firstWhere(
                  (p) => p!.name.contains('1080'),
                  orElse: () => null,
                );
            settings.sonarrQualityProfileId = match?.id ?? profiles.first.id;
          }

          // Auto-select root folder if not yet chosen
          if (settings.sonarrRootFolderPath.isEmpty && folders.isNotEmpty) {
            settings.sonarrRootFolderPath = folders.first.path;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSonarrLoading = false);
        snackBar('Failed to load Sonarr data: $e', severity: InfoBarSeverity.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Connection header
        Row(
          children: [
            SizedBox(width: 44, height: 44, child: svg.sonarr),
            SizedBox(width: 12),
            Text('Sonarr', style: Manager.titleStyle),
          ],
        ),
        VDiv(8),
        Text('Connection', style: Manager.subtitleStyle),
        VDiv(4),
        Text(
          'Configure Sonarr client for local Series management.',
          style: Manager.bodyStyle.copyWith(color: Colors.white.withValues(alpha: .5)),
        ),
        VDiv(12),

        // Base URL
        Row(
          children: [
            SizedBox(width: 100, child: Text('Base URL', style: Manager.bodyStyle)),
            SizedBox(width: 14),
            Expanded(
              child: TextBox(
                controller: _sonarrUrlController,
                placeholder: SonarrRepository.defaultUrlPort, // http://localhost:8989
                placeholderStyle: Manager.bodyStyle.copyWith(color: Colors.white.withValues(alpha: .5), fontStyle: FontStyle.italic),
                onSubmitted: (value) {
                  settings.sonarrBaseUrl = value.trim();
                  _sonarrTestResult = null;
                },
                onChanged: (value) {
                  setState(() {
                    _isEditing = _isEditing || value.trim() != settings.sonarrBaseUrl;
                  });
                },
              ),
            ),
          ],
        ),
        VDiv(12),

        // API Key
        Row(
          children: [
            SizedBox(width: 100, child: Text('API Key', style: Manager.bodyStyle)),
            SizedBox(width: 14),
            Expanded(
              child: PasswordBox(
                controller: _sonarrApiKeyController,
                placeholder: 'Sonarr API key',
                onSubmitted: (value) {
                  settings.sonarrApiKey = value.trim();
                  _sonarrTestResult = null;
                },
                onChanged: (value) {
                  setState(() {
                    _isEditing = _isEditing || value.trim() != settings.sonarrApiKey;
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
              cursor: (_sonarrApiKeyController.text.trim().isNotEmpty && !_isSonarrTesting) ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isSonarrTesting)
                    SizedBox(width: 16, height: 16, child: RepaintBoundary(child: mat.CircularProgressIndicator(strokeWidth: 2)))
                  else
                    Icon(
                      _sonarrTestResult == null
                          ? mat.Icons.wifi_find
                          : _sonarrTestResult!
                              ? mat.Icons.check_circle
                              : mat.Icons.error,
                      size: 18,
                      color: _sonarrTestResult == null
                          ? null
                          : _sonarrTestResult!
                              ? Colors.green
                              : Colors.red,
                    ),
                  SizedBox(width: 8),
                  Text(
                    _isSonarrTesting
                        ? 'Testing...'
                        : _sonarrTestResult == null || _isEditing
                            ? 'Test Connection'
                            : _sonarrTestResult!
                                ? 'Connected'
                                : 'Failed',
                    style: Manager.bodyStyle,
                  ),
                ],
              ),
              onPressed: _isSonarrTesting || _sonarrApiKeyController.text.trim().isEmpty
                  ? null
                  : () async {
                      // Save current values before testing
                      settings.sonarrBaseUrl = _sonarrUrlController.text.trim();
                      settings.sonarrApiKey = _sonarrApiKeyController.text.trim();

                      setState(() {
                        _isSonarrTesting = true;
                        _sonarrTestResult = null;
                        _isEditing = false;
                      });
                      try {
                        // Create a temporary repo to test
                        final testRepo = SonarrRepository(
                          baseUrl: settings.sonarrBaseUrl,
                          apiKey: settings.sonarrApiKey,
                        );
                        final ok = await testRepo.testConnection();
                        if (mounted) {
                          setState(() {
                            _sonarrTestResult = ok;
                            _isSonarrTesting = false;
                          });
                          if (ok) {
                            settings.sonarrConnectionVerified = true;
                            TorrentManager.reinitialize();
                            _loadSonarrDropdowns();
                          }
                        }
                      } catch (_) {
                        if (mounted)
                          setState(() {
                            _sonarrTestResult = false;
                            _isSonarrTesting = false;
                          });
                      }
                    },
              tooltip: () {
                if (_sonarrApiKeyController.text.trim().isEmpty) return 'Enter an API Key to enable testing';
                return null;
              }(),
            ),
            if (_sonarrTestResult == false) ...[
              SizedBox(width: 12),
              Text('Could not reach Sonarr. Check URL and API key.', style: Manager.bodyStyle.copyWith(color: Colors.red)),
            ],
          ],
        ),

        VDiv(24),
        InfoBar(
          title: Text('Tip', style: Manager.bodyStrongStyle),
          content: Row(
            children: [
              Text(
                'You can find your API key in Sonarr under Settings → General → Security, or click',
                style: Manager.bodyStyle,
              ),
              SizedBox(width: 12),
              Transform.translate(
                offset: Offset(0, 1),
                child: WrappedHyperlinkButton(
                  text: 'here',
                  url: '${settings.sonarrBaseUrl.fallbackIfEmpty(SonarrRepository.defaultUrlPort)}/settings/general',
                  style: Manager.bodyStyle,
                  icon: Icon(mat.Icons.open_in_new, size: 16, color: getPrimaryColorBasedOnAccent()),
                ),
              ),
            ],
          ),
          severity: InfoBarSeverity.info,
        ),
        VDiv(24),
        Divider(),

        if (settings.isSonarrConfigured && _sonarrTestResult != false) ...[
          VDiv(16),

          // Defaults header
          Text('Defaults', style: Manager.subtitleStyle),
          VDiv(4),
          Text(
            'These are used when adding new series to Sonarr.',
            style: Manager.bodyStyle.copyWith(color: Colors.white.withValues(alpha: .5)),
          ),
          VDiv(16),

          // Quality Profile dropdown
          Row(
            children: [
              Text('Quality Profile', style: Manager.bodyStyle),
              SizedBox(width: 24),
              if (_isSonarrLoading)
                SizedBox(width: 16, height: 16, child: RepaintBoundary(child: mat.CircularProgressIndicator(strokeWidth: 2)))
              else if (_sonarrQualityProfiles.isEmpty)
                _sonarrDropdownsLoaded
                    ? Tooltip(
                        message: 'Add at least one quality profile in Sonarr under Settings → Profiles before continuing.',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(mat.Icons.error_outline, size: 16, color: Colors.red),
                            SizedBox(width: 6),
                            Text('No profiles found in Sonarr', style: Manager.bodyStyle.copyWith(color: Colors.red)),
                          ],
                        ),
                      )
                    : Text('Test connection first', style: Manager.bodyStyle.copyWith(color: Colors.white.withValues(alpha: .5)))
              else
                ComboBox<int>(
                  value: settings.sonarrQualityProfileId == 0 ? null : settings.sonarrQualityProfileId,
                  placeholder: Text('Select a profile'),
                  items: _sonarrQualityProfiles.map((p) => ComboBoxItem<int>(value: p['id'] as int, child: Text(p['name'] as String))).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => settings.sonarrQualityProfileId = value);
                  },
                ),
            ],
          ),
          VDiv(16),

          // Root Folder dropdown
          Row(
            children: [
              Text('Root Folder', style: Manager.bodyStyle),
              SizedBox(width: 24),
              if (_isSonarrLoading)
                SizedBox(width: 16, height: 16, child: RepaintBoundary(child: mat.CircularProgressIndicator(strokeWidth: 2)))
              else if (_sonarrRootFolders.isEmpty)
                _sonarrDropdownsLoaded
                    ? Tooltip(
                        message: 'Add at least one root folder in Sonarr under Settings → Media Management → Root Folders before continuing.',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(mat.Icons.error_outline, size: 16, color: Colors.red),
                            SizedBox(width: 6),
                            Text('No root folders found in Sonarr', style: Manager.bodyStyle.copyWith(color: Colors.red)),
                          ],
                        ),
                      )
                    : Text('Test connection first', style: Manager.bodyStyle.copyWith(color: Colors.white.withValues(alpha: .5)))
              else
                ComboBox<String>(
                  value: settings.sonarrRootFolderPath.isEmpty ? null : settings.sonarrRootFolderPath,
                  placeholder: Text('Select root folder'),
                  items: _sonarrRootFolders.map((f) => ComboBoxItem<String>(value: f['path'] as String, child: Text(f['path'] as String))).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => settings.sonarrRootFolderPath = value);
                  },
                ),
            ],
          ),
        ],

        VDiv(24),
        InfoBar(
          title: Text('Tip', style: Manager.bodyStrongStyle),
          content: Row(
            children: [
              Text(
                'You can find your Quality Profiles in Sonarr under Settings → Profiles, or click',
                style: Manager.bodyStyle,
              ),
              SizedBox(width: 12),
              Transform.translate(
                offset: Offset(0, 1),
                child: WrappedHyperlinkButton(
                  text: 'here',
                  url: '${settings.sonarrBaseUrl.fallbackIfEmpty(SonarrRepository.defaultUrlPort)}/settings/profiles',
                  style: Manager.bodyStyle,
                  icon: Icon(mat.Icons.open_in_new, size: 16, color: getPrimaryColorBasedOnAccent()),
                ),
              ),
            ],
          ),
          severity: InfoBarSeverity.info,
        ),
      ],
    );
  }
}
