# Guía de Debugging - Notificaciones Push

## 🔴 Problema Actual

Las notificaciones **NO funcionan en Web (Chrome)**. FCM solo soporta:
- ✅ Android (APK/device)
- ✅ iOS (iPhone/simulator)
- ❌ Web/Chrome (no soportado por Firebase Messaging)

## 📱 Cómo Ejecutar Correctamente

### En Android (Emulador)

```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar en el emulador
flutter run
```

### En Android (Dispositivo Real)

```bash
# Conecta tu teléfono por USB
# Asegúrate de tener "Depuración USB" activada
flutter run
```

### En iOS (Simulador)

```bash
# Listar simuladores
flutter emulators

# Ejecutar en simulator
flutter run -d "iPhone 15"
```

---

## 🔍 Logs que Debes Ver

Cuando ejecutes `flutter run`, busca estos mensajes en la consola:

### ✅ Si todo funciona:
```
✅ Firebase inicializado correctamente
✅ Permisos de notificación solicitados: AuthorizationStatus.authorized
✅ FCM Token obtenido: eEW8fqYuT9c:APA91bF...
✅ Auto-refresh activado (cada 30s)
```

### ❌ Si hay error:
```
❌ Error en Firebase: ...
ℹ️  Asegúrate de tener google-services.json en android/app/
ℹ️  Asegúrate de tener GoogleService-Info.plist en ios/Runner/
```

---

## 📊 Sistema de Auto-Refresh (Fallback)

Mientras configuras Firebase, la app refresca **automáticamente cada 30 segundos**:

```
✅ Auto-refresh activado (cada 30s)
🔄 Auto-refresh: sincronizando solicitudes...
```

Esto significa que cada 30 segundos verás actualizadas las nuevas solicitudes sin esperar a las notificaciones push.

---

## 🚀 Pasos para que Funcionen las Notificaciones

### 1. Descargar configuración de Firebase

Ve a [Firebase Console](https://console.firebase.google.com/):

#### Para Android:
- En **Configuración del proyecto** → **Tus apps** → Tu app Android
- Haz clic en descargar `google-services.json`
- **Guarda en:** `android/app/google-services.json`

#### Para iOS:
- En **Tus apps** → Tu app iOS
- Haz clic en descargar `GoogleService-Info.plist`
- Abre Xcode: `open ios/Runner.xcworkspace`
- Arrastra el archivo a la carpeta `Runner`
- Marca "Copy items if needed"

### 2. Ejecutar en dispositivo real (Android) o simulator (iOS)

```bash
flutter run  # Automáticamente elige el device conectado
```

### 3. Busca el FCM Token en los logs

Copia algo como: `eEW8fqYuT9c:APA91bF...`

### 4. Registra el token en tu backend

Tu backend debería recibir:
```json
POST /notifications/register-device
{
  "token": "eEW8fqYuT9c:APA91bF...",
  "platform": "android"
}
```

### 5. Prueba desde Firebase Console

- Ve a **Mensajería en la nube**
- Haz clic en **Enviar tu primer mensaje**
- Título: "Test"
- Cuerpo: "¿Funciona?"
- **Token de registro:** Pega el token que copiaste
- Haz clic en **Enviar**

Deberías recibir la notificación en tu dispositivo.

---

## 🔧 Checklist de Configuración

- [ ] `google-services.json` existe en `android/app/`
- [ ] `GoogleService-Info.plist` existe en `ios/Runner/`
- [ ] Backend tiene endpoint `/notifications/register-device`
- [ ] Backend tiene endpoint `/notifications/unregister-device`
- [ ] Backend usa Firebase Admin SDK para enviar notificaciones
- [ ] Ejecutando en Android/iOS, NO en web
- [ ] El FCM token aparece en los logs de la app
- [ ] El backend recibió y almacenó el token

---

## 💡 Solución Temporal

Mientras configuras Firebase, la app:
- ✅ Refresca automáticamente cada 30 segundos
- ✅ Puedes tirar para refrescar manualmente (pull-to-refresh)
- ✅ Las nuevas solicitudes aparecerán en max 30 segundos

---

## 📧 Backend esperado

```javascript
// Cuando hay una nueva solicitud:
async function notifySolicitudCreated(solicitud, userDeviceTokens) {
  const message = {
    notification: {
      title: 'Nueva Solicitud',
      body: `Nueva solicitud de ${solicitud.nombre}`,
    },
    data: {
      solicitudId: solicitud.id,
      tipo: 'nueva_solicitud'
    },
    tokens: userDeviceTokens
  };

  try {
    await admin.messaging().sendMulticast(message);
    console.log('Notificaciones enviadas');
  } catch (error) {
    console.error('Error:', error);
  }
}
```

---

## 🆘 Si sigue sin funcionar

1. Revisa que Firebase console y tu app estén en **el mismo proyecto**
2. Verifica que `google-services.json` tenga el `project_id` correcto
3. Ejecuta `flutter clean && flutter pub get && flutter run`
4. Mira los logs de tu backend para ver si recibe el token FCM
