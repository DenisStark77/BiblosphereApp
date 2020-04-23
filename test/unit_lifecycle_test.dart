import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:mockito/mockito.dart';
import 'package:biblosphere/const.dart';
import 'package:biblosphere/lifecycle.dart';
import 'package:geolocator/geolocator.dart';

// TODO: Add bookrecord, Delete bookrecord, Handover books,

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

main() {
  db = MockFirestoreInstance();
  analytics = MockFirebaseAnalytics();
  //when(analytics.logEvent(name: anyNamed('name'), parameters: anyNamed('parameters'))).thenAnswer((_) async {return;});

  test("Handover function: give book A to B", () async {
    // Create User A
    User userA = new User(
      name: 'User A',
      photo: 'http://image.com/userA.jpg',
    );
    userA.ref.setData(userA.toJson());
    // Balance should be set in wallet

    // Create User B
    User userB = new User(
      name: 'User B',
      photo: 'http://image.com/userB.jpg',
    );
    userB.ref.setData(userB.toJson());

    B.user = userB;
    B.locality = 'Bakuriani';
    B.country = 'GE';
    B.position = Position(latitude: 41.7510, longitude: 43.5292); 

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
    );

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      isbn: book.isbn,
      ownerId: userA.id,
      holderId: userA.id,
      wish: false,
      lent: false,
    );
    record.ref.setData(record.toJson());

    // Run deposit function
    await handover(record, userB);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref.get()).data);
    User resultA = User.fromJson((await userA.ref.get()).data);
    User resultB = User.fromJson((await userB.ref.get()).data);

    expect(resultRec.transit, false);
    expect(resultRec.lent, true);
    expect(resultA.id, userA.id);
    expect(resultB.id, userB.id);
    expect(resultA.balance, 1);
    expect(resultB.balance, -1);
    expect(resultRec.ownerId, userA.id);
    expect(resultRec.holderId, userB.id);
    expect(resultRec.users, {userA.id, userB.id});
  });

  test("Handover function: return book B to A", () async {
    // Create User A
    User userA = new User(
      name: 'User A',
      photo: 'http://image.com/userA.jpg',
    );
    userA.ref.setData(userA.toJson());

    B.user = userA;
    B.locality = 'Bakuriani';
    B.country = 'GE';
    B.position = Position(latitude: 41.7510, longitude: 43.5292); 

    // Create User B
    User userB = new User(
      name: 'User B',
      photo: 'http://image.com/userB.jpg',
    );
    userB.ref.setData(userB.toJson());

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
    );

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      isbn: book.isbn,
      ownerId: userA.id,
      holderId: userA.id,
      wish: false,
      lent: false,
    );
    record.ref.setData(record.toJson());

    // Handover book
    await handover(record, userB);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref.get()).data);
    User resultA = User.fromJson((await userA.ref.get()).data);
    User resultB = User.fromJson((await userB.ref.get()).data);

    expect(resultRec.transit, false);
    expect(resultRec.lent, true);
    expect(resultA.id, userA.id);
    expect(resultB.id, userB.id);
    expect(resultA.balance, 1);
    expect(resultB.balance, -1);
    expect(resultRec.ownerId, userA.id);
    expect(resultRec.holderId, userB.id);
    expect(resultRec.users, {userA.id, userB.id});

    // Return book
    await handover(resultRec, userA);

    Bookrecord resultRec1 = Bookrecord.fromJson((await record.ref.get()).data);
    User resultA1 = User.fromJson((await userA.ref.get()).data);
    User resultB1 = User.fromJson((await userB.ref.get()).data);

    expect(resultRec1.transit, false);
    expect(resultRec1.lent, false);
    expect(resultA1.id, userA.id);
    expect(resultB1.id, userB.id);
    expect(resultA1.balance, 0);
    expect(resultB1.balance, 0);
    expect(resultRec1.ownerId, userA.id);
    expect(resultRec1.holderId, userA.id);
    expect(resultRec1.users, {userA.id});
  });

  test("Handover function: pass book A to B, then to C", () async {
    // Create User A
    User userA = new User(
      name: 'User A',
      photo: 'http://image.com/userA.jpg',
    );
    userA.ref.setData(userA.toJson());

    // Create User B
    User userB = new User(
      name: 'User B',
      photo: 'http://image.com/userB.jpg',
    );
    userB.ref.setData(userB.toJson());

    // Create User C
    User userC = new User(
      name: 'User C',
      photo: 'http://image.com/userC.jpg',
    );
    userC.ref.setData(userC.toJson());

    B.user = userB;
    B.locality = 'Bakuriani';
    B.country = 'GE';
    B.position = Position(latitude: 41.7510, longitude: 43.5292);

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
    );

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      isbn: book.isbn,
      ownerId: userA.id,
      holderId: userA.id,
      wish: false,
      lent: true,
    );
    record.ref.setData(record.toJson());

    // Handover book
    await handover(record, userB);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref.get()).data);
    User resultA = User.fromJson((await userA.ref.get()).data);
    User resultB = User.fromJson((await userB.ref.get()).data);
    User resultC = User.fromJson((await userC.ref.get()).data);

    expect(resultRec.transit, false);
    expect(resultRec.lent, true);
    expect(resultRec.ownerId, userA.id);
    expect(resultRec.holderId, userB.id);
    expect(resultRec.users, {userA.id, userB.id});
    expect(resultA.id, userA.id);
    expect(resultB.id, userB.id);
    expect(resultC.id, userC.id);
    expect(resultA.balance, 1);
    expect(resultB.balance, -1);
    expect(resultC.balance, 0);


    B.user = userC;
    B.locality = 'Bakuriani';
    B.country = 'GE';
    B.position = Position(latitude: 41.7510, longitude: 43.5292);

    // Run complete function
    await handover(resultRec, userC);

    Bookrecord resultRec1 = Bookrecord.fromJson((await record.ref.get()).data);
    User resultA1 = User.fromJson((await userA.ref.get()).data);
    User resultB1 = User.fromJson((await userB.ref.get()).data);
    User resultC1 = User.fromJson((await userC.ref.get()).data);

    expect(resultRec1.transit, false);
    expect(resultRec1.lent, true);
    expect(resultRec1.ownerId, userA.id);
    expect(resultRec1.holderId, userC.id);
    expect(resultRec1.users, {userA.id, userC.id});
    expect(resultA1.id, userA.id);
    expect(resultB1.id, userB.id);
    expect(resultC1.id, userC.id);
    expect(resultA1.balance, 1);
    expect(resultB1.balance, 0);
    expect(resultC1.balance, -1);
  });
}
