import 'package:equatable/equatable.dart';

class LiveStreamModel extends Equatable {
  final String status;
  final String title;
  final String description;
  final String streamUrl;
  final int viewerCount;
  final String thumbnail;
  final String category;
  final String publishDate;

  const LiveStreamModel({
    required this.status,
    required this.title,
    required this.description,
    required this.streamUrl,
    required this.viewerCount,
    required this.thumbnail,
    this.category = '',
    this.publishDate = '',
  });

  LiveStreamModel copyWith({
    String? status,
    String? title,
    String? description,
    String? streamUrl,
    int? viewerCount,
    String? thumbnail,
    String? category,
    String? publishDate,
  }) {
    return LiveStreamModel(
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      streamUrl: streamUrl ?? this.streamUrl,
      viewerCount: viewerCount ?? this.viewerCount,
      thumbnail: thumbnail ?? this.thumbnail,
      category: category ?? this.category,
      publishDate: publishDate ?? this.publishDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'title': title,
      'description': description,
      'stream_url': streamUrl,
      'viewer_count': viewerCount,
      'thumbnail': thumbnail,
      'category': category,
      'publish_date': publishDate,
    };
  }

  factory LiveStreamModel.fromMap(Map<String, dynamic> map) {
    return LiveStreamModel(
      status: (map['status'] ?? 'Offline') as String,
      title: (map['title'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      streamUrl: (map['stream_url'] ?? '') as String,
      viewerCount: (map['viewer_count'] ?? 0) as int,
      thumbnail: (map['thumbnail'] ?? '') as String,
      category: (map['category'] ?? '') as String,
      publishDate: (map['publish_date'] ?? '') as String,
    );
  }

  factory LiveStreamModel.empty() {
    return const LiveStreamModel(
      status: 'Offline',
      title: '',
      description: '',
      streamUrl: '',
      viewerCount: 0,
      thumbnail: '',
      category: '',
      publishDate: '',
    );
  }

  @override
  List<Object> get props => [
        status,
        title,
        description,
        streamUrl,
        viewerCount,
        thumbnail,
        category,
        publishDate,
      ];
}
