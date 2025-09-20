// lib/pages/add_shelter_route_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/shelter.dart';
import '../models/evacuation_route.dart';
import '../data/shelter_data.dart';
import '../data/evacuation_routes_data.dart';

class AddShelterRoutePage extends StatefulWidget {
  const AddShelterRoutePage({super.key});

  @override
  State<AddShelterRoutePage> createState() => _AddShelterRoutePageState();
}

class _AddShelterRoutePageState extends State<AddShelterRoutePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _filledController = TextEditingController();
  final _contactController = TextEditingController();
  final _locationController = TextEditingController();

  LatLng? shelterLatLng;

  // Save shelter & add evacuation route
  void _saveShelter() {
    if (_formKey.currentState!.validate() && shelterLatLng != null) {
      final newShelter = Shelter(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        capacity: int.parse(_capacityController.text.trim()),
        filled: int.parse(_filledController.text.trim()),
        contact: _contactController.text.trim(),
        location: _locationController.text.trim(),
        latitude: shelterLatLng!.latitude,
        longitude: shelterLatLng!.longitude,
      );

      shelters.add(newShelter);

      // Add evacuation route
      evacuationRoutes.add(EvacuationRoute(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        shelterId: newShelter.id,
        name: newShelter.name,
        path: [LatLng(8.8932, 76.6141), shelterLatLng!], // admin default start
        shelterLocation: shelterLatLng!,
      ));

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select shelter location on map")),
      );
    }
  }

  // Pick shelter location on map
  void _pickShelterLocation() {
    showDialog(
      context: context,
      builder: (_) {
        LatLng? tempLatLng = shelterLatLng;
        return AlertDialog(
          title: const Text("Select Shelter Location"),
          content: SizedBox(
            width: 300,
            height: 300,
            child: FlutterMap(
              options: MapOptions(
                center: tempLatLng ?? LatLng(8.8932, 76.6141),
                zoom: 13,
                onTap: (tapPos, latlng) {
                  setState(() {
                    shelterLatLng = latlng;
                  });
                  Navigator.pop(context);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                if (tempLatLng != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: tempLatLng,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 35,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Shelter & Route")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration:
                        const InputDecoration(labelText: "Shelter Name"),
                    validator: (val) =>
                        val!.isEmpty ? "Enter shelter name" : null,
                  ),
                  TextFormField(
                    controller: _capacityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Capacity"),
                    validator: (val) =>
                        val!.isEmpty ? "Enter capacity" : null,
                  ),
                  TextFormField(
                    controller: _filledController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: "Currently Filled"),
                    validator: (val) => val!.isEmpty ? "Enter filled" : null,
                  ),
                  TextFormField(
                    controller: _contactController,
                    decoration: const InputDecoration(labelText: "Contact"),
                    validator: (val) =>
                        val!.isEmpty ? "Enter contact" : null,
                  ),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: "Address"),
                    validator: (val) =>
                        val!.isEmpty ? "Enter address" : null,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _pickShelterLocation,
                    child: const Text("Pick Shelter Location on Map"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveShelter,
                    child: const Text("Save Shelter"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
