import 'package:aurovilletv/data/models/video_model.dart';
import 'package:aurovilletv/utils/theme/colors.dart';
import 'package:aurovilletv/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoModel video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isError = false;
  String _errorMessage = "";
  bool _isFallbackMode = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    String url = widget.video.videoUrl.trim();

    // Check if the URL is a direct video stream (ends with standard formats or includes media signatures)
    final isDirectVideo = url.isNotEmpty && 
        (url.contains('.mp4') || url.contains('.m3u8') || url.contains('.mkv') || url.contains('stream'));

    if (url.isEmpty || !isDirectVideo) {
      setState(() {
        _isFallbackMode = true;
      });
      // Fallback to web-safe sample video for previewing the video player feature
      url = "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4";
    }

    // Initialize Video Player
    _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await _controller!.initialize();
      setState(() {
        _isInitialized = true;
      });
      _controller!.play();
    } catch (e) {
      setState(() {
        _isError = true;
        _errorMessage = "Failed to load video: ${e.toString().replaceAll("Exception: ", "")}";
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.video.videoUrl.trim();
    final isWebsiteLink = url.isNotEmpty && !url.contains('.mp4') && !url.contains('.m3u8') && !url.contains('.mkv');

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          widget.video.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Frame Container
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Video Player
                    if (_isInitialized && _controller != null)
                      Center(
                        child: AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                    
                    // Loading Spinner
                    if (!_isInitialized && !_isError)
                      const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.themeColor),
                        ),
                      ),

                    // Error Placeholder
                    if (_isError)
                      Container(
                        color: Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.info_outline_rounded, size: 40, color: Colors.orangeAccent),
                                const SizedBox(height: 8),
                                Text(
                                  _errorMessage,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                                if (isWebsiteLink) ...[
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: () => AppUtils().openUrl(url),
                                    icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                                    label: const Text("Open on Website", style: TextStyle(fontSize: 12)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.themeColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Controllers (Play/Pause/Time) overlay
                    if (_isInitialized && _controller != null)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          color: Colors.black54,
                          child: Row(
                            children: [
                              ValueListenableBuilder(
                                valueListenable: _controller!,
                                builder: (context, VideoPlayerValue value, child) {
                                  return IconButton(
                                    icon: Icon(
                                      value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      value.isPlaying ? _controller!.pause() : _controller!.play();
                                    },
                                  );
                                },
                              ),
                              Expanded(
                                child: VideoProgressIndicator(
                                  _controller!,
                                  allowScrubbing: true,
                                  colors: const VideoProgressColors(
                                    playedColor: AppColors.themeColor,
                                    bufferedColor: Colors.white24,
                                    backgroundColor: Colors.white10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Video Details Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isFallbackMode) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Colors.amber),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.video.videoUrl.isEmpty
                                  ? "Preview Mode: The server has no video URL configured for this entry. Playing sample test video."
                                  : "Preview Mode: Server configured an external website link (${widget.video.videoUrl}). Playing sample test video.",
                              style: const TextStyle(fontSize: 12, color: AppColors.darkColor, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.themeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.video.categoryId.isNotEmpty ? widget.video.categoryId : "General",
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.themeColor),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.video.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.earthColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Published: ${widget.video.dateTime.toLocal().toString().substring(0, 10)}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.video.description.isNotEmpty ? widget.video.description : "No description available.",
                    style: const TextStyle(fontSize: 14, color: AppColors.darkColor, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
