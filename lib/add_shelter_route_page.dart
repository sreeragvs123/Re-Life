// lib/pages/add_shelter_route_page.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as ll;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'map_picker_page.dart';
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

  ll.LatLng? shelterLatLng;

  // helper to convert google_maps_flutter LatLng -> latlong2 LatLng
  ll.LatLng _gmToLl(gmaps.LatLng p) => ll.LatLng(p.latitude, p.longitude);

  // reverse geocode to get a human readable address (optional)
  Future<String?> _reverseGeocode(double lat, double lng) async {
    const String apiKey =
        String.fromEnvironment(' AIzaSyDk5-TmduiN-vjC2i2POHwJqmTePuufVnY', defaultValue: '');
    if (apiKey.isEmpty) return null;

    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '$lat,$lng',
      'key': apiKey,
    });
    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(res.body);
        final results = json['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          return results.first['formatted_address'] as String?;
        }
      }
    } catch (_) {}
    return null;
  }

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

      evacuationRoutes.add(EvacuationRoute(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        shelterId: newShelter.id,
        name: newShelter.name,
        path: [ll.LatLng(8.8932, 76.6141), shelterLatLng!],
        shelterLocation: shelterLatLng!,
      ));

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select shelter location on map")),
      );
    }
  }

  // Map picker dialog using google_maps_flutter
  void _pickShelterLocation() {
    final Completer<gmaps.GoogleMapController> pickerController =
        Completer<gmaps.GoogleMapController>();
    ll.LatLng? tempLl = shelterLatLng;
    gmaps.LatLng? tempGm = shelterLatLng != null
        ? gmaps.LatLng(shelterLatLng!.latitude, shelterLatLng!.longitude)
        : null;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Select Shelter Location"),
          content: SizedBox(
            width: 350,
            height: 400,
            child: StatefulBuilder(
              builder: (ctx, setStateDialog) {
                // build markers in a non-null-safe way to satisfy the analyzer
                final Set<gmaps.Marker> markers = <gmaps.Marker>{};
                if (tempGm != null) {
                  // force non-null here since we checked above
                  markers.add(gmaps.Marker(
                    markerId: const gmaps.MarkerId('selected'),
                    position: tempGm!, // use non-null assertion
                    icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
                        gmaps.BitmapDescriptor.hueRed),
                  ));
                }

                return Column(
                  children: [
                    Expanded(
                      child: gmaps.GoogleMap(
                        initialCameraPosition: gmaps.CameraPosition(
                          target:
                              tempGm ?? const gmaps.LatLng(8.8932, 76.6141),
                          zoom: 13,
                        ),
                        markers: markers,
                        onMapCreated: (ctrl) {
                          if (!pickerController.isCompleted) {
                            pickerController.complete(ctrl);
                          }
                        },
                        onTap: (pos) {
                          setStateDialog(() {
                            tempGm = pos;
                            tempLl = _gmToLl(pos);
                          });
                        },
                        zoomControlsEnabled: true,
                        myLocationEnabled: false,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            if (tempLl == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text("Tap the map to select a location")),
                              );
                              return;
                            }

                            // make a non-null local copy to satisfy the analyzer across awaits
                            final ll.LatLng selected = tempLl!;

                            final addr = await _reverseGeocode(
                                selected.latitude, selected.longitude);

                            // avoid using context across async gap if widget was disposed
                            if (!mounted) return;

                            setState(() => shelterLatLng = selected);

                            if (addr != null && addr.isNotEmpty) {
                              _locationController.text = addr;
                            } else {
                              _locationController.text =
                                  '${selected.latitude.toStringAsFixed(6)}, ${selected.longitude.toStringAsFixed(6)}';
                            }

                            Navigator.pop(context);
                          },
                          child: const Text('Use this location'),
                        ),
                      ],
                    )
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _filledController.dispose();
    _contactController.dispose();
    _locationController.dispose();
    super.dispose();
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
                    decoration: const InputDecoration(labelText: "Shelter Name"),
                    validator: (val) => val == null || val.isEmpty
                        ? "Enter shelter name"
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _capacityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Capacity"),
                    validator: (val) => val == null || val.isEmpty
                        ? "Enter capacity"
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _filledController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: "Currently Filled"),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Enter filled" : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _contactController,
                    decoration: const InputDecoration(labelText: "Contact"),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Enter contact" : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: "Address"),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Enter address" : null,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.of(context).push<ll.LatLng?>(
                        MaterialPageRoute(
                          builder: (_) => MapPickerPage(initial: shelterLatLng),
                        ),
                      );
                      if (result != null) {
                        setState(() => shelterLatLng = result);
                        // optionally reverse-geocode here (call your existing _reverseGeocode)
                        final addr = await _reverseGeocode(result.latitude, result.longitude);
                        if (!mounted) return;
                        if (addr != null && addr.isNotEmpty) {
                          _locationController.text = addr;
                        } else {
                          _locationController.text =
                              '${result.latitude.toStringAsFixed(6)}, ${result.longitude.toStringAsFixed(6)}';
                        }
                      }
                    },
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
