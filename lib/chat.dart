import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
//import 'package:flutter_crashlytics/flutter_crashlytics.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';

import 'package:biblosphere/l10n.dart';
import 'package:biblosphere/const.dart';
import 'package:biblosphere/helpers.dart';
import 'package:biblosphere/books.dart';
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .body1
                                      .apply(color: Colors.grey[400]))
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
  static runChatWithBookRequest(BuildContext context, Bookrecord record,
      {message = null}) async {
    // Book only can be requested from other user
    assert(record != null && record.holderId != B.user.id);

    // If book belong to current user do nothing
    if (record.holderId == B.user.id) return null;

    // Chat record has to be enriched with user info
    assert(record.holder != null);

    Messages chat = Messages(from: record.holder, to: B.user);

    // Get chat by Id
    DocumentSnapshot chatSnap = await chat.ref.get();

    // Create chat if not found and refresh data if found
    if (!chatSnap.exists) {
      await chat.ref.setData(chat.toJson());
    } else {
      chat = new Messages.fromJson(chatSnap.data, chatSnap);
    }

    // Get user information about counterparty
    String partnerId = chat.partnerId;
    DocumentSnapshot snap = await User.Ref(partnerId).get();
    if (!snap.exists)
      throw "Partner user [${partnerId}] does not exist for chat [${chat.id}]";
    User partner = User.fromJson(snap.data);

    if (message == null) message = S.of(context).requestBook(record.title);

    pushSingle(
        context,
        new MaterialPageRoute(
            builder: (context) => new Chat(
                partner: partner,
                chat: chat,
                message: message,
                attachment: record,
                send: false)),
        'chat');

    // Log book request ad return events
    logAnalyticsEvent(name: 'book_requested', parameters: <String, dynamic>{
      'isbn': record.isbn,
      'type': (B.user.id == record.ownerId) ? 'return' : 'request',
      'from': chat.partnerId,
      'to': B.user.id,
      'distance':
          record.distance == double.infinity ? 50000.0 : record.distance,
    });
  }

  static runChatById(BuildContext context, User partner,
      {String chatId, String message, bool send = false}) async {
    DocumentSnapshot chatSnap = await Messages.Ref(partner.id, B.user.id).get();
    if (!chatSnap.exists) throw 'Chat does not exist: ${chatId}';

    Messages chat = new Messages.fromJson(chatSnap.data, chatSnap);

    if (!chat.system && partner == null) {
      String partnerId = chat.partnerId;
      DocumentSnapshot snap = await User.Ref(partnerId).get();
      if (!snap.exists)
        throw "Partner user [${partnerId}] does not exist for chat [${chat.id}]";
      partner = User.fromJson(snap.data);
    }

    pushSingle(
        context,
        new MaterialPageRoute(
            builder: (context) => new Chat(
                partner: partner, chat: chat, message: message, send: send)),
        'chat');
  }

  static runChat(BuildContext context, User partner,
      {Messages chat, String message, bool send = false}) async {
    if (!chat.system && partner == null)
      partner = User(
          id: chat.partnerId, name: chat.partnerName, photo: chat.partnerImage);

    pushSingle(
        context,
        new MaterialPageRoute(
            builder: (context) => new Chat(
                partner: partner, chat: chat, message: message, send: send)),
        'chat');
  }

  Chat(
      {Key key,
      @required this.partner,
      this.message,
      this.attachment,
      this.chat,
      this.send})
      : super(key: key);

  final Messages chat;
  final User partner;
  // Message to be sent
  final String message;
  // Attachment (bookrecord id) to be sent
  final dynamic attachment;
  final bool send;

  @override
  _ChatState createState() => new _ChatState(
      partner: partner,
      message: message,
      attachment: attachment,
      chat: chat,
      send: send);
}

class _ChatState extends State<Chat> {
  final User partner;
  final String message;
  // Attachment (bookrecord id) to be sent
  final dynamic attachment;
  bool send;
  Messages chat;

  // List of books in the agreement
  StreamSubscription<QuerySnapshot> streamBooks;
  List<Bookrecord> books = [];

  StreamSubscription<Messages> _listener;

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

    // Listem chat updates
    _listener = chat.snapshots().listen((chat) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    if (_listener != null) _listener.cancel();

    super.dispose();
  }

