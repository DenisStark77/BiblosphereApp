import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis/books/v1.dart';
import 'package:xml/xml.dart' as xml;

Firestore db = Firestore.instance;

const String sharingUrl =
    'https://biblosphere.org/images/phone-app-screens-2000.png';

const String nocoverUrl =
    'https://firebasestorage.googleapis.com/v0/b/biblosphere-210106.appspot.com/o/images%2Fnocover.png?alt=media&token=fb68e614-d34e-4b47-bf2c-47e742b4786d';

String getTimestamp() => new DateTime.now().millisecondsSinceEpoch.toString();

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

enum BookSource { none, google, goodreads }

class Book {
  String id;
  String title;
  List<String> authors;
  String isbn = 'NA';
  String image;
  String sourceId;
  BookSource source = BookSource.none;
  double price = 0.0;
  // Price in original currency from the platforms
  Price listPrice;
  String genre;
  String language;
  Set<String> keys;

  Book({
    this.id,
    @required this.title,
    @required this.authors,
    @required this.isbn,
    this.image,
    this.sourceId,
    this.source = BookSource.none,
    this.price,
    this.listPrice,
    this.genre,
    this.language,
  }) {
    if (id == null) id = Ref().documentID;
    keys = getKeys(authors.join(' ') + ' ' + title + ' ' + isbn);
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
      keys = getKeys(authors.join(' ') + ' ' + title + ' ' + isbn);
    } catch (e) {
      print('Unknown error in Book.volume: $e');
    }
    if (id == null) id = Ref().documentID;
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
    keys = getKeys(authors.join(' ') + ' ' + title + ' ' + isbn);
    if (id == null) id = Ref().documentID;
  }

  Book.fromJson(Map json)
      : id = json['id'],
        title = json['title'],
        authors = (json['authors'] as List)?.cast<String>(),
        isbn = json['isbn'],
        image = json['image'],
        sourceId = json['sourceId'],
        source = json['source'] is int ? BookSource.values.elementAt(json['source']??0) : BookSource.none,
        price = json['price'],
        language = json['language'],
        keys = (json['keys'] as List)?.cast<String>()?.toSet(),
        listPrice = json['listPrice'] != null
            ? new Price.fromJson(json['listPrice'])
            : null,
        genre = json['genre'] {
    if (keys == null) {
      print('!!!DEBUG: ${id} ${title} ${json}');
      keys = getKeys((authors != null ? authors.join(' ') : '') + ' ' + (title != null ? title : '') + ' ' + (isbn != null ? isbn : ''));
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'authors': authors,
      'isbn': isbn,
      'image': image,
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
    return 25.0;
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

  DocumentReference ref() {
    return db.collection('books').document(id);
  }

  static DocumentReference Ref([String id]) {
    return db.collection('books').document(id);
  }
}

class User {
  String id;
  String name;
  String photo;
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
  String accountId;
  String payoutId;
  String cursor;
  String secretSeed;
  double d;

  User(
      {@required this.name,
      @required this.photo,
      this.id,
      this.position,
      this.balance = 0,
      this.blocked = 0,
      this.bookCount,
      this.shelfCount,
      this.wishCount,
      this.link,
      this.beneficiary1,
      this.beneficiary2,
      this.accountId,
      this.payoutId,
      this.secretSeed}) {
    if (id == null) id = Ref().documentID;
  }

  User.fromJson(Map json)
      : id = json['id'],
        name = json['name'],
        photo = json['photo'] ?? json['photoUrl'],
        link = json['link'],
        beneficiary1 = json['beneficiary1'],
        beneficiary2 = json['beneficiary2'],
        feeShared = json['feeShared'] != null ? (json['feeShared'] as num).toDouble() : 0,
        position = json['position'] as GeoPoint,
        wishCount = json['wishCount'] ?? 0,
        bookCount = json['bookCount'] ?? 0,
        shelfCount = json['shelfCount'] ?? 0,
        balance =
            json['balance'] != null ? (json['balance'] as num).toDouble() : 0,
        blocked =
            json['blocked'] != null ? (json['blocked'] as num).toDouble() : 0,
        cursor = json['cursor'],
        accountId = json['accountId'],
        payoutId = json['payoutId'],
        secretSeed = json['secretSeed'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photo': photo,
      'link': link,
      'beneficiary1': beneficiary1,
      'beneficiary2': beneficiary2,
      'position': position,
      'wishCount': wishCount,
      'bookCount': bookCount,
      'shelfCount': shelfCount,
      'accountId': accountId,
      'payoutId': payoutId,
      'secretSeed': secretSeed
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
  DocumentReference ref() {
    return db.collection('users').document(id);
  }

  static DocumentReference Ref([String id=null]) {
    if(id != null)
      return db.collection('users').document(id);
    else
      return db.collection('users').document();
  }
}

enum BookrecordType { none, own, wish, lent, borrowed, transit }

class Bookrecord {
  String id;
  String bookId;
  String ownerId;
  String holderId;
  String transitId;
  String rewardId;
  String leasingId;
  // Both users owner and holder to use array-contains instead of OR
  Set<String> users;
  // Daily rent and full price
  double price;
  // Status of the book copy
  bool transit = false;
  bool wish = false;
  bool lent = false;
  // If book are matched (wish and available book)
  bool matched = false;
  String matchedBookId;
  // Position of the book and distance to the closest match
  GeoFirePoint location;
  double distance;

  //Below data are from different Firestore tables and filled on client side
  Book book;
  User owner;
  User holder;
  // User with whom book are at transit
  User transitee;
  // Flag if extra data is loaded
  bool hasData = false;

  Bookrecord(
      {@required this.ownerId,
      @required this.bookId,
      this.location,
      this.holderId,
      this.transitId,
      this.rewardId,
      this.leasingId,
      this.price,
      this.matched = false,
      this.matchedBookId,
      this.wish = false,
      this.lent = false,
      this.transit = false,
      this.distance}) {
    if (holderId == null) holderId = ownerId;
    if (id == null) id = Ref().documentID;
  }

  Bookrecord.fromJson(Map json)
      : id = json['id'],
        ownerId = json['ownerId'],
        holderId = json['holderId'],
        transitId = json['transitId'],
        //users = (json['users']?.map((s) => s as String))?.toSet(),
        //users = (json['users']?.map((dynamic s) => s.toString()))?.toSet(),
        users = (json['users'] as List).cast<String>().toSet(),
        bookId = json['bookId'],
        rewardId = json['rewardId'],
        leasingId = json['leasingId'],
        location = json['location']!=null ? Geoflutterfire().point(
            latitude: json['location']['geopoint'].latitude,
            longitude: json['location']['geopoint'].longitude) : null,
        matched = json['matched'] ?? false,
        matchedBookId = json['matchedBookId'],
        lent = json['lent'] ?? false,
        wish = json['wish'] ?? false,
        transit = json['transit'] ?? false,
        price = json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
        distance = json['distance'] != null
            ? (json['distance'] as num).toDouble()
            : double.infinity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'holderId': holderId,
      'transitId': transitId,
      'rewardId': rewardId,
      'leasingId': leasingId,
      'users': <String>{ownerId, holderId, transitId}.where((s) => s != null).toList(),
      'bookId': bookId,
      'location': location?.data,
      'matched': matched,
      'matchedBookId': matchedBookId,
      'lent': lent,
      'wish': wish,
      'transit': transit,
      'price': price,
      'distance': distance
    };
  }

  bool isOwn(String userId) {
    return ownerId == userId && !transit && !lent && !wish;
  }

  bool isWish(String userId) {
    return ownerId == userId && wish && !transit && !lent;
  }

  bool isLent(String userId) {
    return ownerId == userId && ownerId != holderId && lent && !wish && (!transit || transitId != ownerId);
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

  Future<void> getBookrecord(User user) async {
    if (hasData) {
      return this;
    } else {
      // Read BOOK data
      DocumentSnapshot doc =
          await Firestore.instance.collection('books').document(bookId).get();
      if (doc.exists && doc.data != null)
        book = new Book.fromJson(doc.data);

      // Read owner user data
      if (ownerId == user.id) {
        owner = user;
      } else {
        DocumentSnapshot doc = await Firestore.instance
            .collection('users')
            .document(ownerId)
            .get();
        owner = new User.fromJson(doc?.data);
      }

      // Read holder user data if different from owner
      if (holderId == ownerId) {
        holder = owner;
      } else if (holderId == user.id) {
        holder = user;
      } else {
        DocumentSnapshot doc = await Firestore.instance
            .collection('users')
            .document(holderId)
            .get();
        holder = new User.fromJson(doc?.data);
      }

      // Read transit user data if book are in transit
      if (transit && transitId != null) {
        DocumentSnapshot doc = await Firestore.instance
            .collection('users')
            .document(transitId)
            .get();
        transitee = new User.fromJson(doc?.data);
      }

      hasData = true;
    }
  }

  double getPrice() {
    return 25.0;
  }

  DocumentReference ref() {
    return db.collection('bookrecords').document(id);
  }

  static DocumentReference Ref([String id]) {
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
  String bookId;
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
      this.bookId,
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
    if (id == null)
      id = db.collection('operations').document().documentID;
  }

  Operation.fromJson(Map json)
      : id = json['id'],
        type = OperationType.values.elementAt(json['type']??0),
        //users = (json['users']?.map((dynamic s) => s.toString()))?.toSet(),
        users = (json['users'] as List).cast<String>().toSet(),
        userId = json['userId'],
        amount =
            json['amount'] != null ? (json['amount'] as num).toDouble() : 0.0,
        date = json['date'] != null ? (json['date'] as Timestamp).toDate() : null,
        transactionId = json['transactionId'],
        proxyTransactionId = json['proxyTransactionId'],
        peerId = json['peerId'],
        bookId = json['bookId'],
        bookrecordId = json['bookrecordId'],
        price = json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
        start = json['start'] != null ? (json['start'] as Timestamp).toDate() : null,
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
        'bookId': bookId,
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
    return type == OperationType.Leasing
        && (user.id == ownerFeeUserId1 || user.id == ownerFeeUserId2
            || user.id == payerFeeUserId1 || user.id == payerFeeUserId2);
  }

  double referralAmount(User user) {
    if(type == OperationType.Leasing && user.id == ownerFeeUserId1)
      return ownerFee1;
    else if(type == OperationType.Leasing && user.id == ownerFeeUserId2)
      return ownerFee2;
    else if(type == OperationType.Leasing && user.id == payerFeeUserId1)
      return payerFee1;
    else if(type == OperationType.Leasing && user.id == payerFeeUserId2)
      return payerFee2;
    else
      return 0.0;
  }

  DocumentReference ref() {
    return db.collection('operations').document(id);
  }

  static DocumentReference Ref(String id) {
    return db.collection('operations').document(id);
  }
}

