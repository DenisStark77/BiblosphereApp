'use strict'

const functions = require('firebase-functions');
const mkdirp = require('mkdirp-promise');
const admin = require('firebase-admin');
admin.initializeApp();

//const firestore = new Firestore();
const settings = { timestampsInSnapshots: true };
admin.firestore().settings(settings);

const spawn = require('child-process-promise').spawn;
const path = require('path');
const os = require('os');
const fs = require('fs');
const json2csv = require("json2csv").parse;
//const rq = require('request');
const request = require("request-promise");

// Imports the Google Cloud client library
const vision = require('@google-cloud/vision');
// Creates a client
const client = new vision.ImageAnnotatorClient();

const StellarSdk = require('stellar-sdk')
//const server = new StellarSdk.Server('https://horizon-testnet.stellar.org');
const server = new StellarSdk.Server('https://horizon.stellar.org');

//Keep secret with:
// firebase functions:config:set stellar.secret="SA2S63V5U35YY3QCAZ7WZSPPQ7JL34HQVK4W7RTWBU3AKHSW7SNTP5YJ"


// Deploy with:
// firebase deploy --only functions:checkStellarIn
exports.checkStellarIn = functions.pubsub.topic('cron-topic').onPublish(async (message, context) => {
  var ref = admin.firestore().collection('system').doc('stellar_in');
  try {
    var cursor = null;
    // Set flag that payment processing is in progress
    var snap = await ref.get();
    if (!snap.exists)
      throw new Error('Stellar configuration missing in Firebase');

    // Skip if other checking process are still running 
    if (snap.data().running)
      return;
    // Last payment id
    cursor = snap.data().cursor;
    const accountId = snap.data().accountId;

    // TODO: Double-check cursor by selecting Operations

    // Request payments from Stellar
    var resp = await server.payments().forAccount(accountId).cursor(cursor).order("asc").call();

    // Update cursor for last operation id
    if (resp.records.length > 0) {
      cursor = resp.records[resp.records.length - 1].id;
      await ref.update({ 'cursor': cursor, 'running': true });
    }

    // For each Stellar payment get a transaction Memo and create Biblosphere payment
    for (var op of resp.records) {
      //console.log(JSON.stringify(op, null, 2));
      if (op.type === 'payment' && op.to === accountId)
        applyPayment(op);
    }

    await ref.update({ 'running': false });
  } catch (err) {
    console.log('Exception: ' + err);
    await ref.update({ 'running': false });
  }
});

function applyPayment(op) {
  return op.transaction().then((txs) => {
    if (txs.memo) {
      var walletRef = admin.firestore().collection('wallets').doc(txs.memo);
      var opRef = admin.firestore().collection('operations').doc();

      // Apply payment: create Operation and update balance in Wallet
      return admin.firestore().runTransaction(async (tx) => {
        var walletSnap = await walletRef.get();

        // Create payment operation
        tx.set(opRef, {
          'id': opRef.id, 'type': 2, 'userId': txs.memo,
          'amount': Number(op.amount), 'transactionId': op.id,
          'date': admin.firestore.Timestamp.now(), 'from': op.from,
          'users': [txs.memo]
        });

        // Create or update wallet
        if (walletSnap.exists)
          tx.update(walletRef, { 'balance': admin.firestore.FieldValue.increment(Number(op.amount)) });
        else
          tx.set(walletRef, { 'balance': Number(op.amount) });
      });
    }
    return txs;
  });
}

