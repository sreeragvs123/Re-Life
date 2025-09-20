// lib/models/evacuation_route.dart
import 'package:latlong2/latlong.dart';

class EvacuationRoute {
  final String id;
  final String name;
  final List<LatLng> path;
  final LatLng shelterLocation;

  EvacuationRoute({
    required this.id,
    required this.name,
    required this.path,
    required this.shelterLocation, required String shelterId,
  });
}
