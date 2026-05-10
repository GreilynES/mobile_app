class ApiConfig {
  static const String baseUrl = 'https://b4ck3nd.camaraganaderoshojancha.cloud';
  
  // TODO: Pegar aquí el token obtenido desde Postman o el backend
  // Esta es una solución temporal para el avance.
  // En producción, esto debe venir de un proceso de Login y guardarse en Flutter Secure Storage.
  static const String accessToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6Miwicm9sZSI6IkFETUlOIiwianRpIjoiODdkMGYwNDEtYzdjZC00YzI5LThhYzMtZjUyYTQxYTc2ZDFjIiwiaWF0IjoxNzc4NDMyNTgxLCJleHAiOjE3Nzg1MTg5ODF9.o49Wi_lNzaucaORL8ABBY0psCzzk2mJWR5diB4Kz9XY';

  static Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }
}
