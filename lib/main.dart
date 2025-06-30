import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './screens/login_screen.dart';
import './screens/home_screen.dart';

// Handler para mensajes en segundo plano
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔙 Mensaje recibido en segundo plano: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Registrar el handler para mensajes en background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Pedir permisos para recibir notificaciones (Android 13+)
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('Permisos de notificación: ${settings.authorizationStatus}');

  // Obtener token FCM para enviar mensajes dirigidos a este dispositivo
  final fcmToken = await messaging.getToken();
  print('✅ Token FCM: $fcmToken');
  //Guarda Token FCM
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('fcm_token', fcmToken ?? '');
  //Verificar el Auth Token
  final token = prefs.getString('auth_token');
  print(token);
  runApp(MyApp(isLoggedIn: token != null));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Escuchar notificaciones mientras la app está abierta (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
        '📩 Notificación recibida en foreground: ${message.notification?.title}',
      );

      // Mostrar diálogo o snackbar aquí si quieres
      if (message.notification != null) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(message.notification!.title ?? 'Notificación'),
            content: Text(message.notification!.body ?? ''),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cerrar'),
              ),
            ],
          ),
        );
      }
    });

    // Manejar cuando la app se abre desde la notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📲 App abierta desde notificación');
      // Aquí puedes navegar a una pantalla específica
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Messaging',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: widget.isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
