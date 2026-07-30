import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_desktop_context_menu/flutter_desktop_context_menu.dart';

import '../../services/downloads/torrent_client.dart';
import '../../services/downloads/torrent_manager.dart';
import '../../services/navigation/dialog_framework.dart';
import '../../services/navigation/navigation.dart';
import '../../services/navigation/show_info.dart';
import '../../utils/icons.dart' as icons;
import '../dialogs/show_dialog.dart';
import 'controller.dart';

class TorrentContextMenu extends StatefulWidget {
  final TorrentInfo torrent;
  final Widget child;
  final DesktopContextMenuController controller;
  final VoidCallback? onChanged;

  const TorrentContextMenu({
    super.key,
    required this.torrent,
    required this.child,
    required this.controller,
    this.onChanged,
  });

  @override
  State<TorrentContextMenu> createState() => _TorrentContextMenuState();
}

class _TorrentContextMenuState extends State<TorrentContextMenu> {
  @override
  void initState() {
    super.initState();
    widget.controller.attach(_openMenu, _openMenuAt, this);
  }

  @override
  void didUpdateWidget(TorrentContextMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.detach(this);
      widget.controller.attach(_openMenu, _openMenuAt, this);
    }
  }

  @override
  void dispose() {
    widget.controller.detach(this);
    super.dispose();
  }

  void _openMenu() => _openMenuAt(null, Placement.bottomRight);

  void _openMenuAt(Offset? position, Placement placement) {
    popUpContextMenu(
      _buildMenu(context: context, torrent: widget.torrent),
      position: position,
      placement: placement,
    );
  }

  TorrentClient? get _client => TorrentManager.torrentClient;

  void _notify() => widget.onChanged?.call();

  Future<void> _start() async {
    final client = _client;
    if (client == null) return;
    try {
      await client.resumeTorrent(widget.torrent.hash);
      _notify();
    } catch (e) {
      snackBar('Failed to start: $e', severity: InfoBarSeverity.error);
    }
  }

  Future<void> _forceStart() async {
    final client = _client;
    if (client == null) return;
    try {
      final ok = await client.forceStartTorrent(widget.torrent.hash, value: true);
      if (!ok) throw Exception('Client refused force-start');
      snackBar('Force-started: ${widget.torrent.name}', severity: InfoBarSeverity.success);
      _notify();
    } catch (e) {
      snackBar('Failed to force-start: $e', severity: InfoBarSeverity.error);
    }
  }

  void _confirmRemove() {
    final t = widget.torrent;
    showPaddedDialog(
      context,
      navigationItem: DialogNavigationItem(id: 'downloads:remove-torrent', title: 'Remove Torrent'),
      builder: (context, item, options) {
        return PaddedDialog.custom(
          navigationItem: item,
          barrierOptions: options,
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 300, minWidth: 300),
          contentBuilder: (_, __) => _RemoveTorrentDialogContent(
            torrentName: t.name,
            onConfirm: (deleteFiles) {
              closeDialog();
              _delete(deleteFiles: deleteFiles);
            },
          ),
        );
      },
    );
  }

  Future<void> _delete({required bool deleteFiles}) async {
    final client = _client;
    if (client == null) return;
    try {
      await client.deleteTorrent(widget.torrent.hash, deleteFiles: deleteFiles);
      snackBar('Removed: ${widget.torrent.name}', severity: InfoBarSeverity.success);
      _notify();
    } catch (e) {
      snackBar('Failed to remove: $e', severity: InfoBarSeverity.error);
    }
  }

  void _changeLocation() {
    final t = widget.torrent;
    _showTextInputDialog(
      id: 'downloads:change-location',
      title: 'Change Location',
      label: 'New save path',
      initialValue: t.savePath ?? '',
      confirmLabel: 'Move',
      onSubmit: (value) async {
        final client = _client;
        if (client == null) return;
        try {
          final ok = await client.setLocation(t.hash, value);
          if (!ok) throw Exception('Client refused location change');
          snackBar('Moving to: $value', severity: InfoBarSeverity.success);
          _notify();
        } catch (e) {
          snackBar('Failed to move: $e', severity: InfoBarSeverity.error);
        }
      },
    );
  }

  void _renameTorrent() {
    final t = widget.torrent;
    _showTextInputDialog(
      id: 'downloads:rename-torrent',
      title: 'Rename Torrent',
      label: 'New name',
      initialValue: t.name,
      confirmLabel: 'Rename',
      onSubmit: (value) async {
        final client = _client;
        if (client == null) return;
        try {
          final ok = await client.renameTorrent(t.hash, value);
          if (!ok) throw Exception('Client refused rename');
          _notify();
        } catch (e) {
          snackBar('Failed to rename: $e', severity: InfoBarSeverity.error);
        }
      },
    );
  }

  Future<void> _moveQueue(QueueDirection direction) async {
    final client = _client;
    if (client == null) return;
    try {
      final ok = await client.moveQueue(widget.torrent.hash, direction);
      if (!ok) throw Exception('Client refused queue move');
      _notify();
    } catch (e) {
      snackBar('Failed to move in queue: $e', severity: InfoBarSeverity.error);
    }
  }

  void _copyText(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    snackBar('Copied $label', severity: InfoBarSeverity.success);
  }

  Future<void> _copyMagnet() async {
    final magnet = widget.torrent.magnetUri;
    if (magnet == null || magnet.isEmpty) {
      snackBar('Magnet link unavailable for this torrent', severity: InfoBarSeverity.warning);
      return;
    }
    _copyText(magnet, 'magnet link');
  }

  Future<void> _copyComment() async {
    final client = _client;
    if (client == null) return;
    try {
      final comment = await client.getComment(widget.torrent.hash);
      if (comment == null || comment.isEmpty) {
        snackBar('No comment to copy', severity: InfoBarSeverity.warning);
        return;
      }
      _copyText(comment, 'comment');
    } catch (e) {
      snackBar('Failed to fetch comment: $e', severity: InfoBarSeverity.error);
    }
  }

  Future<void> _exportTorrent() async {
    final client = _client;
    if (client == null) return;
    try {
      final bytes = await client.exportTorrent(widget.torrent.hash);
      if (bytes == null || bytes.isEmpty) {
        snackBar('Failed to export torrent: empty response', severity: InfoBarSeverity.error);
        return;
      }
      final safeName = widget.torrent.name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Torrent File',
        fileName: '$safeName.torrent',
        type: FileType.custom,
        allowedExtensions: const ['torrent'],
        lockParentWindow: true,
      );
      if (savePath == null) return;
      await File(savePath).writeAsBytes(bytes);
      snackBar('Exported to: $savePath', severity: InfoBarSeverity.success);
    } catch (e) {
      snackBar('Failed to export: $e', severity: InfoBarSeverity.error);
    }
  }

  void _showTextInputDialog({
    required String id,
    required String title,
    required String label,
    required String initialValue,
    required String confirmLabel,
    required Future<void> Function(String value) onSubmit,
  }) {
    showPaddedDialog(
      context,
      navigationItem: DialogNavigationItem(id: id, title: title),
      builder: (context, item, options) {
        return PaddedDialog.custom(
          navigationItem: item,
          barrierOptions: options,
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 260, minWidth: 320),
          contentBuilder: (_, __) => _TextInputDialogContent(
            title: title,
            label: label,
            initialValue: initialValue,
            confirmLabel: confirmLabel,
            onSubmit: (value) {
              closeDialog();
              onSubmit(value);
            },
          ),
        );
      },
    );
  }

  Menu _buildMenu({
    required final BuildContext context,
    required final TorrentInfo torrent,
  }) {
    return Menu(
      items: [
        MenuItem(
          label: 'Start',
          icon: icons.play,
          onClick: (_) => _start(),
        ),
        MenuItem(
          label: 'Force Start',
          onClick: (_) => _forceStart(),
        ),
        MenuItem.separator(),
        MenuItem(
          label: 'Remove',
          onClick: (_) => _confirmRemove(),
        ),
        MenuItem.separator(),
        MenuItem(
          label: 'Change Location',
          onClick: (_) => _changeLocation(),
        ),
        MenuItem.submenu(
          label: 'Rename',
          submenu: Menu(
            items: [
              MenuItem(label: 'Rename Torrent', onClick: (_) => _renameTorrent()),
              MenuItem(
                label: 'Rename Files',
                disabled: true,
                onClick: (_) {},
              ),
            ],
          ),
        ),
        MenuItem.separator(),
        MenuItem.submenu(
          label: 'Queue',
          submenu: Menu(
            items: [
              MenuItem(label: 'Move to Top', onClick: (_) => _moveQueue(QueueDirection.top)),
              MenuItem(label: 'Move Up', onClick: (_) => _moveQueue(QueueDirection.up)),
              MenuItem(label: 'Move Down', onClick: (_) => _moveQueue(QueueDirection.down)),
              MenuItem(label: 'Move to Bottom', onClick: (_) => _moveQueue(QueueDirection.bottom)),
            ],
          ),
        ),
        MenuItem.submenu(
          label: 'Copy',
          submenu: Menu(
            items: [
              MenuItem(label: 'Name', onClick: (_) => _copyText(torrent.name, 'name')),
              MenuItem(label: 'Info Hash', onClick: (_) => _copyText(torrent.hash, 'info hash')),
              MenuItem(label: 'Magnet Link', onClick: (_) => _copyMagnet()),
              MenuItem(label: 'Torrent ID', onClick: (_) => _copyText(torrent.hash, 'torrent ID')),
              MenuItem(label: 'Comment', onClick: (_) => _copyComment()),
            ],
          ),
        ),
        MenuItem(
          label: 'Export Torrent',
          onClick: (_) => _exportTorrent(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        if (event.buttons == 2) {
          _openMenuAt(event.position, Placement.bottomRight);
        }
      },
      child: widget.child,
    );
  }
}

class _RemoveTorrentDialogContent extends StatefulWidget {
  final String torrentName;
  final void Function(bool deleteFiles) onConfirm;

  const _RemoveTorrentDialogContent({
    required this.torrentName,
    required this.onConfirm,
  });

  @override
  State<_RemoveTorrentDialogContent> createState() => _RemoveTorrentDialogContentState();
}

class _RemoveTorrentDialogContentState extends State<_RemoveTorrentDialogContent> {
  bool _deleteFiles = false;

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Remove Torrent'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Remove "${widget.torrentName}"?'),
          const SizedBox(height: 16),
          Checkbox(
            checked: _deleteFiles,
            onChanged: (v) => setState(() => _deleteFiles = v ?? false),
            content: const Text('Also delete downloaded files from disk'),
          ),
        ],
      ),
      actions: [
        Button(child: const Text('Cancel'), onPressed: () => closeDialog()),
        FilledButton(
          style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.red)),
          onPressed: () => widget.onConfirm(_deleteFiles),
          child: const Text('Remove'),
        ),
      ],
    );
  }
}

class _TextInputDialogContent extends StatefulWidget {
  final String title;
  final String label;
  final String initialValue;
  final String confirmLabel;
  final void Function(String value) onSubmit;

  const _TextInputDialogContent({
    required this.title,
    required this.label,
    required this.initialValue,
    required this.confirmLabel,
    required this.onSubmit,
  });

  @override
  State<_TextInputDialogContent> createState() => _TextInputDialogContentState();
}

class _TextInputDialogContentState extends State<_TextInputDialogContent> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    widget.onSubmit(value);
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label),
          const SizedBox(height: 8),
          TextBox(
            controller: _controller,
            autofocus: true,
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        Button(child: const Text('Cancel'), onPressed: () => closeDialog()),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
