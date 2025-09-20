class Donation {
  final String id;
  final String donorName;
  final String contact;
  final String item;
  final int quantity;
  final String? address;
  DateTime date;
  bool isApproved;
  String status;

  Donation({
    required this.id,
    required this.donorName,
    required this.contact,
    required this.item,
    required this.quantity,
    this.address,
    required this.date,
    this.isApproved = false,
    this.status = "Pending",
  });
}
