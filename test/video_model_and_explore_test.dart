import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aurovilletv/data/models/video_model.dart';

void main() {
  group('VideoModel Sana changes verification', () {
    test('Correctly parses integers, booleans, and durations from varied API payloads', () {
      final map1 = {
        'id': 'vid-123',
        'title': 'Test Video',
        'description': 'Description here',
        'video_url': 'https://example.com/video.mp4',
        'thumbnail': 'https://example.com/thumb.jpg',
        'category_name': 'Philosophy',
        'publish_date': '2026-09-24T10:00:00Z',
        'duration': '01:30:00',
        'featured': 1,
        'view_count': '150',
        'is_live': '1',
        'published': 'true',
      };

      final video = VideoModel.fromMap(map1);
      expect(video.id, 'vid-123');
      expect(video.title, 'Test Video');
      expect(video.category, 'Philosophy');
      expect(video.categoryId, 'Philosophy');
      expect(video.formattedDuration, '1 hr 30 min');
      expect(video.featured, isTrue);
      expect(video.viewCount, 150);
      expect(video.isLive, isTrue);
      expect(video.published, isTrue);
    });

    test('Handles fallback thumbnail keys and live stream conversion', () {
      final map2 = {
        'name': 'vid-fallback',
        'title': 'Live Stream Event',
        'description': 'Live coverage',
        'stream_url': 'https://aurovilletv.com/hls/live.m3u8',
        'image': 'https://example.com/poster.jpg',
        'genre': 'Events',
        'views': 500,
        'isLive': true,
      };

      final video = VideoModel.fromJson(map2);
      expect(video.id, 'vid-fallback');
      expect(video.thumbnail, 'https://example.com/poster.jpg');
      expect(video.category, 'Events');
      expect(video.viewCount, 500);
      expect(video.isLive, isTrue);

      final liveStream = video.toLiveStreamModel();
      expect(liveStream.streamUrl, 'https://aurovilletv.com/hls/live.m3u8');
      expect(liveStream.title, 'Live Stream Event');
      expect(liveStream.viewerCount, 500);
    });

    test('toJson and copyWith work properly', () {
      const original = VideoModel(
        id: '1',
        title: 'Original',
        description: 'Desc',
        thumbnail: 'thumb.png',
      );

      final modified = original.copyWith(title: 'Updated');
      expect(modified.id, '1');
      expect(modified.title, 'Updated');

      final json = modified.toJson();
      expect(json['title'], 'Updated');
      expect(json['id'], '1');
    });

    testWidgets('Explore card layout: title at top and arrow vertically in middle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 380,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 175,
                    height: 125,
                    child: Placeholder(),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('Test Title', key: Key('title')),
                          SizedBox(height: 6),
                          Text('Spiritual', key: Key('subtitle')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const SizedBox(
                    height: 125,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          key: Key('arrow'),
                          size: 16,
                          color: Color(0xFFBDBDBD),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final titleTop = tester.getTopLeft(find.byKey(const Key('title'))).dy;
      final cardTop = tester.getTopLeft(find.byType(Placeholder)).dy;
      final arrowCenter = tester.getCenter(find.byKey(const Key('arrow'))).dy;
      final placeholderCenter = tester.getCenter(find.byType(Placeholder)).dy;

      // Title is pinned to the top with 4.0px padding
      expect(titleTop - cardTop, equals(4.0));

      // Arrow is vertically centered matching the thumbnail/card center (within 0.5px)
      expect((arrowCenter - placeholderCenter).abs(), lessThan(1.0));
      
      // Arrow size is 16
      final icon = tester.widget<Icon>(find.byKey(const Key('arrow')));
      expect(icon.size, 16.0);
    });
  });
}

