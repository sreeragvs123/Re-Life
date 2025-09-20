// lib/models/video_model.dart
import 'dart:typed_data';

class Video {
  final String id;
  final String title;
  final String? path;       // mobile/desktop
  final Uint8List? bytes;   // web
  Uint8List? thumbnail;     // mobile/desktop thumbnail

  Video({
    required this.id,
    required this.title,
    this.path,
    this.bytes,
    this.thumbnail,
  });
}
