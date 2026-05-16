# UCApp (Flutter) — Taller

Aplicación de ejemplo para un taller en Flutter.

Cumple con los requisitos principales:

- **Login → Home** pasando el usuario logueado.
- **Persistencia local** usando `shared_preferences` (SharedPreferences).
- **Home con formulario + menú + alertas/notificaciones** (SnackBars y AlertDialogs).
- **Registro funcional** con usuario/contraseña y soporte **multiusuario**.

## Funcionalidades

### Autenticación (local)

- Registro de usuario y contraseña.
- Inicio de sesión y sesión persistente.
- Cierre de sesión.
- Historial de sesiones por usuario (login/logout con fecha).

> Nota: para el taller la contraseña se guarda en texto plano dentro de SharedPreferences.
> No es una práctica segura para producción.

### Home (datos)

- Formulario con **Título** y **Descripción**.
- Guarda elementos en una lista y los persiste localmente.
- Cada usuario ve **sus propios datos** (se guardan con una key por usuario).

### Menú (Drawer)

- Historial de sesiones.
- Limpiar datos del usuario.
- Cerrar sesión.
- Acerca de (integrantes).

## Arquitectura / estructura

Estructura simple por capas:

- `lib/main.dart`
	- Entry point (`runApp`) + tema global (Material 3).
- `lib/ui/splash_decider.dart`
	- Decide pantalla inicial según sesión guardada (Login o Home).
- `lib/ui/login_page.dart`
	- Login (usuario/contraseña) + link a registro.
- `lib/ui/register_page.dart`
	- Registro de usuario.
- `lib/ui/home_page.dart`
	- Home con formulario, lista de datos, drawer, SnackBars y AlertDialogs.
- `lib/storage/prefs_service.dart`
	- Servicio centralizado para leer/escribir SharedPreferences.
- `lib/models/home_item.dart`
	- Modelo de un elemento del Home y helpers JSON.

## Persistencia (SharedPreferences)

Se usa `shared_preferences` para guardar datos tipo key/value en el dispositivo.

Principales claves usadas (ver `PrefsKeys` en `lib/storage/prefs_service.dart`):

- `logged_in`: bool (sesión activa)
- `username`: string (usuario actual)
- `users_json`: lista JSON de usuarios registrados
- `sessions_json`: lista JSON de eventos (login/logout)
- `items_json_<username>`: lista JSON de items del Home por usuario

## Cómo correr el proyecto

### Requisitos

- Flutter instalado y funcionando: `flutter doctor -v`

### Pasos básicos

```bash
flutter pub get
flutter run
```

### Web

```bash
flutter run -d chrome
```

Si el entorno no abre Chrome automáticamente, alternativa:

```bash
flutter run -d web-server
```

Flutter mostrará una URL; ábrela manualmente en el navegador.

### Android (Emulador)

- Abre el proyecto desde la **carpeta raíz** (donde está `pubspec.yaml`).

Comandos útiles:

```bash
flutter emulators
flutter emulators --launch Pixel_7
flutter devices
flutter run -d emulator-5554
```

## Tests y análisis

```bash
flutter test
flutter analyze
```

## Generar APK (Android)

```bash
flutter build apk --release
```

Salida típica:

- `build/app/outputs/flutter-apk/app-release.apk`

## Troubleshooting rápido

### `adb.exe: device 'emulator-5554' not found`

- Verifica que el emulador siga encendido (Android Studio / Device Manager).
- Revisa conexión:

```bash
adb devices -l
```

- Reinicia ADB y reintenta:

```bash
adb kill-server
adb start-server
flutter devices
flutter run -d emulator-5554
```

## Integrantes

- Shein Jadid Moreno Sarmiento
- Andrés Fernando Jaramillo Beltran
- Daniel Francisco Valle Ortiz
- José Rafael Campos Guerra
- Rodolfo Carlos Martínez Arellano
