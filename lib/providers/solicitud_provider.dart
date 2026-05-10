import 'package:flutter/foundation.dart';
import '../models/solicitud_model.dart';
import '../services/api_service.dart';

class SolicitudProvider extends ChangeNotifier {
  final ApiService _apiService;

  SolicitudProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  bool _isLoading = false;
  String? _errorMessage;
  List<Solicitud> _solicitudes = [];
  Solicitud? _solicitudDetalle;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Solicitud> get solicitudes => _solicitudes;
  Solicitud? get solicitudDetalle => _solicitudDetalle;

  Future<void> fetchSolicitudes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _solicitudes = await _apiService.getSolicitudes();
      if (_solicitudes.isEmpty) {
        _errorMessage = 'No hay solicitudes disponibles en este momento.';
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSolicitudDetalle(String id) async {
    _isLoading = true;
    _errorMessage = null;
    _solicitudDetalle = null;
    notifyListeners();

    try {
      _solicitudDetalle = await _apiService.getSolicitudById(id);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshSolicitudes() async {
    await fetchSolicitudes();
  }
}
