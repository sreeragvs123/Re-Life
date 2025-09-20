import 'package:flutter/material.dart';
import '../data/donation_data.dart';
import '../models/donation.dart';

class AdminDonationPage extends StatefulWidget {
  const AdminDonationPage({super.key});

  @override
  State<AdminDonationPage> createState() => _AdminDonationPageState();
}

class _AdminDonationPageState extends State<AdminDonationPage> {
  void _approveDonation(Donation donation) {
    setState(() {
      donation.isApproved = true;
      donation.status = "Pending";
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Donation approved")));
  }

  void _rejectDonation(Donation donation) {
    setState(() {
      donationsList.remove(donation);
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Donation rejected")));
  }

  @override
  Widget build(BuildContext context) {
    final pendingDonations =
        donationsList.where((d) => !d.isApproved).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Admin: Approve Donations")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: pendingDonations.isEmpty
            ? const Center(
                child: Text(
                  "No pending donations",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: pendingDonations.length,
                itemBuilder: (context, index) {
                  final donation = pendingDonations[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            donation.item,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text("Quantity: ${donation.quantity}"),
                          const SizedBox(height: 4),
                          Text("Donor: ${donation.donorName}"),
                          Text("Contact: ${donation.contact}"),
                          Text("Address: ${donation.address ?? "N/A"}"),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () => _approveDonation(donation),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: const Text("Approve"),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _rejectDonation(donation),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text("Reject"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
