import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:biblosphere/const.dart';
import 'package:biblosphere/helpers.dart';
import 'package:biblosphere/search.dart';
import 'package:biblosphere/l10n.dart';

//Callback function type definition
typedef BookCallback(Book book);

Future addBookrecord(
    BuildContext context, Book b, User u, bool wish, GeoFirePoint location,
    {String source = 'goodreads', bool snackbar = true}) async {
  bool existingBook = false;

  if (b.isbn == null || b.isbn == 'NA')
    throw 'Book ${b?.title}, ${b?.authors?.join()} has no ISBN';

  //Try to get image if missing
  if (b.image == null ||
      b.image.isEmpty ||
      b.language == null ||
      b.language.isEmpty) {
    b = await enrichBookRecord(b);
  }

  QuerySnapshot q = await Firestore.instance
      .collection('books')
      .where('isbn', isEqualTo: b.isbn)
      .getDocuments();

  if (q.documents.isEmpty) {
    await b.ref().setData(b.toJson());
  } else {
    existingBook = true;
    b.id = q.documents.first.documentID;
  }

  Bookrecord bookrecord = new Bookrecord(
      ownerId: u.id, bookId: b.id, wish: wish, location: location);

  //Check if bookrecord already exist. Make sense only if isbn is registered
  if (existingBook) {
    QuerySnapshot q = await Firestore.instance
        .collection('bookrecords')
        .where('bookId', isEqualTo: b.id)
        .where('ownerId', isEqualTo: u.id)
        .where('wish', isEqualTo: wish)
        .getDocuments();

    //If bookcopy already exist refresh it
    if (q.documents.isNotEmpty) {
      bookrecord.id = q.documents.first.documentID;
      await Firestore.instance
          .collection('bookrecords')
          .document(bookrecord.id)
          .updateData(bookrecord.toJson());
      //if (snackbar) showSnackBar(context, 'KuKu');
      return;
    }
  }

  await bookrecord.ref().setData(bookrecord.toJson());
  if (snackbar) {
    if (wish)
      showSnackBar(context, S.of(context).wishAdded);
    else
      showSnackBar(context, S.of(context).bookAdded);
  }

  await FirebaseAnalytics().logEvent(
      name: 'add_book',
      parameters: <String, dynamic>{'language': b.language ?? ''});
}

void deposit({List<Bookrecord> books, User owner, User payer}) async {
  final DocumentReference ownerRef = User.Ref(owner.id);
  final DocumentReference payerRef = User.Ref(payer.id);
  await db.runTransaction((Transaction tx) async {
    DocumentSnapshot payerSnap = await tx.get(payerRef);
    User payerLast = new User.fromJson(payerSnap.data);

    double amount = 0.0;
    List<Bookrecord> included = [];

    await Future.forEach(books, (rec) async {
      final DocumentReference bookRef = rec.ref();
      DocumentSnapshot bookSnap = await tx.get(bookRef);
      Bookrecord fresh = new Bookrecord.fromJson(bookSnap.data);
      if (fresh.holderId == owner.id &&
          fresh.transitId == payer.id &&
          fresh.lent == false &&
          fresh.transit == true &&
          fresh.wish == false) {
        // Add book price to transaction amount
        amount += fresh.getPrice();

        // Add record to transaction
        included.add(fresh);
      }
    });

    // Check that up-to-date balance is sufficient
    if (total(amount) < payerLast.getAvailable()) {
      // First payment
      double paidTotal = 0.0;
      // Deposit
      double depositTotal = 0.0;

      DateTime start = DateTime.now();
      DateTime end = DateTime.now().add(Duration(days: rentDuration()));

      // Create operations and update bookrecords
      await Future.forEach(included, (rec) async {
        double price = rec.getPrice();
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
            peerId: payerLast.id,
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
            bookId: rec.bookId,
            bookrecordId: rec.id,
            peerId: owner.id);

        final DocumentReference rewardRef = rewardOp.ref();
        final DocumentReference leasingRef = leasingOp.ref();
        final DocumentReference bookrecordRef = rec.ref();

        // Create operations and update bookrecord with reference to operations
        await tx.set(rewardRef, rewardOp.toJson());
        await tx.set(leasingRef, leasingOp.toJson());
        await tx.update(bookrecordRef, {
          'rewardId': rewardOp.id,
          'leasingId': leasingOp.id,
          'holderId': payer.id,
          'transit': false,
          'lent': true,
          'transitId': null,
          'users': [owner.id, payer.id]
        });

        // Sum up paid and deposited amounts
        paidTotal += paid;
        depositTotal += deposit;
      });

      // Update balance and blocked for Owner and Payer
      await tx.update(payerRef, {
        'balance': FieldValue.increment(-paidTotal),
        'blocked': FieldValue.increment(depositTotal)
      });
      await tx.update(ownerRef, {'balance': FieldValue.increment(paidTotal)});
    }
  });
}

