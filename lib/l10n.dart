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

  // List of books genres
    static Map<String, Map<String, String>> _genres = {
    'en': {
      'fiction': 'Fiction',
      'fiction_alternate_history': ' > Alternate history',
      'fiction_anthology': ' > Anthology',
      'fiction_chick_lit': ' > Chick lit',
      'fiction_childrens': ' > Children''s',
      'fiction_classic': ' > Classic',
      'fiction_comic_book': ' > Comic book',
      'fiction_coming_of_age': ' > Coming-of-age',
      'fiction_crime': ' > Crime',
      'fiction_drama': ' > Drama',
      'fiction_fairytale': ' > Fairytale',
      'fiction_fantasy': ' > Fantasy',
      'fiction_graphic_novel': ' > Graphic novel',
      'fiction_historical_fiction': ' > Historical fiction',
      'fiction_horror': ' > Horror',
      'fiction_mystery': ' > Mystery',
      'fiction_paranormal_romance': ' > Paranormal romance',
      'fiction_picture_book': ' > Picture book',
      'fiction_poetry': ' > Poetry',
      'fiction_political_thriller': ' > Political thriller',
      'fiction_romance': ' > Romance',
      'fiction_satire': ' > Satire',
      'fiction_science_fiction': ' > Science fiction',
      'fiction_short_story': ' > Short story',
      'fiction_suspense': ' > Suspense',
      'fiction_thriller': ' > Thriller',
      'fiction_western': ' > Western',
      'fiction_young_adult': ' > Young adult',
      'nonfiction': 'Nonfiction',
      'nonfiction_art_architecture': ' > Art/architecture',
      'nonfiction_autobiography': ' > Autobiography',
      'nonfiction_biography': ' > Biography',
      'nonfiction_business_economics': ' > Business/economics',
      'nonfiction_cookbook': ' > Cookbook',
      'nonfiction_crafts_hobbies': ' > Crafts/hobbies',
      'nonfiction_diary': ' > Diary',
      'nonfiction_dictionary': ' > Dictionary',
      'nonfiction_encyclopedia': ' > Encyclopedia',
      'nonfiction_guide': ' > Guide',
      'nonfiction_health_fitness': ' > Health/fitness',
      'nonfiction_history': ' > History',
      'nonfiction_home_and_garden': ' > Home and garden',
      'nonfiction_humor': ' > Humor',
      'nonfiction_journal': ' > Journal',
      'nonfiction_math': ' > Math',
      'nonfiction_memoir': ' > Memoir',
      'nonfiction_philosophy': ' > Philosophy',
      'nonfiction_prayer': ' > Prayer',
      'nonfiction_religion_spirituality_and_new_age': ' > Religion and spirituality',
      'nonfiction_review': ' > Review',
      'nonfiction_science': ' > Science',
      'nonfiction_self_help': ' > Self help',
      'nonfiction_sports_and_leisure': ' > Sports and leisure',
      'nonfiction_textbook': ' > Textbook',
      'nonfiction_travel': ' > Travel',
      'nonfiction_true_crime': ' > True crime',    
    },
    'ru': {
      'fiction': 'Художественная',
      'fiction_action_and_adventure': ' > Боевики и приключения',
      'fiction_alternate_history': ' > Альтернативная история',
      'fiction_anthology': ' > Антология',
      'fiction_chick_lit': ' > Для молодых женщин',
      'fiction_childrens': ' > Детская',
      'fiction_classic': ' > Классика',
      'fiction_comic_book': ' > Комикс',
      'fiction_coming_of_age': ' > Подростковая',
      'fiction_crime': ' > Криминальная',
      'fiction_drama': ' > Драма',
      'fiction_fairytale': ' > Сказки',
      'fiction_fantasy': ' > Фэнтези',
      'fiction_graphic_novel': ' > Комиксы',
      'fiction_historical_fiction': ' > Историческая фантастика',
      'fiction_horror': ' > Ужасы',
      'fiction_mystery': ' > Мистика',
      'fiction_paranormal_romance': ' > Паранормальный роман',
      'fiction_picture_book': ' > Иллюстрированная книга',
      'fiction_poetry': ' > Поэзия',
      'fiction_political_thriller': ' > Политический триллер',
      'fiction_romance': ' > Романтика',
      'fiction_satire': ' > Сатира',
      'fiction_science_fiction': ' > Научная фантастика',
      'fiction_short_story': ' > Рассказ',
      'fiction_suspense': ' > Саспенс',
      'fiction_thriller': ' > Триллер',
      'fiction_western': ' > Вестерн',
      'fiction_young_adult': ' > Молодежная',
      'nonfiction': 'Нехудожестванная',
      'nonfiction_art_architecture': ' > Искусство / архитектура',
      'nonfiction_autobiography': ' > Автобиография',
      'nonfiction_biography': ' > Биография',
      'nonfiction_business_economics': ' > Бизнес / экономика',
      'nonfiction_cookbook': ' > Поваренная книга',
      'nonfiction_crafts_hobbies': ' > Рукоделие / хобби',
      'nonfiction_diary': ' > Дневник',
      'nonfiction_dictionary': ' > Словарь',
      'nonfiction_encyclopedia': ' > Энциклопедия',
      'nonfiction_guide': ' > Руководство',
      'nonfiction_health_fitness': ' > Здоровье и фитнес',
      'nonfiction_history': ' > История',
      'nonfiction_home_and_garden': ' > Дом и сад',
      'nonfiction_humor': ' > Юмор',
      'nonfiction_journal': ' > Журнал',
      'nonfiction_math': ' > Математика',
      'nonfiction_memoir': ' > Мемуары',
      'nonfiction_philosophy': ' > Философия',
      'nonfiction_prayer': ' > Молитва',
      'nonfiction_religion_spirituality_and_new_age': ' > Религия и духовность',
      'nonfiction_review': ' > Обзор',
      'nonfiction_science': ' > Наука',
      'nonfiction_self_help': ' > Самопомощь',
      'nonfiction_sports_and_leisure': ' > Спорт и отдых',
      'nonfiction_textbook': ' > Учебник',
      'nonfiction_travel': ' > Путешествия',
      'nonfiction_true_crime': ' > Криминальная',    },
  };

  Map<String, String> get genres {
    print('!!!DEDUG: System locale: ${Intl.defaultLocale}');

    String lang = Intl.defaultLocale;

    if( !_genres.keys.contains(lang) )
      lang = 'en';

    return _genres[lang];
  }

  String genre(String code) {
    if (code == null)
      return null;

    String lang = Intl.defaultLocale;
    if( !_genres.keys.contains(lang) )
      lang = 'en';

    String genre = _genres[lang][code];

    if (genre.startsWith(' > '))
       genre = genre.substring(3);

    return genre;
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
    return Intl.message('Add books', name: 'introShoot');
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

  String get loading {
    return Intl.message('Loading...', name: 'loading');
  }

  String get km {
    return Intl.message(' km', name: 'km');
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

  String get welcome {
    return Intl.message('WELCOME', name: 'welcome');
  }

  String get addToWishlist {
    return Intl.message('Add to Wishlist', name: 'addToWishlist');
  }

  String get scanISBN {
    return Intl.message('Scan ISBN code',
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

  String get cart {
    return Intl.message('Books you are going to take', name: 'cart');
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
    return Intl.message("Balance: ${balance}",
        name: 'userBalance', args: [balance]);
  }

  String bookLanguage(lang) {
    return Intl.message("Language: $lang",
        name: 'bookLanguage', args: [lang]);
  }

  String financeTitle(balance) {
    return Intl.message("МОЙ БАЛАНС: $balance",
        name: 'financeTitle', args: [balance]);
  }

  String get addbookTitle{
    return Intl.message('ДОБАВЬ КНИГУ', name: 'addbookTitle');
  }

  String get addBook{
    return Intl.message('Добавить книгу', name: 'addBook');
  }

  String get findbookTitle{
    return Intl.message('НАЙДИ КНИГУ', name: 'findbookTitle');
  }

  String get findBook{
    return Intl.message('Найти книгу', name: 'findBook');
  }

  String get mybooksTitle{
    return Intl.message('МОИ КНИГИ', name: 'mybooksTitle');
  }

  String get myBooks{
    return Intl.message('Мои книги', name: 'myBooks');
  }

  String get referralLink{
    return Intl.message('Ваша партнёрская ссылка:', name: 'referralLink');
  }

  String get linkCopied{
    return Intl.message('Ссылка скопирована в буфер обмена', name: 'linkCopied');
  }

  String get menuMessages{
    return Intl.message('Сообщения', name: 'menuMessages');
  }

  String get titleMessages{
    return Intl.message('СООБЩЕНИЯ', name: 'titleMessages');
  }

  String get menuSettings{
    return Intl.message('Настройки', name: 'menuSettings');
  }

  String get titleSettings{
    return Intl.message('НАСТРОЙКИ', name: 'titleSettings');
  }

  String get menuBalance{
    return Intl.message('Баланс', name: 'menuBalance');
  }

  String get menuReferral{
    return Intl.message('Реферальная программа', name: 'menuReferral');
  }

  String get referralTitle{
    return Intl.message('МОИ РЕФЕРАЛЫ', name: 'referralTitle');
  }

  String get menuSupport{
    return Intl.message('Поддержка', name: 'menuSupport');
  }

  String get supportTitle{
    return Intl.message('ПОДДЕРЖКА', name: 'supportTitle');
  }

  String get hintAuthorTitle{
    return Intl.message('Автор или название', name: 'hintAuthorTitle');
  }

  String get chipMyBooks{
    return Intl.message('Мои книги', name: 'chipMyBooks');
  }

  String get chipLent{
    return Intl.message('Отданные', name: 'chipLent');
  }

  String get chipBorrowed{
    return Intl.message('Взятые', name: 'chipBorrowed');
  }

  String get chipWish{
    return Intl.message('Хочу', name: 'chipWish');
  }

  String get chipTransit{
    return Intl.message('Транзит', name: 'chipTransit');
  }

  String get youHaveThisBook{
    return Intl.message('Книга у вас', name: 'youHaveThisBook');
  }

  String get youWishThisBook{
    return Intl.message('Эту книгу вы хотите почитать', name: 'youWishThisBook');
  }

  String youLentThisBook (user){
    return Intl.message("Книга у $user",
        name: 'youLentThisBook', args: [user]);
  }

  String get youBorrowThisBook {
    return Intl.message('Вы взяли эту книгу',
        name: 'youBorrowThisBook');
  }

  String get youTransitThisBook{
    return Intl.message('По этой книге не завершён процесс передачи', name: 'youTransitThisBook');
  }

  String get chipPayin{
    return Intl.message('Пополнения', name: 'chipPayin');
  }

  String get chipPayout{
    return Intl.message('Выплаты', name: 'chipPayout');
  }

  String get chipLeasing{
    return Intl.message('Расходы', name: 'chipLeasing');
  }

  String get chipReward{
    return Intl.message('Доходы', name: 'chipReward');
  }

  String get chipReferrals{
    return Intl.message('Рефералы', name: 'chipReferrals');
  }

  String get noOperations{
    return Intl.message('No operations', name: 'noOperations');
  }

  String get opLeasing{
    return Intl.message('Оплата/залог за книгу', name: 'opLeasing');
  }

  String get opReward{
    return Intl.message('Вознаграждение за книгу', name: 'opReward');
  }

  String get opInAppPurchase{
    return Intl.message('Пополнение счёта в приложении', name: 'opInAppPurchase');
  }

  String get opInStellar{
    return Intl.message('Пополнение счёта через Stellar', name: 'opInStellar');
  }

  String get opOutStellar{
    return Intl.message('Вывод средств через Stellar', name: 'opOutStellar');
  }

  String get opReferral{
    return Intl.message('Партнёрский доход', name: 'opReferral');
  }

  String get noReferrals{
    return Intl.message('No referrals', name: 'noReferrals');
  }

  String sharedFeeLine(amount) {
    return Intl.message('Общий доход: +$amount',
        name: 'sharedFeeLine', args: [amount]);
  }

  String get inputStellarAcount{
    return Intl.message('Счёт Stellar для пополнения:', name: 'inputStellarAcount');
  }

  String get accountCopied{
    return Intl.message('Счёт скопирован в буфер обмена', name: 'accountCopied');
  }

  String get outputStellarAccount{
    return Intl.message('Счёт Stellar для выплат:', name: 'outputStellarAccount');
  }

  String get wrongAccount{
    return Intl.message('Неверный счёт', name: 'wrongAccount');
  }

  String get hintOutptAcount{
    return Intl.message('Ваш Stellar счёт для вывода средств', name: 'hintOutptAcount');
  }

  String get stellarOutput{
    return Intl.message('Вывод средств на Stellar счёт:', name: 'stellarOutput');
  }

  String hintNotMore(amount) {
    return Intl.message('Введите сумму не более $amount',
        name: 'hintNotMore', args: [amount]);
  }

  String get emptyAmount{
    return Intl.message('Сумма не может быть пустой', name: 'emptyAmount');
  }

  String get negativeAmount{
    return Intl.message('Сумма должна быть больше нуля', name: 'negativeAmount');
  }

  String get exceedAmount{
    return Intl.message('Сумма должна быть меньше доступного остатка', name: 'exceedAmount');
  }

  String get successfulPayment{
    return Intl.message('Платёж добавлен в очередь на исполнение', name: 'successfulPayment');
  }

  String get paymentError{
    return Intl.message('Что-то пошло не так, напишите администратору', name: 'paymentError');
  }

  String get buttonTransfer{
    return Intl.message('Перевести', name: 'buttonTransfer');
  }

  String get titleGetBook{
    return Intl.message('КНИГИ НЕТ', name: 'titleGetBook');
  }

  String get inMyWishes{
    return Intl.message('Эта книга в вашем списке желаний', name: 'inMyWishes');
  }

  String get inMyBooks{
    return Intl.message('Эта книга есть у вас', name: 'inMyBooks');
  }

  String requestBook(book) {
    return Intl.message('Можно взять у вас \"$book\"?',
        name: 'requestBook', args: [book]);
  }

  String get bookAround{
    return Intl.message('Книга поблизости', name: 'bookAround');
  }

  String userHave(user) {
    return Intl.message('У пользователя $user',
        name: 'userHave', args: [user]);
  }

  String distanceLine(distance) {
    return Intl.message('Расстояние: ${distance} км',
        name: 'distanceLine', args: [distance]);
  }

  String requestPost(book) {
    return Intl.message('Можете прислать мне \"$book\"?',
        name: 'requestPost', args: [book]);
  }

  String get bookByPost{
    return Intl.message('Получи по почте', name: 'bookByPost');
  }

  String get bookInLibrary{
    return Intl.message('Найди в библиотеке через', name: 'bookInLibrary');
  }

  String get buyBook{
    return Intl.message('Купи на', name: 'buyBook');
  }

  String get ifNotFound{
    return Intl.message('Если вы не нашли книгу вы можете:', name: 'ifNotFound');
  }

  String get noMessages{
    return Intl.message('Нет сообщений', name: 'noMessages');
  }

  String get titleReceiveBooks{
    return Intl.message('ВЗЯТЬ КНИГИ', name: 'titleReceiveBooks');
  }

  String receiveBooks(num) {
    return Intl.message('Взять книги ($num)',
        name: 'receiveBooks', args: [num]);
  }

  String get titleSendBooks{
    return Intl.message('ОТДАЮ КНИГИ', name: 'titleSendBooks');
  }

  String sendBooks(num) {
    return Intl.message('Отдаю книги ($num)',
        name: 'sendBooks', args: [num]);
  }

  String leaseAgreement(total, month) {
    return Intl.message('Депозит за книги: $total, оплата за месяц $month',
        name: 'leaseAgreement', args: [total, month]);
  }

  String notSufficientForAgreement(missing, total, month) {
    return Intl.message('Вам нехватает $missing. Депозит за книги: $total, оплата за месяц $month',
        name: 'notSufficientForAgreement', args: [missing, total, month]);
  }

  String get buttonPayin{
    return Intl.message('Пополнить счёт', name: 'buttonPayin');
  }

  String get buttonConfirmBooks{
    return Intl.message('Нажмите при получении', name: 'buttonConfirmBooks');
  }

  // Not translated beyond this line

  String get buttonGivenBooks{
    return Intl.message('Книги отдал \u{02713}', name: 'buttonGivenBooks');
  }

  String get displayCurrency{
    return Intl.message('Валюта отображения:', name: 'displayCurrency');
  }

  String get selectDisplayCurrency{
    return Intl.message('Выберите валюту отображения:', name: 'selectDisplayCurrency');
  }

  String get bookImageLabel{
    return Intl.message('Ссылка на фото обложки:', name: 'bookImageLabel');
  }

  String get wrongImageUrl{
    return Intl.message('Неверная ссылка', name: 'wrongImageUrl');
  }

  String get imageLinkHint{
    return Intl.message('Скопируйте ссылку на обложку книги', name: 'imageLinkHint');
  }

  String get bookPriceLabel{
    return Intl.message('Цена книги', name: 'bookPriceLabel');
  }

  String get bookPriceHint{
    return Intl.message('Введите цену книги', name: 'bookPriceHint');
  }

  String get titleBookSettings{
    return Intl.message('О КНИГЕ', name: 'titleBookSettings');
  }

  String get titleUserBooks{
    return Intl.message('ОБМЕН КНИГАМИ', name: 'titleUserBooks');
  }

  String requestReturn(book) {
    return Intl.message('Хочу вернуть вам \"$book\"?',
        name: 'requestReturn', args: [book]);
  }

  String requestReturnByOwner(book) {
    return Intl.message('Пожалуйста, верните книгу \"$book\"?',
        name: 'requestReturnByOwner', args: [book]);
  }

  String get chatStatusInitialFrom{
    return Intl.message('Отдайте книги', name: 'chatStatusInitialFrom');
  }

  String get chatStatusHandoverFrom{
    return Intl.message('Завершите передачу книг', name: 'chatStatusHandoverFrom');
  }

  String get chatStatusCompleteFrom{
    return Intl.message('Книги переданы', name: 'chatStatusCompleteFrom');
  }

  String get chatStatusInitialTo{
    return Intl.message('Получите книги', name: 'chatStatusInitialTo');
  }

  String get chatStatusHandoverTo{
    return Intl.message('Подтвердите получение книг', name: 'chatStatusHandoverTo');
  }

  String get chatStatusCompleteTo{
    return Intl.message('Книги получены', name: 'chatStatusCompleteTo');
  }

  String get chipMyBooksWithHim{
    return Intl.message('Мои книги у него', name: 'chipMyBooksWithHim');
  }

  String get chipHisBooks{
    return Intl.message('Его книги', name: 'chipHisBooks');
  }

  String get chipHisBooksWithMe{
    return Intl.message('Его книги у меня', name: 'chipHisBooksWithMe');
  }

  String bookPrice(total) {
    return Intl.message('Цена: $total',
        name: 'bookPrice', args: [total]);
  }

  String bookRent(month) {
    return Intl.message('Цена: $month в месяц',
        name: 'bookRent', args: [month]);
  }

  String bookOwner(user) {
    return Intl.message("Владелец: $user",
        name: 'bookOwner', args: [user]);
  }

  String bookWith(user) {
    return Intl.message("Книга у $user",
        name: 'bookWith', args: [user]);
  }

  String get wishAlreadyThere{
    return Intl.message('Эта книга уже есть в вашем списке желаний', name: 'wishAlreadyThere');
  }

  String get bookAlreadyThere{
    return Intl.message('Эта книга уже есть у вас в каталоге', name: 'bookAlreadyThere');
  }

  String get hintChatOpen{
    return Intl.message('Перейти в чат', name: 'hintChatOpen');
  }

  String get hintRequestReturn{
    return Intl.message('Попросить вернуть книгу', name: 'hintRequestReturn');
  }

  String get hintReturn{
    return Intl.message('Вернуть книгу', name: 'hintReturn');
  }

  String get hintDeleteBook{
    return Intl.message('Удалить книгу', name: 'hintDeleteBook');
  }

  String get hintBookDetails{
    return Intl.message('Изменить информацию о книге', name: 'hintBookDetails');
  }

  String get hintShareBook{
    return Intl.message('Поделиться ссылкой', name: 'hintShareBook');
  }

  String get snackBookNotConfirmed{
    return Intl.message('Вы не подтвердили получение книг и не можете взять другую книгу', name: 'snackBookNotConfirmed');
  }

  String get snackBookPending{
    return Intl.message('Прошлая передача книг не завершена и вы не можете добавлять книги', name: 'snackBookPending');
  }

  String get snackBookAddedToCart{
    return Intl.message('Книга добавлена в корзину', name: 'snackBookAddedToCart');
  }

  String get sharingMotto{
    return Intl.message('Бери книги у людей вместо покупки в магазинах', name: 'sharingMotto');
  }

  String get inputStellarMemo{
    return Intl.message('Memo для пополнения через Stellar:', name: 'inputStellarMemo');
  }

  String get memoCopied{
    return Intl.message('Memo скопировано в буфер обмена', name: 'memoCopied');
  }

  String get outputStellarMemo{
    return Intl.message('Memo для вывода Stellar:', name: 'outputStellarMemo');
  }

  String get bookNotFound{
    return Intl.message('Эта книга не найдена в Библосфере. Добавьте её в желаемые книги и мы сообщим вам, когда она появится рядом с вами.', name: 'bookNotFound');
  }

  String get chatbotWelcome{
    return Intl.message('Привет! Я чатбот Библосферы, задавай мне любые вопросы про приложение. Если я не смогу ответить, перешлю администратору.', name: 'chatbotWelcome');
  }

  String get snackBookNotFound{
    return Intl.message('Книга не найдена. Попробуйте изменить строку поиска.', name: 'snackBookNotFound');
  }

  /*
  String get snackBookAlreadyInTransit{
    return Intl.message('Книга передаётся другому пользователю. Выберите другую книгу.', name: 'snackBookAlreadyInTransit');
  }
  */

  String get snackBookImageChanged {
    return Intl.message('Новая обложка книги установлена.', name: 'snackBookImageChanged');
  }

  String get snackBookPriceChanged {
    return Intl.message('Цена книги установлена.', name: 'snackBookPriceChanged');
  }

  String get supportChat {
    return Intl.message('Чат с поддержкой', name: 'supportChat');
  }

  String get titleSupport {
    return Intl.message('ПОДДЕРЖКА', name: 'titleSupport');
  }

  String showDeposit(amount) {
    return Intl.message("Залог: $amount",
        name: 'showDeposit', args: [amount]);
  }

  String showRent(amount) {
    return Intl.message("Оплата в месяц: $amount",
        name: 'showRent', args: [amount]);
  }

  String get cartAddBooks {
    return Intl.message('Добавьте книги', name: 'cartAddBooks');
  }

  String cartTopup(amount) {
    return Intl.message("Пополните баланс на $amount",
        name: 'cartTopup', args: [amount]);
  }

  String get cartMakeApointment {
    return Intl.message('Договоритесь о встрече', name: 'cartMakeApointment');
  }

  String get cartRequesterHasToTopup {
    return Intl.message('Получатель книг должен пополнить баланс', name: 'cartRequesterHasToTopup');
  }

  String get cartConfirmHandover {
    return Intl.message('Подтвердите, что отдали книги', name: 'cartConfirmHandover');
  }

  String get cartConfirmReceived {
    return Intl.message('Подтвердите получение книг', name: 'cartConfirmReceived');
  }

  String get cartRequesterHasToConfirm {
    return Intl.message('Получатель должен подтвердить получение книг', name: 'cartRequesterHasToConfirm');
  }

  String get cartBooksAccepted {
    return Intl.message('Книги успешно получены', name: 'cartBooksAccepted');
  }

  String get cartBooksGiven {
    return Intl.message('Книги успешно переданы', name: 'cartBooksGiven');
  }

  String myBooksWithUser(count) {
    return Intl.message("Мои книги у этого пользователя ($count)",
        name: 'myBooksWithUser', args: [count]);
  }

  String booksOfUserWithMe(count) {
    return Intl.message("Книги этого пользователя у меня ($count)",
        name: 'booksOfUserWithMe', args: [count]);
  }

  String profileUserBooks(count) {
    return Intl.message("Книги пользователя ($count)",
        name: 'profileUserBooks', args: [count]);
  }

  String get supportTitleGetBooks {
    return Intl.message('Как брать книги', name: 'supportTitleGetBooks');
  }

  String get supportGetBooks {
    return Intl.message(
              'Найдите книгу, которую Вы хотите почитать, и напишите её хозяину, '
              'чтобы договориться о встрече. При получении книг вам нужно будет оплатить депозит. '
              'Вы можете пополнить свой баланс по карточке или криптовалютой Stellar, а '
              'можете заработать в Библосфере, давая свои книги почитать. Вы также можете зарабатывать '
              'через партнёрскую программу, приглашая других участников.'
    , name: 'supportGetBooks');
  }

  String get supportTitleGetBalance {
    return Intl.message('Пополнение счёта', name: 'supportTitleGetBalance');
  }

  String get supportGetBalance {
    return Intl.message(
              'Пополнить счёт можно двумя способами: через покупку в приложении по карточке, '
              'зарегистрированной в Google Play или App Store. Или сделать перевод криптовалюты '
              'Stellar (XLM) на счёт, указанный в настройках.'
    , name: 'supportGetBalance');
  }

  String get supportTitleReferrals {
    return Intl.message('Партнёрская программа', name: 'supportTitleReferrals');
  }

  String get supportReferrals {
    return Intl.message(
              'Организуйте обмен книгами через Библосферу в своём сообществе или '
              'офисе и получайте комиссию за каждую сделку. Для этого поделитесь с друзьями и '
              'коллегами ссылкой на приложение (Вашей партнёрской ссылкой).'
    , name: 'supportReferrals');
  }

  String get supportTitlePayout {
    return Intl.message('Вывод средств', name: 'supportTitlePayout');
  }

  String get supportPayout {
    return Intl.message(
              'Если у Вас большой баланс в Библосфере, Вы можете вывести эти средства. '
              'Вывести средства можно на свой кошелёк Stellar или через Stellar на любой кошелёк, карту или счёт. '
              'Для вывода на карту или кошелёк воспользуйстесь услугами online-обменников.'
    , name: 'supportPayout');
  }

  String get supportTitleChatbot {
    return Intl.message('Чат-бот Библосферы', name: 'supportTitleChatbot');
  }

  String get supportChatbot {
    return Intl.message(
              'Во вкладке Сообщения есть чат с ботом Библосферы, он может ответить на любые вопросы о '
              'приложении. Если понадобится связаться напрямую со мной, пишите в telegram '
    , name: 'supportChatbot');
  }

  String get supportSignature {
    return Intl.message('Денис Старк', name: 'supportSignature');
  }

  String bookIncome(month) {
    return Intl.message('Доход: $month в месяц',
        name: 'bookIncome', args: [month]);
  }

  String get distanceUnknown {
    return Intl.message('Расстояние: неизвестно',
        name: 'distanceUnknown');
  }

  String get snackAllowLocation {
    return Intl.message('Дайте разрешение на использование текущей позиции для поиска и добавления книг',
        name: 'snackAllowLocation');
  }

  String get hintOutputMemo {
    return Intl.message('Memo для вывода средств через Stellar',
        name: 'hintOutputMemo');
  }
 
  String get settingsTitleOutStellar {
    return Intl.message('Выплаты через Stallar',
        name: 'settingsTitleOutStellar');
  }
   
  String get settingsTitleInStellar {
    return Intl.message('Пополнение через Stallar',
        name: 'settingsTitleInStellar');
  }

  String get settingsTitleIn {
    return Intl.message('Пополнение баланса',
        name: 'settingsTitleIn');
  }
   
  String get settingsTitleGeneral {
    return Intl.message('Общие настройки',
        name: 'settingsTitleGeneral');
  }

  String get recognizeFromGallery {
    return Intl.message('Распознать книги с фотографии',
        name: 'recognizeFromGallery');
  }
  String get recognizeFromCamera {
    return Intl.message('Сфотографировать полку',
        name: 'recognizeFromCamera');
  }

  String get chooseHoldedBookForChat {
    return Intl.message('ВЫБЕРИТЕ КНИГУ',
        name: 'chooseHoldedBookForChat');
  }

  String get choosePartnerBookForChat {
    return Intl.message('ВЫБЕРИТЕ КНИГУ',
        name: 'choosePartnerBookForChat');
  }

  String offerBook(book) {
    return Intl.message('Рекомендую взять у меня \"$book\"',
        name: 'offerBook', args: [book]);
  }

  String get chipBooksToRequest{
    return Intl.message('Взять', name: 'chipBooksToRequest');
  }

  String get chipBooksToOffer{
    return Intl.message('Предложить', name: 'chipBooksToOffer');
  }

  String get chipBooksToReturn{
    return Intl.message('Вернуть', name: 'chipBooksToReturn');
  }

  String get chipBooksToAskForReturn{
    return Intl.message('Забрать', name: 'chipBooksToAskForReturn');
  }

  String get buttonSearchThirdParty{
    return Intl.message('Search in Stores & Libraries', name: 'buttonSearchThirdParty');
  }

  String get hintAddToWishlist {
    return Intl.message('Add to wishlist', name: 'hintAddToWishlist');
  }

  String get hintHolderChatOpen {
    return Intl.message('Open chat with person who hold the book', name: 'hintHolderChatOpen');
  }

  String get hintConfirmHandover {
    return Intl.message('Confirm that you\'ve received this book', name: 'hintConfirmHandover');
  }

  String get hintManageBook {
    return Intl.message('Open this book in MY BOOKS screen', name: 'hintManageBook');
  }

  String get buttonManageBook {
    return Intl.message('Open in MY BOOKS', name: 'buttonManageBook');
  }

  String settingsPlan(name) {
    return Intl.message("Plan: $name",
        name: 'settingsPlan', args: [name]);
  }

  String get planTrial {
    return Intl.message('Trial', name: 'planTrial');
  }

  String get buttonUpgrade {
    return Intl.message('UPGRADE', name: 'buttonUpgrade');
  }

  String get buttonSkip {
    return Intl.message('SKIP', name: 'buttonSkip');
  }

  String get snackRecgnitionStarted {
    return Intl.message('Add more bookshelves while image processing.', name: 'snackRecgnitionStarted');
  }

  String snackRecognitionDone(count) {
    return Intl.message("$count books have been recognized and added to your catalog.",
        name: 'snackRecognitionDone', args: [count]);
  }

  String get snackWishDeleted {
    return Intl.message('Book deleted from your wishlist', name: 'snackWishDeleted');
  }

  String get snackPaidPlanActivated {
    return Intl.message('Your paid plan is activated', name: 'snackPaidPlanActivated');
  }

  String dialogWishLimit(price) {
    return Intl.message('Trial plan only allows 10 books in the wish list. Upgrade for $price per month to have more.',
        name: 'dialogWishLimit', args: [price]);
  }

  String dialogBookLimit(price) {
    return Intl.message('Trial plan allows to keep only up to 2 books at a time. Upgrade for $price per month to have more.',
        name: 'dialogBookLimit', args: [price]);
  }

  String wishLimitTrial(count, upgrade) {
    //return Intl.message('Limit on wish list: $count (upgrate to have $upgrade)',
    return Intl.message('Limit on wish list: $count',
        name: 'wishLimitTrial', args: [count, upgrade]);
  }

  String wishLimitPaid(count) {
    return Intl.message('Limit on wish list: $count',
        name: 'wishLimitPaid', args: [count]);
  }

  String wishLimitTrialDesc(count, upgrade) {
    return Intl.message('You can keep up to $count books in your wish list. Upgrade to paid plan to increase to $upgrade.',
        name: 'wishLimitTrialDesc', args: [count, upgrade]);
  }

  String wishLimitPaidDesc(count) {
    return Intl.message('You can keep up to $count books in your wish list.',
        name: 'wishLimitPaidDesc', args: [count]);
  }

  String bookLimitTrial(count, upgrade) {
    //return Intl.message('Limit on taken books: $count (upgrade to $upgrade)',
    return Intl.message('Limit on taken books: $count',
        name: 'bookLimitTrial', args: [count, upgrade]);
  }

  String bookLimitPaid(count) {
    return Intl.message('Limit on taken books: $count',
        name: 'bookLimitPaid', args: [count]);
  }

  String bookLimitTrialDesc(count, upgrade) {
    return Intl.message('You can take up to $count books at a time plus number of books you\'ve given to other people. To keep up to $upgrade books upgrade to paid plan.',
        name: 'bookLimitTrialDesc', args: [count, upgrade]);
  }

  String bookLimitPaidDesc(count) {
    return Intl.message('You can take up to $count books at a time plus number of books you\'ve given to other people. To take more books return books previously taken.',
        name: 'bookLimitPaidDesc', args: [count]);
  }

  String get planPaid {
    return Intl.message('Member', name: 'planPaid');
  }

  String get perMonth {
    return Intl.message('per month', name: 'perMonth');
  }

  String get perYear {
    return Intl.message('per year', name: 'perYear');
  }

  String get monthlyDescription {
    return Intl.message('Keep more books and enjoy extended wish list with Monthly paid plan', name: 'monthlyDescription');
  }

  String get annualDescription {
    return Intl.message('Enjoy book sharing with your friends and neighbours for a whole year', name: 'annualDescription');
  }

  String get patronDescription {
    return Intl.message('Your generous contribution makes this app better and helps to promote book sharing', name: 'patronDescription');
  }

  String subscriptionDisclaimer(platform) {
    return Intl.message('Subscription will be charged to your $platform account on confirmation. Subscriptions will automatically renew unless canceled within 24-hours before the end of the current period. You can cancel anytime with your $platform account settings. Any unused portion of a free trial will be forfeited if you purchase a subscription.',
        name: 'subscriptionDisclaimer', args: [platform]);
  }

  String get privacyPolicy {
    return Intl.message('Privacy Policy', name: 'privacyPolicy');
  }

  String get termsOfService {
    return Intl.message('Terms of Service', name: 'termsOfService');
  }

  String get supportText {
/*
    return Intl.message("""
## **Introduction**

This app intended for people who love books and reading. App helps you to take books from your friends and neigbours instead of buying in the stores. It also helps you to find like minded people with similar reading taste around you.

## **How to add your books**

You can add you books in three ways:
- By making photo of your bookshelf (App will recognize books from the image by the bookspines)
- By scaning ISBN on a book
- By searching book with author/title

## **How to get books**

App helps you to find your wished books around you. It's simple three step flow: 
- Search book by author/title. 
- Chat with owner of the book and meet for the handover.
- Return the book

Could not find the book in a proximate distance? Just add it to your wishlist and App will inform you as soon as book is available.

## **Messaging**

App has integrated messaging to support book sharing among users. Please note that it's not intended for general chatting (please use other messangers instead).
Chats are not encrypted. Application bot is monitoring and participating in the chat by sending notifications (marked with #bot_message hashtag).

You can attach book to the message. Click on the message with book cover to navigate there. 

## **Paid subscription**

The App available free of charge. However there are following expences:
- cost of development
- cost of hosting and APIs
- design and marketing cost

We will be happy if you join other paying users to support this project and spread book sharing.  

## **Be our partner**

We are looking for people and organizations to partner with. Our mission to spread book sharing and makes books available for reading. Please contact me on Telegram - [Denis Stark](https://t.me/DenisStark77)

""", name: 'supportText');
*/
    return Intl.message("""
## **Описание**

Приложение предназначено для людей, которые любят читать. Оно помогает брать книги у друзей и соседей, вместо покупки в книжном магазине. Оно также помогает находить людей с похожими читательскими вкусами.

## **Как добавить Ваши книги**

Вы можете добавить книги тремя способами:
- Сфотографировать книжную полку (Приложение определит книги по корешкам)
- Сосканировав ISBN штрих-код
- По названию и/или автору

## **Как брать книги**

Приложение поможет найти у друзей и соседей книги, которые Вы хотите прочитать. Три простых шага: 
- Найдите книгу по названию или автору. 
- Напишите хозяину книги, чтобы договориться о встрече и передаче книги.
- Верните книгу после прочтения

Не нашли книгу поблизости? Добавьте её в списох желаний и приложение сообщит Вам, когда книга будет доступна.

## **Сообщения**

В Приложении есть чат с другими пользователями для удобства обмена книгами. Обратите внимание, что этот чат не предназначен для приватного общения (используйте другие мессенджеры).
Чаты не защищены шифрованием. Чат-бот анализирует сообщения и отправляет уведомления в Ваших чатах. Сообщения от бота отмечены тэгом **#bot_message**.

Вы можете добавлять в сообщения ссылки на книги. Нажимайте на сообщения с книгами в чате, чтобы перейти на экран с книгой.

## **Платная подписка**

Вы можете пользоваться приложением без оплаты неограниченное время благодаря тем пользователям, которые перешли на платную подписку. Мы тратим деньги:
- на разработку и доработку приложения
- на хостинг и платные API
- на работу дизайнера и продвижение

Вы можете присоедениться к тем пользователям кто оплачивает подписку. Это поможет улучшению Приложения и распространению шэринга книг.  

## **Стать партнёром**

Мы открыты к партнёрству с людьми и организациями. Наша цель распространение шэринга книг и доступность чтения. Свяжитесь со мной в Телеграм - [Денис Старк](https://t.me/DenisStark77)

""", name: 'supportText');
  }

  String get recognitionProgressTitle {
    return Intl.message('Recognition progress', name: 'recognitionProgressTitle');
  }

  String get recognitionProgressNone {
    return Intl.message('Some problem with recofnition. Try again.', name: 'recognitionProgressNone');
  }

  String get recognitionProgressUpload {
    return Intl.message('Uploading image to cloud storage', name: 'recognitionProgressUpload');
  }

  String get recognitionProgressScan {
    return Intl.message('Computer vision scans the image', name: 'recognitionProgressScan');
  }

  String get recognitionProgressOutline {
    return Intl.message('Recognising books outlines', name: 'recognitionProgressOutline');
  }

  String get recognitionProgressCatalogsLookup {
    return Intl.message('Searching books in catalogues', name: 'recognitionProgressCatalogsLookup');
  }

  String get recognitionProgressRescan {
    return Intl.message('Rescaning fragments of the image', name: 'recognitionProgressRescan');
  }

  String get recognitionProgressCompleted {
    return Intl.message('Successfuly completed',
        name: 'recognitionProgressCompleted');
  }

  String get recognitionProgressFailed {
    return Intl.message('We encountered some difficulties with image recognition. Please try later.', name: 'recognitionProgressFailed');
  }

  String get recognitionProgressStore {
    return Intl.message('Storing book records.', name: 'recognitionProgressStore');
  }

  String recognitionProgressBooks(total, recognized) {
    return Intl.message('$recognized books out of $total were recognized',
        name: 'recognitionProgressBooks', args: [total, recognized]);
  }

  String get autoTranslated {
    return Intl.message('* auto translated', name: 'autoTranslated');
  }

  String get autoGenerated {
    return Intl.message('* auto generated', name: 'autoGenerated');
  }

  String booksAvailableForSearch(count, scope) {
    return Intl.message('$count books available $scope',
        name: 'booksAvailableForSearch', args: [count, scope]);
  }

  String get inNeighborhod {
    return Intl.message('in your neigbourhod', name: 'inNeighborhod');
  }

  String get inCity {
    return Intl.message('in your city', name: 'inCity');
  }
  
  String get inCountry {
    return Intl.message('in your country', name: 'inCountry');
  }

  String get onContinent {
    return Intl.message('on your continent', name: 'onContinent');
  }

  String get currentUserSetting {
    return Intl.message('Current user:', name: 'currentUserSetting');
  }

  String get titleBookDetails {
    return Intl.message('BOOK DETAILS', name: 'titleBookDetails');
  }
  
  String get entryGuidanceEmptyBook {
    return Intl.message('Book is missing in catalogs. Please add a photo of a book cover.', name: 'entryGuidanceEmptyBook');
  }
  
  String get entryGuidanceNoCover {
    return Intl.message('Book cover is missing. Please add a photo of a book cover.', name: 'entryGuidanceNoCover');
  }

  String get entryGuidanceCoverButIncomplete {
    return Intl.message('Complete author and title. Copy from book cover or google it using link below.', name: 'entryGuidanceCoverButIncomplete');
  }

  String get entryGuidanceNotComplete {
    return Intl.message('Book information stored. You can also fill other optional fields.', name: 'entryGuidanceNotComplete');
  }

  String get entryGuidanceComplete {
    return Intl.message('Book information completed and stored.', name: 'entryGuidanceComplete');
  }

  String get recognizeCoverFromGallery {
    return Intl.message('Load book cover from a gallery.', name: 'recognizeCoverFromGallery');
  }

  String get recognizeCoverFromCamera {
    return Intl.message('Take a picture of book cover.', name: 'recognizeCoverFromCamera');
  }

  String get recognizeBackFromCamera {
    return Intl.message('Take a picture of a book back.', name: 'recognizeBackFromCamera');
  }

  String get hintAuthor {
    return Intl.message('Enter or copy author(s)', name: 'hintAuthor');
  }

  String get hintTitle {
    return Intl.message('Enter or copy title', name: 'hintTitle');
  }

  String get labelLanguage {
    return Intl.message('Language:', name: 'labelLanguage');
  }

  String get labelGenre {
    return Intl.message('Genre:', name: 'labelGenre');
  }

  String get labelDescription {
    return Intl.message('Description:', name: 'labelDescription');
  }

  String get labelUserTags {
    return Intl.message('User tags:', name: 'labelUserTags');
  }

  String get labelCoverText {
    return Intl.message('Cover text (copy-paste to author/title):', name: 'labelCoverText');
  }

  String get clickToGoogleBook {
    return Intl.message('Link to search details of this book on Google', name: 'clickToGoogleBook');
  }

  String get hintDescription {
    return Intl.message('Copy paste a description from Internet or make a photo of a book back', name: 'hintDescription');
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

