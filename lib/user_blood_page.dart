// lib/user_blood_page.dart
import 'package:flutter/material.dart';
import '../models/blood_request.dart';
import '../data/blood_request_data.dart';

class UserBloodPage extends StatelessWidget {
  const UserBloodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Blood Donation Requests"),
          backgroundColor: Colors.red.shade700),
      body: bloodRequests.isEmpty // The List containg the data
          ? const Center(child: Text("No blood requests yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: bloodRequests.length,// The list that stores predefines blood request . The Model BloodRequest  which containg the important variables and the intialzer method are used in the list elements
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
                  ),
                );
              },
            ),
    );
  }
}
