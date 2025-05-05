import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import '../models/library.dart';
import '../models/series.dart';
import '../utils/screen_utils.dart';
import '../widgets/series_card.dart';
import 'series.dart';

class HomeScreen extends StatefulWidget {
  final Function(String) onSeriesSelected;

  const HomeScreen({
    super.key,
    required this.onSeriesSelected,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final library = context.watch<Library>();

    if (library.isLoading) return const Center(child: ProgressRing());

    if (library.libraryPath == null) return _buildLibrarySelector();

    if (library.series.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              FluentIcons.folder_open,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text('No series found in your library'),
            const SizedBox(height: 16),
            Button(
              onPressed: _selectLibraryFolder,
              child: const Text('Change Library Folder'),
            ),
          ],
        ),
      );
    }

    return _buildLibraryView(library);
  }

  Widget _buildLibrarySelector() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FluentIcons.folder_open,
            size: 48,
            color: Colors.purple,
          ),
          const SizedBox(height: 16),
          const Text(
            'Select your media library folder to get started',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          Button(
            style: ButtonStyle(
              padding: ButtonState.all(const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              )),
            ),
            onPressed: _selectLibraryFolder,
            child: const Text('Select Library Folder'),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryView(Library library) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Media Library',
                  style: FluentTheme.of(context).typography.title,
                ),
                Button(
                  child: const Text('Refresh'),
                  onPressed: () {
                    library.scanLibrary();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Path: ${library.libraryPath}',
              style: FluentTheme.of(context).typography.caption,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: DynMouseScroll(
                // Tune these parameters to your liking
                scrollSpeed: 3.3,
                durationMS: 300,
                animationCurve: Curves.ease,
                builder: (context, controller, physics) => GridView.builder(
                  controller: controller,
                  physics: physics,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: (constraints.maxWidth ~/ 200).clamp(1, 10),
                    childAspectRatio: 0.71,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: library.series.length,
                  itemBuilder: (context, index) {
                    final series = library.series[index];
                    return SeriesCard(
                      series: series,
                      onTap: () => _navigateToSeries(series),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _selectLibraryFolder() async {
    final String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Media Library Folder',
    );

    if (selectedDirectory != null) {
      final library = context.read<Library>();
      await library.setLibraryPath(selectedDirectory);
    }
  }

  void _navigateToSeries(Series series) => widget.onSeriesSelected(series.path);
}
