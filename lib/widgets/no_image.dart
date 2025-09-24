import 'package:fluent_ui/fluent_ui.dart';

class NoImageWidget extends StatelessWidget {
  const NoImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.withOpacity(0.3),
      child: const Icon(FluentIcons.photo2),
    );
  }
}
