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
    @required this.currentUser,
  }) : super(key: key);

  final User currentUser;

  @override
  _ChatListWidgetState createState() => new _ChatListWidgetState();
}

class _ChatListWidgetState extends State<ChatListWidget> {
  Messages chatWithBiblosphere;

  @override
  void initState() {
    super.initState();

    chatWithBiblosphere = Messages(fromId: widget.currentUser.id, system: true);
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
              ? ChatCard(
                  chat: chatWithBiblosphere,
                  currentUser: widget.currentUser)
              : Container(),
          new Expanded(
              child: new StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection('messages')
                      .where("ids", arrayContains: widget.currentUser.id)
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

                            return ChatCard(
                                chat: msgs,
                                currentUser: widget.currentUser);
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
    @required this.currentUser,
  }) : super(key: key);

  //TODO: data in Widget not State
  final Messages chat;
  final User currentUser;

  @override
  _ChatCardState createState() => new _ChatCardState(chat: chat);
}

class _ChatCardState extends State<ChatCard> {
  Messages chat;
  StreamSubscription<DocumentSnapshot> chatSubscription;

  @override
  void initState() {
    super.initState();

    if (chat.system) {
      chatSubscription = chat.ref.snapshots()
        .listen((snap) async {
          if (snap.exists) {
             chat = Messages.fromJson(snap.data, snap);
             if (mounted) setState(() {});
          }
      });
    }

    if ( !chat.fromDb ) {
      chat.ref.get().then( (snap) {
        if (snap.exists) {
          setState(() {
            chat = Messages.fromJson(snap.data, snap);
          });
        } else {
          // Create chat
          getChatAndTransit(context: context, currentUserId: widget.currentUser.id, from: chat.fromId, to: chat.toId, system: chat.system).then ((c) {
            setState(() {
              chat = c;
            });
          });
        }
      });
    }
  }

  @override
  void dispose() {
    if (chatSubscription != null) chatSubscription.cancel();

    super.dispose();
  }

