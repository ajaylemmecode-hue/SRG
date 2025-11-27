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

  BookingController get bookingController => Get.find<BookingController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    if (!Get.isRegistered<BookingController>()) {
      Get.put(BookingController());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  ColorScheme get cs => Theme.of(context).colorScheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: Column(
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
                Obx(() => IconButton(
                  tooltip: 'Refresh',
                  icon: bookingController.isLoading.value
                      ? SizedBox(
                    width: 16.sp,
                    height: 16.sp,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : FaIcon(FontAwesomeIcons.rotate, size: 16.sp),
                  onPressed: bookingController.isLoading.value
                      ? null
                      : () => bookingController.refresh(),
                )),
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
              labelColor: Colors.white,
              unselectedLabelColor: cs.onSurface.withOpacity(0.7),
              indicator: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(2.w),
                boxShadow: [
                  BoxShadow(color: Colors.blue.withOpacity(0.16), blurRadius: 6)
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
              if (bookingController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (bookingController.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.triangleExclamation,
                        size: 48.sp,
                        color: Colors.orange,
                      ),
                      SizedBox(height: 2.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text(
                          bookingController.errorMessage.value
                              .replaceAll('Exception: ', ''),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: cs.onSurface.withOpacity(0.7),
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      ElevatedButton.icon(
                        onPressed: () => bookingController.refresh(),
                        icon: const FaIcon(FontAwesomeIcons.rotate, size: 16),
                        label: const Text("Retry"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 1.5.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final bookings = bookingController.bookings;
              if (bookings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.calendarXmark,
                        size: 48.sp,
                        color: cs.onSurface.withOpacity(0.3),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "No bookings yet",
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(0.6),
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // ✅ FIXED: Move Obx outside TabBarView
              return TabBarView(
                controller: _tabController,
                children: [
                  _bookingList(bookingController.upcomingBookings),
                  _bookingList(bookingController.completedBookings),
                  _bookingList(bookingController.cancelledBookings),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ✅ FIXED: Remove Obx from here → use pre-filtered lists
  Widget _bookingList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.folderOpen,
              size: 40.sp,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            SizedBox(height: 2.h),
            Text(
              "No bookings in this category",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () {
        bookingController.refresh(); // ✅ Call without await
        return Future.delayed(Duration.zero); // ✅ Return Future for RefreshIndicator
      },
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        itemCount: bookings.length,
        separatorBuilder: (_, __) => SizedBox(height: 1.5.h),
        itemBuilder: (context, i) {
          return _bookingCard(bookings[i]);
        },
      ),
    );
  }

  Widget _bookingCard(BookingModel booking) {
    final Color statusColor;
    final Color statusBg;

    switch (booking.status) {
      case "Confirmed":
        statusColor = Colors.blue;
        statusBg = Colors.blue.shade50;
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

    final formattedDate = DateFormat("dd MMM yyyy, hh:mm a").format(booking.dateTime);

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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      booking.serviceName,
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(5.w),
                    ),
                    child: Text(
                      booking.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.2.h),
              Row(
                children: [
                  FaIcon(FontAwesomeIcons.toolbox, size: 13.sp, color: Colors.grey),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      booking.category,
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  FaIcon(FontAwesomeIcons.calendarDay, size: 13.sp, color: Colors.grey),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      formattedDate,
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  FaIcon(FontAwesomeIcons.locationDot, size: 13.sp, color: Colors.grey),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      booking.address,
                      style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  FaIcon(FontAwesomeIcons.user, size: 13.sp, color: Colors.grey),
                  SizedBox(width: 2.w),
                  Text(
                    booking.customerName,
                    style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                  ),
                ],
              ),
              SizedBox(height: 1.5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "₹${booking.price.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                      color: Colors.blue,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showBookingDetails(booking),
                    icon: const FaIcon(FontAwesomeIcons.circleInfo, size: 14),
                    label: const Text("Details"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingDetails(BookingModel booking) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.w),
        ),
        title: Row(
          children: [
            const FaIcon(FontAwesomeIcons.fileInvoice, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                booking.serviceName,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow("Date", DateFormat('dd MMM yyyy, hh:mm a').format(booking.dateTime)),
              _detailRow("Address", booking.address),
              if (booking.secondaryAddress != null && booking.secondaryAddress!.isNotEmpty)
                _detailRow("Landmark", booking.secondaryAddress!),
              _detailRow("Customer", booking.customerName),
              _detailRow("Category", booking.category),
              _detailRow("Price", "₹${booking.price.toStringAsFixed(2)}"),
              _detailRow("Status", booking.status),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}