// Function to process paout to Stellar account
// Deploy with: firebase deploy --only functions:payoutStellar
exports.payoutStellar = functions.firestore
  .document("payouts/{opId}")
  .onCreate(async (op, context) => {
    if (op.data().type !== 'stellar')
      return;

    // Update status to In Progress 
    await admin.firestore().collection('payouts').doc(op.id).update({ 'status': "progress" });

    // Get secret seed for Biblosphere account
    const sourceSecretKey = functions.config().stellar.secret;

    var transactionId;

    try {
      // Create Stellar transaction
      const sourceKeypair = StellarSdk.Keypair.fromSecret(sourceSecretKey);
      const sourcePublicKey = sourceKeypair.publicKey();
      const receiverPublicKey = op.data().accountId;
      const account = await server.loadAccount(sourcePublicKey);

      const fee = await server.fetchBaseFee();

      const transaction = new StellarSdk.TransactionBuilder(account, {
        fee,
        networkPassphrase: StellarSdk.Networks.PUBLIC,
        //networkPassphrase: StellarSdk.Networks.TESTNET
      })
        // Add a payment operation to the transaction
        .addOperation(StellarSdk.Operation.payment({
          destination: receiverPublicKey,
          asset: StellarSdk.Asset.native(),
          amount: op.data().amount.toString(),
        }))
        .setTimeout(120)
        .addMemo(StellarSdk.Memo.text(op.data().memo))
        .build();

      transaction.sign(sourceKeypair);
      const transactionResult = await server.submitTransaction(transaction);
      transactionId = transactionResult.hash;
      await admin.firestore().collection('payouts').doc(op.id).update({ 'status': "paid" });

      // Create Biblosphere operation and update wallet balance
      var walletRef = admin.firestore().collection('wallets').doc(op.data().userId);
      var opRef = admin.firestore().collection('operations').doc();

      await admin.firestore().runTransaction(async (tx) => {
        var walletSnap = await walletRef.get();
        if (!walletSnap.exists)
          throw Error("Walet does not exist " + op.data().userId);

        // Create payment operation
        tx.set(opRef, {
          'id': opRef.id, 'type': 3, 'userId': op.data().userId,
          'amount': op.data().amount, 'transactionId': transactionId,
          'date': admin.firestore.Timestamp.now(),
          'users': [op.data().userId]
        });

        // Create or update wallet
        tx.update(walletRef, {
          'blocked': admin.firestore.FieldValue.increment(-op.data().amount),
          'balance': admin.firestore.FieldValue.increment(-op.data().amount)
        });
      });

      // Update status of payout to Completed
      await admin.firestore().collection('payouts').doc(op.id).update({
        'status': "done",
        'operation': opRef.id
      });

    } catch (e) {
      console.log('Payment failed:');
      console.log(e);
      await admin.firestore().collection('payouts').doc(op.id).update({ 'error': e.toString() });
    }
  });

// Function to send notification for message
// Deploy with: firebase deploy --only functions:sendNotification
exports.sendNotification = functions.firestore
  .document("messages/{chatId}/{chatCollectionId}/{msgId}")
  .onCreate((snap, context) => {
    const msg = snap.data();
    var token;
    admin.firestore().collection('users').doc(msg.idTo).get()
      .then(userTo => {
        token = userTo.data().token;
        return admin.firestore().collection('users').doc(msg.idFrom).get();
      })
      .then(userFrom => {
        var message = {
          token: token,
          notification: {
            title: 'Chat message',
            body: 'Message from ' + userFrom.data().name
          },
          data: {
            chat: context.params.chatId,
            click_action: 'FLUTTER_NOTIFICATION_CLICK'
          }
        };

        // Send a message to the device corresponding to the provided
        // registration token.
        return admin.messaging().send(message);
      })
      .then(response => {
        return null;
      })
      .catch((error) => {
        console.log('Error retrieve token:', error);
        return null;
      });
    return null;
  });

exports.updateBlocked = functions.firestore
  .document("messages/{chatId}")
  .onCreate((chat, context) => {

    return admin.firestore().collection('messages').doc(chat.id).update({ 'blocked': "no" });

  });

/*
exports.bookId = functions.firestore
  .document("books/{bookId}")
  .onCreate((book, context) => {

       console.log('Updating:', book.id);
       return admin.firestore().collection('books').doc(book.id).update({'book.id': book.id});

  });
*/

function distanceBetween(lat1, lon1, lat2, lon2, unit) {
  if ((lat1 === lat2) && (lon1 === lon2)) {
    return 0;
  }
  else {
    var radlat1 = Math.PI * lat1 / 180;
    var radlat2 = Math.PI * lat2 / 180;
    var theta = lon1 - lon2;
    var radtheta = Math.PI * theta / 180;
    var dist = Math.sin(radlat1) * Math.sin(radlat2) + Math.cos(radlat1) * Math.cos(radlat2) * Math.cos(radtheta);
    if (dist > 1) {
      dist = 1;
    }
    dist = Math.acos(dist);
    dist = dist * 180 / Math.PI;
    dist = dist * 60 * 1.1515;
    if (unit === "K") { dist = dist * 1.609344 }
    if (unit === "N") { dist = dist * 0.8684 }
    return dist;
  }
}

