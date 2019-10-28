import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:biblosphere/l10n.dart';
import 'package:biblosphere/const.dart';
import 'package:biblosphere/helpers.dart';
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
  @override
  void initState() {
    super.initState();
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
          new Expanded(
              child: new StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection('messages')
                      .where("ids", arrayContains: widget.currentUser.id)
                      .where('blocked', isEqualTo: 'no')
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
                              child: Text(S.of(context).noMessages,
                                style: Theme.of(context).textTheme.body1,
                              ));
                        }
                        return new ListView(
                          children: snapshot.data.documents
                              .map((DocumentSnapshot document) {
                            // Find userId of the conact in this chat
                            Messages msgs =
                                new Messages.fromJson(document.data);
                            return new ChatCard(
                                chat: msgs,
                                currentUser: widget.currentUser,
                                builder: (context, chat, user) {
                                  return GestureDetector(
                                      onTap: () async {
                                        Chat.runChat(
                                            context, widget.currentUser, user);
                                      },
                                      child: Card(
                                          child: Row(children: <Widget>[
                                        Stack(children: <Widget>[
                                          userPhoto(user, 60.0, padding: 5.0),
                                          Positioned.fill(
                                              child: Container(
                                                  alignment: Alignment.topRight,
                                                  child: GestureDetector(
                                                      onTap: () {
                                                        showBbsConfirmation(
                                                                context,
                                                                S
                                                                    .of(context)
                                                                    .confirmBlockUser)
                                                            .then((confirmed) {
                                                          if (confirmed) {
                                                            blockUser(
                                                                widget
                                                                    .currentUser
                                                                    ?.id,
                                                                user.id);
                                                          }
                                                        });
                                                      },
                                                      child: ClipOval(
                                                        child: Container(
                                                          color: Colors.red,
                                                          height:
                                                              20.0, // height of the button
                                                          width:
                                                              20.0, // width of the button
                                                          child: Center(
                                                              child: new Icon(
                                                                  MyIcons
                                                                      .cancel_cross,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 10)),
                                                        ),
                                                      ))))
                                        ]),
                                        Expanded(
                                            child: Container(
                                                margin: EdgeInsets.all(5.0),
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(user.name,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .body1),
                                                      Text(chat.message ?? '',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .body1)
                                                    ]))),
                                        Container(
                                            margin: EdgeInsets.all(5.0),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: <Widget>[
                                                  Text(
                                                      DateFormat('H:m MMMd')
                                                          .format(
                                                              chat.timestamp),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .body1),
                                                  chat.unread[widget.currentUser.id] > 0
                                                      ? ClipOval(
                                                          child: Container(
                                                            color: Colors.green,
                                                            height:
                                                                25.0, // height of the button
                                                            width:
                                                                25.0, // width of the button
                                                            child: Center(
                                                                child: Text(chat
                                                                    .unread[widget.currentUser.id]
                                                                    .toString())),
                                                          ),
                                                        )
                                                      : Container()
                                                ])),
                                      ])));
                                });
                          }).toList(),
                        );
                    }
                  })),
        ],
      ),
    );
  }

  void blockUser(String blockingUser, String blockedUser) {
    Firestore.instance
        .collection('messages')
        .document(chatId(blockingUser, blockedUser))
        .updateData({'blocked': 'yes'});
  }
}

typedef ChatCardBuilder = Widget Function(
    BuildContext context, Messages chat, User user);

class ChatCard extends StatefulWidget {
  ChatCard({
    Key key,
    @required this.chat,
    @required this.currentUser,
    @required this.builder,
  }) : super(key: key);

  //TODO: data in Widget not State
  final Messages chat;
  final User currentUser;
  final ChatCardBuilder builder;

  @override
  _ChatCardState createState() => new _ChatCardState(chat: chat);
}

class _ChatCardState extends State<ChatCard> {
  User partner;
  Messages chat;

  @override
  void initState() {
    super.initState();
    chat.getDetails(widget.currentUser).whenComplete(() {
      partner = chat.partner(widget.currentUser.id);
      if (mounted) setState(() {});
    });
  }

