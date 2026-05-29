import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/solicitud_provider.dart';
import '../services/fcm_service.dart';
import '../theme/app_colors.dart';
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
    _loadData();
    _setupFcmCallbacks();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    // El auto-refresh se detiene automáticamente cuando cambias de pantalla
    super.dispose();
  }

  void _startAutoRefresh() {
    Future.microtask(() {
      final auth = context.read<AuthProvider>();
      final solicitudProvider = context.read<SolicitudProvider>();
      
      // Activa refresco automático cada 30 segundos
      solicitudProvider.startAutoRefresh(
        auth.token,
        onUnauthorized: () => auth.logout(),
      );
    });
  }

  void _loadData() {
    Future.microtask(() {
      final auth = context.read<AuthProvider>();
      context.read<SolicitudProvider>().fetchSolicitudes(
        auth.token,
        onUnauthorized: () => auth.logout(),
      );
    });
  }

  void _setupFcmCallbacks() {
    // Callback cuando llega una notificación en foreground
    FcmService.setNotificationCallbacks(
      onNotification: (RemoteMessage message) async {
        // ignore: avoid_print
        print('📲 Notificación recibida en foreground: ${message.notification?.title}');
        
        // Refrescar la lista de solicitudes automáticamente
        if (mounted) {
          final auth = context.read<AuthProvider>();
          await context.read<SolicitudProvider>().refreshSolicitudes(
            auth.token,
            onUnauthorized: () => auth.logout(),
          );
          
          // Mostrar snackbar informativo
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message.notification?.body ?? 'Nueva solicitud recibida'),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      },
      onNotificationTapped: (RemoteMessage message) async {
        // ignore: avoid_print
        print('👆 Notificación tocada: ${message.notification?.title}');
        
        // Si la notificación contiene el ID de la solicitud, navegar a ella
        final solicitudId = message.data['solicitudId'] ?? message.data['id'];
        if (solicitudId != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailScreen(solicitudId: solicitudId),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Solicitudes Cámara'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () => authProvider.logout(),
          ),
        ],
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.backgroundLight,
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
                    const Icon(Icons.error_outline, size: 60, color: AppColors.destructive),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.solicitudes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No hay solicitudes registradas.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Actualizar'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.refreshSolicitudes(
                authProvider.token,
                onUnauthorized: () => authProvider.logout(),
              );
            },
            child: Column(
              children: [
                if (user != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: AppColors.backgroundLight,
                    child: Text(
                      'Bienvenido, ${user.username} (${user.roleName})',
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                // Filtros por estado
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      _buildFilterChip(context, provider, 'PENDIENTE', 'Pendientes'),
                      const SizedBox(width: 8),
                      _buildFilterChip(context, provider, 'APROBADO', 'Aprobadas'),
                      const SizedBox(width: 8),
                      _buildFilterChip(context, provider, 'RECHAZADO', 'Rechazadas'),
                    ],
                  ),
                ),

                Expanded(
                  child: provider.solicitudesFiltradas.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.filter_list_off, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              const Text(
                                'No hay solicitudes en este estado.',
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          itemCount: provider.solicitudesFiltradas.length,
                          itemBuilder: (context, index) {
                            final solicitud = provider.solicitudesFiltradas[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.backgroundAccent,
                                  child: Text(
                                    solicitud.nombre.isNotEmpty ? solicitud.nombre[0].toUpperCase() : '?',
                                    style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                                  ),
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, SolicitudProvider provider, String estado, String label) {
    final isSelected = provider.selectedEstado == estado;
    final count = provider.getCount(estado);

    return ChoiceChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          provider.setEstadoFiltro(estado);
        }
      },
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.primary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.backgroundAccent),
      ),
    );
  }

  Color _getStatusColor(String estado) {
    switch (estado.toUpperCase()) {
      case 'PENDIENTE':
        return AppColors.warning;
      case 'ACEPTADA':
      case 'APROBADA':
        return AppColors.success;
      case 'RECHAZADA':
        return AppColors.destructive;
      default:
        return AppColors.textMuted;
    }
  }
}
