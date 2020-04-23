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
//const rq = require('request');
const request = require("request-promise");

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


// Deploy with:
// firebase deploy --only functions:linkWishes
exports.linkWishes = functions.firestore
  .document("bookrecords/{recId}")
  .onCreate(async (bookrecords, context) => {

    // If wish
    admin.firestore().collection('bookrecords').doc(bookcopy.id).update({ id: bookcopy.id });

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
