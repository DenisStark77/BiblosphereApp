import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stellar/stellar.dart' as stellar;
import 'package:http/http.dart' as http;
import 'package:biblosphere/const.dart';

createStellarAccount(User user) async {
  stellar.KeyPair pair = stellar.KeyPair.random();

  // Add balance to test account
  var url = "https://friendbot.stellar.org/?addr=${pair.accountId}";
  http.get(url).then((response) {
    switch (response.statusCode) {
      case 200:
        {
          print(
              "!!!DEBUG: SUCCESS! You have a new account : \n${response.body}");
          print("!!!DEBUG: Response body: ${response.body}");
          break;
        }
      default:
        {
          print("ERROR! : \n${response.body}");
        }
    }
  });

  user.accountId = pair.accountId;
  user.secretSeed = pair.secretSeed;
  await Firestore.instance
      .collection('users')
      .document(user.id)
      .updateData({'accountId': user.accountId, 'secretSeed': user.secretSeed});
}

Future<bool> checkStellarAccount(String accountId) async {
  try {
    print('!!!DEBUG check account: ${accountId}');
    stellar.KeyPair pair = stellar.KeyPair.fromAccountId(accountId);

    stellar.Network.useTestNetwork();
    stellar.Server server =
        stellar.Server("https://horizon-testnet.stellar.org");
    await server.accounts.account(pair);

    return true;
  } catch (error) {
    print('!!!DEBUG type ${error.runtimeType} ${error}');
    print('!!!DEBUG type CODE: ${(error as stellar.ErrorResponse).code}');
    print((error as stellar.ErrorResponse).body);

    return false;
  }
}

Future<void> payoutStellar(User user, double amount) async {
  DocumentReference userRef = user.ref();
  String payoutId;

  // Block amount first
  await db.runTransaction((Transaction tx) async {
    DocumentSnapshot userSnap = await tx.get(userRef);
    if (!userSnap.exists) throw ('User does not exist in DB ${user.id}');

    User userUpd = new User.fromJson(userSnap.data);

    if (userUpd.getAvailable() < amount)
      throw ('Stellar payout account not configured ${user.name}');

    if (userUpd.payoutId == null) {
      throw ('Stellar payout account not configured ${user.name}');
    }

    payoutId = userUpd.payoutId;
    userRef.updateData({'blocked': FieldValue.increment(amount)});
  });

  // Do StellarPayment
  if (payoutId != null) {
    print('!!!DEBUG: start Stellar payment');
    // Initiate Stellar transaction
    stellar.Network.useTestNetwork();
    stellar.Server server =
        new stellar.Server("https://horizon-testnet.stellar.org");

    // Biblospher account
    //TODO: protect Secret Seed
    stellar.KeyPair source = stellar.KeyPair.fromSecretSeed(
        'SBUXJGJAI7MPORWH6DIA4NUZ4PG4E4M2RKEMZYU5LSHMGWNEXGOMGBDU');

    var sourceAccount = await server.accounts.account(source);

    print('!!!DEBUG: source account validated: ${sourceAccount}');

    stellar.TransactionBuilder builder =
        new stellar.TransactionBuilder(sourceAccount);

    stellar.KeyPair destination = stellar.KeyPair.fromAccountId(payoutId);

    print('!!!DEBUG: destination: ${payoutId}');

    builder.addOperation(new stellar.PaymentOperationBuilder(
            destination, new stellar.AssetTypeNative(), amount.toString())
        .build());

    print('!!!DEBUG: transaction amount: ${amount.toString()}');

    // Add memo and sign Stellar transaction
    builder.addMemo(stellar.Memo.text("Biblosphere payout"));
    stellar.Transaction transaction = builder.build();
    transaction.sign(source);
    print('!!!DEBUG: transaction signed: ${sourceAccount}');

    // Run Stellar transaction
    var response = await server.submitTransaction(transaction);
    print('!!!DEBUG: transaction submitted: ${response}');

    // If transaction successful update books status/handover
    if (!response.success) {
      throw 'Stellar transaction failed';
    }

    print('!!!DEBUG: SuCCESSFUL TRANSACTION ${response.ledger.toString()}');

    await db.runTransaction((Transaction tx) async {
      DocumentSnapshot userSnap = await tx.get(userRef);
      if (!userSnap.exists) throw ('User does not exist in DB ${user.id}');

      tx.update(userRef, {
        'blocked': FieldValue.increment(-amount),
        'balance': FieldValue.increment(-amount)
      });

      if(amount > 0.0) {
        // Create payment operation
        Operation op = new Operation(
            type: OperationType.OutputStellar,
            userId: user.id,
            amount: amount,
            date: DateTime.now(),
            transactionId: response.ledger.toString());
        tx.set(op.ref(), op.toJson());
      }
    });
  }
}

