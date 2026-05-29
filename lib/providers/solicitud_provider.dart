import 'dart:async';
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
  
  // Polling automático
  Timer? _autoRefreshTimer;
  bool _isAutoRefreshEnabled = false;
  Duration _autoRefreshInterval = const Duration(seconds: 30);

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Solicitud> get solicitudes => _solicitudes;
  Solicitud? get solicitudDetalle => _solicitudDetalle;
  String get selectedEstado => _selectedEstado;
  bool get isAutoRefreshEnabled => _isAutoRefreshEnabled;

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

  /// Activa el refresco automático cada X segundos
  void startAutoRefresh(String? token, {VoidCallback? onUnauthorized}) {
    if (_isAutoRefreshEnabled) return;
    
    _isAutoRefreshEnabled = true;
    // ignore: avoid_print
    print('✅ Auto-refresh activado (cada ${_autoRefreshInterval.inSeconds}s)');
    
    _autoRefreshTimer = Timer.periodic(_autoRefreshInterval, (_) async {
      // ignore: avoid_print
      print('🔄 Auto-refresh: sincronizando solicitudes...');
      await fetchSolicitudes(token, onUnauthorized: onUnauthorized);
    });
  }

  /// Detiene el refresco automático
  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _isAutoRefreshEnabled = false;
    // ignore: avoid_print
    print('❌ Auto-refresh desactivado');
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

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
