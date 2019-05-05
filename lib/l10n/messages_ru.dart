// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
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
  get localeName => 'ru';

  static m0(count) => "${Intl.plural(count, zero: 'Нет книг', one: '${count} книга', other: '${count} книг')}";

  static m1(lang) => "Язык: ${lang}";

  static m2(name, title) => "Книга \'${title}\' принадлежит пользователю \'${name}\'. Нажмите кнопку \"Отгрузка\" ниже, чтобы сообщить о возврате книги.";

  static m3(name, title) => "Пользователь \'${name}\' предлагает вам книгу \'${title}\'. Пожалуйста, договоритесь о встрече и подтвердите получение книги. Или откажитесь, если вы не заинтересованы.";

  static m4(name, title) => "Пользователь \'${name}\' подтвердил ваш запрос книги \'${title}\'. Договоритесь о встрече и подтвердите получение книги при получении.";

  static m5(name, title) => "Дождитесь пока пользователь \'${name}\' подтвердит ваш запрос книги \'${title}\'. Спишитесь, чтобы договориться.";

  static m6(name, title) => "Пользователь \'${name}\' отклонил ваш запрос книги \'${title}\'. Вы можете написать ему, чтобы уточнить причину.";

  static m7(name, title) => "Пользователь \'${name}\' хочет вернуть вашу книгу \'${title}\'. Пожалуйста, договоритесь о встрече.";

  static m8(name, title) => "Ваша книга \'${title}\' сейчас у пользователя \'${name}\'. Спишитесь, чтобы напомнить о возвращении книги.";

  static m9(name, title) => "Вы предложили книгу \'${title}\' пользователю \'${name}\'. Спишитесь, чтобы договориться о передаче книги.";

  static m10(name, title) => "Пользователь \'${name}\' подтвердил получение книги \'${title}\'. Книга добавлена в ваши \"Отданные книги\".";

  static m11(name, title) => "Пользователь \'${name}\' отказался от предложенной вами книги \'${title}\'. Вы можете списаться, чтобы уточнить причину.";

  static m12(name, title) => "Пользователь \'${name}\' запросил вашу книгу \'${title}\'. Пожалуйста, подтвердите или откажите. Спишитесь, чтобы познакомиться и договориться.";

  static m13(name, title) => "Передайте книгу \'${title}\' пользователю \'${name}\'. Спишитесь, чтобы договориться.";

  static m14(name, title) => "Пользователь \'${name}\' отменил запрос на вашу книгу \'${title}\'.";

  static m15(name, title) => "Пользователь \'${name}\' подтвердил получение книги \'${title}\'. Книга добавлена в ваши \"Взятые книги\".";

  static m16(name, title) => "Передайте книгу \'${title}\' пользователю \'${name}\'. Спишитесь, чтобы договориться.";

  static m17(name, title) => "Пользователь \'${name}\' подтвердил получение книги \'${title}\'.";

  static m18(count) => "${Intl.plural(count, zero: 'Нет полок', one: '${count} полка', other: '${count} полок')}";

  static m19(balance) => "Баланс ${balance} λ";

  static m20(count) => "${Intl.plural(count, zero: 'Нет желанных книг', one: '${count} желанная книга', other: '${count} желанных книг')}";

  static m21(name, title) => "${name} хочет почитать Вашу книгу \'${title}\'";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "add" : MessageLookupByLibrary.simpleMessage("Добавить"),
    "addShelf" : MessageLookupByLibrary.simpleMessage("Добавить книжную полку"),
    "addToCart" : MessageLookupByLibrary.simpleMessage("Добавить в корзину"),
    "addToOutbox" : MessageLookupByLibrary.simpleMessage("Добавить в отгрузку"),
    "addToWishlist" : MessageLookupByLibrary.simpleMessage("Добавить желаемую книгу"),
    "addYourBook" : MessageLookupByLibrary.simpleMessage("Добавить свою книгу"),
    "addYourBookshelf" : MessageLookupByLibrary.simpleMessage("Добавьте вашу полку"),
    "blockUser" : MessageLookupByLibrary.simpleMessage("Заблокировать пользователя"),
    "blockedChat" : MessageLookupByLibrary.simpleMessage("Пользователь заблокирован"),
    "bookAdded" : MessageLookupByLibrary.simpleMessage("Книга была добавлена в ваш каталог"),
    "bookCount" : m0,
    "bookDeleted" : MessageLookupByLibrary.simpleMessage("Книга была удалена из вашего каталога"),
    "bookLanguage" : m1,
    "books" : MessageLookupByLibrary.simpleMessage("Книги"),
    "bookshelves" : MessageLookupByLibrary.simpleMessage("Полки"),
    "borrow" : MessageLookupByLibrary.simpleMessage("Возьми"),
    "borrowedBookText" : m2,
    "cart" : MessageLookupByLibrary.simpleMessage("Книги, которые вы берёте"),
    "cartOfferConfirmReject" : m3,
    "cartRequestAccepted" : m4,
    "cartRequestCancel" : m5,
    "cartRequestRejected" : m6,
    "cartReturnConfirm" : m7,
    "chat" : MessageLookupByLibrary.simpleMessage("ЧАТ"),
    "confirmBlockUser" : MessageLookupByLibrary.simpleMessage("Заблокировать пользователя?"),
    "confirmReportPhoto" : MessageLookupByLibrary.simpleMessage("Пожаловаться на фото?"),
    "deleteShelf" : MessageLookupByLibrary.simpleMessage("Удалить полку"),
    "drawerHeader" : MessageLookupByLibrary.simpleMessage("Выбери режим"),
    "earn" : MessageLookupByLibrary.simpleMessage("Заработай"),
    "enterTitle" : MessageLookupByLibrary.simpleMessage("Начните вводить автора и/или название"),
    "explore" : MessageLookupByLibrary.simpleMessage("Исследовать"),
    "favorite" : MessageLookupByLibrary.simpleMessage("Добавить полку в избранное"),
    "importToBooks" : MessageLookupByLibrary.simpleMessage("Загрузить в список моих книг:"),
    "importToWishlist" : MessageLookupByLibrary.simpleMessage("Загрузить в список желаемых книг:"),
    "importYouBooks" : MessageLookupByLibrary.simpleMessage("Загрузи книги в Библосферу"),
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
    "lentBookText" : m8,
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
    "messageOwner" : MessageLookupByLibrary.simpleMessage("Написать владельцу"),
    "messageRecepient" : MessageLookupByLibrary.simpleMessage("Спишись с получателем книги."),
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
    "no" : MessageLookupByLibrary.simpleMessage("Нет"),
    "noBooks" : MessageLookupByLibrary.simpleMessage("У Вас ни одной книги в Библосфере. Добавьте их вручную или загрузите из Goodreads."),
    "noBookshelves" : MessageLookupByLibrary.simpleMessage("У Вас ни одной книжной полки в Библосфере. Сделайте фото вашей полки, чтобы на ваши книги могли посмотреть."),
    "noBorrowedBooks" : MessageLookupByLibrary.simpleMessage("У вас нет взятых книг"),
    "noItemsInCart" : MessageLookupByLibrary.simpleMessage("Ваша корзина пуста. Добавьте книги из списка доступных книг или избранного."),
    "noItemsInOutbox" : MessageLookupByLibrary.simpleMessage("Ваша отгрузка пуста. Подождите пока кто-нибудь запросит ваши книги или предложите вашу книгу во вкладке \"Поделись\"."),
    "noLendedBooks" : MessageLookupByLibrary.simpleMessage("У вас нет отданных книг"),
    "noMatchForBooks" : MessageLookupByLibrary.simpleMessage("Здесь Вы увидите людей, кто хочет почитать Ваши книги, как только они появятся. Чтобы это произошло, добавьте больше книг и расскажите о Библосфере друзьям."),
    "noMatchForWishlist" : MessageLookupByLibrary.simpleMessage("К сожалению, пока никто не добавил книг, которые Вы хотите прочитать. Вы их увидите здесь, как только их добавят.\nРасскажите о Библосфере, чтобы это произошло быстрее. И добавьте больше книг в ваш список для прочтения."),
    "noWishes" : MessageLookupByLibrary.simpleMessage("У Вас ни одной книги в списке для прочтения. Добавьте их вручную или загрузите из Goodreads."),
    "notBooks" : MessageLookupByLibrary.simpleMessage("Опа, это не похоже на книги."),
    "nothingToSend" : MessageLookupByLibrary.simpleMessage("Нечего отправить"),
    "ok" : MessageLookupByLibrary.simpleMessage("Ок"),
    "outbox" : MessageLookupByLibrary.simpleMessage("Книги, которые вы отдаёте"),
    "outboxOfferAccepted" : m9,
    "outboxOfferConfirmed" : m10,
    "outboxOfferRejected" : m11,
    "outboxRequestAcceptReject" : m12,
    "outboxRequestAccepted" : m13,
    "outboxRequestCanceled" : m14,
    "outboxRequestConfirmed" : m15,
    "outboxReturnAccepted" : m16,
    "outboxReturnConfirmed" : m17,
    "people" : MessageLookupByLibrary.simpleMessage("Люди"),
    "read" : MessageLookupByLibrary.simpleMessage("Читать"),
    "recentWishes" : MessageLookupByLibrary.simpleMessage("Хочет почитать:"),
    "reportShelf" : MessageLookupByLibrary.simpleMessage("Сообщить о незаконном содержимом"),
    "reportedPhoto" : MessageLookupByLibrary.simpleMessage("Это фото отмечено как запрещённое."),
    "scanISBN" : MessageLookupByLibrary.simpleMessage("Сканировать ISBN с обложки книги"),
    "seeLocation" : MessageLookupByLibrary.simpleMessage("Перейти в карты"),
    "settings" : MessageLookupByLibrary.simpleMessage("Настройки"),
    "share" : MessageLookupByLibrary.simpleMessage("Поделись"),
    "shareBooks" : MessageLookupByLibrary.simpleMessage("Я делюсь книгами через Библосферу. Присоединяйся!"),
    "shareBookshelf" : MessageLookupByLibrary.simpleMessage("Эта моя книжная полка. Заходи в Библосферу, чтобы делиться книгами и знакомиться с читающими людьми."),
    "shareShelf" : MessageLookupByLibrary.simpleMessage("Поделиться фотографией полки"),
    "shareWishlist" : MessageLookupByLibrary.simpleMessage("Я публикую в Библосфере список книг, которые хочу почитать. А ты?"),
    "shelfAdded" : MessageLookupByLibrary.simpleMessage("Новая книжная полка добавлена"),
    "shelfCount" : m18,
    "shelfDeleted" : MessageLookupByLibrary.simpleMessage("Книжная полка была удалена"),
    "shelfSettings" : MessageLookupByLibrary.simpleMessage("Настройки книжной полки"),
    "shelves" : MessageLookupByLibrary.simpleMessage("Полки"),
    "title" : MessageLookupByLibrary.simpleMessage("Библосфера"),
    "transitAccept" : MessageLookupByLibrary.simpleMessage("Принять"),
    "transitCancel" : MessageLookupByLibrary.simpleMessage("Отменить"),
    "transitConfirm" : MessageLookupByLibrary.simpleMessage("Подтвердить"),
    "transitInitiated" : MessageLookupByLibrary.simpleMessage("Вы запустили процесс передачи книги"),
    "transitOk" : MessageLookupByLibrary.simpleMessage("Ок"),
    "transitReject" : MessageLookupByLibrary.simpleMessage("Отклонить"),
    "typeMsg" : MessageLookupByLibrary.simpleMessage("Наберите сообщение..."),
    "useCurrentLocation" : MessageLookupByLibrary.simpleMessage("Использовать текущее местоположение для загрузки"),
    "userBalance" : m19,
    "welcome" : MessageLookupByLibrary.simpleMessage("Добро пожаловать"),
    "wishAdded" : MessageLookupByLibrary.simpleMessage("Книга была добавлена в список желаемых книг"),
    "wishCount" : m20,
    "wishDeleted" : MessageLookupByLibrary.simpleMessage("Книга была удалена из списка желаемых книг"),
    "wishToRead" : m21,
    "wished" : MessageLookupByLibrary.simpleMessage("Избранное"),
    "yourBiblosphere" : MessageLookupByLibrary.simpleMessage("Моя Библосфера"),
    "yourGoodreads" : MessageLookupByLibrary.simpleMessage("Ваш Goodreads"),
    "zoom" : MessageLookupByLibrary.simpleMessage("УВЕЛИЧИТЬ")
  };
}
