import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';
import 'package:stellar/stellar.dart' as stellar;

String biblosphereAccountId;

Future<void> getPaymentContext() async {
  // Read Stellar account id
  DocumentReference stellarRef =
      Firestore.instance.document('system/stellar_in');
  DocumentSnapshot stellarSnap = await stellarRef.get();
  if (stellarSnap.exists) biblosphereAccountId = stellarSnap.data['accountId'];

  return;
}

Future<bool> checkStellarAccount(String accountId) async {
  try {
    stellar.KeyPair pair = stellar.KeyPair.fromAccountId(accountId);

    stellar.Network.useTestNetwork();
    //stellar.Server server = stellar.Server("https://horizon-testnet.stellar.org");
    stellar.Server server = stellar.Server("https://horizon.stellar.org");
    await server.accounts.account(pair);

    return true;
  } catch (error, stack) {
    FlutterCrashlytics().logException(error, stack);

    print((error as stellar.ErrorResponse).body);
    // TODO: Log exception to Firebase
    return false;
  }
}