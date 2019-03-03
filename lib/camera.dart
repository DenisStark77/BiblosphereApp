import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share/share.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';
import 'package:intl/intl.dart';

import 'package:biblosphere/const.dart';
import 'package:biblosphere/l10n.dart';
import 'package:biblosphere/goodreads.dart';

class MyBook extends StatelessWidget {
  MyBook(this.bookcopy, this.currentUser);

  final Bookcopy bookcopy;
  final User currentUser;

  Future<void> deleteShelf() async {
    try {
      //Delete bookshelf record in Firestore database
      DocumentReference doc = Firestore.instance
          .collection('bookcopies')
          .document("${bookcopy.id}");
      await doc.delete();
    } catch (ex, stack) {
      print('Bookcopy delete failed for [${bookcopy.id}, ${currentUser.id}]: ' +
          ex.toString());
      FlutterCrashlytics().logException(ex, stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new Card(
          child: new Column(
            children: <Widget>[
              new Container(
                child: new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Image(
                          width: 120,
                          image: new CachedNetworkImageProvider(
                              bookcopy.book.image),
                          fit: BoxFit.cover),
                      Expanded(
                        child: Container(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(bookcopy.book.authors.join(', '),
                                    style: Theme.of(context).textTheme.caption),
                                Text(bookcopy.book.title,
                                    style:
                                        Theme.of(context).textTheme.subtitle),
                              ]),
                          margin: EdgeInsets.all(5.0),
                          alignment: Alignment.topLeft,
                        ),
                      ),
                    ]),
                margin: EdgeInsets.only(top: 7.0, left: 7.0, right: 7.0),
              ),
              new Align(
                alignment: Alignment(1.0, 1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    new IconButton(
                      onPressed: deleteShelf,
                      tooltip: S.of(context).deleteShelf,
                      icon: new Icon(MyIcons.trash),
                    ),
/*  Nothing to do in settings right now
                    new IconButton(
                      onPressed: () {},
                      tooltip: S.of(context).shelfSettings,
                      icon: new Icon(MyIcons.settings),
                    ),
*/
                    new IconButton(
                      onPressed: () async {
                        final DynamicLinkParameters parameters =
                            DynamicLinkParameters(
                          domain: 'biblosphere.page.link',
                          link: Uri.parse('https://biblosphere.org'),
                          androidParameters: AndroidParameters(
                            packageName: 'com.biblosphere.biblosphere',
                            minimumVersion: 0,
                          ),
                          dynamicLinkParametersOptions:
                              DynamicLinkParametersOptions(
                            shortDynamicLinkPathLength:
                                ShortDynamicLinkPathLength.short,
                          ),
                          iosParameters: IosParameters(
                            bundleId: 'com.biblosphere.biblosphere',
                            minimumVersion: '0',
                          ),
                          socialMetaTagParameters: SocialMetaTagParameters(
                              title: S.of(context).title,
                              description: S.of(context).shareBooks,
                              imageUrl: Uri.parse(sharingUrl)),
                        );

                        final ShortDynamicLink shortLink =
                            await parameters.buildShortLink();

                        Share.share(shortLink.shortUrl.toString());
                      },
                      tooltip: S.of(context).shareShelf,
                      icon: new Icon(MyIcons.share1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          color: greyColor2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0));
  }
}

class MyWish extends StatelessWidget {
  MyWish(this.wish, this.currentUser);

  final Wish wish;
  final User currentUser;

  Future<void> deleteShelf() async {
    try {
      //Delete bookshelf record in Firestore database
      DocumentReference doc =
          Firestore.instance.collection('wishes').document("${wish.id}");
      await doc.delete();
    } catch (ex, stack) {
      print('Wish delete failed for [${wish.id}, ${currentUser.id}]: ' +
          ex.toString());
      FlutterCrashlytics().logException(ex, stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new Card(
          child: new Column(
            children: <Widget>[
              new Container(
                child: new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Image(
                          width: 120,
                          image:
                              new CachedNetworkImageProvider(wish.book.image),
                          fit: BoxFit.cover),
                      Expanded(
                        child: Container(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(wish.book.authors.join(', '),
                                    style: Theme.of(context).textTheme.caption),
                                Text(wish.book.title,
                                    style:
                                        Theme.of(context).textTheme.subtitle),
                              ]),
                          margin: EdgeInsets.all(5.0),
                          alignment: Alignment.topLeft,
                        ),
                      ),
                    ]),
                margin: EdgeInsets.only(top: 7.0, left: 7.0, right: 7.0),
              ),
              new Align(
                alignment: Alignment(1.0, 1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    new IconButton(
                      onPressed: deleteShelf,
                      tooltip: S.of(context).deleteShelf,
                      icon: new Icon(MyIcons.trash),
                    ),
/*  Nothing to do in settings right now
                    new IconButton(
                      onPressed: () {},
                      tooltip: S.of(context).shelfSettings,
                      icon: new Icon(MyIcons.settings),
                    ),
*/
                    new IconButton(
                      onPressed: () async {
                        final DynamicLinkParameters parameters =
                            DynamicLinkParameters(
                          domain: 'biblosphere.page.link',
                          link: Uri.parse('https://biblosphere.org'),
                          androidParameters: AndroidParameters(
                            packageName: 'com.biblosphere.biblosphere',
                            minimumVersion: 0,
                          ),
                          dynamicLinkParametersOptions:
                              DynamicLinkParametersOptions(
                            shortDynamicLinkPathLength:
                                ShortDynamicLinkPathLength.short,
                          ),
                          iosParameters: IosParameters(
                            bundleId: 'com.biblosphere.biblosphere',
                            minimumVersion: '0',
                          ),
                          socialMetaTagParameters: SocialMetaTagParameters(
                              title: S.of(context).title,
                              description: S.of(context).shareWishlist,
                              imageUrl: Uri.parse(sharingUrl)),
                        );

                        final ShortDynamicLink shortLink =
                            await parameters.buildShortLink();

                        Share.share(shortLink.shortUrl.toString());
                      },
                      tooltip: S.of(context).shareShelf,
                      icon: new Icon(MyIcons.share1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          color: greyColor2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0));
  }
}

class MyBookshelf extends StatelessWidget {
  MyBookshelf(
      {Key key,
      @required this.currentUserId,
      @required this.shelfId,
      @required this.imageURL,
      @required this.position,
      @required this.fileName});

  final String shelfId;
  final String imageURL;
  final GeoPoint position;
  final String currentUserId;
  final String fileName;

  Future<void> deleteShelf() async {
    try {
      //Delete bookshelf record in Firestore database
      DocumentReference doc =
          Firestore.instance.collection('shelves').document("$shelfId");
      await doc.delete();

      //Delete image file from Firebase storage
      final StorageReference ref = FirebaseStorage.instance
          .ref()
          .child('images')
          .child(currentUserId)
          .child(fileName);
      await ref.delete();
    } catch (ex, stack) {
      print('Shelf delete failed for [$shelfId, $currentUserId, $fileName]: ' +
          ex.toString());
      FlutterCrashlytics().logException(ex, stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new Card(
          child: new Column(
            children: <Widget>[
              new Container(
                  child: Image(
                      image: new CachedNetworkImageProvider(imageURL),
                      fit: BoxFit.cover),
                  margin: EdgeInsets.only(top: 7.0, left: 7.0, right: 7.0)),
              new Align(
                alignment: Alignment(1.0, 1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    new IconButton(
                      onPressed: deleteShelf,
                      tooltip: S.of(context).deleteShelf,
                      icon: new Icon(MyIcons.trash),
                    ),
/*  Nothing to do in settings right now
                    new IconButton(
                      onPressed: () {},
                      tooltip: S.of(context).shelfSettings,
                      icon: new Icon(MyIcons.settings),
                    ),
*/
                    new IconButton(
                      onPressed: () async {
                        final DynamicLinkParameters parameters =
                            DynamicLinkParameters(
                          domain: 'biblosphere.page.link',
                          link: Uri.parse('https://biblosphere.org'),
                          androidParameters: AndroidParameters(
                            packageName: 'com.biblosphere.biblosphere',
                            minimumVersion: 0,
                          ),
                          dynamicLinkParametersOptions:
                              DynamicLinkParametersOptions(
                            shortDynamicLinkPathLength:
                                ShortDynamicLinkPathLength.short,
                          ),
                          iosParameters: IosParameters(
                            bundleId: 'com.biblosphere.biblosphere',
                            minimumVersion: '0',
                          ),
                          socialMetaTagParameters: SocialMetaTagParameters(
                              title: S.of(context).title,
                              description: S.of(context).shareBookshelf,
                              imageUrl: Uri.parse(imageURL)),
                        );

                        final ShortDynamicLink shortLink =
                            await parameters.buildShortLink();
                        Share.share(shortLink.shortUrl.toString());

//                        final Uri link = await parameters.buildUrl();
//                        Share.share(link.toString());
                      },
                      tooltip: S.of(context).shareShelf,
                      icon: new Icon(MyIcons.share1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          color: greyColor2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0));
  }
}

class MyBookshelfList extends StatelessWidget {
  MyBookshelfList({Key key, @required this.currentUserId});

  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) return Container();
  }
}

class Home extends StatelessWidget {
  Home({
    Key key,
    @required this.currentUser,
  });

  final User currentUser;

  Future getImage(BuildContext context) async {
    try {
      File image = await ImagePicker.pickImage(
          source: ImageSource.camera, maxWidth: 1024.0);

      if (image == null) return;

      bool imageAccepted = await isBookcase(image);

      if (!imageAccepted) {
        showBbsDialog(context, S.of(context).notBooks);
        return;
      }

      String name = getTimestamp() + ".jpg";

      final String storageUrl =
          await uploadPicture(image, currentUser.id, name);

      final position = await Geolocator().getLastKnownPosition();

      //Create record in Firestore database with location, URL, and user
      await Firestore.instance.collection('shelves').add({
        "user": currentUser.id,
        "userName": currentUser.name,
        'URL': storageUrl,
        'position': new GeoPoint(position.latitude, position.longitude),
        'file': name
      });
    } catch (ex, stack) {
      print("Failed to take image: " + ex.toString());
      FlutterCrashlytics().logException(ex, stack);
    }
  }
  /*
  //Demo record for User Actions:
  //TODO: remove it and replace with actual code
  List<UserActionRecord> actions = [
    new UserActionRecord(
        '-LYqzfH9ZbqLhMCixUoK',
        'The Five Dysfunctions of a Team',
        'http://books.google.com/books/content?id=dsN3CgAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api',
        'TzbOEGICy0XVPCUA6XUbTOKPXap2',
        'Denis Stark',
        DateTime.now(),
        UserAction.giveBook),
    new UserActionRecord(
        '-LYrAXkPVxMIBlV2BUHP',
        'Rethinking Money',
        'http://books.google.com/books/content?id=hBfQdF3EhXAC&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api',
        'TzbOEGICy0XVPCUA6XUbTOKPXap2',
        'Denis Stark',
        DateTime.now(),
        UserAction.returnBook),
    new UserActionRecord(
        '-LYrA_SNUAT02-kLFP1X',
        'Great by Choice',
        'http://books.google.com/books/content?id=ZLQ04ypPx7UC&printsec=frontcover&img=1&zoom=1&source=gbs_api',
        'TzbOEGICy0XVPCUA6XUbTOKPXap2',
        'Denis Stark',
        DateTime.now(),
        UserAction.getBook),
  ];

  Widget userActionWidget(BuildContext context, UserActionRecord a) {
    var formatter = new DateFormat('yyyy-MM-dd');
    return new Container(
        margin: EdgeInsets.all(10.0),
        child: Row(children: <Widget>[
          Container(
            height: 60,
            child: Image(
                image: new CachedNetworkImageProvider(a.bookImage),
                fit: BoxFit.cover),
          ),
          Expanded(
              child: Container(
                  margin: EdgeInsets.all(5.0),
                  child: Text(
                      'Return book \'${a.bookTitle}\' to user ${a.userName} by ${formatter.format(a.on)}',
                      style: Theme.of(context).textTheme.body1))),
          RaisedButton(
            textColor: Colors.white,
            color: Theme.of(context).colorScheme.secondary,
            child: new Text('Done', style: Theme.of(context).textTheme.title),
            onPressed: () {
              print("X");
            },
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(20.0)),
          ),
        ]));
  }
  */

  @override
  Widget build(BuildContext context) {
    return new ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(5.0),
      children: <Widget>[
        EnterBook(
            title: S.of(context).addYourBook,
            onConfirm: (Book book) async {
              addBook(book, currentUser, await currentPosition(),
                  source: 'googlebooks');
            },
            scan: true,
            search: true),
        //Add wishlist section
        EnterBook(
            title: S.of(context).addToWishlist,
            onConfirm: (Book book) async {
              addWish(book, currentUser, await currentPosition(),
                  source: 'googlebooks');
            },
            scan: false,
            search: true),
/*
        // Actions to do (return, get, confirm, etc)
        Card(
            color: greyColor2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: new Column(children: <Widget>[
              Text('Actions', style: Theme.of(context).textTheme.subtitle),
              userActionWidget(context, actions[0]),
              userActionWidget(context, actions[1]),
              userActionWidget(context, actions[2]),
            ])),
            */
        // Statistics about library (books, shelves, authors) and links to manage it
        Card(
            color: greyColor2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Container(
                margin: EdgeInsets.all(10.0),
                child: new Column(children: <Widget>[
                  Text(S.of(context).yourBiblosphere,
                      style: Theme.of(context).textTheme.subtitle),
                  Row(children: <Widget>[
                    Expanded(
                        child: Text(S.of(context).myBooksItem,
                            style: Theme.of(context).textTheme.body1)),
                    RaisedButton(
                      textColor: Colors.white,
                      color: Theme.of(context).colorScheme.secondary,
                      child: new Icon(MyIcons.book),
                      onPressed: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new Scaffold(
                                    appBar: new AppBar(
                                      title: new Text(
                                        S.of(context).myBooksTitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .title
                                            .apply(color: Colors.white),
                                      ),
                                      centerTitle: true,
                                    ),
                                    body: new StreamBuilder<QuerySnapshot>(
                                        stream: Firestore.instance
                                            .collection('bookcopies')
                                            .where("owner.id",
                                                isEqualTo: currentUser.id)
                                            .snapshots(),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<QuerySnapshot>
                                                snapshot) {
                                          if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          }
                                          switch (snapshot.connectionState) {
                                            case ConnectionState.waiting:
                                              return Text(
                                                  S.of(context).loading);
                                            default:
                                              if (!snapshot.hasData ||
                                                  snapshot
                                                      .data.documents.isEmpty) {
                                                return Container(
                                                    padding: EdgeInsets.all(10),
                                                    child: Text(
                                                      S.of(context).noBooks,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .body1,
                                                    ));
                                              }
                                              return new ListView(
                                                children: snapshot
                                                    .data.documents
                                                    .map((DocumentSnapshot
                                                        document) {
                                                  return new MyBook(
                                                      new Bookcopy.fromJson(
                                                          document.data),
                                                      currentUser);
                                                }).toList(),
                                              );
                                          }
                                        }))));
                      },
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20.0)),
                    ),
                  ]),
                  Row(children: <Widget>[
                    Expanded(
                        child: Text(S.of(context).myBookshelvesItem,
                            style: Theme.of(context).textTheme.body1)),
                    RaisedButton(
                      textColor: Colors.white,
                      color: Theme.of(context).colorScheme.secondary,
                      child: new Icon(MyIcons.open),
                      onPressed: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new Scaffold(
                                    appBar: new AppBar(
                                      title: new Text(
                                        S.of(context).myBookshelvesTitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .title
                                            .apply(color: Colors.white),
                                      ),
                                      centerTitle: true,
                                    ),
                                    body: StreamBuilder<QuerySnapshot>(
                                        stream: Firestore.instance
                                            .collection('shelves')
                                            .where("user",
                                                isEqualTo: currentUser.id)
                                            .snapshots(),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<QuerySnapshot>
                                                snapshot) {
                                          if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          }
                                          switch (snapshot.connectionState) {
                                            case ConnectionState.waiting:
                                              return Text(
                                                  S.of(context).loading);
                                            default:
                                              if (!snapshot.hasData ||
                                                  snapshot
                                                      .data.documents.isEmpty) {
                                                return Container(
                                                    padding: EdgeInsets.all(10),
                                                    child: Text(
                                                      S
                                                          .of(context)
                                                          .noBookshelves,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .body1,
                                                    ));
                                              }
                                              return new ListView(
                                                children: snapshot
                                                    .data.documents
                                                    .map((DocumentSnapshot
                                                        document) {
                                                  return new MyBookshelf(
                                                      currentUserId:
                                                          currentUser.id,
                                                      shelfId:
                                                          document.documentID,
                                                      imageURL: document['URL'],
                                                      position:
                                                          document['position'],
                                                      fileName:
                                                          document['file']);
                                                }).toList(),
                                              );
                                          }
                                        }))));
                      },
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20.0)),
                    ),
                  ]),
                  Row(children: <Widget>[
                    Expanded(
                        child: Text(S.of(context).myWishlistItem,
                            style: Theme.of(context).textTheme.body1)),
                    RaisedButton(
                      textColor: Colors.white,
                      color: Theme.of(context).colorScheme.secondary,
                      child: new Icon(MyIcons.heart),
                      onPressed: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new Scaffold(
                                    appBar: new AppBar(
                                      title: new Text(
                                        S.of(context).myWishlistTitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .title
                                            .apply(color: Colors.white),
                                      ),
                                      centerTitle: true,
                                    ),
                                    body: new StreamBuilder<QuerySnapshot>(
                                        stream: Firestore.instance
                                            .collection('wishes')
                                            .where("wisher.id",
                                                isEqualTo: currentUser.id)
                                            .snapshots(),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<QuerySnapshot>
                                                snapshot) {
                                          if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          }
                                          switch (snapshot.connectionState) {
                                            case ConnectionState.waiting:
                                              return Text(
                                                  S.of(context).loading);
                                            default:
                                              if (!snapshot.hasData ||
                                                  snapshot
                                                      .data.documents.isEmpty) {
                                                return Container(
                                                    padding: EdgeInsets.all(10),
                                                    child: Text(
                                                      S.of(context).noWishes,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .body1,
                                                    ));
                                              }
                                              return new ListView(
                                                children: snapshot
                                                    .data.documents
                                                    .map((DocumentSnapshot
                                                        document) {
                                                  return new MyWish(
                                                      new Wish.fromJson(
                                                          document.data),
                                                      currentUser);
                                                }).toList(),
                                              );
                                          }
                                        }))));
                      },
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20.0)),
                    ),
                  ]),
                ]))),
        // Linked accounts: Librarything, Goodreads, Bookcrossing, Bookmooch
        Goodreads(),
        Card(
            color: greyColor2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Container(
                margin: EdgeInsets.all(10.0),
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Text(S.of(context).addYourBookshelf,
                      style: Theme.of(context).textTheme.subtitle),
                  Row(children: <Widget>[
                    Expanded(
                        child: Text(S.of(context).makePhotoOfShelf,
                            style: Theme.of(context).textTheme.body1)),
                    RaisedButton(
                      textColor: Colors.white,
                      color: Theme.of(context).colorScheme.secondary,
                      child: new Icon(MyIcons.camera),
                      onPressed: () {
                        getImage(context);
                      },
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20.0)),
                    ),
                  ]),
                ]))),
      ],
    );
  }

  Future<bool> isBookcase(File imageFile) async {
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(imageFile);

    // Cloud detection
    FirebaseVisionDetector detector =
        FirebaseVision.instance.cloudLabelDetector();
    //On-device detection
    //FirebaseVisionDetector detector = FirebaseVision.instance.labelDetector();

    final List<Label> results = await detector.detectInImage(visionImage);

    if (results != null) {
      var books = results.where((label) =>
          label.label.toLowerCase() == 'bookcase' ||
          label.label.toLowerCase() == 'book');
      return books.length > 0;
    }

    return false;
  }

  Future<String> uploadPicture(File image, String user, String name) async {
    final StorageReference ref =
        FirebaseStorage.instance.ref().child('images').child(user).child(name);
    final StorageUploadTask uploadTask = ref.putFile(
      image,
      new StorageMetadata(
        contentType: 'image/jpeg',
        // To enable Client-side caching you can set the Cache-Control headers here. Uncomment below.
        cacheControl: 'public,max-age=3600',
        customMetadata: <String, String>{'activity': 'test'},
      ),
    );
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    final String imageUrl = await storageTaskSnapshot.ref.getDownloadURL();

    return imageUrl;
  }
}
