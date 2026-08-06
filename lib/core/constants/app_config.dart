/// Central configuration. The single most important flag here is
/// [useMockData]: while the client's data structure is still pending, the app
/// builds and runs against in-memory placeholder data. When the real API is
/// ready, flip this to false (or wire it to a --dart-define) and implement the
/// *RemoteDataSource classes — NO feature/UI code changes.
class AppConfig {
  /// TRUE for now: use placeholder data behind the service layer.
  /// Set via: flutter run --dart-define=USE_MOCK=false
  static const bool useMockData =
      bool.fromEnvironment('USE_MOCK', defaultValue: true);

  /// Base URL for the real eWay API (fill in once provided by the client).
  static const String apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.example.com');

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
