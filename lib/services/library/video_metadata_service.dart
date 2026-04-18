import 'package:video_data_utils/video_data_utils.dart';
import '../../models/metadata.dart';
import '../../utils/path.dart';

class VideoMetadataService {
  final VideoDataUtils videoDataUtils;

  VideoMetadataService({VideoDataUtils? videoDataUtils}) : videoDataUtils = videoDataUtils ?? VideoDataUtils();

  Future<Metadata> extractMetadata(PathString filePath) async {
    final results = await Future.wait([
      videoDataUtils.getFileMetadataMap(filePath: filePath.path),
      videoDataUtils.getFileDuration(videoPath: filePath.path),
    ]);

    final metadata = Metadata.fromJson(results[0] as Map<String, dynamic>);
    final duration = Duration(milliseconds: ((results[1] as double?) ?? 0).toInt());

    return metadata.copyWith(duration: duration);
  }
}
