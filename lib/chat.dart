import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
//import 'package:flutter_crashlytics/flutter_crashlytics.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';

import 'package:biblosphere/l10n.dart';
import 'package:biblosphere/const.dart';
import 'package:biblosphere/helpers.dart';
import 'package:biblosphere/payments.dart';
import 'package:biblosphere/lifecycle.dart';

// Class to show list of chats
class ChatListWidget extends StatefulWidget {
  ChatListWidget({
    Key key,
  }) : super(key: key);

  @override
  _ChatListWidgetState createState() => new _ChatListWidgetState();
}

class _ChatListWidgetState extends State<ChatListWidget> {
  Messages chatWithBiblosphere;

  @override
  void initState() {
    super.initState();

    chatWithBiblosphere = Messages(from: B.user, system: true);
  }

  @override
  void dispose() {
    super.dispose();
  }

  _ChatListWidgetState();

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          chatWithBiblosphere != null
              ? ChatCard(chat: chatWithBiblosphere)
              : Container(),
          new Expanded(
              child: new StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection('messages')
                      .where("ids", arrayContains: B.user.id)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Text(S.of(context).loading);
                      default:
                        if (!snapshot.hasData ||
                            snapshot.data.documents.isEmpty) {
                          return Container(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                S.of(context).noMessages,
                                style: Theme.of(context).textTheme.body1,
                              ));
                        }
                        return new ListView(
                          children: snapshot.data.documents
                              .map((DocumentSnapshot document) {
                            // Find userId of the contact in this chat
                            Messages msgs =
                                new Messages.fromJson(document.data, document);

                            return ChatCard(chat: msgs);
                          }).toList(),
                        );
                    }
                  })),
        ],
      ),
    );
  }
}

class ChatCard extends StatefulWidget {
  ChatCard({
    Key key,
    @required this.chat,
  }) : super(key: key);

  //TODO: data in Widget not State
  final Messages chat;

  @override
  _ChatCardState createState() => new _ChatCardState(chat: chat);
}

class _ChatCardState extends State<ChatCard> {
  Messages chat;
  StreamSubscription<Messages> _listener;

  @override
  void initState() {
    super.initState();

    _listener = chat.snapshots().listen((chat) async {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    if (_listener != null) _listener.cancel();

    super.dispose();
  }

  @override
  void didUpdateWidget(ChatCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.chat != widget.chat) {
      chat = widget.chat;
      _listener = chat.snapshots().listen((chat) async {
        if (mounted) setState(() {});
      });
    }
  }

  _ChatCardState({Key key, @required this.chat});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          Chat.runChat(context, null, chat: chat);
        },
        child: Card(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
              Row(children: <Widget>[
                Stack(children: <Widget>[
                  chat.system
                      ? Container(
                          margin: EdgeInsets.all(7.0),
                          child: assetIcon(technical_support_100, size: 50.0))
                      : userPhoto(chat.partnerImage, 60.0, padding: 5.0),
                  chat.system
                      ? Container()
                      : Positioned.fill(
                          child: Container(
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                  onTap: () {
                                    showBbsConfirmation(context,
                                            S.of(context).confirmBlockUser)
                                        .then((confirmed) {
                                      if (confirmed) {
                                        blockUser(B.user.id, chat.partnerId);
                                      }
                                    });
                                  },
                                  child: ClipOval(
                                    child: Container(
                                      color: C.button,
                                      height: 20.0, // height of the button
                                      width: 20.0, // width of the button
                                      child: Center(
                                          child:
                                              assetIcon(cancel_100, size: 20)),
                                    ),
                                  ))))
                ]),
                Expanded(
                    child: Container(
                        margin: EdgeInsets.all(5.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                  child: Text(
                                      chat.system
                                          ? S.of(context).supportChat
                                          : chat.partnerName ?? '',
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle)), // Description
                              Text(chat.message ?? '',
                                  style: Theme.of(context).textTheme.body1.apply(color: Colors.grey[400]))
                            ]))),
                Container(
                    margin: EdgeInsets.all(5.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(DateFormat('H:m MMMd').format(chat.timestamp),
                              style: Theme.of(context).textTheme.body1),
                          chat.unread != null &&
                                  chat.unread[B.user.id] != null &&
                                  chat.unread[B.user.id] > 0
                              ? ClipOval(
                                  child: Container(
                                    color: Colors.green,
                                    height: 25.0, // height of the button
                                    width: 25.0, // width of the button
                                    child: Center(
                                        child: Text(
                                            chat.unread[B.user.id].toString())),
                                  ),
                                )
                              : Container()
                        ])),
              ]),
              Container(
                  margin: EdgeInsets.all(5.0),
                  child: Text(statusText(chat),
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.body1)),
            ])));
  }

  String statusText(Messages chat) {
    if (chat.system)
      return 'Любые вопросы по приложению';
    else if (B.user.id == chat.fromId && chat.status == Messages.Initial) {
      return S.of(context).chatStatusInitialFrom;
    } else if (B.user.id == chat.fromId && chat.status == Messages.Handover) {
      return S.of(context).chatStatusHandoverFrom;
    } else if (B.user.id == chat.fromId && chat.status == Messages.Complete) {
      return S.of(context).chatStatusCompleteFrom;
    } else if (B.user.id == chat.toId && chat.status == Messages.Initial) {
      return S.of(context).chatStatusInitialTo;
    } else if (B.user.id == chat.toId && chat.status == Messages.Handover) {
      return S.of(context).chatStatusHandoverTo;
    } else if (B.user.id == chat.toId && chat.status == Messages.Complete) {
      return S.of(context).chatStatusCompleteTo;
    } else {
      return '';
    }
  }

  void blockUser(String blockingUser, String blockedUser) {
    Firestore.instance.collection('users').document(blockingUser).updateData({
      'blocked': FieldValue.arrayUnion([blockedUser])
    });
  }
}

class Chat extends StatefulWidget {
  static runChatById(BuildContext context, User partner,
      {String chatId,
      String message,
      bool send = false,
      String transit}) async {
    DocumentSnapshot chatSnap = await Messages.Ref(chatId).get();
    if (!chatSnap.exists) throw 'Chat does not exist: ${chatId}';

    Messages chat = new Messages.fromJson(chatSnap.data, chatSnap);

    if (!chat.system && partner == null) {
      String partnerId = chat.partnerId;
      DocumentSnapshot snap = await User.Ref(partnerId).get();
      if (!snap.exists)
        throw "Partner user [${partnerId}] does not exist for chat [${chat.id}]";
      partner = User.fromJson(snap.data);
    }

    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new Chat(
                partner: partner,
                chat: chat,
                message: message,
                send: send,
                transit: transit)));
  }

  static runChat(BuildContext context, User partner,
      {Messages chat,
      String message,
      bool send = false,
      String transit}) async {
    if (!chat.system && partner == null)
      partner = User(
          id: chat.partnerId, name: chat.partnerName, photo: chat.partnerImage);

    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new Chat(
                partner: partner,
                chat: chat,
                message: message,
                send: send,
                transit: transit)));
  }

  Chat(
      {Key key,
      @required this.partner,
      this.message,
      this.chat,
      this.send,
      this.transit})
      : super(key: key);

  final Messages chat;
  final User partner;
  final String message;
  final bool send;
  final String transit;

  @override
  _ChatState createState() => new _ChatState(
      partner: partner,
      message: message,
      chat: chat,
      send: send,
      transit: transit);
}

