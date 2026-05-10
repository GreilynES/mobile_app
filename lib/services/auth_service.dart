import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/auth_user_model.dart';

class AuthService {
  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (!data.containsKey('token') || !data.containsKey('user')) {
          throw Exception('Respuesta inesperada del servidor: Falta token o datos de usuario.');
        }

        final user = AuthUser.fromJson(data['user']);
        final token = data['token'];

        return {
          'user': user,
          'token': token,
        };
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        throw Exception('Credenciales incorrectas. Verifica tu correo y contraseña.');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permiso para acceder a esta aplicación.');
      } else {
        throw Exception('Error del servidor (${response.statusCode}). Intenta de nuevo más tarde.');
      }
    } on SocketException {
      throw Exception('Error de conexión. Verifica tu internet.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Ocurrió un error inesperado: $e');
    }
  }
}
