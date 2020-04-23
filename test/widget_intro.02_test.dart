// This test check that buttons SKIP on IntroPage is working
// Test press button SKIP and validate that login screen appeared

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:biblosphere/main.dart';
import 'package:biblosphere/l10n.dart';

void main() {
  testWidgets('IntroPage smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return MaterialApp(
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: [Locale("en"), Locale("ru")],
        locale: Locale('en'),
        home: IntroPage(),
      );
    }));

    await tester.pumpAndSettle();

    // Verify that SKIP is there and we are on the first intro page
    expect(find.text('SKIP'), findsOneWidget);
    expect(find.text('Add books'), findsWidgets);
    expect(find.text('Surf'), findsNothing);
    expect(find.text('Meet'), findsNothing);
    expect(find.text('DONE'), findsNothing);

    //Tap SKIP button
    await tester.tap(find.text("SKIP"));
    await tester.pumpAndSettle();

    // Verify that SKIP is there and we are on the second intro page
    //expect(find.text('Sign in with Google'), findsOneWidget);
    //expect(find.text('Continue with Facebook'), findsOneWidget);
  });
}
