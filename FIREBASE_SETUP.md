# Configuración de Firebase para Notificaciones Push

## Pasos necesarios para que funcionen las notificaciones:

### 1. **Descargar `google-services.json` (Android)**

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. Ve a **Configuración del proyecto** (⚙️ arriba a la derecha)
4. En la pestaña **Tus apps**, busca tu app Android
5. Haz clic en el ícono de descargar junto a `google-services.json`
6. **Guarda el archivo en: `android/app/google-services.json`**

### 2. **Descargar `GoogleService-Info.plist` (iOS)**

1. En Firebase Console, en **Tus apps**, busca tu app iOS
2. Haz clic en el ícono de descargar junto a `GoogleService-Info.plist`
3. **Abre Xcode**: `open ios/Runner.xcworkspace`
4. En Xcode: 
   - Haz clic derecho en "Runner" en el explorador
   - Selecciona "Add Files to Runner"
   - Selecciona el archivo `GoogleService-Info.plist`
   - Asegúrate de marcar "Copy items if needed"
   - Haz clic en "Add"

### 3. **Configuración del Backend**

Tu backend **DEBE** tener estos endpoints implementados:

```
POST /notifications/register-device
Registra un token FCM para recibir notificaciones
Body: { "token": "...", "platform": "android|ios" }

DELETE /notifications/unregister-device
Desregistra un token cuando el usuario cierra sesión
Body: { "token": "..." }
```

### 4. **Enviar Notificaciones desde el Backend**

El backend debe usar Firebase Admin SDK para enviar notificaciones:

```javascript
// Node.js/Express ejemplo
const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

async function sendNotification(deviceTokens, title, body, data = {}) {
  const message = {
    notification: {
      title: title,
      body: body,
    },
    data: data,
    tokens: Array.isArray(deviceTokens) ? deviceTokens : [deviceTokens]
  };

  try {
    const response = await admin.messaging().sendMulticast(message);
    console.log('Notificaciones enviadas:', response.successCount);
    return response;
  } catch (error) {
    console.error('Error enviando notificaciones:', error);
  }
}

// Cuando haya una nueva solicitud:
await sendNotification(
  storedDeviceTokens,
  'Nueva Solicitud',
  'Se ha recibido una nueva solicitud de negociación',
  { 
    solicitudId: '12345',
    tipo: 'nueva_solicitud'
  }
);
```

### 5. **Permisos en Android**

Ya están configurados en `AndroidManifest.xml` (debe incluir):
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="com.google.android.c2dm.permission.RECEIVE" />
```

### 6. **Configuración en iOS**

Ya está configurada en el Podfile y AppDelegate.swift

---

## Verificación

Después de completar estos pasos:

1. Ejecuta: `flutter pub get`
2. Ejecuta: `flutter run`
3. Busca en la consola el mensaje: `FCM Token: xxxxxxx...`
4. Copia ese token
5. Prueba enviando una notificación desde Firebase Console:
   - Ve a **Mensajería en la nube** > **Enviar tu primer mensaje**
   - En "Token de registro", pega el token
   - Haz clic en "Enviar"
   - La notificación debería aparecer en tu app

## Troubleshooting

### ❌ "Firebase no pudo inicializarse"
- Verifica que `google-services.json` esté en `android/app/`
- Verifica que `GoogleService-Info.plist` esté en `ios/Runner/`

### ❌ No llegan notificaciones
- Verifica que el token FCM se esté registrando en tu backend (revisa los logs)
- Verifica que tu backend esté usando los tokens correctos para enviar

### ❌ "Se requieren permisos"
- En Android 13+, se solicita permiso al abrir la app
- El usuario debe aceptar el permiso en los primeros segundos

---

## Cómo funciona ahora:

1. ✅ El usuario inicia sesión
2. ✅ La app obtiene el token FCM
3. ✅ La app registra el token en tu backend
4. ✅ Cuando llega una notificación:
   - Si la app está en foreground: actualiza la lista automáticamente
   - Si la app está en background: muestra la notificación del sistema
   - Si se toca la notificación: abre el detalle de esa solicitud
5. ✅ Al cerrar sesión, el token se desregistra del backend
