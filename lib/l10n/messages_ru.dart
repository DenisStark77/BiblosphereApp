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

  static m0(month) => "Доход: ${month} в месяц";

  static m1(lang) => "Язык: ${lang}";

  static m2(user) => "Владелец: ${user}";

  static m3(total) => "Цена: ${total}";

  static m4(month) => "Цена: ${month} в месяц";

  static m5(user) => "Книга у ${user}";

  static m6(count) => "Книги этого пользователя у меня (${count})";

  static m7(amount) => "Пополните баланс на ${amount}";

  static m8(price) => "Пробная подписка допускает не более 2 книг на руках. Оплачивайте ${price} в месяц чтобы снять ограничение.";

  static m9(price) => "Пробная подписка допускает не более 10 книг в списке к прочтению. Оплачивайте ${price} в месяц чтобы снять ограничение.";

  static m10(distance) => "Расстояние: ${distance} км";

  static m11(balance) => "МОЙ БАЛАНС: ${balance}";

  static m12(amount) => "Введите сумму не более ${amount}";

  static m13(total, month) => "Депозит за книги: ${total}, оплата за месяц ${month}";

  static m14(count) => "Мои книги у этого пользователя (${count})";

  static m15(missing, total, month) => "Вам нехватает ${missing}. Депозит за книги: ${total}, оплата за месяц ${month}";

  static m16(book) => "Рекомендую взять у меня \"${book}\"";

  static m17(count) => "Книги пользователя (${count})";

  static m18(num) => "Взять книги (${num})";

  static m19(book) => "Можно взять у вас \"${book}\"?";

  static m20(book) => "Можете прислать мне \"${book}\"?";

  static m21(book) => "Хочу вернуть вам \"${book}\"?";

  static m22(book) => "Пожалуйста, верните книгу \"${book}\"?";

  static m23(num) => "Отдаю книги (${num})";

  static m24(name) => "Текущая подписка: ${name}";

  static m25(amount) => "Общий доход: +${amount}";

  static m26(amount) => "Залог: ${amount}";

  static m27(amount) => "Оплата в месяц: ${amount}";

  static m28(count) => "${count} книг было распознано и дабавлено в ваш каталог.";

  static m29(balance) => "Баланс: ${balance}";

  static m30(user) => "У ${user}";

  static m31(user) => "Книга у ${user}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "accountCopied" : MessageLookupByLibrary.simpleMessage("Счёт скопирован в буфер обмена"),
    "add" : MessageLookupByLibrary.simpleMessage("Добавить"),
    "addBook" : MessageLookupByLibrary.simpleMessage("Добавить книгу"),
    "addToWishlist" : MessageLookupByLibrary.simpleMessage("Добавить в желаемые книги"),
    "addbookTitle" : MessageLookupByLibrary.simpleMessage("ДОБАВЬ КНИГУ"),
    "blockUser" : MessageLookupByLibrary.simpleMessage("Заблокировать пользователя"),
    "blockedChat" : MessageLookupByLibrary.simpleMessage("Пользователь заблокирован"),
    "bookAdded" : MessageLookupByLibrary.simpleMessage("Книга была добавлена в ваш каталог"),
    "bookAlreadyThere" : MessageLookupByLibrary.simpleMessage("Эта книга уже есть у вас в каталоге"),
    "bookAround" : MessageLookupByLibrary.simpleMessage("Книга поблизости"),
    "bookByPost" : MessageLookupByLibrary.simpleMessage("Получи по почте"),
    "bookDeleted" : MessageLookupByLibrary.simpleMessage("Книга была удалена из вашего каталога"),
    "bookImageLabel" : MessageLookupByLibrary.simpleMessage("Ссылка на фото обложки:"),
    "bookInLibrary" : MessageLookupByLibrary.simpleMessage("Найди в библиотеке через"),
    "bookIncome" : m0,
    "bookLanguage" : m1,
    "bookNotFound" : MessageLookupByLibrary.simpleMessage("Эта книга не найдена в Библосфере. Добавьте её в желаемые книги и мы сообщим вам, когда она появится рядом с вами."),
    "bookOwner" : m2,
    "bookPrice" : m3,
    "bookPriceHint" : MessageLookupByLibrary.simpleMessage("Введите цену книги"),
    "bookPriceLabel" : MessageLookupByLibrary.simpleMessage("Цена книги"),
    "bookRent" : m4,
    "bookWith" : m5,
    "booksOfUserWithMe" : m6,
    "buttonConfirmBooks" : MessageLookupByLibrary.simpleMessage("Книги получил ✓"),
    "buttonGivenBooks" : MessageLookupByLibrary.simpleMessage("Книги отдал ✓"),
    "buttonManageBook" : MessageLookupByLibrary.simpleMessage("Открыть в МОИ КНИГИ"),
    "buttonPayin" : MessageLookupByLibrary.simpleMessage("Пополнить счёт"),
    "buttonSearchThirdParty" : MessageLookupByLibrary.simpleMessage("Найти в магазинах и библиотеках"),
    "buttonSkip" : MessageLookupByLibrary.simpleMessage("ОТМЕНИТЬ"),
    "buttonTransfer" : MessageLookupByLibrary.simpleMessage("Перевести"),
    "buttonUpgrade" : MessageLookupByLibrary.simpleMessage("ОПЛАТИТЬ"),
    "buyBook" : MessageLookupByLibrary.simpleMessage("Купи на"),
    "cart" : MessageLookupByLibrary.simpleMessage("Книги, которые вы берёте"),
    "cartAddBooks" : MessageLookupByLibrary.simpleMessage("Добавьте книги"),
    "cartBooksAccepted" : MessageLookupByLibrary.simpleMessage("Книги успешно получены"),
    "cartBooksGiven" : MessageLookupByLibrary.simpleMessage("Книги успешно переданы"),
    "cartConfirmHandover" : MessageLookupByLibrary.simpleMessage("Подтвердите, что отдали книги"),
    "cartConfirmReceived" : MessageLookupByLibrary.simpleMessage("Подтвердите получение книг"),
    "cartMakeApointment" : MessageLookupByLibrary.simpleMessage("Договоритесь о встрече"),
    "cartRequesterHasToConfirm" : MessageLookupByLibrary.simpleMessage("Получатель должен подтвердить получение книг"),
    "cartRequesterHasToTopup" : MessageLookupByLibrary.simpleMessage("Получатель книг должен пополнить баланс"),
    "cartTopup" : m7,
    "chatStatusCompleteFrom" : MessageLookupByLibrary.simpleMessage("Книги переданы"),
    "chatStatusCompleteTo" : MessageLookupByLibrary.simpleMessage("Книги получены"),
    "chatStatusHandoverFrom" : MessageLookupByLibrary.simpleMessage("Завершите передачу книг"),
    "chatStatusHandoverTo" : MessageLookupByLibrary.simpleMessage("Подтвердите получение книг"),
    "chatStatusInitialFrom" : MessageLookupByLibrary.simpleMessage("Отдайте книги"),
    "chatStatusInitialTo" : MessageLookupByLibrary.simpleMessage("Получите книги"),
    "chatbotWelcome" : MessageLookupByLibrary.simpleMessage("Привет! Я чатбот Библосферы, задавай мне любые вопросы про приложение."),
    "chipBooksToAskForReturn" : MessageLookupByLibrary.simpleMessage("Забрать"),
    "chipBooksToOffer" : MessageLookupByLibrary.simpleMessage("Предложить"),
    "chipBooksToRequest" : MessageLookupByLibrary.simpleMessage("Взять"),
    "chipBooksToReturn" : MessageLookupByLibrary.simpleMessage("Вернуть"),
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
    "chooseHoldedBookForChat" : MessageLookupByLibrary.simpleMessage("ВЫБЕРИТЕ КНИГУ"),
    "choosePartnerBookForChat" : MessageLookupByLibrary.simpleMessage("ВЫБЕРИТЕ КНИГУ"),
    "confirmBlockUser" : MessageLookupByLibrary.simpleMessage("Заблокировать пользователя?"),
    "dialogBookLimit" : m8,
    "dialogWishLimit" : m9,
    "displayCurrency" : MessageLookupByLibrary.simpleMessage("Валюта отображения:"),
    "distanceLine" : m10,
    "distanceUnknown" : MessageLookupByLibrary.simpleMessage("Расстояние: неизвестно"),
    "emptyAmount" : MessageLookupByLibrary.simpleMessage("Сумма не может быть пустой"),
    "enterTitle" : MessageLookupByLibrary.simpleMessage("Начните вводить автора и/или название"),
    "exceedAmount" : MessageLookupByLibrary.simpleMessage("Сумма должна быть меньше доступного остатка"),
    "financeTitle" : m11,
    "findBook" : MessageLookupByLibrary.simpleMessage("Найти книгу"),
    "findbookTitle" : MessageLookupByLibrary.simpleMessage("НАЙДИ КНИГУ"),
    "hintAddToWishlist" : MessageLookupByLibrary.simpleMessage("Добавить в список к прочтению"),
    "hintAuthorTitle" : MessageLookupByLibrary.simpleMessage("Автор или название"),
    "hintBookDetails" : MessageLookupByLibrary.simpleMessage("Изменить информацию о книге"),
    "hintChatOpen" : MessageLookupByLibrary.simpleMessage("Перейти в чат"),
    "hintConfirmHandover" : MessageLookupByLibrary.simpleMessage("Подтвердить, что Вы получили книгу"),
    "hintDeleteBook" : MessageLookupByLibrary.simpleMessage("Удалить книгу"),
    "hintHolderChatOpen" : MessageLookupByLibrary.simpleMessage("Открыть чат с держателем книги"),
    "hintManageBook" : MessageLookupByLibrary.simpleMessage("Показать эту книгу в экране МОИ КНИГИ"),
    "hintNotMore" : m12,
    "hintOutptAcount" : MessageLookupByLibrary.simpleMessage("Ваш Stellar счёт для вывода средств"),
    "hintOutputMemo" : MessageLookupByLibrary.simpleMessage("Memo для вывода средств через Stellar"),
    "hintRequestReturn" : MessageLookupByLibrary.simpleMessage("Попросить вернуть книгу"),
    "hintReturn" : MessageLookupByLibrary.simpleMessage("Вернуть книгу"),
    "hintShareBook" : MessageLookupByLibrary.simpleMessage("Поделиться ссылкой"),
    "ifNotFound" : MessageLookupByLibrary.simpleMessage("Добавьте в желаемые книги, если вы её не нашли"),
    "imageLinkHint" : MessageLookupByLibrary.simpleMessage("Скопируйте ссылку на обложку книги"),
    "inMyBooks" : MessageLookupByLibrary.simpleMessage("Эта книга есть у вас"),
    "inMyWishes" : MessageLookupByLibrary.simpleMessage("Эта книга в вашем списке желаний"),
    "inputStellarAcount" : MessageLookupByLibrary.simpleMessage("Счёт Stellar для пополнения:"),
    "inputStellarMemo" : MessageLookupByLibrary.simpleMessage("Memo для пополнения через Stellar:"),
    "introDone" : MessageLookupByLibrary.simpleMessage("НАЧАТЬ"),
    "introMeet" : MessageLookupByLibrary.simpleMessage("Встречайся"),
    "introMeetHint" : MessageLookupByLibrary.simpleMessage("Свяжись с владельцем понравившейся книги и договорись о встрече, чтобы взять книгу почитать."),
    "introShoot" : MessageLookupByLibrary.simpleMessage("Добавляй книги"),
    "introShootHint" : MessageLookupByLibrary.simpleMessage("Добавь и покажи свои книги друзьям и соседям. Твои книги привлекут единомышленников."),
    "introSkip" : MessageLookupByLibrary.simpleMessage("ПРОПУСТИТЬ"),
    "introSurf" : MessageLookupByLibrary.simpleMessage("Исследуй"),
    "introSurfHint" : MessageLookupByLibrary.simpleMessage("Приложение показвыает книжные полки в радиусе 200 км. Получи доступ к книгам соседей."),
    "isbnNotFound" : MessageLookupByLibrary.simpleMessage("Книга не найдена по ISBN"),
    "km" : MessageLookupByLibrary.simpleMessage(" км"),
    "leaseAgreement" : m13,
    "linkCopied" : MessageLookupByLibrary.simpleMessage("Ссылка скопирована в буфер обмена"),
    "loading" : MessageLookupByLibrary.simpleMessage("Загружается..."),
    "loginAgree1" : MessageLookupByLibrary.simpleMessage("Заходя в приложение вы соглашаетесь\n с нашим "),
    "loginAgree2" : MessageLookupByLibrary.simpleMessage("пользовательским соглашением"),
    "loginAgree3" : MessageLookupByLibrary.simpleMessage("\nи подтверждаете согласие с "),
    "loginAgree4" : MessageLookupByLibrary.simpleMessage("политикой конфиденциальности"),
    "logout" : MessageLookupByLibrary.simpleMessage("Выйти"),
    "memoCopied" : MessageLookupByLibrary.simpleMessage("Memo скопировано в буфер обмена"),
    "menuBalance" : MessageLookupByLibrary.simpleMessage("Баланс"),
    "menuMessages" : MessageLookupByLibrary.simpleMessage("Сообщения"),
    "menuReferral" : MessageLookupByLibrary.simpleMessage("Реферальная программа"),
    "menuSettings" : MessageLookupByLibrary.simpleMessage("Настройки"),
    "menuSupport" : MessageLookupByLibrary.simpleMessage("Поддержка"),
    "myBooks" : MessageLookupByLibrary.simpleMessage("Мои книги"),
    "myBooksWithUser" : m14,
    "mybooksTitle" : MessageLookupByLibrary.simpleMessage("МОИ КНИГИ"),
    "negativeAmount" : MessageLookupByLibrary.simpleMessage("Сумма должна быть больше нуля"),
    "no" : MessageLookupByLibrary.simpleMessage("Нет"),
    "noMessages" : MessageLookupByLibrary.simpleMessage("Нет сообщений"),
    "noOperations" : MessageLookupByLibrary.simpleMessage("Нет операций"),
    "noReferrals" : MessageLookupByLibrary.simpleMessage("Нет реферралов"),
    "notSufficientForAgreement" : m15,
    "nothingToSend" : MessageLookupByLibrary.simpleMessage("Нечего отправить"),
    "offerBook" : m16,
    "ok" : MessageLookupByLibrary.simpleMessage("Ок"),
    "opInAppPurchase" : MessageLookupByLibrary.simpleMessage("Пополнение счёта в приложении"),
    "opInStellar" : MessageLookupByLibrary.simpleMessage("Пополнение счёта через Stellar"),
    "opLeasing" : MessageLookupByLibrary.simpleMessage("Оплата/залог за книгу"),
    "opOutStellar" : MessageLookupByLibrary.simpleMessage("Вывод средств через Stellar"),
    "opReferral" : MessageLookupByLibrary.simpleMessage("Партнёрский доход"),
    "opReward" : MessageLookupByLibrary.simpleMessage("Вознаграждение за книгу"),
    "outputStellarAccount" : MessageLookupByLibrary.simpleMessage("Счёт Stellar для выплат:"),
    "outputStellarMemo" : MessageLookupByLibrary.simpleMessage("Memo для вывода Stellar:"),
    "paymentError" : MessageLookupByLibrary.simpleMessage("Что-то пошло не так, напишите администратору"),
    "planTrial" : MessageLookupByLibrary.simpleMessage("Пробная"),
    "profileUserBooks" : m17,
    "receiveBooks" : m18,
    "recognizeFromCamera" : MessageLookupByLibrary.simpleMessage("Сфотографировать полку"),
    "recognizeFromGallery" : MessageLookupByLibrary.simpleMessage("Распознать книги с фотографии"),
    "referralLink" : MessageLookupByLibrary.simpleMessage("Ваша партнёрская ссылка:"),
    "referralTitle" : MessageLookupByLibrary.simpleMessage("МОИ РЕФЕРАЛЫ"),
    "requestBook" : m19,
    "requestPost" : m20,
    "requestReturn" : m21,
    "requestReturnByOwner" : m22,
    "scanISBN" : MessageLookupByLibrary.simpleMessage("Сканировать ISBN"),
    "selectDisplayCurrency" : MessageLookupByLibrary.simpleMessage("Выберите валюту отображения:"),
    "sendBooks" : m23,
    "settingsPlan" : m24,
    "settingsTitleGeneral" : MessageLookupByLibrary.simpleMessage("Общие настройки"),
    "settingsTitleIn" : MessageLookupByLibrary.simpleMessage("Пополнение баланса"),
    "settingsTitleInStellar" : MessageLookupByLibrary.simpleMessage("Пополнение через Stallar"),
    "settingsTitleOutStellar" : MessageLookupByLibrary.simpleMessage("Выплаты через Stallar"),
    "sharedFeeLine" : m25,
    "sharingMotto" : MessageLookupByLibrary.simpleMessage("Бери книги у людей вместо покупки в магазинах"),
    "showDeposit" : m26,
    "showRent" : m27,
    "snackAllowLocation" : MessageLookupByLibrary.simpleMessage("Дайте разрешение на использование текущей позиции для поиска и добавления книг"),
    "snackBookAddedToCart" : MessageLookupByLibrary.simpleMessage("Книга добавлена в корзину"),
    "snackBookImageChanged" : MessageLookupByLibrary.simpleMessage("Новая обложка книги установлена."),
    "snackBookNotConfirmed" : MessageLookupByLibrary.simpleMessage("Вы не подтвердили получение книг и не можете взять другую книгу"),
    "snackBookNotFound" : MessageLookupByLibrary.simpleMessage("Книга не найдена. Добавьте книги в корзину вручную."),
    "snackBookPending" : MessageLookupByLibrary.simpleMessage("Прошлая передача книг не завершена и вы не можете добавлять книги"),
    "snackBookPriceChanged" : MessageLookupByLibrary.simpleMessage("Цена книги установлена."),
    "snackPaidPlanActivated" : MessageLookupByLibrary.simpleMessage("Ваша платная подписка активирована"),
    "snackRecgnitionStarted" : MessageLookupByLibrary.simpleMessage("Распознавание фото займёт до 2х минут. Можете загрузить следующий снимок."),
    "snackRecognitionDone" : m28,
    "snackWishDeleted" : MessageLookupByLibrary.simpleMessage("Книга удалена из вашего списка к прочтению"),
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
    "transitInitiated" : MessageLookupByLibrary.simpleMessage("Вы запустили процесс передачи книги"),
    "typeMsg" : MessageLookupByLibrary.simpleMessage("Наберите сообщение..."),
    "userBalance" : m29,
    "userHave" : m30,
    "welcome" : MessageLookupByLibrary.simpleMessage("ДОБРО ПОЖАЛОВАТЬ"),
    "wishAdded" : MessageLookupByLibrary.simpleMessage("Книга была добавлена в список желаемых книг"),
    "wishAlreadyThere" : MessageLookupByLibrary.simpleMessage("Эта книга уже есть в вашем списке желаний"),
    "wrongAccount" : MessageLookupByLibrary.simpleMessage("Неверный счёт"),
    "wrongImageUrl" : MessageLookupByLibrary.simpleMessage("Неверная ссылка"),
    "youBorrowThisBook" : MessageLookupByLibrary.simpleMessage("Вы платите за эту книгу"),
    "youHaveThisBook" : MessageLookupByLibrary.simpleMessage("Книга у вас"),
    "youLentThisBook" : m31,
    "youTransitThisBook" : MessageLookupByLibrary.simpleMessage("По этой книге не завершён процесс передачи"),
    "youWishThisBook" : MessageLookupByLibrary.simpleMessage("Эту книгу вы хотите почитать")
  };
}
