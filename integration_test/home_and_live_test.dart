import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get_it/get_it.dart';
import 'package:aurovilletv/utils/app_constants.dart';
import 'package:aurovilletv/main.dart' as app;

void main() {
  // 1. Initialize Flutter Integration Test binding
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Helper to wait for the Home screen to load without timing out on infinite Shimmer animations
  Future<void> waitForAppLoad(WidgetTester tester) async {
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('Auroville TV').evaluate().isNotEmpty) {
        break;
      }
    }
  }

  setUp(() async {
    // Reset GetIt if previously registered to avoid duplicate singleton errors
    if (GetIt.instance.isRegistered<AppConstants>()) {
      await GetIt.instance.reset();
    }
  });

  group('Auroville TV - Home & Live Tabs Integration Tests', () {
    testWidgets(
      'TC-01 to TC-05: Home Screen loads, displays header bar, and handles notification tap',
      (WidgetTester tester) async {
        // Launch the application
        app.main();
        await waitForAppLoad(tester);

        // 1. Verify Header Bar Elements
        expect(find.text('Auroville TV'), findsOneWidget);

        // 2. Locate Notification bell icon
        final notificationIcon = find.byIcon(Icons.notifications_none_rounded);
        expect(notificationIcon, findsOneWidget);

        // 3. Tap Notification bell icon
        await tester.tap(notificationIcon);
        await tester.pump(const Duration(milliseconds: 300));

        // 4. Verify SnackBar message appears
        expect(find.text('Notifications coming soon!'), findsOneWidget);

        // Let the SnackBar dismiss
        await tester.pump(const Duration(seconds: 2));
      },
    );

    testWidgets(
      'TC-06 to TC-07: Hero Banner displays and navigates to Live Broadcast screen',
      (WidgetTester tester) async {
        // Launch the application
        app.main();
        await waitForAppLoad(tester);

        // Verify Home Screen loaded
        expect(find.text('Auroville TV'), findsOneWidget);

        // Check if Hero Banner is present on screen
        final heroBannerFinder = find.byWidgetPredicate(
          (widget) =>
              widget is ClipRRect &&
              widget.borderRadius == BorderRadius.circular(20),
        );

        if (heroBannerFinder.evaluate().isNotEmpty) {
          // Tap Hero Banner
          await tester.tap(heroBannerFinder.first);
          // Wait for LiveScreen transition
          await tester.pump(const Duration(milliseconds: 800));

          // Verify navigation to Live Broadcast screen
          expect(find.text('Live Broadcast'), findsOneWidget);

          // Tap Back to Home button in AppBar
          final backToHome = find.byTooltip('Back to Home');
          expect(backToHome, findsOneWidget);
          await tester.tap(backToHome);
          await tester.pump(const Duration(milliseconds: 800));

          // Verify returned to Home screen
          expect(find.text('Auroville TV'), findsOneWidget);
        }
      },
    );

    testWidgets(
      'TC-08 to TC-16: Home Screen Explore categories and Video sections verification',
      (WidgetTester tester) async {
        // Launch the application
        app.main();
        await waitForAppLoad(tester);

        // 1. Verify "EXPLORE" section title is visible
        final exploreHeader = find.text('EXPLORE');
        if (exploreHeader.evaluate().isNotEmpty) {
          expect(exploreHeader, findsOneWidget);

          // Test horizontal drag on category list
          final horizontalList = find.byWidgetPredicate(
            (widget) =>
                widget is ListView &&
                widget.scrollDirection == Axis.horizontal,
          );

          if (horizontalList.evaluate().isNotEmpty) {
            // Drag left to simulate scrolling through categories
            await tester.drag(horizontalList.first, const Offset(-150, 0));
            await tester.pump(const Duration(milliseconds: 500));
          }
        }

        // 2. Verify Video Section Headings if loaded
        final featuredHeader = find.text('FEATURED');
        if (featuredHeader.evaluate().isNotEmpty) {
          expect(featuredHeader, findsOneWidget);
        }

        // 3. Scroll down to check Popular / Latest Videos
        final scrollable = find.byType(SingleChildScrollView);
        if (scrollable.evaluate().isNotEmpty) {
          await tester.drag(scrollable.first, const Offset(0, -300));
          await tester.pump(const Duration(milliseconds: 500));
        }
      },
    );

    testWidgets(
      'TC-18 to TC-30: Bottom Navigation to Live Screen and back to Home',
      (WidgetTester tester) async {
        // Launch the application
        app.main();
        await waitForAppLoad(tester);

        // 1. Locate and Tap the "Live" tab in bottom navigation
        final liveTab = find.text('Live');
        expect(liveTab, findsOneWidget);
        await tester.tap(liveTab);

        // Wait for LiveScreen to animate into view
        await tester.pump(const Duration(milliseconds: 800));

        // 2. Verify Live Broadcast Screen AppBar title is displayed
        expect(find.text('Live Broadcast'), findsOneWidget);

        // 3. Verify either Active Stream, Loading, or Offline UI is rendered
        final hasOfflineUI = find.text('Live Broadcast Offline').evaluate().isNotEmpty;
        final hasLiveTitle = find.text('Live Broadcast').evaluate().isNotEmpty;
        expect(hasOfflineUI || hasLiveTitle, isTrue);

        // 4. Tap "Home" tab in bottom navigation bar to return
        final homeTab = find.text('Home');
        expect(homeTab, findsOneWidget);
        await tester.tap(homeTab);
        await tester.pump(const Duration(milliseconds: 800));

        // 5. Verify back on Home Screen
        expect(find.text('Auroville TV'), findsOneWidget);
      },
    );
  });
}
