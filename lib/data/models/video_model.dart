import 'package:equatable/equatable.dart';

class VideoModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? videoUrl;
  final String thumbnail;
  final String? category;
  final DateTime? publishDate;
  final DateTime? uploadDate;
  final String? formattedDuration;
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
    this.formattedDuration,
    this.durationMinutes,
    this.topicTag,
    this.featured = false,
    this.viewCount = 0,
    this.isLive = false,
    this.published = false,
  });

  // Safe integer parsing helper
  static int? _parseInt(dynamic val) {
    if (val == null) return null;
    if (val is int) return val;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString().trim());
  }

  // Safe boolean parsing helper
  static bool _parseBool(dynamic val) {
    if (val == null) return false;
    if (val is bool) return val;
    if (val is num) return val == 1;
    final str = val.toString().trim().toLowerCase();
    return str == '1' || str == 'true' || str == 'live';
  }

  // Automatic duration string builder
  static String? _parseAutoDuration(dynamic val) {
    if (val == null) return null;
    final str = val.toString().trim();
    if (str.isEmpty || str == '0') return null;

    // Handle "HH:MM:SS" or "MM:SS"
    if (str.contains(':')) {
      final parts = str.split(':');
      if (parts.length == 3) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        return h > 0 ? "$h hr $m min" : "$m min";
      } else if (parts.length == 2) {
        final m = int.tryParse(parts[0]) ?? 0;
        final s = int.tryParse(parts[1]) ?? 0;
        return m > 0 ? "$m min" : "$s sec";
      }
    }

    // Handle integer seconds or minutes
    final numVal = int.tryParse(str);
    if (numVal != null && numVal > 0) {
      if (numVal > 120) {
        // Assuming seconds
        final h = numVal ~/ 3600;
        final m = (numVal % 3600) ~/ 60;
        return h > 0 ? "$h hr $m min" : "$m min";
      }
      return "$numVal min";
    }

    return str.contains("min") ? str : "$str min";
  }

  factory VideoModel.fromMap(Map<String, dynamic> map) {
    final rawDuration = map['duration'] ??
        map['duration_minutes'] ??
        map['video_duration'] ??
        map['length'] ??
        map['total_time'];

    final rawThumbnail = map['thumbnail']?.toString() ??
        map['image']?.toString() ??
        map['thumbnail_url']?.toString() ??
        map['poster']?.toString() ??
        '';

    return VideoModel(
      id: map['id']?.toString() ?? map['name']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      videoUrl: map['video_url']?.toString() ??
          map['video']?.toString() ??
          map['url']?.toString() ??
          map['stream_url']?.toString(),
      thumbnail: rawThumbnail.trim().isNotEmpty
          ? rawThumbnail.trim()
          : "assets/images/thumb.png",
      category: map['category']?.toString() ??
          map['category_name']?.toString() ??
          map['genre']?.toString(),
      publishDate: map['date_and_time'] != null
          ? DateTime.tryParse(map['date_and_time'].toString())
          : (map['publish_date'] != null
              ? DateTime.tryParse(map['publish_date'].toString())
              : null),
      uploadDate: map['upload_date'] != null
          ? DateTime.tryParse(map['upload_date'].toString())
          : null,
      formattedDuration: _parseAutoDuration(rawDuration),
      durationMinutes: _parseInt(
        map['duration_minutes'] ?? map['duration'] ?? map['length'],
      ),
      topicTag: map['topic_tag']?.toString(),
      featured: _parseBool(map['featured']),
      viewCount: _parseInt(map['view_count'] ?? map['views']) ?? 0,
      isLive: _parseBool(map['is_live'] ?? map['isLive']),
      published: _parseBool(map['published']),
    );
  }

  factory VideoModel.fromJson(Map<String, dynamic> json) =>
      VideoModel.fromMap(json);

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

  Map<String, dynamic> toJson() => toMap();

  VideoModel copyWith({
    String? id,
    String? title,
    String? description,
    String? videoUrl,
    String? thumbnail,
    String? category,
    DateTime? publishDate,
    DateTime? uploadDate,
    String? formattedDuration,
    int? durationMinutes,
    String? topicTag,
    bool? featured,
    int? viewCount,
    bool? isLive,
    bool? published,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnail: thumbnail ?? this.thumbnail,
      category: category ?? this.category,
      publishDate: publishDate ?? this.publishDate,
      uploadDate: uploadDate ?? this.uploadDate,
      formattedDuration: formattedDuration ?? this.formattedDuration,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      topicTag: topicTag ?? this.topicTag,
      featured: featured ?? this.featured,
      viewCount: viewCount ?? this.viewCount,
      isLive: isLive ?? this.isLive,
      published: published ?? this.published,
    );
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
        formattedDuration,
        durationMinutes,
        topicTag,
        featured,
        viewCount,
        isLive,
        published,
      ];
}