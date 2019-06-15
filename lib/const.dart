import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:googleapis/books/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:xml/xml.dart' as xml;
import 'dart:convert';

import 'package:biblosphere/l10n.dart';

const String sharingUrl =
    'https://biblosphere.org/images/phone-app-screens-2000.png';

const String nocoverUrl =
    'https://firebasestorage.googleapis.com/v0/b/biblosphere-210106.appspot.com/o/images%2Fnocover.png?alt=media&token=fb68e614-d34e-4b47-bf2c-47e742b4786d';

String getTimestamp() => new DateTime.now().millisecondsSinceEpoch.toString();

class MyIcons {
  static const fontFamily = 'MyIcons';

  static const IconData money = const IconData(0xf14d, fontFamily: fontFamily);
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
}

enum AppActivity { books, shelves, wished, people, give, earn }

enum UserAction { getBook, returnBook, giveBook, confirmHandover }

class UserActionRecord {
  UserActionRecord(this.bookId, this.bookTitle, this.bookImage, this.userId,
      this.userName, this.on, this.action);

  String bookId;
  String bookTitle;
  String bookImage;
  String userId;
  String userName;
  DateTime on;
  UserAction action;
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
  String genre;
  String language;

  Book(
      {this.id,
      @required this.title,
      @required this.authors,
      @required this.isbn,
      this.image});

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
      source = BookSource.google;
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
  }

  Book.fromJson(Map json)
      : id = json['id'],
        title = json['title'],
        authors = (json['authors'] as List).cast<String>(),
        isbn = json['isbn'],
        image = json['image'],
        price = json['price'],
        language = json['language'],
        genre = json['genre'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'authors': authors,
      'isbn': isbn,
      'image': image,
      'price': price,
      'genre': genre,
      'language': language
    };
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
        photo = json['photo'],
        position = json['position'] as GeoPoint,
        wishCount = json['wishCount'] ?? 0,
        bookCount = json['bookCount'] ?? 0,
        shelfCount = json['shelfCount'] ?? 0,
        balance =
            json['balance'] != null ? (json['balance'] as num).toDouble() : 0;

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'photo': photo, 'position': position};
  }
}

