import 'dart:async';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

// Command line to generate dart code for localization
//flutter packages pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/l10n.dart
//flutter packages pub run intl_translation:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/l10n.dart lib/l10n/intl_ru.arb lib/l10n/intl_en.arb lib/l10n/intl_messages.arb
import 'l10n/messages_all.dart';

class S {
  static Future<S> load(Locale locale) {
    final String name =
        locale.countryCode == null ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return new S();
    });
  }

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  // main.dart
  String get title {
    return Intl.message('Biblosphere',
        name: 'title', desc: 'The application title');
  }

  String get introShootHint {
    return Intl.message(
        'Shoot your bookcase and share to neighbours and tourists. Your books attract likeminded people.',
        name: 'introShootHint');
  }

  String get introShoot {
    return Intl.message('Shoot', name: 'introShoot');
  }

  String get introSurfHint {
    return Intl.message(
        'App shows bookcases in 200 km around you sorted by distance. Get access to wide variaty of books.',
        name: 'introSurfHint');
  }

  String get introSurf {
    return Intl.message('Surf', name: 'introSurf');
  }

  String get introMeetHint {
    return Intl.message(
        'Contact owner of the books you like and arrange appointment to get new books to read.',
        name: 'introMeetHint');
  }

  String get introDone {
    return Intl.message('DONE', name: 'introDone');
  }

  String get introSkip {
    return Intl.message('SKIP', name: 'introSkip');
  }

  String get introMeet {
    return Intl.message('Meet', name: 'introMeet');
  }

  String get loginAgree1 {
    return Intl.message('By clicking sign in button below, you agree \n to our',
        name: 'loginAgree1');
  }

  String get loginAgree2 {
    return Intl.message('end user licence agreement', name: 'loginAgree2');
  }

  String get loginAgree3 {
    return Intl.message('\nand that you read our ', name: 'loginAgree3');
  }

  String get loginAgree4 {
    return Intl.message('privacy policy', name: 'loginAgree4');
  }

  String get blockUser {
    return Intl.message('Block abusive user', name: 'blockUser');
  }

  String get logout {
    return Intl.message('Logout', name: 'logout');
  }

  // camera.dart
  String get deleteShelf {
    return Intl.message('Delete your bookshelf', name: 'deleteShelf');
  }

  String get shareShelf {
    return Intl.message('Share your bookshelf', name: 'shareShelf');
  }

  String get loading {
    return Intl.message('Loading...', name: 'loading');
  }

  String get notBooks {
    return Intl.message('Hey, this does not look like a bookshelf to me.', name: 'notBooks');
  }

  String get addShelf {
    return Intl.message('Add your bookshelf', name: 'addShelf');
  }

// bookshelf.dart
  String get zoom {
    return Intl.message('ZOOM', name: 'zoom');
  }

  String get km {
    return Intl.message(' km', name: 'km');
  }

  String get reportedPhoto {
    return Intl.message('This photo reported as objectionable content.', name: 'reportedPhoto');
  }

  String get reportShelf {
    return Intl.message('Report objectionable content', name: 'reportShelf');
  }

  String get seeLocation {
    return Intl.message('See location', name: 'seeLocation');
  }

  String get messageOwner {
    return Intl.message('Message owner', name: 'messageOwner');
  }

// chat.dart
  String get chat {
    return Intl.message('CHAT', name: 'chat');
  }

  String get nothingToSend {
    return Intl.message('Nothing to send', name: 'nothingToSend');
  }

  String get typeMsg {
    return Intl.message('Type your message...', name: 'typeMsg');
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ru'].contains(locale.languageCode);
  }

  @override
  Future<S> load(Locale locale) {
    return S.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<S> old) {
    return false;
  }
}
