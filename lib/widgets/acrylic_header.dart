
import 'package:fluent_ui/fluent_ui.dart';

import '../utils/screen.dart';

class AcrylicHeader extends StatelessWidget {
  final Widget child;
  const AcrylicHeader({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(ScreenUtils.kStatCardBorderRadius)),
      child: Acrylic(
        luminosityAlpha: 1,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 50.0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(ScreenUtils.kStatCardBorderRadius),
              topRight: Radius.circular(ScreenUtils.kStatCardBorderRadius),
            ),
            color: Colors.white.withOpacity(0.05),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: child,
        ),
      ),
    );
  }
}
