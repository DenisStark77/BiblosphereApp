import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis/books/v1.dart';
import 'package:geolocator/geolocator.dart';
import 'package:xml/xml.dart' as xml;

class BiblosphereColorScheme {
  Color titleBackground = new Color(0xff344d64);
  Color titleText = Colors.black;
  Color background = new Color(0xfff4f4f3);
  Color cardBackground = new Color(0xffebe1e1);
  Color bar = new Color(0xffcbc1c4);
  Color button = new Color(0xffd3c0c0);
  Color buttonText = Colors.white;
  Color chatMy = new Color(0xffdedede);
  Color chatMyText = Colors.black;
  Color chatHis = new Color(0xff344d64); // new Color(0xff829fb9);
  Color chatHisText = Colors.black; // new Color(0xff829fb9);
//  Color chipSelected = new Color(0xff6789a8);
//  Color chipUnselected = new Color(0xffdedede);
  Color chipSelected = new Color(0xffdedede);
  Color chipUnselected = new Color(0xff6789a8);
  Color chipText = Colors.white;
  Color inputHints = Colors.black;
  TextStyle hints = TextStyle(
      fontSize: 20.0, fontWeight: FontWeight.w300, fontStyle: FontStyle.italic);

  BiblosphereColorScheme(
      {this.titleBackground,
      this.titleText,
      this.background,
      this.cardBackground,
      this.bar,
      this.button,
      this.buttonText,
      this.chatMy,
      this.chatMyText,
      this.chatHis,
      this.chatHisText,
      this.chipSelected,
      this.chipUnselected,
      this.chipText,
      this.inputHints});
}

BiblosphereColorScheme C = new BiblosphereColorScheme(
  titleBackground: Color(0xff8eaac3), //0xff344d64),
  titleText: Colors.black, //0xff344d64),
  // titleBackground: Color(0xffb5ced6), nice light blue
  background: Color(0xffdeedf9),
  // background: Color(0xfff4f4f3), almost white
  cardBackground: Color(0xfff4f4f3),
  // cardBackground: Color(0xffd8dede), // cold grey
  bar: Color(0xffebe1e1),
  button: Color(0xff6789a8),
  buttonText: Colors.white,
  //button: Color(0xffc7d2d1),
  chatMy: Color(0xffd8dede),
  chatMyText: Colors.black,
  // chatMy: Color(0xffbde1de),
  chatHis: Colors.white,
  chatHisText: Colors.black,
  //chatHis: Color(0xffb2c7cb),
  chipSelected: Color(0xff6789a8),
  //chipSelected: Color(0xffc4c4c4), // pinkish grey
  chipUnselected: Color(0xffdeedf9),
  chipText: Colors.black,
  inputHints: Colors.black,
  //chipUnselected: Color(0xffe3e6e5)
);

Firestore db = Firestore.instance;

const String sharingUrl =
    'https://biblosphere.org/images/phone-app-screens-2000.png';

const String nocoverUrl =
    'https://firebasestorage.googleapis.com/v0/b/biblosphere-210106.appspot.com/o/images%2Fnocover.png?alt=media&token=fb68e614-d34e-4b47-bf2c-47e742b4786d';

String getTimestamp() => new DateTime.now().millisecondsSinceEpoch.toString();

//const AssetImage add_book_500 = AssetImage('images/icons/icons8-add-book-500.png');
const String add_book_100 = 'images/icons/icons8-add-book-100.png';
const String books_100 = 'images/icons/icons8-books-100.png';
const String search_100 = 'images/icons/icons8-search-100.png';
const String communication_100 = 'images/icons/icons8-communication-100.png';
const String wallet_100 = 'images/icons/icons8-wallet-100.png';
const String coins_100 = 'images/icons/icons8-coins-100.png';
const String barcode_scanner_100 =
    'images/icons/icons8-barcode-scanner-100.png';
const String shopping_cart_100 = 'images/icons/icons8-shopping-cart-100.png';
const String online_support_100 = 'images/icons/icons8-online-support-100.png';
const String technical_support_100 =
    'images/icons/icons8-technical-support-100.png';
const String handshake_100 = 'images/icons/icons8-handshake-100.png';
const String exit_100 = 'images/icons/icons8-exit-100.png';
const String settings_100 = 'images/icons/icons8-settings-100.png';
const String add_100 = 'images/icons/icons8-add-100.png';
const String cancel_100 = 'images/icons/icons8-cancel-100.png';
const String return_100 = 'images/icons/icons8-return-100.png';
const String trash_100 = 'images/icons/icons8-trash-100.png';
const String share_100 = 'images/icons/icons8-share-100.png';
const String bank_cards_100 = 'images/icons/icons8-bank-cards-100.png';
const String receive_cash_100 = 'images/icons/icons8-receive-cash-100.png';
const String unavailable_100 = 'images/icons/icons8-unavailable-100.png';
const String sent_100 = 'images/icons/icons8-sent-100.png';
const String filter_100 = 'images/icons/icons8-filter-100.png';
const String clear_filters_100 = 'images/icons/icons8-clear-filters-100.png';

Widget assetIcon(String asset, {double size}) {
  if (size != null)
    return Container(
        width: size,
        height: size,
        child: Image.asset(asset, fit: BoxFit.contain));
  else
    return Image.asset(asset, fit: BoxFit.contain);
}

