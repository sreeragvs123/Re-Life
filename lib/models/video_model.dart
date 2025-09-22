import 'dart:typed_data';

class Video {
  String id;
  String title;
  String? path;       // file path for mobile
  Uint8List? thumbnail; // thumbnail can be null
  Uint8List? bytes;   // video bytes for web
  String status;      // pending/approved

  Video({
    required this.id,
    required this.title,
    this.path,
    this.thumbnail,
    this.bytes,
    required this.status,
  });
}
