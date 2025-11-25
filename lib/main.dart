import 'package:flutter/material.dart';
import 'package:good_news/responsive_app.dart';
import 'package:good_news/features/authentication/presentation/screens/login_screen.dart';
import 'package:good_news/features/onboarding/presentation/screens/choose_topics_screen.dart';
import 'package:good_news/core/services/preferences_service.dart';
import 'package:good_news/core/services/theme_service.dart';
import 'package:good_news/core/themes/app_theme.dart';
import 'package:good_news/core/services/notification_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 🔥 Background Message Handler (App बंद असताना)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("📩 Background Notification: ${message.notification?.title}");
}

/// Local Notification Plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Firebase init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔥 Background Notification Handler register
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 🔥 Initialize Local Notifications (foreground popup साठी)
  const AndroidInitializationSettings androidInit =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
  InitializationSettings(android: androidInit);

  await flutterLocalNotificationsPlugin.initialize(initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint("🔔 Notification Clicked");
      });

  runApp(const GoodNewsApp());
}

class GoodNewsApp extends StatefulWidget {
  const GoodNewsApp({Key? key}) : super(key: key);

  @override
  State<GoodNewsApp> createState() => _GoodNewsAppState();
}

class _GoodNewsAppState extends State<GoodNewsApp> {
  late ThemeService _themeService;

  @override
  void initState() {
    super.initState();
    _themeService = ThemeService();
    _themeService.loadPreferences();

    /// 🔥 Messaging Setup
    _setupFirebaseMessaging();
  }

  /// 🔥 Firebase Messaging Setup Function
  void _setupFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Permission request (Android optional, iOS required)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      sound: true,
      badge: true,
    );
    debugPrint("🔔 Permission: ${settings.authorizationStatus}");

    // 🔥 Device Token (API ला पाठवायला)
    String? token = await messaging.getToken();
    debugPrint("📱 FCM Token: $token");

    /// 🔥 Foreground Notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("📩 Foreground Notification: ${message.notification?.title}");
      _showLocalNotification(message);
    });

    /// 🔥 Notification Click (App background मध्ये असताना)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("👉 Notification Clicked: ${message.notification?.title}");
    });
  }

  /// 🔥 Local Notification Popup (Foreground साठी)
  void _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'goodnews_channel',
      'Good News Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification?.title,
      notification?.body,
      platformDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeService,
      builder: (context, child) {
        ThemeData lightTheme;
        ThemeData darkTheme;

        if (_themeService.themeType == AppThemeType.green) {
          lightTheme = AppTheme.greenLightTheme;
          darkTheme = AppTheme.greenDarkTheme;
        } else {
          lightTheme = AppTheme.pinkLightTheme;
          darkTheme = AppTheme.pinkDarkTheme;
        }

        return MaterialApp(
          title: 'Good News',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: _themeService.themeMode,
          scaffoldMessengerKey: NotificationService.scaffoldKey,
          home: FutureBuilder<Widget>(
            future: _determineInitialScreen(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                final bgColor = _themeService.isDarkMode
                    ? const Color(0xFF1A1A1A)
                    : Colors.white;

                final progressColor = _themeService.themeType == AppThemeType.green
                    ? const Color(0xFF4CAF50)
                    : AppTheme.accentPink;

                return Scaffold(
                  backgroundColor: bgColor,
                  body: Center(
                    child: CircularProgressIndicator(color: progressColor),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Scaffold(
                  backgroundColor:
                  _themeService.isDarkMode ? Colors.black : Colors.white,
                  body: Center(
                    child: Text("Error loading app"),
                  ),
                );
              }

              return snapshot.data ?? const LoginScreen();
            },
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  Future<Widget> _determineInitialScreen() async {
    try {
      final isLoggedIn = await PreferencesService.isLoggedIn();

      if (!isLoggedIn) return const LoginScreen();

      final hasCompletedOnboarding =
      await PreferencesService.isOnboardingCompleted();

      if (!hasCompletedOnboarding) return const ChooseTopicsScreen();

      return const ResponsiveApp();
    } catch (e) {
      debugPrint("🔥 Initial Screen Error: $e");
      return const LoginScreen();
    }
  }
}