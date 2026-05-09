class Solicitud {
  final String id;
  final String nombre;
  final DateTime fecha;
  final String telefono;
  final String correo;
  final String motivoVoluntariado;

  const Solicitud({
    required this.id,
    required this.nombre,
    required this.fecha,
    required this.telefono,
    required this.correo,
    required this.motivoVoluntariado,
  });

  factory Solicitud.fromJson(Map<String, dynamic> json) {
    return Solicitud(
      id: json['id'].toString(),
      nombre: json['nombre'] as String? ?? '',
      fecha: DateTime.tryParse(json['fecha'] as String? ?? '') ?? DateTime.now(),
      telefono: json['telefono'] as String? ?? '',
      correo: json['correo'] as String? ?? '',
      motivoVoluntariado: json['motivoVoluntariado'] as String? ??
          json['motivo'] as String? ??
          '',
    );
  }
}
