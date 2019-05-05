// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a it locale. All the
// messages from the main program should be duplicated here with the same
// function name.

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

// ignore: unnecessary_new
final messages = new MessageLookup();

// ignore: unused_element
final _keepAnalysisHappy = Intl.defaultLocale;

// ignore: non_constant_identifier_names
typedef MessageIfAbsent(String message_str, List args);

class MessageLookup extends MessageLookupByLibrary {
  get localeName => 'it';

  static m0(count) => "${Intl.plural(count, zero: 'No books', one: '${count} book', other: '${count} books')}";

  static m1(lang) => "Language: ${lang}";

  static m2(name, title) => "Book \'${title}\' belong to user \'${name}\'. Press outbox button below to initiate return.";

  static m3(name, title) => "User \'${name}\' offer you his book \'${title}\'. Please arrange handover and confirm on receive. Or reject in case you are not interested.";

  static m4(name, title) => "User \'${name}\' has accepted your request for his book \'${title}\'. Please arrange handover and confirm on receive.";

  static m5(name, title) => "Wait for user \'${name}\' to accept your request of his book \'${title}\'. Chat to facilitate.";

  static m6(name, title) => "User \'${name}\' has rejected your request for his book \'${title}\'. You can chat to get explamations.";

  static m7(name, title) => "User \'${name}\' wish to return your book \'${title}\'. Please arrange handover.";

  static m8(name, title) => "Your book \'${title}\' now with user \'${name}\'. Chat with him to remind about return.";

  static m9(name, title) => "You\'ve offered book \'${title}\' to user \'${name}\'. Please chat to arrange handover.";

  static m10(name, title) => "User \'${name}\' confirmed handover of book \'${title}\'. You can see this book in your MY LENT books.";

  static m11(name, title) => "User \'${name}\' rejected your offer for book \'${title}\'. You can chat to get details.";

  static m12(name, title) => "User \'${name}\' request your book \'${title}\'. Please accept or reject. Chat for more details.";

  static m13(name, title) => "Please arrange handover of book \'${title}\' to user \'${name}\'. Chat to coordinate.";

  static m14(name, title) => "User \'${name}\' canceled request for your book \'${title}\'.";

  static m15(name, title) => "Handover of book \'${title}\' to user \'${name}\' confirmed. You can see this book in MY LENT books.";

  static m16(name, title) => "Arrange handover of book \'${title}\' to user \'${name}\'. Chat to facilitate.";

  static m17(name, title) => "User \'${name}\' confirmed handover of the book \'${title}\'.";

  static m18(count) => "${Intl.plural(count, zero: 'No bookshelves', one: '${count} bookshelf', other: '${count} bookshelves')}";

  static m19(balance) => "Balance ${balance} λ";

  static m20(count) => "${Intl.plural(count, zero: 'No wishes', one: '${count} wish', other: '${count} wishes')}";

