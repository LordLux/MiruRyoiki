part of 'anilist_service.dart';

extension AnilistServiceInitialize on AnilistService {
  /// Initialize the service
  Future<bool> initialize() async {
    final authenticated = await _authService.init();

    if (authenticated) {
      logTrace('2 | Setting up GraphQL client...');
      _setupGraphQLClient();
      return true;
    }

    logTrace('2 | AnilistService initialization failed, not authenticated');
    return false;
  }

  /// Set up the GraphQL client
  void _setupGraphQLClient() {
    final authLink = AuthLink(
      getToken: () => 'Bearer ${_authService.client?.credentials.accessToken}',
    );

    final httpLink = HttpLink('https://graphql.anilist.co');
    _client = GraphQLClient(
      cache: GraphQLCache(),
      link: authLink.concat(httpLink),
    );
    logTrace('2 | GraphQL client setup complete');
  }
}
