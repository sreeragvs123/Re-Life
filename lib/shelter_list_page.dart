import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:video_app/models/shelter.dart';
import '../data/shelter_data.dart';
import 'add_shelter_route_page.dart';
import 'user_shelter_map_page.dart';

class ShelterListPage extends StatefulWidget {
  final bool isAdmin;

  const ShelterListPage({super.key, this.isAdmin = false});

  @override
  State<ShelterListPage> createState() => _ShelterListPageState();
}

class _ShelterListPageState extends State<ShelterListPage> {
  // Navigate to Add Shelter Page
  void _goToAddShelter() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddShelterRoutePage()),
    );

    if (result == true) setState(() {}); // Refresh list
  }

  // Ask user for current location before opening map
  void _askUserLocation(Shelter shelter) {
    final latController = TextEditingController();
    final lonController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Enter Your Current Location"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: latController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Latitude",
                hintText: "e.g., 8.8932",
              ),
            ),
            TextField(
              controller: lonController,
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
              final lat = double.tryParse(latController.text.trim());
              final lon = double.tryParse(lonController.text.trim());

              if (lat != null && lon != null) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserShelterMapPage(
                      userLocation: LatLng(lat, lon),
                      shelter: shelter,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Enter valid coordinates")),
                );
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shelters"), centerTitle: true),
      body: shelters.isEmpty
          ? const Center(child: Text("No shelters available"))
          : ListView.builder(
              itemCount: shelters.length,
              itemBuilder: (_, index) {
                final shelter = shelters[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(shelter.name),
                    subtitle: Text(
                        "${shelter.location} | ${shelter.filled}/${shelter.capacity}"),
                    trailing:
                        const Icon(Icons.location_on, color: Colors.red),
                    onTap: () => _askUserLocation(shelter),
                  ),
                );
              },
            ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: _goToAddShelter,
              backgroundColor: Colors.blueGrey,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
