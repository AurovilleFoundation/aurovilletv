import 'package:aurovilletv/data/models/live_stream_model.dart';
import 'package:aurovilletv/ui/live/cubit/live_cubit.dart';
import 'package:aurovilletv/utils/theme/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isPlaying = false;
  bool _isMuted = true; // Muted by default to satisfy browser autoplay policies

  VideoPlayerController? _videoController;
  String? _currentStreamUrl;
  bool _isPlayerInitialized = false;
  int _activeTab = 0; // 0 = Chat, 1 = Schedule

  void _videoPlayerListener() {
    if (mounted) {
      setState(() {});
    }
  }

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) return "00:00";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      return "${twoDigits(hours)}:${twoDigits(minutes.remainder(60))}:${twoDigits(seconds)}";
    }
    return "${twoDigits(minutes)}:${twoDigits(seconds)}";
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<LiveCubit>();
      if (cubit.state is LiveInitial) {
        cubit.loadLiveStatus();
      }
    });
  }

  void _initializePlayer(String url) async {
    if (url.isEmpty) {
      setState(() {
        _videoController = null;
        _isPlayerInitialized = false;
        _currentStreamUrl = null;
      });
      return;
    }

    // On Web, HLS (.m3u8) streams trigger assertion crashes in debug mode
    // due to timeline parsing issues. We fall back to a safe MP4 stream.
    final playUrl = (kIsWeb && url.contains('.m3u8'))
        ? "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4"
        : url;

    setState(() {
      _isPlayerInitialized = false;
      _currentStreamUrl = url;
    });

    final oldController = _videoController;
    final newController = VideoPlayerController.networkUrl(Uri.parse(playUrl));
    _videoController = newController;

    try {
      await newController.initialize();
      if (_videoController == newController) {
        newController.addListener(_videoPlayerListener);
        setState(() {
          _isPlayerInitialized = true;
        });
        newController.setVolume(_isMuted ? 0.0 : 1.0);
        newController.setLooping(true);
        if (_isPlaying) {
          try {
            if (newController.value.position.isNegative) {
              await newController.seekTo(Duration.zero);
              await Future.delayed(const Duration(milliseconds: 100));
            }
            await newController.play();
          } catch (e) {
            debugPrint("Error playing video on init: $e");
          }
        }
      } else {
        newController.dispose();
      }
    } catch (e) {
      debugPrint("Error initializing video player: $e");
      if (_videoController == newController) {
        setState(() {
          _isPlayerInitialized = false;
        });
      }
      newController.dispose();
    }

    if (oldController != null) {
      oldController.removeListener(_videoPlayerListener);
      await oldController.dispose();
    }
  }

  void _togglePlay() async {
    if (_videoController == null || !_isPlayerInitialized) {
      setState(() {
        _isPlaying = !_isPlaying;
      });
      return;
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      try {
        if (_videoController!.value.position.isNegative) {
          await _videoController!.seekTo(Duration.zero);
          await Future.delayed(const Duration(milliseconds: 100));
        }
        await _videoController!.play();
      } catch (e) {
        debugPrint("Error playing video: $e");
      }
    } else {
      try {
        await _videoController!.pause();
      } catch (e) {
        debugPrint("Error pausing video: $e");
      }
    }
  }

  void _toggleMute() {
    if (_videoController == null || !_isPlayerInitialized) {
      setState(() {
        _isMuted = !_isMuted;
      });
      return;
    }
    setState(() {
      _isMuted = !_isMuted;
      _videoController?.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _videoController?.removeListener(_videoPlayerListener);
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          "Live Broadcast",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppColors.earthColor),
            tooltip: "API Configuration",
            onPressed: () => _showApiConfigDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<LiveCubit, LiveState>(
        builder: (context, state) {
          if (state is LiveLoading || state is LiveInitial) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.themeColor),
              ),
            );
          } else if (state is LiveNoCredentials) {
            return _buildNoCredentialsState(context);
          } else if (state is LiveError) {
            return _buildErrorState(context, state.message);
          } else if (state is LiveLoaded) {
            return _buildLiveContent(context, state.liveStream);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNoCredentialsState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: AppColors.themeColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.vpn_key_rounded,
                size: 64,
                color: AppColors.themeColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "API Credentials Required",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.earthColor,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Connecting to the Live Stream API requires an authorized AIIS API Key and API Secret token.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showApiConfigDialog(context),
              icon: const Icon(Icons.settings_rounded),
              label: const Text("Configure API Credentials"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 72,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            const Text(
              "Failed to Connect",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.read<LiveCubit>().loadLiveStatus(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text("Retry Connection"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.earthColor,
                    side: const BorderSide(color: AppColors.earthColor),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showApiConfigDialog(context),
                  icon: const Icon(Icons.settings_rounded),
                  label: const Text("Update Credentials"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveContent(BuildContext context, LiveStreamModel liveStream) {
    if (liveStream.streamUrl != _currentStreamUrl) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializePlayer(liveStream.streamUrl);
      });
    }

    final statusColor = liveStream.status.toLowerCase() == 'live' ? Colors.red : Colors.grey;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Player Container
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Video Player or fallback thumbnail
                  _videoController != null && _isPlayerInitialized
                      ? Center(
                          child: AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          ),
                        )
                      : Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black87, AppColors.earthColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.live_tv_rounded, size: 64, color: Colors.white24),
                          ),
                        ),
                  // Show loading spinner if controller is initializing
                  if (_videoController != null && !_isPlayerInitialized)
                    const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.themeColor),
                      ),
                    ),
                  // Live badge pulsing overlay
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Row(
                      children: [
                        FadeTransition(
                          opacity: _pulseController,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            liveStream.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Viewer count overlay
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            "${liveStream.viewerCount}",
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Play Center Toggle Overlay
                  if (!_isPlaying)
                    Center(
                      child: IconButton(
                        icon: const Icon(Icons.play_arrow_rounded, size: 64, color: Colors.white),
                        onPressed: _togglePlay,
                      ),
                    ),
                  // Bottom controls overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black87],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_videoController != null && _isPlayerInitialized) ...[
                            VideoProgressIndicator(
                              _videoController!,
                              allowScrubbing: true,
                              padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                              colors: const VideoProgressColors(
                                playedColor: AppColors.themeColor,
                                bufferedColor: Colors.white38,
                                backgroundColor: Colors.white24,
                              ),
                            ),
                          ],
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                ),
                                onPressed: _togglePlay,
                              ),
                              IconButton(
                                icon: Icon(
                                  _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                                  color: Colors.white,
                                ),
                                onPressed: _toggleMute,
                              ),
                              const SizedBox(width: 8),
                              if (_videoController != null && _isPlayerInitialized)
                                Builder(
                                  builder: (context) {
                                    final position = _videoController!.value.position;
                                    final duration = _videoController!.value.duration;
                                    final isLive = duration == Duration.zero || duration.inDays > 1;
                                    final elapsedStr = _formatDuration(position);
                                    final durationStr = isLive ? "LIVE" : _formatDuration(duration);
                                    return Text(
                                      "$elapsedStr / $durationStr",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                                  },
                                ),
                              const Spacer(),
                              const Text(
                                "LIVE",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.fullscreen_rounded, color: Colors.white),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Fullscreen mode simulation")),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Info Details Panel
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "BROADCASTING",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.themeColor,
                    letterSpacing: 1.0,
                  ),
                ),
                if (liveStream.title.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    liveStream.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.earthColor,
                    ),
                  ),
                ],
                if (liveStream.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    liveStream.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.darkColor,
                      height: 1.5,
                    ),
                  ),
                ],
                SizedBox(height: (liveStream.title.isNotEmpty || liveStream.description.isNotEmpty) ? 24 : 12),
                const Divider(),
                const SizedBox(height: 12),
                // Tab Selection for Chat & Schedule
                Row(
                  children: [
                    _buildTabButton(0, "Live Chat", Icons.chat_bubble_outline_rounded),
                    const SizedBox(width: 12),
                    _buildTabButton(1, "Schedule", Icons.schedule_rounded),
                  ],
                ),
                const SizedBox(height: 16),
                _activeTab == 0 ? _buildMockChatPlaceholder() : _buildMockSchedulePlaceholder(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockChatPlaceholder() {
    final mockMessages = [
      {"user": "Mirra", "msg": "Greetings from Pondicherry! Beautiful coverage."},
      {"user": "Lars", "msg": "Sound is super clear. Thank you Auroville TV team!"},
      {"user": "Sujata", "msg": "Om Namo Bhagavate 🙏"},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: mockMessages.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final chat = mockMessages[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.themeColor.withValues(alpha: 0.1),
                    child: Text(
                      chat["user"]![0],
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.themeColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: AppColors.darkColor, fontSize: 13),
                        children: [
                          TextSpan(
                            text: "${chat["user"]}: ",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: chat["msg"]),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Join the conversation...",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.themeColor,
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.themeColor : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.themeColor : Colors.grey.shade200,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.themeColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.darkColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMockSchedulePlaceholder() {
    final scheduleItems = [
      {"time": "09:00 AM", "title": "Auroville Charter Day Celebration", "type": "Archive", "isPast": true},
      {"time": "10:30 AM", "title": "Morning Meditations at Matrimandir", "type": "Meditations", "isPast": true},
      {"time": "12:00 PM", "title": "Interviews with Auroville Units - Natura", "type": "Features", "isCurrent": true},
      {"time": "01:30 PM", "title": "Sustainable Living & Ecology in Auroville", "type": "Documentary"},
      {"time": "03:00 PM", "title": "Auroville Radio TV Cultural Evening", "type": "Music"},
      {"time": "04:30 PM", "title": "Community Dialogue: Building the Future", "type": "Talks"},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: scheduleItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = scheduleItems[index];
        final isCurrent = item["isCurrent"] == true;
        final isPast = item["isPast"] == true;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCurrent ? AppColors.themeColor.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCurrent ? AppColors.themeColor.withValues(alpha: 0.3) : Colors.grey.shade200,
              width: isCurrent ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isCurrent 
                      ? AppColors.themeColor 
                      : (isPast ? Colors.grey.shade100 : AppColors.backgroundLight),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item["time"] as String,
                  style: TextStyle(
                    color: isCurrent 
                        ? Colors.white 
                        : (isPast ? Colors.grey : AppColors.earthColor),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["title"] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isPast ? Colors.grey.shade400 : AppColors.darkColor,
                        decoration: isPast ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item["type"] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: isCurrent ? AppColors.themeColor : Colors.grey,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "ON AIR",
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showApiConfigDialog(BuildContext context) async {
    final liveCubit = context.read<LiveCubit>();
    final secureStorage = liveCubit.secureStorage;

    final initialKey = await secureStorage.getValue(LiveCubit.apiKeyStoreKey) ?? '';
    final initialSecret = await secureStorage.getValue(LiveCubit.apiSecretStoreKey) ?? '';

    if (!context.mounted) return;

    final keyController = TextEditingController(text: initialKey);
    final secretController = TextEditingController(text: initialSecret);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Live Stream API Config",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Enter your AIIS API details below. Credentials will be stored securely on your device.",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: keyController,
                    decoration: const InputDecoration(
                      labelText: "API Key",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.vpn_key_outlined),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? "API Key is required" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: secretController,
                    decoration: const InputDecoration(
                      labelText: "API Secret",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ),
                    obscureText: true,
                    validator: (v) => (v == null || v.trim().isEmpty) ? "API Secret is required" : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            if (initialKey.isNotEmpty || initialSecret.isNotEmpty)
              TextButton(
                onPressed: () {
                  liveCubit.clearCredentials();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Clear Keys"),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  liveCubit.saveCredentials(
                    keyController.text,
                    secretController.text,
                  );
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.themeColor,
                foregroundColor: Colors.white,
              ),
              child: const Text("Save Keys"),
            ),
          ],
        );
      },
    );
  }
}
