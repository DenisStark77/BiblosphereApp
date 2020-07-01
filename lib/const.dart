import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'dart:math' as math;
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis/books/v1.dart';
import 'package:geolocator/geolocator.dart';

class B {
  static final B _singleton = B._internal();

  factory B() {
    return _singleton;
  }

  B._internal();

  static User _currentUser;
  static User _loginUser;
  static Position _position;
  static String _locality;
  static String _country;
  static List<User> _linkedUsers;

  static List<User> get linkedUsers => _linkedUsers;
  static set linkedUsers(List<User> list) {
    _linkedUsers = list;
  }

  static User get loginUser => _loginUser;
  static set loginUser(User user) {
    _loginUser = user;
  }

  static User get user => _currentUser;
  static set user(User user) {
    _currentUser = user;
  }

  static Position get position => _position;
  static set position(Position pos) => _position = pos;

  static String get locality => _locality;
  static set locality(String locality) => _locality = locality;

  static String get country => _country;
  static set country(String country) => _country = country;
}

class BiblosphereColorScheme {
  Color titleBackground = new Color(0xff344d64);
  Color titleText = Colors.black;
  Color background = new Color(0xfff4f4f3);
  Color cardBackground = new Color(0xffebe1e1);
  Color bar = new Color(0xffcbc1c4);
  Color button = new Color(0xffd3c0c0);
  Color buttonText = Colors.white;
  Color buttonBorder = Colors.grey;
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
      fontSize: 16.0, fontWeight: FontWeight.w300, fontStyle: FontStyle.italic);

  BiblosphereColorScheme(
      {this.titleBackground,
      this.titleText,
      this.background,
      this.cardBackground,
      this.bar,
      this.button,
      this.buttonText,
      this.buttonBorder,
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
  titleBackground: Color(0xffb5dfff), //0xff344d64),
  titleText: Colors.black, //0xff344d64),
  background: Color(0xffdeedf9),
  cardBackground: Colors.white,
  //cardBackground: Color(0xfff4f4f3), // yellowish
  //cardBackground: Color(0xffe2f2fe), // bluish
  bar: Color(0xffebe1e1),
  button: Color(0xffbde3ff), // light
  buttonText: Colors.black,
  buttonBorder: Colors.grey[600],
  chatMy: Color(0xffd8dede),
  chatMyText: Colors.black,
  chatHis: Colors.white,
  chatHisText: Colors.black,
  chipSelected: Color(0xffdeedf9),
  chipUnselected: Color(0xffbde3ff),
  chipText: Colors.black,
  inputHints: Colors.black,
);

Firestore db = Firestore.instance;
FirebaseAnalytics analytics = FirebaseAnalytics();

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
const String account_100 = 'images/icons/icons8-account-100.png';
const String paper_plane_100 = 'images/icons/icons8-paper-plane-100.png';
const String image_gallery_100 = 'images/icons/icons8-image-gallery-100.png';
const String compact_camera_100 = 'images/icons/icons8-compact-camera-100.png';
const String attach_90 = 'images/icons/icons8-attach-90.png';
const String heart_100 = 'images/icons/icons8-heart-100.png';

Widget assetIcon(String asset, {double size, double padding = 0.0}) {
  if (size != null)
    return Container(
        padding: EdgeInsets.all(padding),
        width: size,
        height: size,
        child: Image.asset(asset, fit: BoxFit.contain));
  else
    return Container(
        padding: EdgeInsets.all(padding),
        child: Image.asset(asset, fit: BoxFit.contain));
}

Widget drawerMenuItem(BuildContext context, String text, String icon,
    {double size}) {
  return Row(children: <Widget>[
    assetIcon(icon, size: size),
    Container(
        margin: EdgeInsets.only(left: 10.0),
        child: Text(text, style: Theme.of(context).textTheme.bodyText2)),
  ]);
}

enum BookSource { none, google, goodreads }

class Book {
  String title;
  List<String> authors;
  String isbn;
  String image;
  Set<String> keys;
  bool userImage = false; // flag that image are loaded by users
  String sourceId;
  int copies = 0;
  int wishes = 0;
  BookSource source = BookSource.none;
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
    this.genre,
    this.language,
  }) {
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
        language = json['language'],
        keys = (json['keys'] as List)?.cast<String>()?.toSet(),
        genre = json['genre'] {
    if (keys == null) {
      keys = getKeys((authors != null ? authors.join(' ') : '') +
          ' ' +
          (title != null ? title : '') +
          ' ' +
          (isbn != null ? isbn : ''));
    }
  }

  Map<String, dynamic> toJson({bool bookOnly = false}) {
    // Do not store copies & wishes. It's updated separatley.
    // Return only fields suitable for Bookrecord
    if (bookOnly)
      return {
        'title': title,
        'authors': authors,
        'isbn': isbn,
        'image': image,
        'keys': keys.toList(),
        'genre': genre,
        'language': language
      };
    else
      return {
        'title': title,
        'authors': authors,
        'isbn': isbn,
        'image': image,
        'userImage': userImage,
        'sourceId': sourceId,
        'source': source?.index,
        'genre': genre,
        'keys': keys.toList(),
        'language': language
      };
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

enum RecognitionStatus { None, Upload, Scan, Outline, CatalogsLookup, Rescan, Completed, Failed, Store }

class Shelf {
  String id;
  String image;
  int total = 0;
  int recognized = 0;
  RecognitionStatus status = RecognitionStatus.None;
  String userId;
  String userName;
  DateTime started;
  DateTime finished;
  String localImage;
  GeoFirePoint location;

  Shelf({
    @required this.id,
    @required this.userId,
    this.image,
    this.localImage,
    this.userName,
    this.status,
    this.location,
  });

  Shelf.fromJson(Map json)
      : id = json['id'],
        image = json['image'],
        total = json['total'] ?? 0,
        recognized = json['recognized'] ?? 0,
        status = json['status'] is int
            ? RecognitionStatus.values.elementAt(json['status'] ?? 0)
            : RecognitionStatus.None,
        userName = json['userName'],
        userId = json['userId'],
        started = json['started']?.toDate(),
        finished = json['finished']?.toDate(),
        //localImage = json['localImage'],
        location = json['location'] != null
            ? Geoflutterfire().point(
                latitude: json['location']['geopoint'] != null ? json['location']['geopoint'].latitude : json['location'].latitude,
                longitude: json['location']['geopoint'] != null ? json['location']['geopoint'].longitude : json['location'].longitude)
            : null;

  Map<String, dynamic> toJson({bool bookOnly = false}) {
    return {
      'id': id,
      'image': image,
      'total': total,
      'recognized': recognized,
      'status': status?.index,
      'userName': userName,
      'userId': userId,
      'started': started != null ? Timestamp.fromDate(started) : FieldValue.serverTimestamp(),
      'location': location?.data
    };
  }

  DocumentReference get ref {
    return db.collection('shelves').document(id);
  }
}

class User {
  String id;
  String name;
  String photo;
  // Fields for referral program. Referral Link and two persons to split fee to
  String link;
  // Support for linked account
  String currentUser;
  List<String> linkedUsers;
  // Support for referal program
  String beneficiary1;
  String beneficiary2;
  GeoPoint position;
  int wishCount = 0;
  int bookCount = 0;
  int shelfCount = 0;
  int balance = 0;
  double d;

  User(
      {@required this.name,
      @required this.photo,
      this.id,
      this.position,
      this.bookCount,
      this.shelfCount,
      this.wishCount,
      this.link,
      this.beneficiary1,
      this.beneficiary2,
      this.balance}) {
    if (id == null) id = Ref().documentID;
  }

  User.fromJson(Map json)
      : id = json['id'],
        name = json['name'],
        photo = json['photo'] ?? json['photoUrl'],
        link = json['link'],
        currentUser = json['currentUser'],
        linkedUsers = (json['linkedUsers'] as List)?.cast<String>(),
        beneficiary1 = json['beneficiary1'],
        beneficiary2 = json['beneficiary2'],
        position = json['position'] as GeoPoint,
        wishCount = json['wishCount'] ?? 0,
        bookCount = json['bookCount'] ?? 0,
        shelfCount = json['shelfCount'] ?? 0,
        balance = json['balance'] == null || json['balance'] is double
            ? 0
            : json['balance'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photo': photo,
      'link': link,
      // Do not update linked users (only direct update from settings)
      //'currentUser': currentUser,
      //'linkedUsers': linkedUsers,
      'beneficiary1': beneficiary1,
      'beneficiary2': beneficiary2,
      'position': position,
      'wishCount': wishCount,
      'bookCount': bookCount,
      'shelfCount': shelfCount,
      'balance': balance,
      // Not include balance, blocked, cursor and feeShared here. ONLY direct updates for these fields!!!
    };
  }

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

enum BookIntent { None, Offer, Request, Return, Remind }

class Bookrecord {
  String id;

  // Book details (inherited from book)
  String isbn;
  String title;
  List<String> authors;
  String image;
  Set<String> keys;
  String language;
  String genre;
  String description;
  String spineText;
  String coverText;

  // Tags assigned to the book by owner
  List<String> tags;

  // All tags assigned to this book by other users
  List<String> allTags;

  String ownerId;
  String ownerName;
  String ownerImage;
  String holderId;
  String holderName;
  String holderImage;
  // Both users owner and holder to use array-contains instead of OR
  Set<String> users;
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
  bool fromDb = false;

  Bookrecord(
      {@required this.ownerId,
      this.ownerName,
      this.ownerImage,
      @required this.isbn,
      this.title,
      this.authors,
      this.image,
      this.spineText,
      this.coverText,
      this.language,
      this.genre,
      this.description,
      this.tags,
      this.allTags,
      this.location,
      this.holderId,
      this.holderName,
      this.holderImage,
      this.matched = false,
      this.matchedId,
      this.wish = false,
      this.lent = false,
      this.chatId,
      this.distance}) {
    fromDb = false;
    if (holderId == null) {
      holderId = ownerId;
      holderName = ownerName;
      holderImage = ownerImage;
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
        genre = json['genre'],
        language = json['language'],
        spineText = json['spineText'],
        coverText = json['coverText'],
        description = json['description'],
        tags = (json['tags'] as List)?.cast<String>(),
        allTags = (json['allTags'] as List)?.cast<String>(),
        keys = (json['keys'] as List)?.cast<String>()?.toSet(),
        ownerId = json['ownerId'],
        ownerName = json['ownerName'],
        ownerImage = json['ownerImage'],
        holderId = json['holderId'],
        holderName = json['holderName'],
        holderImage = json['holderImage'],
        //users = (json['users']?.map((s) => s as String))?.toSet(),
        //users = (json['users']?.map((dynamic s) => s.toString()))?.toSet(),
        users = (json['users'] as List).cast<String>().toSet(),
        isbn = json['isbn'],
        location = json['location'] != null
            ? Geoflutterfire().point(
                latitude: json['location']['geopoint'].latitude,
                longitude: json['location']['geopoint'].longitude)
            : null,
        matched = json['matched'] ?? false,
        matchedId = json['matchedId'],
        lent = json['lent'] ?? false,
        wish = json['wish'] ?? false,
        confirmed = (json['transit'] ?? false) && (json['confirmed'] ?? false),
        chatId = json['chatId'] {
    fromDb = true;
    if (location != null && B.position != null)
      distance = distanceBetween(location.latitude, location.longitude,
          B.position.latitude, B.position.longitude);
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

  Map<String, dynamic> toJson({bookOnly=false}) {
    if (bookOnly) {
    return {
      'title': title,
      'authors': authors,
      'isbn': isbn,
      'image': image,
      'language': language,
      'genre': genre,
      'description': description,
      'coverText': coverText,
      'spineText': spineText,
      'tags': tags,
      'allTags': allTags,
      'keys': keys.toList(),
    };
    } else {
    return {
      'id': id,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerImage': ownerImage,
      'holderId': holderId,
      'holderName': holderName,
      'holderImage': holderImage,
      'users': <String>{ownerId, holderId}.where((s) => s != null).toList(),
      'location': location?.data,
      'matched': matched,
      'matchedId': matchedId,
      'lent': lent,
      'wish': wish,
      'transit': transit,
      'confirmed': confirmed,
      'distance': distance,
      'title': title,
      'authors': authors,
      'isbn': isbn,
      'image': image,
      'language': language,
      'genre': genre,
      'description': description,
      'coverText': coverText,
      'spineText': spineText,
      'tags': tags,
      'allTags': allTags,
      'keys': keys.toList(),
    };
    }
  }

  bool get isEmpty {
    return !hasAuthor && ! hasTitle;
  }

  bool get hasTitle {
    return title != null && title.isNotEmpty;
  }

  bool get hasAuthor {
    return authors != null && authors.length > 0;
  }

  bool get hasCover {
    return image != null && image.isNotEmpty;
  }

  bool get hasCoverText {
    return coverText != null && coverText.isNotEmpty;
  }

  bool get hasLanguage {
    return language != null && language.isNotEmpty;
  }

  bool get hasDescription {
    return description != null && description.isNotEmpty;
  }

  bool get isComplete {
    return !isEmpty && hasCover && hasLanguage && hasDescription;
  }

  bool get isOwn {
    return ownerId == B.user.id && !lent && !wish;
  }

  bool get isWish {
    return ownerId == B.user.id && wish && !lent;
  }

  bool get isLent {
    return ownerId == B.user.id && ownerId != holderId && lent && !wish;
  }

  bool get isBorrowed {
    return holderId == B.user.id && ownerId != holderId && lent && !wish;
  }

  BookrecordType get type {
    if (isOwn)
      return BookrecordType.own;
    else if (isLent)
      return BookrecordType.lent;
    else if (isBorrowed)
      return BookrecordType.borrowed;
    else if (isWish)
      return BookrecordType.wish;
    else
      return BookrecordType.none;
  }

  BookIntent intent({@required String me, @required String him}) {
    if (holderId == me && ownerId != him)
      // Books with the user which does not belong to me
      return BookIntent.Offer;
    else if (holderId == him && ownerId != me)
      // Books with me which belong to the user
      return BookIntent.Request;
    else if (holderId == me && ownerId == him)
      // Books with the user which belong to me
      return BookIntent.Return;
    else if (holderId == him && ownerId == me)
      // Books with him which belong to me
      return BookIntent.Remind;
    else
      return BookIntent.None;
  }

  User get holder {
    return User(id: holderId, name: holderName, photo: holderImage);
  }

  User get owner {
    return User(id: ownerId, name: ownerName, photo: ownerImage);
  }

  bool get complete {
    return isbn == null && title == null ||
        image == null ||
        ownerId == null ||
        ownerName == null ||
        ownerImage == null ||
        holderId == null ||
        holderName == null ||
        holderImage == null;
  }

  // Copy all values from other bookrecord
  void copyFrom(Bookrecord rec) {
    id = rec.id;
    ownerId = rec.ownerId;
    ownerName = rec.ownerName;
    ownerImage = rec.ownerImage;
    holderId = rec.holderId;
    holderName = rec.holderName;
    holderImage = rec.holderImage;
    users = rec.users;
    isbn = rec.isbn;
    location = rec.location;
    matched = rec.matched;
    matchedId = rec.matchedId;
    chatId = rec.chatId;
    lent = rec.lent;
    wish = rec.wish;
    transit = rec.transit;
    confirmed = rec.confirmed;
    distance = rec.distance;
    title = rec.title;
    authors = rec.authors;
    image = rec.image;
    keys = rec.keys;
    fromDb = rec.fromDb;
  }

  // Copy all values from other bookrecord
  bool equalsTo(Bookrecord rec) {
    // keys and authors are excluded as no simple way to compare lists
    return id == rec.id &&
        ownerId == rec.ownerId &&
        ownerName == rec.ownerName &&
        ownerImage == rec.ownerImage &&
        holderId == rec.holderId &&
        holderName == rec.holderName &&
        holderImage == rec.holderImage &&
        users == rec.users &&
        isbn == rec.isbn &&
        location == rec.location &&
        matched == rec.matched &&
        matchedId == rec.matchedId &&
        chatId == rec.chatId &&
        lent == rec.lent &&
        wish == rec.wish &&
        transit == rec.transit &&
        confirmed == rec.confirmed &&
        distance == rec.distance &&
        title == rec.title &&
        image == rec.image;
  }

  Stream<Bookrecord> snapshots() async* {
    // Data are not from DB
    if (!fromDb && !complete) {
      final DocumentSnapshot snap = await ref.get();
      if (snap.exists) {
        Bookrecord rec = Bookrecord.fromJson(snap.data);
        if (!this.equalsTo(rec)) {
          copyFrom(rec);
          yield this;
        }
        fromDb = true;
      }
    }

    assert(isbn != null && ownerId != null && holderId != null);

    bool changed = false;

    // Owner data is not complete need to read original record
    if (ownerName == null || ownerImage == null) {
      final DocumentSnapshot snap = await User.Ref(ownerId).get();
      if (snap.exists) {
        User rec = User.fromJson(snap.data);
        if (ownerName != rec.name || ownerImage != rec.photo) {
          ownerName = rec.name;
          ownerImage = rec.photo;
          if (holderId == ownerId) {
            holderName = rec.name;
            holderImage = rec.photo;
          }

          changed = true;
        }
      }
    }

    // Owner data is not complete need to read original record
    if (holderId != ownerId && (holderName == null || holderImage == null)) {
      final DocumentSnapshot snap = await User.Ref(holderId).get();
      if (snap.exists) {
        User rec = User.fromJson(snap.data);
        if (holderName != rec.name || holderName != rec.photo) {
          holderName = rec.name;
          holderImage = rec.photo;

          changed = true;
        }
      }
    }

    if (changed) {
      // If data updated send it to stream and update record in DB
      yield this;
      ref.updateData(toJson());
    }
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
  List<String> ids;
  DateTime timestamp;
  String message;
  Map<String, int> unread;
  String fromId;
  String fromName;
  String fromImage;
  String toId;
  String toName;
  String toImage;

  bool fromDb;

  Messages({@required User from, User to}) {
    assert(from != null && to != null);

    fromId = from.id;
    fromName = from.name;
    fromImage = from.photo;

    if (to != null) {
      toId = to.id;
      toName = to.name;
      toImage = to.photo;
    }

    ids = <String>[fromId, toId];
    id = this.ref.documentID;

    timestamp = DateTime.now();
    unread = {fromId: 0, 'system': 0};

    fromDb = false;
  }

  Messages.fromJson(Map json, DocumentSnapshot doc)
      : ids = json['ids']?.cast<String>(),
        message = json['message'],
        timestamp = new DateTime.fromMillisecondsSinceEpoch(
            int.parse(json['timestamp'])),
        unread = json['unread'] != null
            ? Map<String, int>.from(json['unread'])
            : null,
        fromId = json['fromId'],
        fromName = json['fromName'],
        fromImage = json['fromImage'],
        toId = json['toId'],
        toName = json['toName'],
        toImage = json['toImage'] {
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
      'ids': [fromId, toId],
      'message': message,
      'timestamp': Timestamp.now().millisecondsSinceEpoch.toString(),
      'unread': unread,
      'fromId': fromId,
      'fromName': fromName,
      'fromImage': fromImage,
      'toId': toId,
      'toName': toName,
      'toImage': toImage,
    };
  }

  /*
  // Return userId of the counterparty
  bool get toMe {
    return toId == B.user.id;
  }

  bool get fromMe {
    return fromId == B.user.id;
  }
  */

  // Return userId of the counterparty
  String get partnerId {
    assert(B.user.id == fromId || B.user.id == toId);
    return B.user.id == ids[0] ? ids[1] : ids[0];
  }

  /*
  User get to {
    return User(id: toId, name: toName, photo: toImage);
  }

  User get from {
    return User(id: fromId, name: fromName, photo: fromImage);
  }
  */

  // Return name of the peer
  String get partnerName {
    assert(B.user.id == fromId || B.user.id == toId);
    return (fromId == B.user.id) ? toName : fromName;
  }

  // Return image of the peer
  String get partnerImage {
    assert(B.user.id == fromId || B.user.id == toId);
    return (fromId == B.user.id) ? toImage : fromImage;
  }

  void reset() {
    unread = {for (var i in ids) i: 0};
    timestamp = DateTime.now();
  }

  bool get complete {
    return toId != null && toName != null ||
        toImage != null ||
        fromId != null ||
        fromName != null ||
        fromImage != null;
  }

  bool equalsTo(Messages rec) {
    // books, unread and ids excluded from comparison (no simple way to compare lists)
    // handover excluded as it's not used
    return message == rec.message &&
        timestamp == rec.timestamp &&
        fromId == rec.fromId &&
        fromName == rec.fromName &&
        fromImage == rec.fromImage &&
        toId == rec.toId &&
        toName == rec.toName &&
        toImage == rec.toImage;
  }

  void copyFrom(Messages rec) {
    message = rec.message;
    timestamp = rec.timestamp;
    fromId = rec.fromId;
    fromName = rec.fromName;
    fromImage = rec.fromImage;
    toId = rec.toId;
    toName = rec.toName;
    toImage = rec.toImage;
    ids = rec.ids;
    unread = rec.unread;
  }

  Stream<Messages> snapshots() async* {
    // Check if data from DB
    if (!fromDb) {
      final DocumentSnapshot snap = await ref.get();
      if (snap.exists) {
        Messages rec = Messages.fromJson(snap.data, snap);
        if (!this.equalsTo(rec)) {
          copyFrom(rec);
          yield this;
        }
        fromDb = true;
      } else {
        // Chat does not exist in DB create it
        ref.setData(toJson());
      }
    }

    assert(fromId != null && toId != null);
    bool changed = false;

    // FROM user data is not complete need to read original record
    if (fromName == null || fromImage == null) {
      final DocumentSnapshot snap = await User.Ref(fromId).get();
      if (snap.exists) {
        User rec = User.fromJson(snap.data);
        if (fromName != rec.name || fromImage != rec.photo) {
          fromName = rec.name;
          fromImage = rec.photo;

          changed = true;
        }
      }
    }

    // TO user data is not complete need to read original record
    if (toName == null || toImage == null) {
      final DocumentSnapshot snap = await User.Ref(toId).get();
      if (snap.exists) {
        User rec = User.fromJson(snap.data);
        if (toName != rec.name || toName != rec.photo) {
          toName = rec.name;
          toImage = rec.photo;

          changed = true;
        }
      }
    }

    if (changed) {
      // If data updated send it to stream and update record in DB
      yield this;
      ref.updateData(toJson());
    }
  }

  DocumentReference get ref {
    if (id != null)
      return db.collection('messages').document(id);
    else
      return db
          .collection('messages')
          .document(idFromTo(fromId, toId));
  }

  static DocumentReference Ref(String id) {
    //return db.collection('messages').document(idFromTo(from, to));
    return db.collection('messages').document(id);
  }

  // Build chat Id from to and from ids (any sequence)
  static String idFromTo(String from, String to) {
    return ([from, to]..sort()).join(':');
  }
}

Set<String> getKeys(String s) {
  List<String> keys = s
      .toLowerCase()
      .split(new RegExp(r"[\s,!?:;.]+"))
      .where((s) => s.length > 2)
      .toList();
  keys.sort((a, b) => b.length - a.length);
  if (keys == null) keys = <String>[];
  return keys.toSet();
}

Future<GeoPoint> currentPosition() async {
  try {
    final position = await Geolocator().getLastKnownPosition();
    B.position = position;
    if (position != null)
      return new GeoPoint(position.latitude, position.longitude);
    else
      return null;  
  } on PlatformException catch (e, stack) {
      Crashlytics.instance.recordError(e, stack);
    print("POSITION: GeoPisition failed ${e} ${stack}");
    return null;
  }
}

Future<GeoFirePoint> currentLocation() async {
  try {
    final position = await Geolocator().getLastKnownPosition();
    B.position = position;
    if (position != null)
      return Geoflutterfire()
          .point(latitude: position.latitude, longitude: position.longitude);
    else
      return null;    
  } on PlatformException catch (e, stack) {
      Crashlytics.instance.recordError(e, stack);
    print("POSITION: GeoPisition failed ${e} ${stack}");
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

//TODO: Not sure it's good idea to have it as global valiables. Need to find
// better way. Hwever to have it in widget is not good idea either as it used
// from Goodreads import as well.
//TODO: Where to close such clients
class LibConnect {
  static Client _googleClient;
  static BooksApi _booksApi;
  static Client _commonClient;
  static Client _cloudFunctionClient;

  static Client getClient() {
    if (_commonClient == null) _commonClient = new Client();
    return _commonClient;
  }

  static Client getCloudFunctionClient() {
    if (_cloudFunctionClient == null) _cloudFunctionClient = new Client();
    return _cloudFunctionClient;
  }

  static BooksApi getGoogleBookApi() {
    if (_googleClient == null)
      _googleClient =
          clientViaApiKey('AIzaSyDJR_BnU_JVJyGTfaWcj086UuQxXP3LoTU');

    if (_booksApi == null) _booksApi = new BooksApi(_googleClient);

    return _booksApi;
  }
}
