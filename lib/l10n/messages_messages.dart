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

  static m1(month) => "Доход: ${month} в месяц";

  static m2(lang) => "Language: ${lang}";

  static m3(user) => "Владелец: ${user}";

  static m4(total) => "Цена: ${total}";

  static m5(month) => "Цена: ${month} в месяц";

  static m6(user) => "Книга у ${user}";

  static m7(count) => "Книги этого пользователя у меня (${count})";

  static m8(name, title) => "Book \'${title}\' belong to user \'${name}\'. Press outbox button below to initiate return.";

  static m9(name, title) => "User \'${name}\' offer you his book \'${title}\'. Please arrange handover and confirm on receive. Or reject in case you are not interested.";

  static m10(name, title) => "User \'${name}\' has accepted your request for his book \'${title}\'. Please arrange handover and confirm on receive.";

  static m11(name, title) => "Wait for user \'${name}\' to accept your request of his book \'${title}\'. Chat to facilitate.";

  static m12(name, title) => "User \'${name}\' has rejected your request for his book \'${title}\'. You can chat to get explamations.";

  static m13(name, title) => "User \'${name}\' wish to return your book \'${title}\'. Please arrange handover.";

  static m14(amount) => "Пополните баланс на ${amount}";

  static m15(distance) => "Расстояние: ${distance} км";

  static m16(balance) => "МОЙ БАЛАНС: ${balance}";

  static m17(amount) => "Введите сумму не более ${amount}";

  static m18(total, month) => "Депозит за книги: ${total}, оплата за месяц ${month}";

  static m19(name, title) => "Your book \'${title}\' now with user \'${name}\'. Chat with him to remind about return.";

  static m20(count) => "Мои книги у этого пользователя (${count})";

  static m21(missing, total, month) => "Вам нехватает ${missing}. Депозит за книги: ${total}, оплата за месяц ${month}";

  static m22(name, title) => "You\'ve offered book \'${title}\' to user \'${name}\'. Please chat to arrange handover.";

  static m23(name, title) => "User \'${name}\' confirmed handover of book \'${title}\'. You can see this book in your MY LENT books.";

  static m24(name, title) => "User \'${name}\' rejected your offer for book \'${title}\'. You can chat to get details.";

  static m25(name, title) => "User \'${name}\' request your book \'${title}\'. Please accept or reject. Chat for more details.";

  static m26(name, title) => "Please arrange handover of book \'${title}\' to user \'${name}\'. Chat to coordinate.";

  static m27(name, title) => "User \'${name}\' canceled request for your book \'${title}\'.";

  static m28(name, title) => "Handover of book \'${title}\' to user \'${name}\' confirmed. You can see this book in MY LENT books.";

  static m29(name, title) => "Arrange handover of book \'${title}\' to user \'${name}\'. Chat to facilitate.";

  static m30(name, title) => "User \'${name}\' confirmed handover of the book \'${title}\'.";

  static m31(count) => "Книги пользователя (${count})";

  static m32(num) => "Взять книги (${num})";

  static m33(book) => "Можно взять у вас \"${book}\"?";

  static m34(book) => "Можете прислать мне \"${book}\"?";

  static m35(book) => "Хочу вернуть вам \"${book}\"?";

  static m36(book) => "Пожалуйста, верните книгу \"${book}\"?";

  static m37(num) => "Отдаю книги (${num})";

  static m38(amount) => "Общий доход: +${amount}";

  static m39(count) => "${Intl.plural(count, zero: 'No bookshelves', one: '${count} bookshelf', other: '${count} bookshelves')}";

  static m40(amount) => "Залог: ${amount}";

  static m41(amount) => "Оплата в месяц: ${amount}";

  static m42(balance) => "Balance: ${balance}";

  static m43(user) => "У пользователя ${user}";

  static m44(count) => "${Intl.plural(count, zero: 'No wishes', one: '${count} wish', other: '${count} wishes')}";

  static m45(name, title) => "${name} wish to read your book \'${title}\'";

  static m46(user) => "Книга у ${user}";

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
    "bookAlreadyThere" : MessageLookupByLibrary.simpleMessage("Эта книга уже есть у вас в каталоге"),
    "bookAround" : MessageLookupByLibrary.simpleMessage("Книга поблизости"),
    "bookByPost" : MessageLookupByLibrary.simpleMessage("Получи по почте"),
    "bookCount" : m0,
    "bookDeleted" : MessageLookupByLibrary.simpleMessage("Book has been deleted from your library"),
    "bookImageLabel" : MessageLookupByLibrary.simpleMessage("Ссылка на фото обложки:"),
    "bookInLibrary" : MessageLookupByLibrary.simpleMessage("Найди в библиотеке через"),
    "bookIncome" : m1,
    "bookLanguage" : m2,
    "bookNotFound" : MessageLookupByLibrary.simpleMessage("Эта книга не найдена в Библосфере. Добавьте её в желаемые книги и мы сообщим вам, когда она появится рядом с вами."),
    "bookOwner" : m3,
    "bookPrice" : m4,
    "bookPriceHint" : MessageLookupByLibrary.simpleMessage("Введите цену книги"),
    "bookPriceLabel" : MessageLookupByLibrary.simpleMessage("Цена книги"),
    "bookRent" : m5,
    "bookWith" : m6,
    "books" : MessageLookupByLibrary.simpleMessage("Books"),
    "booksOfUserWithMe" : m7,
    "bookshelves" : MessageLookupByLibrary.simpleMessage("Bookshelves"),
    "borrow" : MessageLookupByLibrary.simpleMessage("Borrow"),
    "borrowedBookText" : m8,
    "buttonConfirmBooks" : MessageLookupByLibrary.simpleMessage("Книги получил ✓"),
    "buttonGivenBooks" : MessageLookupByLibrary.simpleMessage("Книги отдал ✓"),
    "buttonPayin" : MessageLookupByLibrary.simpleMessage("Пополнить счёт"),
    "buttonTransfer" : MessageLookupByLibrary.simpleMessage("Перевести"),
    "buyBook" : MessageLookupByLibrary.simpleMessage("Купи на"),
    "cart" : MessageLookupByLibrary.simpleMessage("Books you are going to take"),
    "cartAddBooks" : MessageLookupByLibrary.simpleMessage("Добавьте книги"),
    "cartBooksAccepted" : MessageLookupByLibrary.simpleMessage("Книги успешно получены"),
    "cartBooksGiven" : MessageLookupByLibrary.simpleMessage("Книги успешно переданы"),
    "cartConfirmHandover" : MessageLookupByLibrary.simpleMessage("Подтвердите, что отдали книги"),
    "cartConfirmReceived" : MessageLookupByLibrary.simpleMessage("Подтвердите получение книг"),
    "cartMakeApointment" : MessageLookupByLibrary.simpleMessage("Договоритесь о встрече"),
    "cartOfferConfirmReject" : m9,
    "cartRequestAccepted" : m10,
    "cartRequestCancel" : m11,
    "cartRequestRejected" : m12,
    "cartRequesterHasToConfirm" : MessageLookupByLibrary.simpleMessage("Получатель должен подтвердить получение книг"),
    "cartRequesterHasToTopup" : MessageLookupByLibrary.simpleMessage("Получатель книг должен пополнить баланс"),
    "cartReturnConfirm" : m13,
    "cartTopup" : m14,
    "chat" : MessageLookupByLibrary.simpleMessage("CHAT"),
    "chatStatusCompleteFrom" : MessageLookupByLibrary.simpleMessage("Книги переданы"),
    "chatStatusCompleteTo" : MessageLookupByLibrary.simpleMessage("Книги получены"),
    "chatStatusHandoverFrom" : MessageLookupByLibrary.simpleMessage("Завершите передачу книг"),
    "chatStatusHandoverTo" : MessageLookupByLibrary.simpleMessage("Подтвердите получение книг"),
    "chatStatusInitialFrom" : MessageLookupByLibrary.simpleMessage("Отдайте книги"),
    "chatStatusInitialTo" : MessageLookupByLibrary.simpleMessage("Получите книги"),
    "chatbotWelcome" : MessageLookupByLibrary.simpleMessage("Привет! Я чатбот Библосферы, задавай мне любые вопросы про приложение. Если я не смогу ответить, перешлю администратору."),
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
    "distanceLine" : m15,
    "distanceUnknown" : MessageLookupByLibrary.simpleMessage("Расстояние: неизвестно"),
    "drawerHeader" : MessageLookupByLibrary.simpleMessage("Choose mode"),
    "earn" : MessageLookupByLibrary.simpleMessage("Earn"),
    "emptyAmount" : MessageLookupByLibrary.simpleMessage("Сумма не может быть пустой"),
    "enterTitle" : MessageLookupByLibrary.simpleMessage("Enter title/author"),
    "exceedAmount" : MessageLookupByLibrary.simpleMessage("Сумма должна быть меньше доступного остатка"),
    "explore" : MessageLookupByLibrary.simpleMessage("Explore"),
    "favorite" : MessageLookupByLibrary.simpleMessage("Add shelf to favorite"),
    "financeTitle" : m16,
    "findBook" : MessageLookupByLibrary.simpleMessage("Найти книгу"),
    "findbookTitle" : MessageLookupByLibrary.simpleMessage("НАЙДИ КНИГУ"),
    "hintAuthorTitle" : MessageLookupByLibrary.simpleMessage("Автор или название"),
    "hintBookDetails" : MessageLookupByLibrary.simpleMessage("Изменить информацию о книге"),
    "hintChatOpen" : MessageLookupByLibrary.simpleMessage("Перейти в чат"),
    "hintDeleteBook" : MessageLookupByLibrary.simpleMessage("Удалить книгу"),
    "hintNotMore" : m17,
    "hintOutptAcount" : MessageLookupByLibrary.simpleMessage("Ваш Stellar счёт для вывода средств"),
    "hintRequestReturn" : MessageLookupByLibrary.simpleMessage("Попросить вернуть книгу"),
    "hintReturn" : MessageLookupByLibrary.simpleMessage("Вернуть книгу"),
    "hintShareBook" : MessageLookupByLibrary.simpleMessage("Поделиться ссылкой"),
    "ifNotFound" : MessageLookupByLibrary.simpleMessage("Если вы не нашли книгу вы можете:"),
    "imageLinkHint" : MessageLookupByLibrary.simpleMessage("Скопируйте ссылку на обложку книги"),
    "importToBooks" : MessageLookupByLibrary.simpleMessage("Import to available books:"),
    "importToWishlist" : MessageLookupByLibrary.simpleMessage("Import to Wishlist:"),
    "importYouBooks" : MessageLookupByLibrary.simpleMessage("Import your books to Biblosphere"),
    "inMyBooks" : MessageLookupByLibrary.simpleMessage("Эта книга есть у вас"),
    "inMyWishes" : MessageLookupByLibrary.simpleMessage("Эта книга в вашем списке желаний"),
    "inputStellarAcount" : MessageLookupByLibrary.simpleMessage("Счёт Stellar для пополнения:"),
    "inputStellarMemo" : MessageLookupByLibrary.simpleMessage("Memo для пополнения через Stellar:"),
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
    "leaseAgreement" : m18,
    "lentBookText" : m19,
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
    "memoCopied" : MessageLookupByLibrary.simpleMessage("Memo скопировано в буфер обмена"),
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
    "myBooksWithUser" : m20,
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
    "notSufficientForAgreement" : m21,
    "nothingToSend" : MessageLookupByLibrary.simpleMessage("Nothing to send"),
    "ok" : MessageLookupByLibrary.simpleMessage("Ok"),
    "opInAppPurchase" : MessageLookupByLibrary.simpleMessage("Пополнение счёта в приложении"),
    "opInStellar" : MessageLookupByLibrary.simpleMessage("Пополнение счёта через Stellar"),
    "opLeasing" : MessageLookupByLibrary.simpleMessage("Оплата/залог за книгу"),
    "opOutStellar" : MessageLookupByLibrary.simpleMessage("Вывод средств через Stellar"),
    "opReferral" : MessageLookupByLibrary.simpleMessage("Партнёрский доход"),
    "opReward" : MessageLookupByLibrary.simpleMessage("Вознаграждение за книгу"),
    "outbox" : MessageLookupByLibrary.simpleMessage("Books you are giving away"),
    "outboxOfferAccepted" : m22,
    "outboxOfferConfirmed" : m23,
    "outboxOfferRejected" : m24,
    "outboxRequestAcceptReject" : m25,
    "outboxRequestAccepted" : m26,
    "outboxRequestCanceled" : m27,
    "outboxRequestConfirmed" : m28,
    "outboxReturnAccepted" : m29,
    "outboxReturnConfirmed" : m30,
    "outputStellarAccount" : MessageLookupByLibrary.simpleMessage("Счёт Stellar для выплат:"),
    "outputStellarMemo" : MessageLookupByLibrary.simpleMessage("Memo для вывода Stellar:"),
    "paymentError" : MessageLookupByLibrary.simpleMessage("Что-то пошло не так, напишите администратору"),
    "people" : MessageLookupByLibrary.simpleMessage("People"),
    "profileUserBooks" : m31,
    "read" : MessageLookupByLibrary.simpleMessage("Read"),
    "receiveBooks" : m32,
    "recentWishes" : MessageLookupByLibrary.simpleMessage("Recent wishes:"),
    "referralLink" : MessageLookupByLibrary.simpleMessage("Ваша партнёрская ссылка:"),
    "referralTitle" : MessageLookupByLibrary.simpleMessage("МОИ РЕФЕРАЛЫ"),
    "reportShelf" : MessageLookupByLibrary.simpleMessage("Report objectionable content"),
    "reportedPhoto" : MessageLookupByLibrary.simpleMessage("This photo reported as objectionable content."),
    "requestBook" : m33,
    "requestPost" : m34,
    "requestReturn" : m35,
    "requestReturnByOwner" : m36,
    "scanISBN" : MessageLookupByLibrary.simpleMessage("Scan ISBN code"),
    "seeLocation" : MessageLookupByLibrary.simpleMessage("See location"),
    "selectDisplayCurrency" : MessageLookupByLibrary.simpleMessage("Выберите валюту отображения:"),
    "sendBooks" : m37,
    "settings" : MessageLookupByLibrary.simpleMessage("Settings"),
    "share" : MessageLookupByLibrary.simpleMessage("Share"),
    "shareBooks" : MessageLookupByLibrary.simpleMessage("I\'m sharing my books on Biblosphere. Join me to read it."),
    "shareBookshelf" : MessageLookupByLibrary.simpleMessage("That\'s my bookshelf. Join Biblosphere to share books and find like-minded people."),
    "shareShelf" : MessageLookupByLibrary.simpleMessage("Share your bookshelf"),
    "shareWishlist" : MessageLookupByLibrary.simpleMessage("I\'m sharing my book wishlist on Biblosphere. Join me."),
    "sharedFeeLine" : m38,
    "sharingMotto" : MessageLookupByLibrary.simpleMessage("Бери книги у людей вместо покупки в магазинах"),
    "shelfAdded" : MessageLookupByLibrary.simpleMessage("New bookshelf has been added"),
    "shelfCount" : m39,
    "shelfDeleted" : MessageLookupByLibrary.simpleMessage("Bookshelf has been deleted"),
    "shelfSettings" : MessageLookupByLibrary.simpleMessage("Bookshelf settings"),
    "shelves" : MessageLookupByLibrary.simpleMessage("Shelves"),
    "showDeposit" : m40,
    "showRent" : m41,
    "snackAllowLocation" : MessageLookupByLibrary.simpleMessage("Дайте разрешение на использование текущей позиции для поиска и добавления книг"),
    "snackBookAddedToCart" : MessageLookupByLibrary.simpleMessage("Книга добавлена в корзину"),
    "snackBookAlreadyInTransit" : MessageLookupByLibrary.simpleMessage("Книга передаётся другому пользователю. Выберите другую книгу."),
    "snackBookImageChanged" : MessageLookupByLibrary.simpleMessage("Новая обложка книги установлена."),
    "snackBookNotConfirmed" : MessageLookupByLibrary.simpleMessage("Вы не подтвердили получение книг и не можете взять другую книгу"),
    "snackBookNotFound" : MessageLookupByLibrary.simpleMessage("Книга не найдена. Добавьте книги в корзину вручную."),
    "snackBookPending" : MessageLookupByLibrary.simpleMessage("Прошлая передача книг не завершена и вы не можете добавлять книги"),
    "snackBookPriceChanged" : MessageLookupByLibrary.simpleMessage("Цена книги установлена."),
    "stellarOutput" : MessageLookupByLibrary.simpleMessage("Вывод средств на Stellar счёт:"),
    "successfulPayment" : MessageLookupByLibrary.simpleMessage("Платёж добавлен в очередь на исполнение"),
    "supportChat" : MessageLookupByLibrary.simpleMessage("Чат с поддержкой"),
    "supportChatbot" : MessageLookupByLibrary.simpleMessage("Во вкладке Сообщения есть чат с ботом Библосферы, он может ответить на любые вопросы о приложении. Если понадобится связаться напрямую со мной, пишите в telegram "),
    "supportGetBalance" : MessageLookupByLibrary.simpleMessage("Пополнить счёт можно двумя способами: через покупку в приложении по карточке, зарегистрированной в Google Play или App Store. Или сделать перевод криптовалюты Stellar (XLM) на счёт, указанный в настройках."),
    "supportGetBooks" : MessageLookupByLibrary.simpleMessage("Найдите книгу, которую Вы хотите почитать, и напишите её хозяину, чтобы договориться о встрече. При получении книг вам нужно будет оплатить депозит. Вы можете пополнить свой баланс по карточке или криптовалютой Stellar, а можете заработать в Библосфере, давая свои книги почитать. Вы также можете зарабатывать через партнёрскую программу, приглашая других участников."),
    "supportPayout" : MessageLookupByLibrary.simpleMessage("Если у Вас большой баланс в Библосфере, Вы можете вывести эти средства. Вывести средства можно на свой кошелёк Stellar или через Stellar на любой кошелёк, карту или счёт. Для вывода на карту или кошелёк воспользуйстесь услугами online-обменников."),
    "supportReferrals" : MessageLookupByLibrary.simpleMessage("Организуйте обмен книгами через Библосферу в своём сообществе или офисе и получайте комиссию за каждую сделку. Для этого поделитесь с друзьями и коллегами ссылкой на приложение (Вашей партнёрской ссылкой)."),
    "supportSignature" : MessageLookupByLibrary.simpleMessage("Денис Старк"),
    "supportTitle" : MessageLookupByLibrary.simpleMessage("ПОДДЕРЖКА"),
    "supportTitleChatbot" : MessageLookupByLibrary.simpleMessage("Чат-бот Библосферы"),
    "supportTitleGetBalance" : MessageLookupByLibrary.simpleMessage("Пополнение счёта"),
    "supportTitleGetBooks" : MessageLookupByLibrary.simpleMessage("Как брать книги"),
    "supportTitlePayout" : MessageLookupByLibrary.simpleMessage("Вывод средств"),
    "supportTitleReferrals" : MessageLookupByLibrary.simpleMessage("Партнёрская программа"),
    "title" : MessageLookupByLibrary.simpleMessage("Biblosphere"),
    "titleBookSettings" : MessageLookupByLibrary.simpleMessage("О КНИГЕ"),
    "titleGetBook" : MessageLookupByLibrary.simpleMessage("КНИГИ НЕТ"),
    "titleMessages" : MessageLookupByLibrary.simpleMessage("СООБЩЕНИЯ"),
    "titleReceiveBooks" : MessageLookupByLibrary.simpleMessage("ВЗЯТЬ КНИГИ"),
    "titleSendBooks" : MessageLookupByLibrary.simpleMessage("ОТДАЮ КНИГИ"),
    "titleSettings" : MessageLookupByLibrary.simpleMessage("НАСТРОЙКИ"),
    "titleSupport" : MessageLookupByLibrary.simpleMessage("ПОДДЕРЖКА"),
    "titleUserBooks" : MessageLookupByLibrary.simpleMessage("ОБМЕН КНИГАМИ"),
    "transitAccept" : MessageLookupByLibrary.simpleMessage("Accept"),
    "transitCancel" : MessageLookupByLibrary.simpleMessage("Cancel"),
    "transitConfirm" : MessageLookupByLibrary.simpleMessage("Confirm"),
    "transitInitiated" : MessageLookupByLibrary.simpleMessage("Handover process initiated for the book"),
    "transitOk" : MessageLookupByLibrary.simpleMessage("Ok"),
    "transitReject" : MessageLookupByLibrary.simpleMessage("Reject"),
    "typeMsg" : MessageLookupByLibrary.simpleMessage("Type your message..."),
    "useCurrentLocation" : MessageLookupByLibrary.simpleMessage("Use current location for import"),
    "userBalance" : m42,
    "userHave" : m43,
    "welcome" : MessageLookupByLibrary.simpleMessage("WELCOME"),
    "wishAdded" : MessageLookupByLibrary.simpleMessage("Book has been added to your wishlist"),
    "wishAlreadyThere" : MessageLookupByLibrary.simpleMessage("Эта книга уже есть в вашем списке желаний"),
    "wishCount" : m44,
    "wishDeleted" : MessageLookupByLibrary.simpleMessage("Book has been deleted from your wishlist"),
    "wishToRead" : m45,
    "wished" : MessageLookupByLibrary.simpleMessage("Wished"),
    "wrongAccount" : MessageLookupByLibrary.simpleMessage("Неверный счёт"),
    "wrongImageUrl" : MessageLookupByLibrary.simpleMessage("Неверная ссылка"),
    "yes" : MessageLookupByLibrary.simpleMessage("Yes"),
    "youBorrowThisBook" : MessageLookupByLibrary.simpleMessage("Вы взяли эту книгу"),
    "youHaveThisBook" : MessageLookupByLibrary.simpleMessage("Книга у вас"),
    "youLentThisBook" : m46,
    "youTransitThisBook" : MessageLookupByLibrary.simpleMessage("По этой книге не завершён процесс передачи"),
    "youWishThisBook" : MessageLookupByLibrary.simpleMessage("Эту книгу вы хотите почитать"),
    "yourBiblosphere" : MessageLookupByLibrary.simpleMessage("Your Biblosphere"),
    "yourGoodreads" : MessageLookupByLibrary.simpleMessage("Your Goodreads"),
    "zoom" : MessageLookupByLibrary.simpleMessage("ZOOM")
  };
}
