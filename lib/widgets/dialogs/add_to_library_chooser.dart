import 'package:fluent_ui/fluent_ui.dart';

class AddToLibraryChooserDialog extends StatelessWidget {
  final VoidCallback onNewSeries;
  final VoidCallback onExistingSeries;

  const AddToLibraryChooserDialog({
    super.key,
    required this.onNewSeries,
    required this.onExistingSeries,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Where should this AniList entry go?',
          style: TextStyle(fontSize: 12, color: Colors.grey[120]),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ChoiceCard(
                icon: FluentIcons.add,
                title: 'New Series',
                subtitle: 'Create a new library series for this entry.',
                onPressed: onNewSeries,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ChoiceCard(
                icon: FluentIcons.library,
                title: 'Existing Series',
                subtitle: 'Attach this entry to a series already in your library.',
                onPressed: onExistingSeries,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Button(
      onPressed: onPressed,
      style: ButtonStyle(padding: WidgetStatePropertyAll(const EdgeInsets.all(16))),
      child: SizedBox(
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey[120]),
              maxLines: 2,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
