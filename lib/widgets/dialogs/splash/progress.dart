import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import '../../../services/library/library_provider.dart';

class LibraryScanProgressIndicator extends StatelessWidget {
  const LibraryScanProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Library>(
      builder: (context, library, _) {
        if (!library.isLoading /*|| library.scanProgress == null*/) {
          return Text('No library scan in progress');
        }

        return Container();

        //   final progress = library.scanProgress!;
        //   final percentage = progress.total > 0 ? (progress.processed / progress.total * 100).toInt() : 0;

        //   return Positioned(
        //     right: 16,
        //     bottom: 16,
        //     child: Card(
        //       child: Padding(
        //         padding: const EdgeInsets.all(12.0),
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           mainAxisSize: MainAxisSize.min,
        //           children: [
        //             Text(
        //               'Scanning library: ${progress.processed}/${progress.total}',
        //               style: FluentTheme.of(context).typography.caption,
        //             ),
        //             const SizedBox(height: 8),
        //             SizedBox(
        //               width: 200,
        //               child: ProgressBar(value: percentage.toDouble()),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ),
        //   );
      },
    );
  }
}
