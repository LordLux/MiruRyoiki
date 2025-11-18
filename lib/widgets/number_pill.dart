
import 'package:fluent_ui/fluent_ui.dart';

import '../manager.dart';
import '../utils/color.dart';

class NumberPill extends StatelessWidget {
  const NumberPill({super.key, required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Manager.accentColor.light.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Manager.accentColor.light.withOpacity(0.4), width: 1),
      ),
      child: Transform.translate(
        offset: const Offset(0, -0.66),
        child: Text(
          '$number',
          style: Manager.captionStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: lighten(Manager.accentColor.lightest),
          ),
        ),
      ),
    );
  }
}