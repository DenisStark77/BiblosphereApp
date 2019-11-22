// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
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
  String get localeName => 'ru';

  static m0(count) => "${Intl.plural(count, zero: 'Нет книг', one: '${count} книга', other: '${count} книг')}";

  static m1(lang) => "Язык: ${lang}";

  static m2(user) => "Владелец: ${user}";

  static m3(total) => "Цена: ${total}";

  static m4(month) => "Аренда: ${month} в месяц";

  static m5(user) => "Книга у ${user}";

  static m6(count) => "Книги этого пользователя у меня (${count})";

  static m7(name, title) => "Книга \'${title}\' принадлежит пользователю \'${name}\'. Нажмите кнопку \"Отгрузка\" ниже, чтобы сообщить о возврате книги.";

  static m8(name, title) => "Пользователь \'${name}\' предлагает вам книгу \'${title}\'. Пожалуйста, договоритесь о встрече и подтвердите получение книги. Или откажитесь, если вы не заинтересованы.";

  static m9(name, title) => "Пользователь \'${name}\' подтвердил ваш запрос книги \'${title}\'. Договоритесь о встрече и подтвердите получение книги при получении.";

  static m10(name, title) => "Дождитесь пока пользователь \'${name}\' подтвердит ваш запрос книги \'${title}\'. Спишитесь, чтобы договориться.";

  static m11(name, title) => "Пользователь \'${name}\' отклонил ваш запрос книги \'${title}\'. Вы можете написать ему, чтобы уточнить причину.";

  static m12(name, title) => "Пользователь \'${name}\' хочет вернуть вашу книгу \'${title}\'. Пожалуйста, договоритесь о встрече.";

  static m13(amount) => "Пополните баланс на ${amount}";

  static m14(distance) => "Расстояние: ${distance} км";

  static m15(balance) => "МОЙ БАЛАНС: ${balance}";

  static m16(amount) => "Введите сумму не более ${amount}";

  static m17(total, month) => "Депозит за книги: ${total}, оплата за месяц ${month}";

  static m18(name, title) => "Ваша книга \'${title}\' сейчас у пользователя \'${name}\'. Спишитесь, чтобы напомнить о возвращении книги.";

  static m19(count) => "Мои книги у этого пользователя (${count})";

  static m20(missing, total, month) => "Вам нехватает ${missing}. Депозит за книги: ${total}, оплата за месяц ${month}";

  static m21(name, title) => "Вы предложили книгу \'${title}\' пользователю \'${name}\'. Спишитесь, чтобы договориться о передаче книги.";

  static m22(name, title) => "Пользователь \'${name}\' подтвердил получение книги \'${title}\'. Книга добавлена в ваши \"Отданные книги\".";

  static m23(name, title) => "Пользователь \'${name}\' отказался от предложенной вами книги \'${title}\'. Вы можете списаться, чтобы уточнить причину.";

  static m24(name, title) => "Пользователь \'${name}\' запросил вашу книгу \'${title}\'. Пожалуйста, подтвердите или откажите. Спишитесь, чтобы познакомиться и договориться.";

  static m25(name, title) => "Передайте книгу \'${title}\' пользователю \'${name}\'. Спишитесь, чтобы договориться.";

  static m26(name, title) => "Пользователь \'${name}\' отменил запрос на вашу книгу \'${title}\'.";

  static m27(name, title) => "Пользователь \'${name}\' подтвердил получение книги \'${title}\'. Книга добавлена в ваши \"Взятые книги\".";

  static m28(name, title) => "Передайте книгу \'${title}\' пользователю \'${name}\'. Спишитесь, чтобы договориться.";

  static m29(name, title) => "Пользователь \'${name}\' подтвердил получение книги \'${title}\'.";

  static m30(count) => "Книги пользователя (${count})";

  static m31(num) => "Взять книги (${num})";

  static m32(book) => "Можно взять у вас \"${book}\"?";

  static m33(book) => "Можете прислать мне \"${book}\"?";

  static m34(book) => "Хочу вернуть вам \"${book}\"?";

  static m35(book) => "Пожалуйста, верните книгу \"${book}\"?";

  static m36(num) => "Отдаю книги (${num})";

  static m37(amount) => "Общий доход: +${amount}";

  static m38(count) => "${Intl.plural(count, zero: 'Нет полок', one: '${count} полка', other: '${count} полок')}";

  static m39(amount) => "Залог: ${amount}";

  static m40(amount) => "Оплата в месяц: ${amount}";

  static m41(balance) => "Баланс: ${balance}";

  static m42(user) => "У ${user}";

  static m43(count) => "${Intl.plural(count, zero: 'Нет желанных книг', one: '${count} желанная книга', other: '${count} желанных книг')}";

  static m44(name, title) => "${name} хочет почитать Вашу книгу \'${title}\'";

  static m45(user) => "Книга у ${user}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "accountCopied" : MessageLookupByLibrary.simpleMessage("Счёт скопирован в буфер обмена"),
    "add" : MessageLookupByLibrary.simpleMessage("Добавить"),
    "addBook" : MessageLookupByLibrary.simpleMessage("Добавить книгу"),
    "addShelf" : MessageLookupByLibrary.simpleMessage("Добавить книжную полку"),
    "addToCart" : MessageLookupByLibrary.simpleMessage("Добавить в корзину"),
    "addToOutbox" : MessageLookupByLibrary.simpleMessage("Добавить в отгрузку"),
    "addToWishlist" : MessageLookupByLibrary.simpleMessage("Добавить в желаемые книги"),
    "addYourBook" : MessageLookupByLibrary.simpleMessage("Добавить свою книгу"),
    "addYourBookshelf" : MessageLookupByLibrary.simpleMessage("Добавьте вашу полку"),
    "addbookTitle" : MessageLookupByLibrary.simpleMessage("ДОБАВЬ КНИГУ"),
    "blockUser" : MessageLookupByLibrary.simpleMessage("Заблокировать пользователя"),
    "blockedChat" : MessageLookupByLibrary.simpleMessage("Пользователь заблокирован"),
    "bookAdded" : MessageLookupByLibrary.simpleMessage("Книга была добавлена в ваш каталог"),
    "bookAlreadyThere" : MessageLookupByLibrary.simpleMessage("Эта книга уже есть у вас в каталоге"),
    "bookAround" : MessageLookupByLibrary.simpleMessage("Книга поблизости"),
    "bookByPost" : MessageLookupByLibrary.simpleMessage("Получи по почте"),
    "bookCount" : m0,
    "bookDeleted" : MessageLookupByLibrary.simpleMessage("Книга была удалена из вашего каталога"),
    "bookImageLabel" : MessageLookupByLibrary.simpleMessage("Ссылка на фото обложки:"),
    "bookInLibrary" : MessageLookupByLibrary.simpleMessage("Найди в библиотеке через"),
    "bookLanguage" : m1,
    "bookNotFound" : MessageLookupByLibrary.simpleMessage("Эта книга не найдена в Библосфере. Добавьте её в желаемые книги и мы сообщим вам, когда она появится рядом с вами."),
    "bookOwner" : m2,
    "bookPrice" : m3,
    "bookPriceHint" : MessageLookupByLibrary.simpleMessage("Введите цену книги"),
    "bookPriceLabel" : MessageLookupByLibrary.simpleMessage("Цена книги"),
    "bookRent" : m4,
    "bookWith" : m5,
    "books" : MessageLookupByLibrary.simpleMessage("Книги"),
    "booksOfUserWithMe" : m6,
    "bookshelves" : MessageLookupByLibrary.simpleMessage("Полки"),
    "borrow" : MessageLookupByLibrary.simpleMessage("Возьми"),
    "borrowedBookText" : m7,
    "buttonConfirmBooks" : MessageLookupByLibrary.simpleMessage("Книги получил ✓"),
    "buttonGivenBooks" : MessageLookupByLibrary.simpleMessage("Книги отдал ✓"),
    "buttonPayin" : MessageLookupByLibrary.simpleMessage("Пополнить счёт"),
    "buttonTransfer" : MessageLookupByLibrary.simpleMessage("Перевести"),
    "buyBook" : MessageLookupByLibrary.simpleMessage("Купи на"),
    "cart" : MessageLookupByLibrary.simpleMessage("Книги, которые вы берёте"),
    "cartAddBooks" : MessageLookupByLibrary.simpleMessage("Добавьте книги"),
    "cartBooksAccepted" : MessageLookupByLibrary.simpleMessage("Книги успешно получены"),
    "cartBooksGiven" : MessageLookupByLibrary.simpleMessage("Книги успешно переданы"),
    "cartConfirmHandover" : MessageLookupByLibrary.simpleMessage("Подтвердите, что отдали книги"),
    "cartConfirmReceived" : MessageLookupByLibrary.simpleMessage("Подтвердите получение книг"),
    "cartMakeApointment" : MessageLookupByLibrary.simpleMessage("Договоритесь о встрече"),
    "cartOfferConfirmReject" : m8,
    "cartRequestAccepted" : m9,
    "cartRequestCancel" : m10,
    "cartRequestRejected" : m11,
    "cartRequesterHasToConfirm" : MessageLookupByLibrary.simpleMessage("Получатель должен подтвердить получение книг"),
    "cartRequesterHasToTopup" : MessageLookupByLibrary.simpleMessage("Получатель книг должен пополнить баланс"),
    "cartReturnConfirm" : m12,
    "cartTopup" : m13,
    "chat" : MessageLookupByLibrary.simpleMessage("ЧАТ"),
    "chatStatusCompleteFrom" : MessageLookupByLibrary.simpleMessage("Книги переданы"),
    "chatStatusCompleteTo" : MessageLookupByLibrary.simpleMessage("Книги получены"),
    "chatStatusHandoverFrom" : MessageLookupByLibrary.simpleMessage("Завершите передачу книг"),
    "chatStatusHandoverTo" : MessageLookupByLibrary.simpleMessage("Подтвердите получение книг"),
    "chatStatusInitialFrom" : MessageLookupByLibrary.simpleMessage("Отдайте книги"),
    "chatStatusInitialTo" : MessageLookupByLibrary.simpleMessage("Получите книги"),
    "chatbotWelcome" : MessageLookupByLibrary.simpleMessage("Привет! Я чатбот Библосферы, задавай мне любые вопросы про приложение."),
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
    "confirmBlockUser" : MessageLookupByLibrary.simpleMessage("Заблокировать пользователя?"),
    "confirmReportPhoto" : MessageLookupByLibrary.simpleMessage("Пожаловаться на фото?"),
    "deleteShelf" : MessageLookupByLibrary.simpleMessage("Удалить полку"),
    "displayCurrency" : MessageLookupByLibrary.simpleMessage("Валюта отображения:"),
    "distanceLine" : m14,
    "drawerHeader" : MessageLookupByLibrary.simpleMessage("Выбери режим"),
    "earn" : MessageLookupByLibrary.simpleMessage("Заработай"),
    "emptyAmount" : MessageLookupByLibrary.simpleMessage("Сумма не может быть пустой"),
    "enterTitle" : MessageLookupByLibrary.simpleMessage("Начните вводить автора и/или название"),
    "exceedAmount" : MessageLookupByLibrary.simpleMessage("Сумма должна быть меньше доступного остатка"),
    "explore" : MessageLookupByLibrary.simpleMessage("Исследовать"),
    "favorite" : MessageLookupByLibrary.simpleMessage("Добавить полку в избранное"),
    "financeTitle" : m15,
    "findBook" : MessageLookupByLibrary.simpleMessage("Найти книгу"),
    "findbookTitle" : MessageLookupByLibrary.simpleMessage("НАЙДИ КНИГУ"),
    "hintAuthorTitle" : MessageLookupByLibrary.simpleMessage("Автор или название"),
    "hintBookDetails" : MessageLookupByLibrary.simpleMessage("Изменить информацию о книге"),
    "hintChatOpen" : MessageLookupByLibrary.simpleMessage("Перейти в чат"),
    "hintDeleteBook" : MessageLookupByLibrary.simpleMessage("Удалить книгу"),
    "hintNotMore" : m16,
    "hintOutptAcount" : MessageLookupByLibrary.simpleMessage("Ваш Stellar счёт для вывода средств"),
    "hintRequestReturn" : MessageLookupByLibrary.simpleMessage("Попросить вернуть книгу"),
    "hintReturn" : MessageLookupByLibrary.simpleMessage("Вернуть книгу"),
    "hintShareBook" : MessageLookupByLibrary.simpleMessage("Поделиться ссылкой"),
    "ifNotFound" : MessageLookupByLibrary.simpleMessage("Добавьте в желаемые книги, если вы её не нашли"),
    "imageLinkHint" : MessageLookupByLibrary.simpleMessage("Скопируйте ссылку на обложку книги"),
    "importToBooks" : MessageLookupByLibrary.simpleMessage("Загрузить в список моих книг:"),
    "importToWishlist" : MessageLookupByLibrary.simpleMessage("Загрузить в список желаемых книг:"),
    "importYouBooks" : MessageLookupByLibrary.simpleMessage("Загрузи книги в Библосферу"),
    "inMyBooks" : MessageLookupByLibrary.simpleMessage("Эта книга есть у вас"),
    "inMyWishes" : MessageLookupByLibrary.simpleMessage("Эта книга в вашем списке желаний"),
    "inputStellarAcount" : MessageLookupByLibrary.simpleMessage("Счёт Stellar для пополнения:"),
    "inputStellarMemo" : MessageLookupByLibrary.simpleMessage("Memo для пополнения через Stellar:"),
    "introDone" : MessageLookupByLibrary.simpleMessage("НАЧАТЬ"),
    "introMeet" : MessageLookupByLibrary.simpleMessage("Встречайся"),
    "introMeetHint" : MessageLookupByLibrary.simpleMessage("Свяжись с владельцем понравившейся книги и договорись о встрече, чтобы взять книгу почитать."),
    "introShoot" : MessageLookupByLibrary.simpleMessage("Снимай"),
    "introShootHint" : MessageLookupByLibrary.simpleMessage("Сфотографируй и покажи свои книжные полки. Твои книги привлекут единомышленников."),
    "introSkip" : MessageLookupByLibrary.simpleMessage("ПРОПУСТИТЬ"),
    "introSurf" : MessageLookupByLibrary.simpleMessage("Исследуй"),
    "introSurfHint" : MessageLookupByLibrary.simpleMessage("Приложение показвыает книжные полки в радиусе 200 км. Получи доступ к книгам соседей."),
    "isbnNotFound" : MessageLookupByLibrary.simpleMessage("Книга не найдена по ISBN"),
    "km" : MessageLookupByLibrary.simpleMessage(" км"),
    "leaseAgreement" : m17,
    "lentBookText" : m18,
    "linkCopied" : MessageLookupByLibrary.simpleMessage("Ссылка скопирована в буфер обмена"),
    "linkToGoodreads" : MessageLookupByLibrary.simpleMessage("Подключи свой Goodreads"),
    "linkYourAccount" : MessageLookupByLibrary.simpleMessage("Подключи учётную запись Goodreads"),
    "loadPhotoOfShelf" : MessageLookupByLibrary.simpleMessage("Загрузи фото полки из галереи"),
    "loading" : MessageLookupByLibrary.simpleMessage("Загружается..."),
    "loginAgree1" : MessageLookupByLibrary.simpleMessage("Заходя в приложение вы соглашаетесь\n с нашим "),
    "loginAgree2" : MessageLookupByLibrary.simpleMessage("пользовательским соглашением"),
    "loginAgree3" : MessageLookupByLibrary.simpleMessage("\nи подтверждаете согласие с "),
    "loginAgree4" : MessageLookupByLibrary.simpleMessage("политикой конфиденциальности"),
    "logout" : MessageLookupByLibrary.simpleMessage("Выйти"),
    "makePhotoOfShelf" : MessageLookupByLibrary.simpleMessage("Сделайте фотографию вашей книжной полки"),
    "meet" : MessageLookupByLibrary.simpleMessage("Люди"),
    "memoCopied" : MessageLookupByLibrary.simpleMessage("Memo скопировано в буфер обмена"),
    "menuBalance" : MessageLookupByLibrary.simpleMessage("Баланс"),
    "menuMessages" : MessageLookupByLibrary.simpleMessage("Сообщения"),
    "menuReferral" : MessageLookupByLibrary.simpleMessage("Реферальная программа"),
    "menuSettings" : MessageLookupByLibrary.simpleMessage("Настройки"),
    "menuSupport" : MessageLookupByLibrary.simpleMessage("Поддержка"),
    "messageOwner" : MessageLookupByLibrary.simpleMessage("Написать владельцу"),
    "messageRecepient" : MessageLookupByLibrary.simpleMessage("Спишись с получателем книги."),
    "myBooks" : MessageLookupByLibrary.simpleMessage("Мои книги"),
    "myBooksItem" : MessageLookupByLibrary.simpleMessage("Мои книги"),
    "myBooksTitle" : MessageLookupByLibrary.simpleMessage("МОИ КНИГИ"),
    "myBooksWithUser" : m19,
    "myBookshelvesItem" : MessageLookupByLibrary.simpleMessage("Мои полки"),
    "myBookshelvesTitle" : MessageLookupByLibrary.simpleMessage("МОИ ПОЛКИ"),
    "myBorrowedBooksItem" : MessageLookupByLibrary.simpleMessage("Взятые книги"),
    "myBorrowedBooksTitle" : MessageLookupByLibrary.simpleMessage("ВЗЯТЫЕ КНИГИ"),
    "myCartTitle" : MessageLookupByLibrary.simpleMessage("МОЯ КОРЗИНА"),
    "myLendedBooksItem" : MessageLookupByLibrary.simpleMessage("Отданные книги"),
    "myLendedBooksTitle" : MessageLookupByLibrary.simpleMessage("ОТДАННЫЕ КНИГИ"),
    "myOutboxTitle" : MessageLookupByLibrary.simpleMessage("МОЯ ОТГРУЗКА"),
    "myWishlistItem" : MessageLookupByLibrary.simpleMessage("Хочу почитать"),
    "myWishlistTitle" : MessageLookupByLibrary.simpleMessage("ХОЧУ ПОЧИТАТЬ"),
    "mybooksTitle" : MessageLookupByLibrary.simpleMessage("МОИ КНИГИ"),
    "negativeAmount" : MessageLookupByLibrary.simpleMessage("Сумма должна быть больше нуля"),
    "no" : MessageLookupByLibrary.simpleMessage("Нет"),
    "noBooks" : MessageLookupByLibrary.simpleMessage("У Вас ни одной книги в Библосфере. Добавьте их вручную или загрузите из Goodreads."),
    "noBookshelves" : MessageLookupByLibrary.simpleMessage("У Вас ни одной книжной полки в Библосфере. Сделайте фото вашей полки, чтобы на ваши книги могли посмотреть."),
    "noBorrowedBooks" : MessageLookupByLibrary.simpleMessage("У вас нет взятых книг"),
    "noItemsInCart" : MessageLookupByLibrary.simpleMessage("Ваша корзина пуста. Добавьте книги из списка доступных книг или избранного."),
    "noItemsInOutbox" : MessageLookupByLibrary.simpleMessage("Ваша отгрузка пуста. Подождите пока кто-нибудь запросит ваши книги или предложите вашу книгу во вкладке \"Поделись\"."),
    "noLendedBooks" : MessageLookupByLibrary.simpleMessage("У вас нет отданных книг"),
    "noMatchForBooks" : MessageLookupByLibrary.simpleMessage("Здесь Вы увидите людей, кто хочет почитать Ваши книги, как только они появятся. Чтобы это произошло, добавьте больше книг и расскажите о Библосфере друзьям."),
    "noMatchForWishlist" : MessageLookupByLibrary.simpleMessage("К сожалению, пока никто не добавил книг, которые Вы хотите прочитать. Вы их увидите здесь, как только их добавят.\nРасскажите о Библосфере, чтобы это произошло быстрее. И добавьте больше книг в ваш список для прочтения."),
    "noMessages" : MessageLookupByLibrary.simpleMessage("Нет сообщений"),
    "noOperations" : MessageLookupByLibrary.simpleMessage("Нет операций"),
    "noReferrals" : MessageLookupByLibrary.simpleMessage("Нет реферралов"),
    "noWishes" : MessageLookupByLibrary.simpleMessage("У Вас ни одной книги в списке для прочтения. Добавьте их вручную или загрузите из Goodreads."),
    "notBooks" : MessageLookupByLibrary.simpleMessage("Опа, это не похоже на книги."),
    "notSufficientForAgreement" : m20,
    "nothingToSend" : MessageLookupByLibrary.simpleMessage("Нечего отправить"),
    "ok" : MessageLookupByLibrary.simpleMessage("Ок"),
    "opInAppPurchase" : MessageLookupByLibrary.simpleMessage("Пополнение счёта в приложении"),
    "opInStellar" : MessageLookupByLibrary.simpleMessage("Пополнение счёта через Stellar"),
    "opLeasing" : MessageLookupByLibrary.simpleMessage("Оплата/залог за книгу"),
    "opOutStellar" : MessageLookupByLibrary.simpleMessage("Вывод средств через Stellar"),
    "opReferral" : MessageLookupByLibrary.simpleMessage("Партнёрский доход"),
    "opReward" : MessageLookupByLibrary.simpleMessage("Вознаграждение за книгу"),
    "outbox" : MessageLookupByLibrary.simpleMessage("Книги, которые вы отдаёте"),
    "outboxOfferAccepted" : m21,
    "outboxOfferConfirmed" : m22,
    "outboxOfferRejected" : m23,
    "outboxRequestAcceptReject" : m24,
    "outboxRequestAccepted" : m25,
    "outboxRequestCanceled" : m26,
    "outboxRequestConfirmed" : m27,
    "outboxReturnAccepted" : m28,
    "outboxReturnConfirmed" : m29,
    "outputStellarAccount" : MessageLookupByLibrary.simpleMessage("Счёт Stellar для выплат:"),
    "outputStellarMemo" : MessageLookupByLibrary.simpleMessage("Memo для вывода Stellar:"),
    "paymentError" : MessageLookupByLibrary.simpleMessage("Что-то пошло не так, напишите администратору"),
    "people" : MessageLookupByLibrary.simpleMessage("Люди"),
    "profileUserBooks" : m30,
    "read" : MessageLookupByLibrary.simpleMessage("Читать"),
    "receiveBooks" : m31,
    "recentWishes" : MessageLookupByLibrary.simpleMessage("Хочет почитать:"),
    "referralLink" : MessageLookupByLibrary.simpleMessage("Ваша партнёрская ссылка:"),
    "referralTitle" : MessageLookupByLibrary.simpleMessage("МОИ РЕФЕРАЛЫ"),
    "reportShelf" : MessageLookupByLibrary.simpleMessage("Сообщить о незаконном содержимом"),
    "reportedPhoto" : MessageLookupByLibrary.simpleMessage("Это фото отмечено как запрещённое."),
    "requestBook" : m32,
    "requestPost" : m33,
    "requestReturn" : m34,
    "requestReturnByOwner" : m35,
    "scanISBN" : MessageLookupByLibrary.simpleMessage("Сканировать ISBN"),
    "seeLocation" : MessageLookupByLibrary.simpleMessage("Перейти в карты"),
    "selectDisplayCurrency" : MessageLookupByLibrary.simpleMessage("Выберите валюту отображения:"),
    "sendBooks" : m36,
    "settings" : MessageLookupByLibrary.simpleMessage("Настройки"),
    "share" : MessageLookupByLibrary.simpleMessage("Поделись"),
    "shareBooks" : MessageLookupByLibrary.simpleMessage("Я делюсь книгами через Библосферу. Присоединяйся!"),
    "shareBookshelf" : MessageLookupByLibrary.simpleMessage("Эта моя книжная полка. Заходи в Библосферу, чтобы делиться книгами и знакомиться с читающими людьми."),
    "shareShelf" : MessageLookupByLibrary.simpleMessage("Поделиться фотографией полки"),
    "shareWishlist" : MessageLookupByLibrary.simpleMessage("Я публикую в Библосфере список книг, которые хочу почитать. А ты?"),
    "sharedFeeLine" : m37,
    "sharingMotto" : MessageLookupByLibrary.simpleMessage("Бери книги у людей вместо покупки в магазинах"),
    "shelfAdded" : MessageLookupByLibrary.simpleMessage("Новая книжная полка добавлена"),
    "shelfCount" : m38,
    "shelfDeleted" : MessageLookupByLibrary.simpleMessage("Книжная полка была удалена"),
    "shelfSettings" : MessageLookupByLibrary.simpleMessage("Настройки книжной полки"),
    "shelves" : MessageLookupByLibrary.simpleMessage("Полки"),
    "showDeposit" : m39,
    "showRent" : m40,
    "snackBookAddedToCart" : MessageLookupByLibrary.simpleMessage("Книга добавлена в корзину"),
    "snackBookAlreadyInTransit" : MessageLookupByLibrary.simpleMessage("Книга передаётся другому пользователю. Выберите другую книгу."),
    "snackBookImageChanged" : MessageLookupByLibrary.simpleMessage("Новая обложка книги установлена."),
    "snackBookNotConfirmed" : MessageLookupByLibrary.simpleMessage("Вы не подтвердили получение книг и не можете взять другую книгу"),
    "snackBookNotFound" : MessageLookupByLibrary.simpleMessage("Книга не найдена. Добавьте книги в корзину вручную."),
    "snackBookPending" : MessageLookupByLibrary.simpleMessage("Прошлая передача книг не завершена и вы не можете добавлять книги"),
    "snackBookPriceChanged" : MessageLookupByLibrary.simpleMessage("Цена книги установлена."),
    "stellarOutput" : MessageLookupByLibrary.simpleMessage("Вывод средств на Stellar счёт:"),
    "successfulPayment" : MessageLookupByLibrary.simpleMessage("Платёж успешно прошёл"),
    "supportChat" : MessageLookupByLibrary.simpleMessage("Чат с поддержкой"),
    "supportChatbot" : MessageLookupByLibrary.simpleMessage("Во вкладке Сообщения есть чат с ботом Библосферы, он может ответить на любые вопросы о приложении. Если понадобится связаться напрямую со мной, пишите в telegram "),
    "supportGetBalance" : MessageLookupByLibrary.simpleMessage("Пополнить счёт можно двумя способами: через покупку в приложении по карточке, зарегистрированной в Google Play или App Store. Или сделать перевод криптовалюты Stellar (XLM) на счёт, указанный в настройках."),
    "supportGetBooks" : MessageLookupByLibrary.simpleMessage("Найдите книгу, которую Вы хотите почитать, и напишите её хозяину, чтобы договориться о встрече. При получении книг вам нужно будет оплатить депозит. Депозит возвращается, когда вы вернёте книги. Вы можете пополнить свой баланс по карточке или криптовалютой Stellar, а можете заработать в Библосфере, давая свои книги почитать. Вы также можете зарабатывать через партнёрскую программу, приглашая других участников."),
    "supportPayout" : MessageLookupByLibrary.simpleMessage("Если у Вас большой баланс в Библосфере, Вы можете вывести эти средства. Вывести средства можно на свой кошелёк Stellar или через Stellar на любой кошелёк, карту или счёт. Для вывода на карту или кошелёк воспользуйстесь услугами online-обменников."),
    "supportReferrals" : MessageLookupByLibrary.simpleMessage("Организуйте обмен книгами через Библосферу в своём сообществе или офисе и получайте комиссию за каждую сделку. Для этого поделитесь с друзьями и коллегами ссылкой на приложение (Вашей партнёрской ссылкой)."),
    "supportSignature" : MessageLookupByLibrary.simpleMessage("Денис Старк"),
    "supportTitle" : MessageLookupByLibrary.simpleMessage("ПОДДЕРЖКА"),
    "supportTitleChatbot" : MessageLookupByLibrary.simpleMessage("Чат-бот Библосферы"),
    "supportTitleGetBalance" : MessageLookupByLibrary.simpleMessage("Пополнение счёта"),
    "supportTitleGetBooks" : MessageLookupByLibrary.simpleMessage("Как брать книги"),
    "supportTitlePayout" : MessageLookupByLibrary.simpleMessage("Вывод средств"),
    "supportTitleReferrals" : MessageLookupByLibrary.simpleMessage("Партнёрская программа"),
    "title" : MessageLookupByLibrary.simpleMessage("БИБЛОСФЕРА"),
    "titleBookSettings" : MessageLookupByLibrary.simpleMessage("О КНИГЕ"),
    "titleGetBook" : MessageLookupByLibrary.simpleMessage("КНИГИ НЕТ"),
    "titleMessages" : MessageLookupByLibrary.simpleMessage("СООБЩЕНИЯ"),
    "titleReceiveBooks" : MessageLookupByLibrary.simpleMessage("ВЗЯТЬ КНИГИ"),
    "titleSendBooks" : MessageLookupByLibrary.simpleMessage("ОТДАЮ КНИГИ"),
    "titleSettings" : MessageLookupByLibrary.simpleMessage("НАСТРОЙКИ"),
    "titleSupport" : MessageLookupByLibrary.simpleMessage("ПОДДЕРЖКА"),
    "titleUserBooks" : MessageLookupByLibrary.simpleMessage("ОБМЕН КНИГАМИ"),
    "transitAccept" : MessageLookupByLibrary.simpleMessage("Принять"),
    "transitCancel" : MessageLookupByLibrary.simpleMessage("Отменить"),
    "transitConfirm" : MessageLookupByLibrary.simpleMessage("Подтвердить"),
    "transitInitiated" : MessageLookupByLibrary.simpleMessage("Вы запустили процесс передачи книги"),
    "transitOk" : MessageLookupByLibrary.simpleMessage("Ок"),
    "transitReject" : MessageLookupByLibrary.simpleMessage("Отклонить"),
    "typeMsg" : MessageLookupByLibrary.simpleMessage("Наберите сообщение..."),
    "useCurrentLocation" : MessageLookupByLibrary.simpleMessage("Использовать текущее местоположение для загрузки"),
    "userBalance" : m41,
    "userHave" : m42,
    "welcome" : MessageLookupByLibrary.simpleMessage("Добро пожаловать"),
    "wishAdded" : MessageLookupByLibrary.simpleMessage("Книга была добавлена в список желаемых книг"),
    "wishAlreadyThere" : MessageLookupByLibrary.simpleMessage("Эта книга уже есть в вашем списке желаний"),
    "wishCount" : m43,
    "wishDeleted" : MessageLookupByLibrary.simpleMessage("Книга была удалена из списка желаемых книг"),
    "wishToRead" : m44,
    "wished" : MessageLookupByLibrary.simpleMessage("Избранное"),
    "wrongAccount" : MessageLookupByLibrary.simpleMessage("Неверный счёт"),
    "wrongImageUrl" : MessageLookupByLibrary.simpleMessage("Неверная ссылка"),
    "youBorrowThisBook" : MessageLookupByLibrary.simpleMessage("Вы платите за эту книгу"),
    "youHaveThisBook" : MessageLookupByLibrary.simpleMessage("Книга у вас"),
    "youLentThisBook" : m45,
    "youTransitThisBook" : MessageLookupByLibrary.simpleMessage("По этой книге не завершён процесс передачи"),
    "youWishThisBook" : MessageLookupByLibrary.simpleMessage("Эту книгу вы хотите почитать"),
    "yourBiblosphere" : MessageLookupByLibrary.simpleMessage("Моя Библосфера"),
    "yourGoodreads" : MessageLookupByLibrary.simpleMessage("Ваш Goodreads"),
    "zoom" : MessageLookupByLibrary.simpleMessage("УВЕЛИЧИТЬ")
  };
}