  _ChatCardState({Key key, @required this.chat});

  @override
  Widget build(BuildContext context) {
    if (chat == null || !chat.hasData)
      return Container();
    else
      return widget.builder(context, chat, partner);
  }
}

void openMsg(BuildContext context, String user, User currentUser) async {
  try {
    bool isBlocked = false;
    bool isNewChat = true;
    DocumentSnapshot chatSnap = await Firestore.instance
        .collection('messages')
        .document(chatId(currentUser.id, user))
        .get();
    if (chatSnap.exists) {
      isNewChat = false;
      if (chatSnap['blocked'] == 'yes') {
        isBlocked = true;
      }
    }

    if (isBlocked) {
      showBbsDialog(context, S.of(context).blockedChat);
      return;
    }

    DocumentSnapshot userSnap =
        await Firestore.instance.collection('users').document(user).get();
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new Chat(
                  currentUser: currentUser,
                  partner: new User.fromJson(userSnap.data),
                  isNewChat: isNewChat,
                )));
  } catch (ex, stack) {
    print("Chat screen failed: " + ex.toString());
    FlutterCrashlytics().logException(ex, stack);
  }
}

class Chat extends StatefulWidget {
  static runChat(BuildContext context, User currentUser, User partner,
      {String message}) async {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new Chat(
                  currentUser: currentUser,
                  partner: partner,
                  message: message,
                  isNewChat: false,
                ))).then((doc) {});
  }

  Chat(
      {Key key,
      @required this.currentUser,
      @required this.partner,
      @required this.isNewChat,
      this.message})
      : super(key: key);

  final User currentUser;
  final User partner;
  final bool isNewChat;
  final String message;

  @override
  _ChatState createState() => new _ChatState(
      currentUser: currentUser,
      partner: partner,
      isNewChat: isNewChat,
      message: message);
}

class _ChatState extends State<Chat> {
  //List<Book> suggestions = [];
  final User partner;
  final User currentUser;
  final bool isNewChat;
  String message;
  Stream<QuerySnapshot> streamBooksToReceive;
  Stream<QuerySnapshot> streamBooksToGive;
  int booksToReceive = 0;
  int booksToGive = 0;

  @override
  void initState() {
    super.initState();
    streamBooksToReceive = Firestore.instance
        .collection('bookrecords')
        .where("holderId", isEqualTo: partner.id)
        .where("transit", isEqualTo: true)
        .where("transitId", isEqualTo: currentUser.id)
        .where("wish", isEqualTo: false)
        .snapshots();

    streamBooksToReceive.listen((snap) {
      if (mounted)
        setState(() {
          booksToReceive = snap.documents?.length;
        });
    });

    streamBooksToGive = Firestore.instance
        .collection('bookrecords')
        .where("holderId", isEqualTo: currentUser.id)
        .where("transit", isEqualTo: true)
        .where("transitId", isEqualTo: partner.id)
        .where("wish", isEqualTo: false)
        .snapshots();

    streamBooksToGive.listen((snap) {
      if (mounted)
        setState(() {
          booksToGive = snap.documents?.length;
        });
    });
  }

  _ChatState(
      {Key key,
      @required this.currentUser,
      @required this.partner,
      @required this.isNewChat,
      this.message = ''});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                userPhoto(partner, 40),
                Expanded(
                    child: Container(
                        margin: EdgeInsets.only(left: 5.0),
                        child: Text(
                          partner.name,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle
                              .apply(color: Colors.white),
                        ))),
              ]),
          centerTitle: false,
        ),
        body: new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Card(
                  color: Colors.amber[100],
                  child: Container(
                      margin: EdgeInsets.all(10.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            //TODO: translate
                            GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      new MaterialPageRoute(
                                          //TODO: translation
                                          builder: (context) => buildScaffold(
                                              context,
                                              S.of(context).titleReceiveBooks,
                                              new RequestBooksWidget(
                                                  currentUser: currentUser,
                                                  partner: partner))));
                                },
                                child: Text(S.of(context).receiveBooks(booksToReceive),
                                    style: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .apply(color: Colors.blue))),
                            GestureDetector(
                                onTap: () {
                                  if (booksToGive > 0)
                                    Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                            //TODO: translation
                                            builder: (context) => buildScaffold(
                                                context,
                                                S.of(context).titleSendBooks,
                                                new GiveBooksWidget(
                                                    currentUser: currentUser,
                                                    partner: partner))));
                                },
                                child: Text(S.of(context).sendBooks(booksToGive),
                                    style: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .apply(color: Colors.blue))),
                          ]))),
              Expanded(
                  child: new ChatScreen(
                      myId: currentUser.id,
                      partner: partner,
                      isNewChat: isNewChat,
                      message: message)),
            ]));
  }
}

