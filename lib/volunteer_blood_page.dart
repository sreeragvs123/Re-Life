// lib/volunteer_blood_page.dart
import 'package:flutter/material.dart';
import '../models/blood_request.dart';
import '../data/blood_request_data.dart';
import 'add_blood_request_page.dart';

class VolunteerBloodPage extends StatefulWidget {
  const VolunteerBloodPage({super.key});

  @override
  State<VolunteerBloodPage> createState() => _VolunteerBloodPageState();
}

class _VolunteerBloodPageState extends State<VolunteerBloodPage> {
  void _deleteRequest(String id) {
    setState(() {
      bloodRequests.removeWhere((r) => r.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Blood Donation Requests"),
          backgroundColor: Colors.red.shade700),
      body: bloodRequests.isEmpty
          ? const Center(child: Text("No blood requests yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: bloodRequests.length,
              itemBuilder: (context, index) {
                final request = bloodRequests[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text("${request.name} (${request.bloodGroup})",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Contact: ${request.contact}"),
                        Text("City: ${request.city}"),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteRequest(request.id),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red.shade700,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AddBloodRequestPage()));
          setState(() {});
        },
      ),
    );
  }
}
