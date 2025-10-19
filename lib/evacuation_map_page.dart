// lib/pages/evacuation_map_page.dart
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as ll;

import '../models/evacuation_route.dart';
import '../data/evacuation_routes_data.dart';

class EvacuationMapPage extends StatefulWidget {
  final bool isAdmin; // true for admin
  const EvacuationMapPage({super.key, this.isAdmin = false});

  @override
  State<EvacuationMapPage> createState() => _EvacuationMapPageState();
}

class _EvacuationMapPageState extends State<EvacuationMapPage> {
  final Completer<gmaps.GoogleMapController> _controller = Completer();
  ll.LatLng? userStartPoint;

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

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Helper: convert latlong2 LatLng -> google_maps_flutter LatLng
  gmaps.LatLng _toGm(ll.LatLng p) => gmaps.LatLng(p.latitude, p.longitude);

  // Ask user for starting location
  void _askUserLocation() async {
    // Open an interactive picker instead of asking for lat/lon text input
    final picked = await _openLocationPicker();
    if (picked != null) {
      setState(() => userStartPoint = picked);
    }
  }

  // Shows a dialog with a GoogleMap where the user taps to pick their location.
  Future<ll.LatLng?> _openLocationPicker() {
    final fallback = ll.LatLng(8.8932, 76.6141);
    ll.LatLng? selection;
    final Completer<gmaps.GoogleMapController> pickerController = Completer();

    return showDialog<ll.LatLng>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Tap the map to set your current location'),
          content: SizedBox(
            width: double.maxFinite,
            height: 420,
            child: StatefulBuilder(
              builder: (ctx2, setState2) {
                final initial = gmaps.CameraPosition(
                  target: _toGm(userStartPoint ?? (evacuationRoutes.isNotEmpty ? evacuationRoutes[0].path.first : fallback)),
                  zoom: 14,
                );

                final markers = <gmaps.Marker>{};
                if (selection != null) {
                  markers.add(gmaps.Marker(
                    markerId: const gmaps.MarkerId('picker'),
                    position: _toGm(selection!),
                    icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueBlue),
                  ));
                }

                return Column(
                  children: [
                    Expanded(
                      child: gmaps.GoogleMap(
                        initialCameraPosition: initial,
                        markers: markers,
                        onMapCreated: (gm) {
                          if (!pickerController.isCompleted) pickerController.complete(gm);
                        },
                        onTap: (pos) {
                          setState2(() {
                            selection = ll.LatLng(pos.latitude, pos.longitude);
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
                          onPressed: () => Navigator.of(ctx).pop(null),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: selection == null
                              ? null
                              : () => Navigator.of(ctx).pop(selection),
                          child: const Text('Select'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Admin adds a new route via dialog
  void _showAddRouteDialog() {
    _nameController.clear();

    final fallback = ll.LatLng(8.8932, 76.6141);
    ll.LatLng? selection;
    String? selectionName;
    String? selectionPlaceId;
    final Completer<gmaps.GoogleMapController> pickerController = Completer();

    Future<Map<String, dynamic>?> _fetchPlaceDetails(String placeId) async {
      // Provide your Places API key via --dart-define=GOOGLE_PLACES_API_KEY=your_key
      const String apiKey =
          String.fromEnvironment('GOOGLE_PLACES_API_KEY', defaultValue: '');
      if (apiKey.isEmpty) return null;

      final uri = Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
        'place_id': placeId,
        'fields': 'name,formatted_address,geometry,place_id',
        'key': apiKey,
      });

      try {
        final client = HttpClient();
        final req = await client.getUrl(uri);
        final resp = await req.close();
        final body = await resp.transform(utf8.decoder).join();
        client.close();
        final json = jsonDecode(body) as Map<String, dynamic>;
        if (json['status'] == 'OK') {
          return json['result'] as Map<String, dynamic>;
        }
      } catch (_) {}
      return null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Destination Shelter (tap POI or map)"),
          content: SizedBox(
            width: double.maxFinite,
            height: 480,
            child: StatefulBuilder(
              builder: (ctx, setStateDialog) {
                final initial = gmaps.CameraPosition(
                  target: _toGm(userStartPoint ?? (evacuationRoutes.isNotEmpty ? evacuationRoutes[0].path.first : fallback)),
                  zoom: 13,
                );

                final markers = <gmaps.Marker>{};
                if (selection != null) {
                  markers.add(gmaps.Marker(
                    markerId: const gmaps.MarkerId('shelter_picker'),
                    position: _toGm(selection!),
                    infoWindow: gmaps.InfoWindow(title: selectionName),
                    icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueRed),
                  ));
                }

                return Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Shelter Name (auto-filled from POI if available)",
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: gmaps.GoogleMap(
                        initialCameraPosition: initial,
                        markers: markers,
                        onMapCreated: (gm) {
                          if (!pickerController.isCompleted) pickerController.complete(gm);
                        },
                        // Tap any point on map to drop a marker
                        onTap: (pos) {
                          setStateDialog(() {
                            selection = ll.LatLng(pos.latitude, pos.longitude);
                            selectionName = null;
                            selectionPlaceId = null;
                            _nameController.text = '';
                          });
                        },
                        // NOTE: `onPoiTapped` is not available on the GoogleMap class
                        // resolved in this project. Use the onTap handler above to pick
                        // locations. To restore POI support, upgrade google_maps_flutter
                        // to a version that exposes onPoiTapped and use:
                        // onPoiTapped: (gmaps.PointOfInterest poi) { ... }
                        zoomControlsEnabled: true,
                        myLocationEnabled: false,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectionName != null
                                ? 'Selected POI: $selectionName'
                                : (selection != null ? 'Custom location selected' : 'No location selected'),
                            maxLines: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: selectionPlaceId == null
                              ? null
                              : () async {
                                  final details = await _fetchPlaceDetails(selectionPlaceId!);
                                  if (details != null && details['formatted_address'] != null) {
                                    // show brief details
                                    if (!mounted) return;
                                    showDialog(
                                      context: context,
                                      builder: (c) => AlertDialog(
                                        title: Text(details['name'] ?? 'Place details'),
                                        content: Text(details['formatted_address'] ?? 'No address'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('OK')),
                                        ],
                                      ),
                                    );
                                  } else {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Could not fetch place details (missing API key or network).')),
                                    );
                                  }
                                },
                          child: const Text('Show details'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                if ((name.isEmpty) || (selection == null)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Provide a name (or tap a POI) and select a location on the map")),
                  );
                  return;
                }

                setState(() {
                  evacuationRoutes.add(EvacuationRoute(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    path: [userStartPoint ?? fallback, selection!],
                    shelterLocation: selection!,
                    shelterId: selectionPlaceId ?? '',
                  ));
                });

                // Move main map camera to the newly added shelter
                final gm = await _controller.future;
                gm.animateCamera(gmaps.CameraUpdate.newLatLng(_toGm(selection!)));
                Navigator.of(context).pop();
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

  // Distance calculation (haversine)
  double _distanceInKm(ll.LatLng a, ll.LatLng b) {
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
    final fallback = ll.LatLng(8.8932, 76.6141);
    final initialCenter = userStartPoint ?? (evacuationRoutes.isNotEmpty ? evacuationRoutes[0].path.first : fallback);

    final initialCamera = gmaps.CameraPosition(
      target: _toGm(initialCenter),
      zoom: 13,
    );

    // Build markers and polylines for Google Maps
    final markers = <gmaps.Marker>{};
    final polylines = <gmaps.Polyline>{};

    for (final route in evacuationRoutes) {
      final shelterGm = _toGm(route.shelterLocation);
      markers.add(gmaps.Marker(
        markerId: gmaps.MarkerId(route.id),
        position: shelterGm,
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueRed),
        onTap: () {
          // If admin, show delete confirmation; otherwise focus camera
          if (widget.isAdmin) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete route?'),
                content: Text('Delete shelter "${route.name}"?'),
                actions: [
                  TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () {
                      _deleteRoute(route.id);
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          } else {
            _controller.future.then((gm) => gm.animateCamera(gmaps.CameraUpdate.newLatLngZoom(shelterGm, 15)));
          }
        },
      ));

      // Polyline points: include userStartPoint if present
      final points = <gmaps.LatLng>[];
      if (userStartPoint != null) points.add(_toGm(userStartPoint!));
      for (final p in route.path) {
        points.add(_toGm(p));
      }
      polylines.add(gmaps.Polyline(
        polylineId: gmaps.PolylineId(route.id),
        points: points,
        color: Colors.blue,
        width: 4,
      ));
    }

    // User marker
    if (userStartPoint != null) {
      markers.add(gmaps.Marker(
        markerId: const gmaps.MarkerId('__user__'),
        position: _toGm(userStartPoint!),
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueGreen),
      ));
    }

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
            child: gmaps.GoogleMap(
              initialCameraPosition: initialCamera,
              markers: markers,
              polylines: polylines,
              onMapCreated: (gm) {
                if (!_controller.isCompleted) _controller.complete(gm);
              },
              myLocationEnabled: false,
              zoomControlsEnabled: true,
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
                      onTap: () async {
                        final gm = await _controller.future;
                        gm.animateCamera(gmaps.CameraUpdate.newLatLngZoom(_toGm(route.shelterLocation), 15));
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