Widget drawerMenuItem(BuildContext context, String text, String icon,
    {double size}) {
  return Row(children: <Widget>[
    assetIcon(icon, size: size),
    Container(
        margin: EdgeInsets.only(left: 10.0),
        child: Text(text, style: Theme.of(context).textTheme.body1)),
  ]);
}

/*
class MyIcons {
  static const fontFamily = 'MyIcons';

  static const IconData add = const IconData(0xf208, fontFamily: fontFamily);
  static const IconData arrow_left =
      const IconData(0xf116, fontFamily: fontFamily);
  static const IconData arrow_right =
      const IconData(0xf117, fontFamily: fontFamily);
  static const IconData envelop =
      const IconData(0xf1cd, fontFamily: fontFamily);
  static const IconData cancel_cross =
      const IconData(0xf161, fontFamily: fontFamily);
  static const IconData cancel_cross2 =
      const IconData(0xf13a, fontFamily: fontFamily);
  static const IconData cancel_cross3 =
      const IconData(0xf13b, fontFamily: fontFamily);
  static const IconData checkmark =
      const IconData(0xf140, fontFamily: fontFamily);
  static const IconData face = const IconData(0xf131, fontFamily: fontFamily);
  static const IconData library =
      const IconData(0xf107, fontFamily: fontFamily);
  static const IconData mobile = const IconData(0xf1fd, fontFamily: fontFamily);
  static const IconData money = const IconData(0xf14d, fontFamily: fontFamily);
  static const IconData plus = const IconData(0xf208, fontFamily: fontFamily);
  static const IconData plus1 = const IconData(0xf102, fontFamily: fontFamily);
  static const IconData returning =
      const IconData(0xf21d, fontFamily: fontFamily);
  static const IconData settings =
      const IconData(0xf14c, fontFamily: fontFamily);
  static const IconData book = const IconData(0xf12c, fontFamily: fontFamily);
  static const IconData navigation =
      const IconData(0xf14e, fontFamily: fontFamily);
  static const IconData navigation1 =
      const IconData(0xf1c5, fontFamily: fontFamily);
  static const IconData navigation2 =
      const IconData(0xf1d0, fontFamily: fontFamily);
  static const IconData hand_pointer_o =
      const IconData(0xf25a, fontFamily: fontFamily);
  static const IconData exit = const IconData(0xf17c, fontFamily: fontFamily);
  static const IconData heart = const IconData(0xf19b, fontFamily: fontFamily);
  static const IconData heart1 = const IconData(0xf1c8, fontFamily: fontFamily);
  static const IconData home = const IconData(0xf19f, fontFamily: fontFamily);
  static const IconData share = const IconData(0xf18b, fontFamily: fontFamily);
  static const IconData share1 = const IconData(0xf1e7, fontFamily: fontFamily);
  static const IconData barcode =
      const IconData(0xf149, fontFamily: fontFamily);
  static const IconData chat = const IconData(0xf13f, fontFamily: fontFamily);
  static const IconData message =
      const IconData(0xf13e, fontFamily: fontFamily);
  static const IconData filter = const IconData(0xf18f, fontFamily: fontFamily);
  static const IconData trash = const IconData(0xf259, fontFamily: fontFamily);
  static const IconData search = const IconData(0xf1cc, fontFamily: fontFamily);
  static const IconData thumbdown =
      const IconData(0xf16c, fontFamily: fontFamily);
  static const IconData thumbup =
      const IconData(0xf1be, fontFamily: fontFamily);
  static const IconData flag = const IconData(0xf188, fontFamily: fontFamily);
  static const IconData camera = const IconData(0xf1ac, fontFamily: fontFamily);
  static const IconData cart = const IconData(0xf232, fontFamily: fontFamily);
  static const IconData girl = const IconData(0xf283, fontFamily: fontFamily);
  static const IconData boy = const IconData(0xf131, fontFamily: fontFamily);
  static const IconData globe = const IconData(0xf284, fontFamily: fontFamily);
  static const IconData people = const IconData(0xf274, fontFamily: fontFamily);
  static const IconData plane = const IconData(0xf1f6, fontFamily: fontFamily);
  static const IconData idea = const IconData(0xf1bd, fontFamily: fontFamily);
  static const IconData other = const IconData(0xf190, fontFamily: fontFamily);
  static const IconData stop = const IconData(0xf13a, fontFamily: fontFamily);
  static const IconData chain = const IconData(0xf1bf, fontFamily: fontFamily);
  static const IconData open = const IconData(0xf173, fontFamily: fontFamily);
  static const IconData synch = const IconData(0xf15b, fontFamily: fontFamily);
  static const IconData galery = const IconData(0xf201, fontFamily: fontFamily);
  static const IconData given = const IconData(0xf1e9, fontFamily: fontFamily);
  static const IconData taken = const IconData(0xf273, fontFamily: fontFamily);
  static const IconData outbox = const IconData(0xf1ee, fontFamily: fontFamily);
  static const IconData wishlist =
      const IconData(0xf193, fontFamily: fontFamily);
}

*/

enum BookSource { none, google, goodreads }