class ChatScreen extends StatefulWidget {
  final String myId;
  final User partner;
  final bool isNewChat;
  final String message;

  ChatScreen(
      {Key key,
      @required this.myId,
      @required this.partner,
      @required this.isNewChat,
      this.message = ''})
      : super(key: key);

  @override
  State createState() => new ChatScreenState(
      myId: myId, partner: partner, isNewChat: isNewChat, message: message);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState(
      {Key key,
      @required this.myId,
      @required this.partner,
      @required this.isNewChat,
      this.message});

  User partner;
  String myId;
  bool isNewChat;
  String message;

  var listMessage;
  String groupChatId;
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

    groupChatId = chatId(myId, partner.id);

    isLoading = false;
    imageUrl = '';

    updateUnread();
  }

  updateUnread() async {
    var chatRef = Firestore.instance.collection('messages').document(groupChatId);
    Firestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snap = await chatRef.get();
      if (snap.exists) {
        Messages msgs = new Messages.fromJson(snap.data);
        await transaction.update(
          chatRef,
          {
            'unread': {partner.id: msgs.unread[partner.id], myId: 0}
          },
        );
      }
    });
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();
      if (message != null) message = null;

      //TODO: strange but now() at the same moment return different values in different timezones.
      //      to compensate it timeZoneOffset is added to have proper sequence of messages in the
      //      chat. However it does not look quite right for me.
      DateTime time = DateTime.now();
      time = time.add(time.timeZoneOffset);
      String timestamp = time.millisecondsSinceEpoch.toString();

      // Add message
      var msgRef = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(timestamp);

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          msgRef,
          {
            'idFrom': myId,
            'idTo': partner.id,
            'timestamp': timestamp,
            'content': content,
            'type': type
          },
        );
      });
      // Update chat
      var chatRef =
          Firestore.instance.collection('messages').document(groupChatId);

      if (isNewChat) {
        Firestore.instance.runTransaction((transaction) async {
          await transaction.set(
            chatRef,
            {
              'ids': [partner.id, myId],
              'timestamp': timestamp,
              'message': content.length < 20
                  ? content
                  : content.substring(0, 20) + '\u{2026}',
              'blocked': 'no',
              'unread': {partner.id: 1, myId: 0}
            },
          );
        });
        isNewChat = false;
      } else {
        Firestore.instance.runTransaction((transaction) async {
          DocumentSnapshot snap = await chatRef.get();
          if (snap.exists) {
            Messages msgs = new Messages.fromJson(snap.data);
            await transaction.update(
              chatRef,
              {
                'ids': [partner.id, myId],
                'message': content.length < 20
                    ? content
                    : content.substring(0, 20) + '\u{2026}',
                'timestamp': timestamp,
                'unread': {partner.id: msgs.unread[partner.id] + 1, myId: 0}
              },
            );
          }
        });
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
                    style: TextStyle(color: primaryColor),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: greyColor2,
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
                          style: TextStyle(color: Colors.white),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                            color: primaryColor,
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
                icon: new Icon(Icons.send),
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
      child: groupChatId == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
          : StreamBuilder(
              stream: Firestore.instance
                  .collection('messages')
                  .document(groupChatId)
                  .collection(groupChatId)
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

class RequestBooksWidget extends StatefulWidget {
  RequestBooksWidget(
      {Key key, @required this.currentUser, @required this.partner})
      : super(key: key);

  final User currentUser;
  final User partner;

  @override
  _RequestBooksWidgetState createState() =>
      new _RequestBooksWidgetState(currentUser: currentUser, partner: partner);
}

class _RequestBooksWidgetState extends State<RequestBooksWidget> {
  TextEditingController textController;
  final User currentUser;
  final User partner;
  double amountToPay = 0.0;
  List<Bookrecord> books = [];
  StreamSubscription<QuerySnapshot> bookSubscription;

  Set<String> keys = {};

  @override
  void initState() {
    super.initState();

    textController = new TextEditingController();

    books = [];
    amountToPay = 0.0;
    bookSubscription = Firestore.instance
        .collection('bookrecords')
        .where("holderId", isEqualTo: partner.id)
        .where("transit", isEqualTo: true)
        .where("transitId", isEqualTo: currentUser.id)
        .where("wish", isEqualTo: false)
        .snapshots()
        .listen((snap) {
      if (snap.documentChanges.length > 0) {
        snap.documentChanges.forEach((doc) {
          if (doc.type == DocumentChangeType.added) {
            Bookrecord rec = new Bookrecord.fromJson(doc.document.data);
            rec.getBookrecord(currentUser);
            books.insert(doc.newIndex, rec);
            if ( rec.ownerId != currentUser.id)
               amountToPay += rec.getPrice();
          } else if (doc.type == DocumentChangeType.modified) {
            //TODO: Check if redraw correctly especially for child records (users and book)
            Bookrecord rec = new Bookrecord.fromJson(doc.document.data);
            rec.getBookrecord(currentUser);
            if ( books[doc.oldIndex].ownerId != currentUser.id)
               amountToPay -= books[doc.oldIndex].getPrice();
            books[doc.oldIndex] = rec;
            if ( rec.ownerId != currentUser.id)
               amountToPay += rec.getPrice();
          } else if (doc.type == DocumentChangeType.removed) {
            if ( books[doc.oldIndex].ownerId != currentUser.id)
               amountToPay -= books[doc.oldIndex].getPrice();
            books.removeAt(doc.oldIndex);
          }
        });
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    textController.dispose();
    bookSubscription.cancel();
    super.dispose();
  }

  _RequestBooksWidgetState(
      {Key key, @required this.currentUser, @required this.partner});

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
              new Container(
                child: Wrap(
                  children: books.map((Bookrecord rec) {
                    return BookrecordWidget(
                        bookrecord: rec,
                        currentUser: currentUser,
                        builder: (context, rec) {
                          return Stack(children: <Widget>[
                            bookImage(rec.book, 50.0),
                            Positioned.fill(
                                child: Container(
                                    alignment: Alignment.topRight,
                                    child: GestureDetector(
                                        onTap: () {
                                          Firestore.instance
                                              .collection('bookrecords')
                                              .document(rec.id)
                                              .updateData({
                                            'transit': false,
                                            'transitId': null,
                                            'users': [rec.holderId, rec.ownerId]
                                          });
                                        },
                                        child: ClipOval(
                                          child: Container(
                                            color: Colors.red,
                                            height:
                                                20.0, // height of the button
                                            width: 20.0, // width of the button
                                            child: Center(
                                                child: new Icon(
                                                    MyIcons.cancel_cross,
                                                    color: Colors.white,
                                                    size: 10)),
                                          ),
                                        ))))
                          ]);
                        });
                  }).toList(),
                ),
              ),
              amountToPay > 0.0
                  ? Container(
                  child: total(amountToPay) < currentUser.balance ?
                      Text(S.of(context).leaseAgreement(total(amountToPay), monthly(amountToPay))) :
                  Text(S.of(context).notSufficientForAgreement((total(amountToPay) - currentUser.getAvailable()).ceilToDouble(), total(amountToPay), monthly(amountToPay)))
              )
                  : Container(),
              new Row(children: <Widget>[
                amountToPay > 0.0 && total(amountToPay) > currentUser.balance ? new Container(
                    child: RaisedButton(
                  textColor: Colors.white,
                  color: Theme.of(context).colorScheme.secondary,
                  child: new Text(S.of(context).buttonPayin,
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .apply(color: Colors.white)),
                  onPressed: () async {
                    final bool available =
                        await InAppPurchaseConnection.instance.isAvailable();
                    if (!available) {
                      // TODO: Process this more nicely
                      throw('In-App store not available');
                    }
                    // Only show bigger amounts
                    List<int> codes = [50, 100, 200, 500, 1000, 2000];
                    int missing = (total(amountToPay) - currentUser.balance).ceil();
                    int code = codes.firstWhere((code) => code > missing, orElse: () => 2000);

                    Set<String> _kIds = {code.toString()};
                    final ProductDetailsResponse response =
                        await InAppPurchaseConnection.instance
                            .queryProductDetails(_kIds);
                    if (!response.notFoundIDs.isEmpty) {
                      // TODO: Process this more nicely
                      throw('Ids of in-app products not available');
                    }
                    List<ProductDetails> products = response.productDetails;
                    final PurchaseParam purchaseParam = PurchaseParam(
                        productDetails: products.first, sandboxTesting: true);
                    InAppPurchaseConnection.instance
                        .buyConsumable(purchaseParam: purchaseParam);
                  },
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(20.0)),
                )) : Container(),
                amountToPay == 0 && books.length > 0 || amountToPay > 0 && total(amountToPay) <= currentUser.balance ? new Container(
                    child: RaisedButton(
                  textColor: Colors.white,
                  color: Theme.of(context).colorScheme.secondary,
                  child: new Text(S.of(context).buttonConfirmBooks,
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .apply(color: Colors.white)),
                  onPressed: () {
                    transferBooks(partner);
                  },
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(20.0)),
                )) : Container()
              ]),
              new Container(
                padding: new EdgeInsets.all(10.0),
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
                            style: Theme.of(context).textTheme.title,
                            decoration: InputDecoration(
                                //border: InputBorder.none,
                                hintText: S.of(context).hintAuthorTitle),
                          )),
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 20.0),
                        child: RaisedButton(
                          textColor: Colors.white,
                          color: Theme.of(context).colorScheme.secondary,
                          child: new Icon(MyIcons.search, size: 30),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            setState(() {
                              keys = getKeys(textController.text);
                            });
                          },
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(20.0)),
                        )),
                  ],
                ),
              ),
            ]),
          ),
          new Expanded(
              child: Scrollbar(
                  child: new StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance
                          .collection('bookrecords')
                          .where("holderId", isEqualTo: partner.id)
                          .where("transit", isEqualTo: false)
                          .where("wish", isEqualTo: false)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Container();
                          default:
                            if (!snapshot.hasData ||
                                snapshot.data.documents.isEmpty) {
                              return Container();
                            }
                            return new ListView(
                              children: snapshot.data.documents
                                  .map((DocumentSnapshot document) {
                                Bookrecord rec =
                                    new Bookrecord.fromJson(document.data);
                                return BookrecordWidget(
                                    bookrecord: rec,
                                    currentUser: currentUser,
                                    filter: keys,
                                    builder: (context, rec) {
                                      return new Container(
                                          margin: EdgeInsets.all(3.0),
                                          child: GestureDetector(
                                              onTap: () async {
                                                Firestore.instance
                                                    .collection('bookrecords')
                                                    .document(rec.id)
                                                    .updateData({
                                                  'transit': true,
                                                  'transitId': currentUser.id,
                                                  'users': [
                                                    rec.holderId,
                                                    rec.ownerId,
                                                    currentUser.id
                                                  ]
                                                });
                                              },
                                              child: Row(children: <Widget>[
                                                bookImage(rec.book, 50),
                                                Expanded(
                                                    child: Container(
                                                        margin: EdgeInsets.only(
                                                            left: 10.0),
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
                                                              Text(
                                                                  '${rec.book.authors[0]}',
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .body1),
                                                              Text(
                                                                  '\"${rec.book.title}\"',
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .body1)
                                                            ])))
                                              ])));
                                    });
                              }).toList(),
                            );
                        }
                      })))
        ],
      ),
    );
  }

  Future<void> transferBooks(User partner) async {

    QuerySnapshot snap = await Firestore.instance
        .collection('bookrecords')
        .where("holderId", isEqualTo: partner.id)
        .where("transit", isEqualTo: true)
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
    List<Bookrecord> booksPassed =
    books.where((rec) => rec.ownerId != currentUser.id && rec.ownerId != partner.id).toList();

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
  }
}