  @override
  void didUpdateWidget(ChatCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.chat != widget.chat ||
        oldWidget.currentUser.id != widget.currentUser.id) {
      chat = widget.chat;
    }
  }

  _ChatCardState({Key key, @required this.chat});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          Chat.runChat(
              context, widget.currentUser, null,
              chat: chat);
        },
        child: Card(
            child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: <Widget>[
                  Row(children: <Widget>[
                    Stack(children: <Widget>[
                      chat.system ?
                        Container(margin: EdgeInsets.all(7.0), child: assetIcon(technical_support_100, size: 50.0)) :
                        userPhoto(chat.partnerImage(widget.currentUser.id), 60.0, padding: 5.0),
                      chat.system ? Container() :
                        Positioned.fill(
                          child: Container(
                              alignment:
                              Alignment.topRight,
                              child: GestureDetector(
                                  onTap: () {
                                    showBbsConfirmation(
                                        context,
                                        S
                                            .of(
                                            context)
                                            .confirmBlockUser)
                                        .then(
                                            (confirmed) {
                                          if (confirmed) {
                                            blockUser(
                                                widget
                                                    .currentUser
                                                    ?.id,
                                                chat.partnerId(widget.currentUser.id));
                                          }
                                        });
                                  },
                                  child: ClipOval(
                                    child: Container(
                                      color:
                                      C.button,
                                      height:
                                      20.0, // height of the button
                                      width:
                                      20.0, // width of the button
                                      child: Center(
                                          child: assetIcon(cancel_100,
                                              size: 20)),
                                    ),
                                  ))))
                    ]),
                    Expanded(
                        child: Container(
                            margin:
                            EdgeInsets.all(5.0),
                            child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: <Widget>[
                                  Container(
                                      child: Text(
                                          chat.system ?
                                            'Чат с поддержкой' :
                                            chat.partnerName(widget.currentUser.id),
                                          overflow:
                                          TextOverflow
                                              .ellipsis,
                                          style: Theme.of(
                                              context)
                                              .textTheme
                                              .body1)), // Description
                                  Text(
                                      chat.message ??
                                          '',
                                      style: Theme.of(
                                          context)
                                          .textTheme
                                          .body1)
                                ]))),
                    Container(
                        margin: EdgeInsets.all(5.0),
                        child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .end,
                            children: <Widget>[
                              Text(
                                  DateFormat(
                                      'H:m MMMd')
                                      .format(chat
                                      .timestamp),
                                  style: Theme.of(
                                      context)
                                      .textTheme
                                      .body1),
                              chat.unread[widget
                                  .currentUser
                                  .id] >
                                  0
                                  ? ClipOval(
                                child:
                                Container(
                                  color: Colors
                                      .green,
                                  height:
                                  25.0, // height of the button
                                  width:
                                  25.0, // width of the button
                                  child: Center(
                                      child: Text(chat
                                          .unread[widget
                                          .currentUser
                                          .id]
                                          .toString())),
                                ),
                              )
                                  : Container()
                            ])),
                  ]),
                  Container(
                      margin: EdgeInsets.all(5.0),
                      child: Text(statusText(chat),
                          overflow:
                          TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle)),
                ])));
  }

  String statusText(Messages chat) {
    final String userId = widget.currentUser.id;

    if (chat.system)
      return 'Любые вопросы по приложению';
    else if (userId == chat.fromId && chat.status == Messages.Initial) {
      return S.of(context).chatStatusInitialFrom;
    } else if (userId == chat.fromId && chat.status == Messages.Handover) {
      return S.of(context).chatStatusHandoverFrom;
    } else if (userId == chat.fromId && chat.status == Messages.Complete) {
      return S.of(context).chatStatusCompleteFrom;
    } else if (userId == chat.toId && chat.status == Messages.Initial) {
      return S.of(context).chatStatusInitialTo;
    } else if (userId == chat.toId && chat.status == Messages.Handover) {
      return S.of(context).chatStatusHandoverTo;
    } else if (userId == chat.toId && chat.status == Messages.Complete) {
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
  static runChatById(BuildContext context, User currentUser, User partner,
      {String chatId, String message, bool send = false}) async {

      DocumentSnapshot chatSnap = await Messages.Ref(chatId).get();
      if (!chatSnap.exists) throw 'Chat does not exist: ${chatId}';

      Messages chat = new Messages.fromJson(chatSnap.data, chatSnap);

      if (!chat.system && partner == null) {
        String partnerId = chat.partnerId(currentUser.id);
        DocumentSnapshot snap = await User.Ref(partnerId).get();
        if (!snap.exists)
          throw "Partner user [${partnerId}] does not exist for chat [${chat
              .id}]";
        partner = User.fromJson(snap.data);
      }

    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new Chat(
                currentUser: currentUser,
                partner: partner,
                chat: chat,
                message: message,
                send: send))).then((doc) {});
  }

  static runChat(BuildContext context, User currentUser, User partner,
      {Messages chat, String message, bool send = false}) async {

    if(!chat.system && partner == null)
      partner = User(id: chat.partnerId(currentUser.id),
        name: chat.partnerName(currentUser.id),
        photo: chat.partnerImage(currentUser.id));

    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new Chat(
                currentUser: currentUser,
                partner: partner,
                chat: chat,
                message: message,
                send: send))).then((doc) {});
  }

  Chat(
      {Key key,
      @required this.currentUser,
      @required this.partner,
      this.message,
      this.chat,
      this.send})
      : super(key: key);

  final User currentUser;
  final User partner;
  final String message;
  final bool send;
  final Messages chat;

  @override
  _ChatState createState() => new _ChatState(
      currentUser: currentUser,
      partner: partner,
      message: message,
      chat: chat,
      send: send);
}

class _ChatState extends State<Chat> {
  final User partner;
  final User currentUser;
  String message;
  bool send;
  Messages chat;
  String phase;
  bool showCart = false;

  // Conditions for the agreement
  double amountToPay = 0.0;

  // List of books in the agreement
  StreamSubscription<QuerySnapshot> streamBooks;
  List<Bookrecord> books = [];

