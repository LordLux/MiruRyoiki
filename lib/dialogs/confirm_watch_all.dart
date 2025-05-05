import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import '../models/library.dart';
import '../models/series.dart';
import '../services/navigation/dialogs.dart';
import '../services/navigation/navigation.dart';

class ConfirmWatchAllDialog extends StatelessWidget {
  final Series series;
  final BoxConstraints constraints;

  const ConfirmWatchAllDialog({
    super.key,
    required this.series,
    this.constraints = const BoxConstraints(maxWidth: 500, minWidth: 300),
  });

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      constraints: constraints,
      title: const Text('Mark All Watched'),
      content: Text('Are you sure you want to mark all episodes of "${series.displayTitle}" as watched?'),
      actions: [
        ManagedDialogButton(), // Cancel button
        ManagedDialogButton(
          text: 'Confirm',
          onPressed: () {
            final library = context.read<Library>();
            library.markSeriesWatched(series);
          },
        ),
      ],
    );
  }
}
