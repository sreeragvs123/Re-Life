import '../models/video_model.dart';
import 'dart:typed_data';

// Sample placeholder thumbnails (empty Uint8List for example)
Uint8List emptyThumbnail = Uint8List(0);

List<Video> videos = [
  Video(
    id: 'V7',
    title: 'Flood Relief Efforts',
    path: 'assets/videos/videoplayback.mp4', // path inside project
    thumbnail: emptyThumbnail,
  ),
   Video(
    id: 'V1',
    title: 'Flood Relief Efforts',
    path:  'assets/videos/disaster1.mp4', // path inside project
    thumbnail: emptyThumbnail,
  ),
  Video(
    id: 'V2',
    title: 'Flood Relief Efforts',
    path:  'assets/videos/disaster2.mp4', // path inside project
    thumbnail: emptyThumbnail,
  ),
  Video(
    id: 'V3',
    title: 'Flood Relief Efforts',
    path:  'assets/videos/disaster3.mp4', // path inside project
    thumbnail: emptyThumbnail,
  ),
  Video(
    id: 'V4',
    title: 'Flood Relief Efforts',
    path:  'assets/videos/disaster4.mp4', // path inside project
    thumbnail: emptyThumbnail,
  ),
  Video(
    id: 'V5',
    title: 'Flood Relief Efforts',
    path:  'assets/videos/disaster5.mp4', // path inside project
    thumbnail: emptyThumbnail,
  ),
];
