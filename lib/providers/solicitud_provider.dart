import 'package:flutter/foundation.dart';

import '../models/solicitud_model.dart';
import '../services/api_service.dart';

class SolicitudProvider extends ChangeNotifier {
  SolicitudProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  bool isLoading = false;
  String? error;
  List<Solicitud> solicitudes = [];
  Solicitud? solicitudDetalle;

  Future<void> fetchSolicitudes() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      solicitudes = await _apiService.getSolicitudes();
    } catch (e) {
      error = 'No se pudieron obtener las solicitudes.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSolicitudDetalle(String id) async {
    isLoading = true;
    error = null;
    solicitudDetalle = null;
    notifyListeners();

    try {
      solicitudDetalle = await _apiService.getSolicitudById(id);
    } catch (e) {
      error = 'No se pudo obtener el detalle de la solicitud.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
