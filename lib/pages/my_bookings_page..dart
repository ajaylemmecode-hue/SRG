import 'package:flutter/material.dart';
import 'package:new_suvarnraj_group/pages/tabs/bookings_tab.dart';
import 'package:sizer/sizer.dart';

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings', style: TextStyle(fontSize: 16.sp)),
        centerTitle: true,
      ),
      body: BookingsTab(),
    );
  }
}