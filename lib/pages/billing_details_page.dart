import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:new_suvarnraj_group/controller/booking_controller.dart';
import 'package:new_suvarnraj_group/controller/cart_controller.dart';
import 'package:new_suvarnraj_group/controller/home_page_controller.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../api/api_service.dart';

class BillingDetailsPage extends StatefulWidget {
  final Map<String, dynamic> billingData;
  const BillingDetailsPage({super.key, required this.billingData});

  @override
  State<BillingDetailsPage> createState() => _BillingDetailsPageState();
}

class _BillingDetailsPageState extends State<BillingDetailsPage> {
  DateTime? bookingDate;
  String? bookingTime;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController secondaryAddressController = TextEditingController();
  final TextEditingController couponController = TextEditingController();

  bool hasCoupon = false;
  double discount = 0.0;
  String appliedCoupon = "";
  String paymentMethod = "cod";
  String? selectedArea;
  int? selectedCityId;
  String? selectedCityName;

  bool _isProcessing = false;
  bool _citiesLoading = true;
  List<Map<String, dynamic>> cities = [];

  final List<String> times = ["09:00 AM", "12:00 PM", "03:00 PM", "06:00 PM"];
  final List<String> areas = ["Downtown", "City Center", "Suburbs", "Others"];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchCities();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fullName = prefs.getString("name") ?? "";
      final email = prefs.getString("email") ?? "";
      final phone = prefs.getString("phone") ?? "";

      final parts = fullName.trim().split(' ');
      firstNameController.text = parts.isNotEmpty ? parts.first : "";
      lastNameController.text = parts.length > 1 ? parts.sublist(1).join(' ') : "";
      emailController.text = email;
      phoneController.text = phone;
      setState(() {});
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _fetchCities() async {
    try {
      setState(() => _citiesLoading = true);
      final response = await ApiService.fetchCheckoutData();

      if (response['data'] != null && response['data']['cities'] != null) {
        final fetchedCities = response['data']['cities'] as List<dynamic>;
        setState(() {
          cities = fetchedCities.map((c) {
            return {
              'id': c['id'] as int? ?? 0,
              'name': c['name'] as String? ?? 'Unknown',
            };
          }).toList();
          _citiesLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching cities: $e');
      setState(() => _citiesLoading = false);
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
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
                      child: Text("Booking & Billing", style: TextStyle(fontSize: 14.sp, color: Colors.black)),
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
                  _buildBookingScheduleCard(),
                  SizedBox(height: 2.h),
                  _buildPersonalInfoCard(),
                  SizedBox(height: 2.h),
                  _buildAddressDetailsCard(),
                  SizedBox(height: 2.h),
                  _buildCouponCard(total),
                  SizedBox(height: 2.h),
                  _buildOrderSummaryCard(items, total, payable, advance),
                  SizedBox(height: 2.h),
                  _buildPaymentMethodCard(),
                  SizedBox(height: 2.h),
                  _buildConfirmButton(payable),
                  SizedBox(height: 3.h),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingScheduleCard() {
    return _fancyCard(
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
    );
  }

  Widget _buildPersonalInfoCard() {
    return _fancyCard(
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
                child: _buildTextField("First Name *", firstNameController, Icons.person),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildTextField("Last Name *", lastNameController, null),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildTextField("Email *", emailController, Icons.email, TextInputType.emailAddress, null),
          SizedBox(height: 2.h),
          _buildTextField("Phone *", phoneController, Icons.phone, TextInputType.phone, 10),
        ],
      ),
    );
  }

  Widget _buildAddressDetailsCard() {
    return _fancyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            FaIcon(FontAwesomeIcons.mapMarkedAlt, size: 18.sp, color: Colors.red),
            SizedBox(width: 2.w),
            Text("Address Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
          ]),
          SizedBox(height: 2.h),
          if (_citiesLoading)
            SizedBox(height: 5.h, child: Center(child: CircularProgressIndicator()))
          else if (cities.isEmpty)
            Text("No cities available", style: TextStyle(color: Colors.red, fontSize: 12.sp))
          else
            DropdownButtonFormField<int>(
              value: selectedCityId,
              items: cities.map((city) {
                return DropdownMenuItem<int>(
                  value: city['id'],
                  child: Text(city['name'], style: TextStyle(fontSize: 12.sp)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  final city = cities.firstWhere((c) => c['id'] == val);
                  setState(() {
                    selectedCityId = val;
                    selectedCityName = city['name'];
                  });
                }
              },
              decoration: InputDecoration(
                labelText: "City *",
                prefixIcon: Icon(Icons.location_city, size: 18.sp),
                contentPadding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
                labelStyle: TextStyle(fontSize: 12.sp),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(2.w)),
              ),
            ),
          SizedBox(height: 2.h),
          _buildTextField("State *", stateController, null),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildTextField("Pin *", pinController, null, TextInputType.number, 6),
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(2.w)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildTextField("Secondary Address", secondaryAddressController, Icons.home_outlined, TextInputType.text, null, 2),
        ],
      ),
    );
  }

