import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/fcm_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthUser? _user;
  String? _token;
  bool _isLoading = false;
  bool _isInitializing = true; // Nuevo: Para saber si estamos cargando la sesión inicial
  String? _errorMessage;

  AuthUser? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing; // Getter para el Splash
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null;

  AuthProvider() {
    checkSession();
  }

  Future<void> login(String email, String password, {bool rememberMe = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);
      _user = result['user'];
      _token = result['token'];

      if (rememberMe) {
        // Guardar en storage seguro solo si el usuario lo pidió
        await _storage.write(key: 'jwt_token', value: _token);
        await _storage.write(key: 'user_data', value: jsonEncode(_user!.toJson()));
      }

      // Register device token for notifications
      final fcmToken = FcmService.deviceToken;
      if (fcmToken != null) {
        try {
          await _apiService.registerDeviceToken(fcmToken, _token);
        } catch (e) {
          // ignore: avoid_print
          print('Error registering FCM token: $e');
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    final fcmToken = FcmService.deviceToken;
    final currentToken = _token;
    if (fcmToken != null && currentToken != null) {
      try {
        await _apiService.unregisterDeviceToken(fcmToken, currentToken);
      } catch (e) {
        // ignore: avoid_print
        print('Error unregistering FCM token: $e');
      }
    }

    _user = null;
    _token = null;
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_data');
    notifyListeners();
  }

  Future<void> checkSession() async {
    _isInitializing = true;
    notifyListeners();

    // Timeout de 3 segundos para no quedarse esperando
    try {
      await Future.wait([
        _checkSessionInternal(),
        Future.delayed(const Duration(milliseconds: 500)), // Splash mínimo
      ]);
    } catch (e) {
      // ignore: avoid_print
      print('Error en checkSession: $e');
    }

    _isInitializing = false;
    notifyListeners();
  }

  Future<void> _checkSessionInternal() async {
    final savedToken = await _storage.read(key: 'jwt_token');
    final savedUserData = await _storage.read(key: 'user_data');

    if (savedToken != null && savedUserData != null) {
      try {
        _token = savedToken;
        _user = AuthUser.fromJson(jsonDecode(savedUserData));

        // Register device token on session restore if present
        final fcmToken = FcmService.deviceToken;
        if (fcmToken != null) {
          _apiService.registerDeviceToken(fcmToken, _token).catchError((e) {
            // ignore: avoid_print
            print('Error registering FCM token on session restore: $e');
          });
        }
      } catch (e) {
        await logout();
      }
    }
  }

  Future<String?> getToken() async {
    if (_token != null) return _token;
    return await _storage.read(key: 'jwt_token');
  }
}

