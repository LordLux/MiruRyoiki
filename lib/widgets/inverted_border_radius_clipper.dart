import 'package:fluent_ui/fluent_ui.dart';

class InvertedBorderRadiusClipper extends CustomClipper<Path> {
  final BorderRadiusGeometry borderRadius;
  final double? left;
  final double? top;
  final double? width;
  final double? height;

  InvertedBorderRadiusClipper({
    this.borderRadius = BorderRadius.zero,
    this.left,
    this.top,
    this.width,
    this.height,
  });

  factory InvertedBorderRadiusClipper.all(double radius, {Rect? rect, double? left, double? top, double? width, double? height}) {
    assert(
      rect != null || (left != null || top != null || width != null || height != null),
      'Either rect or some of left, top, width, and height must be provided.',
    );
    return InvertedBorderRadiusClipper(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      left: left ?? rect?.left,
      top: top ?? rect?.top,
      width: width ?? rect?.width,
      height: height ?? rect?.height,
    );
  }

  factory InvertedBorderRadiusClipper.only({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
    Rect? rect,
    double? left,
    double? top,
    double? width,
    double? height,
  }) {
    return InvertedBorderRadiusClipper(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(topLeft),
        topRight: Radius.circular(topRight),
        bottomLeft: Radius.circular(bottomLeft),
        bottomRight: Radius.circular(bottomRight),
      ),
      left: left ?? rect?.left,
      top: top ?? rect?.top,
      width: width ?? rect?.width,
      height: height ?? rect?.height,
    );
  }

  factory InvertedBorderRadiusClipper.circular(
    double radius, {
    Rect? rect,
    double? left,
    double? top,
    double? width,
    double? height,
  }) {
    assert(
      rect != null || (left != null || top != null || width != null || height != null),
      'Either rect or some of left, top, width, and height must be provided.',
    );
    return InvertedBorderRadiusClipper(
      borderRadius: BorderRadius.circular(radius),
      left: left ?? rect?.left,
      top: top ?? rect?.top,
      width: width ?? rect?.width,
      height: height ?? rect?.height,
    );
  }

  factory InvertedBorderRadiusClipper.vertical({
    double topRadius = 0,
    double bottomRadius = 0,
    Rect? rect,
    double? left,
    double? top,
    double? width,
    double? height,
  }) {
    assert(
      rect != null || (left != null || top != null || width != null || height != null),
      'Either rect or some of left, top, width, and height must be provided.',
    );
    return InvertedBorderRadiusClipper(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(topRadius),
        bottom: Radius.circular(bottomRadius),
      ),
      left: left ?? rect?.left,
      top: top ?? rect?.top,
      width: width ?? rect?.width,
      height: height ?? rect?.height,
    );
  }

  factory InvertedBorderRadiusClipper.horizontal({
    double leftRadius = 0,
    double rightRadius = 0,
    Rect? rect,
    double? left,
    double? top,
    double? width,
    double? height,
  }) {
    assert(
      rect != null || (left != null || top != null || width != null || height != null),
      'Either rect or some of left, top, width, and height must be provided.',
    );
    return InvertedBorderRadiusClipper(
      borderRadius: BorderRadius.horizontal(
        left: Radius.circular(leftRadius),
        right: Radius.circular(rightRadius),
      ),
      left: left ?? rect?.left,
      top: top ?? rect?.top,
      width: width ?? rect?.width,
      height: height ?? rect?.height,
    );
  }

  @override
  Path getClip(Size size) {
    final Path path = Path();

    // Outer rectangle (full size)
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Inner rectangle with BorderRadiusGeometry
    final innerRect = borderRadius
        .resolve(TextDirection.ltr) //
        .toRRect(Rect.fromLTWH(
          left ?? 0,
          top ?? 0,
          width ?? size.width,
          height ?? size.height,
        ));

    // Combine paths (subtract inner rounded rect)
    path.addRRect(innerRect);
    path.fillType = PathFillType.evenOdd;

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}