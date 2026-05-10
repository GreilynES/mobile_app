import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/solicitud_provider.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Carga inicial de datos reales
    Future.microtask(() => context.read<SolicitudProvider>().fetchSolicitudes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes Cámara Ganaderos'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SolicitudProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.solicitudes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.solicitudes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: provider.fetchSolicitudes,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.solicitudes.isEmpty) {
            return const Center(child: Text('No hay solicitudes registradas.'));
          }

          return RefreshIndicator(
            onRefresh: provider.refreshSolicitudes,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: provider.solicitudes.length,
              itemBuilder: (context, index) {
                final solicitud = provider.solicitudes[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(solicitud.nombre[0].toUpperCase()),
                    ),
                    title: Text(
                      solicitud.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fecha: ${DateFormat('dd/MM/yyyy').format(solicitud.fecha)}'),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(solicitud.estado).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _getStatusColor(solicitud.estado)),
                          ),
                          child: Text(
                            solicitud.estado,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(solicitud.estado),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(solicitudId: solicitud.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String estado) {
    switch (estado.toUpperCase()) {
      case 'PENDIENTE':
        return Colors.orange;
      case 'ACEPTADA':
      case 'APROBADA':
        return Colors.green;
      case 'RECHAZADA':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