  static m21(name, title) => "${name} wish to read your book \'${title}\'";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "add" : MessageLookupByLibrary.simpleMessage("Add"),
    "addShelf" : MessageLookupByLibrary.simpleMessage("Aggiungi il tuo scaffale"),
    "addToCart" : MessageLookupByLibrary.simpleMessage("Add book to your cart"),
    "addToOutbox" : MessageLookupByLibrary.simpleMessage("Add book to your outbox"),
    "addToWishlist" : MessageLookupByLibrary.simpleMessage("Add to Wishlist"),
    "addYourBook" : MessageLookupByLibrary.simpleMessage("Add your book"),
    "addYourBookshelf" : MessageLookupByLibrary.simpleMessage("Add your bookshelf"),
    "blockUser" : MessageLookupByLibrary.simpleMessage("Bloccare l’Utente abusivo"),
    "blockedChat" : MessageLookupByLibrary.simpleMessage("User blocked"),
    "bookAdded" : MessageLookupByLibrary.simpleMessage("Book has been added to your library"),
    "bookCount" : m0,
    "bookDeleted" : MessageLookupByLibrary.simpleMessage("Book has been deleted from your library"),
    "bookLanguage" : m1,
    "books" : MessageLookupByLibrary.simpleMessage("Books"),
    "bookshelves" : MessageLookupByLibrary.simpleMessage("Bookshelves"),
    "borrow" : MessageLookupByLibrary.simpleMessage("Borrow"),
    "borrowedBookText" : m2,
    "cart" : MessageLookupByLibrary.simpleMessage("Books you are going to take"),
    "cartOfferConfirmReject" : m3,
    "cartRequestAccepted" : m4,
    "cartRequestCancel" : m5,
    "cartRequestRejected" : m6,
    "cartReturnConfirm" : m7,
    "chat" : MessageLookupByLibrary.simpleMessage("CHAT"),
    "confirmBlockUser" : MessageLookupByLibrary.simpleMessage("Do you want to block this user?"),
    "confirmReportPhoto" : MessageLookupByLibrary.simpleMessage("Do you want to report this photo as abusive?"),
    "deleteShelf" : MessageLookupByLibrary.simpleMessage("Cancella questo scaffale"),
    "drawerHeader" : MessageLookupByLibrary.simpleMessage("Choose mode"),
    "earn" : MessageLookupByLibrary.simpleMessage("Earn"),
    "enterTitle" : MessageLookupByLibrary.simpleMessage("Enter title/author"),
    "explore" : MessageLookupByLibrary.simpleMessage("Explore"),
    "favorite" : MessageLookupByLibrary.simpleMessage("Add shelf to favorite"),
    "importToBooks" : MessageLookupByLibrary.simpleMessage("Import to available books:"),
    "importToWishlist" : MessageLookupByLibrary.simpleMessage("Import to Wishlist:"),
    "importYouBooks" : MessageLookupByLibrary.simpleMessage("Import your books to Biblosphere"),
    "introDone" : MessageLookupByLibrary.simpleMessage("FATTO"),
    "introMeet" : MessageLookupByLibrary.simpleMessage("Incontrarsi"),
    "introMeetHint" : MessageLookupByLibrary.simpleMessage("Contatta il proprietario dei libri che ti piacciono e fissa un appuntamento per averli."),
    "introShoot" : MessageLookupByLibrary.simpleMessage("Fai foto"),
    "introShootHint" : MessageLookupByLibrary.simpleMessage("Scatta una foto dei tuoi scaffali e condividili ai vicini e ai turisti. I tuoi libri attraggono il aderenti"),
    "introSkip" : MessageLookupByLibrary.simpleMessage("SALTARE"),
    "introSurf" : MessageLookupByLibrary.simpleMessage("Esplora"),
    "introSurfHint" : MessageLookupByLibrary.simpleMessage("App mostra librerie in 200 km intorno a te in ordine di distanza. Ottieni l\'accesso a un\'ampia varietà di libri."),
    "isbnNotFound" : MessageLookupByLibrary.simpleMessage("Book is not found by ISBN"),
    "km" : MessageLookupByLibrary.simpleMessage(" km"),
    "lentBookText" : m8,
    "linkToGoodreads" : MessageLookupByLibrary.simpleMessage("Link your Goodreads"),
    "linkYourAccount" : MessageLookupByLibrary.simpleMessage("Link your Goodreads account"),
    "loading" : MessageLookupByLibrary.simpleMessage("Loading..."),
    "loginAgree1" : MessageLookupByLibrary.simpleMessage("Cliccando su Registrami confermi di accettare  \n le "),
    "loginAgree2" : MessageLookupByLibrary.simpleMessage("condizioni di utilizzo e l\'informativa "),
    "loginAgree3" : MessageLookupByLibrary.simpleMessage("\nsul trattamento dei "),
    "loginAgree4" : MessageLookupByLibrary.simpleMessage("dati personali "),
    "logout" : MessageLookupByLibrary.simpleMessage("Logout"),
    "makePhotoOfShelf" : MessageLookupByLibrary.simpleMessage("Make a photo of your bookshelf"),
    "meet" : MessageLookupByLibrary.simpleMessage("Meet"),
    "messageOwner" : MessageLookupByLibrary.simpleMessage("Messaggio al proprietario"),
    "messageRecepient" : MessageLookupByLibrary.simpleMessage("Chat with book recepient."),
    "myBooksItem" : MessageLookupByLibrary.simpleMessage("My books"),
    "myBooksTitle" : MessageLookupByLibrary.simpleMessage("MY BOOKS"),
    "myBookshelvesItem" : MessageLookupByLibrary.simpleMessage("My bookshelves"),
    "myBookshelvesTitle" : MessageLookupByLibrary.simpleMessage("MY BOOKSHELVES"),
    "myBorrowedBooksItem" : MessageLookupByLibrary.simpleMessage("Borrowed books"),
    "myBorrowedBooksTitle" : MessageLookupByLibrary.simpleMessage("BORROWED BOOKS"),
    "myCartTitle" : MessageLookupByLibrary.simpleMessage("MY CART"),
    "myLendedBooksItem" : MessageLookupByLibrary.simpleMessage("Lent books"),
    "myLendedBooksTitle" : MessageLookupByLibrary.simpleMessage("LENT BOOKS"),
    "myOutboxTitle" : MessageLookupByLibrary.simpleMessage("MY OUTBOX"),
    "myWishlistItem" : MessageLookupByLibrary.simpleMessage("My wishlist"),
    "myWishlistTitle" : MessageLookupByLibrary.simpleMessage("MY WISHLIST"),
    "no" : MessageLookupByLibrary.simpleMessage("No"),
    "noBooks" : MessageLookupByLibrary.simpleMessage("You don\'t have any books in Biblosphere. Add it manually or import from Goodreads."),
    "noBookshelves" : MessageLookupByLibrary.simpleMessage("You don\'t have any bookshelves in Biblosphere. Make a photo of your bookshelf to share with neighbours."),
    "noBorrowedBooks" : MessageLookupByLibrary.simpleMessage("You do not have any borrowed books"),
    "noItemsInCart" : MessageLookupByLibrary.simpleMessage("Your cart is empty. Add books from the list of the books or your matched wishes."),
    "noItemsInOutbox" : MessageLookupByLibrary.simpleMessage("Your outbox is empty. Wait for people to request your books or offer your books in matched books."),
    "noLendedBooks" : MessageLookupByLibrary.simpleMessage("You do not have any lent books"),
    "noMatchForBooks" : MessageLookupByLibrary.simpleMessage("Here you\'ll see people who wish your books once they are registered. To make it happen add more books and spread the word about Biblosphere."),
    "noMatchForWishlist" : MessageLookupByLibrary.simpleMessage("Hey, right now nodody around you has the books from your wishlist. They will be shown here once someone registers them.\nSpread the word about Biblosphere to make it happen sooner. And add more books to your wishlist."),
    "noWishes" : MessageLookupByLibrary.simpleMessage("You don\'t have any books in your wishlist. Add it manually or import from Goodreads."),
    "notBooks" : MessageLookupByLibrary.simpleMessage("Ehi, questa non sembra un scaffale per me"),
    "nothingToSend" : MessageLookupByLibrary.simpleMessage("Niente da inviare"),
    "ok" : MessageLookupByLibrary.simpleMessage("Ok"),
    "outbox" : MessageLookupByLibrary.simpleMessage("Books you are giving away"),
    "outboxOfferAccepted" : m9,
    "outboxOfferConfirmed" : m10,
    "outboxOfferRejected" : m11,
    "outboxRequestAcceptReject" : m12,
    "outboxRequestAccepted" : m13,
    "outboxRequestCanceled" : m14,
    "outboxRequestConfirmed" : m15,
    "outboxReturnAccepted" : m16,
    "outboxReturnConfirmed" : m17,
    "people" : MessageLookupByLibrary.simpleMessage("People"),
    "read" : MessageLookupByLibrary.simpleMessage("Read"),
    "recentWishes" : MessageLookupByLibrary.simpleMessage("Recent wishes:"),
    "reportShelf" : MessageLookupByLibrary.simpleMessage("Segnala un contenuto discutibile"),
    "reportedPhoto" : MessageLookupByLibrary.simpleMessage("Questa foto è segnalata come i contenuti discutibili."),
    "scanISBN" : MessageLookupByLibrary.simpleMessage("Scan ISBN from the back of the book"),
    "seeLocation" : MessageLookupByLibrary.simpleMessage("Vedere la posizione"),
    "settings" : MessageLookupByLibrary.simpleMessage("Impostazioni"),
    "share" : MessageLookupByLibrary.simpleMessage("Share"),
    "shareBooks" : MessageLookupByLibrary.simpleMessage("I\'m sharing my books on Biblosphere. Join me to read it."),
    "shareBookshelf" : MessageLookupByLibrary.simpleMessage("That\'s my bookshelf. Join Biblosphere to share books and find like-minded people."),
    "shareShelf" : MessageLookupByLibrary.simpleMessage("Condividi il scaffale"),
    "shareWishlist" : MessageLookupByLibrary.simpleMessage("I\'m sharing my book wishlist on Biblosphere. Join me."),
    "shelfAdded" : MessageLookupByLibrary.simpleMessage("New bookshelf has been added"),
    "shelfCount" : m18,
    "shelfDeleted" : MessageLookupByLibrary.simpleMessage("Bookshelf has been deleted"),
    "shelfSettings" : MessageLookupByLibrary.simpleMessage("Impostazioni scaffale"),
    "shelves" : MessageLookupByLibrary.simpleMessage("Shelves"),
    "title" : MessageLookupByLibrary.simpleMessage("Biblosfere"),
    "transitAccept" : MessageLookupByLibrary.simpleMessage("Accept"),
    "transitCancel" : MessageLookupByLibrary.simpleMessage("Cancel"),
    "transitConfirm" : MessageLookupByLibrary.simpleMessage("Confirm"),
    "transitInitiated" : MessageLookupByLibrary.simpleMessage("Handover process initiated for the book"),
    "transitOk" : MessageLookupByLibrary.simpleMessage("Ok"),
    "transitReject" : MessageLookupByLibrary.simpleMessage("Reject"),
    "typeMsg" : MessageLookupByLibrary.simpleMessage("Scrivi il tuo messaggio..."),
    "useCurrentLocation" : MessageLookupByLibrary.simpleMessage("Use current location for import"),
    "userBalance" : m19,
    "welcome" : MessageLookupByLibrary.simpleMessage("Welcome"),
    "wishAdded" : MessageLookupByLibrary.simpleMessage("Book has been added to your wishlist"),
    "wishCount" : m20,
    "wishDeleted" : MessageLookupByLibrary.simpleMessage("Book has been deleted from your wishlist"),
    "wishToRead" : m21,
    "wished" : MessageLookupByLibrary.simpleMessage("Wished"),
    "yourBiblosphere" : MessageLookupByLibrary.simpleMessage("Your Biblosphere"),
    "yourGoodreads" : MessageLookupByLibrary.simpleMessage("Your Goodreads"),
    "zoom" : MessageLookupByLibrary.simpleMessage("ZOOM")
  };
}