  _ChatState(
      {Key key,
      @required this.partner,
      this.message = '',
      this.attachment,
      this.chat,
      this.send});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: GestureDetector(
              onTap: () {},
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
                              chat.system
                                  ? S.of(context).titleSupport
                                  : partner.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .title
                                  .apply(color: C.titleText),
                            ))),
                  ])),
          centerTitle: false),
      body: ChatScreen(
          myId: B.user.id,
          partner: partner,
          message: message,
          attachment: attachment,
          send: send,
          chat: chat),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String myId;
  final User partner;
  final String message;
  final dynamic attachment;
  final bool send;
  final Messages chat;
  final VoidCallback onKeyboard;

  ChatScreen(
      {Key key,
      @required this.myId,
      @required this.partner,
      this.message = '',
      this.attachment,
      this.send,
      this.chat,
      this.onKeyboard})
      : super(key: key);

  @override
  State createState() => new ChatScreenState(
      myId: myId,
      partner: partner,
      message: message,
      attachment: attachment,
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
      this.attachment,
      this.send,
      this.chat,
      this.onKeyboard});

  User partner;
  String myId;
  String peerId;
  String message;
  dynamic attachment;
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

        // Wait till authorization before sending messages to Chat bot
        if (message != null && send) {
          print('!!!DEBUG: Sending message');
          onSendMessage(message, extra: attachment);
        }
      });
    } else {
      // Send message to chat automaticaly
      if (message != null && send) {
        print('!!!DEBUG: Sending message');
        onSendMessage(message, extra: attachment);
      }
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

  Widget attachmentImage() {
    if (attachment != null && attachment is Bookrecord) {
      return bookImage(attachment, 28.0, padding: EdgeInsets.all(3.0));
    } else {
      return Container();
    }
  }

  Future<void> onSendMessage(String content, {extra = null}) async {
    // type: 0 = text, 1 = image, 2 = sticker
    print('!!!DEBUG: sending message: ${content}\n${extra}');
    if (content.trim() != '') {
      textEditingController.clear();
      if (message != null) {
        setState(() {
          message = null;
          attachment = null;
        });
      }

      // Reset attachment
      if (attachment != null) {
        setState(() {
          attachment = null;
        });
      }

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

      Map<String, dynamic> data = {
        'idFrom': myId,
        'idTo': peerId,
        'timestamp': timestamp.toString(),
        'content': content,
        'type': 0,
      };

      if (extra != null && extra is Bookrecord) {
        data['attachment'] = extra.runtimeType.toString();
        data['image'] = extra.image;
        data['id'] = extra.id;

        print('!!!DEBUG: Bookrecord attachment added: ${data}');
      }

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(msgRef, data);
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
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          document['type'] == 0 && (! document.data.containsKey('attachment') || document['attachment'] == 'None')
              // No attachment
              ? Container(
                  child: Text(
                    document['content'],
                    style: TextStyle(color: C.chatMyText),
                  ),
                  padding: EdgeInsets.all(10.0),
                  constraints: BoxConstraints(
                    maxWidth: width,
                  ),
                  decoration: BoxDecoration(
                      color: C.chatMy,
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                      right: 10.0),
                )
              : document['type'] == 0 && (! document.data.containsKey('attachment') || document['attachment'] == 'Bookrecord')
                  // Bookrecord attachment
                  ? Container(
                      child: GestureDetector(
                          onTap: () async {
                            pushSingle(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => buildScaffold(
                                        context,
                                        null,
                                        new FindBookWidget(id: document['id']),
                                        appbar: false)),
                                'search');
                          },
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                bookImage(document['image'], 50.0,
                                    padding: EdgeInsets.all(10.0)),
                                Flexible(
                                    child: Container(
                                  child: Text(
                                    document['content'],
                                    style: TextStyle(color: C.chatMyText),
                                  ),
                                  alignment: Alignment.topLeft,
                                  padding:
                                      EdgeInsets.only(top: 10.0, right: 10.0, bottom: 10.0),
                                ))
                              ])),
                      constraints: BoxConstraints(
                        maxWidth: width,
                      ),
                      decoration: BoxDecoration(
                          color: C.chatMy,
                          borderRadius: BorderRadius.circular(8.0)),
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
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                document['type'] == 0 && (! document.data.containsKey('attachment') || document['attachment'] == 'None')
                // No attachment
                    ? Container(
                  child: Text(
                    document['content'],
                    style: TextStyle(color: C.chatMyText),
                  ),
                  padding: EdgeInsets.all(10.0),
                  constraints: BoxConstraints(
                    maxWidth: width,
                  ),
                  decoration: BoxDecoration(
                      color: C.chatHis,
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(left: 10.0,
                    //bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                    ),
                )
                    : document['type'] == 0 && (! document.data.containsKey('attachment') || document['attachment'] == 'Bookrecord')
                // Bookrecord attachment
                    ? Container(
                  child: GestureDetector(
                      onTap: () async {
                        pushSingle(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => buildScaffold(
                                    context,
                                    null,
                                    new FindBookWidget(id: document['id']),
                                    appbar: false)),
                            'search');
                      },
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Flexible(
                                child: Container(
                                  child: Text(
                                    document['content'],
                                    style: TextStyle(color: C.chatMyText),
                                  ),
                                  alignment: Alignment.topLeft,
                                  padding:
                                  EdgeInsets.only(top: 10.0, left: 10.0, bottom: 10.0),
                                )),
                            bookImage(document['image'], 50.0,
                                padding: EdgeInsets.all(10.0)),
                          ])),
                  constraints: BoxConstraints(
                    maxWidth: width,
                  ),
                  decoration: BoxDecoration(
                      color: C.chatMy,
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(
                      //bottom: isLastMessageRight(index) ? 20.0 : 10.0,
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
              mainAxisAlignment: MainAxisAlignment.start,
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
    child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[Row(
      crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          attachmentImage(),
          // Edit text
          Flexible(
            child: Container(
              margin: new EdgeInsets.only(left: 10.0, right: 1.0),
                child: Theme(
                  data: ThemeData(platform: TargetPlatform.android),
                  child: TextField(
                    style: TextStyle(color: primaryColor, fontSize: 16.0),
                    controller: textEditingController,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration.collapsed(
                      hintText: S.of(context).typeMsg,
                      hintStyle: TextStyle(color: greyColor),
                    ),
                    focusNode: focusNode,
                  )),
            ),
          ),

          // Button attachment/delete
          Material(
            child: new Container(
              margin: new EdgeInsets.only(left: 8.0, right: 0.0),
              child: new IconButton(
                icon: attachment == null
                    ? assetIcon(attach_90, size: 20, padding: 0.0)
                    : assetIcon(trash_100, size: 20, padding: 0.0),
                onPressed: () {
                  if (attachment != null)
                    setState(() {
                      attachment = null;
                    });
                  else
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => buildScaffold(
                                context,
                                S.of(context).chooseHoldedBookForChat,
                                new MyBooksWidget(
                                  user: partner,
                                  onSelected: (context, book) {
                                    print('!!!DEBUG: Attachment set');
                                    attachment = book;
                                    if (book.ownerId == B.user.id) {
                                      // Offer My book
                                      textEditingController.text =
                                          S.of(context).offerBook(book.title);
                                    } else {
                                      // Return counterparty's book
                                      textEditingController.text = S
                                          .of(context)
                                          .requestReturn(book.title);
                                    }
                                    if (mounted)
                                      setState(() {
                                        print('!!!DEBUG: setState executed');
                                      });
                                  },
                                ),
                                appbar: false)));
                },
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.only(right: 8.0, left: 0.0),
              child: new IconButton(
                icon: assetIcon(sent_100, size: 30, padding: 0.0),
                onPressed: () => onSendMessage(textEditingController.text,
                    extra: attachment),
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      )]),
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: 100.0,
        minHeight: 50.0
      ),
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

// Class to books (own, partner's and borrowed/lent)
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

  String filter = 'request'; // 'offer' 'return', 'remind', 'request'

  StreamSubscription<QuerySnapshot> bookSubscription;
  List<DocumentSnapshot> books = [];

  @override
  void initState() {
    super.initState();

    textController = new TextEditingController();

    books = [];
    bookSubscription = Firestore.instance
        .collection('bookrecords')
        .where("holderId", whereIn: [B.user.id, user.id])
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
        title: Text(
          S.of(context).chooseHoldedBookForChat,
          style: Theme.of(context).textTheme.title.apply(color: C.titleText),
        ),
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
                          //mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Expanded(
                                child: new Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 2.0,
                                    runSpacing: 0.0,
                                    children: <Widget>[
                                  ChoiceChip(
                                    //avatar: icon,
                                    label:
                                        Text(S.of(context).chipBooksToRequest),
                                    selected: filter == 'request',
                                    onSelected: (bool s) {
                                      setState(() {
                                        filter = s ? 'request' : null;
                                      });
                                    },
                                  ),
                                      ChoiceChip(
                                    //avatar: icon,
                                    label:
                                        Text(S.of(context).chipBooksToReturn),
                                    selected: filter == 'return',
                                    onSelected: (bool s) {
                                      setState(() {
                                        filter = s ? 'return' : null;
                                      });
                                    },
                                  ),
                                      ChoiceChip(
                                    //avatar: icon,
                                    label: Text(
                                        S.of(context).chipBooksToAskForReturn),
                                    selected: filter == 'remind',
                                    onSelected: (bool s) {
                                      setState(() {
                                        filter = s ? 'remind' : null;
                                      });
                                    },
                                  ),
                                      ChoiceChip(
                                    //avatar: icon,
                                    label: Text(S.of(context).chipBooksToOffer),
                                    selected: filter == 'offer',
                                    onSelected: (bool s) {
                                      setState(() {
                                        filter = s ? 'offer' : null;
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

          if (
              // Books with me which does not belong to the user
              filter == 'offer' && rec.holderId == B.user.id && rec.ownerId != user.id
                  // Books with the user which does not belong to me
                  ||
                  filter == 'request' &&
                      rec.holderId == user.id &&
                      rec.ownerId != B.user.id
                  // Books with me which belong to the user
                  ||
                  filter == 'return' &&
                      rec.holderId == B.user.id &&
                      rec.ownerId == user.id
                  // Books with the user which belong to me
                  ||
                  filter == 'remind' &&
                      rec.holderId == user.id &&
                      rec.ownerId == B.user.id) {
            return BookrecordWidget(
                bookrecord: rec,
                builder: (context, rec) {
                  // TODO: Add authors titles and onTap
                  return GestureDetector(
                      onTap: () async {
                        if (onSelected != null) onSelected(context, rec);
                        // Close window
                        Navigator.pop(context);
                      },
                      child: Row(children: <Widget>[
                        bookImage(rec, 50, padding: EdgeInsets.all(5.0)),
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

  @override
  void initState() {
    super.initState();

    textController = new TextEditingController();

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
