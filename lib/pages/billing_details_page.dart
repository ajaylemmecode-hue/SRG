import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:new_suvarnraj_group/controller/booking_controller.dart';
import 'package:new_suvarnraj_group/controller/cart_controller.dart';
import 'package:new_suvarnraj_group/controller/home_page_controller.dart';
import 'package:new_suvarnraj_group/models/booking_model.dart';
import 'package:new_suvarnraj_group/services/notification_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BillingDetailsPage extends StatefulWidget {
  final Map<String, dynamic> billingData;

  const BillingDetailsPage({super.key, required this.billingData});

  @override
  State<BillingDetailsPage> createState() => _BillingDetailsPageState();
}

class _BillingDetailsPageState extends State<BillingDetailsPage> {
  // Schedule
  DateTime? bookingDate;
  String? bookingTime;

  // Personal Info Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Address Controllers
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController secondaryAddressController = TextEditingController();

  // Coupon
  final TextEditingController couponController = TextEditingController();
  bool hasCoupon = false;
  double discount = 0.0;
  String appliedCoupon = "";

  // Payment & selections
  String paymentMethod = "PhonePe";
  String? selectedArea;
  final List<String> times = ["09:00 AM", "12:00 PM", "03:00 PM", "06:00 PM"];
  final List<String> areas = ["Downtown", "City Center", "Suburbs", "Others"];
  @override
  void initState() {
    super.initState();
    _loadUserData(); // load saved info when page opens
  }


  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final fullName = prefs.getString("name") ?? "";
    final email = prefs.getString("email") ?? "";
    final phone = prefs.getString("phone") ?? "";

    // Split full name into first and last name automatically
    final parts = fullName.trim().split(' ');
    firstNameController.text = parts.isNotEmpty ? parts.first : "";
    lastNameController.text = parts.length > 1 ? parts.sublist(1).join(' ') : "";

    emailController.text = email;
    phoneController.text = phone;

