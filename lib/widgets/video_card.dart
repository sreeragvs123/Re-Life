import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/video_model.dart';
import 'package:universal_html/html.dart' as html;

class VideoCard extends StatefulWidget {
  final Video video;
  final VoidCallback onTap;
  final bool canDelete;
  final VoidCallback? onDelete;

  const VideoCard({
    super.key,
    required this.video,
    required this.onTap,
    this.canDelete = false,
    this.onDelete,
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
    return AspectRatio(
      aspectRatio: 25/ 25,
      child: Stack(
        children: [
          // Background video
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _initialized
                  ? Stack(
                      children: [
                        VideoPlayer(_controller),

                        // Progress bar at bottom
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: VideoProgressIndicator(
                            _controller,
                            allowScrubbing: true,
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            colors: VideoProgressColors(
                              playedColor: Colors.red,
                              bufferedColor: Colors.grey,
                              backgroundColor: Colors.black26,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),

          // Play / Pause button
          if (_initialized)
            Center(
              child: IconButton(
                iconSize: 40,
                icon: Icon(
                  _isPlaying
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline,
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

          // Delete button (Admin/Volunteer only)
          if (widget.canDelete)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: widget.onDelete,
              ),
            ),
        ],
      ),
    );
  }
}
