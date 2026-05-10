import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Base para manejo en foreground.
        // Se puede integrar con local notifications según necesidades del proyecto.
        // ignore: avoid_print
        print('Notificación recibida: ${message.notification?.title}');
      });
    } catch (e) {
      // ignore: avoid_print
      print('Firebase no pudo inicializarse. Asegúrate de tener configurado google-services.json o FirebaseOptions: $e');
    }
  }
}
