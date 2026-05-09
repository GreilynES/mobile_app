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
      appBar: AppBar(title: const Text('Detalle de solicitud')),
      body: Consumer<SolicitudProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.solicitudDetalle == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          final s = provider.solicitudDetalle;
          if (s == null) {
            return const Center(child: Text('Sin datos disponibles'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MaterialBanner(
                  content: const Text(
                    'Esta aplicación es de solo consulta. La gestión se realiza en el sistema web',
                  ),
                  actions: const [SizedBox.shrink()],
                ),
                const SizedBox(height: 16),
                _DetailItem(label: 'ID', value: s.id),
                _DetailItem(label: 'Nombre', value: s.nombre),
                _DetailItem(
                  label: 'Fecha',
                  value: DateFormat('yyyy-MM-dd HH:mm').format(s.fecha),
                ),
                _DetailItem(label: 'Teléfono', value: s.telefono),
                _DetailItem(label: 'Correo', value: s.correo),
                _DetailItem(label: 'Motivo', value: s.motivoVoluntariado),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
