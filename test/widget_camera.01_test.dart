// This test check that buttons DONE on IntroPage is working
// Test scroll all intro pages, press button DONE and validate
// that login screen appeared

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:biblosphere/camera.dart';
import 'package:biblosphere/l10n.dart';
import 'package:biblosphere/const.dart';

class FirebaseAuthMock extends Mock implements FirebaseAuth {}

final FirebaseAuth _auth = new FirebaseAuthMock();

void main() async {
  FirebaseUser user = await _auth.signInWithEmailAndPassword(
      email: 'tester2@biblosphere.org', password: '123456');

  testWidgets('IntroPage smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(Builder(builder: (BuildContext context) {
      return MaterialApp(
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: [Locale("en"), Locale("ru")],
        locale: Locale('en'),
        home: Home(
            currentUser: new User(
                id: user.uid, name: user.displayName, photo: user.photoUrl)),
      );
    }));

    await tester.pumpAndSettle();

    // Verify that take photo button is there
    expect(find.byIcon(Icons.photo_camera), findsOneWidget);
  });
}
