import 'dart:async';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

// Command line to generate dart code for localization
//flutter packages pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/l10n.dart
//flutter packages pub run intl_translation:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/l10n.dart lib/l10n/intl_ru.arb lib/l10n/intl_en.arb lib/l10n/intl_it.arb lib/l10n/intl_messages.arb
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
    return Intl.message(
        'By clicking sign in button below, you agree \n to our ',
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

  String get settings {
    return Intl.message('Settings', name: 'settings');
  }

  String get shelfSettings {
    return Intl.message('Bookshelf settings', name: 'shelfSettings');
  }

  // end of main.dart

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
    return Intl.message('Hey, this does not look like a bookshelf to me.',
        name: 'notBooks');
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
    return Intl.message('This photo reported as objectionable content.',
        name: 'reportedPhoto');
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

  String get blockedChat {
    return Intl.message('Blocked', name: 'blockedChat');
  }

  String get confirmReportPhoto {
    return Intl.message('Do you want to report this photo as abusive?',
        name: 'confirmReportPhoto');
  }

  String get yes {
    return Intl.message('Yes', name: 'yes');
  }

  String get no {
    return Intl.message('No', name: 'no');
  }

  String get confirmBlockUser {
    return Intl.message('Do you want to block this user?',
        name: 'confirmBlockUser');
  }

  String get favorite {
    return Intl.message('Add shelf to favorite', name: 'favorite');
  }

  String get drawerHeader {
    return Intl.message('Choose mode', name: 'drawerHeader');
  }

  String get bookshelves {
    return Intl.message('Bookshelves', name: 'bookshelves');
  }

  String get books {
    return Intl.message('Books', name: 'books');
  }

  String get read {
    return Intl.message('Read', name: 'read');
  }

  String get meet {
    return Intl.message('Meet', name: 'meet');
  }

  String get explore {
    return Intl.message('Explore', name: 'explore');
  }

  String get share {
    return Intl.message('Share', name: 'share');
  }

  String get borrow {
    return Intl.message('Borrow', name: 'borrow');
  }

  String get earn {
    return Intl.message('Earn', name: 'earn');
  }

  String get welcome {
    return Intl.message('Welcome', name: 'welcome');
  }

  String get shareBooks {
    return Intl.message(
        'I\'m sharing my books on Biblosphere. Join me to read it.',
        name: 'shareBooks');
  }

  String get shareWishlist {
    return Intl.message(
        'I\'m sharing my book wishlist on Biblosphere. Join me.',
        name: 'shareWishlist');
  }

  String get shareBookshelf {
    return Intl.message(
        'That\'s my bookshelf. Join Biblosphere to share books and find like-minded people.',
        name: 'shareBookshelf');
  }

  String get addYourBook {
    return Intl.message('Add your book', name: 'addYourBook');
  }

  String get addToWishlist {
    return Intl.message('Add to Wishlist', name: 'addToWishlist');
  }

  String get yourBiblosphere {
    return Intl.message('Your Biblosphere', name: 'yourBiblosphere');
  }

  String get myBooksItem {
    return Intl.message('My books', name: 'myBooksItem');
  }

  String get myBooksTitle {
    return Intl.message('MY BOOKS', name: 'myBooksTitle');
  }

  String get noBooks {
    return Intl.message(
        'You don\'t have any books in Biblosphere. Add it manually or import from Goodreads.',
        name: 'noBooks');
  }

  String get myBookshelvesItem {
    return Intl.message('My bookshelves', name: 'myBookshelvesItem');
  }

  String get myBookshelvesTitle {
    return Intl.message('MY BOOKSHELVES', name: 'myBookshelvesTitle');
  }

  String get noBookshelves {
    return Intl.message(
        'You don\'t have any bookshelves in Biblosphere. Make a photo of your bookshelf to share with neighbours.',
        name: 'noBookshelves');
  }

  String get myWishlistItem {
    return Intl.message('My wishlist', name: 'myWishlistItem');
  }

  String get myWishlistTitle {
    return Intl.message('MY WISHLIST', name: 'myWishlistTitle');
  }

  String get noWishes {
    return Intl.message(
        'You don\'t have any books in your wishlist. Add it manually or import from Goodreads.',
        name: 'noWishes');
  }

  String get addYourBookshelf {
    return Intl.message('Add your bookshelf', name: 'addYourBookshelf');
  }

  String get makePhotoOfShelf {
    return Intl.message('Make a photo of your bookshelf',
        name: 'makePhotoOfShelf');
  }

  String get recentWishes {
    return Intl.message('Recent wishes:', name: 'recentWishes');
  }

  String get noMatchForWishlist {
    return Intl.message(
        'Hey, right now nodody around you has the books from your wishlist. They will be shown here once someone registers them.\nSpread the word about Biblosphere to make it happen sooner. And add more books to your wishlist.',
        name: 'noMatchForWishlist');
  }

  String get shelves {
    return Intl.message('Shelves', name: 'shelves');
  }

  String get wished {
    return Intl.message('Wished', name: 'wished');
  }

  String get noMatchForBooks {
    return Intl.message(
        'Here you\'ll see people who wish your books once they are registered. To make it happen add more books and spread the word about Biblosphere.',
        name: 'noMatchForBooks');
  }

  String get people {
    return Intl.message('People', name: 'people');
  }

  String wishToRead(name, title) {
    return Intl.message("$name wish to read your book \'$title\'",
        name: 'wishToRead', args: [name, title]);
  }

  String get yourGoodreads {
    return Intl.message('Your Goodreads', name: 'yourGoodreads');
  }

  String get linkToGoodreads {
    return Intl.message('Link your Goodreads', name: 'linkToGoodreads');
  }

  String get importYouBooks {
    return Intl.message('Import your books to Biblosphere',
        name: 'importYouBooks');
  }

  String get linkYourAccount {
    return Intl.message('Link your Goodreads account', name: 'linkYourAccount');
  }

  String get useCurrentLocation {
    return Intl.message('Use current location for import',
        name: 'useCurrentLocation');
  }

  String get importToWishlist {
    return Intl.message('Import to Wishlist:', name: 'importToWishlist');
  }

  String get importToBooks {
    return Intl.message('Import to available books:', name: 'importToBooks');
  }

  String get scanISBN {
    return Intl.message('Scan ISBN from the back of the book',
        name: 'scanISBN');
  }

  String get enterTitle {
    return Intl.message('Enter title/author', name: 'enterTitle');
  }

  String get add {
    return Intl.message('Add', name: 'add');
  }

  String get ok {
    return Intl.message('Ok', name: 'ok');
  }

  String bookCount(int count) {
    return Intl.plural(
      count,
      zero: 'No books',
      one: '$count book',
      other: '$count books',
      args: [count],
      name: 'bookCount',
    );
  }

  String shelfCount(int count) {
    return Intl.plural(
      count,
      zero: 'No bookshelves',
      one: '$count bookshelf',
      other: '$count bookshelves',
      args: [count],
      name: 'shelfCount',
    );
  }

  String wishCount(int count) {
    return Intl.plural(
      count,
      zero: 'No wishes',
      one: '$count wish',
      other: '$count wishes',
      args: [count],
      name: 'wishCount',
    );
  }

  String get loadPhotoOfShelf {
    return Intl.message('Load shelf photo from galery', name: 'loadPhotoOfShelf');
  }


  String get myBorrowedBooksItem {
    return Intl.message('Borrowed books', name: 'myBorrowedBooksItem');
  }


  String get myBorrowedBooksTitle {
    return Intl.message('BORROWED BOOKS', name: 'myBorrowedBooksTitle');
  }

  String get myLendedBooksItem {
    return Intl.message('Lent books', name: 'myLendedBooksItem');
  }

  String get myLendedBooksTitle {
    return Intl.message('LENT BOOKS', name: 'myLendedBooksTitle');
  }

  String get noBorrowedBooks {
    return Intl.message('You do not have any borrowed books', name: 'noBorrowedBooks');
  }

  String get noLendedBooks {
    return Intl.message('You do not have any lent books', name: 'noLendedBooks');
  }

  String get outbox {
    return Intl.message('Books you are giving away', name: 'outbox');
  }

  String get cart {
    return Intl.message('Books you are going to take', name: 'cart');
  }

  String get addToCart {
    return Intl.message('Add book to your cart', name: 'addToCart');
  }

  String get addToOutbox {
    return Intl.message('Add book to your outbox', name: 'addToOutbox');
  }

  String get myCartTitle {
    return Intl.message('MY CART', name: 'myCartTitle');
  }

  String get noItemsInCart {
    return Intl.message('Your cart is empty. Add books from the list of the books or your matched wishes.', name: 'noItemsInCart');
  }

  String get myOutboxTitle {
    return Intl.message('MY OUTBOX', name: 'myOutboxTitle');
  }

  String get noItemsInOutbox {
    return Intl.message('Your outbox is empty. Wait for people to request your books or offer your books in matched books.', name: 'noItemsInOutbox');
  }

  String get messageRecepient {
    return Intl.message('Chat with book recepient.', name: 'messageRecepient');
  }

  String cartRequestCancel(name, title) {
    return Intl.message("Wait for user \'$name\' to accept your request of his book \'$title\'. Chat to facilitate.",
        name: 'cartRequestCancel', args: [name, title]);
  }

  String cartRequestAccepted(name, title) {
    return Intl.message("User \'$name\' has accepted your request for his book \'$title\'. Please arrange handover and confirm on receive.",
        name: 'cartRequestAccepted', args: [name, title]);
  }

  String cartRequestRejected(name, title) {
    return Intl.message("User \'$name\' has rejected your request for his book \'$title\'. You can chat to get explamations.",
        name: 'cartRequestRejected', args: [name, title]);
  }

  String cartReturnConfirm(name, title) {
    return Intl.message("User \'$name\' wish to return your book \'$title\'. Please arrange handover.",
        name: 'cartReturnConfirm', args: [name, title]);
  }

  String cartOfferConfirmReject(name, title) {
    return Intl.message("User \'$name\' offer you his book \'$title\'. Please arrange handover and confirm on receive. Or reject in case you are not interested.",
        name: 'cartOfferConfirmReject', args: [name, title]);
  }

  String outboxRequestAcceptReject(name, title) {
    return Intl.message("User \'$name\' request your book \'$title\'. Please accept or reject. Chat for more details.",
        name: 'outboxRequestAcceptReject', args: [name, title]);
  }

  String outboxRequestAccepted(name, title) {
    return Intl.message("Please arrange handover of book \'$title\' to user \'$name\'. Chat to coordinate.",
        name: 'outboxRequestAccepted', args: [name, title]);
  }

  String outboxRequestConfirmed(name, title) {
    return Intl.message("Handover of book \'$title\' to user \'$name\' confirmed. You can see this book in MY LENT books.",
        name: 'outboxRequestConfirmed', args: [name, title]);
  }

  String outboxRequestCanceled(name, title) {
    return Intl.message("User \'$name\' canceled request for your book \'$title\'.",
        name: 'outboxRequestCanceled', args: [name, title]);
  }

  String outboxReturnAccepted(name, title) {
    return Intl.message("Arrange handover of book \'$title\' to user \'$name\'. Chat to facilitate.",
        name: 'outboxReturnAccepted', args: [name, title]);
  }

  String outboxReturnConfirmed(name, title) {
    return Intl.message("User \'$name\' confirmed handover of the book \'$title\'.",
        name: 'outboxReturnConfirmed', args: [name, title]);
  }

  String outboxOfferAccepted(name, title) {
    return Intl.message("You've offered book \'$title\' to user \'$name\'. Please chat to arrange handover.",
        name: 'outboxOfferAccepted', args: [name, title]);
  }

  String outboxOfferConfirmed(name, title) {
    return Intl.message("User \'$name\' confirmed handover of book \'$title\'. You can see this book in your MY LENT books.",
        name: 'outboxOfferConfirmed', args: [name, title]);
  }

  String outboxOfferRejected(name, title) {
    return Intl.message("User \'$name\' rejected your offer for book \'$title\'. You can chat to get details.",
        name: 'outboxOfferRejected', args: [name, title]);
  }

  String get transitAccept {
    return Intl.message('Accept', name: 'transitAccept');
  }

  String get transitConfirm {
    return Intl.message('Confirm', name: 'transitConfirm');
  }

  String get transitReject {
    return Intl.message('Reject', name: 'transitReject');
  }

  String get transitCancel {
    return Intl.message('Cancel', name: 'transitCancel');
  }

  String get transitOk {
    return Intl.message('Ok', name: 'transitOk');
  }

  String lentBookText(name, title) {
    return Intl.message("Your book \'$title\' now with user \'$name\'. Chat with him to remind about return.",
        name: 'lentBookText', args: [name, title]);
  }

  String borrowedBookText(name, title) {
    return Intl.message("Book \'$title\' belong to user \'$name\'. Press outbox button below to initiate return.",
        name: 'borrowedBookText', args: [name, title]);
  }

  String get shelfDeleted {
    return Intl.message('Bookshelf has been deleted', name: 'shelfDeleted');
  }

  String get shelfAdded {
    return Intl.message('New bookshelf has been added', name: 'shelfAdded');
  }

  String get wishDeleted {
    return Intl.message('Book has been deleted from your wishlist', name: 'wishDeleted');
  }

  String get wishAdded {
    return Intl.message('Book has been added to your wishlist', name: 'wishAdded');
  }

  String get bookDeleted {
    return Intl.message('Book has been deleted from your library', name: 'bookDeleted');
  }

  String get bookAdded {
    return Intl.message('Book has been added to your library', name: 'bookAdded');
  }

  String get isbnNotFound {
    return Intl.message('Book is not found by ISBN', name: 'isbnNotFound');
  }

  String get transitInitiated {
    return Intl.message('Handover process initiated for the book', name: 'transitInitiated');
  }

  String userBalance(balance) {
    return Intl.message("Balance ${balance} \u{03BB}",
        name: 'userBalance', args: [balance]);
  }

  String bookLanguage(lang) {
    return Intl.message("Language: $lang",
        name: 'bookLanguage', args: [lang]);
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ru', 'it'].contains(locale.languageCode);
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
