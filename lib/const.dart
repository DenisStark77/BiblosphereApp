import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:googleapis/books/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';

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

class Book {
  String id;
  String title;
  List<String> authors;
  String isbn;
  String image;

  Book(
      {this.id,
      @required this.title,
      @required this.authors,
      @required this.isbn,
      this.image});

  Book.volume(Volume v) {
    try {
      if (v.volumeInfo.imageLinks != null)
        image = v.volumeInfo.imageLinks.thumbnail;
      title = v.volumeInfo.title;
      authors = v.volumeInfo.authors;
      //TODO: what if ISBN_13 missing?
      var industryIds = v.volumeInfo.industryIdentifiers;
      if (industryIds != null) {
        var isbnId = industryIds.firstWhere((test) => test.type == 'ISBN_13');
        if (isbnId != null) isbn = isbnId.identifier;
      }
    } catch (e) {
      print('Unknown error: $e');
    }
  }

  Book.fromJson(Map json)
      : id = json['id'],
        title = json['title'],
        authors = (json['authors'] as List).cast<String>(),
        isbn = json['isbn'],
        image = json['image'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'authors': authors,
      'isbn': isbn,
      'image': image
    };
  }
}

class User {
  String id;
  String name;
  String photo;
  GeoPoint position;
  int wishCount=0;
  int bookCount=0;
  int shelfCount=0;
  double d;

  User(
      {@required this.id,
      @required this.name,
      @required this.photo,
      @required this.position});

  User.fromJson(Map json)
      : id = json['id'],
        name = json['name'],
        photo = json['photo'],
        position = json['position'] as GeoPoint,
        wishCount = json['wishCount']??0,
        bookCount = json['bookCount']??0,
        shelfCount = json['shelfCount']??0;

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'photo': photo, 'position': position};
  }
}

class Bookcopy {
  String id;
  User owner;
  Book book;
  GeoPoint position;
  bool matched;
  String wishId;
  User wisher;
  double distance;
  double d;

  Bookcopy(
      {@required this.owner,
      @required this.book,
      @required this.position,
      this.matched = false,
      this.wishId,
      this.wisher,
      this.distance});

