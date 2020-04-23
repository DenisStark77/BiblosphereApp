import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:biblosphere/const.dart';

main() {
  db = MockFirestoreInstance();

  test("B singleton: Set and get", () async {
    B.country = 'RU';
    expect(B.country, 'RU');
  });

  test("getKeys function: build keys from string", () async {
    expect(getKeys(' ').toList(), []);
    expect(getKeys('').toList(), []);
    expect(getKeys('title author').toList(), {'title', 'author'});
    expect(getKeys('title author to').toList(), {'title', 'author'});
    expect(getKeys('Title Author').toList(), {'title', 'author'});
  });

  test("User class: toJson and fromJson", () async {
    User user = new User(
      name: 'Denis Stark',
      photo: 'http:\\image.com\123.jpg',
      link: 'Referral link',
      beneficiary1: 'Beneficiary1',
      beneficiary2: 'Beneficiary2',
      position: new GeoPoint(20, 20),
      wishCount: 1,
      bookCount: 2,
      shelfCount: 3,
    );

    user.ref.setData(user.toJson());
    DocumentSnapshot snap = await user.ref.get();
    User result = User.fromJson(snap.data);

    expect(result.name, 'Denis Stark');
    expect(result.photo, 'http:\\image.com\123.jpg');
    expect(result.link, 'Referral link');
    expect(result.beneficiary1, 'Beneficiary1');
    expect(result.beneficiary2, 'Beneficiary2');
    expect(result.position, GeoPoint(20, 20));
    expect(result.wishCount, 1);
    expect(result.bookCount, 2);
    expect(result.shelfCount, 3);
  });

  test("Book class: toJson and fromJson", () async {
    Book book = new Book(
      title: 'Title',
      authors: ['Author1 Author2', 'Author3 Author4'],
      isbn: '9785362836278',
      image: 'http:\\image.com\1.jpg',
      userImage: false,
      sourceId: 'google',
      source: BookSource.google,
      genre: 'fantasy',
      language: 'ru',
    );

    Book result = Book.fromJson(book.toJson());

    expect(result.title, 'Title');
    expect(result.authors, ['Author1 Author2', 'Author3 Author4']);
    expect(result.isbn, '9785362836278');
    expect(result.image, 'http:\\image.com\1.jpg');
    expect(result.userImage, false);
    expect(result.sourceId, 'google');
    expect(result.source, BookSource.google);
    expect(result.genre, 'fantasy');
    expect(result.language, 'ru');
    expect(result.keys,
        {'9785362836278', 'author1', 'author2', 'author3', 'author4', 'title'});
  });

  test("Bookrecord class: toJson and fromJson", () async {
    Bookrecord record = new Bookrecord(
      isbn: '9785362836278',
      ownerId: 'ownerId',
      holderId: 'holderId',
      wish: false,
      lent: false,
      matched: false,
      matchedId: 'matchedId',
      location: new GeoFirePoint(30, 20),
      title: 'Title',
      authors: ['Author1 Author2', 'Author3 Author4'],
      image: 'http:\\image.com\1.jpg',
    );

    record.ref.setData(record.toJson());
    DocumentSnapshot snap = await record.ref.get();
    Bookrecord result = Bookrecord.fromJson(snap.data);

    expect(result.isbn, '9785362836278');
    expect(result.ownerId, 'ownerId');
    expect(result.holderId, 'holderId');
    expect(result.transit, false);
    expect(result.confirmed, false);
    expect(result.wish, false);
    expect(result.lent, false);
    expect(result.matched, false);
    expect(result.matchedId, 'matchedId');
    expect(result.location,
        (GeoFirePoint point) => point.latitude == 30 && point.longitude == 20);
    expect(result.users, {'ownerId', 'holderId'});
    expect(result.title, 'Title');
    expect(result.authors, ['Author1 Author2', 'Author3 Author4']);
    expect(result.image, 'http:\\image.com\1.jpg');
    expect(result.keys,
        {'9785362836278', 'author1', 'author2', 'author3', 'author4', 'title'});
  });

  test("Bookrecord class: toJson and fromJson with null location", () async {
    Bookrecord record = new Bookrecord(
      isbn: 'isbn',
      ownerId: 'ownerId',
      holderId: 'holderId',
      wish: false,
      lent: false,
      matched: false,
      matchedId: 'matchedId',
    );

    record.ref.setData(record.toJson());
    DocumentSnapshot snap = await record.ref.get();
    Bookrecord result = Bookrecord.fromJson(snap.data);

    expect(result.isbn, 'isbn');
    expect(result.ownerId, 'ownerId');
    expect(result.holderId, 'holderId');
    expect(result.transit, false);
    expect(result.wish, false);
    expect(result.lent, false);
    expect(result.matched, false);
    expect(result.matchedId, 'matchedId');
    expect(result.location, null);
    expect(result.users, {'ownerId', 'holderId'});
  });

  test("Bookrecord class: wish", () async {
    Bookrecord record = new Bookrecord(
      isbn: 'isbn',
      ownerId: 'User A',
      holderId: 'User A',
      wish: true,
      lent: false,
    );

    // Test for current User A
    B.user = User(id: 'User A', name: 'User A', photo: 'PhotoA');
    expect(record.isWish, true);
    expect(record.isBorrowed, false);
    expect(record.isLent, false);
    expect(record.type, BookrecordType.wish);

    // Test for current User B
    B.user = User(id: 'User B', name: 'User B', photo: 'PhotoB');
    expect(record.isWish, false);
    expect(record.isBorrowed, false);
    expect(record.isLent, false);
    expect(record.type, BookrecordType.none);
  });

  test("Bookrecord class: lent/borrowed", () async {
    Bookrecord record = new Bookrecord(
      isbn: 'isbn',
      ownerId: 'User A',
      holderId: 'User B',
      wish: false,
      lent: true,
    );

    // Test for current User A
    B.user = User(id: 'User A', name: 'User A', photo: 'PhotoA');
    expect(record.isWish, false);
    expect(record.isBorrowed, false);
    expect(record.isLent, true);
    expect(record.type, BookrecordType.lent);

    // Test for current User B
    B.user = User(id: 'User B', name: 'User B', photo: 'PhotoB');
    expect(record.isWish, false);
    expect(record.isBorrowed, true);
    expect(record.isLent, false);
    expect(record.type, BookrecordType.borrowed);

    // Test for current User B
    B.user = User(id: 'User C', name: 'User C', photo: 'PhotoC');
    expect(record.isWish, false);
    expect(record.isBorrowed, false);
    expect(record.isLent, false);
    expect(record.type, BookrecordType.none);
  });

  test("Bookrecord class: third person", () async {
    Bookrecord record = new Bookrecord(
      isbn: 'isbn',
      ownerId: 'User A',
      holderId: 'User B',
      wish: false,
      lent: true,
    );

    // Test for current User A
    B.user = User(id: 'User A', name: 'User A', photo: 'PhotoA');
    expect(record.isWish, false);
    expect(record.isBorrowed, false);
    expect(record.isLent, true);
    expect(record.type, BookrecordType.lent);

    // Test for current User B
    B.user = User(id: 'User B', name: 'User B', photo: 'PhotoB');
    expect(record.isWish, false);
    expect(record.isBorrowed, true);
    expect(record.isLent, false);
    expect(record.type, BookrecordType.borrowed);

    // Test for current User C
    B.user = User(id: 'User C', name: 'User C', photo: 'PhotoC');
    expect(record.isWish, false);
    expect(record.isBorrowed, false);
    expect(record.isLent, false);
    expect(record.type, BookrecordType.none);
  });
}
