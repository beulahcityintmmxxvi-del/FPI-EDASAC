// Basic smoke test: verifies the app widget tree builds without throwing.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:vocational_skills_app/main.dart';
import 'package:vocational_skills_app/core/constants/app_constants.dart';

void main() {
  setUpAll(() async {
    await Hive.initFlutter();
    await Hive.openBox(AppConstants.userBox);
    await Hive.openBox(AppConstants.cacheBox);
  });

  testWidgets('App builds and shows splash screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const VocationalSkillsApp());
    await tester.pump();

    // Just confirm it built without throwing — adjust this to something
    // concrete on your SplashScreen once you want a stricter check.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
