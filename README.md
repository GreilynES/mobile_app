## 📱 Asociados Consulta App — Cámara de Ganaderos de Hojancha

Este es un proyecto **Flutter** (app móvil multiplataforma) desarrollado para la **Cámara de Ganaderos de Hojancha** (Costa Rica). Su propósito principal es **consultar y gestionar solicitudes de asociados**.

### 🎯 ¿Qué hace la app?

1. **Autenticación de usuarios**: Los usuarios inician sesión con credenciales (usuario y contraseña). La app maneja roles (ej. `USER`, `ADMIN`) y almacena el token JWT de forma segura con `flutter_secure_storage`.

2. **Listado de solicitudes**: Una vez autenticado, el usuario ve una lista de solicitudes de asociados, cada una con:
   - **Nombre completo** del solicitante (nombre, apellido1, apellido2)
   - **Fecha** de la solicitud
   - **Estado**: `PENDIENTE`, `APROBADO` o `RECHAZADO`
   - **Cédula, teléfono, correo, dirección y motivo**

3. **Filtrado por estado**: Chips de filtro permiten ver solo las solicitudes pendientes, aprobadas o rechazadas.

4. **Detalle de solicitud**: Al tocar una solicitud se navega a una pantalla de detalle con toda la información del asociado.

5. **Notificaciones push**: Integra **Firebase Cloud Messaging (FCM)** para recibir notificaciones push (ej. cuando una solicitud cambia de estado).

### 🏗️ Arquitectura y tecnologías

| Componente     | Tecnología                                             |
| -------------- | ------------------------------------------------------ |
| Framework      | **Flutter** (Dart)                                     |
| Estado         | **Provider** (`AuthProvider`, `SolicitudProvider`)     |
| HTTP           | Paquete `http` contra un backend REST                  |
| Backend        | API en `https://b4ck3nd.camaraganaderoshojancha.cloud` |
| Auth           | JWT Bearer Token                                       |
| Storage seguro | `flutter_secure_storage`                               |
| Notificaciones | Firebase Cloud Messaging                               |
| Formato fechas | `intl`                                                 |

### 📂 Estructura de carpetas clave

| Carpeta/Archivo                                              | Descripción |
| ------------------------------------------------------------ | ----------- |
| [main.dart] Punto de entrada, Splash screen y AuthWrapper    |
| [models/] Modelos de datos (`Solicitud`, `AuthUser`)         |
| [providers/] Gestión de estado (autenticación y solicitudes) |
| [services/] Llamadas HTTP al API y servicio de FCM           |
| [screens/] Pantallas: Login, Home (listado) y Detalle        |
| [config/] URL base del API y headers                         |
| [theme/] Colores de la app                                   |

### 🔄 Flujo de la app

```
Splash Screen → ¿Token guardado? → Sí → Home (lista de solicitudes)
                                  → No → Login Screen → Home
```

En resumen: es una **app de consulta interna** para que los funcionarios de la Cámara de Ganaderos de Hojancha puedan revisar las solicitudes que hacen los asociados (ganaderos), filtrarlas por estado y ver el detalle de cada una, todo conectado a un backend REST con autenticación JWT.
