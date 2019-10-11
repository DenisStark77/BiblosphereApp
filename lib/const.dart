import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:googleapis/books/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:xml/xml.dart' as xml;
import 'dart:convert';
import 'dart:math' as math;
import 'package:stellar/stellar.dart' as stellar;

import 'package:biblosphere/l10n.dart';

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

  Book(
      {this.id,
      @required this.title,
      @required this.authors,
      @required this.isbn,
      this.image}) {
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

      print(
          '!!!DEBUG: price for ${title} = ${listPrice?.amount} ${listPrice?.currency}');
      source = BookSource.google;
      keys = getKeys(authors.join(' ') + ' ' + title + ' ' + isbn);
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
    keys = getKeys(authors.join(' ') + ' ' + title + ' ' + isbn);
  }

  Book.fromJson(Map json)
      : id = json['id'],
        title = json['title'],
        authors = (json['authors'] as List).cast<String>(),
        isbn = json['isbn'],
        image = json['image'],
        price = json['price'],
        language = json['language'],
        keys = (json['keys'] as List).cast<String>().toSet(),
        listPrice = json['listPrice'] != null
            ? new Price.fromJson(json['listPrice'])
            : null,
        genre = json['genre'] {
    if (keys == null) {
      keys = getKeys(authors.join(' ') + ' ' + title + ' ' + isbn);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'authors': authors,
      'isbn': isbn,
      'image': image,
      'price': price,
      'listPrice': listPrice?.toJson(),
      'genre': genre,
      'keys': keys,
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
}

class User {
  String id;
  String name;
  String photo;
  GeoPoint position;
  int wishCount = 0;
  int bookCount = 0;
  int shelfCount = 0;
  double balance = 0;
  String accountId;
  String secretSeed;
  double d;

  User(
      {@required this.id,
      @required this.name,
      @required this.photo,
      @required this.position,
      this.balance = 0,
      this.bookCount,
      this.shelfCount,
      this.wishCount});

  User.fromJson(Map json)
      : id = json['id'],
        name = json['name'],
        photo = json['photo'] ?? json['photoUrl'],
        position = json['position'] as GeoPoint,
        wishCount = json['wishCount'] ?? 0,
        bookCount = json['bookCount'] ?? 0,
        shelfCount = json['shelfCount'] ?? 0,
        balance =
            json['balance'] != null ? (json['balance'] as num).toDouble() : 0,
        accountId = json['accountId'],
        secretSeed = json['secretSeed'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photo': photo,
      'position': position,
      'accountId': accountId,
      'secretSeed': secretSeed
    };
  }

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
}

enum BookrecordType { none, own, wish, lent, borrowed, transit }

class Bookrecord {
  String id;
  String bookId;
  String ownerId;
  String holderId;
  String transitId;
  // Both users owner and holder to use array-contains instead of OR
  List<String> users;
  // Daily rent and full price
  double price;
  Deal deal;
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
      @required this.location,
      this.holderId,
      this.matched = false,
      this.wish = false,
      this.lent = false,
      this.transit = false,
      this.distance}) {
    if (holderId == null) holderId = ownerId;
  }

  Bookrecord.fromJson(Map json)
      : id = json['id'],
        ownerId = json['ownerId'],
        holderId = json['holderId'],
        transitId = json['transitId'],
        bookId = json['bookId'],
        location = Geoflutterfire().point(
            latitude: json['location']['geopoint'].latitude,
            longitude: json['location']['geopoint'].longitude),
        matched = json['matched'] ?? false,
        matchedBookId = json['matchedBookId'],
        lent = json['lent'] ?? false,
        wish = json['wish'] ?? false,
        transit = json['transit'] ?? false,
        price = json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
        deal = json['deal'] != null ? Deal.fromJson(json['deal']) : null,
        distance = json['distance'] != null
            ? (json['distance'] as num).toDouble()
            : double.infinity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'holderId': holderId,
      'transitId': transitId,
      'users': <String>[ownerId, holderId],
      'bookId': bookId,
      'location': location.data,
      'matched': matched,
      'matchedBookId': matchedBookId,
      'lent': lent,
      'wish': wish,
      'transit': transit,
      'deal': deal ?? toJson(),
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
    return ownerId == userId && ownerId != holderId && lent && !wish;
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
      book = new Book.fromJson(doc.data['book']);

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
}

