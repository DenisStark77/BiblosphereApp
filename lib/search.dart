import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biblosphere/const.dart';


// Function to add books to the Biblosphere catalog
Future<void> addBookToCatalog(List<Bookrecord> books) async {
  FirebaseUser user = await FirebaseAuth.instance.currentUser();
  IdTokenResult idtoken = await user.getIdToken();

  String body = json.encode({
    'books': books.map((b) => b.toJson(bookOnly: true)).toList()
  });

  print('!!!DEBUG body: $body');

  // Call Python service to recognize
  Response res = await LibConnect.getCloudFunctionClient().post(
      'https://biblosphere-api-ihj6i2l2aq-uc.a.run.app/add',
          body: body,
          headers: {
            HttpHeaders.authorizationHeader: "Bearer ${idtoken.token}",
            HttpHeaders.contentTypeHeader: "application/json"
          }
      );

  if (res.statusCode != 200) {
    // TODO: Add report to crashalitic
    print('!!!DEBUG: Add book error ${res.body}');
    return;
  } else {
    print('!!!DEBUG: Books added to catalog ${res.body}');
    return;
  }
}


// Function to add books to the Biblosphere catalog
Future<List<String>> getTagList(String query) async {
  FirebaseUser user = await FirebaseAuth.instance.currentUser();
  IdTokenResult idtoken = await user.getIdToken();

  // Call Python service to return list of tags
  // TODO: check that cirilic works well without encoding URL 
  Response res = await LibConnect.getCloudFunctionClient().get(
      'https://biblosphere-api-ihj6i2l2aq-uc.a.run.app/get_tags?query=${query}',
          headers: {
            HttpHeaders.authorizationHeader: "Bearer ${idtoken.token}",
            HttpHeaders.contentTypeHeader: "application/json"
          }
      );

  if (res.statusCode != 200) {
    // TODO: Add report to crashalitic
    print('!!!DEBUG: Get tag list error ${res.body}');
    return [];
  } else {
    final resJson = json.decode(res.body);
    print('!!!DEBUG: Tag list returned ${resJson.length} elements');

    return List<String>.from(resJson);
  }
}


// Function to search in catalogue in MySQL
Future<List<Book>> searchByTitleAuthor(String text) async {
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