  Widget _buildCouponCard(double total) {
    return _fancyCard(
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
                  child: _buildTextField("Coupon Code", couponController, null),
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
                  style: TextStyle(color: Colors.green, fontSize: 12.sp, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(List<dynamic> items, double total, double payable, int advance) {
    return _fancyCard(
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
                Text("₹${(item['price'] * item['quantity']).toStringAsFixed(0)}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
              ],
            ),
          )),
          Divider(thickness: 0.2.h),
          _summaryRow("Subtotal", "₹${total.toStringAsFixed(0)}"),
          _summaryRow("Discount", "- ₹${discount.toStringAsFixed(0)}"),
          _summaryRow("Commuting Charge", "₹0"),
          Divider(thickness: 0.2.h),
          _summaryRowBold("Final Amount", "₹${payable.toStringAsFixed(0)}"),
          SizedBox(height: 1.h),
          Text("Advance (10%): ₹$advance", style: TextStyle(color: Colors.green[700], fontSize: 12.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return _fancyCard(
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
            value: "cod",
            groupValue: paymentMethod,
            onChanged: (val) => setState(() => paymentMethod = val ?? "cod"),
            title: Text("Cash on Delivery (COD)", style: TextStyle(fontSize: 12.sp)),
            secondary: FaIcon(FontAwesomeIcons.moneyBillWave, size: 16.sp),
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<String>(
            value: "advance",
            groupValue: paymentMethod,
            onChanged: (val) => setState(() => paymentMethod = val ?? "advance"),
            title: Text("Pay 10% Advance", style: TextStyle(fontSize: 12.sp)),
            secondary: FaIcon(FontAwesomeIcons.handHoldingUsd, size: 16.sp),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(double payable) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(vertical: 1.8.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.w)),
        ),
        onPressed: _isProcessing ? null : () => _placeOrder(payable),
        child: Text("Confirm Booking • ₹${payable.toStringAsFixed(0)}",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: Colors.white)),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      IconData? icon, [
        TextInputType type = TextInputType.text,
        int? maxLength,
        int maxLines = 1,
      ]) {
    return TextField(
      controller: controller,
      keyboardType: type,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 18.sp) : null,
        contentPadding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
        labelStyle: TextStyle(fontSize: 12.sp),
        counterText: "",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(2.w)),
      ),
      style: TextStyle(fontSize: 12.sp),
    );
  }

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
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: Colors.blue)),
      ]),
    );
  }

  Widget _calendarDatePicker() {
    try {
      final bookingController = Get.find<BookingController>();
      return Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade50, Colors.white],
              ),
              borderRadius: BorderRadius.circular(2.w),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4.sp, offset: Offset(0, 2.sp))],
            ),
            padding: EdgeInsets.all(3.w),
            child: TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime(DateTime.now().year + 2),
              focusedDay: bookingDate ?? DateTime.now(),
              selectedDayPredicate: (day) => bookingDate != null && isSameDay(bookingDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                if (bookingController.isDateFull(selectedDay)) {
                  _showError("This date is already full");
                } else {
                  setState(() => bookingDate = selectedDay);
                }
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)]),
                ),
                todayDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade300),
                ),
              ),
            ),
          ),
          SizedBox(height: 1.h),
        ],
      );
    } catch (e) {
      return Text("Error loading calendar: $e");
    }
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(2.w)),
      ),
    );
  }

  void _applyCoupon(double total) {
    final enteredCode = couponController.text.trim().toUpperCase();
    final coupons = {"KITCHEN25": 0.25, "CLEAN20": 0.20, "WELCOME30": 0.30};

    if (enteredCode.isEmpty) {
      _showError("Please enter a coupon code");
      return;
    }

    if (coupons.containsKey(enteredCode)) {
      setState(() {
        appliedCoupon = enteredCode;
        discount = total * coupons[enteredCode]!;
      });
      Get.snackbar("Success", "Coupon applied! Saved ₹${discount.toStringAsFixed(0)}",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.shade100);
    } else {
      setState(() {
        appliedCoupon = "";
        discount = 0.0;
      });
      _showError("Invalid coupon code");
    }
  }

  void _placeOrder(double total) async {
    if (_isProcessing) return;

    if (!_validateForm()) return;

    try {
      setState(() => _isProcessing = true);
      Get.dialog(Center(child: CircularProgressIndicator(strokeWidth: 3)), barrierDismissible: false);

      final timeOnly = bookingTime!.split(' ')[0];
      final formattedDate = DateFormat('yyyy-MM-dd').format(bookingDate!);
      final items = widget.billingData["items"] as List<dynamic>;
      final List<Map<String, dynamic>> apiItems = [];

      for (var item in items) {
        if (item['id'] == null) {
          Get.back();
          _showError("Product ID missing");
          setState(() => _isProcessing = false);
          return;
        }
        apiItems.add({
          "product_id": item['id'],
          "qty": item['quantity'],
          "price": item['price'],
        });
      }

      final response = await ApiService.placeGuestOrder(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        mobile: phoneController.text.trim(),
        address: stateController.text.trim(),
        apartment: secondaryAddressController.text.trim().isNotEmpty ? secondaryAddressController.text.trim() : null,
        state: stateController.text.trim(),
        cityId: selectedCityId!,
        zip: pinController.text.trim(),
        notes: "Booked via mobile app",
        countryId: 1,
        bookingDate: formattedDate,
        bookingTime: timeOnly,
        bookingType: "standard",
        paymentMethod: paymentMethod,
        items: apiItems,
      );

      Get.back();

      final orderId = response['data']['order_id'] ?? 'N/A';
      Get.find<CartController>().clearCart();
      await Get.find<BookingController>().fetchBookings();

      _showSuccessDialog(orderId);
    } catch (e) {
      Get.back();
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      _showError(errorMsg);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  bool _validateForm() {
    if (bookingDate == null) return _showErrorBool("Select booking date");
    if (bookingTime == null) return _showErrorBool("Select booking time");
    if (firstNameController.text.trim().isEmpty) return _showErrorBool("Enter first name");
    if (lastNameController.text.trim().isEmpty) return _showErrorBool("Enter last name");
    if (emailController.text.trim().isEmpty) return _showErrorBool("Enter email");
    if (phoneController.text.trim().isEmpty) return _showErrorBool("Enter phone");
    if (stateController.text.trim().isEmpty) return _showErrorBool("Enter state");
    if (pinController.text.trim().isEmpty) return _showErrorBool("Enter pin");
    if (selectedCityId == null) return _showErrorBool("Select city");
    if (selectedArea == null) return _showErrorBool("Select area");

    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(emailController.text.trim())) {
      return _showErrorBool("Invalid email");
    }

    if (!RegExp(r'^[0-9]{10}$').hasMatch(phoneController.text.trim())) {
      return _showErrorBool("Phone must be 10 digits");
    }

    if (pinController.text.trim().length != 6) {
      return _showErrorBool("Pin must be 6 digits");
    }

    return true;
  }

  bool _showErrorBool(String msg) {
    _showError(msg);
    return false;
  }

  void _showError(String message) {
    Get.snackbar("Error", message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red[900],
        duration: Duration(seconds: 3));
  }

  void _showSuccessDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.w),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8.sp)],
          ),
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                padding: EdgeInsets.all(3.w),
                child: Icon(Icons.check, color: Colors.white, size: 30.sp),
              ),
              SizedBox(height: 2.h),
              Text("Order Placed Successfully! ✅",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.green[700]),
              ),
              SizedBox(height: 1.h),
              Text("Order ID: $orderId", style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );

    Future.delayed(Duration(seconds: 3), () {
      if (context.mounted) Navigator.of(context).pop();
      Get.find<HomePageController>().changeTab(2);
    });
  }
}