exports.linkShelves = functions.firestore
  .document("shelves/{shelfId}")
  .onCreate(async (shelf, context) => {

    var userRef = admin.firestore().collection('users').doc(shelf.data().user);

    var transaction = admin.firestore().runTransaction(t => {
      return t.get(userRef)
        .then(doc => {
          var shelfCount = doc.data().shelfCount;
          if (!shelfCount) shelfCount = 0;
          return t.update(userRef, { shelfCount: shelfCount + 1 });
        });
    }).then(result => {
      console.log('Transaction success!');
      return true;
    }).catch(err => {
      console.log('Transaction failure:', err);
    });
    return;
  });

exports.deleteShelf = functions.firestore
  .document("shelves/{shelfId}")
  .onDelete(async (shelf, context) => {

    var userRef = admin.firestore().collection('users').doc(shelf.data().user);

    var transaction = admin.firestore().runTransaction(t => {
      return t.get(userRef)
        .then(doc => {
          var shelfCount = doc.data().shelfCount;
          if (!shelfCount) shelfCount = 1;
          return t.update(userRef, { shelfCount: shelfCount - 1 });
        });
    }).then(result => {
      console.log('Transaction success!');
      return true;
    }).catch(err => {
      console.log('Transaction failure:', err);
    });
    return;
  });


exports.deleteBookcopy = functions.firestore
  .document("bookcopies/{bookId}")
  .onDelete(async (bookcopy, context) => {

    var userRef = admin.firestore().collection('users').doc(bookcopy.data().owner.id);

    var transaction = admin.firestore().runTransaction(t => {
      return t.get(userRef)
        .then(doc => {
          var bookCount = doc.data().bookCount;
          if (!bookCount) bookCount = 1;
          return t.update(userRef, { bookCount: bookCount - 1 });
        });
    }).then(result => {
      console.log('Transaction success!');
      return true;
    }).catch(err => {
      console.log('Transaction failure:', err);
    });
  });


exports.deleteWish = functions.firestore
  .document("wishes/{wishId}")
  .onDelete(async (wish, context) => {

    var userRef = admin.firestore().collection('users').doc(wish.data().wisher.id);

    var transaction = admin.firestore().runTransaction(t => {
      return t.get(userRef)
        .then(doc => {
          var wishCount = doc.data().wishCount;
          if (!wishCount) wishCount = 1;
          return t.update(userRef, { wishCount: wishCount - 1 });
        });
    }).then(result => {
      console.log('Transaction success!');
      return true;
    }).catch(err => {
      console.log('Transaction failure:', err);
    });
  });


// Deploy with:
// firebase deploy --only functions:linkWishes
exports.linkWishes = functions.firestore
  .document("bookcopies/{bookcopyId}")
  .onCreate(async (bookcopy, context) => {

    admin.firestore().collection('bookcopies').doc(bookcopy.id).update({ id: bookcopy.id });

    if (bookcopy.data().holder === null || bookcopy.data().holder === undefined) {
      admin.firestore().collection('bookcopies').doc(bookcopy.id).update({ holder: bookcopy.data().owner });
    }

    if (bookcopy.data().status === null || bookcopy.data().status === undefined) {
      admin.firestore().collection('bookcopies').doc(bookcopy.id).update({ status: 'available' });
    }

    var minDistance = 40000.0;
    var nearestWisher;
    var nearestWishId;

    var userRef = admin.firestore().collection('users').doc(bookcopy.data().owner.id);

    var transaction = admin.firestore().runTransaction(t => {
      return t.get(userRef)
        .then(doc => {
          var bookCount = doc.data().bookCount;
          if (!bookCount) bookCount = 0;
          console.log(`Book count ${wishCount}`);
          return t.update(userRef, { bookCount: bookCount + 1 });
        });
    }).then(result => {
      console.log('Transaction success!');
      return true;
    }).catch(err => {
      console.log('Transaction failure:', err);
    });

    var q = await admin.firestore().collection('wishes').where('book.id', '==', bookcopy.data().book.id).get();
    q.forEach(async (wish) => {
      var d = distanceBetween(wish.data().wisher.position.latitude, wish.data().wisher.position.longitude,
        bookcopy.data().position.latitude, bookcopy.data().position.longitude, 'K');

      if (d < minDistance) {
        minDistance = d;
        nearestWisher = wish.data().wisher;
        nearestWishId = wish.id;
      }

      if (!wish.data().matched || wish.data().distance > d) {
        admin.firestore().collection('wishes').doc(wish.id).update({ matched: true, owner: bookcopy.data().owner, bookcopyId: bookcopy.id, bookcopyPosition: bookcopy.data().position, distance: d });
      }
    });

    //Wish found
    if (minDistance < 40000.0) {
      return admin.firestore().collection('bookcopies').doc(bookcopy.id).update({ matched: true, wisher: nearestWisher, wishId: nearestWishId, distance: minDistance });
    }

    return false;
  });


