import 'package:equatable/equatable.dart';

class VideoModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnail;
  final int categoryId;
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
    int? categoryId,
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
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      videoUrl: map['video_url'] as String,
      thumbnail: map['thumbnail'] as String,
      categoryId: map['category_id'] as int,
      dateTime: DateTime.parse(map['date_time'] as String),
      featured: (map['featured'] as int) == 1,
      viewCount: map['view_count'] as int,
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
