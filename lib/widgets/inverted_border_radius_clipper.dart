import 'package:fluent_ui/fluent_ui.dart';

class InvertedBorderRadiusClipper extends CustomClipper<Path> {
  final BorderRadiusGeometry borderRadius;

  InvertedBorderRadiusClipper({this.borderRadius = BorderRadius.zero});

  @override
  Path getClip(Size size) {
    final Path path = Path();

    // Outer rectangle (full size)
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Inner rectangle with BorderRadiusGeometry
    final innerRect = borderRadius.resolve(TextDirection.ltr).toRRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    // Combine paths (subtract inner rounded rect)
    path.addRRect(innerRect);
    path.fillType = PathFillType.evenOdd;

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