class Book {
  String title;
  List<String> authors;
  String isbn;
  String image;
  double price = 0.0;
  Set<String> keys;
  bool userImage = false; // flag that image are loaded by users
  String sourceId;
  int copies = 0;
  int wishes = 0;
  BookSource source = BookSource.none;
  // Price in original currency from the platforms
  Price listPrice;
  String genre;
  String language;

  Book({
    @required this.title,
    @required this.authors,
    @required this.isbn,
    this.image,
    this.userImage,
    this.sourceId,
    this.source = BookSource.none,
    this.price,
    this.listPrice,
    this.genre,
    this.language,
  }) {
    keys = getKeys(' ' + authors.join(' ') + ' ' + title + ' ' + isbn);
  }

  //TODO: Add price, genre, language
  Book.volume(Volume v) {
    try {
      if (v.volumeInfo?.imageLinks != null)
        image = v.volumeInfo.imageLinks.thumbnail;
      title = v.volumeInfo?.title;
      authors = v.volumeInfo?.authors;
      language = v.volumeInfo?.language;
      //TODO: what if ISBN_13 missing?
      var industryIds = v.volumeInfo?.industryIdentifiers;
      if (industryIds != null) {
        var isbnId = industryIds.firstWhere((test) => test.type == 'ISBN_13',
            orElse: () => null);
        if (isbnId != null) isbn = isbnId.identifier;
      }
      if (v.saleInfo?.listPrice != null)
        listPrice = new Price(
            amount: v.saleInfo.listPrice.amount,
            currency: v.saleInfo.listPrice.currencyCode);
      source = BookSource.google;
      keys = getKeys(' ' + authors.join(' ') + ' ' + title + ' ' + isbn);
    } catch (e) {
      print('Unknown error in Book.volume: $e');
    }
  }

  //TODO: Add price, genre, language
  Book.goodreads(xml.XmlElement xml) {
//      isbn = xml.findElements("isbn13")?.first?.text?.toString();
    sourceId = xml.findElements("id")?.first?.text?.toString();
    var isbnXml = xml.findElements("isbn13");
    if (isbnXml != null && isbnXml.isNotEmpty)
      isbn = isbnXml.first?.text?.toString();
    if (isbn == null) isbn = 'NA';
    title = xml.findElements("title")?.first?.text?.toString();
    if (title.contains(':')) title = title.substring(0, title.indexOf(':'));
    image = xml.findElements("image_url")?.first?.text?.toString();
    if (image.contains('nophoto')) image = '';
    authors = [];
    xml.findAllElements("author").forEach(
        (a) => authors.add(a.findElements("name")?.first?.text?.toString()));
    source = BookSource.goodreads;
    keys = getKeys(' ' + authors.join(' ') + ' ' + title + ' ' + isbn);
  }

  Book.fromJson(Map json)
      : title = json['title'],
        authors = (json['authors'] as List)?.cast<String>(),
        isbn = json['isbn'],
        image = json['image'],
        userImage = json['userImage'] ?? false,
        sourceId = json['sourceId'],
        source = json['source'] is int
            ? BookSource.values.elementAt(json['source'] ?? 0)
            : BookSource.none,
        copies = json['copies'] ?? 0,
        wishes = json['wishes'] ?? 0,
        price = json['price'],
        language = json['language'],
        keys = (json['keys'] as List)?.cast<String>()?.toSet(),
        listPrice = json['listPrice'] != null
            ? new Price.fromJson(json['listPrice'])
            : null,
        genre = json['genre'] {
    if (keys == null) {
      keys = getKeys((authors != null ? authors.join(' ') : '') +
          ' ' +
          (title != null ? title : '') +
          ' ' +
          (isbn != null ? isbn : ''));
    }
  }

  Map<String, dynamic> toJson() {
    // Do not store copies & wishes. It's updated separatley.
    return {
      'title': title,
      'authors': authors,
      'isbn': isbn,
      'image': image,
      'userImage': userImage,
      'sourceId': sourceId,
      'source': source?.index,
      'price': price,
      'listPrice': listPrice?.toJson(),
      'genre': genre,
      'keys': keys.toList(),
      'language': language
    };
  }

  double getPrice() {
    return price;
  }

  @override
  operator ==(other) {
    if (other is! Book) {
      return false;
    }
    return isbn == (other as Book).isbn;
  }

  int _hashCode;
  @override
  int get hashCode {
    if (_hashCode == null) {
      _hashCode = isbn.hashCode;
    }
    return _hashCode;
  }

  DocumentReference get ref {
    assert(isbn != null);
    return db.collection('books').document(isbn);
  }

  static DocumentReference Ref(String isbn) {
    return db.collection('books').document(isbn);
  }
}

class User {
  String id;
  String name;
  String photo;
  String currency;
  // Fields for referral program. Referral Link and two persons to split fee to
  String link;
  String beneficiary1;
  double feeShared;
  String beneficiary2;
  GeoPoint position;
  int wishCount = 0;
  int bookCount = 0;
  int shelfCount = 0;
  double balance = 0;
  double blocked = 0;
  String payoutId;
  String cursor;
  double d;

  User(
      {@required this.name,
      @required this.photo,
      this.id,
      this.currency,
      this.position,
      this.balance = 0,
      this.blocked = 0,
      this.bookCount,
      this.shelfCount,
      this.wishCount,
      this.link,
      this.beneficiary1,
      this.beneficiary2,
      this.payoutId}) {
    if (id == null) id = Ref().documentID;
  }

