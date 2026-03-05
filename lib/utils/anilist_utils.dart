import 'package:url_launcher/url_launcher.dart';

import '../manager.dart';
import '../models/anilist/anime_card.dart';

/// Base URL for AniList website
const String kAnilistBaseUrl = 'https://anilist.co';

/// Navigate to a series detail page within the app.
void navigateToSeries(AnimeCard anime) {
  Manager.navigation.pushPage(
    '/searched_series:${anime.id}',
    anime.title.userPreferred ?? 'Anime Details',
    data: anime,
  );
}

/// Open an AniList page in the browser.
///
/// [path] is appended to the base URL, e.g. `anime/12345`, `manga/67890`,
/// `character/111`, `staff/222`, `user/Username`.
void openAnilistUrl(String path) {
  launchUrl(Uri.parse('$kAnilistBaseUrl/$path'));
}

/// Open an AniList anime page in the browser.
void openAnilistAnime(int id) => openAnilistUrl('anime/$id');

/// Open an AniList manga page in the browser.
void openAnilistManga(int id) => openAnilistUrl('manga/$id');

/// Open an AniList character page in the browser.
void openAnilistCharacter(int id) => openAnilistUrl('character/$id');

/// Open an AniList staff page in the browser.
void openAnilistStaff(int id) => openAnilistUrl('staff/$id');

/// Open an AniList user page in the browser.
void openAnilistUser(String name) => openAnilistUrl('user/$name');