  StreamSubscription<DocumentSnapshot> streamChat;
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

    streamChat = Firestore.instance
        .collection('messages')
        .document(chat.id)
        .snapshots()
        .listen((snap) {
      Messages upd = new Messages.fromJson(snap.data, snap);

      if (upd.status != chat.status) {
        refreshChat();
        setState(() {
          chat = upd;
        });
      }
    });

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

      refreshChat();
    }
  }

  void refreshChat() async {
    books = [];

    if (streamBooks != null) streamBooks.cancel();

    if (chat.toMe(currentUser.id) && chat.status == Messages.Initial) {
      phase = 'initialToMe';

      streamBooks = Firestore.instance
          .collection('bookrecords')
          .where("holderId", isEqualTo: partner.id)
          .where("transit", isEqualTo: true)
          .where("confirmed", isEqualTo: false)
          .where("transitId", isEqualTo: currentUser.id)
          .where("wish", isEqualTo: false)
          .snapshots()
          .listen((snap) {
        books =
            snap.documents.map((doc) => Bookrecord.fromJson(doc.data)).toList();

        // Calculate total amount to pay for transferred books
        amountToPay = 0.0;
        for (Bookrecord b in books) {
          if (b.transitId == currentUser.id && b.ownerId != currentUser.id)
            amountToPay += b.getPrice();
        }

        if (mounted) setState(() {});
      });
    } else if (chat.fromMe(currentUser.id) && chat.status == Messages.Initial) {
      phase = 'initialFromMe';

      streamBooks = Firestore.instance
          .collection('bookrecords')
          .where("holderId", isEqualTo: currentUser.id)
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
    } else if (chat.toMe(currentUser.id) && chat.status == Messages.Handover) {
      phase = 'handoverToMe';

      streamBooks = Firestore.instance
          .collection('bookrecords')
          .where("holderId", isEqualTo: partner.id)
          .where("transit", isEqualTo: true)
          .where("confirmed", isEqualTo: true)
          .where("transitId", isEqualTo: currentUser.id)
          .where("wish", isEqualTo: false)
          .snapshots()
          .listen((snap) {
        books =
            snap.documents.map((doc) => Bookrecord.fromJson(doc.data)).toList();

        // Calculate total amount to pay for transferred books
        amountToPay = 0.0;
        for (Bookrecord b in books) {
          if (b.transitId == currentUser.id && b.ownerId != currentUser.id)
            amountToPay += b.getPrice();
        }

        if (mounted) setState(() {});
      });
    } else if (chat.fromMe(currentUser.id) &&
        chat.status == Messages.Handover) {
      phase = 'handoverFromMe';

      streamBooks = Firestore.instance
          .collection('bookrecords')
          .where("holderId", isEqualTo: currentUser.id)
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
    } else if (chat.toMe(currentUser.id) && chat.status == Messages.Complete) {
      phase = 'completeToMe';

      streamBooks = null;
      books = [];
      await Future.forEach(chat.books, (id) async {
        DocumentSnapshot snap = await Bookrecord.Ref(id).get();
        if (snap.exists)
          books.add(Bookrecord.fromJson(snap.data));
        else
          print('!!!DEBUG: book record missing: ${id}');
      });

      if (mounted) setState(() {});
    } else if (chat.fromMe(currentUser.id) &&
        chat.status == Messages.Complete) {
      phase = 'completeFromMe';

      streamBooks = null;
      books = [];
      await Future.forEach(chat.books, (id) async {
        DocumentSnapshot snap = await Bookrecord.Ref(id).get();
        if (snap.exists)
          books.add(Bookrecord.fromJson(snap.data));
        else
          print('!!!DEBUG: book record missing: ${id}');
      });

      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    if (streamBooks != null) streamBooks.cancel();

    if (streamChat != null) streamChat.cancel();

    if (streamPartnerWallet != null) streamPartnerWallet.cancel();

    super.dispose();
  }

  _ChatState(
      {Key key,
      @required this.currentUser,
      @required this.partner,
      this.message = '',
      this.chat,
      this.send});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new UserProfileWidget(
                              currentUser: currentUser,
                              user: partner,
                            )));
              },
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    chat.system
                        ? Container(margin: EdgeInsets.all(2.0), child: assetIcon(technical_support_100, size: 30.0))
          : userPhoto(partner, 40),
                    Expanded(
                        child: Container(
                            margin: EdgeInsets.only(left: 5.0),
                            child: Text(
                              chat.system ? 'ПОДДЕРЖКА' : partner.name,
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
                    //TODO: Change tooltip
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
          myId: currentUser.id,
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
    if (chat.toMe(currentUser.id)) {
      return Container(
          height: 110.0,
          child: ListView(
              scrollDirection: Axis.horizontal,
              children: books.map<Widget>((rec) {
                return BookrecordWidget(
                    bookrecord: rec,
                    currentUser: currentUser,
                    builder: (context, rec) {
                      return Stack(children: <Widget>[
                        Container(margin: EdgeInsets.all(5.0), child: bookImage(rec, 100.0, sameHeight: true)),
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
                                      new UserBooksWidget(
                                          currentUser: currentUser,
                                          user: partner),
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
                    currentUser: currentUser,
                    builder: (context, rec) {
                      return Stack(children: <Widget>[
                        Container(margin: EdgeInsets.all(5.0), child: bookImage(rec, 100.0, sameHeight: true)),
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
                                          currentUser: currentUser,
                                          user: partner),
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
    if (chat.toMe(currentUser.id))
      return Container(
          margin: EdgeInsets.only(left: 3.0, right: 3.0),
          child: Row(children: <Widget>[
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      child: Text('Залог: ${money(total(amountToPay))}',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.body1)),
                  Container(
                      child: Text(
                          'Оплата в месяц: ${money(monthly(amountToPay))}',
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
                    child: Text('Доход в месяц: ${money(income(amountToPay))}',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.body1)),
              ]),
          Expanded(
              child: Container(
                  padding: EdgeInsets.only(left: 10.0), child: getButton()))
          ]));
  }

  Widget getButton() {
    if (chat.toMe(currentUser.id) &&
        chat.status != Messages.Complete &&
        total(amountToPay) >= currentUser.getAvailable())
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
          List<int> codes = [50, 100, 200, 500, 1000, 2000];
          int missing =
          (total(amountToPay) - currentUser.getAvailable()).ceil();
          int code =
          codes.firstWhere((code) => code > missing, orElse: () => 2000);

          Set<String> _kIds = {code.toString()};
          final ProductDetailsResponse response =
          await InAppPurchaseConnection.instance.queryProductDetails(_kIds);
          if (!response.notFoundIDs.isEmpty) {
            // TODO: Process this more nicely
            throw ('Ids of in-app products not available');
          }
          List<ProductDetails> products = response.productDetails;
          final PurchaseParam purchaseParam = PurchaseParam(
              productDetails: products.first, sandboxTesting: true);
          InAppPurchaseConnection.instance
              .buyConsumable(purchaseParam: purchaseParam);
        },
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(20.0)),
      );
    else if (chat.toMe(currentUser.id) && chat.status == Messages.Handover && books != null && books.length > 0)
      return RaisedButton(
        textColor: C.buttonText,
        color: C.button,
        child: new Text(S.of(context).buttonConfirmBooks,
            style:
            Theme.of(context).textTheme.body1.apply(color: Colors.white)),
        onPressed: () async {
          transferBooks(partner);
        },
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(20.0)),
      );
    else if (chat.fromMe(currentUser.id) &&
        chat.status == Messages.Initial &&
        total(amountToPay) < partnerBalance && books != null && books.length > 0)
      return RaisedButton(
        textColor: C.buttonText,
        color: C.button,
        child: new Text(S.of(context).buttonGivenBooks,
            style:
            Theme.of(context).textTheme.body1.apply(color: Colors.white)),
        onPressed: () async {
          confirmBooks(partner);
        },
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(20.0)),
      );

    return Container(width: 0.0, height: 0.0);
  }

  String getLongText() {
    if (chat.status == Messages.Initial && chat.toMe(currentUser.id)) {
      if (books == null || books.length == 0)
        return 'Добавьте книги';
      else if (currentUser.getAvailable() < total(amountToPay))
        return 'Пополните баланс на ${money(total(amountToPay) - currentUser.getAvailable())}';
      else
        return 'Договоритесь о встрече';
    } else if (chat.status == Messages.Initial && chat.fromMe(currentUser.id)) {
      if (amountToPay > 0.0 && amountToPay > partnerBalance)
        return 'Получатель книг должен пополнить баланс';
      else if (amountToPay > 0.0 && amountToPay <= partnerBalance)
        // Some books to be rented (not returned)
        return 'Подтвердите, что отдали книги';
      else
        // All books are returning (not rented)
        return 'Подтвердите, что отдали книги';
    } else if (chat.status == Messages.Handover && chat.toMe(currentUser.id)) {
      return 'Подтвердите получение книг';
    } else if (chat.status == Messages.Handover &&
        chat.fromMe(currentUser.id)) {
      return 'Получатель должен подтвердить получение книг';
    } else if (chat.status == Messages.Complete && chat.toMe(currentUser.id)) {
      return 'Книги успешно получены';
    } else if (chat.status == Messages.Complete &&
        chat.fromMe(currentUser.id)) {
      return 'Книги успешно переданы';
    }
    // TODO: Add other phases and directions
    return '';
  }

  Future<void> confirmBooks(User partner) async {
    QuerySnapshot snap = await Firestore.instance
        .collection('bookrecords')
        .where("holderId", isEqualTo: currentUser.id)
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

    chat.ref.updateData({'status': Messages.Handover, 'books': books.map((b) => b.id).toList()});
    chat.status = Messages.Handover;

    setState(() {});
  }

  Future<void> transferBooks(User partner) async {
    QuerySnapshot snap = await Firestore.instance
        .collection('bookrecords')
        .where("holderId", isEqualTo: partner.id)
        .where("transit", isEqualTo: true)
        .where("confirmed", isEqualTo: true)
        .where("transitId", isEqualTo: currentUser.id)
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
        .where(
            (rec) => rec.ownerId != currentUser.id && rec.ownerId != partner.id)
        .toList();

    // Books returned to owner
    List<Bookrecord> booksReturned =
        books.where((rec) => rec.ownerId == currentUser.id).toList();

    if (booksTaken.length > 0) {
      await deposit(books: booksTaken, owner: partner, payer: currentUser);
    }

    if (booksPassed.length > 0) {
      await pass(books: booksPassed, holder: partner, payer: currentUser);
    }

    if (booksReturned.length > 0) {
      await complete(books: booksReturned, holder: partner, owner: currentUser);
    }

    chat.ref.updateData({'status': Messages.Complete, 'books': books.map((b) => b.id).toList()});
    chat.status = Messages.Complete;
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

    AuthGoogle(fileJson: "assets/dialogflow.json").build().then((auth) {
      dialogflow =
          Dialogflow(authGoogle: auth, language: Intl.getCurrentLocale());

      if (message != null && send) {
        onSendMessage(message, 0);
      }
    });

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
              'id': chat.id, // Update ID to recover for old chats (old version of app)
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
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
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
                          width: 200.0,
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
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
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
                                width: 200.0,
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

// Class to show users books (to add into transit/chat)
class UserBooksWidget extends StatefulWidget {
  UserBooksWidget({
    Key key,
    @required this.currentUser,
    @required this.user,
  }) : super(key: key);

  final User currentUser;
  final User user;

  @override
  _UserBooksWidgetState createState() =>
      new _UserBooksWidgetState(currentUser: currentUser, user: user);
}

class _UserBooksWidgetState extends State<UserBooksWidget> {
  User currentUser;
  User user;
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

  _UserBooksWidgetState({this.currentUser, this.user});

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

          if (my && rec.ownerId == widget.currentUser.id ||
              his && rec.ownerId != widget.currentUser.id) {
            return new BookrecordWidget(
                bookrecord: rec,
                currentUser: widget.currentUser,
                builder: (context, rec) {
                  // TODO: Add authors titles aand onTap
                  return GestureDetector(
                      onTap: () async {
                        // Add book to a chat
                        Messages chat = await getChatAndTransit(
                            context: context,
                            currentUserId: currentUser.id,
                            from: rec.holderId,
                            to: currentUser.id,
                            bookrecordId: rec.id);
                        if (chat != null)
                          showSnackBar(
                            context, S.of(context).snackBookAddedToCart);
                        else
                          showSnackBar(
                              context, S.of(context).snackBookNotConfirmed);
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
    @required this.currentUser,
    @required this.user,
  }) : super(key: key);

  final User currentUser;
  final User user;

  @override
  _MyBooksWidgetState createState() =>
      new _MyBooksWidgetState(currentUser: currentUser, user: user);
}

class _MyBooksWidgetState extends State<MyBooksWidget> {
  User currentUser;
  User user;
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
        .where("holderId", isEqualTo: currentUser.id)
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

  _MyBooksWidgetState({this.currentUser, this.user});

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
                currentUser: widget.currentUser,
                builder: (context, rec) {
                  // TODO: Add authors titles aand onTap
                  return GestureDetector(
                      onTap: () async {
                        // Add book to a chat
                        Messages chat = await getChatAndTransit(
                            context: context,
                            currentUserId: currentUser.id,
                            from: currentUser.id,
                            to: user.id,
                            bookrecordId: rec.id);
                        if (chat != null)
                          showSnackBar(
                              context, S.of(context).snackBookAddedToCart);
                        else
                          showSnackBar(
                              context, S.of(context).snackBookPending);
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
  UserProfileWidget({Key key, @required this.currentUser, @required this.user})
      : super(key: key);

  final User currentUser;
  final User user;

  @override
  _UserProfileWidgetState createState() =>
      new _UserProfileWidgetState(currentUser: currentUser, user: user);
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  TextEditingController textController;
  User currentUser;
  User user;
  List<DocumentSnapshot> booksBorrowed = [];
  List<DocumentSnapshot> booksLent = [];
  List<DocumentSnapshot> booksAvailable = [];
  StreamSubscription<QuerySnapshot> booksBorrowedStream;
  StreamSubscription<QuerySnapshot> booksLentStream;
  StreamSubscription<QuerySnapshot> booksAvailableStream;

  Set<String> keys = {};

  @override
  void initState() {
    super.initState();

    textController = new TextEditingController();

    booksBorrowed = [];
    booksBorrowedStream = Firestore.instance
        .collection('bookrecords')
        .where("holderId", isEqualTo: user.id)
        .where("transit", isEqualTo: false)
        .where("ownerId", isEqualTo: currentUser.id)
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
        .where("holderId", isEqualTo: currentUser.id)
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

  _UserProfileWidgetState(
      {Key key, @required this.currentUser, @required this.user});

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
                          'Мои книги у этого пользователя (${booksBorrowed.length})',
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
                                    currentUser: currentUser,
                                    builder: (context, rec) {
                                      return Stack(children: <Widget>[
                                        Container(margin: EdgeInsets.all(5.0), child: bookImage(rec, 80.0,
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
                            'Книги этого пользователя у меня (${booksLent.length})',
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
                                    currentUser: currentUser,
                                    builder: (context, rec) {
                                      return Stack(children: <Widget>[
                                        Container(margin: EdgeInsets.all(5.0), child: bookImage(rec, 80.0,
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
                                                            child: assetIcon(return_100,
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
                          'Книги пользователя (${booksAvailable.length})',
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
                  ])))),
    ));

    slivers.add(SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
      Bookrecord rec = new Bookrecord.fromJson(booksAvailable[index].data);
      return BookrecordWidget(
          bookrecord: rec,
          currentUser: currentUser,
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
                        new Text('Баланс: ${money(user?.getAvailable())}',
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
