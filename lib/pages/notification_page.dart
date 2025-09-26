import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:new_suvarnraj_group/controller/notification_controller.dart';
import 'package:new_suvarnraj_group/controller/home_page_controller.dart';
import 'package:new_suvarnraj_group/models/notification_model.dart';
import 'package:new_suvarnraj_group/pages/home_page.dart';

class NotificationsPage extends StatelessWidget {
  final NotificationController controller = Get.find();

  NotificationsPage({super.key});

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hr ago";
    return DateFormat("dd MMM, hh:mm a").format(timestamp);
  }

  IconData _getIconForNotif(AppNotification notif) {
    if (notif.payload != null && notif.payload!.startsWith("booking:")) {
      return Icons.event_note;
    }
    return Icons.notifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: "Clear all",
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Clear all notifications?"),
                  content: const Text("This action cannot be undone."),
                  actions: [
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    ElevatedButton(
                      child: const Text("Clear All"),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                ),
              );
              if (confirm == true) controller.clearAll();
            },
          )
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return const Center(
            child: Text(
              "No notifications yet 🙂",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notif = controller.notifications[index];
            return Dismissible(
              key: ValueKey(notif.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => controller.removeNotification(notif.id),
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(_getIconForNotif(notif), color: Colors.blue),
                  ),
                  title: Text(
                    notif.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notif.body),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(notif.timestamp),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    if (notif.payload != null && notif.payload!.startsWith("booking:")) {
                      final bookingId = notif.payload!.split(":").last;

                      Get.snackbar(
                        "Notification tapped",
                        "Opening booking $bookingId",
                        snackPosition: SnackPosition.BOTTOM,
                      );

                      try {
                        final homeCtrl = Get.find<HomePageController>();
                        homeCtrl.changeTab(HomePageTabs.bookings);

                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (kIsWeb) {
                            Get.toNamed('/booking-details?id=$bookingId');
                          } else {
                            Get.toNamed('/booking-details', arguments: {"id": bookingId});
                          }
                        });
                      } catch (_) {
                        debugPrint("HomePageController not found.");
                      }
                    }
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