class _ChatState extends State<Chat> {
  final User partner;
  String transit;
  String message;
  bool send;
  Messages chat;
  String phase;
  bool showCart = false;
  String status;

  // Conditions for the agreement
  double amountToPay = 0.0;

  // List of books in the agreement
  StreamSubscription<QuerySnapshot> streamBooks;
  List<Bookrecord> books = [];

  StreamSubscription<Messages> _listener;
  StreamSubscription<DocumentSnapshot> streamPartnerWallet;
  double partnerBalance = 0.0;

  // Text field controller for the search bar
  TextEditingController textController;

  // Keys from search bar to filter books
  Set<String> keys = {};

  // Flag to control expansion of book bar
  bool isBarExpanded = false;

  @override
  void initState() {
    super.initState();

    textController = new TextEditingController();

    // Initialize chat queries
    status = null;
    refreshChat();

    // Listem chat updates
    _listener = chat.snapshots().listen((chat) {
      if (mounted) setState(() {});
    }, onDone: () async {
      if (transit != null) {
        Messages chatT = await doTransit(
            context: context, chat: chat, bookrecordId: transit);
        chat.status = chatT.status;
        chat.books = chatT.books;
        transit = null;
      }
      refreshChat();
    } );

    if (!chat.system) {
      // Get current balance of the peer
      Firestore.instance
          .collection('wallets')
          .document(partner.id)
          .get()
          .then((snap) {
        if (snap.exists) {
          Wallet wallet = new Wallet.fromJson(snap.data);
          setState(() {
            partnerBalance = wallet.getAvailable();
          });
        }
      });

      // Update balance of the peer in real-time to reflect changes to the screen
      streamPartnerWallet = Firestore.instance
          .collection('wallets')
          .document(partner.id)
          .snapshots()
          .listen((snap) {
        if (snap.exists) {
          Wallet wallet = new Wallet.fromJson(snap.data);
          if (partnerBalance != wallet.getAvailable()) {
            setState(() {
              partnerBalance = wallet.getAvailable();
            });
          }
        }
      });
    }
  }

