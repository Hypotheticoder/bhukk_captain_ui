import 'package:bhukkdelivery/firebase_options.dart';
import 'package:bhukkdelivery/providers/theme/theme_provider.dart';
import 'package:bhukkdelivery/routes/app_router.dart';
import 'package:bhukkdelivery/services/map_service.dart';
import 'package:bhukkdelivery/services/driver_notification_service.dart';
import 'package:bhukkdelivery/services/background_notification_service.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Top-level background message handler.
/// Must be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint("🔥 Driver Background Ping: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  MapService.instance.init();

  // Initialise notification services
  await DriverNotificationService.instance.init();
  await BackgroundNotificationService.instance.requestPermissionsAndCreateChannel();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Caby24 Driver',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