void pass({List<Bookrecord> books, User holder, User payer}) async {
  final DocumentReference holderRef = holder.ref();
  final DocumentReference payerRef = payer.ref();
  await db.runTransaction((Transaction tx) async {
    DocumentSnapshot holderSnap = await tx.get(holderRef);
    User holderLast = new User.fromJson(holderSnap.data);
    DocumentSnapshot payerSnap = await tx.get(payerRef);
    User payerLast = new User.fromJson(payerSnap.data);

    double amount = 0.0;
    List<Bookrecord> included = [];

    await Future.forEach(books, (rec) async {
      final DocumentReference bookRef = rec.ref();
      DocumentSnapshot bookSnap = await tx.get(bookRef);
      Bookrecord fresh = new Bookrecord.fromJson(bookSnap.data);
      if (fresh.holderId == holder.id &&
          fresh.holderId != fresh.ownerId &&
          fresh.ownerId != payer.id &&
          fresh.transitId == payer.id &&
          fresh.lent == true &&
          fresh.transit == true &&
          fresh.wish == false) {
        // Add book price to transaction amount
        amount += fresh.getPrice();

        // Add record to transaction
        included.add(fresh);
      }
    });

    // Check that up-to-date balance is sufficient
    if (total(amount) < payerLast.getAvailable()) {
      DateTime start = DateTime.now();
      DateTime end = DateTime.now().add(Duration(days: rentDuration()));

      Map<String, Operation> rewards = {};
      Map<String, Operation> leasings = {};

      // Read referrals for the payer in order to update their balance
      if (payer.beneficiary1 != null) {
        final DocumentReference userRef = User.Ref(payer.beneficiary1);
        await tx.get(userRef);
      }

      if (payer.beneficiary2 != null) {
        final DocumentReference userRef = User.Ref(payer.beneficiary2);
        await tx.get(userRef);
      }

      // Read all records which are going to be changed (Firestore requirment)
      await Future.forEach(included, (rec) async {
        final DocumentReference rewardRef = Operation.Ref(rec.rewardId);
        DocumentSnapshot rewardSnap = await tx.get(rewardRef);
        Operation rewardOp = new Operation.fromJson(rewardSnap.data);
        rewards.addAll({rewardOp.id: rewardOp});

        final DocumentReference leasingRef = Operation.Ref(rec.leasingId);
        DocumentSnapshot leasingSnap = await tx.get(leasingRef);
        Operation leasingOp = new Operation.fromJson(leasingSnap.data);

        // Read record of book owner user to be able to update it in transaction
        final DocumentReference ownerRef = User.Ref(rec.ownerId);
        DocumentSnapshot ownerSnap = await tx.get(ownerRef);
        User owner = new User.fromJson(ownerSnap.data);

        // Read record of refferals to be able to update it in transaction
        if (owner.beneficiary1 != null) {
          final DocumentReference userRef = User.Ref(owner.beneficiary1);
          await tx.get(userRef);
          leasingOp.ownerFeeUserId1 = owner.beneficiary1;
        }

        // Read record of refferals to be able to update it in transaction
        if (owner.beneficiary2 != null) {
          final DocumentReference userRef = User.Ref(owner.beneficiary2);
          await tx.get(userRef);
          leasingOp.ownerFeeUserId2 = owner.beneficiary2;
        }

        if (payerLast.beneficiary1 != null) {
          leasingOp.payerFeeUserId1 = payer.beneficiary1;
        }

        if (payerLast.beneficiary2 != null) {
          leasingOp.payerFeeUserId2 = payer.beneficiary2;
        }

        leasings.addAll({leasingOp.id: leasingOp});
      });

      // Create/update operations and update bookrecords
      await Future.forEach(included, (Bookrecord rec) async {
        final ownerRef = User.Ref(rec.ownerId);
        Operation oldRewardOp = rewards[rec.rewardId];
        Operation oldLeasingOp = leasings[rec.leasingId];

        double price = oldLeasingOp.price;

        // Calculate total and fees for the current date
        double portion = DateTime.now().difference(oldLeasingOp.start).inDays /
            oldLeasingOp.end.difference(oldLeasingOp.start).inDays;

        // If rental less than first payment consider first payment as rental
        double rentAmount = price * portion;
        if (rentAmount < oldRewardOp.paid) rentAmount = oldLeasingOp.paid;

        double feeAmount = fee(rentAmount);

        // Reward owner. Take paid from Leasing operation NOT Reward
        double reward = rentAmount - oldLeasingOp.paid;
        if (reward < 0.0) reward = 0.0;

        if (feeAmount + reward > holderLast.balance) {
          // TODO: log event for the investigation
          print(
              '!!!DEBUG - NOT SIFFICIENT BALANCE ${holderLast.id} !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        }

        // Deduct reward and fee from holder acount
        await tx.update(
            holderRef, {'balance': FieldValue.increment(-feeAmount - reward)});
        oldLeasingOp.amount = rentAmount + feeAmount;

        double systemFee = feeAmount * 0.5;
        if (oldLeasingOp.payerFeeUserId1 != null) {
          oldLeasingOp.payerFee1 = beneficiary1(feeAmount);
          final userRef = User.Ref(oldLeasingOp.payerFeeUserId1);
          await tx.update(userRef,
              {'balance': FieldValue.increment(oldLeasingOp.payerFee1)});
        } else {
          systemFee += beneficiary1(feeAmount);
        }

        if (oldLeasingOp.payerFeeUserId2 != null) {
          oldLeasingOp.payerFee2 = beneficiary2(feeAmount);
          final userRef = User.Ref(oldLeasingOp.payerFeeUserId2);
          await tx.update(userRef,
              {'balance': FieldValue.increment(oldLeasingOp.payerFee2)});
        } else {
          systemFee += beneficiary2(feeAmount);
        }

        if (oldLeasingOp.ownerFeeUserId1 != null) {
          oldLeasingOp.ownerFee1 = beneficiary1(feeAmount);
          final userRef = User.Ref(oldLeasingOp.ownerFeeUserId1);
          await tx.update(userRef,
              {'balance': FieldValue.increment(oldLeasingOp.ownerFee1)});
        } else {
          systemFee += beneficiary1(feeAmount);
        }

        if (oldLeasingOp.ownerFeeUserId2 != null) {
          oldLeasingOp.ownerFee2 = beneficiary2(feeAmount);
          final userRef = User.Ref(oldLeasingOp.ownerFeeUserId2);
          await tx.update(userRef,
              {'balance': FieldValue.increment(oldLeasingOp.ownerFee2)});
        } else {
          systemFee += beneficiary2(feeAmount);
        }

        oldLeasingOp.fee = systemFee;

        if (reward > 0) {
          // Pay reward to the owner
          await tx.update(ownerRef, {'balance': FieldValue.increment(reward)});
          oldLeasingOp.paid += reward;
          oldRewardOp.paid += reward;
          oldRewardOp.amount = oldRewardOp.paid;
          oldRewardOp.date = DateTime.now();
        }

        // Unblock holder account & update leasing operation
        await tx.update(holderRef,
            {'blocked': FieldValue.increment(-oldLeasingOp.deposit)});
        oldLeasingOp.deposit = 0.0;
        oldLeasingOp.date = DateTime.now();

        // Update old leasing operation
        await tx.update(oldLeasingOp.ref(), oldLeasingOp.toJson());

        double newPaid = first(price);
        double deposit = total(price) - newPaid;

        // Update old leasing operation
        oldRewardOp.paid += newPaid;
        oldRewardOp.amount = oldRewardOp.paid;
        oldRewardOp.peerId = payerLast.id;
        await tx.update(oldRewardOp.ref(), oldRewardOp.toJson());
        await tx.update(ownerRef, {'balance': FieldValue.increment(newPaid)});

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
          bookId: rec.bookId,
          bookrecordId: rec.id,
          peerId: rec.ownerId,
        );

        await tx.update(newLeasingOp.ref(), newLeasingOp.toJson());

        await tx.update(payerRef, {
          'balance': FieldValue.increment(-newPaid),
          'blocked': FieldValue.increment(deposit)
        });

        final DocumentReference bookrecordRef = rec.ref();

        // Update bookrecord with reference to operations
        await tx.update(bookrecordRef, {
          'leasingId': newLeasingOp.id,
          'holderId': payer.id,
          'transit': false,
          'lent': true,
          'transitId': null,
          'users': [rec.ownerId, payer.id]
        });
      });
    }
  });
}

void complete({List<Bookrecord> books, User holder, User owner}) async {
  final DocumentReference holderRef = holder.ref();
  final DocumentReference ownerRef = owner.ref();
  await db.runTransaction((Transaction tx) async {
    try {
      DocumentSnapshot holderSnap = await tx.get(holderRef);
      if (!holderSnap.exists) throw ('Holder does not exist');

      User holderLast = new User.fromJson(holderSnap.data);

      DocumentSnapshot ownerSnap = await tx.get(ownerRef);
      if (!ownerSnap.exists) {
        throw ('User does not exist in DB');
      }
      User ownerLast = new User.fromJson(ownerSnap.data);

      List<Bookrecord> included = [];

      for (Bookrecord rec in books) {
        final DocumentReference bookRef = rec.ref();
        DocumentSnapshot bookSnap = await tx.get(bookRef);
        if (!bookSnap.exists) throw ('Bookrecord does not exist');
        Bookrecord fresh = new Bookrecord.fromJson(bookSnap.data);
        if (fresh.holderId == holder.id &&
            fresh.ownerId == owner.id &&
            fresh.transitId == owner.id &&
            fresh.lent == true &&
            fresh.transit == true &&
            fresh.wish == false) {
          // Add record to transaction
          included.add(fresh);
        }
      }
      ;

      Map<String, Operation> rewards = {};
      Map<String, Operation> leasings = {};

      // Read referrals for the owner/holder in order to update their balance
      // Do not calculate referral fee if referrals are owner/holder
      if (ownerLast.beneficiary1 != null && ownerLast.beneficiary1 != holderLast.id) {
        final DocumentReference userRef = User.Ref(ownerLast.beneficiary1);
        DocumentSnapshot userSnap = await tx.get(userRef);
        if (!userSnap.exists) throw ('User does not exist');
      }

      if (ownerLast.beneficiary2 != null && ownerLast.beneficiary1 != holderLast.id) {
        final DocumentReference userRef = User.Ref(ownerLast.beneficiary2);
        DocumentSnapshot userSnap = await tx.get(userRef);
        if (!userSnap.exists) throw ('User does not exist');
      }

      if (holderLast.beneficiary1 != null && holderLast.beneficiary1 != ownerLast.id) {
        final DocumentReference userRef = User.Ref(holderLast.beneficiary1);
        DocumentSnapshot userSnap = await tx.get(userRef);
        if (!userSnap.exists) throw ('User does not exist');
      }

      if (holderLast.beneficiary2 != null && holderLast.beneficiary1 != ownerLast.id) {
        final DocumentReference userRef = User.Ref(holderLast.beneficiary2);
        DocumentSnapshot userSnap = await tx.get(userRef);
        if (!userSnap.exists) throw ('User does not exist');
      }

      // Read all records which are going to be changed (Firestore requirment)
      for (Bookrecord rec in included) {
        final DocumentReference rewardRef = Operation.Ref(rec.rewardId);
        DocumentSnapshot rewardSnap = await tx.get(rewardRef);
        if (!rewardSnap.exists) throw ('Reward operation does not exist');
        Operation rewardOp = new Operation.fromJson(rewardSnap.data);
        rewards.addAll({rewardOp.id: rewardOp});

        final DocumentReference leasingRef = Operation.Ref(rec.leasingId);
        DocumentSnapshot leasingSnap = await tx.get(leasingRef);
        if (!leasingSnap.exists) throw ('Leasing operation does not exist');
        Operation leasingOp = new Operation.fromJson(leasingSnap.data);

        // Read record of refferals to be able to update it in transaction
        if (ownerLast.beneficiary1 != null && ownerLast.beneficiary1 != holderLast.id) {
          leasingOp.ownerFeeUserId1 = owner.beneficiary1;
        }

        if (ownerLast.beneficiary2 != null && ownerLast.beneficiary2 != holderLast.id) {
          leasingOp.ownerFeeUserId2 = owner.beneficiary2;
        }

        if (holderLast.beneficiary1 != null && holderLast.beneficiary1 != ownerLast.id) {
          leasingOp.payerFeeUserId1 = holderLast.beneficiary1;
        }

        if (holderLast.beneficiary2 != null && holderLast.beneficiary2 != ownerLast.id) {
          leasingOp.payerFeeUserId2 = holderLast.beneficiary2;
        }

        leasings.addAll({leasingOp.id: leasingOp});
      }
      ;

      // Create/update operations and update bookrecords
      for (Bookrecord rec in included) {
        Operation rewardOp = rewards[rec.rewardId];
        Operation leasingOp = leasings[rec.leasingId];

        double price = leasingOp.price;

        // Calculate total and fees for the current date
        double portion = DateTime.now().difference(leasingOp.start).inDays /
            leasingOp.end.difference(leasingOp.start).inDays;

        double rentAmount = price * portion;
        if (rentAmount < leasingOp.paid) rentAmount = leasingOp.paid;

        // Actual fee to pay (might be deducted)
        double feeAmount = fee(rentAmount);
        double deposit = leasingOp.deposit;

        // Reward owner
        double reward = rentAmount - leasingOp.paid;
        if (reward < 0.0) reward = 0.0;

        if (feeAmount + reward > holderLast.balance) {
          // TODO: log event for the investigation
          print(
              '!!!DEBUG - NOT SIFFICIENT BALANCE ${holderLast.id} ${holderLast.balance} ${rentAmount} ${leasingOp.paid} ${reward}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        }

        double payerFeeDeduction = 0.0, ownerFeeDeduction = 0.0;

        double systemFee = bbsFee(feeAmount);
        if (leasingOp.payerFeeUserId1 != null) {
          leasingOp.payerFee1 = beneficiary1(feeAmount);
          final userRef = User.Ref(leasingOp.payerFeeUserId1);
          await tx.update(
              userRef, {'balance': FieldValue.increment(leasingOp.payerFee1)});
          await tx.update(
              holderRef, {'feeShared': FieldValue.increment(leasingOp.payerFee1)});
        } else if (holderLast.beneficiary1 == ownerLast.id) {
          reward += beneficiary1(feeAmount);
          payerFeeDeduction += beneficiary1(feeAmount);
        } else {
          systemFee += beneficiary1(feeAmount);
        }

        if (leasingOp.payerFeeUserId2 != null) {
          leasingOp.payerFee2 = beneficiary2(feeAmount);
          final userRef = User.Ref(leasingOp.payerFeeUserId2);
          final referralRef = User.Ref(holderLast.beneficiary1); // Use reference from user leasingOp.payerFeeUserId1 might be empty if ownerId
          await tx.update(
              userRef, {'balance': FieldValue.increment(leasingOp.payerFee2)});
          await tx.update(
              referralRef, {'feeShared': FieldValue.increment(leasingOp.payerFee2)});
        } else if (holderLast.beneficiary2 == ownerLast.id) {
          reward += beneficiary2(feeAmount);
          payerFeeDeduction += beneficiary2(feeAmount);
        } else {
          systemFee += beneficiary2(feeAmount);
        }

        if (leasingOp.ownerFeeUserId1 != null) {
          leasingOp.ownerFee1 = beneficiary1(feeAmount);
          final userRef = User.Ref(leasingOp.ownerFeeUserId1);
          await tx.update(
              userRef, {'balance': FieldValue.increment(leasingOp.ownerFee1)});
          await tx.update(
              ownerRef, {'feeShared': FieldValue.increment(leasingOp.ownerFee1)});
        } else if (ownerLast.beneficiary1 == holderLast.id) {
          ownerFeeDeduction += beneficiary1(feeAmount);
        } else {
          systemFee += beneficiary1(feeAmount);
        }

        if (leasingOp.ownerFeeUserId2 != null) {
          leasingOp.ownerFee2 = beneficiary2(feeAmount);
          final userRef = User.Ref(leasingOp.ownerFeeUserId2);
          final referralRef = User.Ref(ownerLast.beneficiary1);
          await tx.update(
              userRef, {'balance': FieldValue.increment(leasingOp.ownerFee2)});
          await tx.update(
              referralRef, {'feeShared': FieldValue.increment(leasingOp.ownerFee2)});
        } else if (ownerLast.beneficiary2 == holderLast.id) {
          ownerFeeDeduction += beneficiary2(feeAmount);
        } else {
          systemFee += beneficiary2(feeAmount);
        }

        leasingOp.fee = systemFee;

        // TODO: Transaction fails if not all records updated.
        // TODO: Put update within IF once bug in cloud_firestore corrected
        await tx.update(ownerRef, {'balance': FieldValue.increment(reward)});

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
        await tx.update(holderRef, {
          'balance': FieldValue.increment(-feeAmount-reward+ownerFeeDeduction+payerFeeDeduction),
          'blocked': FieldValue.increment(-deposit)
        });

        // Update leasing & reward operation
        await tx.set(rewardOp.ref(), rewardOp.toJson());

        await tx.set(leasingOp.ref(), leasingOp.toJson());

        final DocumentReference bookrecordRef = rec.ref();

        // Update bookrecord with reference to operations
        await tx.update(bookrecordRef, {
          'leasingId': null,
          'rewardId': null,
          'holderId': ownerLast.id,
          'transit': false,
          'lent': false,
          'transitId': null,
          'users': [ownerLast.id]
        });
      };
    } catch (ex, stack) {
      print(
          '!!!DEBUG: >>>>>>>>>>>>>> Exception within transaction <<<<<<<<<<<<<<<<');
      print(ex);
      print(stack);
    }

    return;
  }, timeout: Duration(seconds: 25));
}

Future<Operation> payment(
    {User user, double amount, OperationType type}) async {
  if (type != OperationType.InputInApp && type != OperationType.InputStellar)
    return null;

  Operation op = new Operation(
      type: type, userId: user.id, amount: amount, date: DateTime.now());
  final DocumentReference userRef = user.ref();
  final DocumentReference opRef = op.ref();
  await db.runTransaction((Transaction tx) async {
    await tx.get(userRef);
    await tx.update(userRef, {'balance': FieldValue.increment(amount)});
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
