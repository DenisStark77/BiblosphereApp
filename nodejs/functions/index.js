'use strict'

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendNotification = functions.firestore
  .document("messages/{chatId}/{chatCollectionId}/{msgId}")
  .onCreate((snap, context) => {
      const msg = snap.data();
      console.log('Notification on message to user: ', msg.idTo);

      admin.firestore().collection('users').doc(msg.idTo).get()
      .then(doc => {
         console.log('Notify to token:', doc.data().token);

         var message = {
               token: doc.data().token,
               notification: {
                  title: 'Message notification',
                  body: doc.data().name + ' sent you a message'
               },
               data : {
                 sender: msg.idFrom,
                 click_action: 'FLUTTER_NOTIFICATION_CLICK'
               }
         };

         // Send a message to the device corresponding to the provided
         // registration token.
         return admin.messaging().send(message);
      })
      .then(response => { 
         // Response is a message ID string.
         console.log('Successfully sent message:', response);
         return null;
      })
      .catch((error) => {
         console.log('Error retrieve token:', error);
         return null;
      });
      return null;
  });

//    .database.ref('/messages/{chatId}/{chatCollectionId}/')
//    .firestore.document('/messages/{chatId}/{chatCollectionId}/')

//exports.onMessageNotify = functions
//    .firestore.document('/messages')
//    .onCreate((snap, context) => {
//      const newMsg = snap.data();
//      console.log('Successfully sent message:', 'kuku');
//    });