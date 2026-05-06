// ignore_for_file: use_build_context_synchronously

import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/services/navigation/show_info.dart';
import 'package:path/path.dart' as p;

import '../../services/navigation/navigation.dart';
import '../../utils/filename.dart';
import '../../utils/path.dart';

enum _Preset { sonarr, romaji, english, cleaned }

class FolderConfirmDialog extends StatefulWidget {
  final int anilistId;
  final String? sonarrTitle;
  final int? sonarrSeriesId;
  final String libraryRootPath;
  final String romajiTitle;
  final String englishTitle;
  final String userPreferredTitle;
  final Future<void> Function(String finalLocalPath) onConfirm;

  const FolderConfirmDialog({
    super.key,
    required this.anilistId,
    required this.sonarrTitle,
    required this.sonarrSeriesId,
    required this.libraryRootPath,
    required this.romajiTitle,
    required this.englishTitle,
    required this.userPreferredTitle,
    required this.onConfirm,
  });

  @override
  State<FolderConfirmDialog> createState() => _FolderConfirmDialogState();
}

class _FolderConfirmDialogState extends State<FolderConfirmDialog> {
  late _Preset _selectedPreset;
  late final TextEditingController _pathController;
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _selectedPreset = widget.sonarrTitle != null ? _Preset.sonarr : _Preset.cleaned;
    _pathController = TextEditingController(text: _nameFor(_selectedPreset));
  }

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  String _nameFor(_Preset preset) => switch (preset) {
        _Preset.sonarr => FilenameUtils.sanitize(widget.sonarrTitle ?? ''),
        _Preset.romaji => FilenameUtils.sanitize(widget.romajiTitle),
        _Preset.english => FilenameUtils.sanitize(widget.englishTitle),
        _Preset.cleaned => FilenameUtils.sanitizeForFolder(widget.userPreferredTitle),
      };

  bool _hasCollision(PathString path) => path.path.isNotEmpty && path.directory!.existsSync();

  List<(_Preset, String, String)> _buildOptions() {
    final seen = <String>{};
    final result = <(_Preset, String, String)>[];

    void add(_Preset preset, String label) {
      if (preset == _Preset.sonarr && widget.sonarrTitle == null) return;
      final name = _nameFor(preset);
      if (name.isEmpty) return;
      if (!seen.contains(name)) {
        seen.add(name);
        result.add((preset, label, name));
      }
    }

    add(_Preset.sonarr, 'Sonarr title');
    add(_Preset.romaji, 'AniList Romaji');
    add(_Preset.english, 'AniList English');
    add(_Preset.cleaned, 'AniList (cleaned)');

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final options = _buildOptions();
    final seriesFolder = _pathController.text
        .trim()
        .replaceAll(RegExp(PathString.unallowedWindowsCharactersPattern, caseSensitive: false), '')
        .trim();
    final currentPathString = PathString(p.join(widget.libraryRootPath, seriesFolder));
    bool collision;
    try {
      collision = _hasCollision(currentPathString);
    } catch (_) {
      collision = false;
      snackBar('Please enter a valid path.', severity: InfoBarSeverity.warning);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Choose folder name', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...options.map((opt) {
          final (preset, label, name) = opt;
          return RadioButton(
            checked: _selectedPreset == preset,
            onChanged: (checked) {
              if (checked) {
                setState(() {
                  _selectedPreset = preset;
                  _pathController.text = _nameFor(preset);
                });
              }
            },
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label),
                Text(name, style: TextStyle(fontSize: 11, color: Colors.grey[120])),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
        const Text('Folder path (editable):'),
        const SizedBox(height: 4),
        TextBox(
          controller: _pathController,
          prefix: Padding(
            padding: const EdgeInsets.only(left: 0.0),
            child: Tooltip(
              message: widget.libraryRootPath,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: Transform.translate(
                  offset: const Offset(9, -1),
                  child: Text(
                    '${widget.libraryRootPath}$ps',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[120]),
                  ),
                ),
              ),
            ),
          ),
          inputFormatters: [PathString.pathInputFormatter],
          onChanged: (_) => setState(() {}),
        ),
        if (collision) ...[
          const SizedBox(height: 6),
          const Text(
            'Warning: A folder already exists at this path.',
            style: TextStyle(color: Colors.warningPrimaryColor),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Button(
              onPressed: _isConfirming ? null : closeDialog,
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: seriesFolder.isEmpty || _isConfirming ? null : _confirm,
              child: _isConfirming ? const SizedBox(width: 16, height: 16, child: ProgressRing(strokeWidth: 2)) : const Text('Confirm'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _confirm() async {
    final seriesFolder = _pathController.text
        .trim()
        .replaceAll(RegExp(PathString.unallowedWindowsCharactersPattern, caseSensitive: false), '')
        .trim();
    if (seriesFolder.isEmpty) return;

    final finalPath = p.join(widget.libraryRootPath, seriesFolder);
    setState(() => _isConfirming = true);
    try {
      await widget.onConfirm(finalPath);
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }
}