  void refreshChat() async {
    // Skip if status not changed
    if (chat.status == status)
      return;

    status = chat.status;
    books = [];

    if (streamBooks != null) streamBooks.cancel();

    if (chat.toMe && chat.status == Messages.Initial) {
      phase = 'initialToMe';

      streamBooks = Firestore.instance
          .collection('bookrecords')
          .where("holderId", isEqualTo: partner.id)
          .where("transit", isEqualTo: true)
          .where("confirmed", isEqualTo: false)
          .where("transitId", isEqualTo: B.user.id)
          .where("wish", isEqualTo: false)
          .snapshots()
          .listen((snap) {
        books =
            snap.documents.map((doc) => Bookrecord.fromJson(doc.data)).toList();

        // Calculate total amount to pay for transferred books
        amountToPay = 0.0;
        for (Bookrecord b in books) {
          if (b.transitId == B.user.id && b.ownerId != B.user.id)
            amountToPay += b.getPrice();
        }

        if (mounted) setState(() {});
      });
    } else if (chat.fromMe && chat.status == Messages.Initial) {
      phase = 'initialFromMe';

      streamBooks = Firestore.instance
          .collection('bookrecords')
          .where("holderId", isEqualTo: B.user.id)
          .where("transit", isEqualTo: true)
          .where("confirmed", isEqualTo: false)
          .where("transitId", isEqualTo: partner.id)
          .where("wish", isEqualTo: false)
          .snapshots()
          .listen((snap) {
        books =
            snap.documents.map((doc) => Bookrecord.fromJson(doc.data)).toList();

        // Nothing to pay on giving the books
        amountToPay = 0.0;
        for (Bookrecord b in books) {
          if (b.transitId == partner.id && b.ownerId != partner.id)
            amountToPay += b.getPrice();
        }

        if (mounted) setState(() {});
      });
    } else if (chat.toMe && chat.status == Messages.Handover) {
      phase = 'handoverToMe';

      streamBooks = Firestore.instance
          .collection('bookrecords')
          .where("holderId", isEqualTo: partner.id)
          .where("transit", isEqualTo: true)
          .where("confirmed", isEqualTo: true)
          .where("transitId", isEqualTo: B.user.id)
          .where("wish", isEqualTo: false)
          .snapshots()
          .listen((snap) {
        books =
            snap.documents.map((doc) => Bookrecord.fromJson(doc.data)).toList();

        // Calculate total amount to pay for transferred books
        amountToPay = 0.0;
        for (Bookrecord b in books) {
          if (b.transitId == B.user.id && b.ownerId != B.user.id)
            amountToPay += b.getPrice();
        }

        if (mounted) setState(() {});
      });
    } else if (chat.fromMe && chat.status == Messages.Handover) {
      phase = 'handoverFromMe';

      streamBooks = Firestore.instance
          .collection('bookrecords')
          .where("holderId", isEqualTo: B.user.id)
          .where("transit", isEqualTo: true)
          .where("confirmed", isEqualTo: true)
          .where("transitId", isEqualTo: partner.id)
          .where("wish", isEqualTo: false)
          .snapshots()
          .listen((snap) {
        books =
            snap.documents.map((doc) => Bookrecord.fromJson(doc.data)).toList();

        // Nothing to pay on giving the books
        amountToPay = 0.0;
        for (Bookrecord b in books) {
          if (b.transitId == partner.id && b.ownerId != partner.id)
            amountToPay += b.getPrice();
        }

        if (mounted) setState(() {});
      });
    } else if (chat.toMe && chat.status == Messages.Complete) {
      phase = 'completeToMe';

      streamBooks = null;
      books = [];
      await Future.forEach(chat.books, (id) async {
        DocumentSnapshot snap = await Bookrecord.Ref(id).get();
        if (snap.exists) books.add(Bookrecord.fromJson(snap.data));
        // TODO: Deal with books which are not found
      });

      amountToPay = chat.amount;

      if (mounted) setState(() {});
    } else if (chat.fromMe && chat.status == Messages.Complete) {
      phase = 'completeFromMe';

      streamBooks = null;
      books = [];
      await Future.forEach(chat.books, (id) async {
        DocumentSnapshot snap = await Bookrecord.Ref(id).get();
        if (snap.exists) books.add(Bookrecord.fromJson(snap.data));
        // TODO: Deal with books which are not found
      });

      amountToPay = chat.amount;

      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    if (streamBooks != null) streamBooks.cancel();

    if (_listener != null) _listener.cancel();

    if (streamPartnerWallet != null) streamPartnerWallet.cancel();

    super.dispose();
  }

  _ChatState(
      {Key key,
      @required this.partner,
      this.message = '',
      this.chat,
      this.send,
      this.transit});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: GestureDetector(
              onTap: () {
                // TODO: Design user profile screen and uncomment
                /*
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new UserProfileWidget(
                              user: partner,
                            )));
                */
              },
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    chat.system
                        ? Container(
                            margin: EdgeInsets.all(2.0),
                            child: assetIcon(technical_support_100, size: 30.0))
                        : userPhoto(partner, 40),
                    Expanded(
                        child: Container(
                            margin: EdgeInsets.only(left: 5.0),
                            child: Text(
                              chat.system ? S.of(context).titleSupport : partner.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .title
                                  .apply(color: C.titleText),
                            ))),
                  ])),
          bottom: showCart
              ? PreferredSize(
                  child: GestureDetector(
                      onVerticalDragUpdate: (details) {
                        if (details.delta.distance > 1.0 &&
                            details.delta.direction < 0.0) {
                          setState(() {
                            showCart = false;
                          });
                        }
                      },
                      child: Container(child: phaseBody())),
                  preferredSize: Size.fromHeight(185.0))
              : null,
          centerTitle: false,
          actions: <Widget>[
            !chat.system
                ? IconButton(
                    onPressed: () {
                      if (!showCart) FocusScope.of(context).unfocus();

                      setState(() {
                        showCart = !showCart;
                      });
                    },
                    tooltip: S.of(context).cart,
                    icon: Stack(children: <Widget>[
                      new Container(
                          padding: EdgeInsets.only(right: 5.0),
                          child: assetIcon(shopping_cart_100, size: 30)),
                      books.length > 0
                          ? Positioned.fill(
                              child: Container(
                                  alignment: Alignment.topRight,
                                  child: ClipOval(
                                    child: Container(
                                        color: C.button,
                                        height: 12.0, // height of the button
                                        width: 12.0, // width of the button
                                        child: Center(
                                            child: Text(books.length.toString(),
                                                style: TextStyle(
                                                    fontSize: 10.0,
                                                    color: C.buttonText)))),
                                  )))
                          : Container()
                    ]),
                  )
                : Container(width: 0.0, height: 0.0)
          ]),
      body: ChatScreen(
          myId: B.user.id,
          partner: partner,
          message: message,
          send: send,
          chat: chat,
          onKeyboard: () {
            setState(() {
              showCart = false;
            });
          }),
    );
  }

  Widget phaseBody() {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Short hint text
          getBookBar(),
          getFinance(),
          // Long text hint
          Container(
              margin: EdgeInsets.fromLTRB(3.0, 8.0, 3.0, 10.0),
              child: Text(
                getLongText(),
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.body1,
              ))
        ]);
  }

  Widget getBookBar() {
    if (chat.toMe) {
      return Container(
          height: 110.0,
          child: ListView(
              scrollDirection: Axis.horizontal,
              children: books.map<Widget>((rec) {
                return BookrecordWidget(
                    bookrecord: rec,
                    builder: (context, rec) {
                      return Stack(children: <Widget>[
                        Container(
                            margin: EdgeInsets.all(5.0),
                            child: bookImage(rec, 100.0, sameHeight: true)),
                        chat.status == Messages.Initial
                            ? Positioned.fill(
                                child: Container(
                                    alignment: Alignment.topRight,
                                    child: GestureDetector(
                                        onTap: () {
                                          // Exclude book from list
                                          rec.ref.updateData({
                                            'transit': false,
                                            'confirmed': false,
                                            'transitId': null,
                                            'users': [rec.holderId, rec.ownerId]
                                          });
                                          chat.ref.updateData({
                                            'books':
                                                FieldValue.arrayRemove([rec.id])
                                          });

                                          logAnalyticsEvent(
                                              name: 'remove_from_cart',
                                              parameters: <String, dynamic>{
                                                'isbn': rec.isbn,
                                                'user': B.user.id,
                                                'type': (chat.toId == rec.owner)
                                                    ? 'return'
                                                    : 'request',
                                                'by':
                                                    (B.user.id == rec.holderId)
                                                        ? 'holder'
                                                        : 'peer',
                                                'from': chat.fromId,
                                                'to': chat.toId,
                                                'distance': rec.distance == double.infinity ? 50000.0 : rec.distance
                                              });
                                        },
                                        child: ClipOval(
                                          child: Container(
                                            color: C.button,
                                            height:
                                                20.0, // height of the button
                                            width: 20.0, // width of the button
                                            child: Center(
                                                child: assetIcon(cancel_100,
                                                    size: 20)),
                                          ),
                                        ))))
                            : Container(width: 0.0, height: 0.0)
                      ]);
                    });
              }).toList()
                ..add(chat.status == Messages.Initial
                    ? GestureDetector(
                        onTap: () {
                          // Run screen to chose more books from user
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => buildScaffold(
                                      context,
                                      '',
                                      new UserBooksWidget(
                                        user: partner,
                                        onSelected: (context, rec) async {
                                          // Add book to a chat
                                          // TODO: Use record instead of id
                                          Messages chatT = await doTransit(
                                              context: context,
                                              chat: chat,
                                              bookrecordId: rec.id);
                                          setState(() {
                                            chat = chatT;
                                          });
                                        },
                                      ),
                                      appbar: false)));
                        },
                        child: Container(
                            height: 100.0,
                            width: 60.0,
                            child: Center(
                              child: ClipOval(
                                child: Container(
                                    height: 35.0, // height of the button
                                    width: 35.0, // width of the button
                                    color: C.button,
                                    child: assetIcon(add_100, size: 35)),
                              ),
                            )))
                    : Container(width: 0.0, height: 0.0))));
    } else {
      return Container(
          height: 110.0,
          child: ListView(
              scrollDirection: Axis.horizontal,
              children: books.map<Widget>((rec) {
                return BookrecordWidget(
                    bookrecord: rec,
                    builder: (context, rec) {
                      return Stack(children: <Widget>[
                        Container(
                            margin: EdgeInsets.all(5.0),
                            child: bookImage(rec, 100.0, sameHeight: true)),
                        chat.status == Messages.Initial
                            ? Positioned.fill(
                                child: Container(
                                    alignment: Alignment.topRight,
                                    child: GestureDetector(
                                        onTap: () {
                                          // Exclude book from list
                                          rec.ref.updateData({
                                            'transit': false,
                                            'confirmed': false,
                                            'transitId': null,
                                            'users': [rec.holderId, rec.ownerId]
                                          });
                                          chat.ref.updateData({
                                            'books':
                                                FieldValue.arrayRemove([rec.id])
                                          });
                                        },
                                        child: ClipOval(
                                          child: Container(
                                            color: C.button,
                                            height:
                                                20.0, // height of the button
                                            width: 20.0, // width of the button
                                            child: Center(
                                                child: assetIcon(cancel_100,
                                                    size: 20)),
                                          ),
                                        ))))
                            : Container(width: 0.0, height: 0.0)
                      ]);
                    });
              }).toList()
                ..add(chat.status == Messages.Initial
                    ? GestureDetector(
                        onTap: () {
                          // Run screen to chose more books from user
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => buildScaffold(
                                      context,
                                      '',
                                      new MyBooksWidget(
                                        user: partner,
                                        onSelected: (context, rec) async {
                                          // Add book to a chat
                                          // TODO: Use record instead of id
                                          Messages chatT = await doTransit(
                                              context: context,
                                              chat: chat,
                                              bookrecordId: rec.id);
                                          setState(() {
                                            chat = chatT;
                                          });
                                        },
                                      ),
                                      appbar: false)));
                        },
                        child: Container(
                            height: 100.0,
                            width: 60.0,
                            child: Center(
                              child: ClipOval(
                                child: Container(
                                  height: 35.0, // height of the button
                                  width: 35.0, // width of the button
                                  color: C.button,
                                  child: assetIcon(add_100, size: 35),
                                ),
                              ),
                            )))
                    : Container(width: 0.0, height: 0.0))));
    }
  }

  Widget getFinance() {
    if (chat.toMe)
      return Container(
          margin: EdgeInsets.only(left: 3.0, right: 3.0),
          child: Row(children: <Widget>[
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      child: Text(S.of(context).showDeposit( money(total(amountToPay)) ),
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.body1)),
                  Container(
                      child: Text(S.of(context).showRent( money(monthly(amountToPay)) ),
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.body1)),
                ]),
            Expanded(
                child: Container(
                    padding: EdgeInsets.only(left: 10.0), child: getButton()))
          ]));
    else
      return Container(
          margin: EdgeInsets.only(left: 3.0, right: 3.0),
          child: Row(children: <Widget>[
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      child: Text('Цена: ${money(amountToPay)}',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.body1)),
                  Container(
                      child: Text(
                          'Доход в месяц: ${money(income(amountToPay))}',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.body1)),
                ]),
            Expanded(
                child: Container(
                    padding: EdgeInsets.only(left: 10.0), child: getButton()))
          ]));
  }

  Widget getButton() {
    if (chat.toMe &&
        chat.status != Messages.Complete &&
        total(amountToPay) >= B.wallet.getAvailable())
      return RaisedButton(
        textColor: C.buttonText,
        color: C.button,
        child: new Text(S.of(context).buttonPayin),
        onPressed: () async {
          final bool available =
              await InAppPurchaseConnection.instance.isAvailable();
          if (!available) {
            // TODO: Process this more nicely
            throw ('In-App store not available');
          }
          // Only show bigger amounts
          Set<String> _kIds = {'50', '100', '200', '500', '1000', '2000'};
          final ProductDetailsResponse response =
              await InAppPurchaseConnection.instance.queryProductDetails(_kIds);

          if (!response.notFoundIDs.isEmpty) {
            // TODO: Process this more nicely
            throw ('Ids of in-app products not available');
          }

          List<ProductDetails> products = response.productDetails;

          products.sort( (p1, p2) => p1.skuDetail.priceAmountMicros - p2.skuDetail.priceAmountMicros);
       
          int missing = ((total(amountToPay) - B.wallet.getAvailable()) * 1.05).ceil();
          ProductDetails product = products.firstWhere( (p) => missing < toXlm(p.skuDetail.priceAmountMicros / 1000000, currency: p.skuDetail.priceCurrencyCode), orElse: () => products.elementAt(products.length-1));

          final PurchaseParam purchaseParam = PurchaseParam(
              productDetails: product, sandboxTesting: false);
          bool res = await InAppPurchaseConnection.instance
              .buyConsumable(purchaseParam: purchaseParam);
        },
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(15.0),
                              side: BorderSide(color: C.buttonBorder)),
      );
    else if (chat.toMe &&
        chat.status == Messages.Handover &&
        books != null &&
        books.length > 0)
      return RaisedButton(
        textColor: C.buttonText,
        color: C.button,
        child: new Text(S.of(context).buttonConfirmBooks,
            style:
                Theme.of(context).textTheme.body1.apply(color: Colors.white)),
        onPressed: () async {
          chat.amount = amountToPay;
          await transferBooks(partner);
        },
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(15.0),
                              side: BorderSide(color: C.buttonBorder)),
      );
    else if (chat.fromMe &&
        chat.status == Messages.Initial &&
        total(amountToPay) < partnerBalance &&
        books != null &&
        books.length > 0)
      return RaisedButton(
        textColor: C.buttonText,
        color: C.button,
        child: new Text(S.of(context).buttonGivenBooks,
            style:
                Theme.of(context).textTheme.body1.apply(color: Colors.white)),
        onPressed: () async {
          await confirmBooks(partner);
          refreshChat();
        },
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(15.0),
                              side: BorderSide(color: C.buttonBorder)),
      );

    return Container(width: 0.0, height: 0.0);
  }

  String getLongText() {
    if (chat.status == Messages.Initial && chat.toMe) {
      if (books == null || books.length == 0)
        return S.of(context).cartAddBooks;
      else if (B.wallet.getAvailable() < total(amountToPay))
        return S.of(context).cartTopup( money(total(amountToPay) - B.wallet.getAvailable()) );
      else
        return S.of(context).cartMakeApointment;
    } else if (chat.status == Messages.Initial && chat.fromMe) {
      if (amountToPay > 0.0 && amountToPay > partnerBalance)
        return S.of(context).cartRequesterHasToTopup;
      else if (amountToPay > 0.0 && amountToPay <= partnerBalance)
        // Some books to be rented (not returned)
        return S.of(context).cartConfirmHandover;
      else
        // All books are returning (not rented)
        return S.of(context).cartConfirmHandover;
    } else if (chat.status == Messages.Handover && chat.toMe) {
      return S.of(context).cartConfirmReceived;
    } else if (chat.status == Messages.Handover && chat.fromMe) {
      return S.of(context).cartRequesterHasToConfirm;
    } else if (chat.status == Messages.Complete && chat.toMe) {
      return S.of(context).cartBooksAccepted;
    } else if (chat.status == Messages.Complete && chat.fromMe) {
      return S.of(context).cartBooksGiven;
    }
    // TODO: Add other phases and directions
    return '';
  }

  Future<void> confirmBooks(User partner) async {
    QuerySnapshot snap = await Firestore.instance
        .collection('bookrecords')
        .where("holderId", isEqualTo: B.user.id)
        .where("transit", isEqualTo: true)
        //.where("confirmed", isEqualTo: false)
        .where("transitId", isEqualTo: partner.id)
        .where("wish", isEqualTo: false)
        .getDocuments();

    List<Bookrecord> books = snap.documents.map((doc) {
      Bookrecord rec = new Bookrecord.fromJson(doc.data);
      return rec;
    }).toList();

    for (Bookrecord b in books) {
      b.ref.updateData({'confirmed': true});
    }

    chat.ref.updateData({
      'status': Messages.Handover,
      'books': books.map((b) => b.id).toList()
    });
    chat.status = Messages.Handover;
    refreshChat();
  }

  Future<void> transferBooks(User partner) async {
    QuerySnapshot snap = await Firestore.instance
        .collection('bookrecords')
        .where("holderId", isEqualTo: partner.id)
        .where("transit", isEqualTo: true)
        .where("confirmed", isEqualTo: true)
        .where("transitId", isEqualTo: B.user.id)
        .where("wish", isEqualTo: false)
        .getDocuments();

    List<Bookrecord> books = snap.documents.map((doc) {
      Bookrecord rec = new Bookrecord.fromJson(doc.data);
      return rec;
    }).toList();

    // Books taken from owner
    List<Bookrecord> booksTaken =
        books.where((rec) => rec.ownerId == partner.id).toList();

    // Books taken from person other than owner
    List<Bookrecord> booksPassed = books
        .where((rec) => rec.ownerId != B.user.id && rec.ownerId != partner.id)
        .toList();

    // Books returned to owner
    List<Bookrecord> booksReturned =
        books.where((rec) => rec.ownerId == B.user.id).toList();

    if (booksTaken.length > 0) {
      await deposit(books: booksTaken, owner: partner, payer: B.user);
    }

    if (booksPassed.length > 0) {
      await pass(books: booksPassed, holder: partner, payer: B.user);
    }

    if (booksReturned.length > 0) {
      await complete(books: booksReturned, holder: partner, owner: B.user);
    }

    chat.ref.updateData({
      'status': Messages.Complete,
      'books': books.map((b) => b.id).toList(),
      'amount': chat.amount
    });
    chat.status = Messages.Complete;
    refreshChat();
  }
}

