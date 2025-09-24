import 'dart:typed_data';

class Video {
  String id;
  String title;
  String status; // 'pending' or 'approved'
  String? path; // for mobile
  Uint8List? bytes; // for web
  Uint8List? thumbnail;
  String? owner; // who uploaded (for volunteer restriction)

  Video({
    required this.id,
    required this.title,
    required this.status,
    this.path,
    this.bytes,
    this.thumbnail,
    this.owner,
  });
}
