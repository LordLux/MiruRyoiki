import 'package:fluent_ui/fluent_ui.dart' as fluent show InfoBarSeverity;
import 'package:flutter/material.dart';
import 'package:miruryoiki/functions.dart';
import 'package:miruryoiki/services/navigation/dialogs.dart';
import 'package:miruryoiki/services/navigation/show_info.dart';
import '../../manager.dart';
import '../../utils/database_recovery.dart';
import '../../utils/time.dart';
import '../buttons/button.dart';

/// Dialog for handling database lock recovery
class DatabaseRecoveryDialog extends StatefulWidget {
  const DatabaseRecoveryDialog({super.key});

  @override
  State<DatabaseRecoveryDialog> createState() => _DatabaseRecoveryDialogState();
}

class _DatabaseRecoveryDialogState extends State<DatabaseRecoveryDialog> {
  bool _isProcessing = false;
  final ExpansionTileController expansionTileKey = ExpansionTileController();

  @override
  void initState() {
    super.initState();
    _expandTileInitially();
  }

  Future<void> _expandTileInitially() async {
    nextFrame(() {
      if (mounted && !expansionTileKey.isExpanded) expansionTileKey.expand();
    });
  }

  Future<bool> _attemptAutomaticRecovery() async {
    setState(() => _isProcessing = true);

    try {
      final result = await DatabaseRecovery.attemptAutomaticRecovery();

      setState(() => _isProcessing = false);

      if (result.success) {
        // Close dialog after successful recovery
        snackBar(result.message, severity: fluent.InfoBarSeverity.success);
        
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) closeDialog(context);
        return true;
      }
    } catch (e, st) {
      setState(() => _isProcessing = false);
      snackBar('Automatic recovery failed', severity: fluent.InfoBarSeverity.error, exception: e, stackTrace: st);
    }
    return false;
  }

  void _copyInstructionsToClipboard() {
    final instructions = DatabaseRecovery.getManualRecoveryInstructions().join('\n');
    copyToClipboard(instructions);

    snackBar(
      'Instructions copied to clipboard',
      severity: fluent.InfoBarSeverity.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'The database appears to be locked, likely due to an interrupted operation. '
            'This usually happens when the app is force-closed during a save operation.',
          ),
          const SizedBox(height: 16),
          // Manual instructions (primary option)
          ExpansionTile(
            controller: expansionTileKey,
            collapsedIconColor: Colors.white,
            iconColor: Colors.white,
            leading: const Icon(Icons.description, color: Colors.blue),
            title: const Text('Manual Fix (Recommended)', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Safest option - follow these steps'),
            children: [
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...DatabaseRecovery.getManualRecoveryInstructions().map((instruction) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(instruction, style: const TextStyle(fontFamily: 'monospace')),
                        )),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: StandardButton.iconLabel(
                        onPressed: _copyInstructionsToClipboard,
                        expand: false,
                        isSmall: true,
                        icon: const Icon(Icons.copy, color: Colors.white),
                        label: Text('Copy Instructions', style: Manager.bodyStrongStyle.copyWith(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Automatic recovery (secondary option)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_fix_high, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Automatic Fix', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Attempts to fix the issue automatically. This will try to '
                  'safely remove the lock file if possible.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: StandardButton.iconLabel(
                    onPressed: _isProcessing ? null : () => _attemptAutomaticRecovery(),
                    icon: _isProcessing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.healing, color: Colors.white),
                    label: Text(_isProcessing ? 'Processing...' : 'Attempt Automatic Fix', style: Manager.bodyStrongStyle.copyWith(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('In the event that the above methods do not resolve the issue, you can try restoring from a previous backup.', style: Manager.miniBodyStyle),
          ),
        ],
      ),
    );
  }
}

/// Function to show the database recovery dialog
Future<bool?> showDatabaseRecoveryDialog(BuildContext context) {
  return showSimpleOneButtonManagedDialog<bool>(
    id: 'database_recovery',
    context: context,
    builder: (_) => const DatabaseRecoveryDialog(),
    title: 'Database Recovery',
  );
}
