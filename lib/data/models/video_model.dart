import 'package:equatable/equatable.dart';

class VideoModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? videoUrl;
  final String thumbnail;
  final String? category;
  final DateTime? publishDate;
  final DateTime? uploadDate; // ✅ new field
  final int? durationMinutes;
  final String? topicTag;
  final bool featured;
  final int viewCount;
  final bool isLive;
  final bool published;

  const VideoModel({
    required this.id,
    required this.title,
    required this.description,
    this.videoUrl,
    required this.thumbnail,
    this.category,
    this.publishDate,
    this.uploadDate,
    this.durationMinutes,
    this.topicTag,
    this.featured = false,
    this.viewCount = 0,
    this.isLive = false,
    this.published = false,
  });

  factory VideoModel.fromMap(Map<String, dynamic> map) {
    // ✅ robust duration parsing
    int? parseDuration(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String && value.contains(':')) {
        // handle "28:00" → take minutes part
        final parts = value.split(':');
        final minutes = int.tryParse(parts[0]) ?? 0;
        return minutes;
      }
      return int.tryParse(value.toString());
    }

    return VideoModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      videoUrl: map['video_url']?.toString(),
      thumbnail: (map['thumbnail']?.toString().isNotEmpty ?? false)
          ? map['thumbnail'].toString()
          : "assets/images/thumb.png",
      category: map['category']?.toString(),
      publishDate: map['date_and_time'] != null
          ? DateTime.tryParse(map['date_and_time'].toString())
          : (map['publish_date'] != null
              ? DateTime.tryParse(map['publish_date'].toString())
              : null),
      uploadDate: map['upload_date'] != null
          ? DateTime.tryParse(map['upload_date'].toString())
          : null,
      durationMinutes: parseDuration(map['duration_minutes']),
      topicTag: map['topic_tag']?.toString(),
      featured: (map['featured'] is int
          ? (map['featured'] == 1)
          : (map['featured'].toString() == 'true')),
      viewCount: map['view_count'] is int
          ? map['view_count'] as int
          : int.tryParse(map['view_count'].toString()) ?? 0,
      isLive: (map['is_live'] is int
          ? (map['is_live'] == 1)
          : (map['is_live'].toString() == 'true')),
      published: (map['published'] is int
          ? (map['published'] == 1)
          : (map['published'].toString() == 'true')),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'thumbnail': thumbnail,
      'category': category,
      'publish_date': publishDate?.toIso8601String(),
      'upload_date': uploadDate?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'topic_tag': topicTag,
      'featured': featured ? 1 : 0,
      'view_count': viewCount,
      'is_live': isLive ? 1 : 0,
      'published': published ? 1 : 0,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        videoUrl,
        thumbnail,
        category,
        publishDate,
        uploadDate,
        durationMinutes,
        topicTag,
        featured,
        viewCount,
        isLive,
        published,
      ];
}