exports.linkBookcopies = functions.firestore
  .document("wishes/{wishId}")
  .onCreate(async (wish, context) => {

    admin.firestore().collection('wishes').doc(wish.id).update({ id: wish.id });

    var minDistance = 40000.0;
    var nearestBookcopyId;
    var nearestBookcopyPosition;
    var nearestOwner;

    // Initialize document
    var userRef = admin.firestore().collection('users').doc(wish.data().wisher.id);

    var transaction = admin.firestore().runTransaction(t => {
      return t.get(userRef)
        .then(doc => {
          var wishCount = doc.data().wishCount;
          if (!wishCount) wishCount = 0;
          console.log(`Wish count ${wishCount}`);
          return t.update(userRef, { wishCount: wishCount + 1, positioned: true, position: wish.data().position });
        });
    }).then(result => {
      console.log('Transaction success!');
      return true;
    }).catch(err => {
      console.log('Transaction failure:', err);
    });

    //       admin.firestore().collection('users').doc(wish.data().wisher.id).update({positioned: true, position: wish.data().position});

    var q = await admin.firestore().collection('bookcopies').where('book.id', '==', wish.data().book.id).get();
    q.forEach(async (bookcopy) => {
      var d = distanceBetween(wish.data().wisher.position.latitude, wish.data().wisher.position.longitude,
        bookcopy.data().position.latitude, bookcopy.data().position.longitude, 'K');

      if (d < minDistance) {
        minDistance = d;
        nearestOwner = bookcopy.data().owner;
        nearestBookcopyId = bookcopy.id;
        nearestBookcopyPosition = bookcopy.data().position;
      }

      if (!bookcopy.data().matched || bookcopy.data().distance > d) {
        admin.firestore().collection('bookcopies').doc(bookcopy.id).update({ matched: true, wisher: wish.data().wisher, wishId: wish.id, distance: d });
      }
    });

    //Wish found
    if (minDistance < 40000.0) {
      return admin.firestore().collection('wishes').doc(wish.id).update({ matched: true, owner: nearestOwner, bookcopyId: nearestBookcopyId, bookcopyPosition: nearestBookcopyPosition, distance: minDistance });
    }

    return false;
  });


// Deploy with:
// firebase deploy --only functions:userOnCreate
/*
exports.userOnCreate = functions.firestore
    .document("users/{userId}")
    .onCreate(async (user, context) => {

       if (user.data().balance === null || user.data().balance === undefined) {
            admin.firestore().collection('users').doc(user.id).update({balance: 0});
        }

        return true;
    });
*/

// ADMIN functions
// Function addHolders:
// Copy owners to holders if holder is not populated
// Deploy with:
// firebase deploy --only functions:createBalances
exports.createBalances = functions.https.onRequest(async (req, res) => {
  try {
    var querySnapshot = await admin.firestore().collection('users').get();
    querySnapshot.forEach(async (user) => {

      // Ifholder is missing update it from owner
      if (user.data().balance === null || user.data().balance === undefined) {
        admin.firestore().collection('users').doc(user.id).update({ balance: 0 });
        console.log('User updated for balance: ', user.id);
      }
    });
    return res.status(200).send("Running");
  } catch (err) {
    console.log('Users balance update failed: ', err);
    return res.status(404).send("Users balance update failed");
  }
});


