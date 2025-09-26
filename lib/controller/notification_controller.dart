import 'package:get/get.dart';
import 'package:new_suvarnraj_group/models/notification_model.dart';

class NotificationController extends GetxController {
  var notifications = <AppNotification>[].obs;

  void addNotification(AppNotification notification) {
    notifications.insert(0, notification); // newest first
  }

  void removeNotification(int id) {
    notifications.removeWhere((n) => n.id == id);
  }

  void clearAll() {
    notifications.clear();
  }
}