class GiveBooksWidget extends StatefulWidget {
  GiveBooksWidget({Key key, @required this.currentUser, @required this.partner})
      : super(key: key);

  final User currentUser;
  final User partner;

  @override
  _GiveBooksWidgetState createState() =>
      new _GiveBooksWidgetState(currentUser: currentUser, partner: partner);
}

class _GiveBooksWidgetState extends State<GiveBooksWidget> {
  TextEditingController textController;
  final User currentUser;
  final User partner;

  @override
  void initState() {
    super.initState();

    textController = new TextEditingController();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  _GiveBooksWidgetState(
      {Key key, @required this.currentUser, @required this.partner});

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Expanded(
              child: Scrollbar(
                  child: new StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance
                          .collection('bookrecords')
                          .where("holderId", isEqualTo: currentUser.id)
                          .where("transit", isEqualTo: true)
                          .where("transitId", isEqualTo: partner.id)
                          .where("wish", isEqualTo: false)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Container();
                          default:
                            if (!snapshot.hasData ||
                                snapshot.data.documents.isEmpty) {
                              return Container();
                            }
                            return new ListView(
                              children: snapshot.data.documents
                                  .map((DocumentSnapshot document) {
                                Bookrecord rec =
                                    new Bookrecord.fromJson(document.data);
                                return BookrecordWidget(
                                    bookrecord: rec,
                                    currentUser: currentUser,
                                    builder: (context, rec) {
                                      return new Stack(children: <Widget>[
                                        Container(
                                            margin: EdgeInsets.all(3.0),
                                            child: GestureDetector(
                                                onTap: () async {
                                                  Firestore.instance
                                                      .collection('bookrecords')
                                                      .document(rec.id)
                                                      .updateData({
                                                    'transit': true,
                                                    'transitId': currentUser.id,
                                                    'users': [
                                                      rec.ownerId,
                                                      rec.holderId,
                                                      currentUser.id
                                                    ]
                                                  });
                                                },
                                                child: Row(children: <Widget>[
                                                  bookImage(rec.book, 50),
                                                  Expanded(
                                                      child: Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 10.0),
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                    '${rec.book.authors[0]}',
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .body1),
                                                                Text(
                                                                    '\"${rec.book.title}\"',
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .body1)
                                                              ])))
                                                ]))),
                                        Positioned.fill(
                                            child: Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: GestureDetector(
                                                    onTap: () {
                                                      Firestore.instance
                                                          .collection(
                                                              'bookrecords')
                                                          .document(rec.id)
                                                          .updateData({
                                                        'transit': false,
                                                        'transitId': null,
                                                        'users': [
                                                          rec.ownerId,
                                                          rec.holderId
                                                        ]
                                                      });
                                                    },
                                                    child: Container(
                                                        margin:
                                                            EdgeInsets.all(5.0),
                                                        child: ClipOval(
                                                          child: Container(
                                                            color: Colors.red,
                                                            height:
                                                                30.0, // height of the button
                                                            width:
                                                                30.0, // width of the button
                                                            child: Center(
                                                                child: new Icon(
                                                                    MyIcons
                                                                        .cancel_cross,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 20)),
                                                          ),
                                                        )))))
                                      ]);
                                    });
                              }).toList(),
                            );
                        }
                      })))
        ],
      ),
    );
  }
}
