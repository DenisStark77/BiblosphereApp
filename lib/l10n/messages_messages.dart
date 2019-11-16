// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a messages locale. All the
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
  String get localeName => 'messages';

  static m0(count) => "${Intl.plural(count, zero: 'No books', one: '${count} book', other: '${count} books')}";

  static m1(lang) => "Language: ${lang}";

  static m2(user) => "Владелец: ${user}";

  static m3(total) => "Цена: ${total}";

  static m4(month) => "Аренда: ${month} в месяц";

  static m39(user) => "Книга у: ${user}";

  static m5(name, title) => "Book \'${title}\' belong to user \'${name}\'. Press outbox button below to initiate return.";

  static m6(name, title) => "User \'${name}\' offer you his book \'${title}\'. Please arrange handover and confirm on receive. Or reject in case you are not interested.";

  static m7(name, title) => "User \'${name}\' has accepted your request for his book \'${title}\'. Please arrange handover and confirm on receive.";

  static m8(name, title) => "Wait for user \'${name}\' to accept your request of his book \'${title}\'. Chat to facilitate.";

  static m9(name, title) => "User \'${name}\' has rejected your request for his book \'${title}\'. You can chat to get explamations.";

  static m10(name, title) => "User \'${name}\' wish to return your book \'${title}\'. Please arrange handover.";

  static m11(distance) => "Расстояние: ${distance} км";

  static m12(balance) => "МОЙ БАЛАНС: ${balance}";

  static m13(amount) => "Введите сумму не более ${amount}";

  static m14(total, month) => "Депозит за книги: ${total}, оплата за месяц ${month}";

  static m15(name, title) => "Your book \'${title}\' now with user \'${name}\'. Chat with him to remind about return.";

  static m16(missing, total, month) => "Вам нехватает ${missing}. Депозит за книги: ${total}, оплата за месяц ${month}";

  static m17(name, title) => "You\'ve offered book \'${title}\' to user \'${name}\'. Please chat to arrange handover.";

  static m18(name, title) => "User \'${name}\' confirmed handover of book \'${title}\'. You can see this book in your MY LENT books.";

  static m19(name, title) => "User \'${name}\' rejected your offer for book \'${title}\'. You can chat to get details.";

  static m20(name, title) => "User \'${name}\' request your book \'${title}\'. Please accept or reject. Chat for more details.";

  static m21(name, title) => "Please arrange handover of book \'${title}\' to user \'${name}\'. Chat to coordinate.";

  static m22(name, title) => "User \'${name}\' canceled request for your book \'${title}\'.";

  static m23(name, title) => "Handover of book \'${title}\' to user \'${name}\' confirmed. You can see this book in MY LENT books.";

  static m24(name, title) => "Arrange handover of book \'${title}\' to user \'${name}\'. Chat to facilitate.";

  static m25(name, title) => "User \'${name}\' confirmed handover of the book \'${title}\'.";

  static m26(num) => "Взять книги (${num})";

  static m27(book) => "Можно взять у вас \"${book}\"?";

  static m28(book) => "Можете прислать мне \"${book}\"?";

  static m29(book) => "Хочу вернуть вам \"${book}\"?";

  static m30(book) => "Пожалуйста, верните книгу \"${book}\"?";

  static m31(num) => "Отдаю книги (${num})";

  static m32(amount) => "Общий доход: +${amount}";

  static m33(count) => "${Intl.plural(count, zero: 'No bookshelves', one: '${count} bookshelf', other: '${count} bookshelves')}";

  static m34(balance) => "Balance ${balance} λ";

  static m35(user) => "У пользователя ${user}";

  static m36(count) => "${Intl.plural(count, zero: 'No wishes', one: '${count} wish', other: '${count} wishes')}";

  static m37(name, title) => "${name} wish to read your book \'${title}\'";

  static m38(user) => "Книга у ${user}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "accountCopied" : MessageLookupByLibrary.simpleMessage("Счёт скопирован в буфер обмена"),
    "add" : MessageLookupByLibrary.simpleMessage("Add"),
    "addBook" : MessageLookupByLibrary.simpleMessage("Добавить книгу"),
    "addShelf" : MessageLookupByLibrary.simpleMessage("Add your bookshelf"),
    "addToCart" : MessageLookupByLibrary.simpleMessage("Add book to your cart"),
    "addToOutbox" : MessageLookupByLibrary.simpleMessage("Add book to your outbox"),
    "addToWishlist" : MessageLookupByLibrary.simpleMessage("Add to Wishlist"),
    "addYourBook" : MessageLookupByLibrary.simpleMessage("Add your book"),
    "addYourBookshelf" : MessageLookupByLibrary.simpleMessage("Add your bookshelf"),
    "addbookTitle" : MessageLookupByLibrary.simpleMessage("ДОБАВЬ КНИГУ"),
    "blockUser" : MessageLookupByLibrary.simpleMessage("Block abusive user"),
    "blockedChat" : MessageLookupByLibrary.simpleMessage("Blocked"),
    "bookAdded" : MessageLookupByLibrary.simpleMessage("Book has been added to your library"),
    "bookAround" : MessageLookupByLibrary.simpleMessage("Книга поблизости"),
    "bookByPost" : MessageLookupByLibrary.simpleMessage("Получи по почте"),
    "bookCount" : m0,
    "bookDeleted" : MessageLookupByLibrary.simpleMessage("Book has been deleted from your library"),
    "bookImageLabel" : MessageLookupByLibrary.simpleMessage("Ссылка на фото обложки:"),
    "bookInLibrary" : MessageLookupByLibrary.simpleMessage("Найди в библиотеке через"),
    "bookLanguage" : m1,
    "bookOwner" : m2,
    "bookPrice" : m3,
    "bookPriceHint" : MessageLookupByLibrary.simpleMessage("Введите цену книги"),
    "bookPriceLabel" : MessageLookupByLibrary.simpleMessage("Цена книги"),
    "bookRent" : m4,
    "bookWith" : m39,
    "books" : MessageLookupByLibrary.simpleMessage("Books"),
    "bookshelves" : MessageLookupByLibrary.simpleMessage("Bookshelves"),
    "borrow" : MessageLookupByLibrary.simpleMessage("Borrow"),
    "borrowedBookText" : m5,
    "buttonConfirmBooks" : MessageLookupByLibrary.simpleMessage("Книги получил ✓"),
    "buttonGivenBooks" : MessageLookupByLibrary.simpleMessage("Книги отдал ✓"),
    "buttonPayin" : MessageLookupByLibrary.simpleMessage("Пополнить счёт"),
    "buttonTransfer" : MessageLookupByLibrary.simpleMessage("Перевести"),
    "buyBook" : MessageLookupByLibrary.simpleMessage("Купи на"),
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
    "chipBorrowed" : MessageLookupByLibrary.simpleMessage("Взятые"),
    "chipHisBooks" : MessageLookupByLibrary.simpleMessage("Его книги"),
    "chipHisBooksWithMe" : MessageLookupByLibrary.simpleMessage("Его книги у меня"),
    "chipLeasing" : MessageLookupByLibrary.simpleMessage("Расходы"),
    "chipLent" : MessageLookupByLibrary.simpleMessage("Отданные"),
    "chipMyBooks" : MessageLookupByLibrary.simpleMessage("Мои книги"),
    "chipMyBooksWithHim" : MessageLookupByLibrary.simpleMessage("Мои книги у него"),
    "chipPayin" : MessageLookupByLibrary.simpleMessage("Пополнения"),
    "chipPayout" : MessageLookupByLibrary.simpleMessage("Выплаты"),
    "chipReferrals" : MessageLookupByLibrary.simpleMessage("Рефералы"),
    "chipReward" : MessageLookupByLibrary.simpleMessage("Доходы"),
    "chipTransit" : MessageLookupByLibrary.simpleMessage("Транзит"),
    "chipWish" : MessageLookupByLibrary.simpleMessage("Хочу"),
    "confirmBlockUser" : MessageLookupByLibrary.simpleMessage("Do you want to block this user?"),
    "confirmReportPhoto" : MessageLookupByLibrary.simpleMessage("Do you want to report this photo as abusive?"),
    "deleteShelf" : MessageLookupByLibrary.simpleMessage("Delete your bookshelf"),
    "displayCurrency" : MessageLookupByLibrary.simpleMessage("Валюта отображения:"),
    "distanceLine" : m11,
    "drawerHeader" : MessageLookupByLibrary.simpleMessage("Choose mode"),
    "earn" : MessageLookupByLibrary.simpleMessage("Earn"),
    "emptyAmount" : MessageLookupByLibrary.simpleMessage("Сумма не может быть пустой"),
    "enterTitle" : MessageLookupByLibrary.simpleMessage("Enter title/author"),
    "exceedAmount" : MessageLookupByLibrary.simpleMessage("Сумма должна быть меньше доступного остатка"),
    "explore" : MessageLookupByLibrary.simpleMessage("Explore"),
    "favorite" : MessageLookupByLibrary.simpleMessage("Add shelf to favorite"),
    "financeTitle" : m12,
    "findBook" : MessageLookupByLibrary.simpleMessage("Найти книгу"),
    "findbookTitle" : MessageLookupByLibrary.simpleMessage("НАЙДИ КНИГУ"),
    "hintAuthorTitle" : MessageLookupByLibrary.simpleMessage("Автор или название"),
    "hintNotMore" : m13,
    "hintOutptAcount" : MessageLookupByLibrary.simpleMessage("Ваш Stellar счёт для вывода средств"),
    "ifNotFound" : MessageLookupByLibrary.simpleMessage("Если вы не нашли книгу вы можете:"),
    "imageLinkHint" : MessageLookupByLibrary.simpleMessage("Скопируйте ссылку на обложку книги"),
    "importToBooks" : MessageLookupByLibrary.simpleMessage("Import to available books:"),
    "importToWishlist" : MessageLookupByLibrary.simpleMessage("Import to Wishlist:"),
    "importYouBooks" : MessageLookupByLibrary.simpleMessage("Import your books to Biblosphere"),
    "inMyBooks" : MessageLookupByLibrary.simpleMessage("Эта книга есть у вас"),
    "inMyWishes" : MessageLookupByLibrary.simpleMessage("Эта книга в вашем списке желаний"),
    "inputStellarAcount" : MessageLookupByLibrary.simpleMessage("Счёт Stellar для пополнения:"),
    "introDone" : MessageLookupByLibrary.simpleMessage("DONE"),
    "introMeet" : MessageLookupByLibrary.simpleMessage("Meet"),
    "introMeetHint" : MessageLookupByLibrary.simpleMessage("Contact owner of the books you like and arrange appointment to get new books to read."),
    "introShoot" : MessageLookupByLibrary.simpleMessage("Shoot"),
    "introShootHint" : MessageLookupByLibrary.simpleMessage("Shoot your bookcase and share to neighbours and tourists. Your books attract likeminded people."),
    "introSkip" : MessageLookupByLibrary.simpleMessage("SKIP"),
    "introSurf" : MessageLookupByLibrary.simpleMessage("Surf"),
    "introSurfHint" : MessageLookupByLibrary.simpleMessage("App shows bookcases in 200 km around you sorted by distance. Get access to wide variaty of books."),
    "isbnNotFound" : MessageLookupByLibrary.simpleMessage("Book is not found by ISBN"),
    "km" : MessageLookupByLibrary.simpleMessage(" km"),
    "leaseAgreement" : m14,
    "lentBookText" : m15,
    "linkCopied" : MessageLookupByLibrary.simpleMessage("Ссылка скопирована в буфер обмена"),
    "linkToGoodreads" : MessageLookupByLibrary.simpleMessage("Link your Goodreads"),
    "linkYourAccount" : MessageLookupByLibrary.simpleMessage("Link your Goodreads account"),
    "loadPhotoOfShelf" : MessageLookupByLibrary.simpleMessage("Load shelf photo from galery"),
    "loading" : MessageLookupByLibrary.simpleMessage("Loading..."),
    "loginAgree1" : MessageLookupByLibrary.simpleMessage("By clicking sign in button below, you agree \n to our "),
    "loginAgree2" : MessageLookupByLibrary.simpleMessage("end user licence agreement"),
    "loginAgree3" : MessageLookupByLibrary.simpleMessage("\nand that you read our "),
    "loginAgree4" : MessageLookupByLibrary.simpleMessage("privacy policy"),
    "logout" : MessageLookupByLibrary.simpleMessage("Logout"),
    "makePhotoOfShelf" : MessageLookupByLibrary.simpleMessage("Make a photo of your bookshelf"),
    "meet" : MessageLookupByLibrary.simpleMessage("Meet"),
    "menuBalance" : MessageLookupByLibrary.simpleMessage("Баланс"),
    "menuMessages" : MessageLookupByLibrary.simpleMessage("Сообщения"),
    "menuReferral" : MessageLookupByLibrary.simpleMessage("Реферальная программа"),
    "menuSettings" : MessageLookupByLibrary.simpleMessage("Настройки"),
    "menuSupport" : MessageLookupByLibrary.simpleMessage("Поддержка"),
    "messageOwner" : MessageLookupByLibrary.simpleMessage("Message owner"),
    "messageRecepient" : MessageLookupByLibrary.simpleMessage("Chat with book recepient."),
    "myBooks" : MessageLookupByLibrary.simpleMessage("Мои книги"),
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
    "mybooksTitle" : MessageLookupByLibrary.simpleMessage("МОИ КНИГИ"),
    "negativeAmount" : MessageLookupByLibrary.simpleMessage("Сумма должна быть больше нуля"),
    "no" : MessageLookupByLibrary.simpleMessage("No"),
    "noBooks" : MessageLookupByLibrary.simpleMessage("You don\'t have any books in Biblosphere. Add it manually or import from Goodreads."),
    "noBookshelves" : MessageLookupByLibrary.simpleMessage("You don\'t have any bookshelves in Biblosphere. Make a photo of your bookshelf to share with neighbours."),
    "noBorrowedBooks" : MessageLookupByLibrary.simpleMessage("You do not have any borrowed books"),
    "noItemsInCart" : MessageLookupByLibrary.simpleMessage("Your cart is empty. Add books from the list of the books or your matched wishes."),
    "noItemsInOutbox" : MessageLookupByLibrary.simpleMessage("Your outbox is empty. Wait for people to request your books or offer your books in matched books."),
    "noLendedBooks" : MessageLookupByLibrary.simpleMessage("You do not have any lent books"),
    "noMatchForBooks" : MessageLookupByLibrary.simpleMessage("Here you\'ll see people who wish your books once they are registered. To make it happen add more books and spread the word about Biblosphere."),
    "noMatchForWishlist" : MessageLookupByLibrary.simpleMessage("Hey, right now nodody around you has the books from your wishlist. They will be shown here once someone registers them.\nSpread the word about Biblosphere to make it happen sooner. And add more books to your wishlist."),
    "noMessages" : MessageLookupByLibrary.simpleMessage("Нет сообщений"),
    "noOperations" : MessageLookupByLibrary.simpleMessage("No operations"),
    "noReferrals" : MessageLookupByLibrary.simpleMessage("No referrals"),
    "noWishes" : MessageLookupByLibrary.simpleMessage("You don\'t have any books in your wishlist. Add it manually or import from Goodreads."),
    "notBooks" : MessageLookupByLibrary.simpleMessage("Hey, this does not look like a bookshelf to me."),
    "notSufficientForAgreement" : m16,
    "nothingToSend" : MessageLookupByLibrary.simpleMessage("Nothing to send"),
    "ok" : MessageLookupByLibrary.simpleMessage("Ok"),
    "opInAppPurchase" : MessageLookupByLibrary.simpleMessage("Пополнение счёта в приложении"),
    "opInStellar" : MessageLookupByLibrary.simpleMessage("Пополнение счёта через Stellar"),
    "opLeasing" : MessageLookupByLibrary.simpleMessage("Оплата/залог за книгу"),
    "opOutStellar" : MessageLookupByLibrary.simpleMessage("Вывод средств через Stellar"),
    "opReferral" : MessageLookupByLibrary.simpleMessage("Партнёрский доход"),
    "opReward" : MessageLookupByLibrary.simpleMessage("Вознаграждение за книгу"),
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
    "outputStellarAccount" : MessageLookupByLibrary.simpleMessage("Счёт Stellar для выплат:"),
    "paymentError" : MessageLookupByLibrary.simpleMessage("Что-то пошло не так, напишите администратору"),
    "people" : MessageLookupByLibrary.simpleMessage("People"),
    "read" : MessageLookupByLibrary.simpleMessage("Read"),
    "receiveBooks" : m26,
    "recentWishes" : MessageLookupByLibrary.simpleMessage("Recent wishes:"),
    "referralLink" : MessageLookupByLibrary.simpleMessage("Ваша партнёрская ссылка:"),
    "referralTitle" : MessageLookupByLibrary.simpleMessage("МОИ РЕФЕРАЛЫ"),
    "reportShelf" : MessageLookupByLibrary.simpleMessage("Report objectionable content"),
    "reportedPhoto" : MessageLookupByLibrary.simpleMessage("This photo reported as objectionable content."),
    "requestBook" : m27,
    "requestPost" : m28,
    "requestReturn" : m29,
    "requestReturnByOwner" : m30,
    "scanISBN" : MessageLookupByLibrary.simpleMessage("Scan ISBN code"),
    "seeLocation" : MessageLookupByLibrary.simpleMessage("See location"),
    "selectDisplayCurrency" : MessageLookupByLibrary.simpleMessage("Выберите валюту отображения:"),
    "sendBooks" : m31,
    "settings" : MessageLookupByLibrary.simpleMessage("Settings"),
    "share" : MessageLookupByLibrary.simpleMessage("Share"),
    "shareBooks" : MessageLookupByLibrary.simpleMessage("I\'m sharing my books on Biblosphere. Join me to read it."),
    "shareBookshelf" : MessageLookupByLibrary.simpleMessage("That\'s my bookshelf. Join Biblosphere to share books and find like-minded people."),
    "shareShelf" : MessageLookupByLibrary.simpleMessage("Share your bookshelf"),
    "shareWishlist" : MessageLookupByLibrary.simpleMessage("I\'m sharing my book wishlist on Biblosphere. Join me."),
    "sharedFeeLine" : m32,
    "shelfAdded" : MessageLookupByLibrary.simpleMessage("New bookshelf has been added"),
    "shelfCount" : m33,
    "shelfDeleted" : MessageLookupByLibrary.simpleMessage("Bookshelf has been deleted"),
    "shelfSettings" : MessageLookupByLibrary.simpleMessage("Bookshelf settings"),
    "shelves" : MessageLookupByLibrary.simpleMessage("Shelves"),
    "stellarOutput" : MessageLookupByLibrary.simpleMessage("Вывод средств на Stellar счёт:"),
    "successfulPayment" : MessageLookupByLibrary.simpleMessage("Платёж успешно прошёл"),
    "supportTitle" : MessageLookupByLibrary.simpleMessage("ПОДДЕРЖКА"),
    "title" : MessageLookupByLibrary.simpleMessage("Biblosphere"),
    "titleBookSettings" : MessageLookupByLibrary.simpleMessage("О КНИГЕ"),
    "titleGetBook" : MessageLookupByLibrary.simpleMessage("ПОЛУЧИ КНИГУ"),
    "titleMessages" : MessageLookupByLibrary.simpleMessage("СООБЩЕНИЯ"),
    "titleReceiveBooks" : MessageLookupByLibrary.simpleMessage("ВЗЯТЬ КНИГИ"),
    "titleSendBooks" : MessageLookupByLibrary.simpleMessage("ОТДАЮ КНИГИ"),
    "titleSettings" : MessageLookupByLibrary.simpleMessage("НАСТРОЙКИ"),
    "titleUserBooks" : MessageLookupByLibrary.simpleMessage("ОБМЕН КНИГАМИ"),
    "transitAccept" : MessageLookupByLibrary.simpleMessage("Accept"),
    "transitCancel" : MessageLookupByLibrary.simpleMessage("Cancel"),
    "transitConfirm" : MessageLookupByLibrary.simpleMessage("Confirm"),
    "transitInitiated" : MessageLookupByLibrary.simpleMessage("Handover process initiated for the book"),
    "transitOk" : MessageLookupByLibrary.simpleMessage("Ok"),
    "transitReject" : MessageLookupByLibrary.simpleMessage("Reject"),
    "typeMsg" : MessageLookupByLibrary.simpleMessage("Type your message..."),
    "useCurrentLocation" : MessageLookupByLibrary.simpleMessage("Use current location for import"),
    "userBalance" : m34,
    "userHave" : m35,
    "welcome" : MessageLookupByLibrary.simpleMessage("Welcome"),
    "wishAdded" : MessageLookupByLibrary.simpleMessage("Book has been added to your wishlist"),
    "wishCount" : m36,
    "wishDeleted" : MessageLookupByLibrary.simpleMessage("Book has been deleted from your wishlist"),
    "wishToRead" : m37,
    "wished" : MessageLookupByLibrary.simpleMessage("Wished"),
    "wrongAccount" : MessageLookupByLibrary.simpleMessage("Неверный счёт"),
    "wrongImageUrl" : MessageLookupByLibrary.simpleMessage("Неверная ссылка"),
    "yes" : MessageLookupByLibrary.simpleMessage("Yes"),
    "youBorrowThisBook" : MessageLookupByLibrary.simpleMessage("Вы взяли эту книгу"),
    "youHaveThisBook" : MessageLookupByLibrary.simpleMessage("Эта книга находится у вас"),
    "youLentThisBook" : m38,
    "youTransitThisBook" : MessageLookupByLibrary.simpleMessage("По этой книге не завершён процесс передачи"),
    "youWishThisBook" : MessageLookupByLibrary.simpleMessage("Эту книгу вы хотите почитать"),
    "yourBiblosphere" : MessageLookupByLibrary.simpleMessage("Your Biblosphere"),
    "yourGoodreads" : MessageLookupByLibrary.simpleMessage("Your Goodreads"),
    "zoom" : MessageLookupByLibrary.simpleMessage("ZOOM")
  };
}
