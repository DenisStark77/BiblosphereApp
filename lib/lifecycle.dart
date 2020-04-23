import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter_crashlytics/flutter_crashlytics.dart';

import 'package:biblosphere/const.dart';
import 'package:biblosphere/helpers.dart';
import 'package:biblosphere/l10n.dart';

//Callback function type definition
typedef BookCallback(Book book);

Future addBookrecord(
    BuildContext context, Book b, User u, bool wish, GeoFirePoint location,
    {String source = 'goodreads', bool snackbar = true}) async {
  if (b.isbn == null || b.isbn == 'NA')
    throw 'Book ${b?.title}, ${b?.authors?.join()} has no ISBN';

  // create book record from book and user
  Bookrecord bookrecord = new Bookrecord(
      ownerId: u.id,
      isbn: b.isbn,
      authors: b.authors,
      title: b.title,
      image: b.image,
      ownerName: u.name,
      ownerImage: u.photo,
      wish: wish,
      location: location);

  // Get bookrecord with predefined id
  DocumentSnapshot recSnap = await bookrecord.ref.get();

  if (recSnap.exists) {
    // Show snackbar (already exist), Add data from book, Write bookrecord
    if (snackbar)
      showSnackBar(
          context,
          wish
              ? S.of(context).wishAlreadyThere
              : S.of(context).bookAlreadyThere);
  } else {
    // Add bookrecord to firestore
    await bookrecord.ref.setData(bookrecord.toJson());

    // Show snackbar that book added
    if (snackbar)
      showSnackBar(
          context, wish ? S.of(context).wishAdded : S.of(context).bookAdded);

    // If wish - increment user wish count
    if (wish) {
      u.ref.updateData({'wishCount': FieldValue.increment(1)});
    }

    // TODO: Run background process in MySQL to enrich book records
    //  and populate it to Firestore bookrecords

    logAnalyticsEvent(
        name: wish ? 'add_to_wishlist' : 'book_add',
        parameters: <String, dynamic>{
          'language': b.language ?? '',
          'isbn': b.isbn,
        });
  }
}

Future<void> handover(Bookrecord rec, User to) async {
  await db.runTransaction((tx) async {
    tx.update(rec.ref, {
      'holderId': to.id,
      'holderName': to.name,
      'holderImage': to.photo,
      'users': [to.id, rec.ownerId],
      'lent': rec.ownerId != to.id
    });

    // Hold an allowance of the receiver of the book
    tx.update(to.ref, {
      'balance': FieldValue.increment(-1)
    });

    // Increase an allowance of the giver of the book
    tx.update(User.Ref(rec.holderId), {
      'balance': FieldValue.increment(1)
    });
  });

  logAnalyticsEvent(
      name: 'book_received',
      parameters: <String, dynamic>{
        'user': B.user.id,
        'isbn': rec.isbn,
      });
}
