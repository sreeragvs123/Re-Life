// lib/pages/evacuation_map_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/evacuation_route.dart';
import '../data/evacuation_routes_data.dart';

class EvacuationMapPage extends StatefulWidget {
  final bool isAdmin; // true for admin
  const EvacuationMapPage({super.key, this.isAdmin = false});

  @override
  State<EvacuationMapPage> createState() => _EvacuationMapPageState();
}

class _EvacuationMapPageState extends State<EvacuationMapPage> {
  final MapController mapController = MapController();
  LatLng? userStartPoint;

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!widget.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _askUserLocation());
    }
  }

  // Ask user for starting location
  void _askUserLocation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Your Current Location"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _latController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Latitude",
                  hintText: "e.g., 8.8932",
                ),
              ),
              TextField(
                controller: _lonController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Longitude",
                  hintText: "e.g., 76.6141",
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final lat = double.tryParse(_latController.text.trim());
                final lon = double.tryParse(_lonController.text.trim());
                if (lat != null && lon != null) {
                  setState(() {
                    userStartPoint = LatLng(lat, lon);
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter valid coordinates")),
                  );
                }
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  // Admin adds a new route via dialog
  void _showAddRouteDialog() {
    _latController.clear();
    _lonController.clear();
    _nameController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Destination Shelter"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Shelter Name",
                ),
              ),
              TextField(
                controller: _latController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Latitude",
                ),
              ),
              TextField(
                controller: _lonController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Longitude",
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final name = _nameController.text.trim();
                final lat = double.tryParse(_latController.text.trim());
                final lon = double.tryParse(_lonController.text.trim());

                if (name.isNotEmpty && lat != null && lon != null) {
                  setState(() {
                    evacuationRoutes.add(EvacuationRoute(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      path: [userStartPoint ?? LatLng(8.8932, 76.6141), LatLng(lat, lon)],
                      shelterLocation: LatLng(lat, lon), shelterId: '',
                    ));
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter valid data")),
                  );
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  // Admin deletes a route
  void _deleteRoute(String id) {
    setState(() {
      evacuationRoutes.removeWhere((route) => route.id == id);
    });
  }

  // Distance calculation
  double _distanceInKm(LatLng a, LatLng b) {
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
    final initialCenter = userStartPoint ??
        (evacuationRoutes.isNotEmpty ? evacuationRoutes[0].path.first : LatLng(8.8932, 76.6141));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Evacuation Routes"),
        backgroundColor: Colors.grey[850],
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: _showAddRouteDialog,
              backgroundColor: Colors.red,
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: initialCenter,
                zoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),

                // Markers
                MarkerLayer(
                  markers: evacuationRoutes.map((route) {
                    return Marker(
                      point: route.shelterLocation,
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onLongPress: widget.isAdmin ? () => _deleteRoute(route.id) : null,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // Polylines
                PolylineLayer(
                  polylines: evacuationRoutes.map((route) {
                    return Polyline(
                      points: [if (userStartPoint != null) userStartPoint!, ...route.path],
                      strokeWidth: 4,
                      color: Colors.blue,
                    );
                  }).toList(),
                ),

                // User marker
                if (userStartPoint != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: userStartPoint!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.green,
                          size: 35,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Route list with distances
          if (userStartPoint != null)
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.grey[100],
                child: ListView.builder(
                  itemCount: evacuationRoutes.length,
                  itemBuilder: (context, index) {
                    final route = evacuationRoutes[index];
                    final distance =
                        _distanceInKm(userStartPoint!, route.shelterLocation).toStringAsFixed(2);
                    return ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.red),
                      title: Text(route.name),
                      subtitle: Text("Distance: $distance km"),
                      onTap: () {
                        mapController.move(route.shelterLocation, 15);
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
