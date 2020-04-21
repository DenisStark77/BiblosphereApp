import 'package:flutter_crashlytics/flutter_crashlytics.dart';
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

    //print('!!!DEBUG: Response ${res.body}');

    final resJson = json.decode(res.body);
    //print('!!!DEBUG: Response JSON \n${resJson}');

    // TODO: Add language and genre once available in MySQL
    List<Book> books = List<Book>.from(resJson.map((dynamic obj) => Book(title: obj['title'], authors: obj['authors'].split(';'), isbn: obj['isbn'], image: obj['image'])));
    return books;
}


Future<Book> searchByIsbn(String isbn) async {
  try {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    IdTokenResult jwt = await user.getIdToken();

    // Call Python service to recognize
    Response res = await LibConnect.getCloudFunctionClient().get(
        'https://biblosphere-api-ihj6i2l2aq-uc.a.run.app/get?isbn=$isbn',
        headers: {HttpHeaders.authorizationHeader: "Bearer ${jwt.token}"});

    print('!!!DEBUG: Response ${res.body}');

    final resJson = json.decode(res.body);
    print('!!!DEBUG: Response JSON \n${res.body}');

    // TODO: Debug mapping from MySQL JSON to Books
    List<Book> books = resJson.map((Map<String, dynamic> obj) {
      print('!!!DEBUG: Book object $obj');
      return new Book(title: obj['title'], authors: obj['authors'], isbn: obj['isbn'], image: obj['image']);
    });
    return books[0];
  } catch (e, stack) {
    FlutterCrashlytics().logException(e, stack);

    print('Unknown error in searchByIsbn: $e');
    return null;
  }
}