// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gm_image_cleaner/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GoodMorningCleanerApp());

    // Verify that the app title is present
    expect(find.text('Good Morning Image Cleaner'), findsOneWidget);

    // Verify that the app initializes without errors
    expect(tester.takeException(), isNull);
  });
}
