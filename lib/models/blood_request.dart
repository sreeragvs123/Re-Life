// lib/models/blood_request.dart
class BloodRequest {
  final String id;
  final String name;
  final String bloodGroup;
  final String contact;
  final String city;

  BloodRequest({
    required this.id,
    required this.name,
    required this.bloodGroup,
    required this.contact,
    required this.city,
  });
}
