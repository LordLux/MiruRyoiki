import 'package:fluent_ui/fluent_ui.dart';
import '../manager.dart';
import '../models/players/mediastatus.dart';

class VideoDurationBar extends StatefulWidget {
  final MediaStatus? status;
  final Function(int seconds)? onSeek;
  final Function()? onSeekDown;
  final Function()? onSeekUp;
  final double height;
  final Color progressColor;
  final Color backgroundColor;
  final Color thumbColor;

  VideoDurationBar({
    super.key,
    this.status,
    this.onSeek,
    this.onSeekDown,
    this.onSeekUp,
    this.height = 4.0,
    Color? progressColor,
    Color? backgroundColor,
    Color? thumbColor,
  })  : backgroundColor = backgroundColor ?? const Color(0xFF595959).lerpWith(Manager.currentDominantColor ?? Manager.accentColor, 0.2),
        progressColor = progressColor ?? Manager.currentDominantColor ?? Manager.accentColor,
        thumbColor = thumbColor ?? Manager.currentDominantColor ?? Manager.accentColor;

  @override
  State<VideoDurationBar> createState() => _VideoDurationBarState();
}

class _VideoDurationBarState extends State<VideoDurationBar> {
  bool _isDragging = false;
  double _dragValue = 0.0;
  double _barWidth = 0.0;
  static const Color _whiteColor = Color.fromARGB(255, 208, 208, 208);

  @override
  Widget build(BuildContext context) {
    if (widget.status == null || widget.status!.totalDuration.inSeconds == 0) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.height / 2),
        ),
      );
    }

    final status = widget.status!;
    final progress = _isDragging ? _dragValue : status.progress;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Time labels
        Text(
          _formatDuration(_isDragging ? Duration(seconds: (_dragValue * status.totalDuration.inSeconds).round()) : status.currentPosition),
          style: const TextStyle(fontSize: 10, color: _whiteColor),
        ),
        const SizedBox(width: 4),
        // Progress bar
        Expanded(
          child: SizedBox(
            height: widget.height + 16, // Extra height for easier touch target
            child: GestureDetector(
              onTapDown: (details) => _handleTap(details),
              onPanStart: (details) => _handlePanStart(details),
              onPanUpdate: (details) => _handlePanUpdate(details),
              onPanEnd: (details) => _handlePanEnd(),
              child: Container(
                alignment: Alignment.center,
                child: LayoutBuilder(builder: (context, constraints) {
                  _barWidth = constraints.maxWidth;
                  return Stack(
                    children: [
                      // Background bar
                      Container(
                        height: widget.height,
                        decoration: BoxDecoration(
                          color: widget.backgroundColor,
                          borderRadius: BorderRadius.circular(widget.height / 2),
                        ),
                      ),
                      // Progress bar
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          height: widget.height,
                          width: progress * _barWidth,
                          decoration: BoxDecoration(
                            color: widget.progressColor,
                            borderRadius: BorderRadius.circular(widget.height / 2),
                          ),
                        ),
                      ),
                      // Thumb (only visible when dragging or hovering)
                      if (_isDragging || progress > 0)
                        Positioned(
                          left: (progress * _barWidth) - 8,
                          top: (widget.height / 2) - 8,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: widget.thumbColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          _formatDuration(status.totalDuration),
          style: const TextStyle(fontSize: 10, color: _whiteColor),
        ),
      ],
    );
  }

  void _handleTap(TapDownDetails details) {
    final barWidth = _barWidth;
    final clickPosition = details.localPosition.dx;
    final newProgress = (clickPosition / barWidth).clamp(0.0, 1.0);

    _seekToProgress(newProgress);

    setState(() {});
  }

  void _handlePanStart(DragStartDetails details) {
    widget.onSeekDown?.call();
    setState(() {
      _isDragging = true;
      final barWidth = _barWidth;
      final clickPosition = details.localPosition.dx;
      _dragValue = (clickPosition / barWidth).clamp(0.0, 1.0);
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    setState(() {
      final barWidth = _barWidth;
      final newPosition = details.localPosition.dx;
      _dragValue = (newPosition / barWidth).clamp(0.0, 1.0);
    });
  }

  void _handlePanEnd() {
    if (!_isDragging) return;

    _seekToProgress(_dragValue);
    widget.onSeekUp?.call();
    setState(() {
      _isDragging = false;
    });
  }

  void _seekToProgress(double progress) {
    if (widget.status == null || widget.onSeek == null) return;

    final targetSeconds = (progress * widget.status!.totalDuration.inSeconds).round();
    widget.onSeek!(targetSeconds);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
  }
}
