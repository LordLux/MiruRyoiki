import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import '../models/library.dart';
import '../models/series.dart';

class ConfirmWatchAllDialog extends StatelessWidget {
  final Series series;

  const ConfirmWatchAllDialog({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 500, minWidth: 300),
      title: const Text('Mark All Watched'),
      content: Text('Are you sure you want to mark all episodes of "${series.displayTitle}" as watched?'),
      actions: [
        Button(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        Button(
          child: const Text('Confirm'),
          onPressed: () async {
            final library = context.read<Library>();
            library.markSeriesWatched(series);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
