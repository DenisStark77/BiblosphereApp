import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis/books/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:xml/xml.dart' as xml;
import 'dart:convert';
import 'package:biblosphere/const.dart';

//TODO: Not sure it's good idea to have it as global valiables. Need to find
// better way. Hwever to have it in widget is not good idea either as it used
// from Goodreads import as well.
//TODO: Where to close such clients
class LibConnect {
  static Client _googleClient;
  static BooksApi _booksApi;
  static String goodreadsApiKey = 'SXMWtbHvcnbTgRTLT7isA';
  static Client _goodreadsClient;
  static Client _commonClient;

  static Client getClient() {
    if (_commonClient == null) _commonClient = new Client();
    return _commonClient;
  }

  static Client getGoodreadClient() {
    if (_goodreadsClient == null) _goodreadsClient = new Client();
    return _goodreadsClient;
  }

  static BooksApi getGoogleBookApi() {
    if (_googleClient == null)
      _googleClient =
          clientViaApiKey('AIzaSyDJR_BnU_JVJyGTfaWcj086UuQxXP3LoTU');

    if (_booksApi == null) _booksApi = new BooksApi(_googleClient);

    return _booksApi;
  }
}

Future<List<Book>> searchByTitleAuthorBiblosphere(String text) async {
  //TODO: Redesign search as now it only use ONE keyword
  // and doing rest of filtering on client side
  Set<String> keys = getKeys(text);
  QuerySnapshot snapshot;

  if (keys.length == 0)
    return [];
  else
    snapshot = await Firestore.instance
        .collection('books')
        .where('keys', arrayContains: keys.elementAt(0))
        .getDocuments();

  List<Book> books = snapshot.documents.where((doc) {
    return doc.data['keys'].toSet().containsAll(keys);
  }).map((doc) {
    Book book = new Book.fromJson(doc.data);
    return book;
  }).toList();

  return books;
}

Future<List<Book>> searchByTitleAuthorGoogle(String text) async {
  Volumes books = await LibConnect.getGoogleBookApi()
      .volumes
      .list(text, printType: 'books', maxResults: 20);

  if (books.items != null && books.items.isNotEmpty) {
    return books.items
        .where((v) =>
    v.volumeInfo.title != null &&
        v.volumeInfo.authors != null &&
        v.volumeInfo.authors.isNotEmpty &&
        v.volumeInfo.imageLinks != null &&
        v.volumeInfo.imageLinks.thumbnail != null &&
        v.volumeInfo.industryIdentifiers != null &&
        v.saleInfo != null &&
        !v.saleInfo.isEbook)
        .map((v) {
      return new Book.volume(v);
    }).toList();
  } else {
    return null;
  }
}

Future<List<Book>> searchByTitleAuthorGoodreads(String text) async {
  //TODO: avoid calls using ApiKey as it is not protected from others calling
  var res = await LibConnect.getGoodreadClient().get(
      'https://www.goodreads.com/search/index.xml?key=${LibConnect.goodreadsApiKey}&q=$text');

  var document = xml.parse(res.body);

  List<Book> books =
  document.findAllElements('best_book')?.take(5)?.map((xml.XmlElement e) {
    return new Book.goodreads(e);
    //As Goodreads doesn't have ISBN in search responce keep Goodreads ID instead.
    // It'll be replaced by ISBN by enrichBookRecord function on confirm stage.
  })?.toList();

  return books;
}

Future<Book> enrichBookRecord(Book book) async {
  //As Goodreads search by title/author does not return ISBN it's empty for
  // these records
  try {
    if (book.isbn == null || book.isbn.isEmpty || book.isbn == 'NA') {
      if (book.sourceId != null && book.sourceId.isNotEmpty) {
        var res = await LibConnect.getGoodreadClient().get(
            'https://www.goodreads.com/book/show/${book.sourceId}.xml?key=${LibConnect.goodreadsApiKey}');

        var document = xml.parse(res.body);
        String isbn =
        document.findAllElements('isbn13')?.first?.text?.toString();

        if (isbn != null) book.isbn = isbn;
      }
      if (book.isbn == null || book.isbn.isEmpty) book.isbn = 'NA';
    }

    //As many Goodreads books doesn't have images enrich it from Google
    if (book.image == null || book.image.isEmpty) {
      if (book.isbn != 'NA' && book.source != BookSource.google) {
        Book b = await searchByIsbnGoogle(book.isbn);
        if (b?.image != null) book.image = b.image;
        if (b?.language != null) book.language = b.language;
      }
    }

    return book;
  } catch (e) {
    print('Unknown error in enrichBookRecord: $e');
    return book;
  }
}