// Function addKeys:
// Add keys to books
// Deploy with:
// firebase deploy --only functions:addKeys
exports.addKeys = functions.https.onRequest(async (req, res) => {
  try {
    var querySnapshot = await admin.firestore().collection('books').where("book.id", ">=", "-LlBDNa2_tOyrEnsc3Zi")
      .orderBy("book.id", "asc").get();

    querySnapshot.forEach(async (book) => {

      // Ifholder is missing update it from owner
      if (book.data().book.keys === null || book.data().book.keys === undefined) {
        var str = book.data().book.authors.join(' ') + ' ' + book.data().book.title + ' ' + book.data().book.isbn;
        var keys = [...new Set(str.toLowerCase().replace(/([\s.)(,;!:]+)/g, '|').split('|').filter((str) => str.length > 2))];
        admin.firestore().collection('books').doc(book.id).update({ 'book.keys': keys });
      }
    });
    return res.status(200).send("Running 1.6");
  } catch (err) {
    console.log('Users balance update failed: ', err);
    return res.status(404).send("Book keys update failed");
  }
});


// Function addHolders:
// Copy owners to holders if holder is not populated
// Deploy with:
// firebase deploy --only functions:addHolders
exports.addHolders = functions.https.onRequest(async (req, res) => {
  try {
    var querySnapshot = await admin.firestore().collection('bookcopies').get();
    querySnapshot.forEach(async (bookcopy) => {

      // Ifholder is missing update it from owner
      if (!bookcopy.data().holder) {
        admin.firestore().collection('bookcopies').doc(bookcopy.id).update({ holder: bookcopy.data().owner });
        console.log('Bookcopy updated for holder: ', bookcopy.id);
      }

      if (!bookcopy.data().status) {
        admin.firestore().collection('bookcopies').doc(bookcopy.id).update({ status: 'available' });
        console.log('Bookcopy updated for status: ', bookcopy.id);
      }
    });
    return res.status(200).send("Running");
  } catch (err) {
    console.log('Bookcopies holder update failed: ', err);
    return res.status(404).send("Bookcopies holder update failed");
  }
});

// Function recogniseShelfHttp:
// Recognise books from shelf image (store segmented book's images and book/bookcopy records)
// Deploy with:
// firebase deploy --only functions:recogniseShelfHttp
const runtimeOpts = {
  timeoutSeconds: 300,
  memory: '1GB'
}

exports.recogniseShelfHttp = functions.runWith(runtimeOpts).https.onRequest(async (req, res) => {
  try {
    const shelfId = req.query.id;
    console.log('Book recognition requested for shelf (v0.10): ', shelfId);

    const shelf = await admin.firestore().collection('shelves').doc(shelfId).get();
    console.log('Shelf found ', shelfId);

    const imgPath = `images/${shelf.data().user}/${shelf.data().file}`;
    const body = await request(`https://us-central1-biblosphere-210106.cloudfunctions.net/segment_shelf?gcs=${imgPath}`);

    console.log('RESPONSE reseived:', body);

    const info = JSON.parse(body);
    let response = [];

    const promises = info.map(async (segment) => {
      console.log('Segment path: ', segment['gcs']);
      const imgUri = segment['gcs'];
      const rq = {
        image: {
          source: { imageUri: imgUri }
        },
      };

      const results = await client.documentTextDetection(rq);
      if (results && results[0] && results[0].fullTextAnnotation && results[0].fullTextAnnotation.text) {
        console.log('Text detected: ', results[0].fullTextAnnotation.text);
        segment['text'] = results[0].fullTextAnnotation.text;
        segment['status'] = 'recognized';

        const body = await request(`https://www.googleapis.com/books/v1/volumes?key=AIzaSyDJR_BnU_JVJyGTfaWcj086UuQxXP3LoTU&country=RU&printType=books&q=${encodeURIComponent(segment['text'])}`);
        const library = JSON.parse(body);
        if (library && library.items && library.items[0] && library.items[0].volumeInfo && library.items[0].volumeInfo.title) {
          console.log('Book found: ', library.items[0].volumeInfo.title);
          segment['book'] = library.items[0].volumeInfo.title;
          segment['status'] = 'found';
        } else {
          console.log('Book not found: ', segment['text']);
          segment['status'] = 'notfound';
        }
      } else {
        console.log('Text detection failed for: ', imgUri);
        segment['status'] = 'unrecognized';
      }

      response.push(segment);
      return true;
    });

    await Promise.all(promises);
    console.log('All promisses completed');

    return res.status(200).send(response);
  } catch (err) {
    console.log('Shelf recognition failed: ', err);
    return res.status(404).send("Shelf recognition failed");
  }
});

