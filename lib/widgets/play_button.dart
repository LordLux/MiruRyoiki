import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:miruryoiki/manager.dart';
import 'package:provider/provider.dart';
import 'package:material_shapes/material_shapes.dart';

import '../models/episode.dart';
import '../services/library/library_provider.dart';
import '../utils/color.dart';

class PlayButton extends StatefulWidget {
  final Episode episode;
  final bool isNextEpisodeToPlay;
  final bool forceExpand;

  const PlayButton({
    super.key,
    required this.episode,
    required this.isNextEpisodeToPlay,
    this.forceExpand = false,
  });

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> with TickerProviderStateMixin {
  late AnimationController _morphController;
  late AnimationController _sizeController;
  late AnimationController _rotationController;
  late AnimationController _quickRotationController;
  bool _isHovered = false;
  bool _rotateClockwise = true;

  static final RoundedPolygon _baseShape = MaterialShapes.square;
  static final List<({RoundedPolygon shape, String title})> _shapes = [
    // (shape: MaterialShapes.circle, title: 'Circle'), // doesn't look good
    // (shape: MaterialShapes.square, title: 'Square'), // base shape
    (shape: MaterialShapes.slanted, title: 'Slanted'),
    (shape: MaterialShapes.arch, title: 'Arch'),
    (shape: MaterialShapes.pill, title: 'Pill'),
    (shape: MaterialShapes.triangle, title: 'Triangle'),
    // (shape: MaterialShapes.diamond, title: 'Diamond'), // doesn't look good
    // (shape: MaterialShapes.clamShell, title: 'Clamshell'), // too thin
    (shape: MaterialShapes.pentagon, title: 'Pentagon'),
    (shape: MaterialShapes.gem, title: 'Gem'),
    (shape: MaterialShapes.sunny, title: 'Sunny'),
    (shape: MaterialShapes.cookie4Sided, title: 'Cookie4'),
    (shape: MaterialShapes.cookie6Sided, title: 'Cookie6'),
    (shape: MaterialShapes.cookie7Sided, title: 'Cookie7'),
    (shape: MaterialShapes.clover4Leaf, title: 'Clover4'),
    (shape: MaterialShapes.clover8Leaf, title: 'Clover8'),
    (shape: MaterialShapes.softBurst, title: 'Soft Burst'),
    (shape: MaterialShapes.flower, title: 'Flower'),
    // (shape: MaterialShapes.puffy, title: 'Puffy'), // doesn't look good
    (shape: MaterialShapes.ghostish, title: 'Ghostish'),
    (shape: MaterialShapes.bun, title: 'Bun'),
  ];

  late Morph _currentMorph;
  int _targetShapeIndex = 0;

  @override
  void initState() {
    super.initState();
    _morphController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _sizeController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _rotationController = AnimationController(duration: const Duration(seconds: 12), vsync: this);
    _quickRotationController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);

    _currentMorph = Morph(_baseShape, _baseShape);
    _targetShapeIndex = 0;

    if (widget.isNextEpisodeToPlay) {
      // Start continuous slow rotation
      _rotationController.repeat();
    }

    // Handle initial expansion if card is already hovered
    if (widget.forceExpand && !widget.isNextEpisodeToPlay) {
      _sizeController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(PlayButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle size expansion when card hover state changes
    if (!widget.isNextEpisodeToPlay && widget.forceExpand != oldWidget.forceExpand) {
      if (widget.forceExpand) {
        _sizeController.forward();
      } else {
        _sizeController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _morphController.dispose();
    _sizeController.dispose();
    _rotationController.dispose();
    _quickRotationController.dispose();
    super.dispose();
  }

  void _playEpisode(Episode episode) {
    final library = Provider.of<Library>(context, listen: false);
    library.playEpisode(episode);
  }

  void _onHoverChanged(bool isHovered) {
    // log(isHovered ? 'Play button hovered' : 'Play button unhovered');
    setState(() => _isHovered = isHovered);

    if (isHovered) {
      // Pick a random target shape and morph to it
      _targetShapeIndex = Random().nextInt(_shapes.length);
      setState(() {
        _currentMorph = Morph(_baseShape, _shapes[_targetShapeIndex].shape);
        _rotateClockwise = true;
      });
      _morphController.forward(from: 0.0);
      _quickRotationController.forward(from: 0.0);
    } else {
      // Morph back to base shape and rotate in reverse
      setState(() {
        _currentMorph = Morph(_shapes[_targetShapeIndex].shape, _baseShape);
        _rotateClockwise = false;
      });
      _morphController.forward(from: 0.0);
      _quickRotationController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.isNextEpisodeToPlay ? 34.0 : 16.0;
    final hoverPadding = 5.0; // Extra padding around the button for hover region

    return MouseRegion(
      onExit: (_) {
        if (_isHovered) _onHoverChanged(false);
      },
      onEnter: (_) {
        if (!_isHovered) _onHoverChanged(true);
      },
      child: Builder(builder: (context) {
        if (!widget.isNextEpisodeToPlay) {
          return AnimatedBuilder(
            animation: _sizeController,
            builder: (context, child) {
              final curvedValue = Curves.easeOut.transform(_sizeController.value);
              final scale = Tween<double>(begin: 1, end: 2).transform(curvedValue);
              final scaledSize = size * scale;

              return SizedBox(
                width: scaledSize + hoverPadding,
                height: scaledSize + hoverPadding,
                child: mat.InkWell(
                  onTap: () => _playEpisode(widget.episode),
                  child: _buildRegularButton(scaledSize + hoverPadding),
                ),
              );
            },
          );
        }

        return MouseRegion(
          onExit: (_) {
            if (_isHovered) {
              _onHoverChanged(false);
            }
          },
          child: SizedBox(
            width: size + hoverPadding,
            height: size + hoverPadding,
            child: Stack(
              alignment: Alignment.center,
              children: [
                mat.InkWell(
                  onTap: () => _playEpisode(widget.episode),
                  child: _buildNextEpisodeButton(size),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNextEpisodeButton(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_morphController, _rotationController, _quickRotationController]),
            builder: (context, _) {
              // Slow rotation + quick rotation combined
              final slowRotation = _rotationController.value * 2 * 3.14159;
              final quickRotation = _quickRotationController.value * 3.14159 * (_rotateClockwise ? .75 : -.75);
              final totalRotation = slowRotation + quickRotation;

              return CustomPaint(
                painter: _PlayButtonMorphPainter(
                  morph: _currentMorph,
                  progress: _morphController.value.clamp(0.0, 1.0),
                  rotation: totalRotation,
                  color: Manager.currentDominantColor,
                ),
                child: const SizedBox.expand(),
              );
            },
          ),
          Icon(
            mat.Icons.play_arrow,
            size: size * 0.6,
            color: getTextColorBasedOnAccent(darkColor: const Color.fromARGB(255, 14, 14, 14)),
          )
        ],
      ),
    );
  }

  Widget _buildRegularButton(double size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_morphController, _quickRotationController]),
          builder: (context, _) {
            final quickRotation = _quickRotationController.value * 3.14159 * (_rotateClockwise ? .5 : -.5);
            return CustomPaint(
              painter: _PlayButtonMorphPainter(
                morph: _currentMorph,
                progress: _morphController.value.clamp(0.0, 1.0),
                rotation: quickRotation,
                color: Manager.currentDominantColor,
              ),
              child: const SizedBox.expand(),
            );
          },
        ),
        Icon(
          mat.Icons.play_arrow,
          size: size * 0.6,
          color: getTextColorBasedOnAccent(darkColor: const Color.fromARGB(255, 24, 24, 24)),
          fill: 1,
        )
      ],
    );
  }
}

class _PlayButtonMorphPainter extends CustomPainter {
  _PlayButtonMorphPainter({
    required this.morph,
    required this.progress,
    required this.rotation,
    Color? color,
  }) : color = color ?? Colors.blue;

  final Morph morph;
  final double progress;
  final double rotation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = morph.toPath(progress: progress);

    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2) // move to center for rotation
      ..rotate(rotation)
      ..scale(size.width, size.height)
      ..translate(-0.5, -0.5) // center the shape
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.fill
          ..color = color,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_PlayButtonMorphPainter oldDelegate) {
    return oldDelegate.morph != morph || oldDelegate.progress != progress || oldDelegate.rotation != rotation;
  }
}
