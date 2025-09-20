import 'package:flutter/material.dart';
import 'data/video_data.dart';
import 'widgets/video_card.dart';
import 'volunteer_video_page.dart'; // VideoPlayerPage

class VideoGalleryPage extends StatelessWidget {
  const VideoGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // YouTube-like dark background
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Video Gallery",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 per row
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 16 / 12, // force 16:9-ish thumbnail box
          ),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VideoPlayerPage(video: video),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Force same thumbnail size for all
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: AspectRatio(
                        aspectRatio: 16 / 9, // fixed preview ratio
                        child: VideoCard(
                          video: video,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VideoPlayerPage(video: video),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // ✅ Title under video
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        video.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
