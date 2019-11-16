// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a it locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'it';

  static m0(count) => "${Intl.plural(count, zero: 'No books', one: '${count} book', other: '${count} books')}";

  static m1(lang) => "Language: ${lang}";

  static m2(user) => "Владелец: ${user}";

  static m3(total) => "Цена: ${total}";

  static m4(month) => "Аренда: ${month} в месяц";

  static m5(name, title) => "Book \'${title}\' belong to user \'${name}\'. Press outbox button below to initiate return.";

  static m6(name, title) => "User \'${name}\' offer you his book \'${title}\'. Please arrange handover and confirm on receive. Or reject in case you are not interested.";

  static m7(name, title) => "User \'${name}\' has accepted your request for his book \'${title}\'. Please arrange handover and confirm on receive.";

  static m8(name, title) => "Wait for user \'${name}\' to accept your request of his book \'${title}\'. Chat to facilitate.";

  static m9(name, title) => "User \'${name}\' has rejected your request for his book \'${title}\'. You can chat to get explamations.";

  static m10(name, title) => "User \'${name}\' wish to return your book \'${title}\'. Please arrange handover.";

  static m11(distance) => "Distance: ${distance} km";

  static m12(balance) => "MY BALANCE: ${balance}";

  static m13(amount) => "Enter amount not more than ${amount}";

  static m14(total, month) => "Deposit for books: ${total}, monthly payment ${month}";

  static m15(name, title) => "Your book \'${title}\' now with user \'${name}\'. Chat with him to remind about return.";

  static m16(missing, total, month) => "Missing ${missing}. Deposit for books: ${total}, monthly payment ${month}";

  static m17(name, title) => "You\'ve offered book \'${title}\' to user \'${name}\'. Please chat to arrange handover.";

  static m18(name, title) => "User \'${name}\' confirmed handover of book \'${title}\'. You can see this book in your MY LENT books.";

  static m19(name, title) => "User \'${name}\' rejected your offer for book \'${title}\'. You can chat to get details.";

  static m20(name, title) => "User \'${name}\' request your book \'${title}\'. Please accept or reject. Chat for more details.";

  static m21(name, title) => "Please arrange handover of book \'${title}\' to user \'${name}\'. Chat to coordinate.";

  static m22(name, title) => "User \'${name}\' canceled request for your book \'${title}\'.";

  static m23(name, title) => "Handover of book \'${title}\' to user \'${name}\' confirmed. You can see this book in MY LENT books.";

  static m24(name, title) => "Arrange handover of book \'${title}\' to user \'${name}\'. Chat to facilitate.";

  static m25(name, title) => "User \'${name}\' confirmed handover of the book \'${title}\'.";

  static m26(num) => "Receiving books (${num})";

  static m27(book) => "Can you give me \"${book}\"?";

  static m28(book) => "Can you send me \"${book}\"?";

  static m29(book) => "Хочу вернуть вам \"${book}\"?";

  static m30(book) => "Пожалуйста, верните книгу \"${book}\"?";

  static m31(num) => "Handover books (${num})";

  static m32(amount) => "Total shared: +${amount}";

  static m33(count) => "${Intl.plural(count, zero: 'No bookshelves', one: '${count} bookshelf', other: '${count} bookshelves')}";

  static m34(balance) => "Balance: ${balance}";

  static m35(user) => "from user ${user}";

  static m36(count) => "${Intl.plural(count, zero: 'No wishes', one: '${count} wish', other: '${count} wishes')}";

  static m37(name, title) => "${name} wish to read your book \'${title}\'";

  static m38(user) => "Book with ${user}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "accountCopied" : MessageLookupByLibrary.simpleMessage("Account copied to clipboard"),
    "add" : MessageLookupByLibrary.simpleMessage("Add"),
    "addBook" : MessageLookupByLibrary.simpleMessage("Add book"),
    "addShelf" : MessageLookupByLibrary.simpleMessage("Aggiungi il tuo scaffale"),
    "addToCart" : MessageLookupByLibrary.simpleMessage("Add book to your cart"),
    "addToOutbox" : MessageLookupByLibrary.simpleMessage("Add book to your outbox"),
    "addToWishlist" : MessageLookupByLibrary.simpleMessage("Add to Wishlist"),
    "addYourBook" : MessageLookupByLibrary.simpleMessage("Add your book"),
    "addYourBookshelf" : MessageLookupByLibrary.simpleMessage("Add your bookshelf"),
    "addbookTitle" : MessageLookupByLibrary.simpleMessage("ADD BOOK"),
    "blockUser" : MessageLookupByLibrary.simpleMessage("Bloccare l’Utente abusivo"),
    "blockedChat" : MessageLookupByLibrary.simpleMessage("User blocked"),
    "bookAdded" : MessageLookupByLibrary.simpleMessage("Book has been added to your library"),
    "bookAround" : MessageLookupByLibrary.simpleMessage("Get book"),
    "bookByPost" : MessageLookupByLibrary.simpleMessage("Receive by post"),
    "bookCount" : m0,
    "bookDeleted" : MessageLookupByLibrary.simpleMessage("Book has been deleted from your library"),
    "bookImageLabel" : MessageLookupByLibrary.simpleMessage("Ссылка на фото обложки:"),
    "bookInLibrary" : MessageLookupByLibrary.simpleMessage("Find in library via"),
    "bookLanguage" : m1,
    "bookOwner" : m2,
    "bookPrice" : m3,
    "bookPriceHint" : MessageLookupByLibrary.simpleMessage("Введите цену книги"),
    "bookPriceLabel" : MessageLookupByLibrary.simpleMessage("Цена книги"),
    "bookRent" : m4,
    "books" : MessageLookupByLibrary.simpleMessage("Books"),
    "bookshelves" : MessageLookupByLibrary.simpleMessage("Bookshelves"),
    "borrow" : MessageLookupByLibrary.simpleMessage("Borrow"),
    "borrowedBookText" : m5,
    "buttonConfirmBooks" : MessageLookupByLibrary.simpleMessage("Confirm handover ✓"),
    "buttonGivenBooks" : MessageLookupByLibrary.simpleMessage("Книги отдал ✓"),
    "buttonPayin" : MessageLookupByLibrary.simpleMessage("Get balance"),
    "buttonTransfer" : MessageLookupByLibrary.simpleMessage("Transfer"),
    "buyBook" : MessageLookupByLibrary.simpleMessage("Buy on"),
    "cart" : MessageLookupByLibrary.simpleMessage("Books you are going to take"),
    "cartOfferConfirmReject" : m6,
    "cartRequestAccepted" : m7,
    "cartRequestCancel" : m8,
    "cartRequestRejected" : m9,
    "cartReturnConfirm" : m10,
    "chat" : MessageLookupByLibrary.simpleMessage("CHAT"),
    "chatStatusCompleteFrom" : MessageLookupByLibrary.simpleMessage("Книги переданы"),
    "chatStatusCompleteTo" : MessageLookupByLibrary.simpleMessage("Книги получены"),
    "chatStatusHandoverFrom" : MessageLookupByLibrary.simpleMessage("Завершите передачу книг"),
    "chatStatusHandoverTo" : MessageLookupByLibrary.simpleMessage("Подтвердите получение книг"),
    "chatStatusInitialFrom" : MessageLookupByLibrary.simpleMessage("Отдайте книги"),
    "chatStatusInitialTo" : MessageLookupByLibrary.simpleMessage("Получите книги"),
    "chipBorrowed" : MessageLookupByLibrary.simpleMessage("Borrowed"),
    "chipHisBooks" : MessageLookupByLibrary.simpleMessage("Его книги"),
    "chipHisBooksWithMe" : MessageLookupByLibrary.simpleMessage("Его книги у меня"),
    "chipLeasing" : MessageLookupByLibrary.simpleMessage("Spent"),
    "chipLent" : MessageLookupByLibrary.simpleMessage("Lent"),
    "chipMyBooks" : MessageLookupByLibrary.simpleMessage("My books"),
    "chipMyBooksWithHim" : MessageLookupByLibrary.simpleMessage("Мои книги у него"),
    "chipPayin" : MessageLookupByLibrary.simpleMessage("Pay In"),
    "chipPayout" : MessageLookupByLibrary.simpleMessage("Pay Out"),
    "chipReferrals" : MessageLookupByLibrary.simpleMessage("Referrals"),
    "chipReward" : MessageLookupByLibrary.simpleMessage("Rewards"),
    "chipTransit" : MessageLookupByLibrary.simpleMessage("Transit"),
    "chipWish" : MessageLookupByLibrary.simpleMessage("Wishes"),
    "confirmBlockUser" : MessageLookupByLibrary.simpleMessage("Do you want to block this user?"),
    "confirmReportPhoto" : MessageLookupByLibrary.simpleMessage("Do you want to report this photo as abusive?"),
    "deleteShelf" : MessageLookupByLibrary.simpleMessage("Cancella questo scaffale"),
    "displayCurrency" : MessageLookupByLibrary.simpleMessage("Валюта отображения:"),
    "distanceLine" : m11,
    "drawerHeader" : MessageLookupByLibrary.simpleMessage("Choose mode"),
    "earn" : MessageLookupByLibrary.simpleMessage("Earn"),
    "emptyAmount" : MessageLookupByLibrary.simpleMessage("Empty amount not accepted"),
    "enterTitle" : MessageLookupByLibrary.simpleMessage("Enter title/author"),
    "exceedAmount" : MessageLookupByLibrary.simpleMessage("Amount exceed available balance"),
    "explore" : MessageLookupByLibrary.simpleMessage("Explore"),
    "favorite" : MessageLookupByLibrary.simpleMessage("Add shelf to favorite"),
    "financeTitle" : m12,
    "findBook" : MessageLookupByLibrary.simpleMessage("Find Book"),
    "findbookTitle" : MessageLookupByLibrary.simpleMessage("FIND BOOK"),
    "hintAuthorTitle" : MessageLookupByLibrary.simpleMessage("Author or title"),
    "hintNotMore" : m13,
    "hintOutptAcount" : MessageLookupByLibrary.simpleMessage("Enter your Stellar account for pay out"),
    "ifNotFound" : MessageLookupByLibrary.simpleMessage("Add book to wishlist if not found"),
    "imageLinkHint" : MessageLookupByLibrary.simpleMessage("Скопируйте ссылку на обложку книги"),
    "importToBooks" : MessageLookupByLibrary.simpleMessage("Import to available books:"),
    "importToWishlist" : MessageLookupByLibrary.simpleMessage("Import to Wishlist:"),
    "importYouBooks" : MessageLookupByLibrary.simpleMessage("Import your books to Biblosphere"),
    "inMyBooks" : MessageLookupByLibrary.simpleMessage("You have this book"),
    "inMyWishes" : MessageLookupByLibrary.simpleMessage("This book in your wishlist"),
    "inputStellarAcount" : MessageLookupByLibrary.simpleMessage("Stellar account for Pay In:"),
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
    "leaseAgreement" : m14,
    "lentBookText" : m15,
    "linkCopied" : MessageLookupByLibrary.simpleMessage("Link copied to clipboard"),
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
    "menuBalance" : MessageLookupByLibrary.simpleMessage("Balance"),
    "menuMessages" : MessageLookupByLibrary.simpleMessage("Messages"),
    "menuReferral" : MessageLookupByLibrary.simpleMessage("Referral program"),
    "menuSettings" : MessageLookupByLibrary.simpleMessage("Settings"),
    "menuSupport" : MessageLookupByLibrary.simpleMessage("Support"),
    "messageOwner" : MessageLookupByLibrary.simpleMessage("Messaggio al proprietario"),
    "messageRecepient" : MessageLookupByLibrary.simpleMessage("Chat with book recepient."),
    "myBooks" : MessageLookupByLibrary.simpleMessage("My books"),
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
    "mybooksTitle" : MessageLookupByLibrary.simpleMessage("MY BOOKS"),
    "negativeAmount" : MessageLookupByLibrary.simpleMessage("Amount should be positive"),
    "no" : MessageLookupByLibrary.simpleMessage("No"),
    "noBooks" : MessageLookupByLibrary.simpleMessage("You don\'t have any books in Biblosphere. Add it manually or import from Goodreads."),
    "noBookshelves" : MessageLookupByLibrary.simpleMessage("You don\'t have any bookshelves in Biblosphere. Make a photo of your bookshelf to share with neighbours."),
    "noBorrowedBooks" : MessageLookupByLibrary.simpleMessage("You do not have any borrowed books"),
    "noItemsInCart" : MessageLookupByLibrary.simpleMessage("Your cart is empty. Add books from the list of the books or your matched wishes."),
    "noItemsInOutbox" : MessageLookupByLibrary.simpleMessage("Your outbox is empty. Wait for people to request your books or offer your books in matched books."),
    "noLendedBooks" : MessageLookupByLibrary.simpleMessage("You do not have any lent books"),
    "noMatchForBooks" : MessageLookupByLibrary.simpleMessage("Here you\'ll see people who wish your books once they are registered. To make it happen add more books and spread the word about Biblosphere."),
    "noMatchForWishlist" : MessageLookupByLibrary.simpleMessage("Hey, right now nodody around you has the books from your wishlist. They will be shown here once someone registers them.\nSpread the word about Biblosphere to make it happen sooner. And add more books to your wishlist."),
    "noMessages" : MessageLookupByLibrary.simpleMessage("No messages"),
    "noOperations" : MessageLookupByLibrary.simpleMessage("No operations"),
    "noReferrals" : MessageLookupByLibrary.simpleMessage("No referrals"),
    "noWishes" : MessageLookupByLibrary.simpleMessage("You don\'t have any books in your wishlist. Add it manually or import from Goodreads."),
    "notBooks" : MessageLookupByLibrary.simpleMessage("Ehi, questa non sembra un scaffale per me"),
    "notSufficientForAgreement" : m16,
    "nothingToSend" : MessageLookupByLibrary.simpleMessage("Niente da inviare"),
    "ok" : MessageLookupByLibrary.simpleMessage("Ok"),
    "opInAppPurchase" : MessageLookupByLibrary.simpleMessage("Pay In (In-App)"),
    "opInStellar" : MessageLookupByLibrary.simpleMessage("Pay In (Stellar)"),
    "opLeasing" : MessageLookupByLibrary.simpleMessage("Spent/Deposit for book"),
    "opOutStellar" : MessageLookupByLibrary.simpleMessage("Pay Out (Stellar)"),
    "opReferral" : MessageLookupByLibrary.simpleMessage("Referrals pay"),
    "opReward" : MessageLookupByLibrary.simpleMessage("Reward for book"),
    "outbox" : MessageLookupByLibrary.simpleMessage("Books you are giving away"),
    "outboxOfferAccepted" : m17,
    "outboxOfferConfirmed" : m18,
    "outboxOfferRejected" : m19,
    "outboxRequestAcceptReject" : m20,
    "outboxRequestAccepted" : m21,
    "outboxRequestCanceled" : m22,
    "outboxRequestConfirmed" : m23,
    "outboxReturnAccepted" : m24,
    "outboxReturnConfirmed" : m25,
    "outputStellarAccount" : MessageLookupByLibrary.simpleMessage("Stellar account for Pay Out:"),
    "paymentError" : MessageLookupByLibrary.simpleMessage("Something went wrong, contact administrator"),
    "people" : MessageLookupByLibrary.simpleMessage("People"),
    "read" : MessageLookupByLibrary.simpleMessage("Read"),
    "receiveBooks" : m26,
    "recentWishes" : MessageLookupByLibrary.simpleMessage("Recent wishes:"),
    "referralLink" : MessageLookupByLibrary.simpleMessage("Your referral link:"),
    "referralTitle" : MessageLookupByLibrary.simpleMessage("MY REFERRALS"),
    "reportShelf" : MessageLookupByLibrary.simpleMessage("Segnala un contenuto discutibile"),
    "reportedPhoto" : MessageLookupByLibrary.simpleMessage("Questa foto è segnalata come i contenuti discutibili."),
    "requestBook" : m27,
    "requestPost" : m28,
    "requestReturn" : m29,
    "requestReturnByOwner" : m30,
    "scanISBN" : MessageLookupByLibrary.simpleMessage("Scan ISBN from the back of the book"),
    "seeLocation" : MessageLookupByLibrary.simpleMessage("Vedere la posizione"),
    "selectDisplayCurrency" : MessageLookupByLibrary.simpleMessage("Выберите валюту отображения:"),
    "sendBooks" : m31,
    "settings" : MessageLookupByLibrary.simpleMessage("Impostazioni"),
    "share" : MessageLookupByLibrary.simpleMessage("Share"),
    "shareBooks" : MessageLookupByLibrary.simpleMessage("I\'m sharing my books on Biblosphere. Join me to read it."),
    "shareBookshelf" : MessageLookupByLibrary.simpleMessage("That\'s my bookshelf. Join Biblosphere to share books and find like-minded people."),
    "shareShelf" : MessageLookupByLibrary.simpleMessage("Condividi il scaffale"),
    "shareWishlist" : MessageLookupByLibrary.simpleMessage("I\'m sharing my book wishlist on Biblosphere. Join me."),
    "sharedFeeLine" : m32,
    "shelfAdded" : MessageLookupByLibrary.simpleMessage("New bookshelf has been added"),
    "shelfCount" : m33,
    "shelfDeleted" : MessageLookupByLibrary.simpleMessage("Bookshelf has been deleted"),
    "shelfSettings" : MessageLookupByLibrary.simpleMessage("Impostazioni scaffale"),
    "shelves" : MessageLookupByLibrary.simpleMessage("Shelves"),
    "stellarOutput" : MessageLookupByLibrary.simpleMessage("Pay out to Stellar account:"),
    "successfulPayment" : MessageLookupByLibrary.simpleMessage("Successful payment"),
    "supportTitle" : MessageLookupByLibrary.simpleMessage("SUPPORT"),
    "title" : MessageLookupByLibrary.simpleMessage("Biblosfere"),
    "titleBookSettings" : MessageLookupByLibrary.simpleMessage("О КНИГЕ"),
    "titleGetBook" : MessageLookupByLibrary.simpleMessage("GET BOOK"),
    "titleMessages" : MessageLookupByLibrary.simpleMessage("MESSAGES"),
    "titleReceiveBooks" : MessageLookupByLibrary.simpleMessage("RECEIVING BOOKS"),
    "titleSendBooks" : MessageLookupByLibrary.simpleMessage("HANDOVER BOOKS"),
    "titleSettings" : MessageLookupByLibrary.simpleMessage("SETTINGS"),
    "titleUserBooks" : MessageLookupByLibrary.simpleMessage("ОБМЕН КНИГАМИ"),
    "transitAccept" : MessageLookupByLibrary.simpleMessage("Accept"),
    "transitCancel" : MessageLookupByLibrary.simpleMessage("Cancel"),
    "transitConfirm" : MessageLookupByLibrary.simpleMessage("Confirm"),
    "transitInitiated" : MessageLookupByLibrary.simpleMessage("Handover process initiated for the book"),
    "transitOk" : MessageLookupByLibrary.simpleMessage("Ok"),
    "transitReject" : MessageLookupByLibrary.simpleMessage("Reject"),
    "typeMsg" : MessageLookupByLibrary.simpleMessage("Scrivi il tuo messaggio..."),
    "useCurrentLocation" : MessageLookupByLibrary.simpleMessage("Use current location for import"),
    "userBalance" : m34,
    "userHave" : m35,
    "welcome" : MessageLookupByLibrary.simpleMessage("Welcome"),
    "wishAdded" : MessageLookupByLibrary.simpleMessage("Book has been added to your wishlist"),
    "wishCount" : m36,
    "wishDeleted" : MessageLookupByLibrary.simpleMessage("Book has been deleted from your wishlist"),
    "wishToRead" : m37,
    "wished" : MessageLookupByLibrary.simpleMessage("Wished"),
    "wrongAccount" : MessageLookupByLibrary.simpleMessage("Wrong account"),
    "wrongImageUrl" : MessageLookupByLibrary.simpleMessage("Неверная ссылка"),
    "youBorrowThisBook" : MessageLookupByLibrary.simpleMessage("You borrowed this book"),
    "youHaveThisBook" : MessageLookupByLibrary.simpleMessage("You keep this book"),
    "youLentThisBook" : m38,
    "youTransitThisBook" : MessageLookupByLibrary.simpleMessage("This book is in transit"),
    "youWishThisBook" : MessageLookupByLibrary.simpleMessage("This book in your wishlist"),
    "yourBiblosphere" : MessageLookupByLibrary.simpleMessage("Your Biblosphere"),
    "yourGoodreads" : MessageLookupByLibrary.simpleMessage("Your Goodreads"),
    "zoom" : MessageLookupByLibrary.simpleMessage("ZOOM")
  };
}
