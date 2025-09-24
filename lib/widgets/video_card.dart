import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/video_model.dart';
import 'package:universal_html/html.dart' as html;

class VideoCard extends StatefulWidget {
  final Video video;
  final VoidCallback onTap;
  final VoidCallback? onDelete;   // optional callback for delete
  final VoidCallback? onApprove;  // optional callback for approve

  const VideoCard({
    super.key,
    required this.video,
    required this.onTap,
    this.onDelete,
    this.onApprove,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    if (widget.video.path != null) {
      if (kIsWeb && widget.video.bytes != null) {
        final blob = html.Blob([widget.video.bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        _controller = VideoPlayerController.network(url);
      } else if (widget.video.path!.startsWith('http')) {
        _controller = VideoPlayerController.network(widget.video.path!);
      } else if (widget.video.path!.startsWith('assets/')) {
        _controller = VideoPlayerController.asset(widget.video.path!);
      } else {
        _controller = VideoPlayerController.file(File(widget.video.path!));
      }
    } else if (widget.video.bytes != null && kIsWeb) {
      final blob = html.Blob([widget.video.bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      _controller = VideoPlayerController.network(url);
    } else {
      _initialized = false;
      return;
    }

    _controller.setLooping(true);
    _controller.initialize().then((_) {
      setState(() {
        _initialized = true;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (!_initialized) return;
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(widget.video.id), // ✅ unique key to prevent widget reuse issues
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            GestureDetector(
              onTap: widget.onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _initialized
                      ? VideoPlayer(_controller)
                      : const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),

            // Large play button
            if (!_isPlaying && _initialized)
              Center(
                child: IconButton(
                  iconSize: 60,
                  icon: Icon(
                    Icons.play_circle_outline,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  onPressed: _togglePlayPause,
                ),
              ),

            // Small pause button
            if (_isPlaying && _initialized)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  iconSize: 30,
                  icon: Icon(
                    Icons.pause_circle_outline,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  onPressed: _togglePlayPause,
                ),
              ),

            // Pending Approval Badge
            if (widget.video.status == 'pending')
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade700,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    "Pending",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Video title overlay
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: Colors.black54,
                child: Text(
                  widget.video.title,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Optional Approve button inside card
            if (widget.video.status == 'pending' && widget.onApprove != null)
              Positioned(
                bottom: 8,
                right: 8,
                child: ElevatedButton.icon(
                  onPressed: widget.onApprove,
                  icon: const Icon(Icons.check),
                  label: const Text("Approve"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(90, 35),
                  ),
                ),
              ),

            // Optional Delete button inside card
            if (widget.onDelete != null)
              Positioned(
                top: 8,
                right: 8,
                child: ElevatedButton.icon(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete),
                  label: const Text("Delete"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(70, 30),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}