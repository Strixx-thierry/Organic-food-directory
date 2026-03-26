import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:organic_food_directory/widgets/guest_view_placeholder.dart';

Widget buildTestWidget({
  required String iconType,
  required String message,
  required String submessage,
  VoidCallback? onSignIn,
}) {
  return MaterialApp(
    home: GuestViewPlaceholder(
      iconType: iconType,
      message: message,
      submessage: submessage,
      onSignIn: onSignIn ?? () {},
    ),
  );
}

void main() {
  group('GuestViewPlaceholder widget', () {
    testWidgets('shows the correct icon based on iconType',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        iconType: 'favorite',
        message: 'No favorites yet',
        submessage: 'Sign in to save items',
      ));

      expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
    });

    testWidgets('displays the message and submessage text',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        iconType: 'person',
        message: 'You are not signed in',
        submessage: 'Please sign in to continue',
      ));

      expect(find.text('You are not signed in'), findsOneWidget);
      expect(find.text('Please sign in to continue'), findsOneWidget);
    });

    testWidgets('Sign In button is visible on screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        iconType: 'list',
        message: 'No lists found',
        submessage: 'Sign in to manage your lists',
      ));

      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('tapping Sign In calls the onSignIn callback',
        (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(buildTestWidget(
        iconType: 'person',
        message: 'Sign in required',
        submessage: 'To view this page',
        onSignIn: () => pressed = true,
      ));

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(pressed, isTrue);
    });
  });
}
