import 'package:equatable/equatable.dart';

class LiveStreamModel extends Equatable {
  final String status;
  final String title;
  final String description;
  final String streamUrl;
  final int viewerCount;
  final String thumbnail;

  const LiveStreamModel({
    required this.status,
    required this.title,
    required this.description,
    required this.streamUrl,
    required this.viewerCount,
    required this.thumbnail,
  });

  LiveStreamModel copyWith({
    String? status,
    String? title,
    String? description,
    String? streamUrl,
    int? viewerCount,
    String? thumbnail,
  }) {
    return LiveStreamModel(
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      streamUrl: streamUrl ?? this.streamUrl,
      viewerCount: viewerCount ?? this.viewerCount,
      thumbnail: thumbnail ?? this.thumbnail,
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
    );
  }

  factory LiveStreamModel.empty() {
    return const LiveStreamModel(
      status: 'Offline',
      title: 'Auroville TV Live Stream',
      description: 'Currently we are offline. Please check back later.',
      streamUrl: '',
      viewerCount: 0,
      thumbnail: '',
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
      ];
}
