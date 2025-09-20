import 'package:flutter/material.dart';
import '../models/donation.dart';

class DonationTable extends StatelessWidget {
  final List<Donation> donations;
  final bool showAction; // Admin or Volunteer action buttons
  final void Function(Donation, String)? onAction; // status update or approve/reject

  const DonationTable({
    super.key,
    required this.donations,
    this.showAction = false,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text("Donor")),
          DataColumn(label: Text("Contact")),
          DataColumn(label: Text("Item")),
          DataColumn(label: Text("Qty")),
          DataColumn(label: Text("Status")),
          DataColumn(label: Text("Action")),
        ],
        rows: donations.map((donation) {
          return DataRow(
            cells: [
              DataCell(Text(donation.donorName)),
              DataCell(Text(donation.contact)),
              DataCell(Text(donation.item)),
              DataCell(Text(donation.quantity.toString())),
              DataCell(Text(donation.status)),
              DataCell(showAction
                  ? PopupMenuButton<String>(
                      onSelected: (value) {
                        if (onAction != null) onAction!(donation, value);
                      },
                      itemBuilder: (_) => donation.isApproved
                          ? const [
                              PopupMenuItem(value: "Ongoing", child: Text("Ongoing")),
                              PopupMenuItem(value: "Delivered", child: Text("Delivered")),
                              PopupMenuItem(value: "Received", child: Text("Received")),
                            ]
                          : const [
                              PopupMenuItem(value: "Approve", child: Text("Approve")),
                              PopupMenuItem(value: "Reject", child: Text("Reject")),
                            ],
                      child: const Icon(Icons.edit),
                    )
                  : const SizedBox.shrink()),
            ],
          );
        }).toList(),
      ),
    );
  }
}
