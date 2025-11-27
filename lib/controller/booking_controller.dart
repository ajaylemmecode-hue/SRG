// lib/controller/booking_controller.dart - COMPLETE FIXED VERSION

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_suvarnraj_group/api/api_service.dart';
import 'package:new_suvarnraj_group/controller/user_controller.dart';
import 'package:new_suvarnraj_group/models/booking_model.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingController extends GetxController {
  final RxList<BookingModel> bookings = <BookingModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  bool _isFetching = false;

  // ✅ FOR CALENDAR FULL DATE CHECK
  final Set<DateTime> _fullDates = <DateTime>{}.obs;

  late UserController userCtrl;

  @override
  void onInit() {
    super.onInit();
    userCtrl = Get.find<UserController>();

    if (userCtrl.isLoggedIn.value && userCtrl.token.value.isNotEmpty) {
      fetchBookings();
    }

    ever(userCtrl.isLoggedIn, (isLoggedIn) {
      if (isLoggedIn && userCtrl.token.value.isNotEmpty) {
        fetchBookings();
      } else {
        clearData();
      }
    });
  }

  /// ✅ CHECK IF DATE IS FULL (FOR CALENDAR)
  bool isDateFull(DateTime date) {
    return _fullDates.any((d) => isSameDay(d, date));
  }

  /// ✅ MARK DATE AS FULL (CALL WHEN NEEDED)
  void markDateAsFull(DateTime date) {
    _fullDates.add(date);
  }

  /// ✅ FETCH BOOKINGS FROM API - FULLY FIXED
  Future<void> fetchBookings() async {
    if (_isFetching) {
      if (kDebugMode) print("⚠️ Already fetching bookings, skipping...");
      return;
    }

    try {
      _isFetching = true;
      isLoading.value = true;
      errorMessage.value = '';

      final token = userCtrl.token.value;
      if (token.isEmpty) {
        errorMessage.value = "Please login to view bookings";
        if (kDebugMode) print("❌ No token available");
        return;
      }

      if (kDebugMode) {
        print("📡 Fetching bookings with token: ${token.substring(0, 20)}...");
      }

      final response = await ApiService.fetchBookings(token);

      if (kDebugMode) {
        print("✅ Bookings API Response received");
        print("   Response Keys: ${response.keys.toList()}");
        print("   Message: ${response['message']}");
        print("   Data Type: ${response['data'].runtimeType}");
      }

      // ✅ HANDLE BOTH LIST AND MAP RESPONSES
      List<dynamic> bookingList = [];

      if (response['data'] == null) {
        // No data key at all
        bookingList = [];
        if (kDebugMode) print("⚠️ No 'data' key in response");
      } else if (response['data'] is List) {
        // ✅ Case 1: data is directly a List
        bookingList = response['data'] as List<dynamic>;
        if (kDebugMode) print("✅ Data is a List with ${bookingList.length} items");
      } else if (response['data'] is Map) {
        // ✅ Case 2: data is a Map containing a list
        final dataMap = response['data'] as Map<String, dynamic>;
        if (kDebugMode) print("✅ Data is a Map with keys: ${dataMap.keys.toList()}");

        if (dataMap.containsKey('bookings')) {
          bookingList = dataMap['bookings'] as List<dynamic>;
          if (kDebugMode) print("   Found 'bookings' key");
        } else if (dataMap.containsKey('orders')) {
          bookingList = dataMap['orders'] as List<dynamic>;
          if (kDebugMode) print("   Found 'orders' key");
        } else if (dataMap.containsKey('data')) {
          bookingList = dataMap['data'] as List<dynamic>;
          if (kDebugMode) print("   Found nested 'data' key");
        } else {
          // Try to find any key that contains a list
          for (var entry in dataMap.entries) {
            if (entry.value is List) {
              bookingList = entry.value as List<dynamic>;
              if (kDebugMode) print("   Found list in key: '${entry.key}'");
              break;
            }
          }
        }
      }

      if (kDebugMode) print("📦 Total bookings found: ${bookingList.length}");

      if (bookingList.isEmpty) {
        bookings.clear();
        if (kDebugMode) print("ℹ️ No bookings to display");
      } else {
        final List<BookingModel> parsed = [];

        for (var i = 0; i < bookingList.length; i++) {
          try {
            final booking = BookingModel.fromJson(bookingList[i] as Map<String, dynamic>);
            parsed.add(booking);
          } catch (e) {
            if (kDebugMode) {
              print("⚠️ Error parsing booking at index $i: $e");
              print("   Raw data: ${bookingList[i]}");
            }
          }
        }

        bookings.assignAll(parsed);
        if (kDebugMode) print("✅ Successfully parsed ${parsed.length} bookings");
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      if (kDebugMode) {
        print("❌ Fetch bookings error: $e");
        print("   Error type: ${e.runtimeType}");
      }

      // ✅ FIXED: Only show snackbar if one isn't already open
      if (!Get.isSnackbarOpen) {
        Get.snackbar(
          "Error",
          errorMessage.value.isEmpty ? "Failed to load bookings" : errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(10),
        );
      }
    } finally {
      isLoading.value = false;
      _isFetching = false;
    }
  }

  /// ✅ CANCEL BOOKING
  Future<bool> cancelBooking(int orderId) async {
    try {
      isLoading.value = true;
      final token = userCtrl.token.value;
      if (token.isEmpty) throw Exception("Authentication required");

      if (kDebugMode) print("🗑️ Cancelling booking ID: $orderId");

      await ApiService.cancelOrder(orderId, token);
      bookings.removeWhere((b) => b.id == orderId);

      if (!Get.isSnackbarOpen) {
        Get.snackbar(
          "Success",
          "Booking cancelled successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(10),
        );
      }

      if (kDebugMode) print("✅ Booking cancelled: $orderId");
      return true;
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      if (kDebugMode) print("❌ Cancel error: $e");

      if (!Get.isSnackbarOpen) {
        Get.snackbar(
          "Error",
          errorMsg.isEmpty ? "Failed to cancel booking" : errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(10),
        );
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ RESCHEDULE BOOKING
  Future<bool> rescheduleBooking(int orderId, DateTime newDateTime) async {
    try {
      isLoading.value = true;
      final token = userCtrl.token.value;
      if (token.isEmpty) throw Exception("Authentication required");

      if (kDebugMode) print("📅 Rescheduling booking ID: $orderId to $newDateTime");

      await ApiService.rescheduleOrder(
        orderId: orderId,
        newDateTime: newDateTime,
        token: token,
      );

      final index = bookings.indexWhere((b) => b.id == orderId);
      if (index != -1) {
        bookings[index].dateTime = newDateTime;
        bookings.refresh();
      }

      if (!Get.isSnackbarOpen) {
        Get.snackbar(
          "Success",
          "Booking rescheduled successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(10),
        );
      }

      if (kDebugMode) print("✅ Booking rescheduled: $orderId");
      return true;
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      if (kDebugMode) print("❌ Reschedule error: $e");

      if (!Get.isSnackbarOpen) {
        Get.snackbar(
          "Error",
          errorMsg.isEmpty ? "Failed to reschedule booking" : errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(10),
        );
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ CLEAR DATA
  void clearData() {
    bookings.clear();
    errorMessage.value = '';
    isLoading.value = false;
    _isFetching = false;
    _fullDates.clear();
    if (kDebugMode) print("🧹 Booking data cleared");
  }

  /// ✅ GET BOOKING BY ID
  BookingModel? getBookingById(int id) {
    try {
      return bookings.firstWhere((b) => b.id == id);
    } catch (e) {
      if (kDebugMode) print("⚠️ Booking not found with ID: $id");
      return null;
    }
  }

  /// ✅ REFRESH BOOKINGS
  Future<void> refreshBookings() async {
    if (kDebugMode) print("🔄 Refreshing bookings...");
    await fetchBookings();
  }

  // ✅ GETTERS FOR STATS
  int get totalBookings => bookings.length;

  int get upcomingCount =>
      bookings.where((b) => b.status.toLowerCase() == 'confirmed' ||
          b.status.toLowerCase() == 'pending').length;

  int get completedCount =>
      bookings.where((b) => b.status.toLowerCase() == 'completed').length;

  int get cancelledCount =>
      bookings.where((b) => b.status.toLowerCase() == 'cancelled').length;

  double get totalRevenue =>
      bookings.fold(0.0, (sum, b) => sum + b.price);

  List<BookingModel> get upcomingBookings =>
      bookings.where((b) => b.status.toLowerCase() == 'confirmed' ||
          b.status.toLowerCase() == 'pending').toList();

  List<BookingModel> get completedBookings =>
      bookings.where((b) => b.status.toLowerCase() == 'completed').toList();

  List<BookingModel> get cancelledBookings =>
      bookings.where((b) => b.status.toLowerCase() == 'cancelled').toList();

  /// ✅ CHECK IF HAS BOOKINGS
  bool get hasBookings => bookings.isNotEmpty;

  /// ✅ CHECK IF HAS ERROR
  bool get hasError => errorMessage.value.isNotEmpty;
}