  User.fromJson(Map json)
      : id = json['id'],
        name = json['name'],
        photo = json['photo'] ?? json['photoUrl'],
        currency = json['currency'],
        link = json['link'],
        beneficiary1 = json['beneficiary1'],
        beneficiary2 = json['beneficiary2'],
        feeShared = json['feeShared'] != null
            ? (json['feeShared'] as num).toDouble()
            : 0,
        position = json['position'] as GeoPoint,
        wishCount = json['wishCount'] ?? 0,
        bookCount = json['bookCount'] ?? 0,
        shelfCount = json['shelfCount'] ?? 0,
        balance =
            json['balance'] != null ? (json['balance'] as num).toDouble() : 0,
        blocked =
            json['blocked'] != null ? (json['blocked'] as num).toDouble() : 0,
        cursor = json['cursor'],
        payoutId = json['payoutId'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photo': photo,
      'currency': currency,
      'link': link,
      'beneficiary1': beneficiary1,
      'beneficiary2': beneficiary2,
      'position': position,
      'wishCount': wishCount,
      'bookCount': bookCount,
      'shelfCount': shelfCount,
      'payoutId': payoutId,
      // Not include balance, blocked, cursor and feeShared here. ONLY direct updates for these fields!!!
    };
  }

  double getAvailable() {
    return balance - blocked;
  }

  /*
  // Retrieve balance from Stellar account
  Future<double> getStellarBalance() async {
    if (accountId == null) return 0.0;

    stellar.KeyPair pair = stellar.KeyPair.fromAccountId(accountId);

    stellar.Network.useTestNetwork();
    stellar.Server server =
        stellar.Server("https://horizon-testnet.stellar.org");
    stellar.AccountResponse account = await server.accounts.account(pair);
    String strBalance = account.balances
        .where((bal) => bal.assetType == "native")
        .first
        .balance;

    balance = double.parse(strBalance);
    return balance;
  }
  */
  DocumentReference get ref {
    return db.collection('users').document(id);
  }

  static DocumentReference Ref([String id = null]) {
    if (id != null)
      return db.collection('users').document(id);
    else
      return db.collection('users').document();
  }
}

enum BookrecordType { none, own, wish, lent, borrowed, transit }

class Bookrecord {
  String id;

  // Book details (inherited from book)
  String isbn;
  String title;
  List<String> authors;
  String image;
  double price = 0.0;
  Set<String> keys;

  String ownerId;
  String ownerName;
  String holderId;
  String holderName;
  String transitId;
  String rewardId;
  String leasingId;
  // Both users owner and holder to use array-contains instead of OR
  Set<String> users;
  // Daily rent and full price
  // Status of the book copy
  bool transit = false;
  bool confirmed = false; // indicate that transit confirmed by giving party
  bool wish = false;
  bool lent = false;
  // If book are matched (wish and available book)
  bool matched = false;
  String matchedId;
  // Chat id there book transit is discussed
  String chatId;
  // Position of the book and distance to the closest match
  GeoFirePoint location;
  double distance;

  Bookrecord(
      {@required this.ownerId,
      this.ownerName,
      @required this.isbn,
      this.title,
      this.authors,
      this.image,
      this.location,
      this.holderId,
      this.holderName,
      this.transitId,
      this.rewardId,
      this.leasingId,
      this.price,
      this.matched = false,
      this.matchedId,
      this.wish = false,
      this.lent = false,
      this.transit = false,
      this.confirmed = false,
      this.chatId,
      this.distance}) {
    if (holderId == null) {
      holderId = ownerId;
      holderName = ownerName;
    }
    if (id == null) id = this.ref.documentID;
    if (!transit) confirmed = false;
    if (keys == null) {
      keys = getKeys((authors != null ? authors.join(' ') : '') +
          ' ' +
          (title != null ? title : '') +
          ' ' +
          (isbn != null ? isbn : ''));
    }
  }

  Bookrecord.fromJson(Map json)
      : id = json['id'],
        title = json['title'],
        authors = (json['authors'] as List)?.cast<String>(),
        image = json['image'],
        keys = (json['keys'] as List)?.cast<String>()?.toSet(),
        ownerId = json['ownerId'],
        ownerName = json['ownerName'],
        holderId = json['holderId'],
        holderName = json['holderName'],
        transitId = json['transitId'],
        //users = (json['users']?.map((s) => s as String))?.toSet(),
        //users = (json['users']?.map((dynamic s) => s.toString()))?.toSet(),
        users = (json['users'] as List).cast<String>().toSet(),
        isbn = json['isbn'],
        rewardId = json['rewardId'],
        leasingId = json['leasingId'],
        location = json['location'] != null
            ? Geoflutterfire().point(
                latitude: json['location']['geopoint'].latitude,
                longitude: json['location']['geopoint'].longitude)
            : null,
        matched = json['matched'] ?? false,
        matchedId = json['matchedId'],
        lent = json['lent'] ?? false,
        wish = json['wish'] ?? false,
        transit = json['transit'] ?? false,
        confirmed = (json['transit'] ?? false) && (json['confirmed'] ?? false),
        price = json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
        chatId = json['chatId'] {
    if (location != null && lastKnownPosition != null)
      distance = distanceBetween(location.latitude, location.longitude,
          lastKnownPosition.latitude, lastKnownPosition.longitude);
    else
      distance = double.infinity;
    if (keys == null) {
      keys = getKeys((authors != null ? authors.join(' ') : '') +
          ' ' +
          (title != null ? title : '') +
          ' ' +
          (isbn != null ? isbn : ''));
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'holderId': holderId,
      'holderName': holderName,
      'transitId': transitId,
      'rewardId': rewardId,
      'leasingId': leasingId,
      'users': <String>{ownerId, holderId, transitId}
          .where((s) => s != null)
          .toList(),
      'isbn': isbn,
      'location': location?.data,
      'matched': matched,
      'matchedId': matchedId,
      'chatId': transit ? chatId : null,
      'lent': lent,
      'wish': wish,
      'transit': transit,
      'confirmed': confirmed,
      'price': price,
      'distance': distance,
      'title': title,
      'authors': authors,
      'isbn': isbn,
      'image': image,
      'keys': keys.toList(),
    };
  }

