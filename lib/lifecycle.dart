import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';

import 'package:biblosphere/const.dart';
import 'package:biblosphere/helpers.dart';
import 'package:biblosphere/search.dart';
import 'package:biblosphere/l10n.dart';

//Callback function type definition
typedef BookCallback(Book book);

Future addBookrecord(
    BuildContext context, Book b, User u, bool wish, GeoFirePoint location,
    {String source = 'goodreads', bool snackbar = true}) async {
  if (b.isbn == null || b.isbn == 'NA')
    throw 'Book ${b?.title}, ${b?.authors?.join()} has no ISBN';

  // create book record from book and user
  Bookrecord bookrecord = new Bookrecord(
      ownerId: u.id,
      isbn: b.isbn,
      authors: b.authors,
      title: b.title,
      image: b.image,
      price: b.price,
      ownerName: u.name,
      ownerImage: u.photo,
      wish: wish,
      location: location);

  // Get bookrecord with predefined id
  DocumentSnapshot recSnap = await bookrecord.ref.get();

  if (recSnap.exists) {
    // Show snackbar (already exist), Add data from book, Write bookrecord
    if (snackbar)
      showSnackBar(
          context,
          wish
              ? S.of(context).wishAlreadyThere
              : S.of(context).bookAlreadyThere);
  } else {
    // Add bookrecord to firestore
    await bookrecord.ref.setData(bookrecord.toJson());

    // Show snackbar that book added
    if (snackbar)
      showSnackBar(
          context, wish ? S.of(context).wishAdded : S.of(context).bookAdded);

    // Check if book entry exist, write if missing
    DocumentSnapshot bookSnap = await b.ref.get();
    if (!bookSnap.exists) {
      if (b.image == null ||
          b.image.isEmpty ||
          b.language == null ||
          b.language.isEmpty ||
          b.price == null ||
          b.price == 0.0) b = await enrichBookRecord(b);
      await b.ref.setData(b.toJson());
      // Update bookrecord with enriched fields
      await bookrecord.ref.updateData(b.toJson(bookOnly: true));
    }

    logAnalyticsEvent(
        name: wish ? 'add_to_wishlist' : 'book_add',
        parameters: <String, dynamic>{
          'language': b.language ?? '',
          'isbn': b.isbn,
        });
  }
}

