import 'dart:async';
import 'dart:convert';
import 'package:graphql/client.dart';
import '../../../../models/anilist/anime.dart';
import '../../../../models/anilist/user_list.dart';
import '../../../main.dart';
import '../../../manager.dart';
import '../../../models/anilist/user_data.dart';
import '../../../utils/logging.dart';
import '../auth.dart';

part 'initialization.dart';
part 'auth.dart';
part 'search.dart';
part 'user.dart';
part 'anime_details.dart';
part 'mutations.dart';

class AnilistService {
  // Singleton
  static final AnilistService _instance = AnilistService._internal();
  factory AnilistService() => _instance;
  AnilistService._internal() : _authService = AnilistAuthService();

  final AnilistAuthService _authService;
  GraphQLClient? _client;

  bool get isLoggedIn => _authService.isAuthenticated;

  /// Format status name for display
  String _formatStatusName(String status) {
    switch (status) {
      case 'CURRENT':
        return 'Watching';
      case 'PLANNING':
        return 'Plan to Watch';
      case 'COMPLETED':
        return 'Completed';
      case 'DROPPED':
        return 'Dropped';
      case 'PAUSED':
        return 'On Hold';
      case 'REPEATING':
        return 'Rewatching';
      default:
        return status;
    }
  }
}
