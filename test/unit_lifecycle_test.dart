import 'package:flutter_test/flutter_test.dart';
import 'package:biblosphere/mock_firestore.dart';
import 'package:biblosphere/const.dart';
import 'package:biblosphere/helpers.dart';
import 'package:biblosphere/lifecycle.dart';
import 'package:geolocator/geolocator.dart';

main() {
  db = MockFirestore.instance;
  analytics = MockFirebaseAnalytics();
  //when(analytics.logEvent(name: anyNamed('name'), parameters: anyNamed('parameters'))).thenAnswer((_) async {return;});

  test("Deposit function: give book A to B", () async {
    // Create User A
    User userA = new User(
      name: 'User A',
      photo: 'http://image.com/userA.jpg',
    );
    userA.ref.setData(userA.toJson());
    // Balance should be set in wallet
    Wallet walletA = new Wallet(id: userA.id, balance: 10.0);
    walletA.ref.setData(walletA.toJson());

    // Create User B
    User userB = new User(
      name: 'User B',
      photo: 'http://image.com/userB.jpg',
    );
    userB.ref.setData(userB.toJson());
    Wallet walletB = new Wallet(id: userB.id, balance: 50.0);
    walletB.ref.setData(walletB.toJson());

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
      price: 10.0,
    );
    book.ref.setData(book.toJson());

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      isbn: book.isbn,
      ownerId: userA.id,
      holderId: userA.id,
      transitId: userB.id,
      price: 25.00,
      transit: true,
      confirmed: true,
      wish: false,
      lent: false,
    );
    record.ref.setData(record.toJson());

    // Run deposit function
    await deposit(books: [record], owner: userA, payer: userB);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref.get()).data);
    User resultA = User.fromJson((await userA.ref.get()).data);
    User resultB = User.fromJson((await userB.ref.get()).data);
    Wallet resultWA = Wallet.fromJson((await Wallet.Ref(userA.id).get()).data);
    Wallet resultWB = Wallet.fromJson((await Wallet.Ref(userB.id).get()).data);

    expect(resultRec.rewardId, (s) => s != null);
    expect(resultRec.leasingId, (s) => s != null);

    Operation reward = Operation.fromJson(
        (await Operation.Ref(resultRec.rewardId).get()).data);
    Operation leasing = Operation.fromJson(
        (await Operation.Ref(resultRec.leasingId).get()).data);

    expect(resultRec.transit, false);
    expect(resultRec.lent, true);
    expect(resultA.id, userA.id);
    expect(resultB.id, userB.id);
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
    expect(resultWA.id, userA.id);
    expect(resultWB.id, userB.id);
    expect(resultWA.balance, 10.0 + 25.0 / 6);
    expect(resultWA.blocked, 0.0);
    expect(resultWB.balance, 50.0 - 25.0 / 6);
    expect(resultWB.blocked, 25.0 * 1.2 - 25.0 / 6);
  });

  test("Complete function: return book B to A", () async {
    // Create User A
    User userA = new User(
      name: 'User A',
      photo: 'http://image.com/userA.jpg',
    );
    userA.ref.setData(userA.toJson());
    Wallet walletA = new Wallet(id: userA.id, balance: 10 + 25.0 / 6);
    walletA.ref.setData(walletA.toJson());

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
    Wallet walletB = new Wallet(
        id: userB.id, balance: 50 - 25.0 / 6, blocked: 25.0 * 1.2 - 25.0 / 6);
    walletB.ref.setData(walletB.toJson());

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
      price: 10.0,
    );
    book.ref.setData(book.toJson());

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      isbn: book.isbn,
      ownerId: userA.id,
      holderId: userB.id,
      transitId: userA.id,
      price: 30.00, // Price different from original price 25 (ignored)
      transit: true,
      confirmed: true,
      wish: false,
      lent: true,
    );
    record.ref.setData(record.toJson());

    // Create reward operation
    Operation rewardOp = new Operation(
        type: OperationType.Reward,
        userId: userA.id,
        amount: 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userB.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        paid: 25.0 / 6);
    rewardOp.ref.setData(rewardOp.toJson());

    // Create leasing operation
    Operation leasingOp = new Operation(
        type: OperationType.Leasing,
        userId: userB.id,
        amount: 25.0 * 1.2 - 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userA.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        deposit: 25.0 * 1.2 - 25.0 / 6,
        paid: 25.0 / 6);
    leasingOp.ref.setData(leasingOp.toJson());

    // Update reference to operations
    record
        .ref
        .updateData({'rewardId': rewardOp.id, 'leasingId': leasingOp.id});

    // Run complete function
    await complete(books: [record], holder: userB, owner: userA);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref.get()).data);
    User resultA = User.fromJson((await userA.ref.get()).data);
    User resultB = User.fromJson((await userB.ref.get()).data);
    Wallet resultWA = Wallet.fromJson((await Wallet.Ref(userA.id).get()).data);
    Wallet resultWB = Wallet.fromJson((await Wallet.Ref(userB.id).get()).data);
    Operation reward = Operation.fromJson((await rewardOp.ref.get()).data);
    Operation leasing = Operation.fromJson((await leasingOp.ref.get()).data);

    expect(resultRec.transit, false);
    expect(resultRec.lent, false);
    expect(resultA.id, userA.id);
    expect(resultB.id, userB.id);
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
    expect(resultWA.balance, 10.0 + 25.0 * 83 / 183);
    expect(resultWA.blocked, 0);
    expect(resultWB.balance, 50.0 - 25.0 * 1.2 * 83 / 183);
    expect(resultWB.blocked, 0);
  });

  test("Pass function: pass book B to C", () async {
    // Create User A
    User userA = new User(
      name: 'User A',
      photo: 'http://image.com/userA.jpg',
    );
    userA.ref.setData(userA.toJson());
    // Balance should be set directly
    Wallet walletA = new Wallet(id: userA.id, balance: 10 + 25.0 / 6);
    walletA.ref.setData(walletA.toJson());

    // Create User B
    User userB = new User(
      name: 'User B',
      photo: 'http://image.com/userB.jpg',
    );
    userB.ref.setData(userB.toJson());
    Wallet walletB = new Wallet(
        id: userB.id, balance: 50 - 25.0 / 6, blocked: 25.0 * 1.2 - 25.0 / 6);
    walletB.ref.setData(walletB.toJson());

    // Create User C
    User userC = new User(
      name: 'User C',
      photo: 'http://image.com/userC.jpg',
    );
    userC.ref.setData(userC.toJson());
    Wallet walletC = new Wallet(id: userC.id, balance: 100);
    walletC.ref.setData(walletC.toJson());

    B.user = userC;
    B.locality = 'Bakuriani';
    B.country = 'GE';
    B.position = Position(latitude: 41.7510, longitude: 43.5292); 

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
      price: 10.0,
    );
    book.ref.setData(book.toJson());

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      isbn: book.isbn,
      ownerId: userA.id,
      holderId: userB.id,
      transitId: userC.id,
      price: 30.00,
      transit: true,
      confirmed: true,
      wish: false,
      lent: true,
    );
    record.ref.setData(record.toJson());

    // Create reward operation
    Operation rewardOp = new Operation(
        type: OperationType.Reward,
        userId: userA.id,
        amount: 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userB.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        paid: 25.0 / 6);
    rewardOp.ref.setData(rewardOp.toJson());

    // Create leasing operation
    Operation leasingOp = new Operation(
        type: OperationType.Leasing,
        userId: userB.id,
        amount: 25.0 * 1.2 - 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userA.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        deposit: 25.0 * 1.2 - 25.0 / 6,
        paid: 25.0 / 6);
    leasingOp.ref.setData(leasingOp.toJson());

    // Update reference to operations
    record
        .ref
        .updateData({'rewardId': rewardOp.id, 'leasingId': leasingOp.id});

    // Run complete function
    await pass(books: [record], holder: userB, payer: userC);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref.get()).data);
    User resultA = User.fromJson((await userA.ref.get()).data);
    User resultB = User.fromJson((await userB.ref.get()).data);
    User resultC = User.fromJson((await userC.ref.get()).data);
    Wallet resultWA = Wallet.fromJson((await Wallet.Ref(userA.id).get()).data);
    Wallet resultWB = Wallet.fromJson((await Wallet.Ref(userB.id).get()).data);
    Wallet resultWC = Wallet.fromJson((await Wallet.Ref(userC.id).get()).data);
    Operation rewardOld = Operation.fromJson((await rewardOp.ref.get()).data);
    Operation leasingOld =
        Operation.fromJson((await leasingOp.ref.get()).data);

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
    expect(dp(resultWA.balance, 5), dp(10.0 + 25.0 * 83 / 183 + 25.0 / 6, 5));
    expect(resultWB.balance, 50.0 - 25.0 * 1.2 * 83 / 183);
    expect(resultWB.blocked, 0);
    expect(resultWC.balance, 100.0 - 25.0 / 6);
    expect(resultWC.blocked, 25 * 1.2 - 25.0 / 6);
    expect(resultA.id, userA.id);
    expect(resultB.id, userB.id);
    expect(resultC.id, userC.id);
  });

  test("Pass function: pass book B to C then to D", () async {
    // Create User A
    User userA = new User(
      name: 'User A',
      photo: 'http://image.com/userA.jpg',
    );
    userA.ref.setData(userA.toJson());
    // Balance should be set directly
    Wallet walletA = new Wallet(id: userA.id, balance: 10 + 25.0 / 6);
    walletA.ref.setData(walletA.toJson());

    // Create User B
    User userB = new User(
      name: 'User B',
      photo: 'http://image.com/userB.jpg',
    );
    userB.ref.setData(userB.toJson());
    Wallet walletB = new Wallet(
        id: userB.id, balance: 50 - 25.0 / 6, blocked: 25.0 * 1.2 - 25.0 / 6);
    walletB.ref.setData(walletB.toJson());

    // Create User C
    User userC = new User(
      name: 'User C',
      photo: 'http://image.com/userC.jpg',
    );
    userC.ref.setData(userC.toJson());
    Wallet walletC = new Wallet(id: userC.id, balance: 100);
    walletC.ref.setData(walletC.toJson());

    B.user = userC;
    B.locality = 'Bakuriani';
    B.country = 'GE';
    B.position = Position(latitude: 41.7510, longitude: 43.5292); 

    // Create User D
    User userD = new User(
      name: 'User D',
      photo: 'http://image.com/userD.jpg',
    );
    userD.ref.setData(userD.toJson());
    Wallet walletD = new Wallet(id: userD.id, balance: 150);
    walletD.ref.setData(walletD.toJson());

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
      price: 10.0,
    );
    book.ref.setData(book.toJson());

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      isbn: book.isbn,
      ownerId: userA.id,
      holderId: userB.id,
      transitId: userC.id,
      price: 30.00,
      transit: true,
      confirmed: true,
      wish: false,
      lent: true,
    );
    record.ref.setData(record.toJson());

    // Create reward operation
    Operation rewardOp = new Operation(
        type: OperationType.Reward,
        userId: userA.id,
        amount: 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userB.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        paid: 25.0 / 6);
    rewardOp.ref.setData(rewardOp.toJson());

    // Create leasing operation
    Operation leasingOp = new Operation(
        type: OperationType.Leasing,
        userId: userB.id,
        amount: 25.0 * 1.2 - 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userA.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        deposit: 25.0 * 1.2 - 25.0 / 6,
        paid: 25.0 / 6);
    leasingOp.ref.setData(leasingOp.toJson());

    // Update reference to operations
    record
        .ref
        .updateData({'rewardId': rewardOp.id, 'leasingId': leasingOp.id});

    // Run complete function to pass B to C
    await pass(books: [record], holder: userB, payer: userC);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref.get()).data);
    User resultA = User.fromJson((await userA.ref.get()).data);
    User resultB = User.fromJson((await userB.ref.get()).data);
    User resultC = User.fromJson((await userC.ref.get()).data);
    Wallet resultWA = Wallet.fromJson((await Wallet.Ref(userA.id).get()).data);
    Wallet resultWB = Wallet.fromJson((await Wallet.Ref(userB.id).get()).data);
    Wallet resultWC = Wallet.fromJson((await Wallet.Ref(userC.id).get()).data);
    Operation rewardOld = Operation.fromJson((await rewardOp.ref.get()).data);
    Operation leasingOld =
        Operation.fromJson((await leasingOp.ref.get()).data);

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
    expect(dp(resultWA.balance, 5), dp(10.0 + 25.0 * 83 / 183 + 25.0 / 6, 5));
    expect(resultWB.balance, 50.0 - 25.0 * 1.2 * 83 / 183);
    expect(resultWB.blocked, 0);
    expect(resultWC.balance, 100.0 - 25.0 / 6);
    expect(resultWC.blocked, 25 * 1.2 - 25.0 / 6);
    expect(resultA.id, userA.id);
    expect(resultB.id, userB.id);
    expect(resultC.id, userC.id);

    // Transit to User D
    record.ref.updateData({'transit': true, 'confirmed': true, 'transitId': userD.id});
    B.user = userD;

    // Run complete function to pass B to C
    await pass(books: [record], holder: userC, payer: userD);

    resultRec = Bookrecord.fromJson((await record.ref.get()).data);
    resultA = User.fromJson((await userA.ref.get()).data);
    resultC = User.fromJson((await userC.ref.get()).data);
    User resultD = User.fromJson((await userD.ref.get()).data);
    resultWA = Wallet.fromJson((await Wallet.Ref(userA.id).get()).data);
    resultWC = Wallet.fromJson((await Wallet.Ref(userC.id).get()).data);
    Wallet resultWD = Wallet.fromJson((await Wallet.Ref(userD.id).get()).data);
    rewardOld = Operation.fromJson((await rewardOp.ref.get()).data);
    leasingOld = Operation.fromJson((await leasingNew.ref.get()).data);

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
    expect(rewardOld.paid, 25.0 * 83 / 183 + 25.0 / 6 + 25.0 / 6);
    expect(rewardOld.amount, 25.0 * 83 / 183 + 25.0 / 6 + 25.0 / 6);
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
    expect(dp(resultWA.balance, 5),
        dp(10.0 + 25.0 * 83 / 183 + 25.0 / 6 + 25.0 / 6, 5));
    expect(resultWC.balance, 100.0 - 25.0 / 6 * 1.2);
    expect(resultWC.blocked, 0.0);
    expect(resultWD.balance, 150.0 - 25.0 / 6);
    expect(resultWD.blocked, 25.0 * 1.2 - 25.0 / 6);
    expect(resultD.id, userD.id);
  });

  test("Pass & Complete functions: pass book B to C then return", () async {
    // Create User A
    User userA = new User(
      name: 'User A',
      photo: 'http://image.com/userA.jpg',
    );
    userA.ref.setData(userA.toJson());
    // Balance should be set directly
    Wallet walletA = new Wallet(id: userA.id, balance: 10 + 25.0 / 6);
    walletA.ref.setData(walletA.toJson());

    // Create User B
    User userB = new User(
      name: 'User B',
      photo: 'http://image.com/userB.jpg',
    );
    userB.ref.setData(userB.toJson());
    Wallet walletB = new Wallet(
        id: userB.id, balance: 50 - 25.0 / 6, blocked: 25.0 * 1.2 - 25.0 / 6);
    walletB.ref.setData(walletB.toJson());

    // Create User C
    User userC = new User(
      name: 'User C',
      photo: 'http://image.com/userC.jpg',
    );
    userC.ref.setData(userC.toJson());
    Wallet walletC = new Wallet(id: userC.id, balance: 100);
    walletC.ref.setData(walletC.toJson());

    B.user = userC;
    B.locality = 'Bakuriani';
    B.country = 'GE';
    B.position = Position(latitude: 41.7510, longitude: 43.5292); 

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
      price: 10.0,
    );
    book.ref.setData(book.toJson());

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      isbn: book.isbn,
      ownerId: userA.id,
      holderId: userB.id,
      transitId: userC.id,
      price: 30.00,
      transit: true,
      confirmed: true,
      wish: false,
      lent: true,
    );
    record.ref.setData(record.toJson());

    // Create reward operation
    Operation rewardOp = new Operation(
        type: OperationType.Reward,
        userId: userA.id,
        amount: 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userB.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        paid: 25.0 / 6);
    rewardOp.ref.setData(rewardOp.toJson());

    // Create leasing operation
    Operation leasingOp = new Operation(
        type: OperationType.Leasing,
        userId: userB.id,
        amount: 25.0 * 1.2 - 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userA.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        deposit: 25.0 * 1.2 - 25.0 / 6,
        paid: 25.0 / 6);
    leasingOp.ref.setData(leasingOp.toJson());

    // Update reference to operations
    record
        .ref
        .updateData({'rewardId': rewardOp.id, 'leasingId': leasingOp.id});

    // Run complete function to pass B to C
    await pass(books: [record], holder: userB, payer: userC);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref.get()).data);
    User resultA = User.fromJson((await userA.ref.get()).data);
    User resultB = User.fromJson((await userB.ref.get()).data);
    User resultC = User.fromJson((await userC.ref.get()).data);
    Wallet resultWA = Wallet.fromJson((await Wallet.Ref(userA.id).get()).data);
    Wallet resultWB = Wallet.fromJson((await Wallet.Ref(userB.id).get()).data);
    Wallet resultWC = Wallet.fromJson((await Wallet.Ref(userC.id).get()).data);
    Operation rewardOld = Operation.fromJson((await rewardOp.ref.get()).data);
    Operation leasingOld =
        Operation.fromJson((await leasingOp.ref.get()).data);

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
    expect(dp(resultWA.balance, 5), dp(10.0 + 25.0 * 83 / 183 + 25.0 / 6, 5));
    expect(resultWB.balance, 50.0 - 25.0 * 1.2 * 83 / 183);
    expect(resultWB.blocked, 0);
    expect(resultWC.balance, 100.0 - 25.0 / 6);
    expect(resultWC.blocked, 25 * 1.2 - 25.0 / 6);
    expect(resultA.id, userA.id);
    expect(resultB.id, userB.id);
    expect(resultC.id, userC.id);

    // Transit to User A
    record.ref.updateData({'transit': true, 'confirmed': true, 'transitId': userA.id});
    B.user = userA;

    // Run complete function to pass B to C
    await complete(books: [record], holder: userC, owner: userA);

    resultRec = Bookrecord.fromJson((await record.ref.get()).data);
    resultA = User.fromJson((await userA.ref.get()).data);
    resultC = User.fromJson((await userC.ref.get()).data);
    resultWA = Wallet.fromJson((await Wallet.Ref(userA.id).get()).data);
    resultWC = Wallet.fromJson((await Wallet.Ref(userC.id).get()).data);
    rewardOld = Operation.fromJson((await rewardOp.ref.get()).data);
    leasingOld = Operation.fromJson((await leasingNew.ref.get()).data);

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
    expect(dp(resultWA.balance, 5), dp(10.0 + 25.0 * 83 / 183 + 25.0 / 6, 5));
    expect(resultWC.balance, 100.0 - 25.0 / 6 * 1.2);
    expect(resultWC.blocked, 0.0);
  });

  test("Complete function: Referrals", () async {
    // Referral users
    User userA2 = new User(
      name: 'User A2',
      photo: 'http://image.com/userA2.jpg',
    );
    userA2.ref.setData(userA2.toJson());
    Wallet walletA2 = new Wallet(id: userA2.id, balance: 120);
    walletA2.ref.setData(walletA2.toJson());

    User userA1 = new User(
        name: 'User A1',
        photo: 'http://image.com/userA1.jpg',
        beneficiary1: userA2.id);
    userA1.ref.setData(userA1.toJson());
    // Balance should be set directly
    Wallet walletA1 = new Wallet(id: userA1.id, balance: 110);
    walletA1.ref.setData(walletA1.toJson());

    User userB2 = new User(
      name: 'User B2',
      photo: 'http://image.com/userB2.jpg',
    );
    userB2.ref.setData(userB2.toJson());
    Wallet walletB2 = new Wallet(id: userB2.id, balance: 220);
    walletB2.ref.setData(walletB2.toJson());

    User userB1 = new User(
        name: 'User B1',
        photo: 'http://image.com/userB1.jpg',
        beneficiary1: userB2.id);
    userB1.ref.setData(userB1.toJson());
    // Balance should be set directly
    Wallet walletB1 = new Wallet(id: userB1.id, balance: 210);
    walletB1.ref.setData(walletB1.toJson());

    // Create User A
    User userA = new User(
        name: 'User A',
        photo: 'http://image.com/userA.jpg',
        beneficiary1: userA1.id,
        beneficiary2: userA2.id);
    userA.ref.setData(userA.toJson());
    // Balance should be set directly
    Wallet walletA = new Wallet(id: userA.id, balance: 10 + 25.0 / 6);
    walletA.ref.setData(walletA.toJson());

    B.user = userA;
    B.locality = 'Bakuriani';
    B.country = 'GE';
    B.position = Position(latitude: 41.7510, longitude: 43.5292); 

    // Create User B
    User userB = new User(
        name: 'User B',
        photo: 'http://image.com/userB.jpg',
        beneficiary1: userB1.id,
        beneficiary2: userB2.id);
    userB.ref.setData(userB.toJson());
    Wallet walletB = new Wallet(
        id: userB.id, balance: 50 - 25.0 / 6, blocked: 25.0 * 1.2 - 25.0 / 6);
    walletB.ref.setData(walletB.toJson());

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
      price: 10.0,
    );
    book.ref.setData(book.toJson());

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      isbn: book.isbn,
      ownerId: userA.id,
      holderId: userB.id,
      transitId: userA.id,
      price: 30.00,
      transit: true,
      confirmed: true,
      wish: false,
      lent: true,
    );
    record.ref.setData(record.toJson());

    // Create reward operation
    Operation rewardOp = new Operation(
        type: OperationType.Reward,
        userId: userA.id,
        amount: 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userB.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        paid: 25.0 / 6);
    rewardOp.ref.setData(rewardOp.toJson());

    // Create leasing operation
    Operation leasingOp = new Operation(
        type: OperationType.Leasing,
        userId: userB.id,
        amount: 25.0 * 1.2 - 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userA.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        deposit: 25.0 * 1.2 - 25.0 / 6,
        paid: 25.0 / 6);
    leasingOp.ref.setData(leasingOp.toJson());

    // Update reference to operations
    record
        .ref
        .updateData({'rewardId': rewardOp.id, 'leasingId': leasingOp.id});

    // Run complete function
    await complete(books: [record], holder: userB, owner: userA);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref.get()).data);
    User resultA = User.fromJson((await userA.ref.get()).data);
    User resultA1 = User.fromJson((await userA1.ref.get()).data);
    User resultA2 = User.fromJson((await userA2.ref.get()).data);
    User resultB = User.fromJson((await userB.ref.get()).data);
    User resultB1 = User.fromJson((await userB1.ref.get()).data);
    User resultB2 = User.fromJson((await userB2.ref.get()).data);
    Wallet resultWA = Wallet.fromJson((await Wallet.Ref(userA.id).get()).data);
    Wallet resultWA1 =
        Wallet.fromJson((await Wallet.Ref(userA1.id).get()).data);
    Wallet resultWA2 =
        Wallet.fromJson((await Wallet.Ref(userA2.id).get()).data);
    Wallet resultWB = Wallet.fromJson((await Wallet.Ref(userB.id).get()).data);
    Wallet resultWB1 =
        Wallet.fromJson((await Wallet.Ref(userB1.id).get()).data);
    Wallet resultWB2 =
        Wallet.fromJson((await Wallet.Ref(userB2.id).get()).data);
    Operation reward = Operation.fromJson((await rewardOp.ref.get()).data);
    Operation leasing = Operation.fromJson((await leasingOp.ref.get()).data);

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
    expect(resultA.feeShared, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(resultA1.feeShared, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultB.feeShared, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(resultB1.feeShared, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultWA.balance, 10.0 + 25.0 * 83 / 183);
    expect(resultWB.balance, 50.0 - 25.0 * 1.2 * 83 / 183);
    expect(resultWA1.balance, 110.0 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultWA2.balance, 120.0 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultWB1.balance, 210.0 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultWB2.balance, 220.0 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultWB.blocked, 0);
    expect(resultA2.id, userA2.id);
    expect(resultB2.id, userB2.id);
  });

  test("Complete function: Referrals owner is 1st referral of holder",
      () async {
    // Referral users
    User userA2 = new User(
      name: 'User A2',
      photo: 'http://image.com/userA2.jpg',
    );
    userA2.ref.setData(userA2.toJson());
    Wallet walletA2 = new Wallet(id: userA2.id, balance: 120);
    walletA2.ref.setData(walletA2.toJson());

    User userA1 = new User(
        name: 'User A1',
        photo: 'http://image.com/userA1.jpg',
        beneficiary1: userA2.id);
    userA1.ref.setData(userA1.toJson());
    // Balance should be set directly
    Wallet walletA1 = new Wallet(id: userA1.id, balance: 110);
    walletA1.ref.setData(walletA1.toJson());

    // Create User A
    User userA = new User(
        name: 'User A',
        photo: 'http://image.com/userA.jpg',
        beneficiary1: userA1.id,
        beneficiary2: userA2.id);
    userA.ref.setData(userA.toJson());
    // Balance should be set directly
    Wallet walletA = new Wallet(id: userA.id, balance: 10 + 25.0 / 6);
    walletA.ref.setData(walletA.toJson());

    B.user = userA;
    B.locality = 'Bakuriani';
    B.country = 'GE';
    B.position = Position(latitude: 41.7510, longitude: 43.5292); 

    // Create User B
    User userB = new User(
        name: 'User B',
        photo: 'http://image.com/userB.jpg',
        beneficiary1: userA.id,
        beneficiary2: userA1.id);
    userB.ref.setData(userB.toJson());
    Wallet walletB = new Wallet(
        id: userB.id, balance: 50 - 25.0 / 6, blocked: 25.0 * 1.2 - 25.0 / 6);
    walletB.ref.setData(walletB.toJson());

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
      price: 10.0,
    );
    book.ref.setData(book.toJson());

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      isbn: book.isbn,
      ownerId: userA.id,
      holderId: userB.id,
      transitId: userA.id,
      price: 30.00,
      transit: true,
      confirmed: true,
      wish: false,
      lent: true,
    );
    record.ref.setData(record.toJson());

    // Create reward operation
    Operation rewardOp = new Operation(
        type: OperationType.Reward,
        userId: userA.id,
        amount: 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userB.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        paid: 25.0 / 6);
    rewardOp.ref.setData(rewardOp.toJson());

    // Create leasing operation
    Operation leasingOp = new Operation(
        type: OperationType.Leasing,
        userId: userB.id,
        amount: 25.0 * 1.2 - 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userA.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        deposit: 25.0 * 1.2 - 25.0 / 6,
        paid: 25.0 / 6);
    leasingOp.ref.setData(leasingOp.toJson());

    // Update reference to operations
    record
        .ref
        .updateData({'rewardId': rewardOp.id, 'leasingId': leasingOp.id});

    // Run complete function
    await complete(books: [record], holder: userB, owner: userA);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref.get()).data);
    User resultA = User.fromJson((await userA.ref.get()).data);
    User resultA1 = User.fromJson((await userA1.ref.get()).data);
    User resultA2 = User.fromJson((await userA2.ref.get()).data);
    User resultB = User.fromJson((await userB.ref.get()).data);
    Wallet resultWA = Wallet.fromJson((await Wallet.Ref(userA.id).get()).data);
    Wallet resultWA1 =
        Wallet.fromJson((await Wallet.Ref(userA1.id).get()).data);
    Wallet resultWA2 =
        Wallet.fromJson((await Wallet.Ref(userA2.id).get()).data);
    Wallet resultWB = Wallet.fromJson((await Wallet.Ref(userB.id).get()).data);
    Operation reward = Operation.fromJson((await rewardOp.ref.get()).data);
    Operation leasing = Operation.fromJson((await leasingOp.ref.get()).data);

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
    expect(resultA.feeShared,
        25.0 * 0.2 * 0.15 * 83 / 183 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(dp(resultA1.feeShared, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultB.feeShared, 0.0);
    expect(resultWA.balance,
        10.0 + 25.0 * 83 / 183 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultWB.balance, 50.0 - 25.0 * 1.2 * 83 / 183);
    expect(resultWA1.balance,
        110.0 + 25.0 * 0.2 * 0.15 * 83 / 183 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultWA2.balance, 120.0 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultWB.blocked, 0.0);
    expect(resultA2.id, userA2.id);
  });

  test("Complete function: Referrals holder is 1st referral of owner",
      () async {
    // Referral users
    User userB2 = new User(
      name: 'User B2',
      photo: 'http://image.com/userB2.jpg',
    );
    userB2.ref.setData(userB2.toJson());
    Wallet walletB2 = new Wallet(id: userB2.id, balance: 120);
    walletB2.ref.setData(walletB2.toJson());

    User userB1 = new User(
        name: 'User B1',
        photo: 'http://image.com/userB1.jpg',
        beneficiary1: userB2.id);
    userB1.ref.setData(userB1.toJson());
    // Balance should be set directly
    Wallet walletB1 = new Wallet(id: userB1.id, balance: 110);
    walletB1.ref.setData(walletB1.toJson());

    // Create User B
    User userB = new User(
        name: 'User B',
        photo: 'http://image.com/userB.jpg',
        beneficiary1: userB1.id,
        beneficiary2: userB2.id);
    userB.ref.setData(userB.toJson());
    Wallet walletB = new Wallet(
        id: userB.id, balance: 50 - 25.0 / 6, blocked: 25.0 * 1.2 - 25.0 / 6);
    walletB.ref.setData(walletB.toJson());

    // Create User A
    User userA = new User(
        name: 'User A',
        photo: 'http://image.com/userA.jpg',
        beneficiary1: userB.id,
        beneficiary2: userB1.id);
    userA.ref.setData(userA.toJson());
    // Balance should be set directly
    Wallet walletA = new Wallet(id: userA.id, balance: 10 + 25.0 / 6);
    walletA.ref.setData(walletA.toJson());

    B.user = userA;
    B.locality = 'Bakuriani';
    B.country = 'GE';
    B.position = Position(latitude: 41.7510, longitude: 43.5292); 

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
      price: 10.0,
    );
    book.ref.setData(book.toJson());

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      isbn: book.isbn,
      ownerId: userA.id,
      holderId: userB.id,
      transitId: userA.id,
      price: 30.00,
      transit: true,
      confirmed: true,
      wish: false,
      lent: true,
    );
    record.ref.setData(record.toJson());

    // Create reward operation
    Operation rewardOp = new Operation(
        type: OperationType.Reward,
        userId: userA.id,
        amount: 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userB.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        paid: 25.0 / 6);
    rewardOp.ref.setData(rewardOp.toJson());

    // Create leasing operation
    Operation leasingOp = new Operation(
        type: OperationType.Leasing,
        userId: userB.id,
        amount: 25.0 * 1.2 - 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userA.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        deposit: 25.0 * 1.2 - 25.0 / 6,
        paid: 25.0 / 6);
    leasingOp.ref.setData(leasingOp.toJson());

    // Update reference to operations
    record
        .ref
        .updateData({'rewardId': rewardOp.id, 'leasingId': leasingOp.id});

    // Run complete function
    await complete(books: [record], holder: userB, owner: userA);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref.get()).data);
    User resultA = User.fromJson((await userA.ref.get()).data);
    User resultB1 = User.fromJson((await userB1.ref.get()).data);
    User resultB2 = User.fromJson((await userB2.ref.get()).data);
    User resultB = User.fromJson((await userB.ref.get()).data);
    Wallet resultWA = Wallet.fromJson((await Wallet.Ref(userA.id).get()).data);
    Wallet resultWB = Wallet.fromJson((await Wallet.Ref(userB.id).get()).data);
    Wallet resultWB1 =
        Wallet.fromJson((await Wallet.Ref(userB1.id).get()).data);
    Wallet resultWB2 =
        Wallet.fromJson((await Wallet.Ref(userB2.id).get()).data);
    Operation reward = Operation.fromJson((await rewardOp.ref.get()).data);
    Operation leasing = Operation.fromJson((await leasingOp.ref.get()).data);

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
    expect(
        leasing.amount, 25.0 * 1.2 * 83 / 183 - 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(leasing.userId, userB.id);
    expect(leasing.peerId, userA.id);
    expect(dp(leasing.fee, 5), dp(25.0 * 0.1 * 83 / 183, 5));
    expect(leasing.ownerFeeUserId1, null);
    expect(leasing.ownerFeeUserId2, userB1.id);
    expect(leasing.payerFeeUserId1,
        userB1.id); // Referral fee included into reward
    expect(leasing.payerFeeUserId2, userB2.id);
    expect(leasing.ownerFee1, 0.0);
    expect(dp(leasing.ownerFee2, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(leasing.payerFee1, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(leasing.payerFee2, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultA.feeShared, 0.0);
    expect(dp(resultB1.feeShared, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultB.feeShared,
        25.0 * 0.2 * 0.15 * 83 / 183 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultWA.balance, 10.0 + 25.0 * 83 / 183);
    expect(resultWB.balance,
        50.0 - 25.0 * 1.2 * 83 / 183 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultWB1.balance,
        110.0 + 25.0 * 0.2 * 0.15 * 83 / 183 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultWB2.balance, 120.0 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultWB.blocked, 0.0);
    expect(resultB2.id, userB2.id);
  });

  test("Complete function: Referrals owner is 2st referral of holder",
      () async {
    // Referral users
    User userA2 = new User(
      name: 'User A2',
      photo: 'http://image.com/userA2.jpg',
    );
    userA2.ref.setData(userA2.toJson());
    Wallet walletA2 = new Wallet(id: userA2.id, balance: 120);
    walletA2.ref.setData(walletA2.toJson());

    User userA1 = new User(
        name: 'User A1',
        photo: 'http://image.com/userA1.jpg',
        beneficiary1: userA2.id);
    userA1.ref.setData(userA1.toJson());
    // Balance should be set directly
    Wallet walletA1 = new Wallet(id: userA1.id, balance: 110);
    walletA1.ref.setData(walletA1.toJson());

    // Create User A
    User userA = new User(
        name: 'User A',
        photo: 'http://image.com/userA.jpg',
        beneficiary1: userA1.id,
        beneficiary2: userA2.id);
    userA.ref.setData(userA.toJson());
    // Balance should be set directly
    Wallet walletA = new Wallet(id: userA.id, balance: 10 + 25.0 / 6);
    walletA.ref.setData(walletA.toJson());

    B.user = userA;
    B.locality = 'Bakuriani';
    B.country = 'GE';
    B.position = Position(latitude: 41.7510, longitude: 43.5292); 

    User userB1 = new User(
        name: 'User B1',
        photo: 'http://image.com/userB1.jpg',
        beneficiary1: userA.id);
    userB1.ref.setData(userB1.toJson());
    // Balance should be set directly
    Wallet walletB1 = new Wallet(id: userB1.id, balance: 110);
    walletB1.ref.setData(walletB1.toJson());

    // Create User B
    User userB = new User(
        name: 'User B',
        photo: 'http://image.com/userB.jpg',
        beneficiary1: userB1.id,
        beneficiary2: userA.id);
    userB.ref.setData(userB.toJson());
    Wallet walletB = new Wallet(
        id: userB.id, balance: 50 - 25.0 / 6, blocked: 25.0 * 1.2 - 25.0 / 6);
    walletB.ref.setData(walletB.toJson());

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
      price: 10.0,
    );
    book.ref.setData(book.toJson());

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      isbn: book.isbn,
      ownerId: userA.id,
      holderId: userB.id,
      transitId: userA.id,
      price: 30.00,
      transit: true,
      confirmed: true,
      wish: false,
      lent: true,
    );
    record.ref.setData(record.toJson());

    // Create reward operation
    Operation rewardOp = new Operation(
        type: OperationType.Reward,
        userId: userA.id,
        amount: 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userB.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        paid: 25.0 / 6);
    rewardOp.ref.setData(rewardOp.toJson());

    // Create leasing operation
    Operation leasingOp = new Operation(
        type: OperationType.Leasing,
        userId: userB.id,
        amount: 25.0 * 1.2 - 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userA.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        deposit: 25.0 * 1.2 - 25.0 / 6,
        paid: 25.0 / 6);
    leasingOp.ref.setData(leasingOp.toJson());

    // Update reference to operations
    record
        .ref
        .updateData({'rewardId': rewardOp.id, 'leasingId': leasingOp.id});

    // Run complete function
    await complete(books: [record], holder: userB, owner: userA);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref.get()).data);
    User resultA = User.fromJson((await userA.ref.get()).data);
    User resultA1 = User.fromJson((await userA1.ref.get()).data);
    User resultA2 = User.fromJson((await userA2.ref.get()).data);
    User resultB = User.fromJson((await userB.ref.get()).data);
    User resultB1 = User.fromJson((await userB1.ref.get()).data);
    Wallet resultWA = Wallet.fromJson((await Wallet.Ref(userA.id).get()).data);
    Wallet resultWA1 =
        Wallet.fromJson((await Wallet.Ref(userA1.id).get()).data);
    Wallet resultWA2 =
        Wallet.fromJson((await Wallet.Ref(userA2.id).get()).data);
    Wallet resultWB = Wallet.fromJson((await Wallet.Ref(userB.id).get()).data);
    Wallet resultWB1 =
        Wallet.fromJson((await Wallet.Ref(userB1.id).get()).data);
    Operation reward = Operation.fromJson((await rewardOp.ref.get()).data);
    Operation leasing = Operation.fromJson((await leasingOp.ref.get()).data);

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
    expect(leasing.payerFeeUserId1,
        userB1.id); // Referral fee included into reward
    expect(leasing.payerFeeUserId2, null);
    expect(leasing.ownerFee1, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(leasing.ownerFee2, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(leasing.payerFee1, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(leasing.payerFee2, 0.0);
    expect(resultA.feeShared, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(resultA1.feeShared, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultB1.feeShared, 0.0);
    expect(resultB.feeShared, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(resultWA.balance, 5),
        dp(10.0 + 25.0 * 83 / 183 + 25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultWB.balance, 50.0 - 25.0 * 1.2 * 83 / 183);
    expect(resultWA1.balance, 110.0 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultWA2.balance, 120.0 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultWB1.balance, 110.0 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultWB.blocked, 0.0);
    expect(resultA2.id, userA2.id);
  });

  test("Complete function: Referrals holder is 2st referral of owner",
      () async {
    // Referral users
    User userB2 = new User(
      name: 'User B2',
      photo: 'http://image.com/userB2.jpg',
    );
    userB2.ref.setData(userB2.toJson());
    Wallet walletB2 = new Wallet(id: userB2.id, balance: 120);
    walletB2.ref.setData(walletB2.toJson());

    User userB1 = new User(
        name: 'User B1',
        photo: 'http://image.com/userB1.jpg',
        beneficiary1: userB2.id);
    userB1.ref.setData(userB1.toJson());
    // Balance should be set directly
    Wallet walletB1 = new Wallet(id: userB1.id, balance: 110);
    walletB1.ref.setData(walletB1.toJson());

    // Create User B
    User userB = new User(
        name: 'User B',
        photo: 'http://image.com/userB.jpg',
        beneficiary1: userB1.id,
        beneficiary2: userB2.id);
    userB.ref.setData(userB.toJson());
    Wallet walletB = new Wallet(
        id: userB.id, balance: 50 - 25.0 / 6, blocked: 25.0 * 1.2 - 25.0 / 6);
    walletB.ref.setData(walletB.toJson());

    User userA1 = new User(
        name: 'User A1',
        photo: 'http://image.com/userA1.jpg',
        beneficiary1: userB.id);
    userA1.ref.setData(userA1.toJson());
    // Balance should be set directly
    Wallet walletA1 = new Wallet(id: userA1.id, balance: 110);
    walletA1.ref.setData(walletA1.toJson());

    // Create User A
    User userA = new User(
        name: 'User A',
        photo: 'http://image.com/userA.jpg',
        beneficiary1: userA1.id,
        beneficiary2: userB.id);
    userA.ref.setData(userA.toJson());
    // Balance should be set directly
    Wallet walletA = new Wallet(id: userA.id, balance: 10 + 25.0 / 6);
    walletA.ref.setData(walletA.toJson());

    B.user = userA;
    B.locality = 'Bakuriani';
    B.country = 'GE';
    B.position = Position(latitude: 41.7510, longitude: 43.5292); 

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
      price: 10.0,
    );
    book.ref.setData(book.toJson());

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      isbn: book.isbn,
      ownerId: userA.id,
      holderId: userB.id,
      transitId: userA.id,
      price: 30.00,
      transit: true,
      confirmed: true,
      wish: false,
      lent: true,
    );
    record.ref.setData(record.toJson());

    // Create reward operation
    Operation rewardOp = new Operation(
        type: OperationType.Reward,
        userId: userA.id,
        amount: 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userB.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        paid: 25.0 / 6);
    rewardOp.ref.setData(rewardOp.toJson());

    // Create leasing operation
    Operation leasingOp = new Operation(
        type: OperationType.Leasing,
        userId: userB.id,
        amount: 25.0 * 1.2 - 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userA.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        deposit: 25.0 * 1.2 - 25.0 / 6,
        paid: 25.0 / 6);
    leasingOp.ref.setData(leasingOp.toJson());

    // Update reference to operations
    record
        .ref
        .updateData({'rewardId': rewardOp.id, 'leasingId': leasingOp.id});

    // Run complete function
    await complete(books: [record], holder: userB, owner: userA);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref.get()).data);
    User resultA = User.fromJson((await userA.ref.get()).data);
    User resultA1 = User.fromJson((await userA1.ref.get()).data);
    User resultB1 = User.fromJson((await userB1.ref.get()).data);
    User resultB2 = User.fromJson((await userB2.ref.get()).data);
    User resultB = User.fromJson((await userB.ref.get()).data);
    Wallet resultWA = Wallet.fromJson((await Wallet.Ref(userA.id).get()).data);
    Wallet resultWA1 =
        Wallet.fromJson((await Wallet.Ref(userA1.id).get()).data);
    Wallet resultWB = Wallet.fromJson((await Wallet.Ref(userB.id).get()).data);
    Wallet resultWB1 =
        Wallet.fromJson((await Wallet.Ref(userB1.id).get()).data);
    Wallet resultWB2 =
        Wallet.fromJson((await Wallet.Ref(userB2.id).get()).data);
    Operation reward = Operation.fromJson((await rewardOp.ref.get()).data);
    Operation leasing = Operation.fromJson((await leasingOp.ref.get()).data);

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
    expect(
        leasing.amount, 25.0 * 1.2 * 83 / 183 - 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(leasing.userId, userB.id);
    expect(leasing.peerId, userA.id);
    expect(dp(leasing.fee, 5), dp(25.0 * 0.1 * 83 / 183, 5));
    expect(leasing.ownerFeeUserId1, userA1.id);
    expect(leasing.ownerFeeUserId2, null);
    expect(leasing.payerFeeUserId1,
        userB1.id); // Referral fee included into reward
    expect(leasing.payerFeeUserId2, userB2.id);
    expect(leasing.ownerFee1, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(leasing.ownerFee2, 0.0);
    expect(leasing.payerFee1, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(leasing.payerFee2, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultA.feeShared, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultA1.feeShared, 0.0);
    expect(resultB.feeShared, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(resultB1.feeShared, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultB2.feeShared, 0.0);
    expect(resultWA.balance, 10.0 + 25.0 * 83 / 183);
    expect(resultWA1.balance, 110.0 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultWB.balance,
        50.0 - 25.0 * 1.2 * 83 / 183 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultWB1.balance, 110.0 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultWB2.balance, 120.0 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultWB.blocked, 0.0);
  });

  test("Payment function: In-app-purchase payment", () async {
    // Create User A
    User userA = new User(
      name: 'User A',
      photo: 'http://image.com/userA.jpg',
    );
    userA.ref.setData(userA.toJson());
    // Balance should be set directly
    Wallet walletA = new Wallet(id: userA.id, balance: 25);
    walletA.ref.setData(walletA.toJson());

    B.user = userA;
    B.locality = 'Bakuriani';
    B.country = 'GE';
    B.position = Position(latitude: 41.7510, longitude: 43.5292); 

    // Run payment function
    Operation op = await payment(
        user: userA, amount: 50.0, type: OperationType.InputInApp);

    Operation opResult = Operation.fromJson((await op.ref.get()).data);
    User resultA = User.fromJson((await userA.ref.get()).data);
    Wallet resultWA = Wallet.fromJson((await Wallet.Ref(userA.id).get()).data);

    expect(opResult.type, OperationType.InputInApp);
    expect(opResult.amount, 50.0);
    expect(opResult.userId, userA.id);
    expect(resultA.id, userA.id);
    expect(resultWA.balance, 25.0 + 50.0);
  });

  test("Pass function: Referrals", () async {
    // Referral users
    User userA2 = new User(
      name: 'User A2',
      photo: 'http://image.com/userA2.jpg',
    );
    userA2.ref.setData(userA2.toJson());
    Wallet walletA2 = new Wallet(id: userA2.id, balance: 120);
    walletA2.ref.setData(walletA2.toJson());

    User userA1 = new User(
        name: 'User A1',
        photo: 'http://image.com/userA1.jpg',
        beneficiary1: userA2.id);
    userA1.ref.setData(userA1.toJson());
    // Balance should be set directly
    Wallet walletA1 = new Wallet(id: userA1.id, balance: 110);
    walletA1.ref.setData(walletA1.toJson());

    User userB2 = new User(
      name: 'User B2',
      photo: 'http://image.com/userB2.jpg',
    );
    userB2.ref.setData(userB2.toJson());
    Wallet walletB2 = new Wallet(id: userB2.id, balance: 220);
    walletB2.ref.setData(walletB2.toJson());

    User userB1 = new User(
        name: 'User B1',
        photo: 'http://image.com/userB1.jpg',
        beneficiary1: userB2.id);
    userB1.ref.setData(userB1.toJson());
    // Balance should be set directly
    Wallet walletB1 = new Wallet(id: userB1.id, balance: 210);
    walletB1.ref.setData(walletB1.toJson());

    // Create User A
    User userA = new User(
        name: 'User A',
        photo: 'http://image.com/userA.jpg',
        beneficiary1: userA1.id,
        beneficiary2: userA2.id);
    userA.ref.setData(userA.toJson());
    // Balance should be set directly
    Wallet walletA = new Wallet(id: userA.id, balance: 10 + 25.0 / 6);
    walletA.ref.setData(walletA.toJson());

    // Create User B
    User userB = new User(
        name: 'User B',
        photo: 'http://image.com/userB.jpg',
        beneficiary1: userB1.id,
        beneficiary2: userB2.id);
    userB.ref.setData(userB.toJson());
    Wallet walletB = new Wallet(
        id: userB.id, balance: 50 - 25.0 / 6, blocked: 25.0 * 1.2 - 25.0 / 6);
    walletB.ref.setData(walletB.toJson());

    // Create User C
    User userC = new User(
      name: 'User C',
      photo: 'http://image.com/userC.jpg',
    );
    userC.ref.setData(userC.toJson());
    Wallet walletC = new Wallet(id: userC.id, balance: 100);
    walletC.ref.setData(walletC.toJson());

    B.user = userC;
    B.locality = 'Bakuriani';
    B.country = 'GE';
    B.position = Position(latitude: 41.7510, longitude: 43.5292); 

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
      price: 10.0,
    );
    book.ref.setData(book.toJson());

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      isbn: book.isbn,
      ownerId: userA.id,
      holderId: userB.id,
      transitId: userC.id,
      price: 30.00,
      transit: true,
      confirmed: true,
      wish: false,
      lent: true,
    );
    record.ref.setData(record.toJson());

    // Create reward operation
    Operation rewardOp = new Operation(
        type: OperationType.Reward,
        userId: userA.id,
        amount: 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userB.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        paid: 25.0 / 6);
    rewardOp.ref.setData(rewardOp.toJson());

    // Create leasing operation
    Operation leasingOp = new Operation(
        type: OperationType.Leasing,
        userId: userB.id,
        amount: 25.0 * 1.2 - 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userA.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        deposit: 25.0 * 1.2 - 25.0 / 6,
        paid: 25.0 / 6);
    leasingOp.ref.setData(leasingOp.toJson());

    // Update reference to operations
    record
        .ref
        .updateData({'rewardId': rewardOp.id, 'leasingId': leasingOp.id});

    // Run complete function
    await pass(books: [record], holder: userB, payer: userC);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref.get()).data);
    User resultA = User.fromJson((await userA.ref.get()).data);
    User resultA1 = User.fromJson((await userA1.ref.get()).data);
    User resultA2 = User.fromJson((await userA2.ref.get()).data);
    User resultB = User.fromJson((await userB.ref.get()).data);
    User resultB1 = User.fromJson((await userB1.ref.get()).data);
    User resultB2 = User.fromJson((await userB2.ref.get()).data);
    User resultC = User.fromJson((await userC.ref.get()).data);
    Wallet resultWA = Wallet.fromJson((await Wallet.Ref(userA.id).get()).data);
    Wallet resultWA1 =
    Wallet.fromJson((await Wallet.Ref(userA1.id).get()).data);
    Wallet resultWA2 =
    Wallet.fromJson((await Wallet.Ref(userA2.id).get()).data);
    Wallet resultWB = Wallet.fromJson((await Wallet.Ref(userB.id).get()).data);
    Wallet resultWB1 =
    Wallet.fromJson((await Wallet.Ref(userB1.id).get()).data);
    Wallet resultWB2 =
    Wallet.fromJson((await Wallet.Ref(userB2.id).get()).data);
    Wallet resultWC = Wallet.fromJson((await Wallet.Ref(userC.id).get()).data);
    Operation rewardOld = Operation.fromJson((await rewardOp.ref.get()).data);
    Operation leasingOld =
        Operation.fromJson((await leasingOp.ref.get()).data);

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
    expect(dp(leasingOld.fee, 5), dp(25.0 * 0.1 * 83 / 183, 5));
    expect(leasingOld.ownerFeeUserId1, userA1.id);
    expect(leasingOld.ownerFeeUserId2, userA2.id);
    expect(leasingOld.payerFeeUserId1, userB1.id);
    expect(leasingOld.payerFeeUserId2, userB2.id);
    expect(leasingOld.ownerFee1, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(leasingOld.ownerFee2, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(leasingOld.payerFee1, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(leasingOld.payerFee2, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultA.feeShared, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(resultA1.feeShared, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultB.feeShared, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(resultB1.feeShared, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(leasingNew.paid, 25.0 / 6);
    expect(leasingNew.deposit, 25.0 * 1.2 - 25.0 / 6);
    expect(leasingNew.amount, 25.0 * 1.2);
    expect(leasingNew.userId, userC.id);
    expect(leasingNew.peerId, userA.id);
    expect(leasingNew.fee, 0.0);
    expect(leasingNew.end.difference(leasingNew.start).inDays, 183);
    expect(dp(resultWA.balance, 5), dp(10.0 + 25.0 * 83 / 183 + 25.0 / 6, 5));
    expect(resultWA1.balance, 110.0 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultWA2.balance, 120.0 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultWB.balance, 50.0 - 25.0 * 1.2 * 83 / 183);
    expect(resultWB.blocked, 0);
    expect(resultWB1.balance, 210.0 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultWB2.balance, 220.0 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultWC.balance, 100.0 - 25.0 / 6);
    expect(resultWC.blocked, 25 * 1.2 - 25.0 / 6);
    expect(resultA2.id, userA2.id);
    expect(resultB2.id, userB2.id);
    expect(resultC.id, userC.id);
  });

  test("Pass function: Referrals owner is 1st referral of holder", () async {
    // Referral users
    User userA2 = new User(
      name: 'User A2',
      photo: 'http://image.com/userA2.jpg',
    );
    userA2.ref.setData(userA2.toJson());
    Wallet walletA2 = new Wallet(id: userA2.id, balance: 120);
    walletA2.ref.setData(walletA2.toJson());

    User userA1 = new User(
        name: 'User A1',
        photo: 'http://image.com/userA1.jpg',
        beneficiary1: userA2.id);
    userA1.ref.setData(userA1.toJson());
    // Balance should be set directly
    Wallet walletA1 = new Wallet(id: userA1.id, balance: 110);
    walletA1.ref.setData(walletA1.toJson());

    // Create User A
    User userA = new User(
        name: 'User A',
        photo: 'http://image.com/userA.jpg',
        beneficiary1: userA1.id,
        beneficiary2: userA2.id);
    userA.ref.setData(userA.toJson());
    // Balance should be set directly
    Wallet walletA = new Wallet(id: userA.id, balance: 10 + 25.0 / 6);
    walletA.ref.setData(walletA.toJson());

    // Create User B
    User userB = new User(
        name: 'User B',
        photo: 'http://image.com/userB.jpg',
        beneficiary1: userA.id,
        beneficiary2: userA1.id);
    userB.ref.setData(userB.toJson());
    Wallet walletB = new Wallet(
        id: userB.id, balance: 50 - 25.0 / 6, blocked: 25.0 * 1.2 - 25.0 / 6);
    walletB.ref.setData(walletB.toJson());

    // Create User C
    User userC = new User(
      name: 'User C',
      photo: 'http://image.com/userC.jpg',
    );
    userC.ref.setData(userC.toJson());
    Wallet walletC = new Wallet(id: userC.id, balance: 100);
    walletC.ref.setData(walletC.toJson());

    B.user = userC;
    B.locality = 'Bakuriani';
    B.country = 'GE';
    B.position = Position(latitude: 41.7510, longitude: 43.5292); 

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
      price: 10.0,
    );
    book.ref.setData(book.toJson());

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      isbn: book.isbn,
      ownerId: userA.id,
      holderId: userB.id,
      transitId: userC.id,
      price: 30.00,
      transit: true,
      confirmed: true,
      wish: false,
      lent: true,
    );
    record.ref.setData(record.toJson());

    // Create reward operation
    Operation rewardOp = new Operation(
        type: OperationType.Reward,
        userId: userA.id,
        amount: 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userB.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        paid: 25.0 / 6);
    rewardOp.ref.setData(rewardOp.toJson());

    // Create leasing operation
    Operation leasingOp = new Operation(
        type: OperationType.Leasing,
        userId: userB.id,
        amount: 25.0 * 1.2 - 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userA.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        deposit: 25.0 * 1.2 - 25.0 / 6,
        paid: 25.0 / 6);
    leasingOp.ref.setData(leasingOp.toJson());

    // Update reference to operations
    record
        .ref
        .updateData({'rewardId': rewardOp.id, 'leasingId': leasingOp.id});

    // Run complete function
    await pass(books: [record], holder: userB, payer: userC);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref.get()).data);
    User resultA = User.fromJson((await userA.ref.get()).data);
    User resultA1 = User.fromJson((await userA1.ref.get()).data);
    User resultA2 = User.fromJson((await userA2.ref.get()).data);
    User resultB = User.fromJson((await userB.ref.get()).data);
    User resultC = User.fromJson((await userC.ref.get()).data);
    Wallet resultWA = Wallet.fromJson((await Wallet.Ref(userA.id).get()).data);
    Wallet resultWA1 =
    Wallet.fromJson((await Wallet.Ref(userA1.id).get()).data);
    Wallet resultWA2 =
    Wallet.fromJson((await Wallet.Ref(userA2.id).get()).data);
    Wallet resultWB = Wallet.fromJson((await Wallet.Ref(userB.id).get()).data);
    Wallet resultWC = Wallet.fromJson((await Wallet.Ref(userC.id).get()).data);
    Operation rewardOld = Operation.fromJson((await rewardOp.ref.get()).data);
    Operation leasingOld =
    Operation.fromJson((await leasingOp.ref.get()).data);

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
    expect(rewardOld.paid, 25.0 * 83 / 183 + 25.0 / 6 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(rewardOld.amount, 25.0 * 83 / 183 + 25.0 / 6 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(rewardOld.userId, userA.id);
    expect(rewardOld.peerId, userC.id);
    expect(leasingOld.paid, 25.0 * 83 / 183 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(leasingOld.deposit, 0);
    expect(leasingOld.amount, 25.0 * 1.2 * 83 / 183);
    expect(leasingOld.userId, userB.id);
    expect(leasingOld.peerId, userA.id);
    expect(dp(leasingOld.fee, 5), dp(25.0 * 0.1 * 83 / 183, 5));
    expect(leasingOld.ownerFeeUserId1, userA1.id);
    expect(leasingOld.ownerFeeUserId2, userA2.id);
    expect(leasingOld.payerFeeUserId1, null);
    expect(leasingOld.payerFeeUserId2, userA1.id);
    expect(leasingOld.ownerFee1, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(leasingOld.ownerFee2, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(leasingOld.payerFee1, 0);
    expect(dp(leasingOld.payerFee2, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultA.feeShared, 25.0 * 0.2 * 0.15 * 83 / 183 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(dp(resultA1.feeShared, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultB.feeShared, 0.0);
    expect(leasingNew.paid, 25.0 / 6);
    expect(leasingNew.deposit, 25.0 * 1.2 - 25.0 / 6);
    expect(leasingNew.amount, 25.0 * 1.2);
    expect(leasingNew.userId, userC.id);
    expect(leasingNew.peerId, userA.id);
    expect(leasingNew.fee, 0.0);
    expect(leasingNew.end.difference(leasingNew.start).inDays, 183);
    expect(dp(resultWA.balance, 5), dp(10.0 + 25.0 * 83 / 183 + 25.0 / 6 + 25.0 * 0.2 * 0.15 * 83 / 183, 5));
    expect(resultWA1.balance, 110.0 + 25.0 * 0.2 * 0.15 * 83 / 183 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultWA2.balance, 120.0 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultWB.balance, 50.0 - 25.0 * 1.2 * 83 / 183);
    expect(resultWB.blocked, 0);
    expect(resultWC.balance, 100.0 - 25.0 / 6);
    expect(resultWC.blocked, 25 * 1.2 - 25.0 / 6);
    expect(resultA2.id, userA2.id);
    expect(resultC.id, userC.id);
  });

  test("Pass function: Referrals holder is 1st referral of owner", () async {
    // Referral users
    User userB2 = new User(
      name: 'User B2',
      photo: 'http://image.com/userB2.jpg',
    );
    userB2.ref.setData(userB2.toJson());
    Wallet walletB2 = new Wallet(id: userB2.id, balance: 220);
    walletB2.ref.setData(walletB2.toJson());

    User userB1 = new User(
        name: 'User B1',
        photo: 'http://image.com/userB1.jpg',
        beneficiary1: userB2.id);
    userB1.ref.setData(userB1.toJson());
    // Balance should be set directly
    Wallet walletB1 = new Wallet(id: userB1.id, balance: 210);
    walletB1.ref.setData(walletB1.toJson());

    // Create User B
    User userB = new User(
        name: 'User B',
        photo: 'http://image.com/userB.jpg',
        beneficiary1: userB1.id,
        beneficiary2: userB2.id);
    userB.ref.setData(userB.toJson());
    Wallet walletB = new Wallet(
        id: userB.id, balance: 50 - 25.0 / 6, blocked: 25.0 * 1.2 - 25.0 / 6);
    walletB.ref.setData(walletB.toJson());

    // Create User A
    User userA = new User(
        name: 'User A',
        photo: 'http://image.com/userA.jpg',
        beneficiary1: userB.id,
        beneficiary2: userB1.id);
    userA.ref.setData(userA.toJson());
    // Balance should be set directly
    Wallet walletA = new Wallet(id: userA.id, balance: 10 + 25.0 / 6);
    walletA.ref.setData(walletA.toJson());

    // Create User C
    User userC = new User(
      name: 'User C',
      photo: 'http://image.com/userC.jpg',
    );
    userC.ref.setData(userC.toJson());
    Wallet walletC = new Wallet(id: userC.id, balance: 100);
    walletC.ref.setData(walletC.toJson());

    B.user = userC;
    B.locality = 'Bakuriani';
    B.country = 'GE';
    B.position = Position(latitude: 41.7510, longitude: 43.5292); 

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
      price: 10.0,
    );
    book.ref.setData(book.toJson());

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      isbn: book.isbn,
      ownerId: userA.id,
      holderId: userB.id,
      transitId: userC.id,
      price: 30.00,
      transit: true,
      confirmed: true,
      wish: false,
      lent: true,
    );
    record.ref.setData(record.toJson());

    // Create reward operation
    Operation rewardOp = new Operation(
        type: OperationType.Reward,
        userId: userA.id,
        amount: 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userB.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        paid: 25.0 / 6);
    rewardOp.ref.setData(rewardOp.toJson());

    // Create leasing operation
    Operation leasingOp = new Operation(
        type: OperationType.Leasing,
        userId: userB.id,
        amount: 25.0 * 1.2 - 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userA.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        deposit: 25.0 * 1.2 - 25.0 / 6,
        paid: 25.0 / 6);
    leasingOp.ref.setData(leasingOp.toJson());

    // Update reference to operations
    record
        .ref
        .updateData({'rewardId': rewardOp.id, 'leasingId': leasingOp.id});

    // Run complete function
    await pass(books: [record], holder: userB, payer: userC);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref.get()).data);
    User resultA = User.fromJson((await userA.ref.get()).data);
    User resultB = User.fromJson((await userB.ref.get()).data);
    User resultB1 = User.fromJson((await userB1.ref.get()).data);
    User resultB2 = User.fromJson((await userB2.ref.get()).data);
    User resultC = User.fromJson((await userC.ref.get()).data);
    Wallet resultWA = Wallet.fromJson((await Wallet.Ref(userA.id).get()).data);
    Wallet resultWB = Wallet.fromJson((await Wallet.Ref(userB.id).get()).data);
    Wallet resultWB1 =
    Wallet.fromJson((await Wallet.Ref(userB1.id).get()).data);
    Wallet resultWB2 =
    Wallet.fromJson((await Wallet.Ref(userB2.id).get()).data);
    Wallet resultWC = Wallet.fromJson((await Wallet.Ref(userC.id).get()).data);
    Operation rewardOld = Operation.fromJson((await rewardOp.ref.get()).data);
    Operation leasingOld =
    Operation.fromJson((await leasingOp.ref.get()).data);

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
    expect(leasingOld.amount, 25.0 * 1.2 * 83 / 183 - 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(leasingOld.userId, userB.id);
    expect(leasingOld.peerId, userA.id);
    expect(dp(leasingOld.fee, 5), dp(25.0 * 0.1 * 83 / 183, 5));
    expect(leasingOld.ownerFeeUserId1, null);
    expect(leasingOld.ownerFeeUserId2, userB1.id);
    expect(leasingOld.payerFeeUserId1, userB1.id);
    expect(leasingOld.payerFeeUserId2, userB2.id);
    expect(leasingOld.ownerFee1, 0.0);
    expect(dp(leasingOld.ownerFee2, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(leasingOld.payerFee1, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(leasingOld.payerFee2, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultA.feeShared, 0.0);
    expect(resultB.feeShared, 25.0 * 0.2 * 0.15 * 83 / 183 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(dp(resultB1.feeShared, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(leasingNew.paid, 25.0 / 6);
    expect(leasingNew.deposit, 25.0 * 1.2 - 25.0 / 6);
    expect(leasingNew.amount, 25.0 * 1.2);
    expect(leasingNew.userId, userC.id);
    expect(leasingNew.peerId, userA.id);
    expect(leasingNew.fee, 0.0);
    expect(leasingNew.end.difference(leasingNew.start).inDays, 183);
    expect(dp(resultWA.balance, 5), dp(10.0 + 25.0 * 83 / 183 + 25.0 / 6, 5));
    expect(resultWB.balance, 50.0 - 25.0 * 1.2 * 83 / 183 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultWB.blocked, 0);
    expect(resultWB1.balance, 210.0 + 25.0 * 0.2 * 0.15 * 83 / 183 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultWB2.balance, 220.0 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultWC.balance, 100.0 - 25.0 / 6);
    expect(resultWC.blocked, 25 * 1.2 - 25.0 / 6);
    expect(resultB2.id, userB2.id);
    expect(resultC.id, userC.id);
  });

  test("Pass function: Referrals owner is 2st referral of holder", () async {
    // Referral users
    User userA2 = new User(
      name: 'User A2',
      photo: 'http://image.com/userA2.jpg',
    );
    userA2.ref.setData(userA2.toJson());
    Wallet walletA2 = new Wallet(id: userA2.id, balance: 120);
    walletA2.ref.setData(walletA2.toJson());

    User userA1 = new User(
        name: 'User A1',
        photo: 'http://image.com/userA1.jpg',
        beneficiary1: userA2.id);
    userA1.ref.setData(userA1.toJson());
    // Balance should be set directly
    Wallet walletA1 = new Wallet(id: userA1.id, balance: 110);
    walletA1.ref.setData(walletA1.toJson());

    // Create User A
    User userA = new User(
        name: 'User A',
        photo: 'http://image.com/userA.jpg',
        beneficiary1: userA1.id,
        beneficiary2: userA2.id);
    userA.ref.setData(userA.toJson());
    // Balance should be set directly
    Wallet walletA = new Wallet(id: userA.id, balance: 10 + 25.0 / 6);
    walletA.ref.setData(walletA.toJson());

    User userB1 = new User(
        name: 'User B1',
        photo: 'http://image.com/userB1.jpg',
        beneficiary1: userA.id);
    userB1.ref.setData(userB1.toJson());
    // Balance should be set directly
    Wallet walletB1 = new Wallet(id: userB1.id, balance: 210);
    walletB1.ref.setData(walletB1.toJson());

    // Create User B
    User userB = new User(
        name: 'User B',
        photo: 'http://image.com/userB.jpg',
        beneficiary1: userB1.id,
        beneficiary2: userA.id);
    userB.ref.setData(userB.toJson());
    Wallet walletB = new Wallet(
        id: userB.id, balance: 50 - 25.0 / 6, blocked: 25.0 * 1.2 - 25.0 / 6);
    walletB.ref.setData(walletB.toJson());

    // Create User C
    User userC = new User(
      name: 'User C',
      photo: 'http://image.com/userC.jpg',
    );
    userC.ref.setData(userC.toJson());
    Wallet walletC = new Wallet(id: userC.id, balance: 100);
    walletC.ref.setData(walletC.toJson());

    B.user = userC;
    B.locality = 'Bakuriani';
    B.country = 'GE';
    B.position = Position(latitude: 41.7510, longitude: 43.5292); 

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
      price: 10.0,
    );
    book.ref.setData(book.toJson());

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      isbn: book.isbn,
      ownerId: userA.id,
      holderId: userB.id,
      transitId: userC.id,
      price: 30.00,
      transit: true,
      confirmed: true,
      wish: false,
      lent: true,
    );
    record.ref.setData(record.toJson());

    // Create reward operation
    Operation rewardOp = new Operation(
        type: OperationType.Reward,
        userId: userA.id,
        amount: 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userB.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        paid: 25.0 / 6);
    rewardOp.ref.setData(rewardOp.toJson());

    // Create leasing operation
    Operation leasingOp = new Operation(
        type: OperationType.Leasing,
        userId: userB.id,
        amount: 25.0 * 1.2 - 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userA.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        deposit: 25.0 * 1.2 - 25.0 / 6,
        paid: 25.0 / 6);
    leasingOp.ref.setData(leasingOp.toJson());

    // Update reference to operations
    record
        .ref
        .updateData({'rewardId': rewardOp.id, 'leasingId': leasingOp.id});

    // Run complete function
    await pass(books: [record], holder: userB, payer: userC);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref.get()).data);
    User resultA = User.fromJson((await userA.ref.get()).data);
    User resultA1 = User.fromJson((await userA1.ref.get()).data);
    User resultA2 = User.fromJson((await userA2.ref.get()).data);
    User resultB = User.fromJson((await userB.ref.get()).data);
    User resultB1 = User.fromJson((await userB1.ref.get()).data);
    User resultC = User.fromJson((await userC.ref.get()).data);
    Wallet resultWA = Wallet.fromJson((await Wallet.Ref(userA.id).get()).data);
    Wallet resultWA1 =
    Wallet.fromJson((await Wallet.Ref(userA1.id).get()).data);
    Wallet resultWA2 =
    Wallet.fromJson((await Wallet.Ref(userA2.id).get()).data);
    Wallet resultWB = Wallet.fromJson((await Wallet.Ref(userB.id).get()).data);
    Wallet resultWB1 =
    Wallet.fromJson((await Wallet.Ref(userB1.id).get()).data);
    Wallet resultWC = Wallet.fromJson((await Wallet.Ref(userC.id).get()).data);
    Operation rewardOld = Operation.fromJson((await rewardOp.ref.get()).data);
    Operation leasingOld =
    Operation.fromJson((await leasingOp.ref.get()).data);

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
    expect(dp(rewardOld.paid, 5), dp(25.0 * 83 / 183 + 25.0 / 6 + 25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(dp(rewardOld.amount,5), dp(25.0 * 83 / 183 + 25.0 / 6 + 25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(rewardOld.userId, userA.id);
    expect(rewardOld.peerId, userC.id);
    expect(leasingOld.paid, 25.0 * 83 / 183 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(leasingOld.deposit, 0);
    expect(leasingOld.amount, 25.0 * 1.2 * 83 / 183);
    expect(leasingOld.userId, userB.id);
    expect(leasingOld.peerId, userA.id);
    expect(dp(leasingOld.fee, 5), dp(25.0 * 0.1 * 83 / 183, 5));
    expect(leasingOld.ownerFeeUserId1, userA1.id);
    expect(leasingOld.ownerFeeUserId2, userA2.id);
    expect(leasingOld.payerFeeUserId1, userB1.id);
    expect(leasingOld.payerFeeUserId2, null);
    expect(leasingOld.ownerFee1, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(leasingOld.ownerFee2, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(leasingOld.payerFee1, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(leasingOld.payerFee2, 0.0);
    expect(resultA.feeShared, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(resultA1.feeShared, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultB.feeShared, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultB1.feeShared, 0.0);
    expect(leasingNew.paid, 25.0 / 6);
    expect(leasingNew.deposit, 25.0 * 1.2 - 25.0 / 6);
    expect(leasingNew.amount, 25.0 * 1.2);
    expect(leasingNew.userId, userC.id);
    expect(leasingNew.peerId, userA.id);
    expect(leasingNew.fee, 0.0);
    expect(leasingNew.end.difference(leasingNew.start).inDays, 183);
    expect(dp(resultWA.balance, 5), dp(10.0 + 25.0 * 83 / 183 + 25.0 / 6 + 25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultWA1.balance, 110.0 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultWA2.balance, 120.0 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultWB.balance, 50.0 - 25.0 * 1.2 * 83 / 183);
    expect(resultWB.blocked, 0);
    expect(resultWB1.balance, 210.0 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultWC.balance, 100.0 - 25.0 / 6);
    expect(resultWC.blocked, 25 * 1.2 - 25.0 / 6);
    expect(resultA2.id, userA2.id);
    expect(resultC.id, userC.id);
  });

  test("Pass function: Referrals holder is 2st referral of owner", () async {
    // Referral users
    User userB2 = new User(
      name: 'User B2',
      photo: 'http://image.com/userB2.jpg',
    );
    userB2.ref.setData(userB2.toJson());
    Wallet walletB2 = new Wallet(id: userB2.id, balance: 220);
    walletB2.ref.setData(walletB2.toJson());

    User userB1 = new User(
        name: 'User B1',
        photo: 'http://image.com/userB1.jpg',
        beneficiary1: userB2.id);
    userB1.ref.setData(userB1.toJson());
    // Balance should be set directly
    Wallet walletB1 = new Wallet(id: userB1.id, balance: 210);
    walletB1.ref.setData(walletB1.toJson());

    // Create User B
    User userB = new User(
        name: 'User B',
        photo: 'http://image.com/userB.jpg',
        beneficiary1: userB1.id,
        beneficiary2: userB2.id);
    userB.ref.setData(userB.toJson());
    Wallet walletB = new Wallet(
        id: userB.id, balance: 50 - 25.0 / 6, blocked: 25.0 * 1.2 - 25.0 / 6);
    walletB.ref.setData(walletB.toJson());

    User userA1 = new User(
        name: 'User A1',
        photo: 'http://image.com/userA1.jpg',
        beneficiary1: userB.id);
    userA1.ref.setData(userA1.toJson());
    // Balance should be set directly
    Wallet walletA1 = new Wallet(id: userA1.id, balance: 110);
    walletA1.ref.setData(walletA1.toJson());

    // Create User A
    User userA = new User(
        name: 'User A',
        photo: 'http://image.com/userA.jpg',
        beneficiary1: userA1.id,
        beneficiary2: userB.id);
    userA.ref.setData(userA.toJson());
    // Balance should be set directly
    Wallet walletA = new Wallet(id: userA.id, balance: 10 + 25.0 / 6);
    walletA.ref.setData(walletA.toJson());

    // Create User C
    User userC = new User(
      name: 'User C',
      photo: 'http://image.com/userC.jpg',
    );
    userC.ref.setData(userC.toJson());
    Wallet walletC = new Wallet(id: userC.id, balance: 100);
    walletC.ref.setData(walletC.toJson());

    B.user = userC;
    B.locality = 'Bakuriani';
    B.country = 'GE';
    B.position = Position(latitude: 41.7510, longitude: 43.5292); 

    // Create Book
    Book book = new Book(
      title: 'Title',
      authors: ['Book Author'],
      isbn: '9785362836278',
      image: 'http://image.com/book.jpg',
      price: 10.0,
    );
    book.ref.setData(book.toJson());

    // Create Bookrecord in transit state
    Bookrecord record = new Bookrecord(
      isbn: book.isbn,
      ownerId: userA.id,
      holderId: userB.id,
      transitId: userC.id,
      price: 30.00,
      transit: true,
      confirmed: true,
      wish: false,
      lent: true,
    );
    record.ref.setData(record.toJson());

    // Create reward operation
    Operation rewardOp = new Operation(
        type: OperationType.Reward,
        userId: userA.id,
        amount: 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userB.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        paid: 25.0 / 6);
    rewardOp.ref.setData(rewardOp.toJson());

    // Create leasing operation
    Operation leasingOp = new Operation(
        type: OperationType.Leasing,
        userId: userB.id,
        amount: 25.0 * 1.2 - 25.0 / 6,
        date: DateTime.now().subtract(Duration(days: 83)),
        peerId: userA.id,
        bookrecordId: record.id,
        isbn: book.isbn,
        price: 25.0,
        start: DateTime.now().subtract(Duration(days: 83)),
        end: DateTime.now().add(Duration(days: 100)),
        deposit: 25.0 * 1.2 - 25.0 / 6,
        paid: 25.0 / 6);
    leasingOp.ref.setData(leasingOp.toJson());

    // Update reference to operations
    record
        .ref
        .updateData({'rewardId': rewardOp.id, 'leasingId': leasingOp.id});

    // Run complete function
    await pass(books: [record], holder: userB, payer: userC);

    Bookrecord resultRec = Bookrecord.fromJson((await record.ref.get()).data);
    User resultA = User.fromJson((await userA.ref.get()).data);
    User resultA1 = User.fromJson((await userA1.ref.get()).data);
    User resultB = User.fromJson((await userB.ref.get()).data);
    User resultB1 = User.fromJson((await userB1.ref.get()).data);
    User resultB2 = User.fromJson((await userB2.ref.get()).data);
    User resultC = User.fromJson((await userC.ref.get()).data);
    Wallet resultWA = Wallet.fromJson((await Wallet.Ref(userA.id).get()).data);
    Wallet resultWA1 =
    Wallet.fromJson((await Wallet.Ref(userA1.id).get()).data);
    Wallet resultWB = Wallet.fromJson((await Wallet.Ref(userB.id).get()).data);
    Wallet resultWB1 =
    Wallet.fromJson((await Wallet.Ref(userB1.id).get()).data);
    Wallet resultWB2 =
    Wallet.fromJson((await Wallet.Ref(userB2.id).get()).data);
    Wallet resultWC = Wallet.fromJson((await Wallet.Ref(userC.id).get()).data);
    Operation rewardOld = Operation.fromJson((await rewardOp.ref.get()).data);
    Operation leasingOld =
    Operation.fromJson((await leasingOp.ref.get()).data);

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
    expect(leasingOld.amount, 25.0 * 1.2 * 83 / 183 - 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(leasingOld.userId, userB.id);
    expect(leasingOld.peerId, userA.id);
    expect(dp(leasingOld.fee, 5), dp(25.0 * 0.1 * 83 / 183, 5));
    expect(leasingOld.ownerFeeUserId1, userA1.id);
    expect(leasingOld.ownerFeeUserId2, null);
    expect(leasingOld.payerFeeUserId1, userB1.id);
    expect(leasingOld.payerFeeUserId2, userB2.id);
    expect(leasingOld.ownerFee1, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(leasingOld.ownerFee2, 0.0);
    expect(leasingOld.payerFee1, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(leasingOld.payerFee2, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(resultA.feeShared, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultA1.feeShared, 0.0);
    expect(resultB.feeShared, 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(dp(resultB1.feeShared, 5), dp(25.0 * 0.2 * 0.10 * 83 / 183, 5));
    expect(leasingNew.paid, 25.0 / 6);
    expect(leasingNew.deposit, 25.0 * 1.2 - 25.0 / 6);
    expect(leasingNew.amount, 25.0 * 1.2);
    expect(leasingNew.userId, userC.id);
    expect(leasingNew.peerId, userA.id);
    expect(leasingNew.fee, 0.0);
    expect(leasingNew.end.difference(leasingNew.start).inDays, 183);
    expect(dp(resultWA.balance, 5), dp(10.0 + 25.0 * 83 / 183 + 25.0 / 6, 5));
    expect(resultWA1.balance, 110.0 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultWB.balance, 50.0 - 25.0 * 1.2 * 83 / 183 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultWB.blocked, 0);
    expect(resultWB1.balance, 210.0 + 25.0 * 0.2 * 0.15 * 83 / 183);
    expect(resultWB2.balance, 220.0 + 25.0 * 0.2 * 0.10 * 83 / 183);
    expect(resultWC.balance, 100.0 - 25.0 / 6);
    expect(resultWC.blocked, 25 * 1.2 - 25.0 / 6);
    expect(resultB2.id, userB2.id);
    expect(resultC.id, userC.id);
  });
}