  bool isOwn(String userId) {
    return ownerId == userId && !transit && !lent && !wish;
  }

  bool isWish(String userId) {
    return ownerId == userId && wish && !transit && !lent;
  }

  bool isLent(String userId) {
    return ownerId == userId &&
        ownerId != holderId &&
        lent &&
        !wish &&
        (!transit || transitId != ownerId);
  }

  bool isBorrowed(String userId) {
    return holderId == userId &&
        ownerId != holderId &&
        lent &&
        !wish &&
        !transit;
  }

  bool isTransit(String userId) {
    return (transitId == userId || holderId == userId) && transit && !wish;
  }

  bool isConfirmed(String userId) {
    return (transitId == userId || holderId == userId) &&
        transit &&
        confirmed &&
        !wish;
  }

  BookrecordType type(String userId) {
    if (isOwn(userId))
      return BookrecordType.own;
    else if (isLent(userId))
      return BookrecordType.lent;
    else if (isBorrowed(userId))
      return BookrecordType.borrowed;
    else if (isTransit(userId))
      return BookrecordType.transit;
    else if (isWish(userId))
      return BookrecordType.wish;
    else
      return BookrecordType.none;
  }

  double getPrice() {
    // If price is null or 0 return default price
    return price != null && price != 0.0 ? price : 100;
  }

  DocumentReference get ref {
    assert(ownerId != null && isbn != null && wish != null);
    return db
        .collection('bookrecords')
        .document((wish ? 'w' : 'b') + ':' + ownerId + ':' + isbn);
  }

  static DocumentReference Ref(String id) {
    return db.collection('bookrecords').document(id);
  }
}

class Price {
  double amount;
  String currency;

  Price({@required this.amount, @required this.currency});

  Price.fromJson(Map json)
      : amount = json['amount'] as double,
        currency = json['currency'];

  Map<String, dynamic> toJson() {
    return {'amount': amount, 'currency': currency};
  }
}

// Only add values at the end. It's stored in DB as index
enum OperationType {
  None,
  InputInApp,
  InputStellar,
  OutputStellar,
  Leasing,
  Reward,
  Buy,
  Sell
}

class Operation {
  String id;
  OperationType type;
  Set<String> users;
  String userId;
  double amount;
  DateTime date;
  // InputInApp & InputStellar & OutputStellar
  String transactionId;
  // InputStellar
  String proxyTransactionId;
  // Leasing/Buy & Reward/Sell
  String peerId;
  String bookrecordId;
  String isbn;
  double price;
  DateTime start;
  DateTime end;
  double paid;
// Leasing/Buy
  double deposit; // Amount deposited as guaranty
  double fee; // Biblosphere system fee
  double ownerFee1; // Referral fee
  double ownerFee2; // Referral fee
  double payerFee1; // Referral fee
  double payerFee2; // Referral fee
  String ownerFeeUserId1;
  String ownerFeeUserId2;
  String payerFeeUserId1;
  String payerFeeUserId2;

  Operation(
      {this.id,
      @required this.type,
      @required this.userId,
      @required this.amount,
      @required this.date,
      this.transactionId,
      this.proxyTransactionId,
      this.peerId,
      this.bookrecordId,
      this.isbn,
      this.price,
      this.start,
      this.end,
      this.deposit,
      this.fee,
      this.ownerFee1,
      this.ownerFee2,
      this.payerFee1,
      this.payerFee2,
      this.ownerFeeUserId1,
      this.ownerFeeUserId2,
      this.payerFeeUserId1,
      this.payerFeeUserId2,
      this.paid}) {
    if (id == null) id = db.collection('operations').document().documentID;
  }

