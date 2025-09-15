class MediaStatus {
  final String filePath;
  final Duration currentPosition;
  final Duration totalDuration;
  final bool isPlaying;
  final int volumeLevel;
  final bool isMuted;

  double get progress => totalDuration.inMilliseconds == 0 //
      ? 0.0
      : currentPosition.inMilliseconds / totalDuration.inMilliseconds;

  MediaStatus({
    required this.filePath,
    required this.currentPosition,
    required this.totalDuration,
    required this.isPlaying,
    required this.volumeLevel,
    required this.isMuted,
  });
}