class ChatScreen extends StatefulWidget {
  final String myId;
  final User partner;
  final String message;
  final bool send;
  final Messages chat;
  final VoidCallback onKeyboard;

  ChatScreen(
      {Key key,
      @required this.myId,
      @required this.partner,
      this.message = '',
      this.send,
      this.chat,
      this.onKeyboard})
      : super(key: key);

  @override
  State createState() => new ChatScreenState(
      myId: myId,
      partner: partner,
      message: message,
      send: send,
      chat: chat,
      onKeyboard: onKeyboard);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState(
      {Key key,
      @required this.myId,
      @required this.partner,
      this.message,
      this.send,
      this.chat,
      this.onKeyboard});

  User partner;
  String myId;
  String peerId;
  String message;
  bool send;
  Messages chat;
  VoidCallback onKeyboard;

  Dialogflow dialogflow;

  var listMessage;
//  SharedPreferences prefs;

  File imageFile;
  bool isLoading;
  String imageUrl;

  TextEditingController textEditingController;
  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
    textEditingController = new TextEditingController(text: message);

    isLoading = false;
    imageUrl = '';

    if (chat.system)
      peerId = 'system';
    else
      peerId = partner.id;

    if (chat.system) {
      // Check if system chat is empty add welcome message
      Firestore.instance
          .collection('messages')
          .document(chat.id)
          .collection(chat.id)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .getDocuments()
          .then((snap) {
            if (snap.documents.length == 0)
        injectChatbotMessage(
            context, B.user.id, chat, S.of(context).chatbotWelcome);
      });

      AuthGoogle(fileJson: "assets/dialogflow.json").build().then((auth) {
        dialogflow =
            Dialogflow(authGoogle: auth, language: Intl.getCurrentLocale());

        if (message != null && send) {
          onSendMessage(message, 0);
        }
      });
    }

