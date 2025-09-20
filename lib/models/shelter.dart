// models/shelter.dart
class Shelter {
  final String id;
  final String name;
  final int capacity;
  final int filled;
  final String contact;
  final String location;
  final double latitude;
  final double longitude;

  Shelter({
    required this.id,
    required this.name,
    required this.capacity,
    required this.filled,
    required this.contact,
    required this.location,
    required this.latitude,
    required this.longitude,
  });
}