  Bookcopy.fromJson(Map json)
      : id = json['id'],
        owner = User.fromJson(json['owner']),
        book = Book.fromJson(json['book']),
        position = json['position'] as GeoPoint,
        matched = json['matched'],
        wishId = json['wishId'],
        wisher = json['wisher'] != null ? User.fromJson(json['wisher']) : null,
        distance = json['distance'] != null ? (json['distance'] as num).toDouble() : double.infinity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner': owner.toJson(),
      'book': book.toJson(),
      'position': position,
      'matched': matched,
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
  bool matched;
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
        matched = json['matched'],
        bookcopyId = json['bookcopyId'],
        bookcopyPosition = json['bookcopyPosition'] as GeoPoint,
        owner = json['owner'] != null ? User.fromJson(json['owner']) : null,
        distance = json['distance'] != null ? (json['distance'] as num).toDouble() : double.infinity;

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

//Callback function type definition
typedef BookCallback(Book book);

Future addBook(Book b, User u, GeoPoint position, {String source='goodreads'}) async {
  bool existingBook = false;
  String bookId;
  QuerySnapshot q = await Firestore.instance
      .collection('books')
      .where('book.isbn', isEqualTo: b.isbn)
      .getDocuments();

  if (q.documents.isEmpty) {
    DocumentReference d = await Firestore.instance
        .collection('books')
        .add({'book': b.toJson(), 'source': source});

    b.id = d.documentID;
    existingBook = true;
  } else {
    b.id = q.documents.first.documentID;
  }

  //Check if bookcopy already exist. Make sense only if isb is registered
  if (existingBook) {
    QuerySnapshot q = await Firestore.instance
        .collection('bookcopies')
        .where('book.id', isEqualTo: b.id)
        .where('owner.id', isEqualTo: u.id)
        .getDocuments();

    //Bookcopy already exist
    if (q.documents.isNotEmpty) return;
  }

  Bookcopy bookcopy = new Bookcopy(
      owner: u,
      book: b,
      position: position);

  await Firestore.instance
      .collection('bookcopies')
      .add(bookcopy.toJson());
}

Future addWish(Book b, User u, GeoPoint position, {String source='goodreads'}) async {
  bool existingBook = false;
  String bookId;
  QuerySnapshot q = await Firestore.instance
      .collection('books')
      .where('book.isbn', isEqualTo: b.isbn)
      .getDocuments();

  if (q.documents.isEmpty) {
    DocumentReference d = await Firestore.instance
        .collection('books')
        .add({'book': b.toJson(), 'source': source});

    b.id = d.documentID;
    existingBook = true;
  } else {
    b.id = q.documents.first.documentID;
  }

  //Check if bookcopy already exist. Make sense only if isb is registered
  if (existingBook) {
    QuerySnapshot q = await Firestore.instance
        .collection('wishes')
        .where('book.id', isEqualTo: b.id)
        .where('wisher.id', isEqualTo: u.id)
        .getDocuments();

    //Bookcopy already exist
    if (q.documents.isNotEmpty) return;
  }

  Wish wish = new Wish(
      wisher: u,
      position: u.position,
      book: b,
      created: getTimestamp());

  await Firestore.instance
      .collection('wishes')
      .add(wish.toJson());
}

final themeColor = new Color(0xfff5a623);
final primaryColor = new Color(0xff203152);
final greyColor = new Color(0xffaeaeae);
final greyColor2 = new Color(0xffE8E8E8);

Future scanIsbn(BuildContext context) async {
  try {
    String barcode = await BarcodeScanner.scan();
    print("Isbn: $barcode");

    /*
      //Account credentials are in JSON key file
      final accountCredentials = new ServiceAccountCredentials.fromJson({
        "private_key_id": "ADD HERE",
        "private_key": "ADD HERE",
        "client_email": "biblosphere-210106@appspot.gserviceaccount.com",
        "client_id": "106972658678192953965",
        "type": "service_account"
      });

      var scopes = ['https://www.googleapis.com/auth/books'];

      clientViaServiceAccount(accountCredentials, scopes).then((AuthClient client) async {
        BooksApi booksApi = new BooksApi(client);

        print("Books Api initialized: $booksApi");

        Volumes books = await booksApi.volumes.list('+isbn:$barcode');

        print("Volumes: ${books.toJson()}");

        books.items.forEach((book) => print("Book title: ${book.volumeInfo.title}"));

        client.close();
      });

      //TODO: avoid calls using ApiKey as it is not protected from others calling
      //      our service and use quota. See option above.
      Map<String, String> headers = await googleSignIn.currentUser.authHeaders;
      print("HEADERS: ${headers.toString()}");
      print("SCOPES: ${googleSignIn.scopes.toString()}");

      GoogleSignInAuthentication auth = await googleSignIn.currentUser.authentication;
      print("ACCESS TOKEN: ${auth.accessToken}");
      print("ID TOKEN: ${auth.idToken}");

      Client baseClient = new Client();
      AccessCredentials credentials = new AccessCredentials(new AccessToken("Bearer", auth.accessToken, DateTime.now().toUtc().add(new Duration(days: 1))), null, googleSignIn.scopes);
      AuthClient client = authenticatedClient(baseClient, credentials);
*/

    var client = clientViaApiKey('AIzaSyDJR_BnU_JVJyGTfaWcj086UuQxXP3LoTU');

    BooksApi booksApi = new BooksApi(client);

    Volumes books = await booksApi.volumes.list('isbn:$barcode');

    if (books.items != null) {
      final String title = books.items[0].volumeInfo.title;
      final String author = books.items[0].volumeInfo.authors.join(", ");
      final String image = books.items[0].volumeInfo.imageLinks.thumbnail;

/*
      final position = await Geolocator().getLastKnownPosition();

      //Create record in Firestore database with location, URL, and book details
      await Firestore.instance.collection('books').add({
        "user": currentUserId,
        "userName": currentUserName,
        'URL': image,
        'isbn': barcode,
        'title': title,
        'author': author,
        'position': new GeoPoint(position.latitude, position.longitude)
      });
*/
    } else {
      print("No record found for isbn: $barcode");
    }
    client.close();
  } on PlatformException catch (e) {
    if (e.code == BarcodeScanner.CameraAccessDenied) {
      print('The user did not grant the camera permission!');
    } else {
      print('Unknown error: $e');
    }
  } on FormatException {
    print(
        'null (User returned using the "back"-button before scanning anything. Result)');
  } catch (e) {
    print('Unknown error: $e');
  }
}

class EnterBook extends StatefulWidget {
  EnterBook({Key key, @required this.title, @required this.onConfirm, this.scan = true, this.search = true}) : super(key: key);

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
  Client client;
  BooksApi booksApi;
  TextEditingController textController;

