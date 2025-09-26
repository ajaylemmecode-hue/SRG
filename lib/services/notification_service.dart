import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:new_suvarnraj_group/models/notification_model.dart';
import 'package:get/get.dart';
import 'package:new_suvarnraj_group/controller/home_page_controller.dart';
import 'package:new_suvarnraj_group/controller/notification_controller.dart';
import 'package:new_suvarnraj_group/pages/home_page.dart';

class NotificationService {
  NotificationService._(); // private constructor
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  /// Call this from main() before runApp
  static Future<void> init() async {
    if (kIsWeb) {
      debugPrint("Web platform: notifications will not use FlutterLocalNotificationsPlugin.");
      return;
    }

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings settings =
    InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        _onNotificationTap(payload);
      },
    );

    await requestPermissionsIfNeeded();
  }

  /// Request mobile permissions
  static Future<void> requestPermissionsIfNeeded() async {
    if (kIsWeb) return; // web: skip permissions

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else {
      // Android 13+ permissions can be requested if needed via permission_handler
      debugPrint("Android: notification permissions may be requested if needed.");
    }
  }

  /// Show a notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) {
      // Web fallback: just log
      debugPrint("Web notification: $title - $body (payload: $payload)");
      _saveNotification(id, title, body, payload);
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'booking_channel',
      'Bookings',
      channelDescription: 'Booking related notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(id, title, body, platformDetails, payload: payload);
    _saveNotification(id, title, body, payload);
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    if (!kIsWeb) await _plugin.cancelAll();
  }

  /// Save notification in controller
  static void _saveNotification(int id, String title, String body, String? payload) {
    try {
      final notifCtrl = Get.find<NotificationController>();
      notifCtrl.addNotification(AppNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
        timestamp: DateTime.now(),
      ));
    } catch (_) {}
  }

  /// Handle tap on notification
  static void _onNotificationTap(String? payload) {
    if (payload != null && payload.startsWith('booking:')) {
      final bookingId = payload.split(':').last;
      try {
        final homeCtrl = Get.find<HomePageController>();
        homeCtrl.changeTab(HomePageTabs.bookings);
        // Optional: navigate to booking details page
      } catch (_) {}
    }
  }
}
