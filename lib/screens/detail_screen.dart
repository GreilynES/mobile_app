import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/solicitud_provider.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.solicitudId});

  final String solicitudId;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<SolicitudProvider>().fetchSolicitudDetalle(widget.solicitudId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Solicitud'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SolicitudProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.solicitudDetalle == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchSolicitudDetalle(widget.solicitudId),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final s = provider.solicitudDetalle;
          if (s == null) {
            return const Center(child: Text('Sin datos disponibles'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.amber.shade100,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade900),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Esta aplicación es de solo consulta. La gestión se realiza en el sistema web.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _DetailCard(
                        icon: Icons.person,
                        label: 'Nombre Completo',
                        value: s.nombre,
                      ),
                      _DetailCard(
                        icon: Icons.badge,
                        label: 'Cédula',
                        value: s.cedula,
                      ),
                      _DetailCard(
                        icon: Icons.calendar_today,
                        label: 'Fecha de Solicitud',
                        value: DateFormat('dd/MM/yyyy HH:mm').format(s.fecha),
                      ),
                      _DetailCard(
                        icon: Icons.info_outline,
                        label: 'Estado',
                        value: s.estado,
                      ),
                      _DetailCard(
                        icon: Icons.phone,
                        label: 'Teléfono',
                        value: s.telefono,
                      ),
                      _DetailCard(
                        icon: Icons.email,
                        label: 'Correo Electrónico',
                        value: s.correo,
                      ),
                      _DetailCard(
                        icon: Icons.location_on,
                        label: 'Dirección',
                        value: s.direccion,
                      ),
                      _DetailCard(
                        icon: Icons.description,
                        label: 'Motivo del Voluntariado',
                        value: s.motivo,
                        isLongText: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.icon,
    required this.label,
    required this.value,
    this.isLongText = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLongText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: isLongText ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blue.shade800, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
