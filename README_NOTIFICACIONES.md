# ⚠️ Problema: Notificaciones NO funcionan en Web

## 🔴 La Razón

**Firebase Cloud Messaging (FCM) NO soporta notificaciones push en web/Chrome.**

Solo funciona en:
- ✅ **Android** (físico o emulador)
- ✅ **iOS** (físico o simulador)
- ❌ **Web/Chrome** (no soportado)

## ✅ Solución Temporal (Mientras Configuras Firebase)

Tu app ahora **refresca automáticamente cada 30 segundos** sin necesidad de notificaciones push.

Esto significa:
- Las nuevas solicitudes aparecerán en máximo 30 segundos
- No necesitas esperar a que llegue una notificación
- Funciona mientras configuras Firebase

**Logs que verás:**
```
✅ Auto-refresh activado (cada 30s)
🔄 Auto-refresh: sincronizando solicitudes...
🔄 Auto-refresh: sincronizando solicitudes...
```

## 🚀 Para que Funcionen las Notificaciones Push (Reales)

### Paso 1: Ejecutar en Android o iOS

```bash
# NO ejecutes en web
# flutter run -d chrome  ❌ MAL

# Ejecuta en Android/iOS
flutter run  ✅ BIEN
```

### Paso 2: Descarga la Configuración de Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Busca tu proyecto
3. **Para Android:**
   - Configuración del proyecto → Tus apps → Tu app Android
   - Descarga `google-services.json`
   - Coloca en: `android/app/google-services.json`

4. **Para iOS:**
   - Configuración del proyecto → Tus apps → Tu app iOS
   - Descarga `GoogleService-Info.plist`
   - Abre Xcode: `open ios/Runner.xcworkspace`
   - Arrastra el archivo a Runner
   - Marca "Copy items if needed"

### Paso 3: Ejecuta la App

```bash
flutter run
```

Busca en los logs:
```
✅ Firebase inicializado correctamente
✅ FCM Token obtenido: eEW8fqYuT9c:APA91bF...
```

### Paso 4: Tu Backend

Necesita recibir el token FCM:
```
POST /notifications/register-device
{
  "token": "eEW8fqYuT9c:APA91bF...",
  "platform": "android"
}
```

Y enviar notificaciones:
```javascript
admin.messaging().sendMulticast({
  notification: {
    title: 'Nueva Solicitud',
    body: 'Se recibió una nueva solicitud'
  },
  data: {
    solicitudId: '12345'
  },
  tokens: [deviceToken1, deviceToken2]
})
```

---

## 📊 Comparación: Ahora vs. Después

### 🟡 AHORA (Sin Firebase configurado)
- ✅ Refresco automático cada 30s
- ✅ Puedes tirar para refrescar manual
- ❌ No hay notificaciones push
- ❌ Si sale de la app, no se actualiza

### 🟢 DESPUÉS (Con Firebase configurado)
- ✅ Notificaciones push inmediatas
- ✅ Se actualiza en tiempo real
- ✅ Funciona aunque salgas de la app
- ✅ Sonido/vibración en notificación

---

## 🛠️ Qué Ya Hemos Hecho

- ✅ Mejorado `FcmService` con callbacks
- ✅ `AuthProvider` registra/desregistra tokens
- ✅ `HomeScreen` actualiza lista al recibir notificación
- ✅ Sistema de auto-refresh cada 30s
- ✅ Archivo dummy `google-services.json`
- ✅ Logs claros para debugging

## 📋 Checklist Final

- [ ] Ejecutando en Android/iOS (NO web)
- [ ] Descargaste `google-services.json` desde Firebase
- [ ] Descargaste `GoogleService-Info.plist` desde Firebase
- [ ] Reemplazaste los archivos dummy con los reales
- [ ] Backend recibe token FCM en `/notifications/register-device`
- [ ] Backend envía notificaciones con Firebase Admin SDK
- [ ] El FCM Token aparece en los logs

---

## 🆘 Si Aún No Funciona

Ve a [DEBUG_NOTIFICACIONES.md](DEBUG_NOTIFICACIONES.md) para troubleshooting detallado.
