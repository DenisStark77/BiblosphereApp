import 'dart:ui';
import 'package:flutter/material.dart';

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
          child: Row(
              children: <Widget>[
                Material(
                  child: Image.asset('images/Librarian50x50.jpg', width: 50.0,),
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