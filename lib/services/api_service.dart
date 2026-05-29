import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/solicitud_model.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Solicitud>> getSolicitudes(String? token) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}/solicitudes'),
        headers: ApiConfig.getHeaders(token),
      );

      return _handleResponse(response, (decoded) {
        List<dynamic> list;
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic>) {
          list = (decoded['data'] ?? 
                  decoded['solicitudes'] ?? 
                  decoded['items'] ?? 
                  decoded['result'] ?? 
                  decoded['results'] ?? 
                  []) as List<dynamic>;
        } else {
          list = [];
        }

        return list
            .map((item) => Solicitud.fromJson(item as Map<String, dynamic>))
            .toList();
      });
    } on SocketException {
      throw Exception('No hay conexión a internet. Verifica tu red.');
    } catch (e) {
      rethrow;
    }
  }

  Future<Solicitud> getSolicitudById(String id, String? token) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}/solicitudes/$id'),
        headers: ApiConfig.getHeaders(token),
      );

      return _handleResponse(response, (decoded) {
        Map<String, dynamic> data;
        if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('idSolicitud') || decoded.containsKey('persona')) {
            data = decoded;
          } else if (decoded['data'] is Map<String, dynamic>) {
            data = decoded['data'] as Map<String, dynamic>;
          } else {
            data = decoded;
          }
        } else {
          throw Exception('Formato de respuesta inválido');
        }

        return Solicitud.fromJson(data);
      });
    } on SocketException {
      throw Exception('No hay conexión a internet.');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registerDeviceToken(String fcmToken, String? authToken) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/notifications/register-device'),
        headers: ApiConfig.getHeaders(authToken),
        body: jsonEncode({
          'token': fcmToken,
          'platform': Platform.isIOS ? 'ios' : 'android',
        }),
      );

      _handleResponse(response, (decoded) => decoded);
    } on SocketException {
      throw Exception('No hay conexión a internet.');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unregisterDeviceToken(String fcmToken, String? authToken) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConfig.baseUrl}/notifications/unregister-device'),
        headers: ApiConfig.getHeaders(authToken),
        body: jsonEncode({
          'token': fcmToken,
        }),
      );

      _handleResponse(response, (decoded) => decoded);
    } on SocketException {
      throw Exception('No hay conexión a internet.');
    } catch (e) {
      rethrow;
    }
  }

  dynamic _handleResponse(http.Response response, Function(dynamic) mapper) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return mapper(decoded);
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw UnauthorizedException('Sesión expirada. Inicia sesión nuevamente.');
    } else if (response.statusCode == 404) {
      throw Exception('No se encontró el recurso solicitado.');
    } else {
      throw Exception('Error en el servidor (${response.statusCode}). Intenta más tarde.');
    }
  }
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  @override
  String toString() => message;
}