  Operation.fromJson(Map json)
      : id = json['id'],
        type = OperationType.values.elementAt(json['type'] ?? 0),
        //users = (json['users']?.map((dynamic s) => s.toString()))?.toSet(),
        users = (json['users'] as List).cast<String>().toSet(),
        userId = json['userId'],
        amount =
            json['amount'] != null ? (json['amount'] as num).toDouble() : 0.0,
        date =
            json['date'] != null ? (json['date'] as Timestamp).toDate() : null,
        transactionId = json['transactionId'],
        proxyTransactionId = json['proxyTransactionId'],
        peerId = json['peerId'],
        isbn = json['isbn'],
        bookrecordId = json['bookrecordId'],
        price = json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
        start = json['start'] != null
            ? (json['start'] as Timestamp).toDate()
            : null,
        end = json['end'] != null ? (json['end'] as Timestamp).toDate() : null,
        deposit =
            json['deposit'] != null ? (json['deposit'] as num).toDouble() : 0.0,
        fee = json['fee'] != null ? (json['fee'] as num).toDouble() : 0.0,
        ownerFee1 = json['ownerFee1'] != null
            ? (json['ownerFee1'] as num).toDouble()
            : 0.0, // Referral fee
        ownerFee2 = json['ownerFee2'] != null
            ? (json['ownerFee2'] as num).toDouble()
            : 0.0, // Referral fee
        payerFee1 = json['payerFee1'] != null
            ? (json['payerFee1'] as num).toDouble()
            : 0.0, // Referral fee
        payerFee2 = json['payerFee2'] != null
            ? (json['payerFee2'] as num).toDouble()
            : 0.0, // Referral fee
        ownerFeeUserId1 = json['ownerFeeUserId1'],
        ownerFeeUserId2 = json['ownerFeeUserId2'],
        payerFeeUserId1 = json['payerFeeUserId1'],
        payerFeeUserId2 = json['payerFeeUserId2'],
        paid = json['paid'] != null ? (json['paid'] as num).toDouble() : 0.0;

  Map<String, dynamic> toJson() {
    Set<String> users = {};
    Map<String, dynamic> json = {
      'id': id,
      'type': type?.index,
      'userId': userId,
      'amount': amount,
      'date': date != null ? Timestamp.fromDate(date) : null
    };

    if (userId != null) users.add(userId);

    if (type == OperationType.InputInApp ||
        type == OperationType.InputStellar ||
        type == OperationType.OutputStellar)
      json.addAll({'transactionId': transactionId});

    if (type == OperationType.InputStellar)
      json.addAll({'proxyTransactionId': proxyTransactionId});

    if (type == OperationType.Leasing ||
        type == OperationType.Buy ||
        type == OperationType.Reward ||
        type == OperationType.Sell) {
      json.addAll({
        'peerId': peerId,
        'bookrecordId': bookrecordId,
        'isbn': isbn,
        'price': price,
        'start': start != null ? Timestamp.fromDate(start) : null,
        'end': end != null ? Timestamp.fromDate(end) : null,
        'paid': paid,
      });

      if (peerId != null) users.add(peerId);
    }

    if (type == OperationType.Leasing || type == OperationType.Buy) {
      json.addAll({
        'deposit': deposit,
        'fee': fee,
        'ownerFee1': ownerFee1,
        'ownerFee2': ownerFee2,
        'payerFee1': payerFee1,
        'payerFee2': payerFee2,
        'ownerFeeUserId1': ownerFeeUserId1,
        'ownerFeeUserId2': ownerFeeUserId2,
        'payerFeeUserId1': payerFeeUserId1,
        'payerFeeUserId2': payerFeeUserId2
      });

      if (ownerFeeUserId1 != null) users.add(ownerFeeUserId1);
      if (ownerFeeUserId2 != null) users.add(ownerFeeUserId2);
      if (payerFeeUserId1 != null) users.add(payerFeeUserId1);
      if (payerFeeUserId2 != null) users.add(payerFeeUserId2);
    }

    json.addAll({
      'users': users.toList(),
    });

    return json;
  }

  bool isInPurchase(User user) {
    return type == OperationType.InputInApp && user.id == userId;
  }

  bool isInStellar(User user) {
    return type == OperationType.InputStellar && user.id == userId;
  }

  bool isIn(User user) {
    return isInStellar(user) || isInPurchase(user);
  }

  bool isOutStellar(User user) {
    return type == OperationType.OutputStellar && user.id == userId;
  }

  bool isOut(User user) {
    return isOutStellar(user);
  }

  bool isReward(User user) {
    return type == OperationType.Reward && user.id == userId;
  }

  bool isLeasing(User user) {
    return type == OperationType.Leasing && user.id == userId;
  }

  bool isReferral(User user) {
    return type == OperationType.Leasing &&
        (user.id == ownerFeeUserId1 ||
            user.id == ownerFeeUserId2 ||
            user.id == payerFeeUserId1 ||
            user.id == payerFeeUserId2);
  }

  double referralAmount(User user) {
    if (type == OperationType.Leasing && user.id == ownerFeeUserId1)
      return ownerFee1;
    else if (type == OperationType.Leasing && user.id == ownerFeeUserId2)
      return ownerFee2;
    else if (type == OperationType.Leasing && user.id == payerFeeUserId1)
      return payerFee1;
    else if (type == OperationType.Leasing && user.id == payerFeeUserId2)
      return payerFee2;
    else
      return 0.0;
  }

  DocumentReference get ref {
    return db.collection('operations').document(id);
  }

  static DocumentReference Ref(String id) {
    if (id != null)
      return db.collection('operations').document(id);
    else
      return db.collection('operations').document();
  }
}

// Classes for finantial safety (wallet and audit logs)
class Wallet {
  String id;
  double blocked;
  double balance;
  String seq_tr;
  String seq_in;
  String seq_out;
  String cursor;

