import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/solicitud_provider.dart';
import 'screens/home_screen.dart';
import 'services/fcm_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FcmService.initialize();
  runApp(const VoluntariadoApp());
}

class VoluntariadoApp extends StatelessWidget {
  const VoluntariadoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SolicitudProvider(),
      child: MaterialApp(
        title: 'Voluntariado - Consulta',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
