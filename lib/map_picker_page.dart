import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as ll;

class MapPickerPage extends StatefulWidget {
  final ll.LatLng? initial;
  const MapPickerPage({super.key, this.initial});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final Completer<gmaps.GoogleMapController> _controller = Completer();
  gmaps.LatLng? _picked;

  ll.LatLng _gmToLl(gmaps.LatLng p) => ll.LatLng(p.latitude, p.longitude);

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _picked = gmaps.LatLng(widget.initial!.latitude, widget.initial!.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = _picked ?? const gmaps.LatLng(8.8932, 76.6141);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          TextButton(
            onPressed: () {
              if (_picked == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tap the map to select a location')),
                );
                return;
              }
              final ll.LatLng result = _gmToLl(_picked!);
              Navigator.of(context).pop(result);
            },
            child: const Text('Use', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: gmaps.GoogleMap(
        initialCameraPosition: gmaps.CameraPosition(target: start, zoom: 13),
        onMapCreated: (c) {
          if (!_controller.isCompleted) _controller.complete(c);
        },
        onTap: (pos) => setState(() => _picked = pos),
        markers: _picked == null
            ? <gmaps.Marker>{}
            : {
                gmaps.Marker(
                  markerId: const gmaps.MarkerId('picked'),
                  position: _picked!,
                )
              },
        zoomControlsEnabled: true,
        myLocationEnabled: false,
      ),
    );
  }
}