Future<double> checkStellarPayments(User user) async {
  // Get new payments, calculate total amount and last sequence
  stellar.Network.useTestNetwork();
  stellar.Server server = stellar.Server("https://horizon-testnet.stellar.org");

  // Refresh user record (get payment cursor and balance)
  DocumentReference userRef = user.ref();
  double amount = 0.0;

  // Read cursor via transaction to avoid cached values
  await db.runTransaction((Transaction tx) async {
    DocumentSnapshot userSnap = await tx.get(userRef);

    if (!userSnap.exists) throw ('User does not exist in DB ${user.id}');

    User userUpd = new User.fromJson(userSnap.data);
    String cursor = userUpd.cursor;
    String accountId = userUpd.accountId;

    stellar.KeyPair pair = stellar.KeyPair.fromAccountId(accountId);

    stellar.PaymentsRequestBuilder request = server.payments
        .forAccount(pair)
        .order(stellar.RequestBuilderOrder.ASC)
        .limit(20);

    if (cursor != null) request = request.cursor(cursor);

    amount = 0.0;
    int count = 0;

    try {
      stellar.Page<stellar.OperationResponse> response = await request
          .execute();

      for (stellar.OperationResponse op in response.records) {
        print('!!!DEBUG operation ${op} ${op.runtimeType}');
        if (op is stellar.PaymentOperationResponse) {
          switch (op.assetType) {
            case "native":
              print(
                  "!!!DEBUG: Payment of ${op.amount} XLM from ${op.sourceAccount.accountId} received");
              amount += double.parse(op.amount);
              count++;
              cursor = op.id.toString();
              break;
            default:
              // TODO: Accept payments in other assets
              print(
                  "!!!DEBUG: Payment of ${op.amount} ${op.assetCode} from ${op.sourceAccount.accountId}");
          }
        }
      }
    } catch (err) {
      // TODO: handle no data found seperatly
      print('!!!DEBUG stellar failed ${err}');
    }
    print(
        '!!!DEBUG: count ${count} amount ${amount} cursor ${cursor}');

    // Update amount and cursor
    tx.update(
        userRef, {'balance': FieldValue.increment(amount), 'cursor': cursor});

    if(amount > 0.0) {
      // Create payment operation
      Operation op = new Operation(
          type: OperationType.InputStellar,
          userId: user.id,
          amount: amount,
          date: DateTime.now(),
          transactionId: cursor);
      tx.set(op.ref(), op.toJson());
    }
  });


  return amount;
}

Future<void> paymentStellar(User recepient, double amount) async {
  //Check if book holder has Stellar account, create if needed
  if (recepient.accountId == null) {
    throw ('Stellar account does not exist for user ${recepient.name}');
  }

  // Initiate Stellar transaction
  stellar.Network.useTestNetwork();
  stellar.Server server =
      new stellar.Server("https://horizon-testnet.stellar.org");

  // Biblospher account
  //TODO: protect Secret Seed
  stellar.KeyPair source = stellar.KeyPair.fromSecretSeed(
      'SBUXJGJAI7MPORWH6DIA4NUZ4PG4E4M2RKEMZYU5LSHMGWNEXGOMGBDU');

  var sourceAccount = await server.accounts.account(source);
  stellar.TransactionBuilder builder =
      new stellar.TransactionBuilder(sourceAccount);

  stellar.KeyPair destination =
      stellar.KeyPair.fromAccountId(recepient.accountId);

  builder.addOperation(new stellar.PaymentOperationBuilder(
          destination, new stellar.AssetTypeNative(), amount.toString())
      .build());

  // Add memo and sign Stellar transaction
  builder.addMemo(stellar.Memo.text("Books deposit"));
  stellar.Transaction transaction = builder.build();
  transaction.sign(source);

  // Run Stellar transaction
  var response = await server.submitTransaction(transaction);

  // If transaction successful update books status/handover
  if (!response.success) {
    // TODO: inform administrator about it
    throw 'Stellar transaction failed';
  }

  return;
}
