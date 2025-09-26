import 'package:flutter/material.dart';
import '../api/api_contact.dart';
import '../models/contact_model.dart';

class HistoryPage extends StatefulWidget {
  final String email;
  const HistoryPage({super.key, required this.email});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<ContactHistory>> _futureHistory;

  @override
  void initState() {
    super.initState();
    _futureHistory = ApiContact.getHistory(widget.email) as Future<List<ContactHistory>>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enquiry History"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<ContactHistory>>(
        future: _futureHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No history found"),
            );
          }

          final historyList = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final item = historyList[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Name: ${item.firstName ?? '-'}",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text("Email: ${item.email ?? '-'}"),
                      Text("Mobile: ${item.mobile ?? '-'}"),
                      Text("Service: ${item.service ?? '-'}"),
                      Text("City: ${item.city ?? '-'}"),
                      Text("State: ${item.state ?? '-'}"),
                      Text("Area: ${item.area ?? '-'}"),
                      Text("Date: ${item.date ?? '-'}"),
                      Text("Time: ${item.time ?? '-'}"),
                      Text("Inspection: ${item.orderInspection == '1' ? "Yes" : "No"}"),
                      const SizedBox(height: 6),
                      Text("Message: ${item.message ?? '-'}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
