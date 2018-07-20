import 'package:flutter/material.dart';

class BookshelfCard extends StatelessWidget
{
  String imageURL;

  BookshelfCard(String image){
    imageURL = image;
  }

  @override
  Widget build(BuildContext context) {
    return new Stack (
      children: <Widget>[
        new Image.network(imageURL, fit: BoxFit.cover),
        new Align(
          alignment: Alignment(1.0, 1.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new IconButton(
                onPressed: () {},
                tooltip: 'Increment',
                icon: new Icon(Icons.location_on),
              ),
              new IconButton(
                onPressed: () {},
                tooltip: 'Increment',
                icon: new Icon(Icons.message),
              ),
            ],
          ),
        ),
      ],
    );
  }
}