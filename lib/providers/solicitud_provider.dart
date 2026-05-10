import 'package:flutter/foundation.dart';
import '../models/solicitud_model.dart';
import '../services/api_service.dart';

class SolicitudProvider extends ChangeNotifier {
  final ApiService _apiService;

  SolicitudProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  bool _isLoading = false;
  String? _errorMessage;
  List<Solicitud> _solicitudes = [];
  String _selectedEstado = 'PENDIENTE';
  Solicitud? _solicitudDetalle;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Solicitud> get solicitudes => _solicitudes;
  Solicitud? get solicitudDetalle => _solicitudDetalle;
  String get selectedEstado => _selectedEstado;

  List<Solicitud> get solicitudesFiltradas {
    return _solicitudes.where((s) => s.estado.toUpperCase() == _selectedEstado.toUpperCase()).toList();
  }

  int getCount(String estado) {
    return _solicitudes.where((s) => s.estado.toUpperCase() == estado.toUpperCase()).length;
  }

  void setEstadoFiltro(String estado) {
    _selectedEstado = estado;
    notifyListeners();
  }

  Future<void> fetchSolicitudes(String? token, {VoidCallback? onUnauthorized}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _solicitudes = await _apiService.getSolicitudes(token);
      if (_solicitudes.isEmpty) {
        _errorMessage = 'No hay solicitudes disponibles en este momento.';
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      if (e is UnauthorizedException && onUnauthorized != null) {
        onUnauthorized();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSolicitudDetalle(String id, String? token, {VoidCallback? onUnauthorized}) async {
    _isLoading = true;
    _errorMessage = null;
    _solicitudDetalle = null;
    notifyListeners();

    try {
      _solicitudDetalle = await _apiService.getSolicitudById(id, token);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      if (e is UnauthorizedException && onUnauthorized != null) {
        onUnauthorized();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshSolicitudes(String? token, {VoidCallback? onUnauthorized}) async {
    await fetchSolicitudes(token, onUnauthorized: onUnauthorized);
  }
}