class Provider {
  String name;
  String country;
  String area;
  String query;

  Provider({@required this.name, @required this.query, this.country, this.area}) {
    if(country == null)
      country = 'ALL';
  }
}

class Messages {
  String id;
  List<String> ids;
  DateTime timestamp;
  String message;
  Map<String, int> unread;

  // Flag if extra data is loaded
  bool hasData = false;

  //Below data are from different Firestore tables and filled on client side
  List<User> users;

  Messages({@required this.users}) {
    id = Firestore.instance.collection('messages').document().documentID;
  }

  Messages.fromJson(Map json)
      : id = json['id'],
        ids = json['ids'].cast<String>(),
        message = json['message'],
        timestamp = new DateTime.fromMillisecondsSinceEpoch(
            int.parse(json['timestamp'])),
        unread = json['unread'] != null ? Map<String, int>.from(json['unread']) : null {
   if (unread == null) {
     unread = { for (var i in ids) i: 0 };
   }
   unread = unread.map((key, num) => new MapEntry(key, num??0));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ids': ids,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch.toString(),
      'unread': unread
    };
  }

  // Return userId of the counterparty
  String partnerId(String userId) {
    return ids[0] == userId ? ids[1] : ids[0];
  }

  // Return userId of the counterparty
  User partner(String userId) {
    if (hasData)
      return ids[0] == userId ? users[1] : users[0];
    else
      return null;
  }

  Future<void> getDetails(User user) async {
    if (hasData) {
      return;
    } else {
      users = [null, null];

      // Read first user data
      if (ids[0] == user.id) {
        users[0] = user;
      } else {
        DocumentSnapshot doc =
            await Firestore.instance.collection('users').document(ids[0]).get();
        users[0] = new User.fromJson(doc?.data);
      }

      // Read first user data
      if (ids[1] == user.id) {
        users[1] = user;
      } else {
        DocumentSnapshot doc =
            await Firestore.instance.collection('users').document(ids[1]).get();
        users[1] = new User.fromJson(doc?.data);
      }

      hasData = true;
    }
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
  return keys.toSet();
}