  Wallet({@required this.id, this.balance, this.blocked}) {
    if (balance == null) balance = 0.0;
    if (blocked == null) blocked = 0.0;
  }

  Wallet.fromJson(Map json)
      : id = json['id'],
        balance =
            json['balance'] != null ? (json['balance'] as num).toDouble() : 0,
        blocked =
            json['blocked'] != null ? (json['blocked'] as num).toDouble() : 0,
        cursor = json['cursor'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'balance': balance,
      'blocked': blocked,
      'seq_tr': seq_tr,
      'seq_in': seq_in,
      'seq_out': seq_out,
    };
  }

  double getAvailable() {
    return balance - blocked;
  }

  DocumentReference get ref {
    return db.collection('wallets').document(id);
  }

  static DocumentReference Ref(String userId) {
    return db.collection('wallets').document(userId);
  }
}

class Secret {
  String id;
  String secretSeed;

  Secret({@required this.id, this.secretSeed});

  Secret.fromJson(Map json)
      : id = json['id'],
        secretSeed = json['secretSeed'];

  Map<String, dynamic> toJson() {
    return {'id': id, 'secretSeed': secretSeed};
  }

  DocumentReference get ref {
    return db.collection('secrets').document(id);
  }

  static DocumentReference Ref(String userId) {
    return db.collection('secrets').document(userId);
  }
}

class AuditTr {
  String id;
  String from;
  String to;
  double amount;
  double hold;
  DateTime date;
  String opId;

  AuditTr(
      {@required this.id,
      @required this.from,
      @required this.to,
      @required this.amount,
      @required this.hold,
      @required this.date,
      @required this.opId});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'to': to,
      'amount': amount,
      'hold': hold,
      'date': Timestamp.fromDate(date),
      'opId': opId
    };
  }

  DocumentReference get ref {
    return db.collection('audit_tx').document(id);
  }
}

class AuditIn {
  String id;
  String to;
  double amount;
  DateTime date;
  String type;
  String opId;
  String txId;

  AuditIn(
      {@required this.id,
      @required this.to,
      @required this.amount,
      @required this.date,
      @required this.type,
      @required this.opId,
      @required this.txId});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'to': to,
      'amount': amount,
      'opId': opId,
      'date': Timestamp.fromDate(date),
      'type': type,
      'txId': txId
    };
  }

  DocumentReference get ref {
    return db.collection('audit_in').document(id);
  }
}

class AuditOut {
  String id;
  String from;
  double hold;
  double amount;
  DateTime date;
  String opId;
  String txId;

  AuditOut(
      {@required this.id,
      @required this.from,
      @required this.amount,
      @required this.hold,
      @required this.date,
      @required this.opId,
      @required this.txId});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'amount': amount,
      'hold': hold,
      'date': Timestamp.fromDate(date),
      'opId': opId,
      'txId': txId
    };
  }

  DocumentReference get ref {
    return db.collection('audit_out').document(id);
  }
}

class Provider {
  String name;
  String country;
  String area;
  String query;

  Provider(
      {@required this.name, @required this.query, this.country, this.area}) {
    if (country == null) country = 'ALL';
  }
}

class Messages {
  static const String Initial = 'init';
  static const String Handover = 'handover';
  static const String Complete = 'complete';

  String id;
  bool system = false;
  List<String> ids;
  DateTime timestamp;
  String message;
  Map<String, int> unread;
  List<String> books;
  String status;
  String fromId;
  String fromName;
  String fromImage;
  String toId;
  String toName;
  String toImage;
  DateTime handover;

  bool fromDb;

  Messages(
      {@required this.fromId,
      this.toId,
      this.system = false,
      this.status = Initial,
      this.books}) {
    id = this.ref.documentID;

    timestamp = DateTime.now();
    unread = {fromId: 0, 'system': 0};

    if (books == null) books = <String>[];

    fromDb = false;
  }

  Messages.fromJson(Map json, DocumentSnapshot doc)
      : system = json['system'] != null ? json['system'] : false,
        ids = json['ids']?.cast<String>(),
        message = json['message'],
        timestamp = new DateTime.fromMillisecondsSinceEpoch(
            int.parse(json['timestamp'])),
        unread = json['unread'] != null
            ? Map<String, int>.from(json['unread'])
            : null,
        books =
            json['books'] != null ? List<String>.from(json['books'] as List<dynamic>) : List<String>.from([]),
        status = json['status'],
        fromId = json['fromId'],
        fromName = json['fromName'],
        fromImage = json['fromImage'],
        toId = json['toId'],
        toName = json['toName'],
        toImage = json['toImage'],
        handover = json['handover'] != null
            ? (json['handover'] as Timestamp).toDate()
            : null {
    if (unread == null) {
      unread = {for (var i in ids) i: 0};
    }
    unread = unread.map((key, num) => new MapEntry(key, num ?? 0));

    // Recover id from old version chat ids
    id = doc.documentID;
    fromDb = true;
  }

  Map<String, dynamic> toJson() {
    return {
      'system': system,
      'ids': !system ? [fromId, toId] : null,
      'message': message,
      'timestamp': Timestamp.now().millisecondsSinceEpoch.toString(),
      'unread': unread,
      'books': books,
      'status': status,
      'fromId': fromId,
      'fromName': fromName,
      'fromImage': fromImage,
      'toId': toId,
      'toName': toName,
      'toImage': toImage,
      'handover': handover != null ? Timestamp.fromDate(handover) : null
    };
  }

