import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/solicitud_model.dart';

class ApiService {
  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? 'https://b4ck3nd.camaraganaderoshojancha.cloud';

  final http.Client _client;
  final String _baseUrl;

  Future<List<Solicitud>> getSolicitudes() async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/solicitudes'));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as List<dynamic>;
        return decoded
            .map((item) => Solicitud.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error de conexión al backend: $e. Usando datos de prueba.');
    }
    return _getMockSolicitudes();
  }

  Future<Solicitud> getSolicitudById(String id) async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/solicitudes/$id'));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return Solicitud.fromJson(decoded);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error de conexión al backend: $e. Usando datos de prueba.');
    }
    return _getMockSolicitudes().firstWhere(
      (s) => s.id == id,
      orElse: () => _getMockSolicitudes().first,
    );
  }

  List<Solicitud> _getMockSolicitudes() {
    return [
      Solicitud(
        id: '1',
        nombre: 'Juan Pérez',
        fecha: DateTime.now().subtract(const Duration(days: 2)),
        telefono: '8888-1111',
        correo: 'juan.perez@example.com',
        motivoVoluntariado: 'Deseo ayudar en la limpieza de playas y conservación ambiental.',
      ),
      Solicitud(
        id: '2',
        nombre: 'María García',
        fecha: DateTime.now().subtract(const Duration(days: 5)),
        telefono: '7777-2222',
        correo: 'm.garcia@test.com',
        motivoVoluntariado: 'Me apasiona el trabajo con niños en riesgo social.',
      ),
      Solicitud(
        id: '3',
        nombre: 'Greilyn Esquivel',
        fecha: DateTime.now(),
        telefono: '6666-3333',
        correo: 'greilyn@universidad.ac.cr',
        motivoVoluntariado: 'Quiero aplicar mis conocimientos de tecnología en proyectos sociales.',
      ),
    ];
  }
}
