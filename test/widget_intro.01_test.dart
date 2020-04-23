// This test check that IntroPage is displayed and scroll
// Test scroll from "Shoot" page through "Surf" page to "Meet" page
// checking that SKIP and DONE buttons shows correctly.

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

    // Drag from right to left to swap to the second intro page
    //await tester.tap(find.byIcon(Icons.add));
    await tester.fling(find.byType(IntroPage), const Offset(-250.0, 0.0), 10.0);
    await tester.pumpAndSettle();

    // Verify that SKIP is there and we are on the second intro page
    expect(find.text('SKIP'), findsOneWidget);
    expect(find.text('Add books'), findsNothing);
    expect(find.text('Surf'), findsWidgets);
    expect(find.text('Meet'), findsNothing);
    expect(find.text('DONE'), findsNothing);

    // Drag from right to left to swap to the second intro page
    //await tester.tap(find.byIcon(Icons.add));
    await tester.fling(find.byType(IntroPage), const Offset(-250.0, 0.0), 10.0);
    await tester.pumpAndSettle();

    // Verify that SKIP is there and we are on the second intro page
    expect(find.text('SKIP'), findsNothing);
    expect(find.text('Add books'), findsNothing);
    expect(find.text('Surf'), findsNothing);
    expect(find.text('Meet'), findsWidgets);
    expect(find.text('DONE'), findsOneWidget);
  });
}