Future<Book> searchByIsbnGoogle(String isbn) async {
  try {
    Volumes books =
    await LibConnect.getGoogleBookApi().volumes.list('isbn:$isbn');
    if (books?.items != null && books.items.isNotEmpty) {
      var v = books?.items[0];
      if (v?.volumeInfo?.title != null &&
          v?.volumeInfo?.authors != null &&
          v.volumeInfo.authors.isNotEmpty &&
          v?.volumeInfo?.imageLinks != null &&
          v?.volumeInfo?.imageLinks?.thumbnail != null &&
          v?.volumeInfo?.industryIdentifiers != null &&
          v?.saleInfo != null &&
          !v.saleInfo.isEbook) {
        return new Book.volume(v)..isbn = isbn;
      }
    }
    return null;
  } catch (e) {
    print('Unknown error in searchByIsbnGoogle: $e');
    return null;
  }
}

Future<Book> searchByIsbnGoodreads(String isbn) async {
  try {
    var res = await LibConnect.getGoodreadClient().get(
        'https://www.goodreads.com/search/index.xml?key=${LibConnect.goodreadsApiKey}&q=$isbn');

    var document = xml.parse(res.body);

    var bookXml = document?.findAllElements('best_book')?.first;
    if (bookXml != null) {
      return new Book.goodreads(bookXml)..isbn = isbn;
    }
    return null;
  } catch (e) {
    print('Unknown error in searchByIsbnGoodreads: $e');
    return null;
  }
}

Future<Book> searchByIsbnRsl(String isbn) async {
  // Two requests neede. One to get CSRF cookie and second one to make a query.
  // Undocumented API reverse-engineered from search.rsl.ru/ru/search
  try {
    var headers = {
      'Upgrade-Insecure-Requests': '1',
    };

    String uri = 'https://search.rsl.ru/ru/search';
    var res = await LibConnect.getClient().get(uri, headers: headers);

    String cookie = res.headers['set-cookie'];
    RegExp exp1 = new RegExp(r"(.*?)=(.*?)(?:$|,(?!\s))");
    RegExp exp2 = new RegExp(r"(.*?)=(.*?)(?:$|;|,)");
    Iterable<Match> matches = exp1.allMatches(cookie);

    List<String> cleanCookie = [];
    for (var i = 0; i < matches.length; i++) {
      String c = cookie.substring(
          matches.elementAt(i).start, matches.elementAt(i).end);
      Match match2 = exp2.firstMatch(c);
      cleanCookie.add(c.substring(match2.start, match2.end - 1));
    }

    int tag, start, end;
    String token;

    tag = res.body.indexOf('csrf-token');
    if (tag != -1) {
      start = res.body.indexOf('"', tag + 11) + 1;
      end = res.body.indexOf('"', start);
      token = res.body.substring(start, end);
    }

    uri = 'https://search.rsl.ru/site/ajax-search';
    headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json, text/javascript, */*; q=0.01',
//                     'X-CSRF-Token': token,
      'Origin': 'https://search.rsl.ru',
      'User-Agent':
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.108 Safari/537.36',
      'Accept-Language':
      'en-GB,en;q=0.9,ru-RU;q=0.8,ru;q=0.7,ka-GE;q=0.6,ka;q=0.5,en-US;q=0.4',
      'Accept-Encoding': 'gzip, deflate, br',
      'Cookie': cleanCookie.join(';') + ';'
    };

    String body =
        'SearchFilterForm[search]=isbn:$isbn&_csrf=${Uri.encodeQueryComponent(token)}';

    //Use Request to control Content-Type header. Client.post add charset to it
    // which does not work with RSL
    Request request = new Request('POST', Uri.parse(uri));
    request.body = body;
    request.headers.clear();
    request.headers.addAll(headers);

    StreamedResponse strRes = await LibConnect.getClient().send(request);
    String resBody = await strRes.stream.bytesToString();

    var jsonRes = json.decode(resBody);

    String resStr = jsonRes['content'];

    String author, title;

    tag = resStr.indexOf('js-item-authorinfo');
    if (tag != -1) {
      start = resStr.indexOf('>', tag) + 1;
      end = resStr.indexOf('<', start);
      author = resStr.substring(start, end);
    }

    tag = resStr.indexOf('js-item-maininfo');
    if (tag != -1) {
      start = resStr.indexOf('>', tag) + 1;
      end = resStr.indexOf('[', start);
      title = resStr.substring(start, end);
    }

    if (title != null || author != null) {
      return new Book(title: title, authors: [author], isbn: isbn);
    }
    return null;
  } catch (e) {
    print('Unknown error in searchByIsbnRsi: $e');
    return null;
  }
}


Future<Book> searchByIsbn(String isbn) async {
  try {
    QuerySnapshot q = await Firestore.instance
        .collection('books')
        .where('isbn', isEqualTo: isbn)
        .getDocuments();

    if (q.documents.isEmpty) {
      //No books found
      return null;
    } else {
      Book b = new Book.fromJson(q.documents.first.data);
      b.id = q.documents.first.documentID;
      return b;
    }
  } catch (e) {
    print('Unknown error in searchByIsbn: $e');
    return null;
  }
}
