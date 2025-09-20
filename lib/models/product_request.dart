// models/product_request.dart
class ProductRequest {
  final String name;
  final int quantity;
  final String requester; // Admin or Volunteer
  final String urgency;   // "High", "Medium", "Low"

  ProductRequest({
    required this.name,
    required this.quantity,
    required this.requester,
    required this.urgency,
  });
}
