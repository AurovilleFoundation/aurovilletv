// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:aurovilletv/data/di/service_locator.dart';
import 'package:aurovilletv/data/models/enums.dart';
import 'package:aurovilletv/utils/app_constants.dart';
import 'package:aurovilletv/ui/app/my_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    if (!getIt.isRegistered<AppConstants>()) {
      await setupServiceLocator(appType: AppType.dev);
    }
  });

  testWidgets('App renders main screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MyApp), findsOneWidget);
  });
}
