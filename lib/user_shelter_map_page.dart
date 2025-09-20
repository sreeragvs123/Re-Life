import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/shelter.dart';
import 'dart:math';

class UserShelterMapPage extends StatelessWidget {
  final LatLng userLocation;
  final Shelter shelter;

  const UserShelterMapPage({
    super.key,
    required this.userLocation,
    required this.shelter,
  });

  // Calculate distance in km
  double _calculateDistance(LatLng a, LatLng b) {
    const double earthRadius = 6371; // km
    double dLat = _deg2rad(b.latitude - a.latitude);
    double dLon = _deg2rad(b.longitude - a.longitude);
    double lat1 = _deg2rad(a.latitude);
    double lat2 = _deg2rad(b.latitude);

    double haversine = 
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(haversine), sqrt(1 - haversine));
    return earthRadius * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  @override
  Widget build(BuildContext context) {
    final shelterLocation = LatLng(shelter.latitude, shelter.longitude);
    final center = LatLng(
      (userLocation.latitude + shelterLocation.latitude) / 2,
      (userLocation.longitude + shelterLocation.longitude) / 2,
    );
    final distance = _calculateDistance(userLocation, shelterLocation);

    return Scaffold(
      appBar: AppBar(
        title: Text(shelter.name),
        backgroundColor: Colors.grey[850],
      ),
      body: FlutterMap(
        options: MapOptions(center: center, zoom: 13),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: userLocation,
                width: 40,
                height: 40,
                child: const Icon(Icons.my_location, color: Colors.green, size: 35),
              ),
              Marker(
                point: shelterLocation,
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on, color: Colors.red, size: 35),
              ),
            ],
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: [userLocation, shelterLocation],
                color: Colors.blue,
                strokeWidth: 4,
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12),
        child: Text(
          "Distance: ${distance.toStringAsFixed(2)} km",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