// Function exportUsers:
// export users with emails and counters
exports.exportUsers = functions.https.onRequest(async (req, res) => {
  try {
    const fields = ['id', 'name', 'shelfCount', 'bookCount', 'wishCount', 'email'];
    const opts = { fields };

    var users = [];
    var querySnapshot = await admin.firestore().collection('users').get();

    const promises = querySnapshot.docs.map(async (user) => {
      try {
        const authUser = await admin.auth().getUser(user.id); // this returns a promise, so use await or .then()
        var userJson = user.data();
        //console.log('User record: ', userJson);

        userJson['email'] = authUser.email;
        //console.log('User record with email: ', userJson);

        users.push(userJson);
        return true;
      } catch (err) {
        console.log('Data failed for: ', user.id, ' with error: ', err);
        return false;
      }
    });

    await Promise.all(promises).then(async (values) => {
      console.log('Promisses completed');

      // console.log('User list: ', users);

      console.log('Init storage');
      const bucket = admin.storage().bucket();

      const tempFile = path.join(os.tmpdir(), 'users.csv');
      console.log('Temp filepath: ', tempFile);

      const csv = json2csv(users, opts)

      console.log('Saving to file: ', tempFile);
      fs.writeFileSync(tempFile, csv)

      console.log('Uploading file: ', tempFile);
      await bucket.upload(tempFile, { destination: 'user.csv' });
      console.log('File uploaded to Storage at', 'user.csv');

      return true;
    });

    return res.status(200).send("Running (version 0.18)");
  } catch (err) {
    console.log('User export failed: ', err);
    return res.status(404).send("User export failed (version 0.18");
  }
});

// Function updateUsers:
// update counters and positions of the users
exports.updateUsers = functions.https.onRequest(async (req, res) => {
  try {
    var querySnapshot = await admin.firestore().collection('users').get();
    querySnapshot.forEach(async (user) => {

      //Select shelves. Count shelves and update shelfCounter
      //If 'positioned' false use position of first shelf
      //set books and wishes to 0
      var q = await admin.firestore().collection('shelves').where('user', '==', user.id).get();
      var count = q.size;
      var position;
      if (count > 0)
        position = q.docs[0].data().position;

      console.log('User update data: ', user.id, ', ', count, ', ', position);

      if (!user.data().positioned && position) {
        admin.firestore().collection('users').doc(user.id).update({ 'shelfCount': count, 'bookCount': 0, 'wishCount': 0, positioned: true, position: position });
      } else {
        admin.firestore().collection('users').doc(user.id).update({ 'shelfCount': count, 'bookCount': 0, 'wishCount': 0 });
      }
    });
    return res.status(200).send("Running");
  } catch (err) {
    console.log('User update failed: ', err);
    return res.status(404).send("User update failed");
  }
});

// Function blockedMessages:
// Filling blocked field in messages
exports.blockedMessages = functions.https.onRequest(async (req, res) => {
  try {
    var querySnapshot = await admin.firestore().collection('messages').get();
    querySnapshot.forEach(async (chat) => {
      admin.firestore().collection('messages').doc(chat.id).update({ 'blocked': "no" }).then((result) => {
        console.log(`Chat updated ${chat.id}`);
        return result;
      }).catch((err) => {
        console.log(`Chat update failed ${chat.id}: ${err}`);
      });
      return chat;
    });
    return res.status(200).send("Running");
  } catch (err) {
    console.log('Chat update failed: ', err);
    return res.status(404).send("Chat update generation failed");
  }
});