  @override
  void initState() {
    super.initState();

    textController = new TextEditingController();
    textController.addListener(searchAutocomplete);

    client = clientViaApiKey('AIzaSyDJR_BnU_JVJyGTfaWcj086UuQxXP3LoTU');
    booksApi = new BooksApi(client);
  }

  @override
  void dispose() {
    client.close();
    textController.dispose();
    super.dispose();
  }

  _EnterBookState();

  searchAutocomplete() async {
    String text = textController.text;
    if (text.length > 5) {
      List<Book> newSuggestions = [];
      Volumes books =
          await booksApi.volumes.list(text, printType: 'books', maxResults: 10);

      if (books.items.isNotEmpty) {
        books.items.forEach((Volume v) {
          if (v.volumeInfo.title != null &&
              v.volumeInfo.authors != null &&
              v.volumeInfo.authors.isNotEmpty &&
              v.volumeInfo.imageLinks != null &&
              v.volumeInfo.imageLinks.thumbnail != null &&
              v.volumeInfo.industryIdentifiers != null &&
              v.volumeInfo.industryIdentifiers
                      .firstWhere((test) => test.type == 'ISBN_13') !=
                  null &&
              v.saleInfo != null &&
              !v.saleInfo.isEbook) {
            print('BOOK WITH FULL DATA: ${v.volumeInfo.title}');
            newSuggestions.add(new Book.volume(v));
          }
        });
      }

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
                            child: Text(
                                'Scan ISBN from the back of the book',
                                style: Theme.of(context).textTheme.body1)),
                        RaisedButton(
                          textColor: Colors.white,
                          color: Theme.of(context).colorScheme.secondary,
                          child: new Icon(MyIcons.barcode),
                          onPressed: () {
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
                            child: TextField(
                          maxLines: 1,
                          controller: textController,
                          style: Theme.of(context).textTheme.body1,
                          decoration:
                              InputDecoration(hintText: 'Enter title/author'),
                        )),
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
                                onTap: () {
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
                                            b.image),
                                        width: 25,
                                        fit: BoxFit.cover),
                                  ),
                                  Expanded(
                                      child: Container(
                                          margin: EdgeInsets.only(left: 3.0),
                                          child: Text(
                                              '\'${b.title}\' by ${b.authors[0]}')))
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
                        image: new CachedNetworkImageProvider(book.image),
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
                child:
                    new Text('Add', style: Theme.of(context).textTheme.title),
                onPressed: () {
                  print('Book \'${book.title}\' to be added.');
                  bookToAdd = null;
                  textController.clear();
                  widget.onConfirm(book);
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              ),
            ),
          ],
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0));
    ;
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
            child: Text('Ok'),
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

Future<GeoPoint> currentPosition() async {
  try {
    final position = await Geolocator().getLastKnownPosition();
    return new GeoPoint(position.latitude, position.longitude);
  } on PlatformException {
    print("POSITION: GeoPisition failed");
    return null;
  }
}
