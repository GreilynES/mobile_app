class ApiConfig {
  static const String baseUrl = 'https://b4ck3nd.camaraganaderoshojancha.cloud';

  static Map<String, String> getHeaders(String? token) {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