    updateUnread();

    if (onKeyboard != null)
      focusNode.addListener(() {
        if (focusNode.hasFocus) onKeyboard();
      });
  }

  @override
  void dispose() {
    focusNode.dispose();

    super.dispose();
  }

  updateUnread() async {
    var chatRef = Firestore.instance.collection('messages').document(chat.id);
    Firestore.instance.runTransaction((tx) async {
      DocumentSnapshot snap = await chatRef.get();
      if (snap.exists) {
        Messages msgs = new Messages.fromJson(snap.data, snap);
        await tx.update(
          chatRef,
          {
            'unread': {peerId: msgs.unread[peerId], myId: 0}
          },
        );
      }
    });
  }

  Future<void> onSendMessage(String content, int type) async {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();
      if (message != null) message = null;

      //TODO: strange but now() at the same moment return different values in different timezones.
      //      to compensate it timeZoneOffset is added to have proper sequence of messages in the
      //      chat. However it does not look quite right for me.
      DateTime time = DateTime.now();
      time = time.add(time.timeZoneOffset);
      int timestamp = time.millisecondsSinceEpoch;

      // Add message
      var msgRef = Firestore.instance
          .collection('messages')
          .document(chat.id)
          .collection(chat.id)
          .document(timestamp.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          msgRef,
          {
            'idFrom': myId,
            'idTo': peerId,
            'timestamp': timestamp.toString(),
            'content': content,
            'type': type
          },
        );
      });

      Firestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snap = await chat.ref.get();
        if (snap.exists) {
          Messages msgs = new Messages.fromJson(snap.data, snap);
          await transaction.update(
            chat.ref,
            {
              'id': chat
                  .id, // Update ID to recover for old chats (old version of app)
              'message': content.length < 20
                  ? content
                  : content.substring(0, 20) + '\u{2026}',
              'timestamp': timestamp.toString(),
              'unread': {peerId: msgs.unread[peerId] + 1, myId: 0}
            },
          );
        }
      });

      // Inject message from Biblosphere chat-bot
      if (chat.system) {
        AIResponse response = await dialogflow.detectIntent(content);
        content = response.getMessage();

        await injectChatbotMessage(context, myId, chat, content);
      }

      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: S.of(context).nothingToSend);
    }
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    double width = MediaQuery.of(context).size.width * 0.80;

    if (document['idFrom'] == myId) {
      // Right (my message)
      return Row(
        children: <Widget>[
          document['type'] == 0
              // Text
              ? Container(
                  child: Text(
                    document['content'],
                    style: TextStyle(color: C.chatMyText),
                  ),
                  padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                  width: width,
                  decoration: BoxDecoration(
                      color: C.chatMy,
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                      right: 10.0),
                )
              : document['type'] == 1
                  // Image
                  ? Container(
                      child: Material(
                        child: CachedNetworkImage(
                          imageUrl: document['content'],
                          width: width,
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    )
                  // Sticker
                  : Container(
                      child: new Image.asset(
                        'images/${document['content']}.gif',
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                document['type'] == 0
                    ? Container(
                        child: Text(
                          document['content'],
                          style: TextStyle(color: C.chatHisText),
                        ),
                        padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                        width: width,
                        decoration: BoxDecoration(
                            color: C.chatHis,
                            borderRadius: BorderRadius.circular(8.0)),
                        margin: EdgeInsets.only(left: 10.0),
                      )
                    : document['type'] == 1
                        ? Container(
                            child: Material(
                              child: CachedNetworkImage(
                                imageUrl: document['content'],
                                width: width,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                            margin: EdgeInsets.only(left: 10.0),
                          )
                        : Container(
                            child: new Image.asset(
                              'images/${document['content']}.gif',
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                            margin: EdgeInsets.only(
                                bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                                right: 10.0),
                          ),
              ],
            ),

            // Time
            isLastMessageLeft(index)
                ? Container(
                    child: Text(
                      DateFormat('dd MMM kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(document['timestamp']))
                              .subtract(DateTime.now().timeZoneOffset)),
                      style: TextStyle(
                          color: greyColor,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] == myId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] != myId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    Navigator.pop(context);

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // List of messages
              buildListMessage(),

              // Input content
              buildInput(),
            ],
          ),

          // Loading
          buildLoading()
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
              ),
              color: Colors.white.withOpacity(0.8),
            )
          : Container(),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Edit text
          Flexible(
            child: Container(
              margin: new EdgeInsets.only(left: 10.0, right: 1.0),
              child: Theme(
                  data: ThemeData(platform: TargetPlatform.android),
                  child: TextField(
                    style: TextStyle(color: primaryColor, fontSize: 15.0),
                    controller: textEditingController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration.collapsed(
                      hintText: S.of(context).typeMsg,
                      hintStyle: TextStyle(color: greyColor),
                    ),
                    focusNode: focusNode,
                  )),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: assetIcon(sent_100, size: 30),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border:
              new Border(top: new BorderSide(color: greyColor2, width: 0.5)),
          color: Colors.white),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: chat.id == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
          : StreamBuilder(
              stream: Firestore.instance
                  .collection('messages')
                  .document(chat.id)
                  .collection(chat.id)
                  .orderBy('timestamp', descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(themeColor)));
                } else {
                  listMessage = snapshot.data.documents;
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) =>
                        buildItem(index, snapshot.data.documents[index]),
                    itemCount: snapshot.data.documents.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }
}

typedef void BookSelectedCallback(BuildContext context, Bookrecord book);

// Class to show users books (to add into transit/chat)
class UserBooksWidget extends StatefulWidget {
  UserBooksWidget({Key key, @required this.user, @required this.onSelected})
      : super(key: key);

  final User user;
  final BookSelectedCallback onSelected;

  @override
  _UserBooksWidgetState createState() =>
      new _UserBooksWidgetState(user: user, onSelected: onSelected);
}

class _UserBooksWidgetState extends State<UserBooksWidget> {
  User user;
  BookSelectedCallback onSelected;

  Set<String> keys = {};
  List<Book> suggestions = [];
  TextEditingController textController;
  bool my = true, his = true;

  StreamSubscription<QuerySnapshot> bookSubscription;
  List<DocumentSnapshot> books = [];

  @override
  void initState() {
    super.initState();

    textController = new TextEditingController();

    books = [];
    bookSubscription = Firestore.instance
        .collection('bookrecords')
        .where("holderId", isEqualTo: user.id)
        .where("transit", isEqualTo: false)
        .snapshots()
        .listen((snap) async {
      // Update list of document snapshots
      books = snap.documents;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    textController.dispose();
    bookSubscription.cancel();
    super.dispose();
  }

  _UserBooksWidgetState({this.user, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverAppBar(
        // Provide a standard title.
        title:
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          userPhoto(user, 40),
          Expanded(
              child: Container(
                  margin: EdgeInsets.only(left: 5.0),
                  child: Text(
                    user.name,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle
                        .apply(color: C.titleText),
                  ))),
        ]),
        // Allows the user to reveal the app bar if they begin scrolling
        // back up the list of items.
        floating: true,
        pinned: true,
        snap: true,
        // Display a placeholder widget to visualize the shrinking size.
        flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: ListView(
                //crossAxisAlignment: CrossAxisAlignment.start,
                //mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Container(height: 42),
                  new Container(
                    //decoration: BoxDecoration(color: Colors.transparent),
                    color: Colors.transparent,
                    padding: new EdgeInsets.all(5.0),
                    child: new Row(
                      //mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        new Expanded(
                          child: Theme(
                              data: ThemeData(platform: TargetPlatform.android),
                              child: TextField(
                                maxLines: 1,
                                controller: textController,
                                style: Theme.of(context)
                                    .textTheme
                                    .title
                                    .apply(color: Colors.white),
                                decoration: InputDecoration(
                                  //border: InputBorder.none,
                                  hintText: S.of(context).hintAuthorTitle,
                                  hintStyle: C.hints.apply(color: C.inputHints),
                                ),
                              )),
                        ),
                        Container(
                            padding: EdgeInsets.only(left: 0.0),
                            child: IconButton(
                              color: Colors.white,
                              icon: assetIcon(search_100, size: 30),
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  keys = getKeys(textController.text);
                                });
                              },
                            )),
                      ],
                    ),
                  ),
                  new Container(
                      color: Colors.transparent,
                      padding: new EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Row(
                          //mainAxisSize: MainAxisSize.min,
                          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            new Expanded(
                                child: new Wrap(
                                    alignment: WrapAlignment.end,
                                    spacing: 2.0,
                                    runSpacing: 0.0,
                                    children: <Widget>[
                                  FilterChip(
                                    //avatar: icon,
                                    label:
                                        Text(S.of(context).chipMyBooksWithHim),
                                    selected: my,
                                    onSelected: (bool s) {
                                      setState(() {
                                        my = s;
                                      });
                                    },
                                  ),
                                  FilterChip(
                                    //avatar: icon,
                                    label: Text(S.of(context).chipHisBooks),
                                    selected: his,
                                    onSelected: (bool s) {
                                      setState(() {
                                        his = s;
                                      });
                                    },
                                  ),
                                ]))
                          ]))
                ])),
        // Make the initial height of the SliverAppBar larger than normal.
        expandedHeight: 150,
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          Bookrecord rec = new Bookrecord.fromJson(books[index].data);

          if (my && rec.ownerId == B.user.id ||
              his && rec.ownerId != B.user.id) {
            return new BookrecordWidget(
                bookrecord: rec,
                builder: (context, rec) {
                  // TODO: Add authors titles aand onTap
                  return GestureDetector(
                      onTap: () async {
                        // Call book selection callback
                        if (onSelected != null) onSelected(context, rec);
                      },
                      child: Row(children: <Widget>[
                        bookImage(rec, 50, padding: 5.0),
                        Expanded(
                            child: Container(
                                margin: EdgeInsets.only(left: 10.0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text('${rec.authors[0]}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .body1),
                                      Text('\"${rec.title}\"',
                                          style:
                                              Theme.of(context).textTheme.body1)
                                    ])))
                      ]));
                });
          } else {
            return Container(height: 0.0, width: 0.0);
          }
        }, childCount: books.length),
      )
    ]);
  }
}

