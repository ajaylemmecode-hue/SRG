// enquiry_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/api_contact.dart';
import '../models/contact_model.dart';

class EnquiryController extends GetxController {
  // Controllers
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final areaCtrl = TextEditingController();
  final messageCtrl = TextEditingController();

  // State
  var selectedService = "Choose Service".obs;
  var selectedDate = Rxn<DateTime>();
  var selectedTime = Rxn<TimeOfDay>();
  var orderInspection = false.obs;

  final List<String> services = [
    "Choose Service",
    "Bungalows Cleaning",
    "Offices Cleaning",
    "Societies Cleaning",
    "Restaurant Cleaning",
    "Shops Cleaning",
    "School/College Cleaning"
  ];

  // Submit enquiry
  Future<Map<String, dynamic>> submitEnquiry() async {
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();

    if (name.isEmpty || email.isEmpty) {
      return {"status": false, "message": "Name and Email are required"};
    }

    final contact = Contact(
      firstName: name,
      email: email,
      mobile: mobileCtrl.text.trim(),
      address: addressCtrl.text.trim(),
      state: stateCtrl.text.trim(),
      city: cityCtrl.text.trim(),
      service: selectedService.value,
      area: areaCtrl.text.trim(),
      date: selectedDate.value?.toIso8601String(),
      time: selectedTime.value?.format(Get.context!),
      orderInspection: orderInspection.value ? "1" : "0",
      message: messageCtrl.text.trim(),
    );

    final res = await ApiContact.submitContact(contact);
    return res;
  }

  // ✅ Correct return type
  Future<Object> getHistory() async {
    final email = emailCtrl.text.trim();
    if (email.isEmpty) return [];
    final history = await ApiContact.getHistory(email);
    return history;
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    mobileCtrl.dispose();
    addressCtrl.dispose();
    stateCtrl.dispose();
    cityCtrl.dispose();
    areaCtrl.dispose();
    messageCtrl.dispose();
    super.onClose();
  }
}
