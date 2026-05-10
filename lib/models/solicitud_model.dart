class Solicitud {
  final String id;
  final String nombre;
  final DateTime fecha;
  final String telefono;
  final String correo;
  final String motivo;
  final String estado;
  final String cedula;
  final String direccion;

  const Solicitud({
    required this.id,
    required this.nombre,
    required this.fecha,
    required this.telefono,
    required this.correo,
    required this.motivo,
    required this.estado,
    required this.cedula,
    required this.direccion,
  });

  factory Solicitud.fromJson(Map<String, dynamic> json) {
    // Manejo de la anidación de persona
    final persona = json['persona'] as Map<String, dynamic>?;

    // Construcción del nombre completo
    String nombreCompleto = 'Sin nombre';
    if (persona != null) {
      final n = persona['nombre'] as String? ?? '';
      final a1 = persona['apellido1'] as String? ?? '';
      final a2 = persona['apellido2'] as String? ?? '';
      nombreCompleto = '$n $a1 $a2'.trim();
      if (nombreCompleto.isEmpty) nombreCompleto = 'Sin nombre';
    }

    return Solicitud(
      id: json['idSolicitud']?.toString() ?? json['id']?.toString() ?? '',
      nombre: nombreCompleto,
      fecha: DateTime.tryParse(json['fechaSolicitud']?.toString() ?? json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      telefono: persona?['telefono'] as String? ?? 'N/A',
      correo: persona?['email'] as String? ?? 'N/A',
      motivo: json['motivo'] as String? ?? 'Sin motivo registrado',
      estado: json['estado'] as String? ?? 'PENDIENTE',
      cedula: persona?['cedula'] as String? ?? 'N/A',
      direccion: persona?['direccion'] as String? ?? 'No especificada',
    );
  }
}
