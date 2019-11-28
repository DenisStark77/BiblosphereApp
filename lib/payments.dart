import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';
import 'package:stellar/stellar.dart' as stellar;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:biblosphere/const.dart';

String biblosphereAccountId;

Map<String,String> currencySymbol = {
  'RUB': r'₽',
  'AED': r'aed',
  'GEL': '\u{20BE}',
  'USD': r'$',
  'EUR': r'€',
  'XLM': '\u{03BB}'
};

Map<String, double> xlmRates = {
  'RUB': 4.0773975423,
  'AED': 0.2340837911,
  'GEL': 0.1889691382,
  'USD': 0.0637326218,
  'EUR': 0.0571,
  'XLM': 1.0
};


double toXlm(double amount) {
  return amount / xlmRates[B.currency];
}


double toCurrency(double amount) {
  return amount * xlmRates[B.currency];
}


String money(double amount) {
  return '${new NumberFormat.currency(symbol: currencySymbol[B.currency]).format((amount ?? 0) * xlmRates[B.currency])}';
}


Future<void> getPaymentContext() async {
  // Read Stellar account id
  DocumentReference stellarRef = Firestore.instance.document('system/stellar_in');
  DocumentSnapshot stellarSnap = await stellarRef.get();
  if (stellarSnap.exists)
    biblosphereAccountId = stellarSnap.data['accountId'];

  // Read rates record
  DocumentReference ratesRef = Firestore.instance.document('system/rates');
  DocumentSnapshot snap = await ratesRef.get();

  // If timestamp older than 1 day retrieve new rates
  Timestamp threshold =
      Timestamp.fromDate(DateTime.now().subtract(Duration(days: 1)));

  if (snap.exists &&
      snap.data['timestamp'] != null &&
      (snap.data['timestamp'] as Timestamp).seconds > threshold.seconds &&
      snap.data['rates'] != null) {
    // Read rates from Firestore
    Map<String, double> savedRates =
    snap.data['rates'].map<String, double>((code, rate) => MapEntry<String, double>(code, 1.0 * rate));

    xlmRates = savedRates;
  } else if (!snap.exists ||
      snap.data['timestamp'] == null ||
      (snap.data['timestamp'] as Timestamp).seconds < threshold.seconds) {

    // Get rates from APIs
    http.Response resp = await http
        .get('https://apiv2.bitcoinaverage.com/indices/local/ticker/XLMEUR');
    if (resp.statusCode != 200)
      throw "Request to apiv2.bitcoinaverage.com failed. Code: ${resp.statusCode}";

    Map<String, dynamic> xlmBody = json.decode(resp.body);
    double xlm2eur = xlmBody['averages']['day'];

    resp = await http.get(
        'http://data.fixer.io/api/latest?access_key=8dd7d7c931c45c0346af488bd1154269&symbols=RUB,AED,GEL,USD,EUR');
    if (resp.statusCode != 200)
      throw "Request to apiv2.bitcoinaverage.com failed. Code: ${resp.statusCode}";


    Map<String, dynamic> ratesBody = json.decode(resp.body);
    Map<String, double> rates = ratesBody['rates'].map<String, double>((code, rate) => MapEntry<String, double>(code, 1.0*rate));
    Map<String, double> newRates =
        rates.map((code, rate) => MapEntry(code, rate * xlm2eur));

    newRates.addAll({'XLM': 1.0});

    // Update rates and timestamp
    ratesRef.setData({'timestamp': Timestamp.now(), 'rates': newRates});

    // Keep rates to global variable
    xlmRates = newRates;
  }

  return;
  //https://apiv2.bitcoinaverage.com/indices/local/ticker/XLMUSD
  //http://data.fixer.io/api/latest?access_key=8dd7d7c931c45c0346af488bd1154269&symbols=RUB,AED,GEL
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

Future<void> payoutStellar(User user, double amount, {String memo=''}) async {
  DocumentReference walletRef = Wallet.Ref(user.id);
  if (user.payoutId == null) {
    throw ('Stellar payout account not configured ${user.name}');
  }

  if (amount <= 0.0) {
    throw ('Amount is not valid for Stellar payment ${amount}');
  }

  // Block amount first
  await db.runTransaction((Transaction tx) async {
    DocumentSnapshot walletSnap = await tx.get(walletRef);
    if (!walletSnap.exists) throw ('Wallet does not exist in DB ${user.id}');

    Wallet wallet = new Wallet.fromJson(walletSnap.data);

    if (wallet.getAvailable() < amount)
      throw ('Stellar payout account not configured ${user.name}, ${user.id}');

    walletRef.updateData({'blocked': FieldValue.increment(amount)});
  });

  // Request Stellar payments
  DocumentReference payoutRef = Firestore.instance.collection('payouts').document();
  await db.runTransaction((Transaction tx) async {
    payoutRef.setData({
      'userId': user.id,
      'amount': amount,
      'accountId': user.payoutId,
      'memo': memo,
      'status': 'waiting',
      'type': 'stellar'
      });
  });

  FirebaseAnalytics().logEvent(
                                name: 'ecommerce_refund',
                                parameters: <String, dynamic>{
                                  'amount': amount,
                                  'channel': 'stellar',
                                  'user': user.id,
                                  'locality': B.locality,
                                  'country': B.country,
                                  'latitude': B.position.latitude,
                                  'longitude': B.position.longitude,
                                });
}