class AppConstants {
  // FatSecret API Credentials
  static const String fatSecretClientId = 'f28cb6e8959f49aebe907601c64b8272';
  static const String fatSecretClientSecret =
      'f4f9f8818a784721a2e009d69848e9ec';

  // FatSecret API Endpoints
  static const String fatSecretBaseUrl = 'https://oauth.fatsecret.com/connect';
  static const String fatSecretApiUrl =
      'https://platform.fatsecret.com/rest/server.api';

  // OAuth Endpoints
  static const String tokenEndpoint = '$fatSecretBaseUrl/token';

  // API Parameters
  static const String grantType = 'client_credentials';
  static const String scope = 'basic';

  // Cache duration for access token (in seconds)
  static const int tokenCacheDuration = 3600; // 1 hour
}
