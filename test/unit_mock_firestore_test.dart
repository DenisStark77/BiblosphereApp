// This test check that IntroPage is displayed and scroll
// Test scroll from "Shoot" page through "Surf" page to "Meet" page
// checking that SKIP and DONE buttons shows correctly.

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biblosphere/mock_firestore.dart';

Firestore db = MockFirestore.instance;

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
}