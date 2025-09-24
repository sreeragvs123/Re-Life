import 'dart:typed_data';

class Video {
  final String id;
  final String title;
  final String? path;        // allow null for web uploads
  final Uint8List? thumbnail; // allow null for web uploads
  final Uint8List? bytes;     // web file bytes
  String status;              // 'pending' or 'approved'
  final String uploader;      // volunteer name/id

  Video({
    required this.id,
    required this.title,
    this.path,
    this.thumbnail,
    this.bytes,
    this.status = 'pending',
    this.uploader = 'unknown',
});
}