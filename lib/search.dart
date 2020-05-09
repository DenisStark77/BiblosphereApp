import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biblosphere/const.dart';

// TODO: Result of searchByTitleAuthor has to be updated from Firestore
//  for the books which available in Biblosphere
Future<List<Book>> searchByTitleAuthor(String text) async {
  //TODO: Redesign search as now it only use ONE keyword
  // and doing rest of filtering on client side
  // Search in catalogue in MySQL
  FirebaseUser user = await FirebaseAuth.instance.currentUser();
  IdTokenResult jwt = await user.getIdToken();

  // Call Python service to recognize
  Response res = await LibConnect.getCloudFunctionClient().get(
      'https://biblosphere-api-ihj6i2l2aq-uc.a.run.app/search?q=$text',
      headers: {HttpHeaders.authorizationHeader: "Bearer ${jwt.token}"});

  if (res.statusCode != 200) {
    return null;
  } else {
    //print('!!!DEBUG: Response ${res.body}');

    final resJson = json.decode(res.body);
    //print('!!!DEBUG: Response JSON \n${resJson}');

    // TODO: Add language and genre once available in MySQL
    List<Book> books = List<Book>.from(resJson.map((dynamic obj) => Book(
        title: obj['title'],
        authors: obj['authors'].split(';'),
        isbn: obj['isbn'],
        image: obj['image'])));
    return books;
  }
}

Future<Book> searchByIsbn(String isbn) async {
  try {
    //print('!!!DEBUG search ISBN: ${isbn}');

    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    IdTokenResult jwt = await user.getIdToken();

    // Call Python service to recognize
    Response res = await LibConnect.getCloudFunctionClient().get(
        'https://biblosphere-api-ihj6i2l2aq-uc.a.run.app/get?isbn=$isbn',
        headers: {HttpHeaders.authorizationHeader: "Bearer ${jwt.token}"});

    //print('!!!DEBUG: Response ${res.body}');

    if (res.statusCode != 200) {
      return null;
    } else {
      final resJson = json.decode(res.body);
      //print('!!!DEBUG: Response JSON \n${resJson}');

      // TODO: Debug mapping from MySQL JSON to Books
      List<Book> books = List<Book>.from(resJson.map((obj) {
        //print('!!!DEBUG: Book object $obj');
        return new Book(
            title: obj['title'],
            authors: obj['authors'].split(','),
            isbn: obj['isbn'],
            image: obj['image']);
      }));

      if (books != null && books.length > 0) {
        //print('!!!DEBUG book found by ISBN: ${books[0].title}');
        return books[0];
      } else {
        //print('!!!DEBUG book NOT found by ISBN: ${isbn}');
        return null;
      }
    }
  } catch (e, stack) {
    Crashlytics.instance.recordError(e, stack);

    print('Unknown error in searchByIsbn: $e $stack');
    return null;
  }
}