    setState(() {}); // refresh UI
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    stateController.dispose();
    pinController.dispose();
    secondaryAddressController.dispose();
    couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.billingData["items"] as List<dynamic>;
    final total = (widget.billingData["totalAmount"] as num).toDouble();
    final payable = (total - discount).clamp(0.0, double.infinity);
    final advance = (payable * 0.1).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 1,
              expandedHeight: 12.h,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                title: Row(
                  children: [
                    FaIcon(FontAwesomeIcons.receipt, size: 18.sp, color: Colors.blue),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        "Booking & Billing",
                        style: TextStyle(fontSize: 14.sp, color: Colors.black),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          hasCoupon = false;
                          appliedCoupon = "";
                          discount = 0.0;
                          couponController.clear();
                        });
                        Get.snackbar("Coupon", "Cleared", snackPosition: SnackPosition.BOTTOM);
                      },
                      icon: Icon(Icons.refresh, color: Colors.grey, size: 18.sp),
                    )
                  ],
                ),
                background: Container(color: Colors.white),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(4.w),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ---------------- Booking Schedule ----------------
                  _fancyCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          FaIcon(FontAwesomeIcons.calendarAlt, size: 18.sp, color: Colors.purple),
                          SizedBox(width: 2.w),
                          Text("Booking Schedule", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
                        ]),
                        SizedBox(height: 2.h),
                        _calendarDatePicker(),
                        SizedBox(height: 2.h),
                        _timeDropdown(),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // ---------------- Personal Information ----------------
                  _fancyCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          FaIcon(FontAwesomeIcons.user, size: 18.sp, color: Colors.teal),
                          SizedBox(width: 2.w),
                          Text("Personal Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
                        ]),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: firstNameController,
                                decoration: InputDecoration(
                                  labelText: "First Name *",
                                  prefixIcon: Icon(Icons.person, size: 18.sp),
                                  contentPadding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
                                  labelStyle: TextStyle(fontSize: 12.sp),
                                ),
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: TextField(
                                controller: lastNameController,
                                decoration: InputDecoration(
                                  labelText: "Last Name *",
                                  contentPadding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
                                  labelStyle: TextStyle(fontSize: 12.sp),
                                ),
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email *",
                            prefixIcon: Icon(Icons.email, size: 18.sp),
                            contentPadding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
                            labelStyle: TextStyle(fontSize: 12.sp),
                          ),
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        SizedBox(height: 2.h),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: "Phone *",
                            prefixIcon: Icon(Icons.phone, size: 18.sp),
                            contentPadding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
                            labelStyle: TextStyle(fontSize: 12.sp),
                          ),
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // ---------------- Address Details ----------------
                  _fancyCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          FaIcon(FontAwesomeIcons.mapMarkedAlt, size: 18.sp, color: Colors.red),
                          SizedBox(width: 2.w),
                          Text("Address Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
                        ]),
                        SizedBox(height: 2.h),
                        TextField(
                          controller: cityController,
                          decoration: InputDecoration(
                            labelText: "City *",
                            prefixIcon: Icon(Icons.location_city, size: 18.sp),
                            contentPadding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
                            labelStyle: TextStyle(fontSize: 12.sp),
                          ),
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        SizedBox(height: 2.h),
                        TextField(
                          controller: stateController,
                          decoration: InputDecoration(
                            labelText: "State *",
                            contentPadding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
                            labelStyle: TextStyle(fontSize: 12.sp),
                          ),
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: pinController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Pin *",
                                  contentPadding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
                                  labelStyle: TextStyle(fontSize: 12.sp),
                                ),
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedArea,
                                items: areas.map((a) => DropdownMenuItem(value: a, child: Text(a, style: TextStyle(fontSize: 12.sp)))).toList(),
                                onChanged: (val) => setState(() => selectedArea = val),
                                decoration: InputDecoration(
                                  labelText: "Area *",
                                  contentPadding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
                                  labelStyle: TextStyle(fontSize: 12.sp),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        TextField(
                          controller: secondaryAddressController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: "Secondary Address (Optional)",
                            hintText: "Apartment, Landmark, Floor...",
                            prefixIcon: Icon(Icons.home_outlined, size: 18.sp),
                            contentPadding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
                            labelStyle: TextStyle(fontSize: 12.sp),
                            hintStyle: TextStyle(fontSize: 11.sp),
                          ),
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // ---------------- Coupon Section ----------------
                  _fancyCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          FaIcon(FontAwesomeIcons.tag, size: 18.sp, color: Colors.indigo),
                          SizedBox(width: 2.w),
                          Text("Discount Coupon", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
                        ]),
                        SizedBox(height: 1.h),
                        CheckboxListTile(
                          value: hasCoupon,
                          onChanged: (val) {
                            setState(() {
                              hasCoupon = val ?? false;
                              if (!hasCoupon) {
                                discount = 0.0;
                                appliedCoupon = "";
                                couponController.clear();
                              }
                            });
                          },
                          title: Text("I have a discount coupon", style: TextStyle(fontSize: 12.sp)),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (hasCoupon)
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: couponController,
                                  decoration: InputDecoration(
                                    hintText: "Enter coupon code",
                                    contentPadding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
                                    hintStyle: TextStyle(fontSize: 12.sp),
                                  ),
                                  style: TextStyle(fontSize: 12.sp),
                                ),
                              ),
                              SizedBox(width: 2.w),
                              ElevatedButton.icon(
                                icon: FaIcon(FontAwesomeIcons.check, size: 14.sp, color: Colors.white),
                                label: Text("Apply", style: TextStyle(fontSize: 12.sp, color: Colors.white)),
                                onPressed: () => _applyCoupon(total),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 3.w),
                                ),
                              ),
                            ],
                          ),
                        if (appliedCoupon.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 1.h),
                            child: Text("Applied: $appliedCoupon - Saved ₹${discount.toStringAsFixed(0)}",
                                style: TextStyle(color: Colors.green, fontSize: 12.sp)),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // ---------------- Order Summary ----------------
                  _fancyCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          FaIcon(FontAwesomeIcons.shoppingCart, size: 18.sp, color: Colors.orange),
                          SizedBox(width: 2.w),
                          Text("Order Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
                        ]),
                        SizedBox(height: 2.h),
                        ...items.map((item) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 0.5.h),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text("${item['title']} × ${item['quantity']}", style: TextStyle(fontSize: 12.sp)),
                              ),
                              Text("₹${item['price'] * item['quantity']}",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
                            ],
                          ),
                        )),
                        Divider(thickness: 0.2.h),
                        _summaryRow("Subtotal", "₹$total"),
                        _summaryRow("Discount", "- ₹${discount.toStringAsFixed(0)}"),
                        _summaryRow("Commuting Charge", "₹0"),
                        Divider(thickness: 0.2.h),
                        _summaryRowBold("Final Amount", "₹${payable.toStringAsFixed(0)}"),
                        SizedBox(height: 1.h),
                        Text("Advance (10%): ₹$advance", style: TextStyle(color: Colors.green[700], fontSize: 12.sp)),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // ---------------- Payment Method ----------------
                  _fancyCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          FaIcon(FontAwesomeIcons.moneyCheckAlt, size: 18.sp, color: Colors.brown),
                          SizedBox(width: 2.w),
                          Text("Payment Method", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
                        ]),
                        SizedBox(height: 1.h),
                        RadioListTile<String>(
                          value: "PhonePe",
                          groupValue: paymentMethod,
                          onChanged: (val) => setState(() => paymentMethod = val ?? paymentMethod),
                          title: Text("PhonePe (UPI / Card / Netbanking)", style: TextStyle(fontSize: 12.sp)),
                          secondary: FaIcon(FontAwesomeIcons.mobileAlt, size: 16.sp),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // ---------------- Buttons ----------------
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.w)),
                          ),
                          onPressed: () => _placeOrder(context, isAdvance: false, total: payable),
                          child: Text("Pay Full • ₹${payable.toStringAsFixed(0)}",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: Colors.white)),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.w)),
                          ),
                          onPressed: () => _placeOrder(context, isAdvance: true, total: payable),
                          child: Text("Pay Advance • ₹$advance",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- UI Helpers ----------------
  Widget _fancyCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2.w),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4.sp, offset: Offset(0, 2.sp))],
      ),
      padding: EdgeInsets.all(3.w),
      child: child,
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(children: [
        Expanded(child: Text(label, style: TextStyle(fontSize: 12.sp))),
        Text(value, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12.sp)),
      ]),
    );
  }

  Widget _summaryRowBold(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(children: [
        Expanded(child: Text(label, style: TextStyle(fontSize: 12.sp))),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
      ]),
    );
  }

  Widget _calendarDatePicker() {
    final bookingController = Get.find<BookingController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    // Responsive fonts
    final headerFontSize = isTablet ? 16.sp : 18.sp;
    final weekFontSize = isTablet ? 12.sp : 12.sp;
    final dayFontSize = isTablet ? 12.sp : 13.sp;

    return Column(
      children: [
        // Card around the calendar
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade50,
                Colors.white,
              ],
            ),
            borderRadius: BorderRadius.circular(2.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4.sp,
                offset: Offset(0, 2.sp),
              ),
            ],
          ),
          padding: EdgeInsets.all(3.w),
          child: TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime(DateTime.now().year + 2),
            focusedDay: bookingDate ?? DateTime.now(),
            selectedDayPredicate: (day) =>
            bookingDate != null && isSameDay(bookingDate, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (bookingController.isDateFull(selectedDay)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("⚠️ This date is already full"),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                setState(() => bookingDate = selectedDay);
              }
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: headerFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[900],
              ),
              leftChevronIcon: Icon(Icons.chevron_left,
                  size: headerFontSize, color: Colors.blueGrey[900]),
              rightChevronIcon: Icon(Icons.chevron_right,
                  size: headerFontSize, color: Colors.blueGrey[900]),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                fontSize: weekFontSize,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              weekendStyle: TextStyle(
                fontSize: weekFontSize,
                fontWeight: FontWeight.w500,
                color: Colors.redAccent,
              ),
            ),

            // ✅ Fixed: no borderRadius with circle shape
            calendarStyle: CalendarStyle(
              cellMargin: EdgeInsets.all(screenWidth * 0.008),
              defaultTextStyle: TextStyle(fontSize: dayFontSize),
              weekendTextStyle:
              TextStyle(fontSize: dayFontSize, color: Colors.red),
              selectedDecoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                ),
              ),
              todayDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade300),
              ),
            ),

            calendarBuilders: CalendarBuilders(
              selectedBuilder: (context, day, focusedDay) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                    ),
                  ),
                  child: Text(
                    "${day.day}",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: dayFontSize,
                    ),
                  ),
                );
              },
              todayBuilder: (context, day, focusedDay) {
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue.shade300),
                  ),
                  child: Text(
                    "${day.day}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: dayFontSize),
                  ),
                );
              },
              markerBuilder: (context, date, events) {
                if (bookingController.isDateFull(date)) {
                  return Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
        ),
        SizedBox(height: 1.h),

        // ✅ Legend row
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _legendItem(color: Colors.blue, text: "Selected"),
              _legendItem(color: Colors.red, text: "Full"),
              _legendItem(color: Colors.blue.shade50, text: "Today"),
            ],
          ),
        ),
      ],
    );
  }


  Widget _legendItem({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 1.w),
        Text(text, style: TextStyle(fontSize: 9.sp)),
      ],
    );
  }


  Widget _timeDropdown() {
    return DropdownButtonFormField<String>(
      value: bookingTime,
      items: times.map((t) => DropdownMenuItem(value: t, child: Text(t, style: TextStyle(fontSize: 12.sp)))).toList(),
      onChanged: (val) => setState(() => bookingTime = val),
      decoration: InputDecoration(
        labelText: "Select Time *",
        prefixIcon: Icon(Icons.access_time, size: 18.sp),
        contentPadding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
        labelStyle: TextStyle(fontSize: 12.sp),
      ),
    );
  }

  // ---------------- Logic ----------------
  void _applyCoupon(double total) {
    final enteredCode = couponController.text.trim().toUpperCase();
    final coupons = {"KITCHEN25": 0.25, "CLEAN20": 0.20, "WELCOME30": 0.30};

    if (enteredCode.isEmpty) {
      Get.snackbar("Coupon", "Please enter a coupon code", snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (coupons.containsKey(enteredCode)) {
      setState(() {
        appliedCoupon = enteredCode;
        discount = total * coupons[enteredCode]!;
      });
      Get.snackbar("Success", "Coupon $enteredCode applied! 🎉", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.shade100);
    } else {
      setState(() {
        appliedCoupon = "";
        discount = 0.0;
      });
      Get.snackbar("Invalid Coupon", "Please enter a valid coupon ❌", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
    }
  }

  void _placeOrder(BuildContext context, {required bool isAdvance, required double total}) {
    if (bookingDate == null || bookingTime == null || firstNameController.text.isEmpty || lastNameController.text.isEmpty || emailController.text.isEmpty || phoneController.text.isEmpty || cityController.text.isEmpty || stateController.text.isEmpty || pinController.text.isEmpty || selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("⚠️ Please fill all required fields")));
      return;
    }

    final bookingController = Get.find<BookingController>();
    if (bookingController.isDateFull(bookingDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("⚠️ This date is full, please select another date")));
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("⚠️ Please enter a valid Email ID")));
      return;
    }

    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("⚠️ Please enter a valid 10-digit Mobile Number")));
      return;
    }

    final items = widget.billingData["items"] as List<dynamic>;
    final cartController = Get.find<CartController>();

    for (var item in items) {
      final itemTotal = item['price'] * item['quantity'];
      final price = isAdvance ? (itemTotal * 0.1).toInt() : itemTotal;

      final booking = BookingModel(
        id: "BK${Random().nextInt(1000).toString().padLeft(3, '0')}",
        serviceName: item['title'],
        category: "Furnished Flats",
        dateTime: bookingDate!,
        address: "${cityController.text}, ${stateController.text}, ${selectedArea ?? ''}",
        secondaryAddress: secondaryAddressController.text.isNotEmpty ? secondaryAddressController.text : null,
        customerName: "${firstNameController.text} ${lastNameController.text}",
        price: price,
        status: "Confirmed",
      );

      bookingController.addBooking(booking);

      NotificationService.showNotification(
        id: Random().nextInt(100000),
        title: "Booking Confirmed",
        body: "${booking.serviceName} on ${booking.dateTime.day}-${booking.dateTime.month}-${booking.dateTime.year} at $bookingTime",
        payload: "booking:${booking.id}",
      );
    }

    cartController.cartItems.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/animations/success_gif.json', width: 40.w, height: 40.w, repeat: false),
            SizedBox(height: 2.h),
            Text(isAdvance ? "Advance Payment Successful!" : "Full Payment Successful!", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop();
      Get.find<HomePageController>().changeTab(2);
      Get.snackbar("Success", isAdvance ? "Order placed with Advance Payment" : "Order placed with Full Payment", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.shade100);
    });
  }
}