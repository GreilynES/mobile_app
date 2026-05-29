import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

typedef OnNotificationCallback = Future<void> Function(RemoteMessage message);

class FcmService {
  static String? _deviceToken;
  static String? get deviceToken => _deviceToken;
  
  static OnNotificationCallback? _onNotificationCallback;
  static OnNotificationCallback? _onNotificationTappedCallback;

  /// Registra callbacks para cuando llegan notificaciones
  static void setNotificationCallbacks({
    OnNotificationCallback? onNotification,
    OnNotificationCallback? onNotificationTapped,
  }) {
    _onNotificationCallback = onNotification;
    _onNotificationTappedCallback = onNotificationTapped;
  }

  /// Background message handler - debe ser una función top-level
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // ignore: avoid_print
    print('Notificación en background: ${message.notification?.title}');
  }

  static Future<void> initialize() async {
    try {
      // Timeout de 5 segundos para Firebase initialization
      await Firebase.initializeApp().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          // ignore: avoid_print
          print('⚠️ Firebase inicialización tardó demasiado');
          throw TimeoutException('Firebase initialization timeout');
        },
      );
      // ignore: avoid_print
      print('✅ Firebase inicializado correctamente');

      final messaging = FirebaseMessaging.instance;
      
      // Solicitar permisos con timeout
      final settings = await messaging
          .requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          )
          .timeout(
            const Duration(seconds: 3),
            onTimeout: () {
              // ignore: avoid_print
              print('⚠️ Timeout solicitando permisos');
              throw TimeoutException('Permission request timeout');
            },
          );

      // ignore: avoid_print
      print('✅ Permisos: ${settings.authorizationStatus}');

      // Obtener token con timeout
      _deviceToken = await messaging
          .getToken()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              // ignore: avoid_print
              print('⚠️ Timeout obteniendo FCM token');
              return null;
            },
          );

      if (_deviceToken != null) {
        // ignore: avoid_print
        print('✅ FCM Token: $_deviceToken');
      } else {
        // ignore: avoid_print
        print('⚠️ No se pudo obtener el FCM Token');
      }

      // Escuchar cambios de token
      messaging.onTokenRefresh.listen((newToken) {
        _deviceToken = newToken;
        // ignore: avoid_print
        print('🔄 Token actualizado: $newToken');
      });

      // Handler para notificaciones cuando la app está en foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // ignore: avoid_print
        print('📲 Notificación en foreground: ${message.notification?.title}');
        _onNotificationCallback?.call(message);
      });

      // Handler cuando se toca la notificación desde background/terminated
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        // ignore: avoid_print
        print('👆 Notificación tocada: ${message.notification?.title}');
        _onNotificationTappedCallback?.call(message);
      });

      // Handler para notificaciones cuando la app está cerrada
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Validar si hay una notificación que abrió la app al inicio
      try {
        final initialMessage = await messaging
            .getInitialMessage()
            .timeout(const Duration(seconds: 2));
        if (initialMessage != null) {
          // ignore: avoid_print
          print('📲 App abierta desde notificación');
          _onNotificationTappedCallback?.call(initialMessage);
        }
      } catch (e) {
        // ignore: avoid_print
        print('⚠️ Error verificando mensaje inicial: $e');
      }
    } on TimeoutException catch (e) {
      // ignore: avoid_print
      print('⏱️ Timeout en Firebase: $e');
      // ignore: avoid_print
      print('ℹ️  La app continuará sin notificaciones push');
    } catch (e) {
      // ignore: avoid_print
      print('❌ Error en Firebase: $e');
      // ignore: avoid_print
      print('ℹ️  Asegúrate de tener google-services.json en android/app/');
      // ignore: avoid_print
      print('ℹ️  La app continuará sin notificaciones push');
    }
  }
}
