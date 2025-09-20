import 'package:flutter/material.dart';
import '../data/donation_data.dart';
import '../models/donation.dart';

class UserDonationPage extends StatefulWidget {
  final String userName;
  final String userContact;
  final String userAddress;

  const UserDonationPage({
    super.key,
    required this.userName,
    required this.userContact,
    required this.userAddress,
  });

  @override
  State<UserDonationPage> createState() => _UserDonationPageState();
}

class _UserDonationPageState extends State<UserDonationPage> {
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _itemController = TextEditingController();
  final _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill with user info but editable
    _nameController.text = widget.userName;
    _contactController.text = widget.userContact;
    _addressController.text = widget.userAddress;
  }

  void _submitDonation() {
    if (_nameController.text.isEmpty ||
        _contactController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _itemController.text.isEmpty ||
        _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() {
      donationsList.add(
        Donation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          donorName: _nameController.text,
          contact: _contactController.text,
          address: _addressController.text,
          item: _itemController.text,
          quantity: int.tryParse(_quantityController.text) ?? 0,
          date: DateTime.now(),
          isApproved: false,
          status: "Pending",
        ),
      );
    });

    // clear only product fields
    _itemController.clear();
    _quantityController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Donation submitted! Waiting for admin approval.")),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Approved":
        return Colors.blue;
      case "On the way":
        return Colors.teal;
      case "Delivered":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // User-specific donations
    final userDonations = donationsList
        .where((d) =>
            d.donorName == widget.userName &&
            d.contact == widget.userContact)
        .toList();

    // All delivered donations (public view)
    final deliveredDonations =
        donationsList.where((d) => d.status == "Delivered").toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Donate a Product")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ---------- Donation Form ----------
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Your Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: "Contact Number / Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _itemController,
                decoration: const InputDecoration(
                  labelText: "Item",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: "Quantity",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitDonation,
                  child: const Text("Donate"),
                ),
              ),
              const SizedBox(height: 30),

              // ---------- User Donations ----------
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Your Donations",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              userDonations.isEmpty
                  ? const Text(
                      "No donations yet",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: userDonations.length,
                      itemBuilder: (context, index) {
                        final donation = userDonations[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              donation.item,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Quantity: ${donation.quantity}"),
                                Text(
                                  "Status: ${donation.status}",
                                  style: TextStyle(
                                    color: _statusColor(donation.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 30),

              // ---------- Public Delivered Donations ----------
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Delivered Donations (Public List)",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              deliveredDonations.isEmpty
                  ? const Text(
                      "No donations delivered yet",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: deliveredDonations.length,
                      itemBuilder: (context, index) {
                        final donation = deliveredDonations[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              donation.item,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            subtitle: Text("Quantity: ${donation.quantity}"),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
