import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

Random rng = new Random();
Map<String, Map<String, dynamic>> collections = {};

class MockDocumentSnapshot extends Fake implements DocumentSnapshot {
  DocumentReference ref;
  Map<String, dynamic> data;

  MockDocumentSnapshot({this.ref, this.data});

  @override
  bool get exists => true;
}

class MockDocumentReference extends Fake implements DocumentReference {
  String col;
  String documentID;
  MockDocumentReference({this.col, this.documentID});

  @override
  // TODO: implement path
  String get path => col+ '/' + documentID;

  @override
  Future<DocumentSnapshot> get ({
    Source source: Source.serverAndCache
  }) async {
    if (collections[col] != null && collections[col][documentID] != null)
      return new MockDocumentSnapshot(ref: this, data: collections[col][documentID]);
    else
      return null;
  }

  @override
  Future<void> setData (
      Map<String, dynamic> data, {
        bool merge: false
      }) {
    if( collections[col] == null) {
      collections.addAll({col: {documentID: data}});
    } else if (collections[col][documentID] == null) {
      collections[col].addAll({documentID: data});
    } else {
      collections[col][documentID] = data;
    }
    return Future.delayed(Duration(seconds: 0));
  }

  @override
  Future<void> updateData (
      Map<String, dynamic> data, {
        bool merge: false
      }) {
    if( collections[col] == null) {
      collections.addAll({col: {documentID: data}});
    } else if (collections[col][documentID] == null) {
      collections[col].addAll({documentID: data});
    } else {
      data.forEach((String key, dynamic data) {
        if(data is FieldValue) {
          FieldValue fv = data;
          dynamic value;
          // ignore: invalid_use_of_visible_for_testing_member
          if(fv.type == FieldValueType.incrementDouble) {
            // ignore: invalid_use_of_visible_for_testing_member
            value = (fv.value as double);
            // ignore: invalid_use_of_visible_for_testing_member
          } else if(fv.type == FieldValueType.incrementInteger) {
            // ignore: invalid_use_of_visible_for_testing_member
            value = (fv.value as int);
          } else {
            throw('Only increment supported for FieldValue');
          }

          if(collections[col][documentID][key] != null)
            value += collections[col][documentID][key];

          collections[col][documentID][key] = value;
        } else {
          collections[col][documentID][key] = data;
        }
      });
    }
    return Future.delayed(Duration(seconds: 0));
  }
}

class MockCollectionReference extends Fake implements CollectionReference {
  String col;

  MockCollectionReference({this.col});

  @override
  DocumentReference document([String path]) {
    if (path == null) {
      path = Timestamp
          .now()
          .microsecondsSinceEpoch
          .toString() + rng.nextInt(10000).toString();
    }

    return new MockDocumentReference(col: col, documentID: path);
  }
}

class MockTransaction extends Fake implements Transaction {
  Set<String> read = {};
  Set<String> updated = {};

  @override
  Future<DocumentSnapshot> get (
      DocumentReference documentReference
      ) {
    read.add(documentReference.path);
    return documentReference.get();
  }

  @override
  Future<void> set (
      DocumentReference documentReference,
      Map<String, dynamic> data
      ) {
    updated.add(documentReference.path);

    documentReference.setData(data);
    return Future.delayed(Duration(seconds: 0));
  }

  @override
  Future<void> update (
      DocumentReference documentReference,
      Map<String, dynamic> data
      ) {
    updated.add(documentReference.path);

    documentReference.updateData(data);
    return Future.delayed(Duration(seconds: 0));
  }
}

class MockFirestore extends Fake implements Firestore {
  static MockFirestore instance = new MockFirestore();
  @override
  CollectionReference collection(String path) {
     return new MockCollectionReference(col: path);
  }

  Future<Map<String, dynamic>> runTransaction (
      TransactionHandler transactionHandler, {
        Duration timeout: const Duration(seconds: 5)
      }) async {
     MockTransaction tx = new MockTransaction();
     await transactionHandler(tx);

     Set notUpdated = tx.read.difference(tx.updated);
     if(notUpdated.length > 0)
       throw "Records read but not updated: ${notUpdated.join(', ')}";

     return <String, dynamic>{};
  }
}
