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

import 'package:biblosphere/const.dart';
import 'package:biblosphere/l10n.dart';
import 'package:biblosphere/goodreads.dart';
import 'package:biblosphere/chat.dart';

class MyBook extends StatelessWidget {
  MyBook(this.bookcopy, this.currentUser);

  final Bookcopy bookcopy;
  final User currentUser;

  Future<void> deleteBook(BuildContext context) async {
    try {
      //Delete bookshelf record in Firestore database
      DocumentReference doc = Firestore.instance
          .collection('bookcopies')
          .document("${bookcopy.id}");
      await doc.delete();
      showSnackBar(context, S.of(context).bookDeleted);
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
                              (bookcopy.book.image != null && bookcopy.book.image.isNotEmpty) ? bookcopy.book.image : nocoverUrl),
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
                      onPressed: () => deleteBook(context),
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
                            new DynamicLinkParameters(
                          uriPrefix: 'biblosphere.page.link',
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

  Future<void> deleteWish(BuildContext context) async {
    try {
      //Delete bookshelf record in Firestore database
      DocumentReference doc =
          Firestore.instance.collection('wishes').document("${wish.id}");
      await doc.delete();
      showSnackBar(context, S.of(context).wishDeleted);
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
                              new CachedNetworkImageProvider((wish.book.image != null && wish.book.image.isNotEmpty) ? wish.book.image : nocoverUrl),
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
                      onPressed: () => deleteWish(context),
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
                          uriPrefix: 'biblosphere.page.link',
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

  Future<void> deleteShelf(BuildContext context) async {
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
      showSnackBar(context, S.of(context).shelfDeleted);
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
                      onPressed: () => deleteShelf(context),
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
                          uriPrefix: 'biblosphere.page.link',
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

class MyLentBook extends StatelessWidget {
  MyLentBook(this.bookcopy, this.currentUser);

  final Bookcopy bookcopy;
  final User currentUser;

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
                          width: 60,
                          image: new CachedNetworkImageProvider(
                              (bookcopy.book.image != null && bookcopy.book.image.isNotEmpty) ? bookcopy.book.image : nocoverUrl),
                          fit: BoxFit.cover),
                      Expanded(
                        child: Container(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(S.of(context).lentBookText(bookcopy.holder.name, bookcopy.book.title),
                                    style: Theme.of(context).textTheme.body1)
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
                      onPressed: () {
                        openMsg(context, bookcopy.holder.id, currentUser.id);
                      },
                      tooltip: S.of(context).messageRecepient,
                      icon: new Icon(MyIcons.chat),
                    )
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

class MyBorrowedBook extends StatelessWidget {
  MyBorrowedBook(this.bookcopy, this.currentUser);

  final Bookcopy bookcopy;
  final User currentUser;

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
                          width: 60,
                          image: new CachedNetworkImageProvider(
                              (bookcopy.book.image != null && bookcopy.book.image.isNotEmpty) ? bookcopy.book.image : nocoverUrl),
                          fit: BoxFit.cover),
                      Expanded(
                        child: Container(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(S.of(context).borrowedBookText(bookcopy.owner.name, bookcopy.book.title),
                                    style: Theme.of(context).textTheme.body1)
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
                      onPressed: () {
                        startTransit(context, bookcopy.id, currentUser, bookcopy.owner, Transit.Return);
                      },
                      tooltip: S.of(context).addToOutbox,
                      icon: new Icon(MyIcons.outbox),
                    ),
                    new IconButton(
                      onPressed: () {
                        openMsg(context, bookcopy.owner.id, currentUser.id);
                      },
                      tooltip: S.of(context).messageRecepient,
                      icon: new Icon(MyIcons.chat),
                    )
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

class MyOutbox extends StatelessWidget {
  MyOutbox(this.transit, this.currentUser);

  final Transit transit;
  final User currentUser;

  @override
  Widget build(BuildContext context) {
    // Skip if not intended to show
    if (!transit.showInOutbox()) return new Container();

    List<Widget> actions = (transit.getOutboxSteps().map((step) {
      Widget wid = new Container(
          margin: EdgeInsets.only(left: 5.0, right: 5.0),
          child: new RaisedButton(
            color: Theme.of(context).colorScheme.secondary,
            child: new Text(Transit.stepText(step, context),
                style: Theme.of(context)
                    .textTheme
                    .body1
                    .apply(color: Colors.white)),
            onPressed: () {
              changeTransit(transit, currentUser, step);
            },
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(20.0)),
          ));
      return wid;
    }))
        .toList();

    actions.add(new IconButton(
      onPressed: () {
        openMsg(context, transit.to.id, transit.from.id);
      },
      tooltip: S.of(context).messageRecepient,
      icon: new Icon(MyIcons.chat),
    ));

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
                          width: 60,
                          image: new CachedNetworkImageProvider(
                              (transit.bookcopy.book.image != null && transit.bookcopy.book.image.isNotEmpty) ? transit.bookcopy.book.image : nocoverUrl),
                          fit: BoxFit.cover),
                      Expanded(
                        child: Container(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(transit.getOutboxText(context),
                                    style: Theme.of(context).textTheme.body1)
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
                    children: actions),
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

class MyCart extends StatelessWidget {
  MyCart(this.transit, this.currentUser);

  final Transit transit;
  final User currentUser;

  @override
  Widget build(BuildContext context) {
    // Skip if not intended to show
    if (!transit.showInCart()) return new Container();

    List<Widget> actions = (transit.getCartSteps().map((step) {
      Widget wid = new Container(
          margin: EdgeInsets.only(left: 5.0, right: 5.0),
          child: new RaisedButton(
            color: Theme.of(context).colorScheme.secondary,
            child: new Text(Transit.stepText(step, context),
                style: Theme.of(context)
                    .textTheme
                    .body1
                    .apply(color: Colors.white)),
            onPressed: () {
              changeTransit(transit, currentUser, step);
            },
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(20.0)),
          ));
      return wid;
    }))
        .toList();

    actions.add(new IconButton(
      onPressed: () {
        openMsg(context, transit.from.id, transit.to.id);
      },
      tooltip: S.of(context).messageRecepient,
      icon: new Icon(MyIcons.chat),
    ));

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
                          width: 60,
                          image: new CachedNetworkImageProvider(
                              (transit.bookcopy.book.image != null && transit.bookcopy.book.image.isNotEmpty) ? transit.bookcopy.book.image : nocoverUrl),
                          fit: BoxFit.cover),
                      Expanded(
                        child: Container(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(transit.getCartText(context),
                                    style: Theme.of(context).textTheme.body1)
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
                    children: actions),
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

class Home extends StatelessWidget {
  Home({
    Key key,
    @required this.currentUser,
  });

  final User currentUser;

  Future getImage(BuildContext context,
      {ImageSource source = ImageSource.camera}) async {
    try {
      File image =
          await ImagePicker.pickImage(source: source, maxWidth: 1024.0);

      if (image == null) return;

      bool imageAccepted = await isBookcase(image);

      if (!imageAccepted) {
        showSnackBar(context, S.of(context).notBooks);
        //showBbsDialog(context, );
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
      showSnackBar(context, S.of(context).shelfAdded);
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
              addBook(context, book, currentUser, await currentPosition(),
                  source: 'googlebooks');
            },
            scan: true,
            search: true),
        //Add wishlist section
        EnterBook(
            title: S.of(context).addToWishlist,
            onConfirm: (Book book) async {
              addWish(context, book, currentUser, await currentPosition(),
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
                            cardListPage(
                                user: currentUser,
                                stream: Firestore.instance
                                    .collection('bookcopies')
                                    .where("owner.id",
                                        isEqualTo: currentUser.id)
                                    .snapshots(),
                                mapper: (doc, user) {
                                  return new MyBook(
                                      new Bookcopy.fromJson(doc.data),
                                      currentUser);
                                },
                                title: S.of(context).myBooksTitle,
                                empty: S.of(context).noBooks));
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
                            cardListPage(
                                user: currentUser,
                                stream: Firestore.instance
                                    .collection('shelves')
                                    .where("user", isEqualTo: currentUser.id)
                                    .snapshots(),
                                mapper: (doc, user) {
                                  return new MyBookshelf(
                                      currentUserId: currentUser.id,
                                      shelfId: doc.documentID,
                                      imageURL: doc['URL'],
                                      position: doc['position'],
                                      fileName: doc['file']);
                                },
                                title: S.of(context).myBookshelvesTitle,
                                empty: S.of(context).noBookshelves));
                      },
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20.0)),
                    ),
                  ]),
                  Row(children: <Widget>[
                    Expanded(
                        child: Text(S.of(context).myBorrowedBooksItem,
                            style: Theme.of(context).textTheme.body1)),
                    RaisedButton(
                      textColor: Colors.white,
                      color: Theme.of(context).colorScheme.secondary,
                      child: new Icon(MyIcons.taken),
                      onPressed: () {
                        Navigator.push(
                            context,
                            cardListPage(
                                user: currentUser,
                                stream: Firestore.instance
                                    .collection('bookcopies')
                                    .where("holder.id",
                                        isEqualTo: currentUser.id)
                                    .where("lent", isEqualTo: true)
                                    .snapshots(),
                                mapper: (doc, user) {
                                  return new MyBorrowedBook(
                                      new Bookcopy.fromJson(doc.data),
                                      currentUser);
                                },
                                title: S.of(context).myBorrowedBooksTitle,
                                empty: S.of(context).noBorrowedBooks));
                      },
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20.0)),
                    ),
                  ]),
                  Row(children: <Widget>[
                    Expanded(
                        child: Text(S.of(context).myLendedBooksItem,
                            style: Theme.of(context).textTheme.body1)),
                    RaisedButton(
                      textColor: Colors.white,
                      color: Theme.of(context).colorScheme.secondary,
                      child: new Icon(MyIcons.given),
                      onPressed: () {
                        Navigator.push(
                            context,
                            cardListPage(
                                user: currentUser,
                                stream: Firestore.instance
                                    .collection('bookcopies')
                                    .where("owner.id",
                                        isEqualTo: currentUser.id)
                                    .where("lent", isEqualTo: true)
                                    .snapshots(),
                                mapper: (doc, user) {
                                  return new MyLentBook(
                                      new Bookcopy.fromJson(doc.data), user);
                                },
                                title: S.of(context).myLendedBooksTitle,
                                empty: S.of(context).noLendedBooks));
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
                            cardListPage(
                                user: currentUser,
                                stream: Firestore.instance
                                    .collection('wishes')
                                    .where("wisher.id",
                                        isEqualTo: currentUser.id)
                                    .snapshots(),
                                mapper: (doc, user) {
                                  return new MyWish(
                                      new Wish.fromJson(doc.data), currentUser);
                                },
                                title: S.of(context).myWishlistTitle,
                                empty: S.of(context).noWishes));
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
                  Row(children: <Widget>[
                    Expanded(
                        child: Text(S.of(context).loadPhotoOfShelf,
                            style: Theme.of(context).textTheme.body1)),
                    RaisedButton(
                      textColor: Colors.white,
                      color: Theme.of(context).colorScheme.secondary,
                      child: new Icon(MyIcons.galery),
                      onPressed: () {
                        getImage(context, source: ImageSource.gallery);
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
    final ImageLabeler detector = FirebaseVision.instance.cloudImageLabeler();

    final List<ImageLabel> results = await detector.processImage(visionImage);

    if (results != null) {
      var books = results.where((label) =>
          label.text.toLowerCase() == 'bookcase' ||
          label.text.toLowerCase() == 'book');
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