class Bookcopy {
  String id;
  User owner;
  User holder;
  Book book;
  GeoPoint position;
  String status;
  bool matched=false;
  bool lent=false;
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
        matched = json['matched']??false,
        lent = json['lent']??false,
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
  bool matched=false;
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
        matched = json['matched']??false,
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

Future addBook(BuildContext context, Book b, User u, GeoPoint position,
    {String source = 'goodreads', bool snackbar = true}) async {
  bool existingBook = false;

  if (b.isbn == null || b.isbn == 'NA')
    throw 'Book ${b?.title}, ${b?.authors?.join()} has no ISBN';

  //Try to get image if missing
  if (b.image == null || b.image.isEmpty || b.language == null || b.language.isEmpty ) {
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

  Bookcopy bookcopy = new Bookcopy(owner: u, book: b, position: position);

  //Check if bookcopy already exist. Make sense only if isb is registered
  if (existingBook) {
    QuerySnapshot q = await Firestore.instance
        .collection('bookcopies')
        .where('book.id', isEqualTo: b.id)
        .where('owner.id', isEqualTo: u.id)
        .getDocuments();

    //If bookcopy already exist refresh it
    if (q.documents.isNotEmpty) {
      bookcopy.id = q.documents.first.documentID;
      await Firestore.instance
          .collection('bookcopies')
          .document(bookcopy.id)
          .updateData(bookcopy.toJson());
      return;
    }
  }

  await Firestore.instance.collection('bookcopies').add(bookcopy.toJson());
  if (snackbar) showSnackBar(context, S.of(context).bookAdded);
  await FirebaseAnalytics().logEvent(
      name: 'add_book',
      parameters: <String, dynamic>{
        'language': bookcopy.book.language??''
      });
}

Future addWish(BuildContext context, Book b, User u, GeoPoint position,
    {String source = 'goodreads', bool snackbar = true}) async {
  bool existingBook = false;

  if (b.isbn == null || b.isbn == 'NA')
    throw 'Book ${b?.title}, ${b?.authors?.join()} has no ISBN';

  //Try to get image if missing
  if (b.image == null || b.image.isEmpty || b.language == null || b.language.isEmpty ) {
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

  Wish wish = new Wish(
      wisher: u, position: u.position, book: b, created: getTimestamp());

  //Check if wish already exist. Make sense only if isb is registered
  if (existingBook) {
    QuerySnapshot q = await Firestore.instance
        .collection('wishes')
        .where('book.id', isEqualTo: b.id)
        .where('wisher.id', isEqualTo: u.id)
        .getDocuments();

    if (q.documents.isNotEmpty) {
      wish.id = q.documents.first.documentID;
      await Firestore.instance
          .collection('wishes')
          .document(wish.id)
          .updateData(wish.toJson());
      return;
    }
  }

  await Firestore.instance.collection('wishes').add(wish.toJson());
  if (snackbar) showSnackBar(context, S.of(context).wishAdded);
  // Log event for the analytics
  await FirebaseAnalytics().logEvent(
      name: 'add_wish',
      parameters: <String, dynamic>{
        'language': wish.book.language??''
      });
}

Future startTransit(BuildContext context, String bookcopyId, User from, User to,
    String action) async {
  // Create firestore transaction
  // Check that status of bookcopy is 'available'
  // Change status of bookcopy to 'transit'
  // Create and store transit record

  final DocumentReference bookcopyRef =
      Firestore.instance.document('bookcopies/${bookcopyId}');

  print('DEBUG: transit bookcopy id: ${bookcopyRef.documentID}');

  try {
    Firestore.instance.runTransaction((Transaction tx) async {
      DocumentSnapshot bookcopySnapshot = await tx.get(bookcopyRef);
      print('DEBUG: transit bookcopy snapshot: ${bookcopySnapshot}');
      if (bookcopySnapshot.exists) {
        Bookcopy fresh = new Bookcopy.fromJson(bookcopySnapshot.data);
        print('DEBUG: transit bookcopy: ${fresh}');
        String status;
        if (fresh.status == 'available') {
          // Adjust status
          if (action == 'request')
            status = 'requested';
          else if (action == 'return' || action == 'offer') status = 'accepted';
          // Autogenerate new reference
          final DocumentReference transitRef =
              Firestore.instance.collection('transit').document();
          print('DEBUG: transit referrence: ${transitRef.documentID}');
          // Create transit record and insert it to Firestore
          Transit transit = new Transit(
              id: transitRef.documentID,
              bookcopy: fresh,
              from: from,
              to: to,
              action: action,
              status: status);
          print('DEBUG: transit record: ${transit}');
          await tx.update(bookcopyRef, {'status': 'transit'});
          await tx.set(transitRef, transit.toJson());
          print('DEBUG: transit record updated');
          showSnackBar(context, S.of(context).transitInitiated);
          // Log event for the analytics
          await FirebaseAnalytics().logEvent(
              name: '${action}_book',
              parameters: <String, dynamic>{
                'language': fresh.book.language??''
              });

        } else {
          print('DEBUG: book already in transit: ${bookcopyRef.documentID}');
        }
      }
    });
  } catch (e) {
    print('DEBUG: Exception happens: ${e}');
  }
}

Future changeTransit(Transit t, User user, String step) async {
  // Create firestore transaction
  // Check that status of transit
  // Validate if step is valid and calculate next status
  // Update transit record
  // Commit transaction

  print('DEBUG: User id: ${user.id}, step: ${step}');

  final DocumentReference transitRef =
      Firestore.instance.document('transit/${t.id}');

  await Firestore.instance.runTransaction((Transaction tx) async {
    DocumentSnapshot transitSnapshot = await tx.get(transitRef);
    if (transitSnapshot.exists) {
      Transit tr = new Transit.fromJson(transitSnapshot.data);
      // Input transit record inconsistent with Firestore record
      if (tr.status != t.status || tr.action != t.action)
        // TODO: Not sure should I throw exception or just return new record to get transit Widget refreshed.
        //throw 'Transit record in db has been changed';
        return;

      bool toUpdate = false;
      bool toDelete = false;
      String nextStatus;

      print('DEBUG: TO user: ${tr.to.id}, FROM user: ${tr.from.id}');

      if (tr.action == Transit.Request &&
          tr.status == Transit.Requested &&
          user.id == tr.to.id) {
        // Cancel
        if (step == Transit.Cancel) {
          toDelete = true;
        }
      } else if (tr.action == Transit.Request &&
          tr.status == Transit.Requested &&
          user.id == tr.from.id) {
        // Accept, Reject
        if (step == Transit.Accept) {
          toUpdate = true;
          nextStatus = Transit.Accepted;
        } else if (step == Transit.Reject) {
          toUpdate = true;
          nextStatus = Transit.Rejected;
        }
      } else if (tr.action == Transit.Request &&
          tr.status == Transit.Accepted &&
          user.id == tr.to.id) {
        // Confirm, Cancel
        if (step == Transit.Confirm) {
          toUpdate = true;
          nextStatus = Transit.Confirmed;
        } else if (step == Transit.Cancel) {
          toUpdate = true;
          nextStatus = Transit.Canceled;
        }
      } else if (tr.action == Transit.Request &&
          tr.status == Transit.Accepted &&
          user.id == tr.from.id) {
        // Reject
        if (step == Transit.Reject) {
          toUpdate = true;
          nextStatus = Transit.Rejected;
        }
      } else if (tr.action == Transit.Request &&
          tr.status == Transit.Confirmed &&
          user.id == tr.from.id) {
        // Ok
        if (step == Transit.Ok) toDelete = true;
      } else if (tr.action == Transit.Request &&
          tr.status == Transit.Rejected &&
          user.id == tr.to.id) {
        // Ok
        if (step == Transit.Ok) toDelete = true;
      } else if (tr.action == Transit.Request &&
          tr.status == Transit.Canceled &&
          user.id == tr.from.id) {
        // Ok
        if (step == Transit.Ok) toDelete = true;
      } else if (tr.action == Transit.Return &&
          tr.status == Transit.Accepted &&
          user.id == tr.from.id) {
        // Cancel
        if (step == Transit.Cancel) toDelete = true;
      } else if (tr.action == Transit.Return &&
          tr.status == Transit.Accepted &&
          user.id == tr.to.id) {
        // Confirm
        if (step == Transit.Confirm) {
          toUpdate = true;
          nextStatus = Transit.Confirmed;
        }
      } else if (tr.action == Transit.Return &&
          tr.status == Transit.Confirmed &&
          user.id == tr.from.id) {
        // Ok
        if (step == Transit.Ok) toDelete = true;
      } else if (tr.action == Transit.Offer &&
          tr.status == Transit.Accepted &&
          user.id == tr.from.id) {
        // Cancel
        if (step == Transit.Cancel) toDelete = true;
      } else if (tr.action == Transit.Offer &&
          tr.status == Transit.Accepted &&
          user.id == tr.to.id) {
        // Confirm, Reject
        if (step == Transit.Confirm) {
          toUpdate = true;
          nextStatus = Transit.Confirmed;
        } else if (step == Transit.Reject) {
          toUpdate = true;
          nextStatus = Transit.Rejected;
        }
      } else if (tr.action == Transit.Offer &&
          tr.status == Transit.Confirmed &&
          user.id == tr.from.id) {
        // Ok
        if (step == Transit.Ok) toDelete = true;
      } else if (tr.action == Transit.Offer &&
          tr.status == Transit.Rejected &&
          user.id == tr.from.id) {
        // Ok
        if (step == Transit.Ok) toDelete = true;
      }

      print(
          'Action: ${tr.action}, Status: ${tr.status}, NextStatus: ${nextStatus}, Delete: ${toDelete}, Update: ${toUpdate}');

      if (toUpdate) {
        if (step == Transit.Confirm) {
          bool lent=false;
          // Update bookcopy holder and status
          if (tr.action == Transit.Return) {
            lent = false;
          } else if (tr.action == Transit.Request ||
              tr.action == Transit.Offer) {
            lent = true;
          }
          //TODO: Use firestore increment to avoid reading (only available from version 0.10 of cloud_firestore)
          final DocumentReference fromRef =
              Firestore.instance.document('users/${tr.from.id}');
          final DocumentReference toRef =
              Firestore.instance.document('users/${tr.to.id}');
          final DocumentReference sysRef =
              Firestore.instance.document('system/commission');

          DocumentSnapshot fromSnapshot = await tx.get(fromRef);
          DocumentSnapshot toSnapshot = await tx.get(toRef);
          DocumentSnapshot sysSnapshot = await tx.get(sysRef);

          await tx
              .update(fromRef, {"balance": fromSnapshot.data['balance'] + 4});
          await tx.update(toRef, {"balance": toSnapshot.data['balance'] - 5});
          await tx.update(sysRef, {"balance": sysSnapshot.data['balance'] + 1});

          final DocumentReference bookcopyRef = Firestore.instance
              .collection('bookcopies')
              .document(tr.bookcopy.id);
          await tx.update(bookcopyRef,
              {'lent': lent, 'status': 'available', 'holder': tr.to.toJson()});
        }
        await tx.update(transitRef, {'status': nextStatus});
      } else if (toDelete) {
        tx.delete(transitRef);
      }
    }
  });

  if (step == Transit.Confirm) {
    // Log event for the analytics
    await FirebaseAnalytics().logEvent(
        name: 'handover_book',
        parameters: <String, dynamic>{
          'language': t.bookcopy.book.language ?? ''
        });
  } else if (step == Transit.Reject) {
    // Log event for the analytics
    await FirebaseAnalytics().logEvent(
        name: 'reject_request_book',
        parameters: <String, dynamic>{
          'language': t.bookcopy.book.language ?? ''
        });

  }
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

class EnterBook extends StatefulWidget {
  EnterBook(
      {Key key,
      @required this.title,
      @required this.onConfirm,
      this.scan = true,
      this.search = true})
      : super(key: key);

  final BookCallback onConfirm;
  final String title;
  final bool scan;
  final bool search;

  @override
  _EnterBookState createState() => new _EnterBookState();
}

class _EnterBookState extends State<EnterBook> {
  List<Book> suggestions = [];
  Book bookToAdd;

  TextEditingController textController;

  @override
  void initState() {
    super.initState();

    textController = new TextEditingController();
    textController.addListener(searchAutocomplete);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  _EnterBookState();

  searchAutocomplete() async {
    String text = textController.text;
    if (text.length > 5) {
      //Goodreads search does not have ISBN in response, so using Google
      //List<Book> newSuggestions = await searchByTitleAuthorGoodreads(text);

      List<Book> newSuggestions = await searchByTitleAuthorGoogle(text);
      setState(() {
        suggestions = newSuggestions;
        bookToAdd = null;
      });
    } else {
      setState(() {
        bookToAdd = null;
      });
      //Clear previous suggestions if new text is typing
      if (suggestions.isNotEmpty) {
        setState(() {
          suggestions.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        color: greyColor2,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Container(
          margin: EdgeInsets.all(10.0),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(widget.title, style: Theme.of(context).textTheme.subtitle),
                widget.scan
                    ? Row(children: <Widget>[
                        Expanded(
                            child: Text(S.of(context).scanISBN,
                                style: Theme.of(context).textTheme.body1)),
                        RaisedButton(
                          textColor: Colors.white,
                          color: Theme.of(context).colorScheme.secondary,
                          child: new Icon(MyIcons.barcode),
                          onPressed: () {
                            setState(() {
                              bookToAdd = null;
                              suggestions.clear();
                            });
                            scanIsbn(context);
                          },
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(20.0)),
                        ),
                      ])
                    : Container(),
                widget.search
                    ? Row(children: <Widget>[
                        Flexible(
                            //Workaround for bug on iOS with paste to text field https://github.com/flutter/flutter/issues/22624
                            child: Theme(
                                data:
                                    ThemeData(platform: TargetPlatform.android),
                                child: TextField(
                                  maxLines: 1,
                                  controller: textController,
                                  style: Theme.of(context).textTheme.body1,
                                  decoration: InputDecoration(
                                      hintText: S.of(context).enterTitle),
                                ))),
                        RaisedButton(
                          textColor: Colors.white,
                          color: Theme.of(context).colorScheme.secondary,
                          child: new Icon(MyIcons.search),
                          onPressed: () {
                            print("X");
                          },
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(20.0)),
                        ),
                      ])
                    : Container(),
//              Expanded(child: Column(children: )),
              ]
                ..addAll(suggestions != null
                    ? suggestions.map((Book b) {
                        return Container(
                            margin: EdgeInsets.all(3.0),
                            child: GestureDetector(
                                onTap: () async {
                                  b = await enrichBookRecord(b);
                                  setState(() {
                                    bookToAdd = b;
                                    suggestions.clear();
                                  });
                                },
                                child: Row(children: <Widget>[
                                  Container(
                                    width: 30,
                                    child: Image(
                                        image: new CachedNetworkImageProvider(
                                            (b.image != null && b.image.isNotEmpty) ? b.image : nocoverUrl),
                                        width: 25,
                                        fit: BoxFit.cover),
                                  ),
                                  Expanded(
                                      child: Container(
                                          margin: EdgeInsets.only(left: 3.0),
                                          child: Text(
                                              '\'${b.title}\' ${b.authors[0]}')))
                                ])));
                      }).toList()
                    : [Container()])
                ..addAll([
                  bookToAdd != null
                      ? confirmBook(context, bookToAdd)
                      : Container()
                ])),
        ));
  }

  Future scanIsbn(BuildContext context) async {
    try {
      String barcode = await BarcodeScanner.scan();

      Book book = await searchByIsbn(barcode);

      if (book == null) {
        book = await searchByIsbnGoodreads(barcode);
      }

      if (book == null) {
        if (barcode.startsWith('9785'))
          book = await searchByIsbnRsl(barcode);
        else
          book = await searchByIsbnGoogle(barcode);
      }

      if (book != null) {
        //Many books on goodreads does not have images. Enreach it from Google
        book = await enrichBookRecord(book);
        setState(() {
          bookToAdd = book;
        });
      } else {
        Firestore.instance.collection('noisbn').add({'isbn': barcode});
        //print("No record found for isbn: $barcode");
        showSnackBar(context, S.of(context).isbnNotFound);
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        print('The user did not grant the camera permission!');
      } else {
        print('Unknown platform error in scanIsbn: $e');
      }
    } on FormatException {
      print(
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      print('Unknown error in scanIsbn: $e');
    }
  }

  Widget confirmBook(BuildContext context, Book book) {
    return new Container(
        child: new Column(
          children: <Widget>[
            new Container(
              child: new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Image(
                        image: new CachedNetworkImageProvider(
                            (book.image != null && book.image.isNotEmpty) ? book.image : nocoverUrl),
                        width: 50,
                        fit: BoxFit.cover),
                    Expanded(
                      child: Container(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(book.authors.join(", "),
                                  style: Theme.of(context).textTheme.caption),
                              Text(book.title,
                                  style: Theme.of(context).textTheme.subtitle),
                            ]),
                        margin: EdgeInsets.all(5.0),
                        alignment: Alignment.topLeft,
                      ),
                    ),
                  ]),
              margin: EdgeInsets.only(top: 7.0, left: 7.0, right: 7.0),
            ),
            new Align(
              alignment: Alignment.centerRight,
              child: RaisedButton(
                textColor: Colors.white,
                color: Theme.of(context).colorScheme.secondary,
                child: new Text(S.of(context).add,
                    style: Theme.of(context).textTheme.title),
                onPressed: () {
                  print('Book \'${book.title}\' to be added.');
                  widget.onConfirm(book);
                  setState(() {
                    bookToAdd = null;
                    textController.clear();
                  });
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              ),
            ),
          ],
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0));
  }
}

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