// Function userNames: 
// Filling shelf records with user name
exports.userNames = functions.https.onRequest(async (req, res) => {
  try {
    var querySnapshot = await admin.firestore().collection('shelves').get();
    querySnapshot.forEach(async (shelf) => {
      const userDoc = await admin.firestore().collection('users').doc(shelf.data().user).get();
      const userName = userDoc.data().name;
      console.log(`Name found for shelf: ${shelf.id}, ${userName}`);
      admin.firestore().collection('shelves').doc(shelf.id).update({ 'userName': userName }).then((result) => {
        console.log(`Shelf updated ${shelf.id}`);
        return result;
      }).catch((err) => {
        console.log(`Shelf update failed ${shelf.id}: ${err}`);
      });
      return shelf;
    });
    return res.status(200).send("Running");
  } catch (err) {
    console.log('Shelf update failed: ', err);
    return res.status(404).send("Shelf update generation failed");
  }
});

//Function: detectLanguage
// Detect languages of the books and store it in detectedLanguages field
exports.detectLanguage = functions.https.onRequest(async (req, res) => {
  try {
    console.log('Function detectLanguage version 0.0.19');
    //    var querySnapshot = await admin.firestore().collection('shelves').where('user', '==', 'oyYUDByQGVdgP13T1nyArhyFkct1').get();
    var querySnapshot = await admin.firestore().collection('shelves').get();
    querySnapshot.forEach(async (shelf) => {
      const imgUri = `gs://biblosphere-210106.appspot.com/images/${shelf.data().user}/${shelf.data().file}`;
      const request = {
        image: {
          source: { imageUri: imgUri }
        },
      };

      client.textDetection(request)
        .then(results => {
          var langList = new Set();
          if (results[0] && results[0].fullTextAnnotation && results[0].fullTextAnnotation.pages[0]) {
            const blocks = results[0].fullTextAnnotation.pages[0].blocks;

            blocks.forEach(blk => {
              if (blk.property) {
                blk.property.detectedLanguages.forEach(lang => {
                  langList.add(lang.languageCode);
                });
              }
            });

            console.log('List of detected languages: ', langList);
            return admin.firestore().collection('shelves').doc(shelf.id).update({ 'detectedLanguages': Array.from(langList) });
          } else {
            throw new Error("OCR request failed");
          }
        })
        .then(result => {
          console.log(`Shelf ${shelf.id} with languages ${langList}`);
          return null;
        })
        .catch(err => {
          console.error(err);
        });
    });
    return res.status(200).send("Language detection running...");
  } catch (err) {
    console.log('Language detection failed: ', err);
    return res.status(404).send("Language detection failed");
  }
});

//Function: detectBooks
// Detect languages of the books and store it in detectedLanguages field
exports.detectBooks = functions.https.onRequest(async (req, res) => {
  try {
    console.log('Function detectBooks version 0.0.5');
    const shelfId = req.query.id;
    console.log('Book recognition requested for shelf ', shelfId);

    const shelf = await admin.firestore().collection('shelves').doc(shelfId).get();
    console.log('Shelf found ', shelfId);

    const imgUri = `gs://biblosphere-210106.appspot.com/images/${shelf.data().user}/${shelf.data().file}`;
    const request = {
      image: {
        source: { imageUri: imgUri }
      },
    };

    var results = await client.textDetection(request);

    if (results[0] && results[0].fullTextAnnotation && results[0].fullTextAnnotation.text) {
      results[0].fullTextAnnotation.text
      var bookList = results[0].fullTextAnnotation.text.split("\n");
      /*
             // JSON output       
             const response = {
                books: bookList
             };
      */
      //HTML output
      const response = `
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<HTML>
   <HEAD>
      <TITLE>Books</TITLE>
   </HEAD>
   <BODY>
      <ul>
        ${bookList.map(book => `<li>${book}</li>`)}
      </ul>
      <img src="${shelf.data().URL}"/>
   </BODY>
</HTML>
`;

      return res.status(200).send(response)
    } else {
      console.log('Empty annotation', results);
      return res.status(404).send("Empty annotation response");
    }
  } catch (err) {
    console.log('Book detection failed: ', err);
    return res.status(404).send("Book detection failed");
  }
});

