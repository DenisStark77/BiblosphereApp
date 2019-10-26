import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biblosphere/mock_firestore.dart';
import 'package:biblosphere/const.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

main() {
  db = MockFirestore.instance;

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
      balance: 10.50,
      blocked: 2.0,
      accountId: 'Account',
      payoutId: 'Payout',
      secretSeed: 'Secret',
    );

    user.ref().setData(user.toJson());
    DocumentSnapshot snap = await user.ref().get();
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
    expect(result.balance, 0.0); // Do not store balance. Only direct updates!!!
    expect(result.blocked, 0.0); // Do not store blocked. Only direct updates!!!
    expect(result.accountId, 'Account');
    expect(result.payoutId, 'Payout');
    expect(result.secretSeed, 'Secret');
  });

  test("Book class: toJson and fromJson", () async {
    Book book = new Book(
      title: 'Title',
      authors: ['Author1 Author2', 'Author3 Author4'],
      isbn: '9785362836278',
      image: 'http:\\image.com\1.jpg',
      sourceId: 'google',
      source: BookSource.google,
      price: 10.0,
      listPrice: new Price(amount: 100.0, currency: 'USD'),
      genre: 'fantasy',
      language: 'ru',
    );

    book.ref().setData(book.toJson());
    DocumentSnapshot snap = await book.ref().get();
    Book result = Book.fromJson(snap.data);

    expect(result.title, 'Title');
    expect(result.authors, ['Author1 Author2', 'Author3 Author4']);
    expect(result.isbn, '9785362836278');
    expect(result.image, 'http:\\image.com\1.jpg');
    expect(result.sourceId, 'google');
    expect(result.source, BookSource.google);
    expect(result.price, 10.0);
    expect(result.listPrice,
        (price) => price.amount == 100.0 && price.currency == 'USD');
    expect(result.genre, 'fantasy');
    expect(result.language, 'ru');
    expect(result.keys,
        {'9785362836278', 'author1', 'author2', 'author3', 'author4', 'title'});
  });

  test("Bookrecord class: toJson and fromJson", () async {
    Bookrecord record = new Bookrecord(
      bookId: 'bookId',
      ownerId: 'ownerId',
      holderId: 'holderId',
      transitId: 'transitId',
      rewardId: 'rewardId',
      leasingId: 'leasingId',
      price: 100.50,
      transit: false,
      wish: false,
      lent: false,
      matched: false,
      matchedBookId: 'matchedBookId',
      location: new GeoFirePoint(30, 20),
    );

    record.ref().setData(record.toJson());
    DocumentSnapshot snap = await record.ref().get();
    Bookrecord result = Bookrecord.fromJson(snap.data);

    expect(result.bookId, 'bookId');
    expect(result.ownerId, 'ownerId');
    expect(result.holderId, 'holderId');
    expect(result.transitId, 'transitId');
    expect(result.rewardId, 'rewardId');
    expect(result.leasingId, 'leasingId');
    expect(result.price, 100.50);
    expect(result.transit, false);
    expect(result.wish, false);
    expect(result.lent, false);
    expect(result.matched, false);
    expect(result.matchedBookId, 'matchedBookId');
    expect(result.location,
        (GeoFirePoint point) => point.latitude == 30 && point.longitude == 20);
    expect(result.users, {'transitId', 'ownerId', 'holderId'});
  });

  test("Bookrecord class: toJson and fromJson with null location", () async {
    Bookrecord record = new Bookrecord(
      bookId: 'bookId',
      ownerId: 'ownerId',
      holderId: 'holderId',
      transitId: 'transitId',
      rewardId: 'rewardId',
      leasingId: 'leasingId',
      price: 100.50,
      transit: false,
      wish: false,
      lent: false,
      matched: false,
      matchedBookId: 'matchedBookId',
    );

    record.ref().setData(record.toJson());
    DocumentSnapshot snap = await record.ref().get();
    Bookrecord result = Bookrecord.fromJson(snap.data);

    expect(result.bookId, 'bookId');
    expect(result.ownerId, 'ownerId');
    expect(result.holderId, 'holderId');
    expect(result.transitId, 'transitId');
    expect(result.rewardId, 'rewardId');
    expect(result.leasingId, 'leasingId');
    expect(result.price, 100.50);
    expect(result.transit, false);
    expect(result.wish, false);
    expect(result.lent, false);
    expect(result.matched, false);
    expect(result.matchedBookId, 'matchedBookId');
    expect(result.location, null);
    expect(result.users, {'transitId', 'ownerId', 'holderId'});
  });


  test("Bookrecord class: wish", () async {
    Bookrecord record = new Bookrecord(
      bookId: 'Book',
      ownerId: 'User A',
      holderId: 'User A',
      transit: false,
      wish: true,
      lent: false,
    );

    expect(record.isWish('User A'), true);
    expect(record.isWish('User B'), false);
    expect(record.isBorrowed('User A'), false);
    expect(record.isBorrowed('User B'), false);
    expect(record.isTransit('User A'), false);
    expect(record.isTransit('User B'), false);
    expect(record.isLent('User A'), false);
    expect(record.isLent('User B'), false);
    expect(record.type('User A'), BookrecordType.wish);
    expect(record.type('User B'), BookrecordType.none);
  });

  test("Bookrecord class: lent/borrowed", () async {
    Bookrecord record = new Bookrecord(
      bookId: 'Book',
      ownerId: 'User A',
      holderId: 'User B',
      transit: false,
      wish: false,
      lent: true,
    );

    expect(record.isWish('User A'), false);
    expect(record.isWish('User B'), false);
    expect(record.isWish('User C'), false);
    expect(record.isBorrowed('User A'), false);
    expect(record.isBorrowed('User B'), true);
    expect(record.isBorrowed('User C'), false);
    expect(record.isTransit('User A'), false);
    expect(record.isTransit('User B'), false);
    expect(record.isTransit('User C'), false);
    expect(record.isLent('User A'), true);
    expect(record.isLent('User B'), false);
    expect(record.isLent('User C'), false);
    expect(record.type('User A'), BookrecordType.lent);
    expect(record.type('User B'), BookrecordType.borrowed);
    expect(record.type('User C'), BookrecordType.none);
  });

  test("Bookrecord class: transit to third person", () async {
    Bookrecord record = new Bookrecord(
      bookId: 'Book',
      ownerId: 'User A',
      holderId: 'User B',
      transitId: 'User C',
      transit: true,
      wish: false,
      lent: true,
    );

    expect(record.isWish('User A'), false);
    expect(record.isWish('User B'), false);
    expect(record.isWish('User C'), false);
    expect(record.isWish('User D'), false);
    expect(record.isBorrowed('User A'), false);
    expect(record.isBorrowed('User B'), false);
    expect(record.isBorrowed('User C'), false);
    expect(record.isBorrowed('User D'), false);
    expect(record.isTransit('User A'), false);
    expect(record.isTransit('User B'), true);
    expect(record.isTransit('User C'), true);
    expect(record.isTransit('User D'), false);
    expect(record.isLent('User A'), true);
    expect(record.isLent('User B'), false);
    expect(record.isLent('User C'), false);
    expect(record.isLent('User D'), false);
    expect(record.type('User A'), BookrecordType.lent);
    expect(record.type('User B'), BookrecordType.transit);
    expect(record.type('User C'), BookrecordType.transit);
    expect(record.type('User D'), BookrecordType.none);
  });

  test("Bookrecord class: transit to borrower", () async {
    Bookrecord record = new Bookrecord(
      bookId: 'Book',
      ownerId: 'User A',
      holderId: 'User A',
      transitId: 'User B',
      transit: true,
      wish: false,
      lent: false,
    );

    expect(record.isWish('User A'), false);
    expect(record.isWish('User B'), false);
    expect(record.isWish('User C'), false);
    expect(record.isBorrowed('User A'), false);
    expect(record.isBorrowed('User B'), false);
    expect(record.isBorrowed('User C'), false);
    expect(record.isTransit('User A'), true);
    expect(record.isTransit('User B'), true);
    expect(record.isTransit('User C'), false);
    expect(record.isLent('User A'), false);
    expect(record.isLent('User B'), false);
    expect(record.isLent('User C'), false);
    expect(record.type('User A'), BookrecordType.transit);
    expect(record.type('User B'), BookrecordType.transit);
    expect(record.type('User C'), BookrecordType.none);
  });

  test("Bookrecord class: transit to borrower/invalid lent flag", () async {
    Bookrecord record = new Bookrecord(
      bookId: 'Book',
      ownerId: 'User A',
      holderId: 'User A',
      transitId: 'User B',
      transit: true,
      wish: false,
      lent: true,
    );

    expect(record.isWish('User A'), false);
    expect(record.isWish('User B'), false);
    expect(record.isWish('User C'), false);
    expect(record.isBorrowed('User A'), false);
    expect(record.isBorrowed('User B'), false);
    expect(record.isBorrowed('User C'), false);
    expect(record.isTransit('User A'), true);
    expect(record.isTransit('User B'), true);
    expect(record.isTransit('User C'), false);
    expect(record.isLent('User A'), false);
    expect(record.isLent('User B'), false);
    expect(record.isLent('User C'), false);
    expect(record.type('User A'), BookrecordType.transit);
    expect(record.type('User B'), BookrecordType.transit);
    expect(record.type('User C'), BookrecordType.none);
  });

  test("Bookrecord class: transit to owner", () async {
    Bookrecord record = new Bookrecord(
      bookId: 'Book',
      ownerId: 'User A',
      holderId: 'User B',
      transitId: 'User A',
      transit: true,
      wish: false,
      lent: true,
    );

    expect(record.isWish('User A'), false);
    expect(record.isWish('User B'), false);
    expect(record.isWish('User C'), false);
    expect(record.isBorrowed('User A'), false);
    expect(record.isBorrowed('User B'), false);
    expect(record.isBorrowed('User C'), false);
    expect(record.isTransit('User A'), true);
    expect(record.isTransit('User B'), true);
    expect(record.isTransit('User C'), false);
    expect(record.isLent('User A'), false);
    expect(record.isLent('User B'), false);
    expect(record.isLent('User C'), false);
    expect(record.type('User A'), BookrecordType.transit);
    expect(record.type('User B'), BookrecordType.transit);
    expect(record.type('User C'), BookrecordType.none);
  });

  test("Bookrecord class: transit to owner/invalid lent flag", () async {
    Bookrecord record = new Bookrecord(
      bookId: 'Book',
      ownerId: 'User A',
      holderId: 'User B',
      transitId: 'User A',
      transit: true,
      wish: false,
      lent: false,
    );

    expect(record.isWish('User A'), false);
    expect(record.isWish('User B'), false);
    expect(record.isWish('User C'), false);
    expect(record.isBorrowed('User A'), false);
    expect(record.isBorrowed('User B'), false);
    expect(record.isBorrowed('User C'), false);
    expect(record.isTransit('User A'), true);
    expect(record.isTransit('User B'), true);
    expect(record.isTransit('User C'), false);
    expect(record.isLent('User A'), false);
    expect(record.isLent('User B'), false);
    expect(record.isLent('User C'), false);
    expect(record.type('User A'), BookrecordType.transit);
    expect(record.type('User B'), BookrecordType.transit);
    expect(record.type('User C'), BookrecordType.none);
  });

  test("Operation class: Reward, toJson and fromJson", () async {
    User userA = new User(name: 'A', photo: 'photoA', id: 'userId');
    User userB = new User(name: 'B', photo: 'photoB', id: 'peerId');

    Operation op = new Operation(
        type: OperationType.Reward,
        userId: userA.id,
        amount: 100.0,
        date: new DateTime(2018, 6, 1),
        transactionId: 'transactionId',
        proxyTransactionId: 'proxyTransactionId',
        peerId: userB.id,
        bookrecordId: 'bookrecordId',
        bookId: 'bookId',
        price: 200.0,
        start: new DateTime(2018, 1, 1),
        end: new DateTime(2020, 1, 1),
        deposit: 50.0,
        fee: 10.0,
        ownerFee1: 1.0,
        ownerFee2: 1.5,
        payerFee1: 1.0,
        payerFee2: 1.5,
        ownerFeeUserId1: 'ownerFeeUserId1',
        ownerFeeUserId2: 'ownerFeeUserId2',
        payerFeeUserId1: 'payerFeeUserId1',
        payerFeeUserId2: 'payerFeeUserId2',
        paid: 30.0);

    op.ref().setData(op.toJson());
    DocumentSnapshot snap = await op.ref().get();
    Operation result = Operation.fromJson(snap.data);

    expect(result.type, OperationType.Reward);
    expect(result.userId, 'userId');
    expect(result.amount, 100.0);
    expect(result.date, new DateTime(2018, 6, 1));
    expect(result.transactionId, null);           // Not applicable for Reward
    expect(result.proxyTransactionId, null);      // Not applicable for Reward
    expect(result.peerId, 'peerId');
    expect(result.bookrecordId, 'bookrecordId');
    expect(result.bookId, 'bookId');
    expect(result.price, 200.0);
    expect(result.start, new DateTime(2018, 1, 1));
    expect(result.end, new DateTime(2020, 1, 1));
    expect(result.deposit, 0.0);                  // Not applicable for Reward
    expect(result.fee, 0.0);                      // Not applicable for Reward
    expect(result.ownerFee1, 0.0);                // Not applicable for Reward
    expect(result.ownerFee2, 0.0);                // Not applicable for Reward
    expect(result.payerFee1, 0.0);                // Not applicable for Reward
    expect(result.payerFee2, 0.0);                // Not applicable for Reward
    expect(result.ownerFeeUserId1, null);         // Not applicable for Reward
    expect(result.ownerFeeUserId2, null);         // Not applicable for Reward
    expect(result.payerFeeUserId1, null);         // Not applicable for Reward
    expect(result.payerFeeUserId2, null);         // Not applicable for Reward
    expect(result.paid, 30.0);
    expect(result.users, {'userId', 'peerId'});
    expect(result.isReward(userA), true);
    expect(result.isReward(userB), false);
    expect(result.isLeasing(userA), false);
    expect(result.isLeasing(userB), false);
  });

  test("Operation class: Leasing, toJson and fromJson", () async {
    User userA = new User(name: 'A', photo: 'photoA', id: 'userId');
    User userB = new User(name: 'B', photo: 'photoB', id: 'peerId');
    User user1 = new User(name: '1', photo: 'photoA', id: 'ownerFeeUserId1');
    User user2 = new User(name: '2', photo: 'photoB', id: 'ownerFeeUserId2');
    User user3 = new User(name: '3', photo: 'photoA', id: 'payerFeeUserId1');
    User user4 = new User(name: '4', photo: 'photoB', id: 'payerFeeUserId2');

    Operation op = new Operation(
        type: OperationType.Leasing,
        userId: userA.id,
        amount: 100.0,
        date: new DateTime(2018, 6, 1),
        transactionId: 'transactionId',
        proxyTransactionId: 'proxyTransactionId',
        peerId: userB.id,
        bookrecordId: 'bookrecordId',
        bookId: 'bookId',
        price: 200.0,
        start: new DateTime(2018, 1, 1),
        end: new DateTime(2020, 1, 1),
        deposit: 50.0,
        fee: 10.0,
        ownerFee1: 1.0,
        ownerFee2: 1.5,
        payerFee1: 1.0,
        payerFee2: 1.5,
        ownerFeeUserId1: user1.id,
        ownerFeeUserId2: user2.id,
        payerFeeUserId1: user3.id,
        payerFeeUserId2: user4.id,
        paid: 30.0);

    op.ref().setData(op.toJson());
    DocumentSnapshot snap = await op.ref().get();
    Operation result = Operation.fromJson(snap.data);

    expect(result.type, OperationType.Leasing);
    expect(result.userId, 'userId');
    expect(result.amount, 100.0);
    expect(result.date, new DateTime(2018, 6, 1));
    expect(result.transactionId, null);           // Not applicable for Reward
    expect(result.proxyTransactionId, null);      // Not applicable for Reward
    expect(result.peerId, 'peerId');
    expect(result.bookrecordId, 'bookrecordId');
    expect(result.bookId, 'bookId');
    expect(result.price, 200.0);
    expect(result.start, new DateTime(2018, 1, 1));
    expect(result.end, new DateTime(2020, 1, 1));
    expect(result.deposit, 50.0);
    expect(result.fee, 10.0);
    expect(result.ownerFee1, 1.0);
    expect(result.ownerFee2, 1.5);
    expect(result.payerFee1, 1.0);
    expect(result.payerFee2, 1.5);
    expect(result.ownerFeeUserId1, 'ownerFeeUserId1');
    expect(result.ownerFeeUserId2, 'ownerFeeUserId2');
    expect(result.payerFeeUserId1, 'payerFeeUserId1');
    expect(result.payerFeeUserId2, 'payerFeeUserId2');
    expect(result.paid, 30.0);
    expect(result.users, {'userId', 'peerId', 'ownerFeeUserId1', 'ownerFeeUserId2', 'payerFeeUserId1', 'payerFeeUserId2'});
    expect(result.isLeasing(userA), true);
    expect(result.isLeasing(userB), false);
    expect(result.isLeasing(user1), false);
    expect(result.isLeasing(user2), false);
    expect(result.isLeasing(user3), false);
    expect(result.isLeasing(user4), false);
    expect(result.isReferral(user1), true);
    expect(result.isReferral(user2), true);
    expect(result.isReferral(user3), true);
    expect(result.isReferral(user4), true);
    expect(result.isReferral(userA), false);
    expect(result.isReferral(userB), false);
    expect(result.isReward(userA), false);
    expect(result.isReward(userB), false);
    expect(result.isIn(userA), false);
    expect(result.isIn(userB), false);
    expect(result.isIn(user1), false);
    expect(result.isIn(user2), false);
    expect(result.isIn(user3), false);
    expect(result.isIn(user4), false);
    expect(result.isOut(userA), false);
    expect(result.isOut(userB), false);
    expect(result.isOut(user1), false);
    expect(result.isOut(user2), false);
    expect(result.isOut(user3), false);
    expect(result.isOut(user4), false);
  });

  test("Operation class: Leasing empty referrals, toJson and fromJson", () async {
    User userA = new User(name: 'A', photo: 'photoA', id: 'userId');
    User userB = new User(name: 'B', photo: 'photoB', id: 'peerId');
    User user1 = new User(name: '1', photo: 'photoA', id: 'ownerFeeUserId1');
    User user2 = new User(name: '2', photo: 'photoB', id: 'ownerFeeUserId2');
    User user3 = new User(name: '3', photo: 'photoA', id: 'payerFeeUserId1');
    User user4 = new User(name: '4', photo: 'photoB', id: 'payerFeeUserId1');

    Operation op = new Operation(
        type: OperationType.Leasing,
        userId: userA.id,
        amount: 100.0,
        date: new DateTime(2018, 6, 1),
        transactionId: 'transactionId',
        proxyTransactionId: 'proxyTransactionId',
        peerId: userB.id,
        bookrecordId: 'bookrecordId',
        bookId: 'bookId',
        price: 200.0,
        start: new DateTime(2018, 1, 1),
        end: new DateTime(2020, 1, 1),
        deposit: 50.0,
        fee: 10.0,
        paid: 30.0);

    op.ref().setData(op.toJson());
    DocumentSnapshot snap = await op.ref().get();
    Operation result = Operation.fromJson(snap.data);

    expect(result.type, OperationType.Leasing);
    expect(result.userId, 'userId');
    expect(result.amount, 100.0);
    expect(result.date, new DateTime(2018, 6, 1));
    expect(result.transactionId, null);           // Not applicable for Reward
    expect(result.proxyTransactionId, null);      // Not applicable for Reward
    expect(result.peerId, 'peerId');
    expect(result.bookrecordId, 'bookrecordId');
    expect(result.bookId, 'bookId');
    expect(result.price, 200.0);
    expect(result.start, new DateTime(2018, 1, 1));
    expect(result.end, new DateTime(2020, 1, 1));
    expect(result.deposit, 50.0);
    expect(result.fee, 10.0);
    expect(result.paid, 30.0);
    expect(result.users, {'userId', 'peerId'});
    expect(result.isLeasing(userA), true);
    expect(result.isLeasing(userB), false);
    expect(result.isLeasing(user1), false);
    expect(result.isLeasing(user2), false);
    expect(result.isLeasing(user3), false);
    expect(result.isLeasing(user4), false);
    expect(result.isReferral(user1), false);
    expect(result.isReferral(user2), false);
    expect(result.isReferral(user3), false);
    expect(result.isReferral(user4), false);
    expect(result.isReferral(userA), false);
    expect(result.isReferral(userB), false);
    expect(result.isReward(userA), false);
    expect(result.isReward(userB), false);
    expect(result.isIn(userA), false);
    expect(result.isIn(userB), false);
    expect(result.isIn(user1), false);
    expect(result.isIn(user2), false);
    expect(result.isIn(user3), false);
    expect(result.isIn(user4), false);
    expect(result.isOut(userA), false);
    expect(result.isOut(userB), false);
    expect(result.isOut(user1), false);
    expect(result.isOut(user2), false);
    expect(result.isOut(user3), false);
    expect(result.isOut(user4), false);
  });

  // TODO: Check is Function with optional users == null
  // TODO: test referralAmount
}
