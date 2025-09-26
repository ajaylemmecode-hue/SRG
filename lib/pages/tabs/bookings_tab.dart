// lib/pages/tabs/bookings_tab.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../controller/booking_controller.dart';
import '../../models/booking_model.dart';

class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final BookingController bookingController = Get.put(BookingController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  ColorScheme get cs => Theme.of(context).colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          child: Row(
            children: [
              FaIcon(FontAwesomeIcons.calendarCheck, size: 18.sp),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'My Bookings',
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                icon: FaIcon(FontAwesomeIcons.rotate, size: 16.sp),
                onPressed: () => bookingController.refresh(),
              ),
            ],
          ),
        ),

        // Tabs
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          padding: EdgeInsets.all(1.w),
          decoration: BoxDecoration(
            color: cs.surface.withOpacity(0.06),
            borderRadius: BorderRadius.circular(3.w),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: cs.onPrimary,
            unselectedLabelColor: cs.onSurface.withOpacity(0.7),
            indicator: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(2.w),
              boxShadow: [
                BoxShadow(color: cs.primary.withOpacity(0.16), blurRadius: 6)
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp),
            tabs: const [
              Tab(text: "Upcoming"),
              Tab(text: "Completed"),
              Tab(text: "Cancelled"),
            ],
          ),
        ),

        // Body
        Expanded(
          child: Obx(() {
            final bookings = bookingController.bookings;
            if (bookings.isEmpty) {
              return Center(
                child: Text(
                  "No bookings yet",
                  style: TextStyle(
                      color: cs.onSurface.withOpacity(0.6), fontSize: 14.sp),
                ),
              );
            }

            return TabBarView(
              controller: _tabController,
              children: [
                _bookingListForStatus("Confirmed"),
                _bookingListForStatus("Completed"),
                _bookingListForStatus("Cancelled"),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _bookingListForStatus(String status) {
    final filtered = bookingController.bookings
        .where((b) => b.status == status)
        .toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text("No $status bookings",
            style: TextStyle(color: cs.onSurface.withOpacity(0.6), fontSize: 14.sp)),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => SizedBox(height: 1.5.h),
      itemBuilder: (context, i) {
        // fade-in animation
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + (i * 100)),
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 20),
              child: child,
            ),
          ),
          child: _bookingCard(filtered[i]),
        );
      },
    );
  }

  Widget _bookingCard(BookingModel booking) {
    final Color statusColor;
    final Color statusBg;

    switch (booking.status) {
      case "Confirmed":
        statusColor = Colors.blue;
        statusBg = Colors.indigo.shade50;
        break;
      case "Completed":
        statusColor = Colors.green;
        statusBg = Colors.green.shade50;
        break;
      case "Cancelled":
        statusColor = Colors.red;
        statusBg = Colors.red.shade50;
        break;
      default:
        statusColor = Colors.grey;
        statusBg = Colors.grey.shade200;
    }

    final formattedDate =
    DateFormat("dd MMM yyyy, hh:mm a").format(booking.dateTime);

    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(3.w),
      child: InkWell(
        borderRadius: BorderRadius.circular(3.w),
        onTap: () => _showBookingDetails(booking),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      booking.serviceName,
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                    decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(5.w)),
                    child: Text(booking.status,
                        style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp)),
                  ),
                ],
              ),

              SizedBox(height: 1.2.h),

              // category + date
              Row(
                children: [
                  FaIcon(FontAwesomeIcons.toolbox,
                      size: 13.sp, color: Colors.grey),
                  SizedBox(width: 2.w),
                  Expanded(
                      child: Text(booking.category,
                          style: TextStyle(
                              fontSize: 13.sp,
                              color: cs.onSurface.withOpacity(0.7)))),
                  SizedBox(width: 3.w),
                  FaIcon(FontAwesomeIcons.calendarDay,
                      size: 13.sp, color: Colors.grey),
                  SizedBox(width: 1.w),
                  Text(formattedDate,
                      style: TextStyle(
                          fontSize: 13.sp,
                          color: cs.onSurface.withOpacity(0.75))),
                ],
              ),

              SizedBox(height: 1.2.h),

              // location
              Row(
                children: [
                  FaIcon(FontAwesomeIcons.locationDot,
                      size: 13.sp, color: Colors.grey),
                  SizedBox(width: 2.w),
                  Expanded(
                      child: Text(booking.address,
                          style: TextStyle(
                              fontSize: 13.sp,
                              color: cs.onSurface.withOpacity(0.8)))),
                ],
              ),

              SizedBox(height: 1.h),

              // customer
              Row(
                children: [
                  FaIcon(FontAwesomeIcons.user,
                      size: 13.sp, color: Colors.grey),
                  SizedBox(width: 2.w),
                  Text(booking.customerName,
                      style: TextStyle(
                          fontSize: 13.sp,
                          color: cs.onSurface.withOpacity(0.8))),
                ],
              ),

              SizedBox(height: 1.5.h),

              // price + actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("₹${booking.price}",
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15.sp)),
                  Row(children: _buildActionsForBooking(booking)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActionsForBooking(BookingModel booking) {
    final List<Widget> actions = [];

    if (booking.status == "Confirmed") {
      actions.add(_smallActionButton(
        icon: FontAwesomeIcons.calendarXmark,
        label: 'Cancel',
        color: Colors.red.shade700,
        onTap: () => _confirmCancel(booking),
      ));

      actions.add(SizedBox(width: 1.5.w));

      actions.add(_smallActionButton(
        icon: FontAwesomeIcons.calendarAlt,
        label: 'Reschedule',
        color: Colors.orange.shade700,
        onTap: () => _rescheduleBooking(booking),
      ));

      actions.add(SizedBox(width: 1.5.w));

      actions.add(_smallActionButton(
        icon: FontAwesomeIcons.infoCircle,
        label: 'Details',
        color: Colors.blue.shade700,
        onTap: () => _showBookingDetails(booking),
      ));
    } else {
      actions.add(_smallActionButton(
        icon: FontAwesomeIcons.infoCircle,
        label: 'Details',
        color: Colors.blue.shade700,
        onTap: () => _showBookingDetails(booking),
      ));
    }

    return actions;
  }

  Widget _smallActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.08),
        foregroundColor: color,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.w)),
      ),
      onPressed: onTap,
      icon: FaIcon(icon, size: 12.sp),
      label: Text(label, style: TextStyle(fontSize: 14.sp)),
    );
  }

  // cancel / reschedule / details logic remain same
  Future<void> _confirmCancel(BookingModel booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cancel booking?"),
        content: Text(
            "Do you want to cancel the booking for \"${booking.serviceName}\" on ${DateFormat('dd MMM yyyy').format(booking.dateTime)}?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("No")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes, cancel")),
        ],
      ),
    );

    if (confirmed == true) {
      bookingController.updateBookingStatus(booking.id, "Cancelled");
      Get.snackbar("Cancelled", "Booking cancelled successfully",
          backgroundColor: Colors.red.shade50);
    }
  }

  Future<void> _rescheduleBooking(BookingModel booking) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: booking.dateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (picked == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(booking.dateTime),
    );

    if (pickedTime == null) return;

    final newDateTime = DateTime(
        picked.year, picked.month, picked.day, pickedTime.hour, pickedTime.minute);
    await _applyReschedule(booking, newDateTime);
  }

  Future<void> _applyReschedule(BookingModel booking, DateTime newDateTime) async {
    bookingController.updateBookingDate(booking.id, newDateTime);

    Get.snackbar(
      "Rescheduled",
      "Booking moved to ${DateFormat('dd MMM yyyy, hh:mm a').format(newDateTime)}",
      backgroundColor: Colors.orange.shade50,
    );
  }

  void _showBookingDetails(BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(3.w)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FaIcon(FontAwesomeIcons.receipt, size: 16.sp),
                      SizedBox(width: 3.w),
                      Expanded(
                          child: Text(booking.serviceName,
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold))),
                      IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close)),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  _detailRow(Icons.calendar_today, "Date",
                      DateFormat('dd MMM yyyy, hh:mm a').format(booking.dateTime)),
                  SizedBox(height: 1.h),
                  _detailRow(Icons.location_on, "Address",
                      booking.address +
                          (booking.secondaryAddress != null
                              ? '\n${booking.secondaryAddress}'
                              : '')),
                  SizedBox(height: 1.h),
                  _detailRow(Icons.person, "Customer", booking.customerName),
                  SizedBox(height: 1.h),
                  _detailRow(Icons.tag, "Category", booking.category),
                  SizedBox(height: 1.h),
                  _detailRow(Icons.money, "Price", "₹${booking.price}"),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _rescheduleBooking(booking);
                            },
                            icon: FaIcon(FontAwesomeIcons.calendarAlt, size: 14.sp),
                            label: Text("Reschedule",
                                style: TextStyle(fontSize: 14.sp)),
                          )),
                      SizedBox(width: 3.w),
                      Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _confirmCancel(booking);
                            },
                            icon: FaIcon(FontAwesomeIcons.trash,
                                size: 14.sp, color: Colors.white),
                            label: Text("Cancel",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14.sp)),
                          )),
                    ],
                  ),
                  SizedBox(height: 1.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14.sp, color: cs.onSurface.withOpacity(0.7)),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 13.sp, color: cs.onSurface.withOpacity(0.6))),
              SizedBox(height: 0.5.h),
              Text(value,
                  style: TextStyle(fontSize: 14.sp, color: cs.onSurface)),
            ],
          ),
        )
      ],
    );
  }
}
