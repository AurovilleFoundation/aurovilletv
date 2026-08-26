import 'package:equatable/equatable.dart';

class VideoModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnail;
  final String categoryId;
  final DateTime dateTime;
  final bool featured;
  final int viewCount;

  const VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnail,
    required this.categoryId,
    required this.dateTime,
    required this.featured,
    required this.viewCount,
  });

  VideoModel copyWith({
    String? id,
    String? title,
    String? description,
    String? videoUrl,
    String? thumbnail,
    String? categoryId,
    DateTime? dateTime,
    bool? featured,
    int? viewCount,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnail: thumbnail ?? this.thumbnail,
      categoryId: categoryId ?? this.categoryId,
      dateTime: dateTime ?? this.dateTime,
      featured: featured ?? this.featured,
      viewCount: viewCount ?? this.viewCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'thumbnail': thumbnail,
      'category_id': categoryId,
      'date_time': dateTime.toIso8601String(),
      'featured': featured ? 1 : 0,
      'view_count': viewCount,
    };
  }

  factory VideoModel.fromMap(Map<String, dynamic> map) {
    return VideoModel(
      id: map['id'].toString(),
      title: (map['title'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      videoUrl: (map['video_url'] ?? '') as String,
      thumbnail: (map['thumbnail'] ?? '') as String,
      categoryId: (map['category_id'] ?? '').toString(),
      dateTime: map['date_time'] != null 
          ? DateTime.parse(map['date_time'] as String)
          : DateTime.now(),
      featured: map['featured'] == 1 || map['featured'] == true,
      viewCount: (map['view_count'] ?? 0) as int,
    );
  }

  factory VideoModel.fromApi(Map<String, dynamic> map) {
    // Parse publish_date (API uses "publish_date": "2026-07-24 14:00:00")
    DateTime date = DateTime.now();
    if (map['publish_date'] != null) {
      try {
        date = DateTime.parse(map['publish_date'] as String);
      } catch (_) {}
    } else if (map['created_at'] != null) {
      try {
        date = DateTime.parse(map['created_at'] as String);
      } catch (_) {}
    }

    return VideoModel(
      id: map['id'].toString(),
      title: (map['title'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      videoUrl: (map['video_url'] ?? '') as String,
      thumbnail: (map['thumbnail'] ?? '') as String,
      categoryId: (map['category'] ?? '').toString(),
      dateTime: date,
      featured: map['featured'] == 1 || map['featured'] == true,
      viewCount: (map['view_count'] ?? 0) as int,
    );
  }

  @override
  List<Object> get props => [
    id,
    title,
    description,
    videoUrl,
    thumbnail,
    categoryId,
    dateTime,
    featured,
    viewCount,
  ];

  @override
  String toString() {
    return 'VideoModel(id: $id, title: $title)';
  }
}
