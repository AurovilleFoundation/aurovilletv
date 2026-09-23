import 'package:aurovilletv/utils/theme/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Programmatically generated video thumbnail placeholder widget in Flutter code.
/// Renders a professional placeholder with background image asset fallback,
/// pure Dart gradient styling, and a centered video play icon overlay.
class VideoPlaceholderWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final String? imageUrl;
  final double iconSize;
  final double borderRadius;
  final bool showPlayIcon;

  const VideoPlaceholderWidget({
    super.key,
    this.width,
    this.height,
    this.imageUrl,
    this.iconSize = 24.0,
    this.borderRadius = 12.0,
    this.showPlayIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          color: AppColors.earthColor,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background: Network Image, Asset Image, or Programmatic Gradient Fallback
            _buildBackground(),

            // Subtle dark overlay tint for contrast
            Container(
              color: Colors.black.withValues(alpha: 0.15),
            ),

            // Centered Video Play Icon Overlay
            if (showPlayIcon)
              Center(
                child: Container(
                  width: iconSize * 1.6,
                  height: iconSize * 1.6,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: iconSize,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      final url = imageUrl!.trim();
      if (url.startsWith('http://') || url.startsWith('https://')) {
        return CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          placeholder: (context, url) => _buildAssetPlaceholder(),
          errorWidget: (context, url, error) => _buildAssetPlaceholder(),
        );
      } else if (url.startsWith('assets/')) {
        return Image.asset(
          url,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (context, error, stackTrace) => _buildAssetPlaceholder(),
        );
      }
    }
    return _buildAssetPlaceholder();
  }

  Widget _buildAssetPlaceholder() {
    return Image.asset(
      'assets/images/video_placeholder.jpg',
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      errorBuilder: (context, error, stackTrace) => _buildProgrammaticFallback(),
    );
  }

  /// Pure Dart programmatic fallback container drawn entirely in Flutter code
  Widget _buildProgrammaticFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF8C3A27), // Deep terracotta earth color
            Color(0xFFB85C37), // Warm earth tone
            Color(0xFFD98A5B), // Golden orange
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Background decorative watermark icon
          Center(
            child: Opacity(
              opacity: 0.12,
              child: Icon(
                Icons.spa_rounded,
                size: (height ?? 100) * 0.7,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
