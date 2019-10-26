import 'package:flutter_test/flutter_test.dart';
import 'package:biblosphere/mock_firestore.dart';
import 'package:biblosphere/const.dart';
import 'package:biblosphere/helpers.dart';
import 'package:biblosphere/lifecycle.dart';

main() {
  db = MockFirestore.instance;

  test("Deposit function: give book A to B", () async {
    // Create User A
    User userA = new User(
        name: 'User A',
        photo: 'http://image.com/userA.jpg',
    );
    userA.ref().setData(userA.toJson());
    // Balance should be set directly
    userA.ref().updateData({'balance': 10});

    // Create User B
    User userB = new User(
        name: 'User B',
        photo: 'http://image.com/userB.jpg',
    );
    userB.ref().setData(userB.toJson());
    userB.ref().updateData({'balance': 50});

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
      price: 10.0,
    );
    book.ref().setData(book.toJson());

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      bookId: book.id,
      ownerId: userA.id,
      holderId: userA.id,
      transitId: userB.id,
      price: 30.00,
      transit: true,
      wish: false,
      lent: false,
    );
    record.ref().setData(record.toJson());

    // Run deposit function
    await deposit(books: [record], owner: userA, payer: userB);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref().get()).data);
    User resultA = User.fromJson((await userA.ref().get()).data);
    User resultB = User.fromJson((await userB.ref().get()).data);

    expect(resultRec.rewardId, (s) => s != null);
    expect(resultRec.leasingId, (s) => s != null);

    Operation reward = Operation.fromJson(
        (await Operation.Ref(resultRec.rewardId).get()).data);
    Operation leasing = Operation.fromJson(
        (await Operation.Ref(resultRec.leasingId).get()).data);

    expect(resultRec.transit, false);
    expect(resultRec.lent, true);
    expect(resultRec.ownerId, userA.id);
    expect(resultRec.holderId, userB.id);
    expect(resultRec.transitId, null);
    expect(resultRec.users, {userA.id, userB.id});
    expect(reward.paid, 25.0 / 6);
    expect(reward.amount, 25.0 / 6);
    expect(reward.userId, userA.id);
    expect(reward.peerId, userB.id);
    expect(leasing.paid, 25.0 / 6);
    expect(leasing.deposit, 25.0 * 1.2 - 25.0 / 6);
    expect(leasing.amount, 25.0 * 1.2);
    expect(leasing.end.difference(leasing.start).inDays, 183);
    expect(leasing.userId, userB.id);
    expect(leasing.peerId, userA.id);
    expect(resultA.balance, 10.0 + 25.0 / 6);
    expect(resultB.balance, 50.0 - 25.0 / 6);
    expect(resultB.blocked, 25.0 * 1.2 - 25.0 / 6);
  });

  test("Complete function: return book B to A", () async {
    // Create User A
    User userA = new User(
      name: 'User A',
      photo: 'http://image.com/userA.jpg',
    );
    userA.ref().setData(userA.toJson());
    // Balance should be set directly
    userA.ref().updateData({'balance': 10 + 25.0 / 6});

    // Create User B
    User userB = new User(
      name: 'User B',
      photo: 'http://image.com/userB.jpg',
    );
    userB.ref().setData(userB.toJson());
    userB.ref().updateData({'balance': 50 - 25.0 / 6, 'blocked': 25.0 * 1.2 - 25.0 / 6});

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
      price: 10.0,
    );
    book.ref().setData(book.toJson());

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      bookId: book.id,
      ownerId: userA.id,
      holderId: userB.id,
      transitId: userA.id,
      price: 30.00,
      transit: true,
      wish: false,
      lent: true,
    );
    record.ref().setData(record.toJson());

    // Create reward operation
    Operation rewardOp = new Operation(
        type: OperationType.Reward,
        userId: userA.id,
        amount: 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userB.id,
        bookrecordId: record.id,
        bookId: book.id,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        paid: 25.0 / 6);
    rewardOp.ref().setData(rewardOp.toJson());

    // Create leasing operation
    Operation leasingOp = new Operation(
        type: OperationType.Leasing,
        userId: userB.id,
        amount: 25.0 * 1.2 - 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userA.id,
        bookrecordId: record.id,
        bookId: book.id,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        deposit: 25.0 * 1.2 - 25.0 / 6,
        paid: 25.0 / 6);
    leasingOp.ref().setData(leasingOp.toJson());

    // Update reference to operations
    record.ref().updateData({'rewardId': rewardOp.id, 'leasingId': leasingOp.id});

    // Run complete function
    await complete(books: [record], holder: userB, owner: userA);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref().get()).data);
    User resultA = User.fromJson((await userA.ref().get()).data);
    User resultB = User.fromJson((await userB.ref().get()).data);
    Operation reward = Operation.fromJson((await rewardOp.ref().get()).data);
    Operation leasing = Operation.fromJson((await leasingOp.ref().get()).data);

    expect(resultRec.transit, false);
    expect(resultRec.lent, false);
    expect(resultRec.ownerId, userA.id);
    expect(resultRec.holderId, userA.id);
    expect(resultRec.transitId, null);
    expect(resultRec.users, {userA.id});
    expect(resultRec.rewardId, null);
    expect(resultRec.leasingId, null);
    expect(reward.paid, 25.0 * 83 / 183);
    expect(reward.amount, 25.0 * 83 / 183);
    expect(reward.userId, userA.id);
    expect(reward.peerId, userB.id);
    expect(leasing.paid, 25.0 * 83 / 183);
    expect(leasing.deposit, 0);
    expect(leasing.amount, 25.0 * 1.2 * 83 / 183);
    expect(leasing.userId, userB.id);
    expect(leasing.peerId, userA.id);
    expect(dp(leasing.fee, 5), dp(25.0 * 0.2 * 83 / 183, 5));
    expect(resultA.balance, 10.0 + 25.0 * 83 / 183);
    expect(resultB.balance, 50.0 - 25.0 * 1.2 * 83 / 183);
    expect(resultB.blocked, 0);
  });

  test("Pass function: pass book B to C", () async {
    // Create User A
    User userA = new User(
      name: 'User A',
      photo: 'http://image.com/userA.jpg',
    );
    userA.ref().setData(userA.toJson());
    // Balance should be set directly
    userA.ref().updateData({'balance': 10 + 25.0 / 6});

    // Create User B
    User userB = new User(
      name: 'User B',
      photo: 'http://image.com/userB.jpg',
    );
    userB.ref().setData(userB.toJson());
    userB.ref().updateData({'balance': 50 - 25.0 / 6, 'blocked': 25.0 * 1.2 - 25.0 / 6});

    // Create User C
    User userC = new User(
      name: 'User C',
      photo: 'http://image.com/userC.jpg',
    );
    userC.ref().setData(userC.toJson());
    userC.ref().updateData({'balance': 100});

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
      price: 10.0,
    );
    book.ref().setData(book.toJson());

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      bookId: book.id,
      ownerId: userA.id,
      holderId: userB.id,
      transitId: userC.id,
      price: 30.00,
      transit: true,
      wish: false,
      lent: true,
    );
    record.ref().setData(record.toJson());

    // Create reward operation
    Operation rewardOp = new Operation(
        type: OperationType.Reward,
        userId: userA.id,
        amount: 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userB.id,
        bookrecordId: record.id,
        bookId: book.id,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        paid: 25.0 / 6);
    rewardOp.ref().setData(rewardOp.toJson());

    // Create leasing operation
    Operation leasingOp = new Operation(
        type: OperationType.Leasing,
        userId: userB.id,
        amount: 25.0 * 1.2 - 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userA.id,
        bookrecordId: record.id,
        bookId: book.id,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        deposit: 25.0 * 1.2 - 25.0 / 6,
        paid: 25.0 / 6);
    leasingOp.ref().setData(leasingOp.toJson());

    // Update reference to operations
    record.ref().updateData({'rewardId': rewardOp.id, 'leasingId': leasingOp.id});

    // Run complete function
    await pass(books: [record], holder: userB, payer: userC);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref().get()).data);
    User resultA = User.fromJson((await userA.ref().get()).data);
    User resultB = User.fromJson((await userB.ref().get()).data);
    User resultC = User.fromJson((await userC.ref().get()).data);
    Operation rewardOld = Operation.fromJson((await rewardOp.ref().get()).data);
    Operation leasingOld = Operation.fromJson((await leasingOp.ref().get()).data);

    expect(resultRec.leasingId, (s) => s != leasingOld.id);

    Operation leasingNew = Operation.fromJson(
        (await Operation.Ref(resultRec.leasingId).get()).data);

    expect(resultRec.transit, false);
    expect(resultRec.lent, true);
    expect(resultRec.ownerId, userA.id);
    expect(resultRec.holderId, userC.id);
    expect(resultRec.transitId, null);
    expect(resultRec.users, {userA.id, userC.id});
    expect(resultRec.rewardId, rewardOld.id);
    expect(resultRec.leasingId, leasingNew.id);
    expect(rewardOld.paid, 25.0 * 83 / 183 + 25.0 / 6);
    expect(rewardOld.amount, 25.0 * 83 / 183 + 25.0 / 6);
    expect(rewardOld.userId, userA.id);
    expect(rewardOld.peerId, userC.id);
    expect(leasingOld.paid, 25.0 * 83 / 183);
    expect(leasingOld.deposit, 0);
    expect(leasingOld.amount, 25.0 * 1.2 * 83 / 183);
    expect(leasingOld.userId, userB.id);
    expect(leasingOld.peerId, userA.id);
    expect(dp(leasingOld.fee,5), dp(25.0 * 0.2 * 83 / 183,5));
    expect(leasingNew.paid, 25.0 / 6);
    expect(leasingNew.deposit, 25.0 * 1.2 - 25.0 / 6);
    expect(leasingNew.amount, 25.0 * 1.2);
    expect(leasingNew.userId, userC.id);
    expect(leasingNew.peerId, userA.id);
    expect(leasingNew.fee, 0.0);
    expect(leasingNew.end.difference(leasingNew.start).inDays, 183);
    expect(resultA.balance, 10.0 + 25.0 * 83 / 183 + 25.0 / 6);
    expect(resultB.balance, 50.0 - 25.0 * 1.2 * 83 / 183);
    expect(resultB.blocked, 0);
    expect(resultC.balance, 100.0 - 25.0 / 6);
    expect(resultC.blocked, 25 * 1.2 - 25.0 / 6);
  });


  test("Pass function: pass book B to C then to D", () async {
    // Create User A
    User userA = new User(
      name: 'User A',
      photo: 'http://image.com/userA.jpg',
    );
    userA.ref().setData(userA.toJson());
    // Balance should be set directly
    userA.ref().updateData({'balance': 10 + 25.0 / 6});

    // Create User B
    User userB = new User(
      name: 'User B',
      photo: 'http://image.com/userB.jpg',
    );
    userB.ref().setData(userB.toJson());
    userB.ref().updateData({'balance': 50 - 25.0 / 6, 'blocked': 25.0 * 1.2 - 25.0 / 6});

    // Create User C
    User userC = new User(
      name: 'User C',
      photo: 'http://image.com/userC.jpg',
    );
    userC.ref().setData(userC.toJson());
    userC.ref().updateData({'balance': 100});

    // Create User D
    User userD = new User(
      name: 'User D',
      photo: 'http://image.com/userD.jpg',
    );
    userD.ref().setData(userD.toJson());
    userD.ref().updateData({'balance': 150});

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
      price: 10.0,
    );
    book.ref().setData(book.toJson());

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      bookId: book.id,
      ownerId: userA.id,
      holderId: userB.id,
      transitId: userC.id,
      price: 30.00,
      transit: true,
      wish: false,
      lent: true,
    );
    record.ref().setData(record.toJson());

    // Create reward operation
    Operation rewardOp = new Operation(
        type: OperationType.Reward,
        userId: userA.id,
        amount: 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userB.id,
        bookrecordId: record.id,
        bookId: book.id,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        paid: 25.0 / 6);
    rewardOp.ref().setData(rewardOp.toJson());

    // Create leasing operation
    Operation leasingOp = new Operation(
        type: OperationType.Leasing,
        userId: userB.id,
        amount: 25.0 * 1.2 - 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userA.id,
        bookrecordId: record.id,
        bookId: book.id,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        deposit: 25.0 * 1.2 - 25.0 / 6,
        paid: 25.0 / 6);
    leasingOp.ref().setData(leasingOp.toJson());

    // Update reference to operations
    record.ref().updateData({'rewardId': rewardOp.id, 'leasingId': leasingOp.id});

    // Run complete function to pass B to C
    await pass(books: [record], holder: userB, payer: userC);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref().get()).data);
    User resultA = User.fromJson((await userA.ref().get()).data);
    User resultB = User.fromJson((await userB.ref().get()).data);
    User resultC = User.fromJson((await userC.ref().get()).data);
    Operation rewardOld = Operation.fromJson((await rewardOp.ref().get()).data);
    Operation leasingOld = Operation.fromJson((await leasingOp.ref().get()).data);

    expect(resultRec.leasingId, (s) => s != leasingOld.id);

    Operation leasingNew = Operation.fromJson(
        (await Operation.Ref(resultRec.leasingId).get()).data);

    expect(resultRec.transit, false);
    expect(resultRec.lent, true);
    expect(resultRec.ownerId, userA.id);
    expect(resultRec.holderId, userC.id);
    expect(resultRec.transitId, null);
    expect(resultRec.users, {userA.id, userC.id});
    expect(resultRec.rewardId, rewardOld.id);
    expect(resultRec.leasingId, leasingNew.id);
    expect(rewardOld.paid, 25.0 * 83 / 183 + 25.0 / 6);
    expect(rewardOld.amount, 25.0 * 83 / 183 + 25.0 / 6);
    expect(rewardOld.userId, userA.id);
    expect(rewardOld.peerId, userC.id);
    expect(leasingOld.paid, 25.0 * 83 / 183);
    expect(leasingOld.deposit, 0);
    expect(leasingOld.amount, 25.0 * 1.2 * 83 / 183);
    expect(leasingOld.userId, userB.id);
    expect(leasingOld.peerId, userA.id);
    expect(dp(leasingOld.fee, 5), dp(25.0 * 0.2 * 83 / 183, 5));
    expect(leasingNew.paid, 25.0 / 6);
    expect(leasingNew.deposit, 25.0 * 1.2 - 25.0 / 6);
    expect(leasingNew.amount, 25.0 * 1.2);
    expect(leasingNew.userId, userC.id);
    expect(leasingNew.peerId, userA.id);
    expect(leasingNew.fee, 0.0);
    expect(leasingNew.end.difference(leasingNew.start).inDays, 183);
    expect(resultA.balance, 10.0 + 25.0 * 83 / 183 + 25.0 / 6);
    expect(resultB.balance, 50.0 - 25.0 * 1.2 * 83 / 183);
    expect(resultB.blocked, 0);
    expect(resultC.balance, 100.0 - 25.0 / 6);
    expect(resultC.blocked, 25 * 1.2 - 25.0 / 6);

    // Transit to User D
    record.ref().updateData({'transit': true, 'transitId': userD.id});

    // Run complete function to pass B to C
    await pass(books: [record], holder: userC, payer: userD);

    resultRec = Bookrecord.fromJson((await record.ref().get()).data);
    resultA = User.fromJson((await userA.ref().get()).data);
    resultC = User.fromJson((await userC.ref().get()).data);
    User resultD = User.fromJson((await userD.ref().get()).data);
    rewardOld = Operation.fromJson((await rewardOp.ref().get()).data);
    leasingOld = Operation.fromJson((await leasingNew.ref().get()).data);

    expect(resultRec.leasingId, (s) => s != leasingNew.id);

    leasingNew = Operation.fromJson(
        (await Operation.Ref(resultRec.leasingId).get()).data);

    expect(resultRec.transit, false);
    expect(resultRec.lent, true);
    expect(resultRec.ownerId, userA.id);
    expect(resultRec.holderId, userD.id);
    expect(resultRec.transitId, null);
    expect(resultRec.users, {userA.id, userD.id});
    expect(resultRec.rewardId, rewardOld.id);
    expect(resultRec.leasingId, leasingNew.id);
    expect(rewardOld.paid, 25.0 * 83 / 183 + 25.0 / 6  + 25.0 / 6);
    expect(rewardOld.amount, 25.0 * 83 / 183 + 25.0 / 6  + 25.0 / 6);
    expect(rewardOld.userId, userA.id);
    expect(rewardOld.peerId, userD.id);
    expect(leasingOld.paid, 25.0 / 6);
    expect(leasingOld.deposit, 0);
    expect(leasingOld.amount, 25.0 / 6 * 1.2);
    expect(leasingOld.userId, userC.id);
    expect(leasingOld.peerId, userA.id);
    expect(leasingOld.fee, 25.0 / 6 * 0.2);
    expect(leasingNew.paid, 25.0 / 6);
    expect(leasingNew.deposit, 25.0 * 1.2 - 25.0 / 6);
    expect(leasingNew.amount, 25.0 * 1.2);
    expect(leasingNew.userId, userD.id);
    expect(leasingNew.peerId, userA.id);
    expect(leasingNew.fee, 0.0);
    expect(leasingNew.end.difference(leasingNew.start).inDays, 183);
    expect(resultA.balance, 10.0 + 25.0 * 83 / 183 + 25.0 / 6 + 25.0 / 6);
    expect(resultC.balance, 100.0 - 25.0 / 6 * 1.2);
    expect(resultC.blocked, 0.0);
    expect(resultD.balance, 150.0 - 25.0 / 6);
    expect(resultD.blocked, 25.0 * 1.2 - 25.0 / 6);
  });

  test("Pass & Complete functions: pass book B to C then return", () async {
    // Create User A
    User userA = new User(
      name: 'User A',
      photo: 'http://image.com/userA.jpg',
    );
    userA.ref().setData(userA.toJson());
    // Balance should be set directly
    userA.ref().updateData({'balance': 10 + 25.0 / 6});

    // Create User B
    User userB = new User(
      name: 'User B',
      photo: 'http://image.com/userB.jpg',
    );
    userB.ref().setData(userB.toJson());
    userB.ref().updateData({'balance': 50 - 25.0 / 6, 'blocked': 25.0 * 1.2 - 25.0 / 6});

    // Create User C
    User userC = new User(
      name: 'User C',
      photo: 'http://image.com/userC.jpg',
    );
    userC.ref().setData(userC.toJson());
    userC.ref().updateData({'balance': 100});

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
      price: 10.0,
    );
    book.ref().setData(book.toJson());

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      bookId: book.id,
      ownerId: userA.id,
      holderId: userB.id,
      transitId: userC.id,
      price: 30.00,
      transit: true,
      wish: false,
      lent: true,
    );
    record.ref().setData(record.toJson());

    // Create reward operation
    Operation rewardOp = new Operation(
        type: OperationType.Reward,
        userId: userA.id,
        amount: 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userB.id,
        bookrecordId: record.id,
        bookId: book.id,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        paid: 25.0 / 6);
    rewardOp.ref().setData(rewardOp.toJson());

    // Create leasing operation
    Operation leasingOp = new Operation(
        type: OperationType.Leasing,
        userId: userB.id,
        amount: 25.0 * 1.2 - 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userA.id,
        bookrecordId: record.id,
        bookId: book.id,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        deposit: 25.0 * 1.2 - 25.0 / 6,
        paid: 25.0 / 6);
    leasingOp.ref().setData(leasingOp.toJson());

    // Update reference to operations
    record.ref().updateData({'rewardId': rewardOp.id, 'leasingId': leasingOp.id});

    // Run complete function to pass B to C
    await pass(books: [record], holder: userB, payer: userC);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref().get()).data);
    User resultA = User.fromJson((await userA.ref().get()).data);
    User resultB = User.fromJson((await userB.ref().get()).data);
    User resultC = User.fromJson((await userC.ref().get()).data);
    Operation rewardOld = Operation.fromJson((await rewardOp.ref().get()).data);
    Operation leasingOld = Operation.fromJson((await leasingOp.ref().get()).data);

    expect(resultRec.leasingId, (s) => s != leasingOld.id);

    Operation leasingNew = Operation.fromJson(
        (await Operation.Ref(resultRec.leasingId).get()).data);

    expect(resultRec.transit, false);
    expect(resultRec.lent, true);
    expect(resultRec.ownerId, userA.id);
    expect(resultRec.holderId, userC.id);
    expect(resultRec.transitId, null);
    expect(resultRec.users, {userA.id, userC.id});
    expect(resultRec.rewardId, rewardOld.id);
    expect(resultRec.leasingId, leasingNew.id);
    expect(rewardOld.paid, 25.0 * 83 / 183 + 25.0 / 6);
    expect(rewardOld.amount, 25.0 * 83 / 183 + 25.0 / 6);
    expect(rewardOld.userId, userA.id);
    expect(rewardOld.peerId, userC.id);
    expect(leasingOld.paid, 25.0 * 83 / 183);
    expect(leasingOld.deposit, 0);
    expect(leasingOld.amount, 25.0 * 1.2 * 83 / 183);
    expect(leasingOld.userId, userB.id);
    expect(leasingOld.peerId, userA.id);
    expect(dp(leasingOld.fee, 5), dp(25.0 * 0.2 * 83 / 183, 5));
    expect(leasingNew.paid, 25.0 / 6);
    expect(leasingNew.deposit, 25.0 * 1.2 - 25.0 / 6);
    expect(leasingNew.amount, 25.0 * 1.2);
    expect(leasingNew.userId, userC.id);
    expect(leasingNew.peerId, userA.id);
    expect(leasingNew.fee, 0.0);
    expect(leasingNew.end.difference(leasingNew.start).inDays, 183);
    expect(resultA.balance, 10.0 + 25.0 * 83 / 183 + 25.0 / 6);
    expect(resultB.balance, 50.0 - 25.0 * 1.2 * 83 / 183);
    expect(resultB.blocked, 0);
    expect(resultC.balance, 100.0 - 25.0 / 6);
    expect(resultC.blocked, 25 * 1.2 - 25.0 / 6);

    // Transit to User A
    record.ref().updateData({'transit': true, 'transitId': userA.id});

    // Run complete function to pass B to C
    await complete(books: [record], holder: userC, owner: userA);

    resultRec = Bookrecord.fromJson((await record.ref().get()).data);
    resultA = User.fromJson((await userA.ref().get()).data);
    resultC = User.fromJson((await userC.ref().get()).data);
    rewardOld = Operation.fromJson((await rewardOp.ref().get()).data);
    leasingOld = Operation.fromJson((await leasingNew.ref().get()).data);

    expect(resultRec.transit, false);
    expect(resultRec.lent, false);
    expect(resultRec.ownerId, userA.id);
    expect(resultRec.holderId, userA.id);
    expect(resultRec.transitId, null);
    expect(resultRec.users, {userA.id});
    expect(resultRec.rewardId, null);
    expect(resultRec.leasingId, null);
    expect(rewardOld.paid, 25.0 * 83 / 183 + 25.0 / 6);
    expect(rewardOld.amount, 25.0 * 83 / 183 + 25.0 / 6);
    expect(rewardOld.userId, userA.id);
    expect(rewardOld.peerId, userC.id);
    expect(leasingOld.paid, 25.0 / 6);
    expect(leasingOld.deposit, 0);
    expect(leasingOld.amount, 25.0 / 6 * 1.2);
    expect(leasingOld.userId, userC.id);
    expect(leasingOld.peerId, userA.id);
    expect(leasingOld.fee, 25.0 / 6 * 0.2);
    expect(resultA.balance, 10.0 + 25.0 * 83 / 183 + 25.0 / 6);
    expect(resultC.balance, 100.0 - 25.0 / 6 * 1.2);
    expect(resultC.blocked, 0.0);
  });

  test("Complete function: Referrals", () async {
    // Referral users
    User userA2 = new User(
        name: 'User A2',
        photo: 'http://image.com/userA2.jpg',
    );
    userA2.ref().setData(userA2.toJson());
    userA2.ref().updateData({'balance': 120});

    User userA1 = new User(
        name: 'User A1',
        photo: 'http://image.com/userA1.jpg',
        beneficiary1: userA2.id
    );
    userA1.ref().setData(userA1.toJson());
    // Balance should be set directly
    userA1.ref().updateData({'balance': 110});

    User userB2 = new User(
        name: 'User B2',
        photo: 'http://image.com/userB2.jpg',

    );
    userB2.ref().setData(userB2.toJson());
    userB2.ref().updateData({'balance': 220});

    User userB1 = new User(
        name: 'User B1',
        photo: 'http://image.com/userB1.jpg',
        beneficiary1: userB2.id
    );
    userB1.ref().setData(userB1.toJson());
    // Balance should be set directly
    userB1.ref().updateData({'balance': 210});


    // Create User A
    User userA = new User(
      name: 'User A',
      photo: 'http://image.com/userA.jpg',
      beneficiary1: userA1.id,
      beneficiary2: userA2.id
    );
    userA.ref().setData(userA.toJson());
    // Balance should be set directly
    userA.ref().updateData({'balance': 10 + 25.0 / 6});

    // Create User B
    User userB = new User(
      name: 'User B',
      photo: 'http://image.com/userB.jpg',
        beneficiary1: userB1.id,
        beneficiary2: userB2.id
    );
    userB.ref().setData(userB.toJson());
    userB.ref().updateData({'balance': 50 - 25.0 / 6, 'blocked': 25.0 * 1.2 - 25.0 / 6});

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
      price: 10.0,
    );
    book.ref().setData(book.toJson());

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      bookId: book.id,
      ownerId: userA.id,
      holderId: userB.id,
      transitId: userA.id,
      price: 30.00,
      transit: true,
      wish: false,
      lent: true,
    );
    record.ref().setData(record.toJson());

    // Create reward operation
    Operation rewardOp = new Operation(
        type: OperationType.Reward,
        userId: userA.id,
        amount: 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userB.id,
        bookrecordId: record.id,
        bookId: book.id,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        paid: 25.0 / 6);
    rewardOp.ref().setData(rewardOp.toJson());

    // Create leasing operation
    Operation leasingOp = new Operation(
        type: OperationType.Leasing,
        userId: userB.id,
        amount: 25.0 * 1.2 - 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userA.id,
        bookrecordId: record.id,
        bookId: book.id,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        deposit: 25.0 * 1.2 - 25.0 / 6,
        paid: 25.0 / 6);
    leasingOp.ref().setData(leasingOp.toJson());

    // Update reference to operations
    record.ref().updateData({'rewardId': rewardOp.id, 'leasingId': leasingOp.id});

    // Run complete function
    await complete(books: [record], holder: userB, owner: userA);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref().get()).data);
    User resultA = User.fromJson((await userA.ref().get()).data);
    User resultA1 = User.fromJson((await userA1.ref().get()).data);
    User resultA2 = User.fromJson((await userA2.ref().get()).data);
    User resultB = User.fromJson((await userB.ref().get()).data);
    User resultB1 = User.fromJson((await userB1.ref().get()).data);
    User resultB2 = User.fromJson((await userB2.ref().get()).data);
    Operation reward = Operation.fromJson((await rewardOp.ref().get()).data);
    Operation leasing = Operation.fromJson((await leasingOp.ref().get()).data);

    expect(resultRec.transit, false);
    expect(resultRec.lent, false);
    expect(resultRec.ownerId, userA.id);
    expect(resultRec.holderId, userA.id);
    expect(resultRec.transitId, null);
    expect(resultRec.users, {userA.id});
    expect(resultRec.rewardId, null);
    expect(resultRec.leasingId, null);
    expect(reward.paid, 25.0 * 83 / 183);
    expect(reward.amount, 25.0 * 83 / 183);
    expect(reward.userId, userA.id);
    expect(reward.peerId, userB.id);
    expect(leasing.paid, 25.0 * 83 / 183);
    expect(leasing.deposit, 0);
    expect(leasing.amount, 25.0 * 1.2 * 83 / 183);
    expect(leasing.userId, userB.id);
    expect(leasing.peerId, userA.id);
    expect(dp(leasing.fee, 5), dp(25.0 * 0.1 * 83 / 183, 5));
    expect(leasing.ownerFeeUserId1, userA1.id);
    expect(leasing.ownerFeeUserId2, userA2.id);
    expect(leasing.payerFeeUserId1, userB1.id);
    expect(leasing.payerFeeUserId2, userB2.id);
    expect(leasing.ownerFee1, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(leasing.ownerFee2, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(leasing.payerFee1, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(leasing.payerFee2, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultA.balance, 10.0 + 25.0 * 83 / 183);
    expect(resultB.balance, 50.0 - 25.0 * 1.2 * 83 / 183);
    expect(resultA1.balance, 110.0 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultA2.balance, 120.0 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultB1.balance, 210.0 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultB2.balance, 220.0 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultA.feeShared, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(resultA1.feeShared, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultB.feeShared, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(resultB1.feeShared, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultB.blocked, 0);
  });


  test("Complete function: Referrals owner is 1st referral of holder", () async {
    // Referral users
    User userA2 = new User(
      name: 'User A2',
      photo: 'http://image.com/userA2.jpg',
    );
    userA2.ref().setData(userA2.toJson());
    userA2.ref().updateData({'balance': 120});

    User userA1 = new User(
        name: 'User A1',
        photo: 'http://image.com/userA1.jpg',
        beneficiary1: userA2.id
    );
    userA1.ref().setData(userA1.toJson());
    // Balance should be set directly
    userA1.ref().updateData({'balance': 110});

    // Create User A
    User userA = new User(
        name: 'User A',
        photo: 'http://image.com/userA.jpg',
        beneficiary1: userA1.id,
        beneficiary2: userA2.id
    );
    userA.ref().setData(userA.toJson());
    // Balance should be set directly
    userA.ref().updateData({'balance': 10 + 25.0 / 6});

    // Create User B
    User userB = new User(
        name: 'User B',
        photo: 'http://image.com/userB.jpg',
        beneficiary1: userA.id,
        beneficiary2: userA1.id
    );
    userB.ref().setData(userB.toJson());
    userB.ref().updateData({'balance': 50 - 25.0 / 6, 'blocked': 25.0 * 1.2 - 25.0 / 6});

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
      price: 10.0,
    );
    book.ref().setData(book.toJson());

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      bookId: book.id,
      ownerId: userA.id,
      holderId: userB.id,
      transitId: userA.id,
      price: 30.00,
      transit: true,
      wish: false,
      lent: true,
    );
    record.ref().setData(record.toJson());

    // Create reward operation
    Operation rewardOp = new Operation(
        type: OperationType.Reward,
        userId: userA.id,
        amount: 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userB.id,
        bookrecordId: record.id,
        bookId: book.id,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        paid: 25.0 / 6);
    rewardOp.ref().setData(rewardOp.toJson());

    // Create leasing operation
    Operation leasingOp = new Operation(
        type: OperationType.Leasing,
        userId: userB.id,
        amount: 25.0 * 1.2 - 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userA.id,
        bookrecordId: record.id,
        bookId: book.id,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        deposit: 25.0 * 1.2 - 25.0 / 6,
        paid: 25.0 / 6);
    leasingOp.ref().setData(leasingOp.toJson());

    // Update reference to operations
    record.ref().updateData({'rewardId': rewardOp.id, 'leasingId': leasingOp.id});

    // Run complete function
    await complete(books: [record], holder: userB, owner: userA);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref().get()).data);
    User resultA = User.fromJson((await userA.ref().get()).data);
    User resultA1 = User.fromJson((await userA1.ref().get()).data);
    User resultA2 = User.fromJson((await userA2.ref().get()).data);
    User resultB = User.fromJson((await userB.ref().get()).data);
    Operation reward = Operation.fromJson((await rewardOp.ref().get()).data);
    Operation leasing = Operation.fromJson((await leasingOp.ref().get()).data);

    expect(resultRec.transit, false);
    expect(resultRec.lent, false);
    expect(resultRec.ownerId, userA.id);
    expect(resultRec.holderId, userA.id);
    expect(resultRec.transitId, null);
    expect(resultRec.users, {userA.id});
    expect(resultRec.rewardId, null);
    expect(resultRec.leasingId, null);
    expect(reward.paid, 25.0 * 83 / 183 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(reward.amount, 25.0 * 83 / 183 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(reward.userId, userA.id);
    expect(reward.peerId, userB.id);
    expect(leasing.paid, 25.0 * 83 / 183 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(leasing.deposit, 0);
    expect(leasing.amount, 25.0 * 1.2 * 83 / 183);
    expect(leasing.userId, userB.id);
    expect(leasing.peerId, userA.id);
    expect(dp(leasing.fee, 5), dp(25.0 * 0.1 * 83 / 183, 5));
    expect(leasing.ownerFeeUserId1, userA1.id);
    expect(leasing.ownerFeeUserId2, userA2.id);
    expect(leasing.payerFeeUserId1, null); // Referral fee included into reward
    expect(leasing.payerFeeUserId2, userA1.id);
    expect(leasing.ownerFee1, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(leasing.ownerFee2, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(leasing.payerFee1, 0.0);
    expect(dp(leasing.payerFee2, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultA.balance, 10.0 + 25.0 * 83 / 183 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultB.balance, 50.0 - 25.0 * 1.2 * 83 / 183);
    expect(resultA1.balance, 110.0 + 25.0 * 0.2 * 0.15 * 83 / 183 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultA2.balance, 120.0 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultA.feeShared, 25.0 * 0.2 * 0.15 * 83 / 183 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(dp(resultA1.feeShared, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultB.feeShared, 0.0);
    expect(resultB.blocked, 0.0);
  });

  test("Complete function: Referrals holder is 1st referral of owner", () async {
    // Referral users
    User userB2 = new User(
      name: 'User B2',
      photo: 'http://image.com/userB2.jpg',
    );
    userB2.ref().setData(userB2.toJson());
    userB2.ref().updateData({'balance': 120});

    User userB1 = new User(
        name: 'User B1',
        photo: 'http://image.com/userB1.jpg',
        beneficiary1: userB2.id
    );
    userB1.ref().setData(userB1.toJson());
    // Balance should be set directly
    userB1.ref().updateData({'balance': 110});

    // Create User B
    User userB = new User(
        name: 'User B',
        photo: 'http://image.com/userB.jpg',
        beneficiary1: userB1.id,
        beneficiary2: userB2.id
    );
    userB.ref().setData(userB.toJson());
    userB.ref().updateData({'balance': 50 - 25.0 / 6, 'blocked': 25.0 * 1.2 - 25.0 / 6});

    // Create User A
    User userA = new User(
        name: 'User A',
        photo: 'http://image.com/userA.jpg',
        beneficiary1: userB.id,
        beneficiary2: userB1.id
    );
    userA.ref().setData(userA.toJson());
    // Balance should be set directly
    userA.ref().updateData({'balance': 10 + 25.0 / 6});

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
      price: 10.0,
    );
    book.ref().setData(book.toJson());

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      bookId: book.id,
      ownerId: userA.id,
      holderId: userB.id,
      transitId: userA.id,
      price: 30.00,
      transit: true,
      wish: false,
      lent: true,
    );
    record.ref().setData(record.toJson());

    // Create reward operation
    Operation rewardOp = new Operation(
        type: OperationType.Reward,
        userId: userA.id,
        amount: 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userB.id,
        bookrecordId: record.id,
        bookId: book.id,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        paid: 25.0 / 6);
    rewardOp.ref().setData(rewardOp.toJson());

    // Create leasing operation
    Operation leasingOp = new Operation(
        type: OperationType.Leasing,
        userId: userB.id,
        amount: 25.0 * 1.2 - 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userA.id,
        bookrecordId: record.id,
        bookId: book.id,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        deposit: 25.0 * 1.2 - 25.0 / 6,
        paid: 25.0 / 6);
    leasingOp.ref().setData(leasingOp.toJson());

    // Update reference to operations
    record.ref().updateData({'rewardId': rewardOp.id, 'leasingId': leasingOp.id});

    // Run complete function
    await complete(books: [record], holder: userB, owner: userA);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref().get()).data);
    User resultA = User.fromJson((await userA.ref().get()).data);
    User resultB1 = User.fromJson((await userB1.ref().get()).data);
    User resultB2 = User.fromJson((await userB2.ref().get()).data);
    User resultB = User.fromJson((await userB.ref().get()).data);
    Operation reward = Operation.fromJson((await rewardOp.ref().get()).data);
    Operation leasing = Operation.fromJson((await leasingOp.ref().get()).data);

    expect(resultRec.transit, false);
    expect(resultRec.lent, false);
    expect(resultRec.ownerId, userA.id);
    expect(resultRec.holderId, userA.id);
    expect(resultRec.transitId, null);
    expect(resultRec.users, {userA.id});
    expect(resultRec.rewardId, null);
    expect(resultRec.leasingId, null);
    expect(reward.paid, 25.0 * 83 / 183);
    expect(reward.amount, 25.0 * 83 / 183);
    expect(reward.userId, userA.id);
    expect(reward.peerId, userB.id);
    expect(leasing.paid, 25.0 * 83 / 183);
    expect(leasing.deposit, 0);
    expect(leasing.amount, 25.0 * 1.2 * 83 / 183 - 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(leasing.userId, userB.id);
    expect(leasing.peerId, userA.id);
    expect(dp(leasing.fee, 5), dp(25.0 * 0.1 * 83 / 183, 5));
    expect(leasing.ownerFeeUserId1, null);
    expect(leasing.ownerFeeUserId2, userB1.id);
    expect(leasing.payerFeeUserId1, userB1.id); // Referral fee included into reward
    expect(leasing.payerFeeUserId2, userB2.id);
    expect(leasing.ownerFee1, 0.0);
    expect(dp(leasing.ownerFee2, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(leasing.payerFee1, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(leasing.payerFee2, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultA.balance, 10.0 + 25.0 * 83 / 183);
    expect(resultB.balance, 50.0 - 25.0 * 1.2 * 83 / 183 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultB1.balance, 110.0 + 25.0 * 0.2 * 0.15 * 83 / 183 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultB2.balance, 120.0 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultA.feeShared, 0.0);
    expect(dp(resultB1.feeShared, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultB.feeShared, 25.0 * 0.2 * 0.15 * 83 / 183 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultB.blocked, 0.0);
  });

  test("Complete function: Referrals owner is 2st referral of holder", () async {
    // Referral users
    User userA2 = new User(
      name: 'User A2',
      photo: 'http://image.com/userA2.jpg',
    );
    userA2.ref().setData(userA2.toJson());
    userA2.ref().updateData({'balance': 120});

    User userA1 = new User(
        name: 'User A1',
        photo: 'http://image.com/userA1.jpg',
        beneficiary1: userA2.id
    );
    userA1.ref().setData(userA1.toJson());
    // Balance should be set directly
    userA1.ref().updateData({'balance': 110});

    // Create User A
    User userA = new User(
        name: 'User A',
        photo: 'http://image.com/userA.jpg',
        beneficiary1: userA1.id,
        beneficiary2: userA2.id
    );
    userA.ref().setData(userA.toJson());
    // Balance should be set directly
    userA.ref().updateData({'balance': 10 + 25.0 / 6});

    User userB1 = new User(
        name: 'User B1',
        photo: 'http://image.com/userB1.jpg',
        beneficiary1: userA.id
    );
    userB1.ref().setData(userB1.toJson());
    // Balance should be set directly
    userB1.ref().updateData({'balance': 110});

    // Create User B
    User userB = new User(
        name: 'User B',
        photo: 'http://image.com/userB.jpg',
        beneficiary1: userB1.id,
        beneficiary2: userA.id
    );
    userB.ref().setData(userB.toJson());
    userB.ref().updateData({'balance': 50 - 25.0 / 6, 'blocked': 25.0 * 1.2 - 25.0 / 6});

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
      price: 10.0,
    );
    book.ref().setData(book.toJson());

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      bookId: book.id,
      ownerId: userA.id,
      holderId: userB.id,
      transitId: userA.id,
      price: 30.00,
      transit: true,
      wish: false,
      lent: true,
    );
    record.ref().setData(record.toJson());

    // Create reward operation
    Operation rewardOp = new Operation(
        type: OperationType.Reward,
        userId: userA.id,
        amount: 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userB.id,
        bookrecordId: record.id,
        bookId: book.id,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        paid: 25.0 / 6);
    rewardOp.ref().setData(rewardOp.toJson());

    // Create leasing operation
    Operation leasingOp = new Operation(
        type: OperationType.Leasing,
        userId: userB.id,
        amount: 25.0 * 1.2 - 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userA.id,
        bookrecordId: record.id,
        bookId: book.id,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        deposit: 25.0 * 1.2 - 25.0 / 6,
        paid: 25.0 / 6);
    leasingOp.ref().setData(leasingOp.toJson());

    // Update reference to operations
    record.ref().updateData({'rewardId': rewardOp.id, 'leasingId': leasingOp.id});

    // Run complete function
    await complete(books: [record], holder: userB, owner: userA);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref().get()).data);
    User resultA = User.fromJson((await userA.ref().get()).data);
    User resultA1 = User.fromJson((await userA1.ref().get()).data);
    User resultA2 = User.fromJson((await userA2.ref().get()).data);
    User resultB = User.fromJson((await userB.ref().get()).data);
    User resultB1 = User.fromJson((await userB1.ref().get()).data);
    Operation reward = Operation.fromJson((await rewardOp.ref().get()).data);
    Operation leasing = Operation.fromJson((await leasingOp.ref().get()).data);

    expect(resultRec.transit, false);
    expect(resultRec.lent, false);
    expect(resultRec.ownerId, userA.id);
    expect(resultRec.holderId, userA.id);
    expect(resultRec.transitId, null);
    expect(resultRec.users, {userA.id});
    expect(resultRec.rewardId, null);
    expect(resultRec.leasingId, null);
    expect(reward.paid, 25.0 * 83 / 183 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(reward.amount, 25.0 * 83 / 183 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(reward.userId, userA.id);
    expect(reward.peerId, userB.id);
    expect(leasing.paid, 25.0 * 83 / 183 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(leasing.deposit, 0);
    expect(leasing.amount, 25.0 * 1.2 * 83 / 183);
    expect(leasing.userId, userB.id);
    expect(leasing.peerId, userA.id);
    expect(dp(leasing.fee, 5), dp(25.0 * 0.1 * 83 / 183, 5));
    expect(leasing.ownerFeeUserId1, userA1.id);
    expect(leasing.ownerFeeUserId2, userA2.id);
    expect(leasing.payerFeeUserId1, userB1.id); // Referral fee included into reward
    expect(leasing.payerFeeUserId2, null);
    expect(leasing.ownerFee1, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(leasing.ownerFee2, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(leasing.payerFee1, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(leasing.payerFee2, 0.0);
    expect(dp(resultA.balance, 5), dp(10.0 + 25.0 * 83 / 183 + 25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultB.balance, 50.0 - 25.0 * 1.2 * 83 / 183);
    expect(resultA1.balance, 110.0 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultA2.balance, 120.0 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultB1.balance, 110.0 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultA.feeShared, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(resultA1.feeShared, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultB1.feeShared, 0.0);
    expect(resultB.feeShared, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultB.blocked, 0.0);
  });

  test("Complete function: Referrals holder is 2st referral of owner", () async {
    // Referral users
    User userB2 = new User(
      name: 'User B2',
      photo: 'http://image.com/userB2.jpg',
    );
    userB2.ref().setData(userB2.toJson());
    userB2.ref().updateData({'balance': 120});

    User userB1 = new User(
        name: 'User B1',
        photo: 'http://image.com/userB1.jpg',
        beneficiary1: userB2.id
    );
    userB1.ref().setData(userB1.toJson());
    // Balance should be set directly
    userB1.ref().updateData({'balance': 110});

    // Create User B
    User userB = new User(
        name: 'User B',
        photo: 'http://image.com/userB.jpg',
        beneficiary1: userB1.id,
        beneficiary2: userB2.id
    );
    userB.ref().setData(userB.toJson());
    userB.ref().updateData({'balance': 50 - 25.0 / 6, 'blocked': 25.0 * 1.2 - 25.0 / 6});

    User userA1 = new User(
        name: 'User A1',
        photo: 'http://image.com/userA1.jpg',
        beneficiary1: userB.id
    );
    userA1.ref().setData(userA1.toJson());
    // Balance should be set directly
    userA1.ref().updateData({'balance': 110});

    // Create User A
    User userA = new User(
        name: 'User A',
        photo: 'http://image.com/userA.jpg',
        beneficiary1: userA1.id,
        beneficiary2: userB.id
    );
    userA.ref().setData(userA.toJson());
    // Balance should be set directly
    userA.ref().updateData({'balance': 10 + 25.0 / 6});

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
      price: 10.0,
    );
    book.ref().setData(book.toJson());

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      bookId: book.id,
      ownerId: userA.id,
      holderId: userB.id,
      transitId: userA.id,
      price: 30.00,
      transit: true,
      wish: false,
      lent: true,
    );
    record.ref().setData(record.toJson());

    // Create reward operation
    Operation rewardOp = new Operation(
        type: OperationType.Reward,
        userId: userA.id,
        amount: 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userB.id,
        bookrecordId: record.id,
        bookId: book.id,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        paid: 25.0 / 6);
    rewardOp.ref().setData(rewardOp.toJson());

    // Create leasing operation
    Operation leasingOp = new Operation(
        type: OperationType.Leasing,
        userId: userB.id,
        amount: 25.0 * 1.2 - 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userA.id,
        bookrecordId: record.id,
        bookId: book.id,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        deposit: 25.0 * 1.2 - 25.0 / 6,
        paid: 25.0 / 6);
    leasingOp.ref().setData(leasingOp.toJson());

    // Update reference to operations
    record.ref().updateData({'rewardId': rewardOp.id, 'leasingId': leasingOp.id});

    // Run complete function
    await complete(books: [record], holder: userB, owner: userA);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref().get()).data);
    User resultA = User.fromJson((await userA.ref().get()).data);
    User resultA1 = User.fromJson((await userA1.ref().get()).data);
    User resultB1 = User.fromJson((await userB1.ref().get()).data);
    User resultB2 = User.fromJson((await userB2.ref().get()).data);
    User resultB = User.fromJson((await userB.ref().get()).data);
    Operation reward = Operation.fromJson((await rewardOp.ref().get()).data);
    Operation leasing = Operation.fromJson((await leasingOp.ref().get()).data);

    expect(resultRec.transit, false);
    expect(resultRec.lent, false);
    expect(resultRec.ownerId, userA.id);
    expect(resultRec.holderId, userA.id);
    expect(resultRec.transitId, null);
    expect(resultRec.users, {userA.id});
    expect(resultRec.rewardId, null);
    expect(resultRec.leasingId, null);
    expect(reward.paid, 25.0 * 83 / 183);
    expect(reward.amount, 25.0 * 83 / 183);
    expect(reward.userId, userA.id);
    expect(reward.peerId, userB.id);
    expect(leasing.paid, 25.0 * 83 / 183);
    expect(leasing.deposit, 0);
    expect(leasing.amount, 25.0 * 1.2 * 83 / 183 - 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(leasing.userId, userB.id);
    expect(leasing.peerId, userA.id);
    expect(dp(leasing.fee, 5), dp(25.0 * 0.1 * 83 / 183, 5));
    expect(leasing.ownerFeeUserId1, userA1.id);
    expect(leasing.ownerFeeUserId2, null);
    expect(leasing.payerFeeUserId1, userB1.id); // Referral fee included into reward
    expect(leasing.payerFeeUserId2, userB2.id);
    expect(leasing.ownerFee1, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(leasing.ownerFee2, 0.0);
    expect(leasing.payerFee1, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(leasing.payerFee2, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultA.balance, 10.0 + 25.0 * 83 / 183);
    expect(resultB.balance, 50.0 - 25.0 * 1.2 * 83 / 183 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultB1.balance, 110.0 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultB2.balance, 120.0 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultA.feeShared, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultA1.feeShared, 0.0);
    expect(resultB.feeShared, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(resultB1.feeShared, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultB2.feeShared, 0.0);
    expect(resultB.blocked, 0.0);
  });

  test("Payment function: In-app-purchase payment", () async {
    // Create User A
    User userA = new User(
      name: 'User A',
      photo: 'http://image.com/userA.jpg',
    );
    userA.ref().setData(userA.toJson());
    // Balance should be set directly
    userA.ref().updateData({'balance': 25});

    // Run payment function
    Operation op = await payment(user: userA, amount: 50.0, type: OperationType.InputInApp);

    Operation opResult = Operation.fromJson((await op.ref().get()).data);
    User resultA = User.fromJson((await userA.ref().get()).data);

    expect(opResult.type, OperationType.InputInApp);
    expect(opResult.amount, 50.0);
    expect(opResult.userId, userA.id);
    expect(resultA.balance, 25.0  + 50.0);
  });

}