/// Fixed pool of stable AniList media IDs reserved for the real-API test suite.
///
/// Using dedicated IDs per test category ensures that even if two categories run
/// back-to-back their setUp resets don't interfere with each other.
abstract final class TestMedia {
  /// Cowboy Bebop — used by [anilist_integration_test] (notes/dates/score round-trips).
  static const int cowboyBebop = 1;

  /// Fullmetal Alchemist: Brotherhood — used by [anilist_service_mutation_test]
  /// (progress/status/score convenience wrappers).
  static const int fullmetalAlchemist = 5114;

  /// Naruto — used by [anilist_provider_mutations_test] (saveEntry merge behavior).
  static const int naruto = 20;

  /// One Piece — used by [anilist_service_integration_test] (episode titles search).
  static const int onePiece = 21;
}
