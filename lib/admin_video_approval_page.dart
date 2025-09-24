import 'package:flutter/material.dart';
import 'data/video_data.dart';
import 'models/video_model.dart';
import 'widgets/video_card.dart';
import 'volunteer_video_page.dart'; // VideoPlayerPage

class AdminVideoApprovalPage extends StatefulWidget {
  const AdminVideoApprovalPage({super.key});

  @override
  State<AdminVideoApprovalPage> createState() =>
      _AdminVideoApprovalPageState();
}

class _AdminVideoApprovalPageState extends State<AdminVideoApprovalPage> {
  void approveVideo(Video video) {
    setState(() {
      video.status = 'approved';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade600,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text("Video '${video.title}' approved!")),
          ],
        ),
      ),
    );
  }

  void deleteVideo(Video video) {
    setState(() {
      // ✅ Delete by ID instead of object reference
      videos.removeWhere((v) => v.id == video.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade600,
        content: Row(
          children: [
            const Icon(Icons.delete, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text("Video '${video.title}' deleted.")),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allVideos = videos;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Admin Video Approval"),
        centerTitle: true,
      ),
      body: allVideos.isEmpty
          ? const Center(
              child: Text(
                "No videos uploaded yet.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // ✅ 2 videos per row
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 25 / 25, // keeps video size proportional
              ),
              itemCount: allVideos.length,
              itemBuilder: (context, index) {
                final video = allVideos[index];

                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VideoPlayerPage(video: video),
                          ),
                        );
                      },
                      child: VideoCard(video: video, onTap: () {}),
                    ),

                    // ✅ Approve button (if pending)
                    if (video.status == 'pending')
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: ElevatedButton.icon(
                          onPressed: () => approveVideo(video),
                          icon: const Icon(Icons.check),
                          label: const Text("Approve"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(90, 35),
                          ),
                        ),
                      ),

                    // ✅ Delete button (always visible)
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
    );
  }
}
