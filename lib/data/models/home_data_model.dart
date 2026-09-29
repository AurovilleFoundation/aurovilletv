import 'package:equatable/equatable.dart';
import 'video_model.dart';
import 'category_model.dart';

class HomeDataModel extends Equatable {
  final VideoModel? liveVideo;
  final List<CategoryModel> categories;
  final List<VideoModel> featuredVideos;
  final List<VideoModel> latestVideos;
  final List<VideoModel> popularVideos;

  const HomeDataModel({
    this.liveVideo,
    required this.categories,
    required this.featuredVideos,
    required this.latestVideos,
    required this.popularVideos,
  });

  factory HomeDataModel.fromMap(Map<String, dynamic> map) {
    VideoModel? live;
    if (map['live'] != null && map['live'] is Map) {
      live = VideoModel.fromApi(Map<String, dynamic>.from(map['live'] as Map));
    }

    final categoriesList = <CategoryModel>[];
    if (map['categories'] != null && map['categories'] is List) {
      for (final cat in map['categories'] as List) {
        categoriesList.add(CategoryModel.fromMap(Map<String, dynamic>.from(cat as Map)));
      }
    }

    final featuredList = <VideoModel>[];
    if (map['featured'] != null && map['featured'] is Map && map['featured']['items'] != null && map['featured']['items'] is List) {
      for (final v in map['featured']['items'] as List) {
        featuredList.add(VideoModel.fromApi(Map<String, dynamic>.from(v as Map)));
      }
    }

    final latestList = <VideoModel>[];
    if (map['latest'] != null && map['latest'] is Map && map['latest']['items'] != null && map['latest']['items'] is List) {
      for (final v in map['latest']['items'] as List) {
        latestList.add(VideoModel.fromApi(Map<String, dynamic>.from(v as Map)));
      }
    }

    final popularList = <VideoModel>[];
    if (map['popular'] != null && map['popular'] is Map && map['popular']['items'] != null && map['popular']['items'] is List) {
      for (final v in map['popular']['items'] as List) {
        popularList.add(VideoModel.fromApi(Map<String, dynamic>.from(v as Map)));
      }
    }

    return HomeDataModel(
      liveVideo: live,
      categories: categoriesList,
      featuredVideos: featuredList,
      latestVideos: latestList,
      popularVideos: popularList,
    );
  }

  @override
  List<Object?> get props => [
        liveVideo,
        categories,
        featuredVideos,
        latestVideos,
        popularVideos,
      ];
}
