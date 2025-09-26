import 'package:get/get.dart';
import '../models/booking_model.dart';

class BookingController extends GetxController {
  var bookings = <BookingModel>[].obs;
  static const int maxBookingsPerDate = 2;

  bool isDateFull(DateTime date) {
    return countBookingsOnDate(date) >= maxBookingsPerDate;
  }
  // 🔹 Add a booking
  void addBooking(BookingModel booking) {
    bookings.add(booking);
  }

  // 🔹 Update booking status by id
  void updateBookingStatus(String id, String newStatus) {
    int index = bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      bookings[index] = bookings[index].copyWith(status: newStatus);
      bookings.refresh(); // 🔄 refresh list
    }
  }

  // 🔹 Update booking date/time by id
  void updateBookingDate(String id, DateTime newDate) {
    int index = bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      bookings[index] = bookings[index].copyWith(dateTime: newDate);
      bookings.refresh(); // 🔄 refresh list
    }
  }
}

// 🔹 Extra utilities for date checks
extension BookingControllerExt on BookingController {
  int countBookingsOnDate(DateTime date) {
    return bookings.where((b) =>
    b.dateTime.year == date.year &&
        b.dateTime.month == date.month &&
        b.dateTime.day == date.day).length;
  }

  bool isDateFull(DateTime date) {
    return countBookingsOnDate(date) >= 2; // max 2 bookings per date
  }
}