// Class to show my books (own, wishlist and borrowed/lent)
class MyBooksWidget extends StatefulWidget {
  MyBooksWidget({
    Key key,
    @required this.user,
    @required this.onSelected,
  }) : super(key: key);

  final User user;
  final BookSelectedCallback onSelected;

  @override
  _MyBooksWidgetState createState() =>
      new _MyBooksWidgetState(user: user, onSelected: onSelected);
}

class _MyBooksWidgetState extends State<MyBooksWidget> {
  User user;
  BookSelectedCallback onSelected;

  Set<String> keys = {};
  List<Book> suggestions = [];
  TextEditingController textController;
  bool my = true, his = true;

  StreamSubscription<QuerySnapshot> bookSubscription;
  List<DocumentSnapshot> books = [];

  @override
  void initState() {
    super.initState();

    textController = new TextEditingController();

    books = [];
    bookSubscription = Firestore.instance
        .collection('bookrecords')
        .where("holderId", isEqualTo: B.user.id)
        .where("transit", isEqualTo: false)
        .snapshots()
        .listen((snap) async {
      // Update list of document snapshots
      books = snap.documents;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    textController.dispose();
    bookSubscription.cancel();
    super.dispose();
  }

  _MyBooksWidgetState({this.user, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverAppBar(
        // Provide a standard title.
        title:
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          userPhoto(user, 40),
          Expanded(
              child: Container(
                  margin: EdgeInsets.only(left: 5.0),
                  child: Text(
                    user.name,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle
                        .apply(color: C.titleText),
                  ))),
        ]),
        // Allows the user to reveal the app bar if they begin scrolling
        // back up the list of items.
        floating: true,
        pinned: true,
        snap: true,
        // Display a placeholder widget to visualize the shrinking size.
        flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: ListView(
                //crossAxisAlignment: CrossAxisAlignment.start,
                //mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Container(height: 42),
                  new Container(
                    //decoration: BoxDecoration(color: Colors.transparent),
                    color: Colors.transparent,
                    padding: new EdgeInsets.all(5.0),
                    child: new Row(
                      //mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        new Expanded(
                          child: Theme(
                              data: ThemeData(platform: TargetPlatform.android),
                              child: TextField(
                                maxLines: 1,
                                controller: textController,
                                style: Theme.of(context)
                                    .textTheme
                                    .title
                                    .apply(color: Colors.white),
                                decoration: InputDecoration(
                                  //border: InputBorder.none,
                                  hintText: S.of(context).hintAuthorTitle,
                                  hintStyle: C.hints.apply(color: C.inputHints),
                                ),
                              )),
                        ),
                        Container(
                            padding: EdgeInsets.only(left: 0.0),
                            child: IconButton(
                              color: Colors.white,
                              icon: assetIcon(search_100, size: 30),
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  keys = getKeys(textController.text);
                                });
                              },
                            )),
                      ],
                    ),
                  ),
                  new Container(
                      color: Colors.transparent,
                      padding: new EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Row(
                          //mainAxisSize: MainAxisSize.min,
                          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            new Expanded(
                                child: new Wrap(
                                    alignment: WrapAlignment.end,
                                    spacing: 2.0,
                                    runSpacing: 0.0,
                                    children: <Widget>[
                                  FilterChip(
                                    //avatar: icon,
                                    label:
                                        Text(S.of(context).chipHisBooksWithMe),
                                    selected: his,
                                    onSelected: (bool s) {
                                      setState(() {
                                        his = s;
                                      });
                                    },
                                  ),
                                  FilterChip(
                                    //avatar: icon,
                                    label: Text(S.of(context).chipMyBooks),
                                    selected: my,
                                    onSelected: (bool s) {
                                      setState(() {
                                        my = s;
                                      });
                                    },
                                  ),
                                ]))
                          ]))
                ])),
        // Make the initial height of the SliverAppBar larger than normal.
        expandedHeight: 150,
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          Bookrecord rec = new Bookrecord.fromJson(books[index].data);

          if (my && rec.ownerId != user.id || his && rec.ownerId == user.id) {
            return new BookrecordWidget(
                bookrecord: rec,
                builder: (context, rec) {
                  // TODO: Add authors titles aand onTap
                  return GestureDetector(
                      onTap: () async {
                        if (onSelected != null) onSelected(context, rec);
                      },
                      child: Row(children: <Widget>[
                        bookImage(rec, 50, padding: 5.0),
                        Expanded(
                            child: Container(
                                margin: EdgeInsets.only(left: 10.0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text('${rec.authors[0]}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .body1),
                                      Text('\"${rec.title}\"',
                                          style:
                                              Theme.of(context).textTheme.body1)
                                    ])))
                      ]));
                });
          } else {
            return Container(height: 0.0, width: 0.0);
          }
        }, childCount: books.length),
      )
    ]);
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => math.max(maxHeight, minHeight);
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class UserProfileWidget extends StatefulWidget {
  UserProfileWidget({Key key, @required this.user}) : super(key: key);

  final User user;

  @override
  _UserProfileWidgetState createState() =>
      new _UserProfileWidgetState(user: user);
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  TextEditingController textController;
  User user;
  List<DocumentSnapshot> booksBorrowed = [];
  List<DocumentSnapshot> booksLent = [];
  List<DocumentSnapshot> booksAvailable = [];
  StreamSubscription<QuerySnapshot> booksBorrowedStream;
  StreamSubscription<QuerySnapshot> booksLentStream;
  StreamSubscription<QuerySnapshot> booksAvailableStream;

  Set<String> keys = {};
  Wallet wallet;

  @override
  void initState() {
    super.initState();

    textController = new TextEditingController();

    // Read user balance
    wallet = Wallet(id: user.id);
    wallet.ref.get().then((snap) {
      if (snap.exists)
        setState(() {
          wallet = Wallet.fromJson(snap.data);
        });
    });

    booksBorrowed = [];
    booksBorrowedStream = Firestore.instance
        .collection('bookrecords')
        .where("holderId", isEqualTo: user.id)
        .where("transit", isEqualTo: false)
        .where("ownerId", isEqualTo: B.user.id)
        .where("wish", isEqualTo: false)
        .snapshots()
        .listen((snap) {
      booksBorrowed = snap.documents;
      if (mounted) setState(() {});
    });

    booksLent = [];
    booksLentStream = Firestore.instance
        .collection('bookrecords')
        .where("ownerId", isEqualTo: user.id)
        .where("transit", isEqualTo: false)
        .where("holderId", isEqualTo: B.user.id)
        .where("wish", isEqualTo: false)
        .snapshots()
        .listen((snap) {
      booksLent = snap.documents;
      if (mounted) setState(() {});
    });

    booksAvailable = [];
    booksAvailableStream = Firestore.instance
        .collection('bookrecords')
        .where("holderId", isEqualTo: user.id)
        .where("transit", isEqualTo: false)
        .where("wish", isEqualTo: false)
        .snapshots()
        .listen((snap) {
      booksAvailable = snap.documents;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    textController.dispose();
    booksBorrowedStream.cancel();
    booksLentStream.cancel();
    booksAvailableStream.cancel();

    super.dispose();
  }

  _UserProfileWidgetState({Key key, @required this.user});

  @override
  Widget build(BuildContext context) {
    List<Widget> slivers = <Widget>[];

    /*
    slivers.add(SliverPersistentHeader(
      pinned: true,
      floating: true,
      delegate: _SliverAppBarDelegate(
        minHeight: 100.0,
        maxHeight: 100.0,
        child: Container(color: Colors.white, child:
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          userPhoto(user, 90),
          Expanded(
              child: Container(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(user.name,
                            style: Theme.of(context).textTheme.title),
                        Row(children: <Widget>[
                          new Container(
                              margin: EdgeInsets.only(right: 5.0),
                              child: new Icon(MyIcons.money)),
                          new Text(
                              // TODO: Get actual balance from Wallet
                              money(user?.getAvailable()),
                              style: Theme.of(context).textTheme.body1)
                        ]),
                      ]))),
        ]),
        )),
    ));
*/
    if (booksBorrowed.length > 0) {
      slivers.add(
        SliverPersistentHeader(
          pinned: true,
          floating: false,
          delegate: _SliverAppBarDelegate(
            minHeight: 45.0,
            maxHeight: 130.0,
            child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Container(
                    height: 130,
                    color: C.background,
                    child: Column(mainAxisSize: MainAxisSize.min, children: <
                        Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: new EdgeInsets.only(left: 10.0, right: 10.0),
                        height: 45.0,
                        child: Text(
                          S.of(context).myBooksWithUser(booksBorrowed.length),
                          style: Theme.of(context).textTheme.subtitle,
                        ),
                      ),
                      Expanded(
                          child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: booksBorrowed.map((doc) {
                                Bookrecord rec =
                                    new Bookrecord.fromJson(doc.data);
                                return BookrecordWidget(
                                    bookrecord: rec,
                                    builder: (context, rec) {
                                      return Stack(children: <Widget>[
                                        Container(
                                            margin: EdgeInsets.all(5.0),
                                            child: bookImage(rec, 80.0,
                                                sameHeight: true)),
                                        Positioned.fill(
                                            child: Container(
                                                alignment: Alignment.topRight,
                                                child: GestureDetector(
                                                    onTap: () {
                                                      // TODO: Add book to transit (make helper function)
                                                      // Request book to return
                                                    },
                                                    child: ClipOval(
                                                      child: Container(
                                                        color: C.button,
                                                        height:
                                                            20.0, // height of the button
                                                        width:
                                                            20.0, // width of the button
                                                        child: Center(
                                                            child: assetIcon(
                                                                return_100,
                                                                size: 14)),
                                                      ),
                                                    ))))
                                      ]);
                                    });
                              }).toList())),
                    ]))),
          ),
        ),
      );
    }

    if (booksLent.length > 0) {
      slivers.add(
        SliverPersistentHeader(
          pinned: true,
          floating: false,
          delegate: _SliverAppBarDelegate(
            minHeight: 45.0,
            maxHeight: 130.0,
            child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Container(
                    height: 130,
                    color: C.background,
                    child: Column(mainAxisSize: MainAxisSize.min, children: <
                        Widget>[
                      Container(
                          alignment: Alignment.centerLeft,
                          padding: new EdgeInsets.only(left: 10.0, right: 10.0),
                          height: 45.0,
                          child: Text(
                            S.of(context).booksOfUserWithMe(booksLent.length),
                            style: Theme.of(context).textTheme.subtitle,
                          )),
                      Expanded(
                          child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: booksLent.map((doc) {
                                Bookrecord rec =
                                    new Bookrecord.fromJson(doc.data);
                                return BookrecordWidget(
                                    bookrecord: rec,
                                    builder: (context, rec) {
                                      return Stack(children: <Widget>[
                                        Container(
                                            margin: EdgeInsets.all(5.0),
                                            child: bookImage(rec, 80.0,
                                                sameHeight: true)),
                                        Positioned.fill(
                                            child: Container(
                                                alignment: Alignment.topRight,
                                                child: GestureDetector(
                                                    onTap: () {
                                                      // TODO: Add book to transit (make helper function)
                                                      // Initiate book return
                                                    },
                                                    child: ClipOval(
                                                      child: Container(
                                                        color: C.button,
                                                        height:
                                                            20.0, // height of the button
                                                        width:
                                                            20.0, // width of the button
                                                        child: Center(
                                                            child: assetIcon(
                                                                return_100,
                                                                size: 14)),
                                                      ),
                                                    ))))
                                      ]);
                                    });
                              }).toList())),
                    ]))),
          ),
        ),
      );
    }

    slivers.add(SliverPersistentHeader(
      pinned: true,
      floating: false,
      delegate: _SliverAppBarDelegate(
          minHeight: 45.0,
          maxHeight: 95.0,
          child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Container(
                  height: 95.0,
                  color: C.background,
                  child:
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Container(
                        alignment: Alignment.centerLeft,
                        padding: new EdgeInsets.only(left: 10.0, right: 10.0),
                        height: 45.0,
                        child: Text(
                          S.of(context).profileUserBooks(booksAvailable.length),
                          style: Theme.of(context).textTheme.subtitle,
                        )),
                    new Container(
                      height: 45.0,
                      padding: new EdgeInsets.only(left: 10.0, right: 10.0),
                      child: new Row(
                        //mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          new Expanded(
                            child: Theme(
                                data:
                                    ThemeData(platform: TargetPlatform.android),
                                child: TextField(
                                  maxLines: 1,
                                  controller: textController,
                                  style: Theme.of(context).textTheme.title,
                                  decoration: InputDecoration(
                                    //border: InputBorder.none,
                                    hintText: S.of(context).hintAuthorTitle,
                                    hintStyle:
                                        C.hints.apply(color: C.inputHints),
                                  ),
                                )),
                          ),
                          Container(
                              padding: EdgeInsets.only(left: 0.0),
                              child: IconButton(
                                color: Colors.white,
                                icon: assetIcon(search_100, size: 30),
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  setState(() {
                                    keys = getKeys(textController.text);
                                  });
                                },
                              )),
                        ],
                      ),
                    ),
                  ])))),
    ));

    slivers.add(SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
      Bookrecord rec = new Bookrecord.fromJson(booksAvailable[index].data);
      return BookrecordWidget(
          bookrecord: rec,
          filter: keys,
          builder: (context, rec) {
            return new Container(
                margin: EdgeInsets.all(3.0),
                child: GestureDetector(
                    onTap: () async {
                      // TODO: Add book to transit (helper functon)
                    },
                    child: Row(children: <Widget>[
                      bookImage(rec, 50),
                      Expanded(
                          child: Container(
                              margin: EdgeInsets.only(left: 10.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('${rec.authors[0]}',
                                        style:
                                            Theme.of(context).textTheme.body1),
                                    Text('\"${rec.title}\"',
                                        style:
                                            Theme.of(context).textTheme.body1)
                                  ])))
                    ])));
          });
    }, childCount: booksAvailable.length)));

    return Scaffold(
        appBar: new AppBar(
          title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                userPhoto(user, 40),
                Expanded(
                    child: Container(
                        margin: EdgeInsets.only(left: 5.0),
                        child: Text(
                          user.name,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle
                              .apply(color: C.titleText),
                        ))),
              ]),
          centerTitle: false,
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(25.0),
              child: Container(
                  height: 25.0,
                  margin: EdgeInsets.only(left: 72.0),
                  alignment: Alignment.topLeft,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text(S.of(context).userBalance(money(wallet.getAvailable())),
                            style: Theme.of(context)
                                .textTheme
                                .body1
                                .apply(color: C.titleText)),
                        /*
                        new Text('Репутация: 10.0',
                            style: Theme.of(context)
                                .textTheme
                                .body1
                                .apply(color: Colors.white))
                        */
                      ]))),
        ),
        body: CustomScrollView(slivers: slivers));
  }
}