void deposit({List<Bookrecord> books, User owner, User payer}) async {
  for (Bookrecord book in books) {
    final DocumentReference ownerWalletRef = Wallet.Ref(owner.id);
    final DocumentReference payerWalletRef = Wallet.Ref(payer.id);
    await db.runTransaction((Transaction tx) async {
      try {
        DocumentSnapshot ownerWalletSnap = await tx.get(ownerWalletRef);
        if (!ownerWalletSnap.exists)
          throw "User wallet does not exist: ${owner.name}, ${owner.id}";

        DocumentSnapshot payerWalletSnap = await tx.get(payerWalletRef);
        if (!payerWalletSnap.exists)
          throw "User wallet does not exist: ${payer.name}, ${payer.id}";

        Wallet payerWallet = new Wallet.fromJson(payerWalletSnap.data);

        final DocumentReference bookRef = book.ref;
        DocumentSnapshot bookSnap = await tx.get(bookRef);
        Bookrecord fresh = new Bookrecord.fromJson(bookSnap.data);
        double amount = fresh.getPrice();

        if (fresh.holderId == owner.id &&
            fresh.transitId == payer.id &&
            fresh.lent == false &&
            fresh.transit == true &&
            fresh.confirmed == true &&
            fresh.wish == false &&
            total(amount) < payerWallet.getAvailable()) {
          // Proceed with transaction
          DateTime start = DateTime.now();
          DateTime end = DateTime.now().add(Duration(days: rentDuration()));

          double price = book.getPrice();
          double amount = total(price);
          // First payment per book
          double paid = first(price);
          // Deposit per book
          double deposit = amount - paid;

          Operation rewardOp = new Operation(
              type: OperationType.Reward,
              userId: owner.id,
              amount: paid,
              paid: paid,
              isbn: fresh.isbn,
              bookrecordId: fresh.id,
              peerId: payer.id,
              date: DateTime.now());

          Operation leasingOp = new Operation(
              type: OperationType.Leasing,
              userId: payer.id,
              amount: deposit + paid,
              date: DateTime.now(),
              start: start,
              end: end,
              price: price,
              deposit: deposit,
              paid: paid,
              isbn: fresh.isbn,
              bookrecordId: fresh.id,
              peerId: owner.id);

          final DocumentReference rewardRef = rewardOp.ref;
          final DocumentReference leasingRef = leasingOp.ref;
          final DocumentReference bookrecordRef = book.ref;

          // Create operations and update bookrecord with reference to operations
          await tx.set(rewardRef, rewardOp.toJson());
          await tx.set(leasingRef, leasingOp.toJson());
          await tx.update(bookrecordRef, {
            'rewardId': rewardOp.id,
            'leasingId': leasingOp.id,
            'holderId': payer.id,
            'holderName': payer.name,
            'holderImage': payer.photo,
            'transit': false,
            'confirmed': false,
            'lent': true,
            'transitId': null,
            'users': [owner.id, payer.id]
          });

          // Update balance and blocked for Owner and Payer
          await tx.update(payerWalletRef, {
            'balance': FieldValue.increment(-paid),
            'blocked': FieldValue.increment(deposit)
          });
          await tx
              .update(ownerWalletRef, {'balance': FieldValue.increment(paid)});
        }
      } catch (ex, stack) {
        FlutterCrashlytics().logException(ex, stack);

        // TODO: Handle exception
        print(
            '!!!DEBUG: >>>>>>>>>>>>>> Exception within transaction <<<<<<<<<<<<<<<<');
        print(ex);
        print(stack);
      }
    });

    logAnalyticsEvent(name: 'book_paid', parameters: <String, dynamic>{
      'from': owner.id,
      'to': payer.id,
      'isbn': book.isbn,
      'price': book.getPrice(),
      'distance': book.distance == double.infinity ? 50000.0 : book.distance,
    });
  }
}

