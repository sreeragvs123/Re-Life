import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:universal_html/html.dart' as html;
import 'data/video_data.dart';
import 'models/video_model.dart';
import 'widgets/video_card.dart';

class VolunteerVideoPage extends StatefulWidget {
  const VolunteerVideoPage({super.key});

  @override
  State<VolunteerVideoPage> createState() => _VolunteerVideoPageState();
}

class _VolunteerVideoPageState extends State<VolunteerVideoPage> {
  bool _isUploading = false;

  Future<void> pickVideo() async {
    setState(() => _isUploading = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        withData: true,
      );

      if (result != null) {
        String title = result.files.single.name;
        Video newVideo;

        if (kIsWeb && result.files.single.bytes != null) {
          // Web: use bytes
          newVideo = Video(
            id: DateTime.now().toString(),
            title: title,
            bytes: result.files.single.bytes,
            status: 'pending',
            path: null,
            thumbnail: null,
            owner: "volunteer",
          );
        } else if (!kIsWeb && result.files.single.path != null) {
          // Mobile: use file path & thumbnail
          File pickedFile = File(result.files.single.path!);
          Directory appDir = await getApplicationDocumentsDirectory();
          String newPath = '${appDir.path}/$title';
          File savedFile = await pickedFile.copy(newPath);

          Uint8List? thumb = await VideoThumbnail.thumbnailData(
            video: savedFile.path,
            imageFormat: ImageFormat.JPEG,
            maxHeight: 300,
            maxWidth: 300,
            quality: 75,
          );

          newVideo = Video(
            id: DateTime.now().toString(),
            title: title,
            path: savedFile.path,
            thumbnail: thumb,
            status: 'pending',
            bytes: null,
            owner: "volunteer",
          );
        } else {
          throw Exception("Unable to get video data.");
        }

        setState(() {
          videos.add(newVideo);
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.shade600,
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      "Video '$title' uploaded successfully! Pending admin approval."),
                ),
              ],
            ),
          ),
        );
      } else {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No video selected.")),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade600,
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text("Video upload failed: $e")),
            ],
          ),
        ),
      );
    }
  }

  void deleteVideo(Video video) {
    setState(() {
      videos.remove(video);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Video '${video.title}' deleted.")),
    );
  }

  void playVideo(Video video) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VideoPlayerPage(video: video)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final approvedVideos = videos.where((v) => v.status == 'approved').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Volunteer Videos"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: _isUploading ? null : pickVideo,
              icon: const Icon(Icons.upload_file),
              label: Text(_isUploading ? "Uploading..." : "Pick & Upload Video"),
            ),
          ),
          if (_isUploading)
            const LinearProgressIndicator(
                minHeight: 5, color: Colors.deepPurple),
          Expanded(
            child: approvedVideos.isEmpty
                ? const Center(
                    child: Text(
                      "No videos uploaded yet.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 per row
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 25 / 25,
                    ),
                    itemCount: approvedVideos.length,
                    itemBuilder: (context, index) {
                      final video = approvedVideos[index];
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () => playVideo(video),
                            child: VideoCard(
                              video: video,
                              onTap: () {},
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red, size: 28),
                              onPressed: () => deleteVideo(video),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// 🎬 Video Player Page with timeline
class VideoPlayerPage extends StatefulWidget {
  final Video video;
  const VideoPlayerPage({super.key, required this.video});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    if (kIsWeb && widget.video.bytes != null) {
      final blob = html.Blob([widget.video.bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      _controller = VideoPlayerController.network(url)
        ..initialize().then((_) {
          setState(() {});
        });
    } else if (!kIsWeb && widget.video.path != null) {
      _controller = VideoPlayerController.file(File(widget.video.path!))
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.video.title),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoPlayer(_controller),
                          if (!_controller.value.isPlaying)
                            IconButton(
                              icon: const Icon(Icons.play_circle,
                                  size: 80, color: Colors.white70),
                              onPressed: _togglePlayPause,
                            ),
                        ],
                      ),
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
          if (_controller.value.isInitialized) ...[
            VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: Colors.deepPurple,
                bufferedColor: Colors.purple.shade200,
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, VideoPlayerValue value, child) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(value.position),
                          style: const TextStyle(color: Colors.white)),
                      Text(_formatDuration(value.duration),
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _togglePlayPause,
                    icon: Icon(_controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow),
                    label:
                        Text(_controller.value.isPlaying ? "Pause" : "Play"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: () => _controller.seekTo(Duration.zero),
                    icon: const Icon(Icons.stop),
                    label: const Text("Restart"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