class Deal {
  DateTime date;
  double price;

  Deal({@required this.date, @required this.price});

  Deal.fromJson(Map json)
      : date = (json['date'] as Timestamp).toDate(),
        price = json['price'] != null ? (json['price'] as num).toDouble() : 0.0;

  Map<String, dynamic> toJson() {
    return {'date': date, 'price': price};
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

class Messages {
  String id;
  List<String> ids;
  DateTime timestamp;
  String message;
  int unread;

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
        unread = int.parse(json['unread'] ?? '0');

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

class Transit {
  static const Request = 'request';
  static const Return = 'return';
  static const Offer = 'offer';
  static const Requested = 'requested';
  static const Accepted = 'accepted';
  static const Confirmed = 'confirmed';
  static const Rejected = 'rejected';
  static const Canceled = 'canceled';
  static const Accept = 'accept';
  static const Confirm = 'confirm';
  static const Reject = 'reject';
  static const Cancel = 'cancel';
  static const Ok = 'ok';

  String id;
  Bookcopy bookcopy;
  User from;
  User to;
  String action;
  String status;
  DateTime date;

  Transit(
      {@required this.bookcopy,
      @required this.from,
      @required this.to,
      this.action = 'request',
      this.status = 'requested',
      this.id,
      this.date = null});

  Transit.fromJson(Map json)
      : id = json['id'],
        bookcopy = Bookcopy.fromJson(json['bookcopy']),
        from = User.fromJson(json['from']),
        to = User.fromJson(json['to']),
        action = json['action'],
        status = json['status'],
        date = json['date'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookcopy': bookcopy.toJson(),
      'from': from.toJson(),
      'to': to.toJson(),
      'action': action,
      'status': status,
      'date': date
    };
  }

  static String stepText(String step, BuildContext context) {
    switch (step) {
      case Accept:
        return S.of(context).transitAccept;
      case Confirm:
        return S.of(context).transitConfirm;
      case Reject:
        return S.of(context).transitReject;
      case Cancel:
        return S.of(context).transitCancel;
      case Ok:
        return S.of(context).transitOk;
      default:
        return '';
    }
  }

  bool showInCart() {
    if (action == Request && status == Requested ||
        action == Request && status == Accepted ||
        action == Request && status == Rejected ||
        action == Return && status == Accepted ||
        action == Offer && status == Accepted)
      return true;
    else
      return false;
  }

  bool showInOutbox() {
    if (action == Request && status == Requested ||
        action == Request && status == Accepted ||
        action == Request && status == Confirmed ||
        action == Request && status == Canceled ||
        action == Return && status == Accepted ||
        action == Return && status == Confirmed ||
        action == Offer && status == Accepted ||
        action == Offer && status == Confirmed ||
        action == Offer && status == Rejected)
      return true;
    else
      return false;
  }

  String getCartText(BuildContext context) {
    if (action == Request && status == Requested) {
      // Cancel
      return S.of(context).cartRequestCancel(from.name, bookcopy.book.title);
    } else if (action == Request && status == Accepted) {
      // Confirm, Cancel
      return S.of(context).cartRequestAccepted(from.name, bookcopy.book.title);
    } else if (action == Request && status == Rejected) {
      // Ok
      return S.of(context).cartRequestRejected(from.name, bookcopy.book.title);
    } else if (action == Return && status == Accepted) {
      // Confirm
      return S.of(context).cartReturnConfirm(from.name, bookcopy.book.title);
    } else if (action == Offer && status == Accepted) {
      // Confirm, Reject
      return S
          .of(context)
          .cartOfferConfirmReject(from.name, bookcopy.book.title);
    } else {
      return '';
    }
  }

  List<String> getCartSteps() {
    if (action == Request && status == Requested) {
      // Cancel
      return <String>[Cancel];
    } else if (action == Request && status == Accepted) {
      // Confirm, Cancel
      return <String>[Confirm, Cancel];
    } else if (action == Request && status == Rejected) {
      // Ok
      return <String>[Ok];
    } else if (action == Return && status == Accepted) {
      // Confirm
      return <String>[Confirm];
    } else if (action == Offer && status == Accepted) {
      // Confirm, Reject
      return <String>[Confirm, Reject];
    } else {
      return <String>[];
    }
  }

  String getOutboxText(BuildContext context) {
    if (action == Request && status == Requested) {
      // Accept, Reject
      return S
          .of(context)
          .outboxRequestAcceptReject(to.name, bookcopy.book.title);
    } else if (action == Request && status == Accepted) {
      // Reject
      return S.of(context).outboxRequestAccepted(to.name, bookcopy.book.title);
    } else if (action == Request && status == Confirmed) {
      // Ok
      return S.of(context).outboxRequestConfirmed(to.name, bookcopy.book.title);
    } else if (action == Request && status == Canceled) {
      // Ok
      return S.of(context).outboxRequestCanceled(to.name, bookcopy.book.title);
    } else if (action == Return && status == Accepted) {
      // Cancel
      return S.of(context).outboxReturnAccepted(to.name, bookcopy.book.title);
    } else if (action == Return && status == Confirmed) {
      // Ok
      return S.of(context).outboxReturnConfirmed(to.name, bookcopy.book.title);
    } else if (action == Offer && status == Accepted) {
      // Cancel
      return S.of(context).outboxOfferAccepted(to.name, bookcopy.book.title);
    } else if (action == Offer && status == Confirmed) {
      // Ok
      return S.of(context).outboxOfferConfirmed(to.name, bookcopy.book.title);
    } else if (action == Offer && status == Rejected) {
      // Ok
      return S.of(context).outboxOfferRejected(to.name, bookcopy.book.title);
    } else {
      return '';
    }
  }

  List<String> getOutboxSteps() {
    if (action == Request && status == Requested) {
      // Accept, Reject
      return <String>[Accept, Reject];
    } else if (action == Request && status == Accepted) {
      // Reject
      return <String>[Reject];
    } else if (action == Request && status == Confirmed) {
      // Ok
      return <String>[Ok];
    } else if (action == Request && status == Canceled) {
      // Ok
      return <String>[Ok];
    } else if (action == Return && status == Accepted) {
      // Cancel
      return <String>[Cancel];
    } else if (action == Return && status == Confirmed) {
      // Ok
      return <String>[Ok];
    } else if (action == Offer && status == Accepted) {
      // Cancel
      return <String>[Cancel];
    } else if (action == Offer && status == Confirmed) {
      // Ok
      return <String>[Ok];
    } else if (action == Offer && status == Rejected) {
      // Ok
      return <String>[Ok];
    } else {
      return <String>[];
    }
  }
}

//Callback function type definition
typedef BookCallback(Book book);

Future addBookrecord(
    BuildContext context, Book b, User u, bool wish, GeoFirePoint location,
    {String source = 'goodreads', bool snackbar = true}) async {
  bool existingBook = false;

  if (b.isbn == null || b.isbn == 'NA')
    throw 'Book ${b?.title}, ${b?.authors?.join()} has no ISBN';

  //Try to get image if missing
  if (b.image == null ||
      b.image.isEmpty ||
      b.language == null ||
      b.language.isEmpty) {
    b = await enrichBookRecord(b);
  }

  QuerySnapshot q = await Firestore.instance
      .collection('books')
      .where('book.isbn', isEqualTo: b.isbn)
      .getDocuments();

  if (q.documents.isEmpty) {
    DocumentReference d = await Firestore.instance
        .collection('books')
        .add({'book': b.toJson(), 'source': source});

    b.id = d.documentID;
  } else {
    existingBook = true;
    b.id = q.documents.first.documentID;
  }

  Bookrecord bookrecord = new Bookrecord(
      ownerId: u.id, bookId: b.id, wish: wish, location: location);

  //Check if bookrecord already exist. Make sense only if isbn is registered
  if (existingBook) {
    QuerySnapshot q = await Firestore.instance
        .collection('bookrecords')
        .where('bookId', isEqualTo: b.id)
        .where('ownerId', isEqualTo: u.id)
        .where('wish', isEqualTo: wish)
        .getDocuments();

    //If bookcopy already exist refresh it
    if (q.documents.isNotEmpty) {
      bookrecord.id = q.documents.first.documentID;
      await Firestore.instance
          .collection('bookrecords')
          .document(bookrecord.id)
          .updateData(bookrecord.toJson());
      if (snackbar) showSnackBar(context, 'KuKu');
      return;
    }
  }

  DocumentReference rec =
      await Firestore.instance.collection('bookrecords').document();
  bookrecord.id = rec.documentID;
  await rec.setData(bookrecord.toJson());
  if (snackbar) {
    if (wish)
      showSnackBar(context, S.of(context).wishAdded);
    else
      showSnackBar(context, S.of(context).bookAdded);
  }

  await FirebaseAnalytics().logEvent(
      name: 'add_book',
      parameters: <String, dynamic>{'language': b.language ?? ''});
}

//TODO: Not sure it's good idea to have it as global valiables. Need to find
// better way. Hwever to have it in widget is not good idea either as it used
// from Goodreads import as well.
//TODO: Where to close such clients
class LibConnect {
  static Client _googleClient;
  static BooksApi _booksApi;
  static String goodreadsApiKey = 'SXMWtbHvcnbTgRTLT7isA';
  static Client _goodreadsClient;
  static Client _commonClient;

  static Client getClient() {
    if (_commonClient == null) _commonClient = new Client();
    return _commonClient;
  }

  static Client getGoodreadClient() {
    if (_goodreadsClient == null) _goodreadsClient = new Client();
    return _goodreadsClient;
  }

  static BooksApi getGoogleBookApi() {
    if (_googleClient == null)
      _googleClient =
          clientViaApiKey('AIzaSyDJR_BnU_JVJyGTfaWcj086UuQxXP3LoTU');

    if (_booksApi == null) _booksApi = new BooksApi(_googleClient);

    return _booksApi;
  }
}

Future<List<Book>> searchByTitleAuthorBiblosphere(String text) async {
  //TODO: Redesign search as now it only use ONE keyword
  // and doing rest of filtering on client side
  Set<String> keys = getKeys(text);
  QuerySnapshot snapshot;

  if (keys.length == 0)
    return [];
  else
    snapshot = await Firestore.instance
        .collection('books')
        .where('book.keys', arrayContains: keys.elementAt(0))
        .getDocuments();

  List<Book> books = snapshot.documents.where((doc) {
    return doc.data['book']['keys'].toSet().containsAll(keys);
  }).map((doc) {
    Book book = new Book.fromJson(doc.data['book']);
    return book;
  }).toList();

  return books;
}

Future<List<Book>> searchByTitleAuthorGoogle(String text) async {
  Volumes books = await LibConnect.getGoogleBookApi()
      .volumes
      .list(text, printType: 'books', maxResults: 10);

  if (books.items != null && books.items.isNotEmpty) {
    return books.items
        .where((v) =>
            v.volumeInfo.title != null &&
            v.volumeInfo.authors != null &&
            v.volumeInfo.authors.isNotEmpty &&
            v.volumeInfo.imageLinks != null &&
            v.volumeInfo.imageLinks.thumbnail != null &&
            v.volumeInfo.industryIdentifiers != null &&
            v.saleInfo != null &&
            !v.saleInfo.isEbook)
        .map((v) {
      return new Book.volume(v);
    }).toList();
  } else {
    return null;
  }
}

Future<List<Book>> searchByTitleAuthorGoodreads(String text) async {
  //TODO: avoid calls using ApiKey as it is not protected from others calling
  var res = await LibConnect.getGoodreadClient().get(
      'https://www.goodreads.com/search/index.xml?key=${LibConnect.goodreadsApiKey}&q=$text');

  var document = xml.parse(res.body);

  List<Book> books =
      document.findAllElements('best_book')?.take(5)?.map((xml.XmlElement e) {
    return new Book.goodreads(e);
    //As Goodreads doesn't have ISBN in search responce keep Goodreads ID instead.
    // It'll be replaced by ISBN by enrichBookRecord function on confirm stage.
  })?.toList();

  return books;
}

Future<Book> enrichBookRecord(Book book) async {
  //As Goodreads search by title/author does not return ISBN it's empty for
  // these records
  try {
    if (book.isbn == null || book.isbn.isEmpty || book.isbn == 'NA') {
      if (book.sourceId != null && book.sourceId.isNotEmpty) {
        var res = await LibConnect.getGoodreadClient().get(
            'https://www.goodreads.com/book/show/${book.sourceId}.xml?key=${LibConnect.goodreadsApiKey}');

        var document = xml.parse(res.body);
        String isbn =
            document.findAllElements('isbn13')?.first?.text?.toString();

        if (isbn != null) book.isbn = isbn;
      }
      if (book.isbn == null || book.isbn.isEmpty) book.isbn = 'NA';
    }

    //As many Goodreads books doesn't have images enrich it from Google
    if (book.image == null || book.image.isEmpty) {
      if (book.isbn != 'NA' && book.source != BookSource.google) {
        Book b = await searchByIsbnGoogle(book.isbn);
        if (b?.image != null) book.image = b.image;
        if (b?.language != null) book.language = b.language;
      }
    }

    return book;
  } catch (e) {
    print('Unknown error in enrichBookRecord: $e');
    return book;
  }
}

Future<Book> searchByIsbnGoogle(String isbn) async {
  try {
    Volumes books =
        await LibConnect.getGoogleBookApi().volumes.list('isbn:$isbn');
    if (books?.items != null && books.items.isNotEmpty) {
      var v = books?.items[0];
      if (v?.volumeInfo?.title != null &&
          v?.volumeInfo?.authors != null &&
          v.volumeInfo.authors.isNotEmpty &&
          v?.volumeInfo?.imageLinks != null &&
          v?.volumeInfo?.imageLinks?.thumbnail != null &&
          v?.volumeInfo?.industryIdentifiers != null &&
          v?.saleInfo != null &&
          !v.saleInfo.isEbook) {
        return new Book.volume(v)..isbn = isbn;
      }
    }
    return null;
  } catch (e) {
    print('Unknown error in searchByIsbnGoogle: $e');
    return null;
  }
}

Future<Book> searchByIsbnGoodreads(String isbn) async {
  try {
    var res = await LibConnect.getGoodreadClient().get(
        'https://www.goodreads.com/search/index.xml?key=${LibConnect.goodreadsApiKey}&q=$isbn');

    var document = xml.parse(res.body);

    var bookXml = document?.findAllElements('best_book')?.first;
    if (bookXml != null) {
      return new Book.goodreads(bookXml)..isbn = isbn;
    }
    return null;
  } catch (e) {
    print('Unknown error in searchByIsbnGoodreads: $e');
    return null;
  }
}

Future<Book> searchByIsbnRsl(String isbn) async {
  // Two requests neede. One to get CSRF cookie and second one to make a query.
  // Undocumented API reverse-engineered from search.rsl.ru/ru/search
  try {
    var headers = {
      'Upgrade-Insecure-Requests': '1',
    };

    String uri = 'https://search.rsl.ru/ru/search';
    var res = await LibConnect.getClient().get(uri, headers: headers);

    String cookie = res.headers['set-cookie'];
    RegExp exp1 = new RegExp(r"(.*?)=(.*?)(?:$|,(?!\s))");
    RegExp exp2 = new RegExp(r"(.*?)=(.*?)(?:$|;|,)");
    Iterable<Match> matches = exp1.allMatches(cookie);

    List<String> cleanCookie = [];
    for (var i = 0; i < matches.length; i++) {
      String c = cookie.substring(
          matches.elementAt(i).start, matches.elementAt(i).end);
      Match match2 = exp2.firstMatch(c);
      cleanCookie.add(c.substring(match2.start, match2.end - 1));
    }

    int tag, start, end;
    String token;

    tag = res.body.indexOf('csrf-token');
    if (tag != -1) {
      start = res.body.indexOf('"', tag + 11) + 1;
      end = res.body.indexOf('"', start);
      token = res.body.substring(start, end);
    }

    uri = 'https://search.rsl.ru/site/ajax-search';
    headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json, text/javascript, */*; q=0.01',
//                     'X-CSRF-Token': token,
      'Origin': 'https://search.rsl.ru',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.108 Safari/537.36',
      'Accept-Language':
          'en-GB,en;q=0.9,ru-RU;q=0.8,ru;q=0.7,ka-GE;q=0.6,ka;q=0.5,en-US;q=0.4',
      'Accept-Encoding': 'gzip, deflate, br',
      'Cookie': cleanCookie.join(';') + ';'
    };

    String body =
        'SearchFilterForm[search]=isbn:$isbn&_csrf=${Uri.encodeQueryComponent(token)}';

    //Use Request to control Content-Type header. Client.post add charset to it
    // which does not work with RSL
    Request request = new Request('POST', Uri.parse(uri));
    request.body = body;
    request.headers.clear();
    request.headers.addAll(headers);

    StreamedResponse strRes = await LibConnect.getClient().send(request);
    String resBody = await strRes.stream.bytesToString();

    var jsonRes = json.decode(resBody);

    String resStr = jsonRes['content'];

    String author, title;

    tag = resStr.indexOf('js-item-authorinfo');
    if (tag != -1) {
      start = resStr.indexOf('>', tag) + 1;
      end = resStr.indexOf('<', start);
      author = resStr.substring(start, end);
    }

    tag = resStr.indexOf('js-item-maininfo');
    if (tag != -1) {
      start = resStr.indexOf('>', tag) + 1;
      end = resStr.indexOf('[', start);
      title = resStr.substring(start, end);
    }

    if (title != null || author != null) {
      return new Book(title: title, authors: [author], isbn: isbn);
    }
    return null;
  } catch (e) {
    print('Unknown error in searchByIsbnRsi: $e');
    return null;
  }
}

/*

Response response = await post(
uri,
headers: headers,
body: jsonBody,
encoding: encoding,
);

int statusCode = response.statusCode;
String responseBody = response.body;
*/

Future<Book> searchByIsbn(String isbn) async {
  try {
    QuerySnapshot q = await Firestore.instance
        .collection('books')
        .where('book.isbn', isEqualTo: isbn)
        .getDocuments();

    if (q.documents.isEmpty) {
      //No books found
      return null;
    } else {
      Book b = new Book.fromJson(q.documents.first.data['book']);
      b.id = q.documents.first.documentID;
      return b;
    }
  } catch (e) {
    print('Unknown error in searchByIsbn: $e');
    return null;
  }
}

final themeColor = new Color(0xfff5a623);
final primaryColor = new Color(0xff203152);
final greyColor = new Color(0xffaeaeae);
final greyColor2 = new Color(0xffE8E8E8);

void showBbsDialog(BuildContext context, String text) {
  showDialog<Null>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Container(
          child: Row(children: <Widget>[
            Material(
              child: Image.asset(
                'images/Librarian50x50.jpg',
                width: 50.0,
              ),
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            new Flexible(
              child: Container(
                child: new Container(
                  child: Text(
                    text,
                    style: TextStyle(color: themeColor),
                  ),
                  alignment: Alignment.centerLeft,
                  margin: new EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 5.0),
                ),
                margin: EdgeInsets.only(left: 5.0),
              ),
            ),
          ]),
          height: 50.0,
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(S.of(context).ok),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

String chatId(String user1, String user2) {
  if (user1.hashCode <= user2.hashCode) {
    return '$user1-$user2';
  } else {
    return '$user2-$user1';
  }
}

Future<bool> showBbsConfirmation(BuildContext context, String text) async {
  return (await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Container(
          child: Row(children: <Widget>[
            Material(
              child: Image.asset(
                'images/Librarian50x50.jpg',
                width: 50.0,
              ),
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            new Flexible(
              child: Container(
                child: new Container(
                  child: Text(
                    text,
                    style: TextStyle(color: themeColor),
                  ),
                  alignment: Alignment.centerLeft,
                  margin: new EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 5.0),
                ),
                margin: EdgeInsets.only(left: 5.0),
              ),
            ),
          ]),
          height: 50.0,
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(S.of(context).yes),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          FlatButton(
            child: Text(S.of(context).no),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      );
    },
  ));
}

Future<GeoPoint> currentPosition() async {
  try {
    final position = await Geolocator().getLastKnownPosition();
    return new GeoPoint(position.latitude, position.longitude);
  } on PlatformException {
    print("POSITION: GeoPisition failed");
    return null;
  }
}

Future<GeoFirePoint> currentLocation() async {
  try {
    final position = await Geolocator().getLastKnownPosition();
    return Geoflutterfire()
        .point(latitude: position.latitude, longitude: position.longitude);
  } on PlatformException {
    print("POSITION: GeoPisition failed");
    return null;
  }
}

typedef Widget CardCallback(DocumentSnapshot document, User user);

MaterialPageRoute cardListPage(
    {User user,
    Stream stream,
    CardCallback mapper,
    String title,
    String empty}) {
  return new MaterialPageRoute(
      builder: (context) => new Scaffold(
          appBar: new AppBar(
            title: new Text(
              title,
              style:
                  Theme.of(context).textTheme.title.apply(color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: new StreamBuilder<QuerySnapshot>(
              stream: stream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Text(S.of(context).loading);
                  default:
                    if (!snapshot.hasData || snapshot.data.documents.isEmpty) {
                      return Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            empty,
                            style: Theme.of(context).textTheme.body1,
                          ));
                    }
                    return new ListView(
                      children: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                        return mapper(document, user);
                      }).toList(),
                    );
                }
              })));
}

showSnackBar(BuildContext context, String text) {
  final snackBar = SnackBar(
    content: Text(text),
    /*
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        // Some code to undo the change!
      },
    ),
    */
  );

// Find the Scaffold in the Widget tree and use it to show a SnackBar!
  Scaffold.of(context).showSnackBar(snackBar);
}

Scaffold buildScaffold(BuildContext context, String title, Widget body) {
  return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          title,
          style: Theme.of(context).textTheme.title.apply(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: body);
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

Widget bookImage(Book book, double size, {padding = 3.0}) {
  if (book == null)
    return Container();
  else
    return new Container(
        margin: EdgeInsets.all(padding),
        child: Image(
            image: new CachedNetworkImageProvider(
                (book.image != null && book.image.isNotEmpty)
                    ? book.image
                    : nocoverUrl),
            width: size,
            fit: BoxFit.cover));
}

Widget userPhoto(User user, double size, {double padding = 0.0}) {
  if (user == null) {
    return Container();
  } else {
    return Container(
        margin: EdgeInsets.all(padding),
        width: size,
        height: size,
        decoration: new BoxDecoration(
            shape: BoxShape.circle,
            image: new DecorationImage(
                fit: BoxFit.fill,
                image: new CachedNetworkImageProvider(user.photo))));
  }
}

typedef BookrecordWidgetBuilder = Widget Function(
    BuildContext context, Bookrecord bookrecord);

class BookrecordWidget extends StatefulWidget {
  BookrecordWidget(
      {Key key,
      @required this.bookrecord,
      @required this.currentUser,
      @required this.builder,
      this.filter = const {}})
      : super(key: key);

  final Bookrecord bookrecord;
  final User currentUser;
  final BookrecordWidgetBuilder builder;
  final Set<String> filter;

  @override
  _BookrecordWidgetState createState() => new _BookrecordWidgetState(
      bookrecord: bookrecord, currentUser: currentUser, builder: builder);
}

class _BookrecordWidgetState extends State<BookrecordWidget> {
  Bookrecord bookrecord;
  User currentUser;
  final BookrecordWidgetBuilder builder;

  @override
  void initState() {
    super.initState();
    bookrecord.getBookrecord(currentUser).whenComplete(() {
      setState(() {});
    });
  }

  _BookrecordWidgetState({
    Key key,
    @required this.bookrecord,
    @required this.currentUser,
    @required this.builder,
  });

  @override
  void didUpdateWidget(BookrecordWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentUser.id != widget.currentUser.id) {
      currentUser = widget.currentUser;
    }

    if (oldWidget.bookrecord.id != widget.bookrecord.id) {
      bookrecord = widget.bookrecord;
      if (!bookrecord.hasData)
        bookrecord.getBookrecord(currentUser).whenComplete(() {
          setState(() {});
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (bookrecord == null ||
        !bookrecord.hasData ||
        bookrecord.book == null ||
        bookrecord.book.keys == null ||
        !bookrecord.book.keys.containsAll(widget.filter)) {
      return Container();
    } else {
      return builder(context, bookrecord);
    }
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

createStellarAccount(User user) async {
  stellar.KeyPair pair = stellar.KeyPair.random();

  /* Add balance to test account
  var url = "https://friendbot.stellar.org/?addr=${pair.accountId}";
  http.get(url).then((response) {
    switch (response.statusCode) {
      case 200:
        {
          print(
              "!!!DEBUG: SUCCESS! You have a new account : \n${response.body}");
          print("!!!DEBUG: Response body: ${response.body}");
          break;
        }
      default:
        {
          print("ERROR! : \n${response.body}");
        }
    }
  });
  */

  user.accountId = pair.accountId;
  user.secretSeed = pair.secretSeed;
  await Firestore.instance
      .collection('users')
      .document(user.id)
      .updateData({'accountId': user.accountId, 'secretSeed': user.secretSeed});
}

void charge(User buyer, double amount, stellar.TransactionBuilder builder) {
  amount = (amount * 100).roundToDouble() / 100;

  //Check if book holder has Stellar account, create if needed
  if (buyer.secretSeed == null) {
    print('!!!DEBUG: source account does not exist ${buyer.id}');
    throw ('Stellar account does not exist for user ${buyer.name}');
  }

  // Biblospher account
  stellar.KeyPair destination = stellar.KeyPair.fromAccountId(
      'GA2VIBWLNPLRY3SPUAFPIDLNFJJR4HJV5RONNQZJO4OA4LSXJ6UZV3MS');

  print('!!!DEBUG adding operation');
  builder.addOperation(new stellar.PaymentOperationBuilder(destination,
                  new stellar.AssetTypeNative(), amount.toString()).build());
}

void refund(User buyer, User owner, Deal deal, stellar.TransactionBuilder builder) async {
  if (deal == null) throw ('Transaction tried on empty deal');

  double refund =
      (deal.date.difference(DateTime.now()).inDays * deal.price / 183 * 100)
          .roundToDouble() / 100;

  // Could not be negative (in case of calculation after last day)
  if (refund < 0.0) refund = 0.0;

  // Reward owner
  double reward = deal.price - refund;

  // Refund fee as well
  refund = (refund * 1.2 * 100).roundToDouble() / 100;

  print('!!!DEBUG: price/refund/reward: ${deal.price}, ${refund}, ${reward}');

  if (refund > 0.0) {
    stellar.KeyPair destination =
        stellar.KeyPair.fromAccountId(buyer.accountId);

    builder.addOperation(new stellar.PaymentOperationBuilder(
            destination, new stellar.AssetTypeNative(), refund.toString())
        .build());
  }

  if (reward > 0.0) {
    stellar.KeyPair destination =
        stellar.KeyPair.fromAccountId(owner.accountId);

    builder.addOperation(new stellar.PaymentOperationBuilder(
            destination, new stellar.AssetTypeNative(), reward.toString())
        .build());
  }
}
