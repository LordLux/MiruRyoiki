// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:miruryoiki/main.dart';
import 'package:miruryoiki/models/anilist/anime.dart';
import 'package:miruryoiki/models/anilist/mapping.dart';
import 'package:miruryoiki/models/series.dart';
import 'package:miruryoiki/services/isolates/isolate_manager.dart';
import 'package:miruryoiki/utils/color.dart';
import 'package:miruryoiki/utils/path.dart';
import 'package:miruryoiki/utils/time.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final Directory tempDir;

  MockPathProviderPlatform(this.tempDir);

  @override
  Future<String?> getApplicationSupportPath() async {
    return tempDir.path;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('miru_test_');
    PathProviderPlatform.instance = MockPathProviderPlatform(tempDir);
    
    await initializeMiruRyoikiSaveDirectory();
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('Calculate dominant color', () async {
    // Initialize the app
    rootIsolateToken = RootIsolateToken.instance;

    // Setup cache directory
    final saveDir = miruRyoikiSaveDirectory;
    final cacheDir = Directory('${saveDir.path}/image_cache');
    if (!cacheDir.existsSync()) {
      cacheDir.createSync(recursive: true);
    }

    const bannerUrl = 'https://example.com/banner.jpg';
    const posterUrl = 'https://example.com/poster.png';

    // Create dummy images
    // Blue Banner (Background)
    _createCachedImage(cacheDir, bannerUrl, img.ColorRgb8(0, 0, 255)); 
    // Red Poster (Vibrant)
    _createCachedImage(cacheDir, posterUrl, img.ColorRgb8(255, 0, 0)); 

    final testSeries = Series(
      name: 'Test Series',
      path: PathString(r'M:\Videos\Series\Test Series'),
      seasons: [],
      anilistBanner: bannerUrl,
      anilistPoster: posterUrl,
      anilistMappings: [
        AnilistMapping(
          anilistId: 12345,
          localPath: PathString(r'M:\Videos\Series\Test Series'),
          anilistData: AnilistAnime(
            id: 12345, 
            title: AnilistTitle(romaji: 'Test', english: 'Test', native: 'Test'),
            bannerImage: bannerUrl,
            posterImage: posterUrl,
          ),
          title: 'Test Series',
          lastSynced: now,
        ),
      ],
      primaryAnilistId: 12345,
    );

    // Run the isolate function directly in the main isolate to avoid
    // issues with mocking PathProvider in spawned isolates.
    final receivePort = ReceivePort();
    final params = CalculateDominantColorsParams(
      serializedMappings: testSeries.anilistMappings.map((m) => m.toJson()).toList(),
      forceRecalculate: true,
      replyPort: receivePort.sendPort,
    );

    await calculateDominantColorsIsolate(params);

    Map<int, Map<String, dynamic>>? results;
    await for (final element in receivePort) {
      if (element is Map<int, Map<String, dynamic>>) {
        results = element;
        break;
      }
    }
    receivePort.close();

    expect(results, isNotNull);
    expect(results, isNotEmpty);
    final result = results![12345];
    expect(result, isNotNull);
    expect(result!['changed'], isTrue);
    expect(result['posterColor'], isNotNull);
    expect(result['bannerColor'], isNotNull);
    
    // Verify colors (approximate)
    // Poster (Red)
    final posterColor = Color(result['posterColor']);
    // Red should be dominant in vibrant mode
    expect(posterColor.red, greaterThan(200));
    
    // Banner (Blue)
    final bannerColor = Color(result['bannerColor']);
    // Blue should be dominant in background mode
    // Note: Background extraction might darken/lighten, but should be blue-ish
    expect(bannerColor.blue, greaterThan(100));
  });
}

void _createCachedImage(Directory cacheDir, String url, img.Color color) {
  final bytes = utf8.encode(url);
  final digest = md5.convert(bytes);
  final extension = url.split('.').last.split('?').first;
  final filename = '${digest.toString()}.$extension';
  
  final image = img.Image(width: 100, height: 100);
  img.fill(image, color: color);
  
  final file = File('${cacheDir.path}/$filename');
  file.writeAsBytesSync(img.encodePng(image));
}
