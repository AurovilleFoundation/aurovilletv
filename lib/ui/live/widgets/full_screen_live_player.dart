import 'dart:async';
import 'package:aurovilletv/data/models/live_stream_model.dart';
import 'package:aurovilletv/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class FullScreenLivePlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final LiveStreamModel liveStream;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleMute;
  final AnimationController pulseController;

  const FullScreenLivePlayer({
    super.key,
    required this.controller,
    required this.liveStream,
    required this.onTogglePlay,
    required this.onToggleMute,
    required this.pulseController,
  });

  @override
  State<FullScreenLivePlayer> createState() => _FullScreenLivePlayerState();
}

class _FullScreenLivePlayerState extends State<FullScreenLivePlayer> {
  bool _showControls = true;
  bool _isCover = true; // Full bleed edge-to-edge landscape
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    // Force true landscape mode and immersive sticky display
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    widget.controller.addListener(_videoListener);
    _startHideTimer();
  }

  void _videoListener() {
    if (mounted) {
      setState(() {});
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _restoreOrientation() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    widget.controller.removeListener(_videoListener);
    _restoreOrientation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = widget.controller.value.isPlaying;
    final isMuted = widget.controller.value.volume == 0;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        _hideTimer?.cancel();
        _restoreOrientation();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          bottom: false,
          top: false,
          left: false,
          right: false,
          child: GestureDetector(
            onTap: _toggleControls,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Edge-to-edge Fullscreen Video Player
                SizedBox.expand(
                  child: FittedBox(
                    fit: _isCover ? BoxFit.cover : BoxFit.contain,
                    child: SizedBox(
                      width: widget.controller.value.size.width > 0
                          ? widget.controller.value.size.width
                          : 16,
                      height: widget.controller.value.size.height > 0
                          ? widget.controller.value.size.height
                          : 9,
                      child: VideoPlayer(widget.controller),
                    ),
                  ),
                ),

                // Interactive Controls Overlay
                if (_showControls) ...[
                  // Top Gradient Scrim
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 100,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xB3000000), Colors.transparent],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // Bottom Gradient Scrim
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 120,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Color(0xDD000000)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // Top Header Bar
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                          tooltip: "Exit Fullscreen",
                          onPressed: () {
                            _restoreOrientation();
                            Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.liveStream.title.isNotEmpty ? widget.liveStream.title : "Live Stream",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2E6DB),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  FadeTransition(
                                    opacity: widget.pulseController,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: AppColors.themeColor.withValues(alpha: 0.32),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 9,
                                    height: 9,
                                    decoration: const BoxDecoration(
                                      color: AppColors.themeColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                "WATCH LIVE",
                                style: TextStyle(
                                  color: AppColors.earthColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Center Play/Pause Toggle Button
                  Center(
                    child: IconButton(
                      iconSize: 68,
                      icon: Icon(
                        isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      onPressed: () {
                        widget.onTogglePlay();
                        _startHideTimer();
                      },
                    ),
                  ),

                  // Bottom Control Bar
                  Positioned(
                    bottom: MediaQuery.of(context).padding.bottom + 8,
                    left: 12,
                    right: 12,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VideoProgressIndicator(
                          widget.controller,
                          allowScrubbing: true,
                          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                          colors: const VideoProgressColors(
                            playedColor: AppColors.themeColor,
                            bufferedColor: Colors.white38,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                widget.onTogglePlay();
                                _startHideTimer();
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                widget.onToggleMute();
                                _startHideTimer();
                              },
                            ),
                            const Spacer(),
                            // Aspect Ratio Fill / Fit Toggle
                            IconButton(
                              icon: Icon(
                                _isCover ? Icons.fit_screen_rounded : Icons.crop_free_rounded,
                                color: Colors.white,
                              ),
                              tooltip: _isCover ? "Fit to screen" : "Fill screen",
                              onPressed: () {
                                setState(() {
                                  _isCover = !_isCover;
                                });
                                _startHideTimer();
                              },
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "LIVE",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.fullscreen_exit_rounded, color: Colors.white),
                              tooltip: "Exit Fullscreen",
                              onPressed: () {
                                _restoreOrientation();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