void pass({List<Bookrecord> books, User holder, User payer}) async {
  for (Bookrecord book in books) {
    int days = 0;
    double feeStat = 0.0;
    final DocumentReference holderRef = holder.ref;
    final DocumentReference holderWalletRef = Wallet.Ref(holder.id);
    final DocumentReference payerWalletRef = Wallet.Ref(payer.id);
    await db.runTransaction((Transaction tx) async {
      try {
        DocumentSnapshot holderWalletSnap = await tx.get(holderWalletRef);
        if (!holderWalletSnap.exists)
          throw "Holder wallet does not exist: ${holder.name}, ${holder.id}";
        Wallet holderWallet = new Wallet.fromJson(holderWalletSnap.data);

        DocumentSnapshot payerWalletSnap = await tx.get(payerWalletRef);
        if (!payerWalletSnap.exists)
          throw "Payer wallet does not exist: ${payer.name}, ${payer.id}";
        Wallet payerWallet = new Wallet.fromJson(payerWalletSnap.data);

        final DocumentReference bookRef = book.ref;
        DocumentSnapshot bookSnap = await tx.get(bookRef);
        Bookrecord fresh = new Bookrecord.fromJson(bookSnap.data);
        double amount = fresh.getPrice();

        // Check record record state and available amount
        if (fresh.holderId == holder.id &&
            fresh.holderId != fresh.ownerId &&
            fresh.ownerId != payer.id &&
            fresh.transitId == payer.id &&
            fresh.lent == true &&
            fresh.transit == true &&
            fresh.confirmed == true &&
            fresh.wish == false &&
            total(amount) < payerWallet.getAvailable()) {
          // Proceed with transaction
          DateTime start = DateTime.now();
          DateTime end = DateTime.now().add(Duration(days: rentDuration()));

          DocumentReference holderR1WalletRef,
              holderR2WalletRef,
              ownerR1WalletRef,
              ownerR2WalletRef,
              holderFeeSharingRef,
              ownerFeeSharingRef;
          DocumentSnapshot holderR1WalletSnap,
              holderR2WalletSnap,
              ownerR1WalletSnap,
              ownerR2WalletSnap,
              holderFeeSharingSnap,
              ownerFeeSharingSnap;

          final DocumentReference rewardRef = Operation.Ref(fresh.rewardId);
          DocumentSnapshot rewardSnap = await tx.get(rewardRef);
          Operation rewardOp = new Operation.fromJson(rewardSnap.data);

          final DocumentReference leasingRef = Operation.Ref(fresh.leasingId);
          DocumentSnapshot leasingSnap = await tx.get(leasingRef);
          Operation leasingOp = new Operation.fromJson(leasingSnap.data);

          // Read record of book owner user and his wallet to be able to update
          // it in transaction
          final DocumentReference ownerWalletRef = Wallet.Ref(fresh.ownerId);
          await tx.get(ownerWalletRef);

          final DocumentReference ownerRef = User.Ref(fresh.ownerId);
          DocumentSnapshot ownerSnap = await tx.get(ownerRef);
          User owner = new User.fromJson(ownerSnap.data);

          double price = leasingOp.price;

          // Calculate total and fees for the current date
          double portion = DateTime.now().difference(leasingOp.start).inDays /
              leasingOp.end.difference(leasingOp.start).inDays;

          // For Analitic ONLY
          days = DateTime.now().difference(leasingOp.start).inDays;

          // If rental less than first payment consider first payment as rental
          double rentAmount = price * portion;
          if (rentAmount < rewardOp.paid) rentAmount = leasingOp.paid;

          double feeAmount = fee(rentAmount);
          // Actual fee to pay (might be deducted)
          double deposit = leasingOp.deposit;
          double newPaid = first(price);

          // Reward owner. Take paid from Leasing operation NOT Reward
          double reward = rentAmount - leasingOp.paid;
          if (reward < 0.0) reward = 0.0;

          if (feeAmount + reward > holderWallet.getAvailable()) {
            // TODO: log event for the investigation
            print(
                '!!!DEBUG - NOT SIFFICIENT BALANCE ${holderWallet.id} !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
          }

          double payerFeeDeduction = 0.0, ownerFeeDeduction = 0.0;
          double systemFee = bbsFee(feeAmount);

          // Read referrals for the owner/holder in order to update their balance
          // Do not calculate referral fee if referrals are owner/holder
          if (owner.beneficiary1 != null && owner.beneficiary1 != holder.id) {
            ownerR1WalletRef = Wallet.Ref(owner.beneficiary1);
            ownerR1WalletSnap = await tx.get(ownerR1WalletRef);
            if (!ownerR1WalletSnap.exists)
              throw ('owner referral 1 wallet does not exist ${owner.beneficiary1}');
            leasingOp.ownerFeeUserId1 = owner.beneficiary1;
            leasingOp.ownerFee1 = beneficiary1(feeAmount);

            // Statistics only
            feeStat += leasingOp.ownerFee1;
          } else if (owner.beneficiary1 == holder.id) {
            ownerFeeDeduction += beneficiary1(feeAmount);
          } else {
            systemFee += beneficiary1(feeAmount);
          }

          if (owner.beneficiary2 != null && owner.beneficiary2 != holder.id) {
            ownerR2WalletRef = Wallet.Ref(owner.beneficiary2);
            ownerR2WalletSnap = await tx.get(ownerR2WalletRef);
            if (!ownerR2WalletSnap.exists)
              throw ('owner referral 2 wallet does not exist ${owner.beneficiary2}');

            // Get record to update feeSharing
            ownerFeeSharingRef = User.Ref(owner.beneficiary1);
            ownerFeeSharingSnap = await tx.get(ownerFeeSharingRef);
            if (!ownerFeeSharingSnap.exists)
              throw ('owner fee sharing user does not exist ${owner.beneficiary1}');

            leasingOp.ownerFeeUserId2 = owner.beneficiary2;
            leasingOp.ownerFee2 = beneficiary2(feeAmount);

            // Statistics only
            feeStat += leasingOp.ownerFee2;
          } else if (owner.beneficiary2 == holder.id) {
            ownerFeeDeduction += beneficiary2(feeAmount);
          } else {
            systemFee += beneficiary2(feeAmount);
          }

          if (holder.beneficiary1 != null && holder.beneficiary1 != owner.id) {
            holderR1WalletRef = Wallet.Ref(holder.beneficiary1);
            holderR1WalletSnap = await tx.get(holderR1WalletRef);
            if (!holderR1WalletSnap.exists)
              throw ('holder referral 1 wallet does not exist ${holder.beneficiary1}');
            leasingOp.payerFeeUserId1 = holder.beneficiary1;
            leasingOp.payerFee1 = beneficiary1(feeAmount);

            // Statistics only
            feeStat += leasingOp.payerFee1;
          } else if (holder.beneficiary1 == owner.id) {
            reward += beneficiary1(feeAmount);
            payerFeeDeduction += beneficiary1(feeAmount);
          } else {
            systemFee += beneficiary1(feeAmount);
          }

          if (holder.beneficiary2 != null && holder.beneficiary2 != owner.id) {
            holderR2WalletRef = Wallet.Ref(holder.beneficiary2);
            holderR2WalletSnap = await tx.get(holderR2WalletRef);
            if (!holderR2WalletSnap.exists)
              throw ('holder referral 2 wallet does not exist ${holder.beneficiary2}');

            // Get record to update feeSharing
            holderFeeSharingRef = User.Ref(holder.beneficiary1);
            holderFeeSharingSnap = await tx.get(holderFeeSharingRef);
            if (!holderFeeSharingSnap.exists)
              throw ('holder fee sharing user does not exist ${holder.beneficiary1}');

            leasingOp.payerFeeUserId2 = holder.beneficiary2;
            leasingOp.payerFee2 = beneficiary2(feeAmount);

            // Statistics only
            feeStat += leasingOp.payerFee2;
          } else if (holder.beneficiary2 == owner.id) {
            reward += beneficiary2(feeAmount);
            payerFeeDeduction += beneficiary2(feeAmount);
          } else {
            systemFee += beneficiary2(feeAmount);
          }

          // Update part of the transaction
          if (leasingOp.ownerFeeUserId1 != null) {
            await tx.update(ownerR1WalletRef,
                {'balance': FieldValue.increment(leasingOp.ownerFee1)});
            await tx.update(ownerRef,
                {'feeShared': FieldValue.increment(leasingOp.ownerFee1)});
          }

          if (leasingOp.ownerFeeUserId2 != null) {
            await tx.update(ownerR2WalletRef,
                {'balance': FieldValue.increment(leasingOp.ownerFee2)});
            await tx.update(ownerFeeSharingRef,
                {'feeShared': FieldValue.increment(leasingOp.ownerFee2)});
          }

          if (leasingOp.payerFeeUserId1 != null) {
            await tx.update(holderR1WalletRef,
                {'balance': FieldValue.increment(leasingOp.payerFee1)});
            await tx.update(holderRef,
                {'feeShared': FieldValue.increment(leasingOp.payerFee1)});
          }

          if (leasingOp.payerFeeUserId2 != null) {
            await tx.update(holderR2WalletRef,
                {'balance': FieldValue.increment(leasingOp.payerFee2)});
            await tx.update(holderFeeSharingRef,
                {'feeShared': FieldValue.increment(leasingOp.payerFee2)});
          }

          leasingOp.fee = systemFee;

          // TODO: Transaction fails if not all records updated.
          // TODO: Put update within IF once bug in cloud_firestore corrected
          // Pay reward to the owner together the old one and new one
          await tx.update(ownerWalletRef,
              {'balance': FieldValue.increment(newPaid + reward)});

          // This is dummy update to close transaction without exception
          await tx.update(ownerRef, {'distance': FieldValue.increment(0.0)});

          // Pay reward to the owner
          leasingOp.paid += reward;
          rewardOp.paid += reward + newPaid; // Different from complete
          rewardOp.amount = rewardOp.paid;
          rewardOp.date = DateTime.now();
          rewardOp.peerId = payer.id; // Different from complete

          // Update leasing operation
          leasingOp.amount = rentAmount + feeAmount - ownerFeeDeduction;
          leasingOp.deposit = 0.0;
          leasingOp.date = DateTime.now();

          // Deduct reward and fee from holder account and unblock
          await tx.update(holderWalletRef, {
            'balance': FieldValue.increment(
                -feeAmount - reward + ownerFeeDeduction + payerFeeDeduction),
            'blocked': FieldValue.increment(-deposit)
          });

          // Update leasing & reward operation
          await tx.update(rewardOp.ref, rewardOp.toJson());

          await tx.update(leasingOp.ref, leasingOp.toJson());

          // Create new leasing operation
          Operation newLeasingOp = new Operation(
            type: OperationType.Leasing,
            userId: payer.id,
            amount: deposit + newPaid,
            date: DateTime.now(),
            start: start,
            end: end,
            price: price,
            deposit: deposit,
            paid: newPaid,
            isbn: fresh.isbn,
            bookrecordId: fresh.id,
            peerId: fresh.ownerId,
          );

          await tx.set(newLeasingOp.ref, newLeasingOp.toJson());

          await tx.update(payerWalletRef, {
            'balance': FieldValue.increment(-newPaid),
            'blocked': FieldValue.increment(deposit)
          });

          final DocumentReference bookrecordRef = book.ref;

          // Update bookrecord with reference to operations
          await tx.update(bookrecordRef, {
            'leasingId': newLeasingOp.id,
            'holderId': payer.id,
            'holderName': payer.name,
            'holderImage': payer.photo,
            'transit': false,
            'confirmed': false,
            'lent': true,
            'transitId': null,
            'users': [fresh.ownerId, payer.id]
          });
        }
      } catch (ex, stack) {
        FlutterCrashlytics().logException(ex, stack);

        // TODO: Handle exception
        print(
            '!!!DEBUG: >>>>>>>>>>>>>> Exception within transaction <<<<<<<<<<<<<<<<');
        print(ex);
        print(stack);
      }
    });

    logAnalyticsEvent(name: 'book_pass', parameters: <String, dynamic>{
      'from': holder.id,
      'to': payer.id,
      'isbn': book.isbn,
      'price': book.getPrice(),
      'days': days,
      'distance': book.distance == double.infinity ? 50000.0 : book.distance,
    });

    logAnalyticsEvent(name: 'referral_reward', parameters: <String, dynamic>{
      'isbn': book.isbn,
      'price': book.getPrice(),
      'days': days,
      'fee': feeStat,
    });
  }
}

void complete({List<Bookrecord> books, User holder, User owner}) async {
  for (Bookrecord book in books) {
    int days = 0;
    double feeStat = 0.0;
    final DocumentReference holderRef = holder.ref;
    final DocumentReference ownerRef = owner.ref;
    final DocumentReference holderWalletRef = Wallet.Ref(holder.id);
    final DocumentReference ownerWalletRef = Wallet.Ref(owner.id);
    await db.runTransaction((Transaction tx) async {
      try {
        DocumentReference ownerR1WalletRef,
            ownerR2WalletRef,
            holderR1WalletRef,
            holderR2WalletRef,
            ownerFeeSharingRef,
            holderFeeSharingRef;
        DocumentSnapshot ownerR1WalletSnap,
            ownerR2WalletSnap,
            holderR1WalletSnap,
            holderR2WalletSnap,
            ownerFeeSharingSnap,
            holderFeeSharingSnap;

        // Get record for holder wallet
        DocumentSnapshot holderWalletSnap = await tx.get(holderWalletRef);
        if (!holderWalletSnap.exists)
          throw "User wallet does not exist: ${holder.name}, ${holder.id}";
        Wallet holderWallet = new Wallet.fromJson(holderWalletSnap.data);

        // Get record for owner wallet
        DocumentSnapshot ownerWalletSnap = await tx.get(ownerWalletRef);
        if (!ownerWalletSnap.exists)
          throw "User wallet does not exist: ${owner.name}, ${owner.id}";

        /* Remove no use
        DocumentSnapshot holderSnap = await tx.get(holderRef);
        if (!holderSnap.exists)
          throw ('Holder user does not exist ${holder.name}, ${holder.id}');

        DocumentSnapshot ownerSnap = await tx.get(ownerRef);
        if (!ownerSnap.exists)
          throw ('Owner user does not exist ${owner.name}, ${owner.id}');
        */

        DocumentSnapshot bookSnap = await tx.get(book.ref);
        if (!bookSnap.exists)
          throw ('Bookrecord does not exist ${book.id},  ${book.isbn}');

        // Get a fresh data of book record
        Bookrecord fresh = new Bookrecord.fromJson(bookSnap.data);

        // Only proceed if correct book record state
        if (fresh.holderId == holder.id &&
            fresh.ownerId == owner.id &&
            fresh.transitId == owner.id &&
            fresh.lent == true &&
            fresh.transit == true &&
            fresh.confirmed == true &&
            fresh.wish == false) {
          // Read record of refferals to be able to update it in transaction
          final DocumentReference rewardRef = Operation.Ref(fresh.rewardId);
          DocumentSnapshot rewardSnap = await tx.get(rewardRef);
          if (!rewardSnap.exists)
            throw ('Reward operation does not exist: ${fresh.id} ${fresh.rewardId}');
          Operation rewardOp = new Operation.fromJson(rewardSnap.data);

          final DocumentReference leasingRef = Operation.Ref(fresh.leasingId);
          DocumentSnapshot leasingSnap = await tx.get(leasingRef);
          if (!leasingSnap.exists)
            throw ('Leasing operation does not exist: ${fresh.id} ${fresh.leasingId}');
          Operation leasingOp = new Operation.fromJson(leasingSnap.data);

          double price = leasingOp.price;

          // Calculate total and fees for the current date
          double portion = DateTime.now().difference(leasingOp.start).inDays /
              leasingOp.end.difference(leasingOp.start).inDays;

          // For Analitic ONLY
          days = DateTime.now().difference(leasingOp.start).inDays;

          double rentAmount = price * portion;
          if (rentAmount < leasingOp.paid) rentAmount = leasingOp.paid;

          // Actual fee to pay (might be deducted)
          double feeAmount = fee(rentAmount);
          double deposit = leasingOp.deposit;

          // Reward owner
          double reward = rentAmount - leasingOp.paid;
          if (reward < 0.0) reward = 0.0;

          if (feeAmount + reward > holderWallet.balance) {
            // TODO: log event for the investigation
            print(
                '!!!DEBUG - NOT SIFFICIENT BALANCE ${holder.id} ${holderWallet.balance} ${rentAmount} ${leasingOp.paid} ${reward}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
          }

          double payerFeeDeduction = 0.0, ownerFeeDeduction = 0.0;
          double systemFee = bbsFee(feeAmount);

          // Read referrals for the owner/holder in order to update their balance
          // Do not calculate referral fee if referrals are owner/holder
          if (owner.beneficiary1 != null && owner.beneficiary1 != holder.id) {
            ownerR1WalletRef = Wallet.Ref(owner.beneficiary1);
            ownerR1WalletSnap = await tx.get(ownerR1WalletRef);
            if (!ownerR1WalletSnap.exists)
              throw ('owner referral 1 wallet does not exist ${owner.beneficiary1}');
            leasingOp.ownerFeeUserId1 = owner.beneficiary1;
            leasingOp.ownerFee1 = beneficiary1(feeAmount);

            // Statistics only
            feeStat += leasingOp.ownerFee1;
          } else if (owner.beneficiary1 == holder.id) {
            ownerFeeDeduction += beneficiary1(feeAmount);
          } else {
            systemFee += beneficiary1(feeAmount);
          }

          if (owner.beneficiary2 != null && owner.beneficiary2 != holder.id) {
            ownerR2WalletRef = Wallet.Ref(owner.beneficiary2);
            ownerR2WalletSnap = await tx.get(ownerR2WalletRef);
            if (!ownerR2WalletSnap.exists)
              throw ('owner referral 2 wallet does not exist ${owner.beneficiary2}');

            // Get record to update feeSharing
            ownerFeeSharingRef = User.Ref(owner.beneficiary1);
            ownerFeeSharingSnap = await tx.get(ownerFeeSharingRef);
            if (!ownerFeeSharingSnap.exists)
              throw ('owner fee sharing user does not exist ${owner.beneficiary1}');

            leasingOp.ownerFeeUserId2 = owner.beneficiary2;
            leasingOp.ownerFee2 = beneficiary2(feeAmount);

            // Statistics only
            feeStat += leasingOp.ownerFee2;
          } else if (owner.beneficiary2 == holder.id) {
            ownerFeeDeduction += beneficiary2(feeAmount);
          } else {
            systemFee += beneficiary2(feeAmount);
          }

          if (holder.beneficiary1 != null && holder.beneficiary1 != owner.id) {
            holderR1WalletRef = Wallet.Ref(holder.beneficiary1);
            holderR1WalletSnap = await tx.get(holderR1WalletRef);
            if (!holderR1WalletSnap.exists)
              throw ('holder referral 1 wallet does not exist ${holder.beneficiary1}');
            leasingOp.payerFeeUserId1 = holder.beneficiary1;
            leasingOp.payerFee1 = beneficiary1(feeAmount);

            // Statistics only
            feeStat += leasingOp.payerFee1;
          } else if (holder.beneficiary1 == owner.id) {
            reward += beneficiary1(feeAmount);
            payerFeeDeduction += beneficiary1(feeAmount);
          } else {
            systemFee += beneficiary1(feeAmount);
          }

          if (holder.beneficiary2 != null && holder.beneficiary2 != owner.id) {
            holderR2WalletRef = Wallet.Ref(holder.beneficiary2);
            holderR2WalletSnap = await tx.get(holderR2WalletRef);
            if (!holderR2WalletSnap.exists)
              throw ('holder referral 2 wallet does not exist ${holder.beneficiary2}');

            // Get record to update feeSharing
            holderFeeSharingRef = User.Ref(holder.beneficiary1);
            holderFeeSharingSnap = await tx.get(holderFeeSharingRef);
            if (!holderFeeSharingSnap.exists)
              throw ('holder fee sharing user does not exist ${holder.beneficiary1}');

            leasingOp.payerFeeUserId2 = holder.beneficiary2;
            leasingOp.payerFee2 = beneficiary2(feeAmount);

            // Statistics only
            feeStat += leasingOp.payerFee2;
          } else if (holder.beneficiary2 == owner.id) {
            reward += beneficiary2(feeAmount);
            payerFeeDeduction += beneficiary2(feeAmount);
          } else {
            systemFee += beneficiary2(feeAmount);
          }

          // Update part of the transaction
          if (leasingOp.ownerFeeUserId1 != null) {
            await tx.update(ownerR1WalletRef,
                {'balance': FieldValue.increment(leasingOp.ownerFee1)});
            await tx.update(ownerRef,
                {'feeShared': FieldValue.increment(leasingOp.ownerFee1)});
          }

          if (leasingOp.ownerFeeUserId2 != null) {
            await tx.update(ownerR2WalletRef,
                {'balance': FieldValue.increment(leasingOp.ownerFee2)});
            await tx.update(ownerFeeSharingRef,
                {'feeShared': FieldValue.increment(leasingOp.ownerFee2)});
          }

          if (leasingOp.payerFeeUserId1 != null) {
            await tx.update(holderR1WalletRef,
                {'balance': FieldValue.increment(leasingOp.payerFee1)});
            await tx.update(holderRef,
                {'feeShared': FieldValue.increment(leasingOp.payerFee1)});
          }

          if (leasingOp.payerFeeUserId2 != null) {
            await tx.update(holderR2WalletRef,
                {'balance': FieldValue.increment(leasingOp.payerFee2)});
            await tx.update(holderFeeSharingRef,
                {'feeShared': FieldValue.increment(leasingOp.payerFee2)});
          }

          leasingOp.fee = systemFee;

          // TODO: Transaction fails if not all records updated.
          // TODO: Put update within IF once bug in cloud_firestore corrected
          await tx.update(
              ownerWalletRef, {'balance': FieldValue.increment(reward)});

          if (reward > 0) {
            // Pay reward to the owner
            leasingOp.paid += reward;
            rewardOp.paid += reward;
            rewardOp.amount = rewardOp.paid;
            rewardOp.date = DateTime.now();
          }

          // Update leasing operation
          leasingOp.amount = rentAmount + feeAmount - ownerFeeDeduction;
          leasingOp.deposit = 0.0;
          leasingOp.date = DateTime.now();

          // Deduct reward and fee from holder account and unblock
          await tx.update(holderWalletRef, {
            'balance': FieldValue.increment(
                -feeAmount - reward + ownerFeeDeduction + payerFeeDeduction),
            'blocked': FieldValue.increment(-deposit)
          });

          // Update leasing & reward operation
          await tx.update(rewardOp.ref, rewardOp.toJson());

          await tx.update(leasingOp.ref, leasingOp.toJson());

          final DocumentReference bookrecordRef = book.ref;

          // Update bookrecord with reference to operations
          await tx.update(bookrecordRef, {
            'leasingId': null,
            'rewardId': null,
            'holderId': owner.id,
            'holderName': owner.name,
            'holderImage': owner.photo,
            'transit': false,
            'confirmed': false,
            'lent': false,
            'transitId': null,
            'users': [owner.id]
          });
        }
      } catch (ex, stack) {
        FlutterCrashlytics().logException(ex, stack);

        // TODO: Handle exception
        print('!!!DEBUG: >>>>>>>>>> Exception within transaction <<<<<<<<<<<');
        print(ex);
        print(stack);
      }

      return;
    });

    logAnalyticsEvent(name: 'book_returned', parameters: <String, dynamic>{
      'from': holder.id,
      'to': owner.id,
      'isbn': book.isbn,
      'price': book.getPrice(),
      'days': days,
      'distance': book.distance == double.infinity ? 50000.0 : book.distance,
    });

    logAnalyticsEvent(name: 'referral_reward', parameters: <String, dynamic>{
      'isbn': book.isbn,
      'price': book.getPrice(),
      'days': days,
      'fee': feeStat,
    });
  }
}

Future<Operation> payment(
    {User user, double amount, OperationType type}) async {
  if (type != OperationType.InputInApp && type != OperationType.InputStellar)
    return null;

  Operation op = new Operation(
      type: type, userId: user.id, amount: amount, date: DateTime.now());
  final DocumentReference walletRef = Wallet.Ref(user.id);
  final DocumentReference opRef = op.ref;
  await db.runTransaction((Transaction tx) async {
    await tx.get(walletRef);
    await tx.update(walletRef, {'balance': FieldValue.increment(amount)});
    await tx.set(opRef, op.toJson());
  });

  return op;
}

double total(double price) {
  return price * 1.2;
}

double monthly(double price) {
  return total(price) * 30 / rentDuration();
}

// Monthly income for the book owner
double income(double price) {
  return price * 30 / rentDuration();
}

double first(double price) {
  return price / 6;
}

double fee(double price) {
  return price * 0.2;
}

double bbsFee(double fee) {
  return fee * 0.5;
}

double beneficiary1(double fee) {
  return fee * 0.15;
}

double beneficiary2(double fee) {
  return fee * 0.10;
}

int rentDuration() {
  return 183;
}
