class Donation {
  final String id;
  final String donorName;
  final String contact;
  final String address;
  final String item;
  final int quantity;
  final DateTime date;
  bool isApproved;
  String status;

  Donation({
    required this.id,
    required this.donorName,
    required this.contact,
    required this.address,
    required this.item,
    required this.quantity,
    required this.date,
    this.isApproved = false,
    this.status = "Pending",
  });
}
