import 'package:flutter/material.dart';

class AppColors {
  // 1. Verdes (Principales)
  /// Verde Oliva (Principal): Utilizado para botones, iconos de navegación y barras de progreso.
  static const Color primary = Color(0xFF708C3E);
  
  /// Verde Bosque (Texto/Títulos): Color principal para textos oscuros y títulos.
  static const Color textDark = Color(0xFF1F3D2B);
  static const Color textDarkVariant = Color(0xFF2E321B);
  
  /// Verde Suave (Hover/Fondo): Usado en estados hover y fondos ligeros.
  static const Color backgroundLight = Color(0xFFF3F5EA);
  
  /// Verde Éxito: Utilizado en alertas y estados positivos.
  static const Color success = Color(0xFF2F5F0B);

  // 2. Tonos Tierra y Neutros
  /// Beige (Bordes y Separadores): Usado para bordes de tarjetas, navbar y menús.
  static const Color border = Color(0xFFDCD6C9);
  static const Color borderVariant = Color(0xFFE6E1D6);
  
  /// Crema (Fondo de Acento): Usado para destacar elementos suavemente.
  static const Color backgroundAccent = Color(0xFFFEF6E0);
  
  /// Gris Silenciado: Para textos secundarios o "muted".
  static const Color textMuted = Color(0xFF4B5563);

  // 3. Acentos y Funcionales
  /// Dorado/Ocre (Acento): Utilizado para destacar iconos de usuario o elementos de importancia.
  static const Color accent = Color(0xFF8B6C2E);
  
  /// Ocre Oscuro (Alertas): Utilizado en iconos de error o advertencia personalizados.
  static const Color warning = Color(0xFF7A6F1A);
  
  /// Rojo (Destructivo): Para acciones de cierre de sesión o eliminación.
  static const Color destructive = Color(0xFFEF4444);
}
