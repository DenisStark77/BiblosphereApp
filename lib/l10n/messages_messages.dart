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

  static m0(month) => "Доход: ${month} в месяц";

  static m1(lang) => "Language: ${lang}";

  static m2(count) => "Limit on taken books: ${count}";

  static m3(count) => "You can take up to ${count} books at a time plus number of books you\'ve given to other people. To take more books return books previously taken.";

  static m4(count, upgrade) => "Limit on taken books: ${count}";

  static m5(count, upgrade) => "You can take up to ${count} books at a time plus number of books you\'ve given to other people. To keep up to ${upgrade} books upgrade to paid plan.";

  static m6(user) => "Владелец: ${user}";

  static m7(total) => "Цена: ${total}";

  static m8(month) => "Цена: ${month} в месяц";

  static m9(user) => "Книга у ${user}";

  static m10(count) => "Книги этого пользователя у меня (${count})";

  static m11(amount) => "Пополните баланс на ${amount}";

  static m12(price) => "Trial plan allows to keep only up to 2 books at a time. Upgrade for ${price} per month to have more.";

  static m13(price) => "Trial plan only allows 10 books in the wish list. Upgrade for ${price} per month to have more.";

  static m14(distance) => "Расстояние: ${distance} км";

  static m15(balance) => "МОЙ БАЛАНС: ${balance}";

  static m16(amount) => "Введите сумму не более ${amount}";

  static m17(total, month) => "Депозит за книги: ${total}, оплата за месяц ${month}";

  static m18(count) => "Мои книги у этого пользователя (${count})";

  static m19(missing, total, month) => "Вам нехватает ${missing}. Депозит за книги: ${total}, оплата за месяц ${month}";

  static m20(book) => "Рекомендую взять у меня \"${book}\"";

  static m21(count) => "Книги пользователя (${count})";

  static m22(num) => "Взять книги (${num})";

  static m23(total, recognized) => "${recognized} books out of ${total} were recognized";

  static m24(book) => "Можно взять у вас \"${book}\"?";

  static m25(book) => "Можете прислать мне \"${book}\"?";

  static m26(book) => "Хочу вернуть вам \"${book}\"?";

  static m27(book) => "Пожалуйста, верните книгу \"${book}\"?";

  static m28(num) => "Отдаю книги (${num})";

  static m29(name) => "Plan: ${name}";

  static m30(amount) => "Общий доход: +${amount}";

  static m31(amount) => "Залог: ${amount}";

  static m32(amount) => "Оплата в месяц: ${amount}";

  static m33(count) => "${count} books have been recognized and added to your catalog.";

  static m34(platform) => "Subscription will be charged to your ${platform} account on confirmation. Subscriptions will automatically renew unless canceled within 24-hours before the end of the current period. You can cancel anytime with your ${platform} account settings. Any unused portion of a free trial will be forfeited if you purchase a subscription.";

  static m35(balance) => "Balance: ${balance}";

  static m36(user) => "У пользователя ${user}";

  static m37(count) => "Limit on wish list: ${count}";

  static m38(count) => "You can keep up to ${count} books in your wish list.";

  static m39(count, upgrade) => "Limit on wish list: ${count}";

  static m40(count, upgrade) => "You can keep up to ${count} books in your wish list. Upgrade to paid plan to increase to ${upgrade}.";

  static m41(user) => "Книга у ${user}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "accountCopied" : MessageLookupByLibrary.simpleMessage("Счёт скопирован в буфер обмена"),
    "add" : MessageLookupByLibrary.simpleMessage("Add"),
    "addBook" : MessageLookupByLibrary.simpleMessage("Добавить книгу"),
    "addToWishlist" : MessageLookupByLibrary.simpleMessage("Add to Wishlist"),
    "addbookTitle" : MessageLookupByLibrary.simpleMessage("ДОБАВЬ КНИГУ"),
    "annualDescription" : MessageLookupByLibrary.simpleMessage("Enjoy book sharing with your friends and neighbours for a whole year"),
    "blockUser" : MessageLookupByLibrary.simpleMessage("Block abusive user"),
    "blockedChat" : MessageLookupByLibrary.simpleMessage("Blocked"),
    "bookAdded" : MessageLookupByLibrary.simpleMessage("Book has been added to your library"),
    "bookAlreadyThere" : MessageLookupByLibrary.simpleMessage("Эта книга уже есть у вас в каталоге"),
    "bookAround" : MessageLookupByLibrary.simpleMessage("Книга поблизости"),
    "bookByPost" : MessageLookupByLibrary.simpleMessage("Получи по почте"),
    "bookDeleted" : MessageLookupByLibrary.simpleMessage("Book has been deleted from your library"),
    "bookImageLabel" : MessageLookupByLibrary.simpleMessage("Ссылка на фото обложки:"),
    "bookInLibrary" : MessageLookupByLibrary.simpleMessage("Найди в библиотеке через"),
    "bookIncome" : m0,
    "bookLanguage" : m1,
    "bookLimitPaid" : m2,
    "bookLimitPaidDesc" : m3,
    "bookLimitTrial" : m4,
    "bookLimitTrialDesc" : m5,
    "bookNotFound" : MessageLookupByLibrary.simpleMessage("Эта книга не найдена в Библосфере. Добавьте её в желаемые книги и мы сообщим вам, когда она появится рядом с вами."),
    "bookOwner" : m6,
    "bookPrice" : m7,
    "bookPriceHint" : MessageLookupByLibrary.simpleMessage("Введите цену книги"),
    "bookPriceLabel" : MessageLookupByLibrary.simpleMessage("Цена книги"),
    "bookRent" : m8,
    "bookWith" : m9,
    "booksOfUserWithMe" : m10,
    "buttonConfirmBooks" : MessageLookupByLibrary.simpleMessage("Нажмите при получении"),
    "buttonGivenBooks" : MessageLookupByLibrary.simpleMessage("Книги отдал ✓"),
    "buttonManageBook" : MessageLookupByLibrary.simpleMessage("Open in MY BOOKS"),
    "buttonPayin" : MessageLookupByLibrary.simpleMessage("Пополнить счёт"),
    "buttonSearchThirdParty" : MessageLookupByLibrary.simpleMessage("Search in Stores & Libraries"),
    "buttonSkip" : MessageLookupByLibrary.simpleMessage("SKIP"),
    "buttonTransfer" : MessageLookupByLibrary.simpleMessage("Перевести"),
    "buttonUpgrade" : MessageLookupByLibrary.simpleMessage("UPGRADE"),
    "buyBook" : MessageLookupByLibrary.simpleMessage("Купи на"),
    "cart" : MessageLookupByLibrary.simpleMessage("Books you are going to take"),
    "cartAddBooks" : MessageLookupByLibrary.simpleMessage("Добавьте книги"),
    "cartBooksAccepted" : MessageLookupByLibrary.simpleMessage("Книги успешно получены"),
    "cartBooksGiven" : MessageLookupByLibrary.simpleMessage("Книги успешно переданы"),
    "cartConfirmHandover" : MessageLookupByLibrary.simpleMessage("Подтвердите, что отдали книги"),
    "cartConfirmReceived" : MessageLookupByLibrary.simpleMessage("Подтвердите получение книг"),
    "cartMakeApointment" : MessageLookupByLibrary.simpleMessage("Договоритесь о встрече"),
    "cartRequesterHasToConfirm" : MessageLookupByLibrary.simpleMessage("Получатель должен подтвердить получение книг"),
    "cartRequesterHasToTopup" : MessageLookupByLibrary.simpleMessage("Получатель книг должен пополнить баланс"),
    "cartTopup" : m11,
    "chatStatusCompleteFrom" : MessageLookupByLibrary.simpleMessage("Книги переданы"),
    "chatStatusCompleteTo" : MessageLookupByLibrary.simpleMessage("Книги получены"),
    "chatStatusHandoverFrom" : MessageLookupByLibrary.simpleMessage("Завершите передачу книг"),
    "chatStatusHandoverTo" : MessageLookupByLibrary.simpleMessage("Подтвердите получение книг"),
    "chatStatusInitialFrom" : MessageLookupByLibrary.simpleMessage("Отдайте книги"),
    "chatStatusInitialTo" : MessageLookupByLibrary.simpleMessage("Получите книги"),
    "chatbotWelcome" : MessageLookupByLibrary.simpleMessage("Привет! Я чатбот Библосферы, задавай мне любые вопросы про приложение. Если я не смогу ответить, перешлю администратору."),
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
    "confirmBlockUser" : MessageLookupByLibrary.simpleMessage("Do you want to block this user?"),
    "dialogBookLimit" : m12,
    "dialogWishLimit" : m13,
    "displayCurrency" : MessageLookupByLibrary.simpleMessage("Валюта отображения:"),
    "distanceLine" : m14,
    "distanceUnknown" : MessageLookupByLibrary.simpleMessage("Расстояние: неизвестно"),
    "emptyAmount" : MessageLookupByLibrary.simpleMessage("Сумма не может быть пустой"),
    "enterTitle" : MessageLookupByLibrary.simpleMessage("Enter title/author"),
    "exceedAmount" : MessageLookupByLibrary.simpleMessage("Сумма должна быть меньше доступного остатка"),
    "financeTitle" : m15,
    "findBook" : MessageLookupByLibrary.simpleMessage("Найти книгу"),
    "findbookTitle" : MessageLookupByLibrary.simpleMessage("НАЙДИ КНИГУ"),
    "hintAddToWishlist" : MessageLookupByLibrary.simpleMessage("Add to wishlist"),
    "hintAuthorTitle" : MessageLookupByLibrary.simpleMessage("Автор или название"),
    "hintBookDetails" : MessageLookupByLibrary.simpleMessage("Изменить информацию о книге"),
    "hintChatOpen" : MessageLookupByLibrary.simpleMessage("Перейти в чат"),
    "hintConfirmHandover" : MessageLookupByLibrary.simpleMessage("Confirm that you\'ve received this book"),
    "hintDeleteBook" : MessageLookupByLibrary.simpleMessage("Удалить книгу"),
    "hintHolderChatOpen" : MessageLookupByLibrary.simpleMessage("Open chat with person who hold the book"),
    "hintManageBook" : MessageLookupByLibrary.simpleMessage("Open this book in MY BOOKS screen"),
    "hintNotMore" : m16,
    "hintOutptAcount" : MessageLookupByLibrary.simpleMessage("Ваш Stellar счёт для вывода средств"),
    "hintOutputMemo" : MessageLookupByLibrary.simpleMessage("Memo для вывода средств через Stellar"),
    "hintRequestReturn" : MessageLookupByLibrary.simpleMessage("Попросить вернуть книгу"),
    "hintReturn" : MessageLookupByLibrary.simpleMessage("Вернуть книгу"),
    "hintShareBook" : MessageLookupByLibrary.simpleMessage("Поделиться ссылкой"),
    "ifNotFound" : MessageLookupByLibrary.simpleMessage("Если вы не нашли книгу вы можете:"),
    "imageLinkHint" : MessageLookupByLibrary.simpleMessage("Скопируйте ссылку на обложку книги"),
    "inMyBooks" : MessageLookupByLibrary.simpleMessage("Эта книга есть у вас"),
    "inMyWishes" : MessageLookupByLibrary.simpleMessage("Эта книга в вашем списке желаний"),
    "inputStellarAcount" : MessageLookupByLibrary.simpleMessage("Счёт Stellar для пополнения:"),
    "inputStellarMemo" : MessageLookupByLibrary.simpleMessage("Memo для пополнения через Stellar:"),
    "introDone" : MessageLookupByLibrary.simpleMessage("DONE"),
    "introMeet" : MessageLookupByLibrary.simpleMessage("Meet"),
    "introMeetHint" : MessageLookupByLibrary.simpleMessage("Contact owner of the books you like and arrange appointment to get new books to read."),
    "introShoot" : MessageLookupByLibrary.simpleMessage("Add books"),
    "introShootHint" : MessageLookupByLibrary.simpleMessage("Shoot your bookcase and share to neighbours and tourists. Your books attract likeminded people."),
    "introSkip" : MessageLookupByLibrary.simpleMessage("SKIP"),
    "introSurf" : MessageLookupByLibrary.simpleMessage("Surf"),
    "introSurfHint" : MessageLookupByLibrary.simpleMessage("App shows bookcases in 200 km around you sorted by distance. Get access to wide variaty of books."),
    "isbnNotFound" : MessageLookupByLibrary.simpleMessage("Book is not found by ISBN"),
    "km" : MessageLookupByLibrary.simpleMessage(" km"),
    "leaseAgreement" : m17,
    "linkCopied" : MessageLookupByLibrary.simpleMessage("Ссылка скопирована в буфер обмена"),
    "loading" : MessageLookupByLibrary.simpleMessage("Loading..."),
    "loginAgree1" : MessageLookupByLibrary.simpleMessage("By clicking sign in button below, you agree \n to our "),
    "loginAgree2" : MessageLookupByLibrary.simpleMessage("end user licence agreement"),
    "loginAgree3" : MessageLookupByLibrary.simpleMessage("\nand that you read our "),
    "loginAgree4" : MessageLookupByLibrary.simpleMessage("privacy policy"),
    "logout" : MessageLookupByLibrary.simpleMessage("Logout"),
    "memoCopied" : MessageLookupByLibrary.simpleMessage("Memo скопировано в буфер обмена"),
    "menuBalance" : MessageLookupByLibrary.simpleMessage("Баланс"),
    "menuMessages" : MessageLookupByLibrary.simpleMessage("Сообщения"),
    "menuReferral" : MessageLookupByLibrary.simpleMessage("Реферальная программа"),
    "menuSettings" : MessageLookupByLibrary.simpleMessage("Настройки"),
    "menuSupport" : MessageLookupByLibrary.simpleMessage("Поддержка"),
    "monthlyDescription" : MessageLookupByLibrary.simpleMessage("Keep more books and enjoy extended wish list with Monthly paid plan"),
    "myBooks" : MessageLookupByLibrary.simpleMessage("Мои книги"),
    "myBooksWithUser" : m18,
    "mybooksTitle" : MessageLookupByLibrary.simpleMessage("МОИ КНИГИ"),
    "negativeAmount" : MessageLookupByLibrary.simpleMessage("Сумма должна быть больше нуля"),
    "no" : MessageLookupByLibrary.simpleMessage("No"),
    "noMessages" : MessageLookupByLibrary.simpleMessage("Нет сообщений"),
    "noOperations" : MessageLookupByLibrary.simpleMessage("No operations"),
    "noReferrals" : MessageLookupByLibrary.simpleMessage("No referrals"),
    "notSufficientForAgreement" : m19,
    "nothingToSend" : MessageLookupByLibrary.simpleMessage("Nothing to send"),
    "offerBook" : m20,
    "ok" : MessageLookupByLibrary.simpleMessage("Ok"),
    "opInAppPurchase" : MessageLookupByLibrary.simpleMessage("Пополнение счёта в приложении"),
    "opInStellar" : MessageLookupByLibrary.simpleMessage("Пополнение счёта через Stellar"),
    "opLeasing" : MessageLookupByLibrary.simpleMessage("Оплата/залог за книгу"),
    "opOutStellar" : MessageLookupByLibrary.simpleMessage("Вывод средств через Stellar"),
    "opReferral" : MessageLookupByLibrary.simpleMessage("Партнёрский доход"),
    "opReward" : MessageLookupByLibrary.simpleMessage("Вознаграждение за книгу"),
    "outputStellarAccount" : MessageLookupByLibrary.simpleMessage("Счёт Stellar для выплат:"),
    "outputStellarMemo" : MessageLookupByLibrary.simpleMessage("Memo для вывода Stellar:"),
    "patronDescription" : MessageLookupByLibrary.simpleMessage("Your generous contribution makes this app better and helps to promote book sharing"),
    "paymentError" : MessageLookupByLibrary.simpleMessage("Что-то пошло не так, напишите администратору"),
    "perMonth" : MessageLookupByLibrary.simpleMessage("per month"),
    "perYear" : MessageLookupByLibrary.simpleMessage("per year"),
    "planPaid" : MessageLookupByLibrary.simpleMessage("Member"),
    "planTrial" : MessageLookupByLibrary.simpleMessage("Trial"),
    "privacyPolicy" : MessageLookupByLibrary.simpleMessage("Privacy Policy"),
    "profileUserBooks" : m21,
    "receiveBooks" : m22,
    "recognitionProgressBooks" : m23,
    "recognitionProgressCatalogsLookup" : MessageLookupByLibrary.simpleMessage("Searching books in catalogues"),
    "recognitionProgressCompleted" : MessageLookupByLibrary.simpleMessage("Successfuly completed"),
    "recognitionProgressFailed" : MessageLookupByLibrary.simpleMessage("We encountered some difficulties with image recognition. Please try later."),
    "recognitionProgressNone" : MessageLookupByLibrary.simpleMessage("Some problem with recofnition. Try again."),
    "recognitionProgressOutline" : MessageLookupByLibrary.simpleMessage("Recognising books outlines"),
    "recognitionProgressRescan" : MessageLookupByLibrary.simpleMessage("Rescaning fragments of the image"),
    "recognitionProgressScan" : MessageLookupByLibrary.simpleMessage("Computer vision scans the image"),
    "recognitionProgressStore" : MessageLookupByLibrary.simpleMessage("Storing book records."),
    "recognitionProgressTitle" : MessageLookupByLibrary.simpleMessage("Recognition progress"),
    "recognitionProgressUpload" : MessageLookupByLibrary.simpleMessage("Uploading image to cloud storage"),
    "recognizeFromCamera" : MessageLookupByLibrary.simpleMessage("Сфотографировать полку"),
    "recognizeFromGallery" : MessageLookupByLibrary.simpleMessage("Распознать книги с фотографии"),
    "referralLink" : MessageLookupByLibrary.simpleMessage("Ваша партнёрская ссылка:"),
    "referralTitle" : MessageLookupByLibrary.simpleMessage("МОИ РЕФЕРАЛЫ"),
    "requestBook" : m24,
    "requestPost" : m25,
    "requestReturn" : m26,
    "requestReturnByOwner" : m27,
    "scanISBN" : MessageLookupByLibrary.simpleMessage("Scan ISBN code"),
    "selectDisplayCurrency" : MessageLookupByLibrary.simpleMessage("Выберите валюту отображения:"),
    "sendBooks" : m28,
    "settingsPlan" : m29,
    "settingsTitleGeneral" : MessageLookupByLibrary.simpleMessage("Общие настройки"),
    "settingsTitleIn" : MessageLookupByLibrary.simpleMessage("Пополнение баланса"),
    "settingsTitleInStellar" : MessageLookupByLibrary.simpleMessage("Пополнение через Stallar"),
    "settingsTitleOutStellar" : MessageLookupByLibrary.simpleMessage("Выплаты через Stallar"),
    "sharedFeeLine" : m30,
    "sharingMotto" : MessageLookupByLibrary.simpleMessage("Бери книги у людей вместо покупки в магазинах"),
    "showDeposit" : m31,
    "showRent" : m32,
    "snackAllowLocation" : MessageLookupByLibrary.simpleMessage("Дайте разрешение на использование текущей позиции для поиска и добавления книг"),
    "snackBookAddedToCart" : MessageLookupByLibrary.simpleMessage("Книга добавлена в корзину"),
    "snackBookImageChanged" : MessageLookupByLibrary.simpleMessage("Новая обложка книги установлена."),
    "snackBookNotConfirmed" : MessageLookupByLibrary.simpleMessage("Вы не подтвердили получение книг и не можете взять другую книгу"),
    "snackBookNotFound" : MessageLookupByLibrary.simpleMessage("Книга не найдена. Попробуйте изменить строку поиска."),
    "snackBookPending" : MessageLookupByLibrary.simpleMessage("Прошлая передача книг не завершена и вы не можете добавлять книги"),
    "snackBookPriceChanged" : MessageLookupByLibrary.simpleMessage("Цена книги установлена."),
    "snackPaidPlanActivated" : MessageLookupByLibrary.simpleMessage("Your paid plan is activated"),
    "snackRecgnitionStarted" : MessageLookupByLibrary.simpleMessage("Add more bookshelves while image processing."),
    "snackRecognitionDone" : m33,
    "snackWishDeleted" : MessageLookupByLibrary.simpleMessage("Book deleted from your wishlist"),
    "stellarOutput" : MessageLookupByLibrary.simpleMessage("Вывод средств на Stellar счёт:"),
    "subscriptionDisclaimer" : m34,
    "successfulPayment" : MessageLookupByLibrary.simpleMessage("Платёж добавлен в очередь на исполнение"),
    "supportChat" : MessageLookupByLibrary.simpleMessage("Чат с поддержкой"),
    "supportChatbot" : MessageLookupByLibrary.simpleMessage("Во вкладке Сообщения есть чат с ботом Библосферы, он может ответить на любые вопросы о приложении. Если понадобится связаться напрямую со мной, пишите в telegram "),
    "supportGetBalance" : MessageLookupByLibrary.simpleMessage("Пополнить счёт можно двумя способами: через покупку в приложении по карточке, зарегистрированной в Google Play или App Store. Или сделать перевод криптовалюты Stellar (XLM) на счёт, указанный в настройках."),
    "supportGetBooks" : MessageLookupByLibrary.simpleMessage("Найдите книгу, которую Вы хотите почитать, и напишите её хозяину, чтобы договориться о встрече. При получении книг вам нужно будет оплатить депозит. Вы можете пополнить свой баланс по карточке или криптовалютой Stellar, а можете заработать в Библосфере, давая свои книги почитать. Вы также можете зарабатывать через партнёрскую программу, приглашая других участников."),
    "supportPayout" : MessageLookupByLibrary.simpleMessage("Если у Вас большой баланс в Библосфере, Вы можете вывести эти средства. Вывести средства можно на свой кошелёк Stellar или через Stellar на любой кошелёк, карту или счёт. Для вывода на карту или кошелёк воспользуйстесь услугами online-обменников."),
    "supportReferrals" : MessageLookupByLibrary.simpleMessage("Организуйте обмен книгами через Библосферу в своём сообществе или офисе и получайте комиссию за каждую сделку. Для этого поделитесь с друзьями и коллегами ссылкой на приложение (Вашей партнёрской ссылкой)."),
    "supportSignature" : MessageLookupByLibrary.simpleMessage("Денис Старк"),
    "supportText" : MessageLookupByLibrary.simpleMessage("## **Описание**\n\nПриложение предназначено для людей, которые любят читать. Оно помогает брать книги у друзей и соседей, вместо покупки в книжном магазине. Оно также помогает находить людей с похожими читательскими вкусами.\n\n## **Как добавить Ваши книги**\n\nВы можете добавить книги тремя способами:\n- Сфотографировать книжную полку (Приложение определит книги по корешкам)\n- Сосканировав ISBN штрих-код\n- По названию и/или автору\n\n## **Как брать книги**\n\nПриложение поможет найти у друзей и соседей книги, которые Вы хотите прочитать. Три простых шага: \n- Найдите книгу по названию или автору. \n- Напишите хозяину книги, чтобы договориться о встрече и передаче книги.\n- Верните книгу после прочтения\n\nНе нашли книгу поблизости? Добавьте её в списох желаний и приложение сообщит Вам, когда книга будет доступна.\n\n## **Сообщения**\n\nВ Приложении есть чат с другими пользователями для удобства обмена книгами. Обратите внимание, что этот чат не предназначен для приватного общения (используйте другие мессенджеры).\nЧаты не защищены шифрованием. Чат-бот анализирует сообщения и отправляет уведомления в Ваших чатах. Сообщения от бота отмечены тэгом **#bot_message**.\n\nВы можете добавлять в сообщения ссылки на книги. Нажимайте на сообщения с книгами в чате, чтобы перейти на экран с книгой.\n\n## **Платная подписка**\n\nВы можете пользоваться приложением без оплаты неограниченное время благодаря тем пользователям, которые перешли на платную подписку. Мы тратим деньги:\n- на разработку и доработку приложения\n- на хостинг и платные API\n- на работу дизайнера и продвижение\n\nВы можете присоедениться к тем пользователям кто оплачивает подписку. Это поможет улучшению Приложения и распространению шэринга книг.  \n\n## **Стать партнёром**\n\nМы открыты к партнёрству с людьми и организациями. Наша цель распространение шэринга книг и доступность чтения. Свяжитесь со мной в Телеграм - [Денис Старк](https://t.me/DenisStark77)\n\n"),
    "supportTitle" : MessageLookupByLibrary.simpleMessage("ПОДДЕРЖКА"),
    "supportTitleChatbot" : MessageLookupByLibrary.simpleMessage("Чат-бот Библосферы"),
    "supportTitleGetBalance" : MessageLookupByLibrary.simpleMessage("Пополнение счёта"),
    "supportTitleGetBooks" : MessageLookupByLibrary.simpleMessage("Как брать книги"),
    "supportTitlePayout" : MessageLookupByLibrary.simpleMessage("Вывод средств"),
    "supportTitleReferrals" : MessageLookupByLibrary.simpleMessage("Партнёрская программа"),
    "termsOfService" : MessageLookupByLibrary.simpleMessage("Terms of Service"),
    "title" : MessageLookupByLibrary.simpleMessage("Biblosphere"),
    "titleBookSettings" : MessageLookupByLibrary.simpleMessage("О КНИГЕ"),
    "titleGetBook" : MessageLookupByLibrary.simpleMessage("КНИГИ НЕТ"),
    "titleMessages" : MessageLookupByLibrary.simpleMessage("СООБЩЕНИЯ"),
    "titleReceiveBooks" : MessageLookupByLibrary.simpleMessage("ВЗЯТЬ КНИГИ"),
    "titleSendBooks" : MessageLookupByLibrary.simpleMessage("ОТДАЮ КНИГИ"),
    "titleSettings" : MessageLookupByLibrary.simpleMessage("НАСТРОЙКИ"),
    "titleSupport" : MessageLookupByLibrary.simpleMessage("ПОДДЕРЖКА"),
    "titleUserBooks" : MessageLookupByLibrary.simpleMessage("ОБМЕН КНИГАМИ"),
    "transitInitiated" : MessageLookupByLibrary.simpleMessage("Handover process initiated for the book"),
    "typeMsg" : MessageLookupByLibrary.simpleMessage("Type your message..."),
    "userBalance" : m35,
    "userHave" : m36,
    "welcome" : MessageLookupByLibrary.simpleMessage("WELCOME"),
    "wishAdded" : MessageLookupByLibrary.simpleMessage("Book has been added to your wishlist"),
    "wishAlreadyThere" : MessageLookupByLibrary.simpleMessage("Эта книга уже есть в вашем списке желаний"),
    "wishLimitPaid" : m37,
    "wishLimitPaidDesc" : m38,
    "wishLimitTrial" : m39,
    "wishLimitTrialDesc" : m40,
    "wrongAccount" : MessageLookupByLibrary.simpleMessage("Неверный счёт"),
    "wrongImageUrl" : MessageLookupByLibrary.simpleMessage("Неверная ссылка"),
    "yes" : MessageLookupByLibrary.simpleMessage("Yes"),
    "youBorrowThisBook" : MessageLookupByLibrary.simpleMessage("Вы взяли эту книгу"),
    "youHaveThisBook" : MessageLookupByLibrary.simpleMessage("Книга у вас"),
    "youLentThisBook" : m41,
    "youTransitThisBook" : MessageLookupByLibrary.simpleMessage("По этой книге не завершён процесс передачи"),
    "youWishThisBook" : MessageLookupByLibrary.simpleMessage("Эту книгу вы хотите почитать")
  };
}
