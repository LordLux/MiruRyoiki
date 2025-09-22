import 'package:fluent_ui/fluent_ui.dart';
import '../manager.dart';
import '../models/players/mediastatus.dart';
import 'package:squiggly_slider/slider.dart';

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
  })  : backgroundColor = backgroundColor ?? const Color(0xFF595959).lerpWith(Manager.currentDominantColor ?? Manager.accentColor, 0.5).withOpacity(0.5),
        progressColor = progressColor ?? Manager.currentDominantColor ?? Manager.accentColor,
        thumbColor = thumbColor ?? (Manager.currentDominantColor ?? Manager.accentColor).toAccentColor().light;

  @override
  State<VideoDurationBar> createState() => _VideoDurationBarState();
}

class _VideoDurationBarState extends State<VideoDurationBar> {
  bool _isDragging = false;
  double _dragValue = 0.0;
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
        // Progress bar
        Expanded(
          child: SizedBox(
            height: widget.height + 16, // Extra height for easier touch target
            child: SquigglySlider(
              value: progress,
              onChanged: (value) {
                setState(() => _dragValue = value);
                _seekToProgress(value);
              },
              thumbsSize: Size(4, 20),
              useLineThumb: true,
              onChangeStart: (value) {
                widget.onSeekDown?.call();
                setState(() {
                  _isDragging = true;
                  _dragValue = value;
                });
              },
              trackThickness: 1,
              onChangeEnd: (value) {
                _seekToProgress(value);
                widget.onSeekUp?.call();
                setState(() => _isDragging = false);
              },
              squiggleAmplitude: 5.0,
              squiggleWavelength: 4.0,
              squiggleSpeed: 0.1,
              activeColor: widget.progressColor,
              inactiveColor: widget.backgroundColor,
              thumbColor: widget.thumbColor,
              min: 0.0,
              max: 1.0,
            ),
          ),
        ),
        Text(
          _formatDuration(status.totalDuration),
          style: const TextStyle(fontSize: 10, color: _whiteColor),
        ),
      ],
    );
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