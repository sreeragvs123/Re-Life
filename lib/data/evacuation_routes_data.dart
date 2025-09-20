import 'package:latlong2/latlong.dart';
import '../models/evacuation_route.dart';
import 'shelter_data.dart';

List<EvacuationRoute> evacuationRoutes = [
  EvacuationRoute(
    id: 'r1',
    name: 'Route to Shelter 1',
    path: [
      LatLng(8.895, 76.612),
      LatLng(8.893, 76.614),
      LatLng(8.8932, 76.6141), // Shelter 1
    ],
    shelterLocation: LatLng(shelters[0].latitude, shelters[0].longitude),
    shelterId: shelters[0].id,
  ),
  EvacuationRoute(
    id: 'r2',
    name: 'Route to Shelter 2',
    path: [
      LatLng(8.877, 76.608),
      LatLng(8.876, 76.610),
      LatLng(8.8764, 76.6100), // Shelter 2
    ],
    shelterLocation: LatLng(shelters[1].latitude, shelters[1].longitude),
    shelterId: shelters[1].id,
  ),
  EvacuationRoute(
    id: 'r3',
    name: 'Route to Shelter 3',
    path: [
      LatLng(8.902, 76.618),
      LatLng(8.901, 76.619),
      LatLng(8.9000, 76.6200), // Shelter 3
    ],
    shelterLocation: LatLng(shelters[2].latitude, shelters[2].longitude),
    shelterId: shelters[2].id,
  ),
  EvacuationRoute(
    id: 'r4',
    name: 'Route to Shelter 4',
    path: [
      LatLng(8.892, 76.602),
      LatLng(8.891, 76.603),
      LatLng(8.8900, 76.6050), // Shelter 4
    ],
    shelterLocation: LatLng(shelters[3].latitude, shelters[3].longitude),
    shelterId: shelters[3].id,
  ),
  EvacuationRoute(
    id: 'r5',
    name: 'Route to Shelter 5',
    path: [
      LatLng(8.911, 76.613),
      LatLng(8.9105, 76.614),
      LatLng(8.9100, 76.6150), // Shelter 5
    ],
    shelterLocation: LatLng(shelters[4].latitude, shelters[4].longitude),
    shelterId: shelters[4].id,
  ),
];
