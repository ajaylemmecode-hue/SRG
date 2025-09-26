import 'package:flutter/material.dart';
import '../api/api_contact.dart';
import '../models/contact_model.dart';
import 'history_page.dart';

class EnquiryFormPage extends StatefulWidget {
  final String serviceName;
  const EnquiryFormPage({super.key, required this.serviceName});

  @override
  State<EnquiryFormPage> createState() => _EnquiryFormPageState();
}

class _EnquiryFormPageState extends State<EnquiryFormPage> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController mobileCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController stateCtrl = TextEditingController();
  final TextEditingController cityCtrl = TextEditingController();
  final TextEditingController areaCtrl = TextEditingController();
  final TextEditingController messageCtrl = TextEditingController();

  String? selectedService;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool orderInspection = false;

  final List<String> services = [
    "Choose Service",
    "Bungalows Cleaning",
    "Offices Cleaning",
    "Societies Cleaning",
    "Restaurant Cleaning",
    "Shops Cleaning",
    "School/College Cleaning"
  ];

  @override
  void initState() {
    super.initState();
    selectedService = services.contains(widget.serviceName)
        ? widget.serviceName
        : services[0];
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    mobileCtrl.dispose();
    addressCtrl.dispose();
    stateCtrl.dispose();
    cityCtrl.dispose();
    areaCtrl.dispose();
    messageCtrl.dispose();
    super.dispose();
  }

  // ------------------- POPUP -------------------
  void _showPopup(String msg, {bool success = true}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: success ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  // ------------------- SUBMIT -------------------
  Future<void> _submitEnquiry() async {
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();

    if (name.isEmpty || email.isEmpty) {
      _showPopup("Name and Email are required", success: false);
      return;
    }

    final contact = Contact(
      firstName: name,
      email: email,
      mobile: mobileCtrl.text.trim(),
      address: addressCtrl.text.trim(),
      state: stateCtrl.text.trim(),
      city: cityCtrl.text.trim(),
      service: selectedService ?? '',
      area: areaCtrl.text.trim(),
      date: selectedDate?.toIso8601String(),
      time: selectedTime?.format(context),
      orderInspection: orderInspection ? "1" : "0",
      message: messageCtrl.text.trim(),
    );

    final res = await ApiContact.submitContact(contact);
    _showPopup(res["message"], success: res["status"] == true);
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.blue),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit an Enquiry"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              if (emailCtrl.text.isEmpty) {
                _showPopup("Enter email to view history", success: false);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HistoryPage(email: emailCtrl.text),
                  ),
                );
              }
            },
            icon: const Icon(Icons.history),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: _inputDecoration("Name")),
            const SizedBox(height: 12),
            TextField(controller: emailCtrl, decoration: _inputDecoration("Email")),
            const SizedBox(height: 12),
            TextField(controller: mobileCtrl, decoration: _inputDecoration("Mobile")),
            const SizedBox(height: 12),
            TextField(controller: addressCtrl, decoration: _inputDecoration("Address")),
            const SizedBox(height: 12),
            TextField(controller: stateCtrl, decoration: _inputDecoration("State")),
            const SizedBox(height: 12),
            TextField(controller: cityCtrl, decoration: _inputDecoration("City")),
            const SizedBox(height: 12),
            TextField(controller: areaCtrl, decoration: _inputDecoration("Area")),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedService,
              items: services.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => selectedService = val),
              decoration: _inputDecoration("Service"),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate == null
                        ? "Select Date"
                        : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => selectedDate = picked);
                  },
                  child: const Text("Pick Date"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedTime == null
                        ? "Select Time"
                        : selectedTime!.format(context),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) setState(() => selectedTime = picked);
                  },
                  child: const Text("Pick Time"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageCtrl,
              maxLines: 3,
              decoration: _inputDecoration("Message"),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: orderInspection,
              onChanged: (val) => setState(() => orderInspection = val ?? false),
              title: const Text("Order Inspection"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitEnquiry,
              child: const Text("Submit Enquiry"),
            ),
          ],
        ),
      ),
    );
  }
}
