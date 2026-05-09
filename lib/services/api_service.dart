import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/solicitud_model.dart';

class ApiService {
  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? 'http://localhost:3000';

  final http.Client _client;
  final String _baseUrl;

  Future<List<Solicitud>> getSolicitudes() async {
    final response = await _client.get(Uri.parse('$_baseUrl/solicitudes'));

    if (response.statusCode != 200) {
      throw Exception('Error al cargar solicitudes (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((item) => Solicitud.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Solicitud> getSolicitudById(String id) async {
    final response = await _client.get(Uri.parse('$_baseUrl/solicitudes/$id'));

    if (response.statusCode != 200) {
      throw Exception('Error al cargar detalle (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return Solicitud.fromJson(decoded);
  }
}
