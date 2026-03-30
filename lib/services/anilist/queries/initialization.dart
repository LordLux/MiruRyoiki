part of 'anilist_service.dart';

extension AnilistServiceInitialize on AnilistService {
  /// Initialize the service
  Future<bool> initialize() async {
    final authenticated = await _authService.init();

    if (authenticated) {
      logTrace('2 | Setting up GraphQL client...');
      _setupGraphQLClient();
      _registerAvailabilityProbe();
      return true;
    }

    logTrace('2 | AnilistService initialization failed, not authenticated');
    return false;
  }

  /// Register a lightweight probe that the availability service can call
  /// to check if AniList is back online without clearing the UI flag.
  void _registerAvailabilityProbe() {
    AnilistAvailabilityService().probeCallback = () async {
      if (_client == null) return false;
      try {
        final result = await _client!.query(QueryOptions(
          document: gql('{ Viewer { id } }'),
          fetchPolicy: FetchPolicy.networkOnly,
        ));
        return !result.hasException && result.data != null;
      } catch (_) {
        return false;
      }
    };
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
