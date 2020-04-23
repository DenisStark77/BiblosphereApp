// This check that Firestore mock is working as expected fot Biblosphere tests

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';

Firestore db = MockFirestoreInstance();

main() {
  test("Mock Firestore: DocumentReference.documentID ", () async {
    DocumentReference doc = db.collection('test').document('123456');

    expect(doc.documentID, '123456');
  });

  test("Mock Firestore: Firestore.collection, DocumentReference.setData, DocumentSnapshot.get ", () async {
    DocumentReference doc = db.collection('test').document();
    doc.setData({'test': 1});
    DocumentSnapshot snap = await doc.get();

    expect(snap.data["test"], 1);
  });

  test("Mock Firestore: DocumentSnapshot.exist", () async {
    DocumentReference doc = db.collection('test').document();
    doc.setData({'test': 1});
    DocumentSnapshot snap = await doc.get();

    expect(snap.exists, true);
  });

  test("Mock Firestore: setData", () async {
    DocumentReference doc = db.collection('test').document();
    doc.setData({'old': 1});
    doc.setData({'new': 2});
    DocumentSnapshot snap = await doc.get();

    expect(snap.data["old"], null);
    expect(snap.data["new"], 2);
  });

  test("Mock Firestore: updateData", () async {
    DocumentReference doc = db.collection('test').document();
    doc.setData({'old': 1});
    doc.updateData({'new': 2, 'notexist': 5});
    DocumentSnapshot snap = await doc.get();

    expect(snap.data["old"], 1);
    expect(snap.data["new"], 2);
    expect(snap.data["notexist"], 5);
  });

  test("Mock Firestore: FieldValue", () async {
    DocumentReference doc = db.collection('test').document();
    doc.setData({'number': 1, 'double': 5.0});
    doc.updateData({'number': FieldValue.increment(3), 'double': FieldValue.increment(1.0)});
    DocumentSnapshot snap = await doc.get();

    expect(snap.data['number'], 4);
    expect(snap.data['double'], 6.0);
  });

  test("Mock Firestore: Transaction", () async {
    DocumentReference doc = db.collection('test').document();
    int data;
    doc.setData({'data': 1});
     db.runTransaction( (tx) {
       // Get value before transaction
       tx.get(doc).then((value) => data = value.data['data']);
       tx.set(doc, {'data': 2});
       return;
     });

    // Read value after transaction
    DocumentSnapshot snap = await doc.get();

    expect(data, 1);
    expect(snap.data['data'], 2);
  });
  // TODO: Compare to actual behaviour of Firestore (not needed for now)
  /*
  test("Mock Firestore: Transaction read and not updated", () async {
    DocumentReference doc1 = db.collection('test1').document();
    DocumentReference doc2 = db.collection('test2').document();
    doc1.setData({'data': 1});

    expect(() async => await db.runTransaction( (tx) {
      // Get value before transaction
      tx.get(doc1);
      tx.update(doc2, {'data': 2});
      return;
    }), throwsA((String str) => str.startsWith('Records read but not updated:')));
  });
  */
}