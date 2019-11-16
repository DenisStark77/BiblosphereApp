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

  static m5(name, title) => "Книга \'${title}\' принадлежит пользователю \'${name}\'. Нажмите кнопку \"Отгрузка\" ниже, чтобы сообщить о возврате книги.";

  static m6(name, title) => "Пользователь \'${name}\' предлагает вам книгу \'${title}\'. Пожалуйста, договоритесь о встрече и подтвердите получение книги. Или откажитесь, если вы не заинтересованы.";

  static m7(name, title) => "Пользователь \'${name}\' подтвердил ваш запрос книги \'${title}\'. Договоритесь о встрече и подтвердите получение книги при получении.";

  static m8(name, title) => "Дождитесь пока пользователь \'${name}\' подтвердит ваш запрос книги \'${title}\'. Спишитесь, чтобы договориться.";

  static m9(name, title) => "Пользователь \'${name}\' отклонил ваш запрос книги \'${title}\'. Вы можете написать ему, чтобы уточнить причину.";

  static m10(name, title) => "Пользователь \'${name}\' хочет вернуть вашу книгу \'${title}\'. Пожалуйста, договоритесь о встрече.";

  static m11(distance) => "Расстояние: ${distance} км";

  static m12(balance) => "МОЙ БАЛАНС: ${balance}";

  static m13(amount) => "Введите сумму не более ${amount}";

  static m14(total, month) => "Депозит за книги: ${total}, оплата за месяц ${month}";

  static m15(name, title) => "Ваша книга \'${title}\' сейчас у пользователя \'${name}\'. Спишитесь, чтобы напомнить о возвращении книги.";

  static m16(missing, total, month) => "Вам нехватает ${missing}. Депозит за книги: ${total}, оплата за месяц ${month}";

  static m17(name, title) => "Вы предложили книгу \'${title}\' пользователю \'${name}\'. Спишитесь, чтобы договориться о передаче книги.";

  static m18(name, title) => "Пользователь \'${name}\' подтвердил получение книги \'${title}\'. Книга добавлена в ваши \"Отданные книги\".";

  static m19(name, title) => "Пользователь \'${name}\' отказался от предложенной вами книги \'${title}\'. Вы можете списаться, чтобы уточнить причину.";

  static m20(name, title) => "Пользователь \'${name}\' запросил вашу книгу \'${title}\'. Пожалуйста, подтвердите или откажите. Спишитесь, чтобы познакомиться и договориться.";

  static m21(name, title) => "Передайте книгу \'${title}\' пользователю \'${name}\'. Спишитесь, чтобы договориться.";

  static m22(name, title) => "Пользователь \'${name}\' отменил запрос на вашу книгу \'${title}\'.";

  static m23(name, title) => "Пользователь \'${name}\' подтвердил получение книги \'${title}\'. Книга добавлена в ваши \"Взятые книги\".";

  static m24(name, title) => "Передайте книгу \'${title}\' пользователю \'${name}\'. Спишитесь, чтобы договориться.";

  static m25(name, title) => "Пользователь \'${name}\' подтвердил получение книги \'${title}\'.";

  static m26(num) => "Взять книги (${num})";

  static m27(book) => "Можно взять у вас \"${book}\"?";

  static m28(book) => "Можете прислать мне \"${book}\"?";

  static m29(book) => "Хочу вернуть вам \"${book}\"?";

  static m30(book) => "Пожалуйста, верните книгу \"${book}\"?";

  static m31(num) => "Отдаю книги (${num})";

  static m32(amount) => "Общий доход: +${amount}";

  static m33(count) => "${Intl.plural(count, zero: 'Нет полок', one: '${count} полка', other: '${count} полок')}";

  static m34(balance) => "Баланс: ${balance}";

  static m35(user) => "У ${user}";

  static m36(count) => "${Intl.plural(count, zero: 'Нет желанных книг', one: '${count} желанная книга', other: '${count} желанных книг')}";

  static m37(name, title) => "${name} хочет почитать Вашу книгу \'${title}\'";

  static m38(user) => "Книга у ${user}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "accountCopied" : MessageLookupByLibrary.simpleMessage("Счёт скопирован в буфер обмена"),
    "add" : MessageLookupByLibrary.simpleMessage("Добавить"),
    "addBook" : MessageLookupByLibrary.simpleMessage("Добавить книгу"),
    "addShelf" : MessageLookupByLibrary.simpleMessage("Добавить книжную полку"),
    "addToCart" : MessageLookupByLibrary.simpleMessage("Добавить в корзину"),
    "addToOutbox" : MessageLookupByLibrary.simpleMessage("Добавить в отгрузку"),
    "addToWishlist" : MessageLookupByLibrary.simpleMessage("Добавить желаемую книгу"),
    "addYourBook" : MessageLookupByLibrary.simpleMessage("Добавить свою книгу"),
    "addYourBookshelf" : MessageLookupByLibrary.simpleMessage("Добавьте вашу полку"),
    "addbookTitle" : MessageLookupByLibrary.simpleMessage("ДОБАВЬ КНИГУ"),
    "blockUser" : MessageLookupByLibrary.simpleMessage("Заблокировать пользователя"),
    "blockedChat" : MessageLookupByLibrary.simpleMessage("Пользователь заблокирован"),
    "bookAdded" : MessageLookupByLibrary.simpleMessage("Книга была добавлена в ваш каталог"),
    "bookAround" : MessageLookupByLibrary.simpleMessage("Книга поблизости"),
    "bookByPost" : MessageLookupByLibrary.simpleMessage("Получи по почте"),
    "bookCount" : m0,
    "bookDeleted" : MessageLookupByLibrary.simpleMessage("Книга была удалена из вашего каталога"),
    "bookImageLabel" : MessageLookupByLibrary.simpleMessage("Ссылка на фото обложки:"),
    "bookInLibrary" : MessageLookupByLibrary.simpleMessage("Найди в библиотеке через"),
    "bookLanguage" : m1,
    "bookOwner" : m2,
    "bookPrice" : m3,
    "bookPriceHint" : MessageLookupByLibrary.simpleMessage("Введите цену книги"),
    "bookPriceLabel" : MessageLookupByLibrary.simpleMessage("Цена книги"),
    "bookRent" : m4,
    "books" : MessageLookupByLibrary.simpleMessage("Книги"),
    "bookshelves" : MessageLookupByLibrary.simpleMessage("Полки"),
    "borrow" : MessageLookupByLibrary.simpleMessage("Возьми"),
    "borrowedBookText" : m5,
    "buttonConfirmBooks" : MessageLookupByLibrary.simpleMessage("Книги получил ✓"),
    "buttonGivenBooks" : MessageLookupByLibrary.simpleMessage("Книги отдал ✓"),
    "buttonPayin" : MessageLookupByLibrary.simpleMessage("Пополнить счёт"),
    "buttonTransfer" : MessageLookupByLibrary.simpleMessage("Перевести"),
    "buyBook" : MessageLookupByLibrary.simpleMessage("Купи на"),
    "cart" : MessageLookupByLibrary.simpleMessage("Книги, которые вы берёте"),
    "cartOfferConfirmReject" : m6,
    "cartRequestAccepted" : m7,
    "cartRequestCancel" : m8,
    "cartRequestRejected" : m9,
    "cartReturnConfirm" : m10,
    "chat" : MessageLookupByLibrary.simpleMessage("ЧАТ"),
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
    "confirmBlockUser" : MessageLookupByLibrary.simpleMessage("Заблокировать пользователя?"),
    "confirmReportPhoto" : MessageLookupByLibrary.simpleMessage("Пожаловаться на фото?"),
    "deleteShelf" : MessageLookupByLibrary.simpleMessage("Удалить полку"),
    "displayCurrency" : MessageLookupByLibrary.simpleMessage("Валюта отображения:"),
    "distanceLine" : m11,
    "drawerHeader" : MessageLookupByLibrary.simpleMessage("Выбери режим"),
    "earn" : MessageLookupByLibrary.simpleMessage("Заработай"),
    "emptyAmount" : MessageLookupByLibrary.simpleMessage("Сумма не может быть пустой"),
    "enterTitle" : MessageLookupByLibrary.simpleMessage("Начните вводить автора и/или название"),
    "exceedAmount" : MessageLookupByLibrary.simpleMessage("Сумма должна быть меньше доступного остатка"),
    "explore" : MessageLookupByLibrary.simpleMessage("Исследовать"),
    "favorite" : MessageLookupByLibrary.simpleMessage("Добавить полку в избранное"),
    "financeTitle" : m12,
    "findBook" : MessageLookupByLibrary.simpleMessage("Найти книгу"),
    "findbookTitle" : MessageLookupByLibrary.simpleMessage("НАЙДИ КНИГУ"),
    "hintAuthorTitle" : MessageLookupByLibrary.simpleMessage("Автор или название"),
    "hintNotMore" : m13,
    "hintOutptAcount" : MessageLookupByLibrary.simpleMessage("Ваш Stellar счёт для вывода средств"),
    "ifNotFound" : MessageLookupByLibrary.simpleMessage("Добавьте в желаемые книги, если вы её не нашли"),
    "imageLinkHint" : MessageLookupByLibrary.simpleMessage("Скопируйте ссылку на обложку книги"),
    "importToBooks" : MessageLookupByLibrary.simpleMessage("Загрузить в список моих книг:"),
    "importToWishlist" : MessageLookupByLibrary.simpleMessage("Загрузить в список желаемых книг:"),
    "importYouBooks" : MessageLookupByLibrary.simpleMessage("Загрузи книги в Библосферу"),
    "inMyBooks" : MessageLookupByLibrary.simpleMessage("Эта книга есть у вас"),
    "inMyWishes" : MessageLookupByLibrary.simpleMessage("Эта книга в вашем списке желаний"),
    "inputStellarAcount" : MessageLookupByLibrary.simpleMessage("Счёт Stellar для пополнения:"),
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
    "leaseAgreement" : m14,
    "lentBookText" : m15,
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
    "noOperations" : MessageLookupByLibrary.simpleMessage("No operations"),
    "noReferrals" : MessageLookupByLibrary.simpleMessage("Нет реферралов"),
    "noWishes" : MessageLookupByLibrary.simpleMessage("У Вас ни одной книги в списке для прочтения. Добавьте их вручную или загрузите из Goodreads."),
    "notBooks" : MessageLookupByLibrary.simpleMessage("Опа, это не похоже на книги."),
    "notSufficientForAgreement" : m16,
    "nothingToSend" : MessageLookupByLibrary.simpleMessage("Нечего отправить"),
    "ok" : MessageLookupByLibrary.simpleMessage("Ок"),
    "opInAppPurchase" : MessageLookupByLibrary.simpleMessage("Пополнение счёта в приложении"),
    "opInStellar" : MessageLookupByLibrary.simpleMessage("Пополнение счёта через Stellar"),
    "opLeasing" : MessageLookupByLibrary.simpleMessage("Оплата/залог за книгу"),
    "opOutStellar" : MessageLookupByLibrary.simpleMessage("Вывод средств через Stellar"),
    "opReferral" : MessageLookupByLibrary.simpleMessage("Партнёрский доход"),
    "opReward" : MessageLookupByLibrary.simpleMessage("Вознаграждение за книгу"),
    "outbox" : MessageLookupByLibrary.simpleMessage("Книги, которые вы отдаёте"),
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
    "people" : MessageLookupByLibrary.simpleMessage("Люди"),
    "read" : MessageLookupByLibrary.simpleMessage("Читать"),
    "receiveBooks" : m26,
    "recentWishes" : MessageLookupByLibrary.simpleMessage("Хочет почитать:"),
    "referralLink" : MessageLookupByLibrary.simpleMessage("Ваша партнёрская ссылка:"),
    "referralTitle" : MessageLookupByLibrary.simpleMessage("МОИ РЕФЕРАЛЫ"),
    "reportShelf" : MessageLookupByLibrary.simpleMessage("Сообщить о незаконном содержимом"),
    "reportedPhoto" : MessageLookupByLibrary.simpleMessage("Это фото отмечено как запрещённое."),
    "requestBook" : m27,
    "requestPost" : m28,
    "requestReturn" : m29,
    "requestReturnByOwner" : m30,
    "scanISBN" : MessageLookupByLibrary.simpleMessage("Сканировать ISBN"),
    "seeLocation" : MessageLookupByLibrary.simpleMessage("Перейти в карты"),
    "selectDisplayCurrency" : MessageLookupByLibrary.simpleMessage("Выберите валюту отображения:"),
    "sendBooks" : m31,
    "settings" : MessageLookupByLibrary.simpleMessage("Настройки"),
    "share" : MessageLookupByLibrary.simpleMessage("Поделись"),
    "shareBooks" : MessageLookupByLibrary.simpleMessage("Я делюсь книгами через Библосферу. Присоединяйся!"),
    "shareBookshelf" : MessageLookupByLibrary.simpleMessage("Эта моя книжная полка. Заходи в Библосферу, чтобы делиться книгами и знакомиться с читающими людьми."),
    "shareShelf" : MessageLookupByLibrary.simpleMessage("Поделиться фотографией полки"),
    "shareWishlist" : MessageLookupByLibrary.simpleMessage("Я публикую в Библосфере список книг, которые хочу почитать. А ты?"),
    "sharedFeeLine" : m32,
    "shelfAdded" : MessageLookupByLibrary.simpleMessage("Новая книжная полка добавлена"),
    "shelfCount" : m33,
    "shelfDeleted" : MessageLookupByLibrary.simpleMessage("Книжная полка была удалена"),
    "shelfSettings" : MessageLookupByLibrary.simpleMessage("Настройки книжной полки"),
    "shelves" : MessageLookupByLibrary.simpleMessage("Полки"),
    "stellarOutput" : MessageLookupByLibrary.simpleMessage("Вывод средств на Stellar счёт:"),
    "successfulPayment" : MessageLookupByLibrary.simpleMessage("Платёж успешно прошёл"),
    "supportTitle" : MessageLookupByLibrary.simpleMessage("ПОДДЕРЖКА"),
    "title" : MessageLookupByLibrary.simpleMessage("БИБЛОСФЕРА"),
    "titleBookSettings" : MessageLookupByLibrary.simpleMessage("О КНИГЕ"),
    "titleGetBook" : MessageLookupByLibrary.simpleMessage("ПОЛУЧИ КНИГУ"),
    "titleMessages" : MessageLookupByLibrary.simpleMessage("СООБЩЕНИЯ"),
    "titleReceiveBooks" : MessageLookupByLibrary.simpleMessage("ВЗЯТЬ КНИГИ"),
    "titleSendBooks" : MessageLookupByLibrary.simpleMessage("ОТДАЮ КНИГИ"),
    "titleSettings" : MessageLookupByLibrary.simpleMessage("НАСТРОЙКИ"),
    "titleUserBooks" : MessageLookupByLibrary.simpleMessage("ОБМЕН КНИГАМИ"),
    "transitAccept" : MessageLookupByLibrary.simpleMessage("Принять"),
    "transitCancel" : MessageLookupByLibrary.simpleMessage("Отменить"),
    "transitConfirm" : MessageLookupByLibrary.simpleMessage("Подтвердить"),
    "transitInitiated" : MessageLookupByLibrary.simpleMessage("Вы запустили процесс передачи книги"),
    "transitOk" : MessageLookupByLibrary.simpleMessage("Ок"),
    "transitReject" : MessageLookupByLibrary.simpleMessage("Отклонить"),
    "typeMsg" : MessageLookupByLibrary.simpleMessage("Наберите сообщение..."),
    "useCurrentLocation" : MessageLookupByLibrary.simpleMessage("Использовать текущее местоположение для загрузки"),
    "userBalance" : m34,
    "userHave" : m35,
    "welcome" : MessageLookupByLibrary.simpleMessage("Добро пожаловать"),
    "wishAdded" : MessageLookupByLibrary.simpleMessage("Книга была добавлена в список желаемых книг"),
    "wishCount" : m36,
    "wishDeleted" : MessageLookupByLibrary.simpleMessage("Книга была удалена из списка желаемых книг"),
    "wishToRead" : m37,
    "wished" : MessageLookupByLibrary.simpleMessage("Избранное"),
    "wrongAccount" : MessageLookupByLibrary.simpleMessage("Неверный счёт"),
    "wrongImageUrl" : MessageLookupByLibrary.simpleMessage("Неверная ссылка"),
    "youBorrowThisBook" : MessageLookupByLibrary.simpleMessage("Вы платите за эту книгу"),
    "youHaveThisBook" : MessageLookupByLibrary.simpleMessage("Эта книга находится у вас"),
    "youLentThisBook" : m38,
    "youTransitThisBook" : MessageLookupByLibrary.simpleMessage("По этой книге не завершён процесс передачи"),
    "youWishThisBook" : MessageLookupByLibrary.simpleMessage("Эту книгу вы хотите почитать"),
    "yourBiblosphere" : MessageLookupByLibrary.simpleMessage("Моя Библосфера"),
    "yourGoodreads" : MessageLookupByLibrary.simpleMessage("Ваш Goodreads"),
    "zoom" : MessageLookupByLibrary.simpleMessage("УВЕЛИЧИТЬ")
  };
}