  // Return userId of the counterparty
  bool toMe(String userId) {
    return toId == userId;
  }

  bool fromMe(String userId) {
    return fromId == userId;
  }

  // Return userId of the counterparty
  String partnerId(String userId) {
    return ids[0] == userId ? ids[1] : ids[0];
  }

  // Return name of the peer
  String partnerName(String userId) {
    return (fromId == userId ) ? toName : fromName;
  }

  // Return image of the peer
  String partnerImage(String userId) {
    return (fromId == userId ) ? toImage : fromImage;
  }

  void reset() {
    status = Messages.Initial;
    books = <String>[];
    unread = {for (var i in ids) i: 0};
    timestamp = DateTime.now();
  }

  DocumentReference get ref {
    return db.collection('messages').document(system ? fromId : fromId + ':' + toId);
  }

  static DocumentReference Ref(String id) {
    return db.collection('messages').document(id);
  }
}

class Bookcopy {
  String id;
  User owner;
  User holder;
  Book book;
  GeoPoint position;
  String status;
  bool matched = false;
  bool lent = false;
  String wishId;
  User wisher;
  double distance;
  double d;

  Bookcopy(
      {@required this.owner,
      @required this.book,
      @required this.position,
      this.status = 'available',
      this.holder,
      this.matched = false,
      this.lent = false,
      this.wishId,
      this.wisher,
      this.distance}) {
    if (holder == null) holder = owner;
  }

  Bookcopy.fromJson(Map json)
      : id = json['id'],
        owner = User.fromJson(json['owner']),
        holder = User.fromJson(json['holder']),
        book = Book.fromJson(json['book']),
        position = json['position'] as GeoPoint,
        status = json['status'],
        matched = json['matched'] ?? false,
        lent = json['lent'] ?? false,
        wishId = json['wishId'],
        wisher = json['wisher'] != null ? User.fromJson(json['wisher']) : null,
        distance = json['distance'] != null
            ? (json['distance'] as num).toDouble()
            : double.infinity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner': owner.toJson(),
      'holder': holder.toJson(),
      'book': book.toJson(),
      'position': position,
      'status': status,
      'matched': matched,
      'lent': lent,
      'wishId': wishId,
      'wisher': wisher?.toJson(),
      'distance': distance
    };
  }
}

class Wish {
  String id;
  User wisher;
  GeoPoint position;
  Book book;
  String created;
  bool matched = false;
  String bookcopyId;
  GeoPoint bookcopyPosition;
  User owner;
  double distance;
  double d; //this field is not saved to DB, only for client-side sorting

  Wish(
      {@required this.wisher,
      @required this.position,
      @required this.book,
      this.created,
      this.matched = false,
      this.bookcopyId,
      this.bookcopyPosition,
      this.owner,
      this.distance});

  Wish.fromJson(Map json)
      : id = json['id'],
        wisher = User.fromJson(json['wisher']),
        position = json['position'] as GeoPoint,
        book = Book.fromJson(json['book']),
        created = json['created'],
        matched = json['matched'] ?? false,
        bookcopyId = json['bookcopyId'],
        bookcopyPosition = json['bookcopyPosition'] as GeoPoint,
        owner = json['owner'] != null ? User.fromJson(json['owner']) : null,
        distance = json['distance'] != null
            ? (json['distance'] as num).toDouble()
            : double.infinity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wisher': wisher.toJson(),
      'position': position,
      'book': book.toJson(),
      'created': created,
      'matched': matched,
      'bookcopyId': bookcopyId,
      'bookcopyPosition': bookcopyPosition,
      'owner': owner?.toJson(),
      'distance': distance
    };
  }
}

Set<String> getKeys(String s) {
  List<String> keys = s
      .toLowerCase()
      .split(new RegExp(r"[\s,!?:;.]+"))
      .where((s) => s.length > 2)
      .toList();
  keys.sort((a, b) {
    return b.length - a.length;
  });
  if (keys == null) keys = <String>[];
  return keys.toSet();
}

Position lastKnownPosition;

Future<GeoPoint> currentPosition() async {
  try {
    final position = await Geolocator().getLastKnownPosition();
    lastKnownPosition = position;
    return new GeoPoint(position.latitude, position.longitude);
  } on PlatformException {
    print("POSITION: GeoPisition failed");
    return null;
  }
}

Future<GeoFirePoint> currentLocation() async {
  try {
    final position = await Geolocator().getLastKnownPosition();
    lastKnownPosition = position;
    return Geoflutterfire()
        .point(latitude: position.latitude, longitude: position.longitude);
  } on PlatformException {
    print("POSITION: GeoPisition failed");
    return null;
  }
}

double distanceBetween(double lat1, double lon1, double lat2, double lon2) {
  double R = 6378.137; // Radius of earth in KM
  double dLat = lat2 * math.pi / 180 - lat1 * math.pi / 180;
  double dLon = lon2 * math.pi / 180 - lon1 * math.pi / 180;
  double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1 * math.pi / 180) *
          math.cos(lat2 * math.pi / 180) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  double d = R * c;
  return d; // meters
}

