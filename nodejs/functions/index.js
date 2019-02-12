'use strict'

const functions = require('firebase-functions');
const mkdirp = require('mkdirp-promise');
const admin = require('firebase-admin');
admin.initializeApp();
const spawn = require('child-process-promise').spawn;
const path = require('path');
const os = require('os');
const fs = require('fs');

// Imports the Google Cloud client library
const vision = require('@google-cloud/vision');
// Creates a client
const client = new vision.ImageAnnotatorClient();


exports.sendNotification = functions.firestore
  .document("messages/{chatId}/{chatCollectionId}/{msgId}")
  .onCreate((snap, context) => {
      const msg = snap.data();
      var token;
      console.log('Notification on message to user: ', msg.idTo);

      admin.firestore().collection('users').doc(msg.idTo).get()
      .then(userTo => {
         console.log('Notify to token:', userTo.data().token);
         token = userTo.data().token;
         return admin.firestore().collection('users').doc(msg.idFrom).get();
      })
      .then(userFrom => {

            var message = {
               token: token,
               notification: {
                  title: 'Message notification',
                  body: userFrom.data().name + ' sent you a message'
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

exports.updateBlocked = functions.firestore
  .document("messages/{chatId}")
  .onCreate((chat, context) => {
       
       return admin.firestore().collection('messages').doc(chat.id).update({'blocked': "no"});

  });

// ADMIN functions
// Function blockedMessages: 
// Filling blocked field in messages
exports.blockedMessages = functions.https.onRequest(async (req, res) => {
  try {
    var querySnapshot = await admin.firestore().collection('messages').get();
    querySnapshot.forEach(async (chat) => {
            admin.firestore().collection('messages').doc(chat.id).update({'blocked': "no"}).then((result) => {
                  console.log(`Chat updated ${chat.id}`); 
                  return result;
            }).catch((err) => {
                  console.log(`Chat update failed ${chat.id}: ${err}`); 
            });
            return chat;
    });
    return res.status(200).send("Running");
  } catch(err) {
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
            admin.firestore().collection('shelves').doc(shelf.id).update({'userName': userName}).then((result) => {
                  console.log(`Shelf updated ${shelf.id}`); 
                  return result;
            }).catch((err) => {
                  console.log(`Shelf update failed ${shelf.id}: ${err}`); 
            });
            return shelf;
    });
    return res.status(200).send("Running");
  } catch(err) {
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
               source: {imageUri: imgUri}
            },
        };

        client.textDetection(request)
          .then(results => {
              var langList = new Set();
              if (results[0] && results[0].fullTextAnnotation && results[0].fullTextAnnotation.pages[0]) {
                 const blocks = results[0].fullTextAnnotation.pages[0].blocks;
                    
                 blocks.forEach(blk => {
                      if(blk.property) {
                           blk.property.detectedLanguages.forEach(lang => {
                              langList.add(lang.languageCode);
                           });
                      }
                 });
       
                 console.log('List of detected languages: ', langList);
                 return admin.firestore().collection('shelves').doc(shelf.id).update({'detectedLanguages': Array.from(langList)});
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
  } catch(err) {
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
           source: {imageUri: imgUri}
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
  } catch(err) {
    console.log('Book detection failed: ', err);
    return res.status(404).send("Book detection failed");
  }
});  

const THUMB_MAX_HEIGHT = 600;
const THUMB_MAX_WIDTH = 600;
const THUMB_PREFIX = 'thumb_';

exports.thumbnail = functions.https.onRequest(async (req, res) => {
  try {
    const shelfId = req.query.id;
    console.log('Thumbnail requested for shelf ', shelfId);
  
    const shelf = await admin.firestore().collection('shelves').doc(shelfId).get();
    console.log('Shelf found ', shelfId);
  
    // Check thumbnail if present return redirect to thumbnail image
    var thumbUrl = shelf.data().thumbnail; 
    console.log('Shelf existing thumbnail ', thumbUrl);
  
    if (typeof thumbUrl !== 'undefined' && thumbUrl !== null)        
       return res.redirect(thumbUrl);
  
    console.log('Shelf thumbnail to be created');
  
    // If no thumbnail: read image url, resize, save thumbnail image, 
    //          generate url, update shelf record with thumbnail url
    const userId = shelf.data().user;
    const fileName = shelf.data().file;
    const fileDir = `images/${userId}`;
    const filePath = path.join(fileDir, fileName);
    const thumbFilePath = path.normalize(path.join(fileDir, `${THUMB_PREFIX}${fileName}`));
    const tempLocalFile = path.join(os.tmpdir(), filePath);
    const tempLocalDir = path.dirname(tempLocalFile);
    const tempLocalThumbFile = path.join(os.tmpdir(), thumbFilePath);
  
    // Cloud Storage files.
    console.log('Initiating files in storage');
    const bucket = admin.storage().bucket();
    const file = bucket.file(filePath);
    const thumbFile = bucket.file(thumbFilePath);
    const metadata = {
       contentType: 'image/jpeg',
       'Cache-Control': 'public,max-age=3600'
    };
  
    // Create the temp directory where the storage file will be downloaded.
    console.log('Creating temp dirs ', tempLocalDir);
    await mkdirp(tempLocalDir);
    // Download file from bucket.
    console.log('Downloading file', filePath, ' to dir ', tempLocalFile);
    await file.download({destination: tempLocalFile});
    console.log('The file has been downloaded to', tempLocalFile);
    // Generate a thumbnail using ImageMagick.
    await spawn('convert', [tempLocalFile, '-thumbnail', `${THUMB_MAX_WIDTH}x${THUMB_MAX_HEIGHT}>`, tempLocalThumbFile], {capture: ['stdout', 'stderr']});
    console.log('Thumbnail created at', tempLocalThumbFile);
    // Uploading the Thumbnail.
    await bucket.upload(tempLocalThumbFile, {destination: thumbFilePath, metadata: metadata});
    console.log('Thumbnail uploaded to Storage at', thumbFilePath);
    // Once the image has been uploaded delete the local files to free up disk space.
    fs.unlinkSync(tempLocalFile);
    fs.unlinkSync(tempLocalThumbFile);
    // Get the Signed URLs for the thumbnail and original image.
    const config = {
       action: 'read',
       expires: '03-01-2500',
    };
    const thumbResult = await thumbFile.getSignedUrl(config);
    console.log('Got Signed URL.');
    const thumbFileUrl = thumbResult[0];
  
    // Add the URLs to the Database
    await admin.firestore().collection('shelves').doc(shelfId).update({'thumbnail': thumbFileUrl});
    return res.redirect(thumbFileUrl);
  } catch(err) {
    console.log('Thumbnail failed: ', err);
    return res.status(404).send("Thumbnail generation failed");
  }
});

exports.shelf = functions.https.onRequest(async (req, res) => {
  try {
    const shelfId = req.query.id;
    console.log('Thumbnail requested for shelf ', shelfId);
  
    const shelf = await admin.firestore().collection('shelves').doc(shelfId).get();
    console.log('Shelf found ', shelfId);
  
    // Check thumbnail if present return redirect to thumbnail image
    var thumbUrl = shelf.data().thumbnail; 
    console.log('Shelf existing thumbnail ', thumbUrl);
  
    if (typeof thumbUrl === 'undefined' || thumbUrl === null)        
    {  
      console.log('Shelf thumbnail to be created');
    
      // If no thumbnail: read image url, resize, save thumbnail image, 
      //          generate url, update shelf record with thumbnail url
      const userId = shelf.data().user;
      const fileName = shelf.data().file;
      const fileDir = `images/${userId}`;
      const filePath = path.join(fileDir, fileName);
      const thumbFilePath = path.normalize(path.join(fileDir, `${THUMB_PREFIX}${fileName}`));
      const tempLocalFile = path.join(os.tmpdir(), filePath);
      const tempLocalDir = path.dirname(tempLocalFile);
      const tempLocalThumbFile = path.join(os.tmpdir(), thumbFilePath);
    
      // Cloud Storage files.
      console.log('Initiating files in storage');
      const bucket = admin.storage().bucket();
      const file = bucket.file(filePath);
      const thumbFile = bucket.file(thumbFilePath);
      const metadata = {
         contentType: 'image/jpeg',
         'Cache-Control': 'public,max-age=3600'
      };
    
      // Create the temp directory where the storage file will be downloaded.
      console.log('Creating temp dirs ', tempLocalDir);
      await mkdirp(tempLocalDir);
      // Download file from bucket.
      console.log('Downloading file', filePath, ' to dir ', tempLocalFile);
      await file.download({destination: tempLocalFile});
      console.log('The file has been downloaded to', tempLocalFile);
      // Generate a thumbnail using ImageMagick.
      await spawn('convert', [tempLocalFile, '-thumbnail', `${THUMB_MAX_WIDTH}x${THUMB_MAX_HEIGHT}>`, tempLocalThumbFile], {capture: ['stdout', 'stderr']});
      console.log('Thumbnail created at', tempLocalThumbFile);
      // Uploading the Thumbnail.
      await bucket.upload(tempLocalThumbFile, {destination: thumbFilePath, metadata: metadata});
      console.log('Thumbnail uploaded to Storage at', thumbFilePath);
      // Once the image has been uploaded delete the local files to free up disk space.
      fs.unlinkSync(tempLocalFile);
      fs.unlinkSync(tempLocalThumbFile);
      // Get the Signed URLs for the thumbnail and original image.
      const config = {
         action: 'read',
         expires: '03-01-2500',
      };
      const thumbResult = await thumbFile.getSignedUrl(config);
      console.log('Got Signed URL.');
      thumbUrl = thumbResult[0];
    
      // Add the URLs to the Database
      await admin.firestore().collection('shelves').doc(shelfId).update({'thumbnail': thumbUrl});
    }

    return res.status(200).send(`<!DOCTYPE html>
<html class="no-js" lang="en">
  <head>
    <meta property="og:title" content="Biblosphere" />
    <meta property="og:image" content="https://biblosphere.org/thumbnail?id=${shelfId}" />
    <meta property="og:url" content="https://biblosphere.org/shelf?id=${shelfId}" />
    <meta property="og:description" content="App for paperback book sharing" />
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <!--- basic page needs
    ================================================== -->
    <title>Biblosphere</title>
    <meta name="description" content="App for paperback book sharing">
    <meta name="author" content="Denis Stark">
    <!-- mobile specific metas
    ================================================== -->
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- CSS
    ================================================== -->
    <link rel="stylesheet" href="css/base.css">
    <link rel="stylesheet" href="css/vendor.css">
    <link rel="stylesheet" href="css/main.css">
    <!-- script
    ================================================== -->
    <script src="js/modernizr.js"></script>
    <script src="js/pace.min.js"></script>
    <!-- favicons
    ================================================== -->
    <link rel="shortcut icon" href="favicon.ico" type="image/x-icon">
    <link rel="icon" href="favicon.ico" type="image/x-icon">
  </head>
  <body id="top">
    <div id="preloader">
      <div id="loader"></div>
    </div>
    <!-- header 
    ================================================== -->
    <header class="s-header">
      <div class="header-logo"> <a class="site-logo" href="index.html"> <img src="images/logo.png"

            alt="Homepage"> </a> </div>
      <nav class="row header-nav-wrap wide">
        <ul class="header-main-nav">
          <li class="current"><a class="smoothscroll" href="#home" title="intro">Intro</a></li>
          <li><a class="smoothscroll" href="#about" title="about">About</a></li>
          <li><a class="smoothscroll" href="#features" title="features">Features</a></li>
          <li><a class="smoothscroll" href="#pricing" title="pricing">Pricing</a></li>
        </ul>
        <ul class="header-social">
          <li><a href="#0"><i class="fab fa-facebook-f" aria-hidden="true"></i></a><br>
          </li>
          <li><a href="#0"><i class="fab fa-twitter" aria-hidden="true"></i></a><br>
          </li>
          <li><a href="#0"><i class="fab fa-instagram" aria-hidden="true"></i></a><br>
          </li>
        </ul>
      </nav>
      <a class="header-menu-toggle" href="#"><span>Menu</span></a> </header>
    <!-- end header -->
    <!-- home
    ================================================== -->
    <section id="home" class="s-home target-section">
      <div class="home-image-part"></div>
      <div class="home-content">
        <div class="row home-content__main wide">
          <h1> Get access to books around you</h1>
          <h3> Read books of your neighbors instead of wasting money on new
            books to read once and store forever.</h3>
          <div class="home-content__button"> <a class="btn-video" href="https://player.vimeo.com/video/303658719?color=00a650&amp;title=0&amp;byline=0&amp;portrait=0"

              data-lity=""> <span class="video-icon"></span> </a> <a href="#download"

              class="smoothscroll btn btn--primary btn--large"> Get The App </a>
          </div>
        </div>
        <!-- end home-content__main --> <a href="#about" class="home-scroll smoothscroll">
          <span class="home-scroll__text">Scroll Down</span> <span class="home-scroll__icon"></span>
        </a> </div>
      <!-- end home-content --> </section>
    <!-- end s-home -->
    <!-- about
    ================================================== -->
    <section id="about" class="s-about target-section">
      <div class="row section-header narrower align-center" data-aos="fade-up">
        <div class="col-full">
          <h1 class="display-1"> Community centered book sharing tool </h1>
          <p class="lead"> Biblosphere app is designed to serve book reading
            communities. Like colleages, campuses, book reading circles,
            litrature clubs, or even neighbourhoods or companies. The app gives
            a convinient way to catalog your books and keep track of the
            sharing. </p>
        </div>
      </div>
      <!-- end section-header -->
      <div class="row about-desc" data-aos="fade-up">
        <div class="col-full slick-slider about-desc__slider">
          <div class="about-desc__slide">
            <h3 class="item-title">Easy to use.</h3>
            <p> Take a picture of your bookshelf and enjoy new connections with
              likeminded people around you. See book cases of your neighbour and
              contact them in a private chat. </p>
          </div>
          <!-- end about-desc__slide -->
          <div class="about-desc__slide">
            <h3 class="item-title">Smart.</h3>
            <p> Powered by Google ML (machine learning) app is smart enough to
              filter unrelated content. Text and image recognition helps you to
              create your book catalogue with no effort. </p>
          </div>
          <!-- end about-desc__slide -->
          <div class="about-desc__slide">
            <h3 class="item-title">Full of fun.</h3>
            <p> Enjoy browsing your neighbour book shelves, making friends with
              like minded people and dive into the world of books. </p>
          </div>
          <!-- end about-desc__slide -->
          <div class="about-desc__slide">
            <h3 class="item-title">Reasonable.</h3>
            <p> Save money by reading books of your neighbours instead of buying
              a new one. Earn money by sharing your books. </p>
          </div>
          <!-- end about-desc__slide --> </div>
        <!-- end about-desc__slider --> </div>
      <!-- end about-desc -->
      <div class="row about-bottom-image" data-aos="fade-up">
        <div id="map" style="height: 500px; width: 100%;"></div>
      </div>
    </section>
    <!-- end s-about -->
    <!-- process
    ================================================== -->
    <section id="process" class="s-process">
      <div class="row">
        <div class="col-full text-center" data-aos="fade-up">
          <h2 class="display-2">How The App Works?</h2>
        </div>
      </div>
      <div class="row process block-1-4 block-m-1-2 block-tab-full">
        <div class="col-block item-process" data-aos="fade-up">
          <div class="item-process__text">
            <h3>Sign Up</h3>
            <p> Download app and sign up with your Facebook account. </p>
          </div>
        </div>
        <div class="col-block item-process" data-aos="fade-up">
          <div class="item-process__text">
            <h3>Surf</h3>
            <p> See bookshelves around you sorted by distance. So you'll first
              see closest one. Contact owner of the books and ask for share. </p>
          </div>
        </div>
        <div class="col-block item-process" data-aos="fade-up">
          <div class="item-process__text">
            <h3>Shoot</h3>
            <p> Take a picture of your bookshelf and publish in the app. So your neighbours
              will be able to contact you. </p>
          </div>
        </div>
        <div class="col-block item-process" data-aos="fade-up">
          <div class="item-process__text">
            <h3>Share</h3>
            <p> Once contacted by neighbour share your books to her/him. To have
              a paid share you need an upgrade to a Member plan. </p>
          </div>
        </div>
      </div>
      <!-- end process -->
      <div class="row process-bottom-image" data-aos="fade-up"> <img src="images/phone-app-screens-1000.png"

          srcset="images/phone-app-screens-600.png 600w, 
                         images/phone-app-screens-1000.png 1000w,                          images/phone-app-screens-2000.png 2000w"

          sizes="(max-width: 2000px) 100vw, 2000px" alt="App Screenshots"> </div>
    </section>
    <!-- end s-process -->
    <!-- features
    ================================================== -->
    <section id="features" class="s-features target-section">
      <div class="row section-header narrower align-center has-bottom-sep" data-aos="fade-up">
        <div class="col-full">
          <h1 class="display-1"> Features are tailor made for community sharing.
          </h1>
          <p class="lead"> App designed to be easy to use, convenient and secure
            for comunity sharing. </p>
        </div>
      </div>
      <!-- end section-header -->
      <div class="row bit-narrow features block-1-2 block-mob-full">
        <div class="col-block item-feature" data-aos="fade-up">
          <div class="item-feature__icon"> <i class="icon-upload"></i> </div>
          <div class="item-feature__text">
            <h3 class="item-title">Cloud Based</h3>
            <p> Your entire book catalogue accessable from your mobile anywhere
              in the world. Full control of the books you share. </p>
          </div>
        </div>
        <div class="col-block item-feature" data-aos="fade-up">
          <div class="item-feature__icon"> <i class="icon-users"></i> </div>
          <!--icon-group-->
          <div class="item-feature__text">
            <h3 class="item-title">Community</h3>
            <p>Join a community you belong to. You will see a books of this
              community members and get updates on the meeting and other events
              of the community to exchange books off-line and meet like-minded
              people.</p>
          </div>
        </div>
        <div class="col-block item-feature" data-aos="fade-up">
          <div class="item-feature__icon"> <i class="icon-eye"></i> </div>
          <div class="item-feature__text">
            <h3 class="item-title">Image and Text recognition</h3>
            <p>Powered by Machine Learning models app will filter not
              book-related images, recognize authors and titles to maintain your
              book catalogue for you. </p>
          </div>
        </div>
        <div class="col-block item-feature" data-aos="fade-up">
          <div class="item-feature__icon"> <i class="icon-pin"></i> </div>
          <!--icon-map  icon-eye  icon-light-bulb -->
          <div class="item-feature__text">
            <h3 class="item-title">Geo-location</h3>
            <p>Geo-location allows you to see bookshelves nearby wherever you
              go. Travel abroad, go on vacation, became an expat you have a
              constant access to best of the books around you and people with
              similar reading taste. </p>
          </div>
        </div>
        <div class="col-block item-feature" data-aos="fade-up">
          <div class="item-feature__icon"> <i class="icon-chat"></i> </div>
          <div class="item-feature__text">
            <h3 class="item-title">Private Chat</h3>
            <p> Private chat with other book owners to agree about sharing. And
              express your gratitude and give feedback on fantastic books you've
              read.</p>
          </div>
        </div>
        <div class="col-block item-feature" data-aos="fade-up">
          <div class="item-feature__icon"> <i class="icon-wallet"></i> </div>
          <div class="item-feature__text">
            <h3 class="item-title">Payments</h3>
            <p>App is securely integrated with PayPal to provide seamless
              payment experience for the book rental. On a Member and Community
              plans you will receive PayPal payments for the books you share as
              well as profit share from community's transactions. </p>
          </div>
        </div>
      </div>
      <!-- end features -->
      <div class="testimonials-wrap" data-aos="fade-up">
        <div class="row">
          <div class="col-full testimonials-header">
            <h2 class="display-2">Domain experts.</h2>
          </div>
        </div>
        <div class="row testimonials">
          <div class="col-full slick-slider testimonials__slider">
            <div class="testimonials__slide"> <img src="images/avatars/user-01.jpg"

                alt="Author image" class="testimonials__avatar">
              <div class="testimonials__author"> <span class="testimonials__name">Jane
                  Stark</span> <a href="https://www.facebook.com/jenia.stark" class="testimonials__link">Founder of Noble Poetry Club, Dubai</a>
              </div>
              <p>As a founder of Noble Poetry Club I do understand how difficult
                to find true lover of poetry and litrature in a modern world of
                social media. This app looks like a wonderful island inhabited
                by people who value reading and espetially paperback books. </p>
            </div>
            <!-- end testimonials__slide -->
            <div class="testimonials__slide"> <img src="images/avatars/user-02.jpg"

                alt="Author image" class="testimonials__avatar">
              <div class="testimonials__author"> <span class="testimonials__name">Anvar 
                Kadyrov</span> <a href="https://www.facebook.com/anvarkadyr" class="testimonials__link">Founder of Darudar, Moscow</a>
              </div>
              <p>The essence of the Biblosphere project is not a distributed catalog of the books, 
                but the community behind these books. You find right people, strike an amazing book, 
                discover how a book influenced the owner, discuss what was the most important catch 
                of a book. You also become a guide to a fascinating literature world to someone else.</p>
            </div>
            <!-- end testimonials__slide -->
            <div class="testimonials__slide"> <img src="images/avatars/user-03.jpg"

                alt="Author image" class="testimonials__avatar">
              <div class="testimonials__author"> <span class="testimonials__name">Shikamaru
                  Nara</span> <a href="#0" class="testimonials__link">@shikamarunara</a>
              </div>
              <p>Repellat dignissimos libero. Qui sed at corrupti expedita
                voluptas odit. Nihil ea quia nesciunt. Ducimus aut sed ipsam.
                Autem eaque officia cum exercitationem sunt voluptatum
                accusamus. Quasi voluptas eius distinctio.</p>
            </div>
            <!-- end testimonials__slide --> </div>
          <!-- end testimonials__slider --> </div>
        <!-- end testimonials --> </div>
      <!-- end testimonials-wrap --> </section>
    <!-- end s-features -->
    <!-- pricing
    ================================================== -->
    <section id="pricing" class="s-pricing target-section">
      <div class="row section-header narrower align-center" data-aos="fade-up">
        <div class="col-full">
          <h1 class="display-1"> Gradual Pricing Model For Everyone. </h1>
          <p class="lead"> You'll start with a Free plan. It allows you to
            catalog your books at one location. You can give books for free and
            take paid or free books. As soon as you share your books for money
            you need to upgrade to a Member plan. Community plan allows you to
            run a community and earn from every transaction they made. </p>
        </div>
      </div>
      <!-- end section-header -->
      <div class="row plans block-1-3 block-m-1-2 block-tab-full stack">
        <div class="col-block item-plan" data-aos="fade-up">
          <div class="item-plan__block">
            <div class="item-plan__top-part">
              <h3 class="item-plan__title">Basic</h3>
              <p class="item-plan__price">Free</p>
            </div>
            <div class="item-plan__bottom-part">
              <ul class="item-plan__features disc">
                <li><span>5</span> bookshelves</li>
                <li><span>1</span> own location</li>
                <li><span>1</span> community</li>
                <li><span>10km</span> radius</li>
                <li><span>Free</span> book sharing</li>
                <li>Access to <span>free and paid</span> book</li>
              </ul>
              <a class="btn btn--primary large full-width" href="#0">Get Started</a>
            </div>
          </div>
        </div>
        <!-- end item-plan -->
        <div class="col-block item-plan item-plan--popular" data-aos="fade-up">
          <div class="item-plan__block">
            <div class="item-plan__top-part">
              <h3 class="item-plan__title">Member Plan</h3>
              <p class="item-plan__price">$5</p>
              <p class="item-plan__per">Per Month</p>
            </div>
            <div class="item-plan__bottom-part">
              <ul class="item-plan__features disc">
                <li><span>10</span> bookshelves</li>
                <li><span>3</span> own locations</li>
                <li><span>3</span> communities</li>
                <li><span>50km</span> radius</li>
                <li><span>Free and paid</span> book sharing</li>
                <li>Access to <span>free and paid</span> book</li>
              </ul>
              <a class="btn btn--primary large full-width" href="#0">Get Started</a>
            </div>
          </div>
        </div>
        <!-- end item-plan -->
        <div class="col-block item-plan" data-aos="fade-up">
          <div class="item-plan__block">
            <div class="item-plan__top-part">
              <h3 class="item-plan__title">Community Plan</h3>
              <p class="item-plan__price">$10</p>
              <p class="item-plan__per">Per Month</p>
            </div>
            <div class="item-plan__bottom-part">
              <ul class="item-plan__features disc">
                <li><span>20</span> bookshelves</li>
                <li><span>5</span> own locations</li>
                <li><span>5</span> communities</li>
                <li><span>200km</span> radius</li>
                <li><span>Free and paid</span> book sharing</li>
                <li><span>Profit</span> share</li>
              </ul>
              <a class="btn btn--primary large full-width" href="#0">Get Started</a>
            </div>
          </div>
        </div>
        <!-- end item-plan --> </div>
      <!-- end plans --> </section>
    <!-- end s-pricing -->
    <!-- download
    ================================================== -->
    <section id="download" class="s-download">
      <div class="row download-content">
        <div class="col-six md-seven download-content__text pull-right" data-aos="fade-up">
          <h1 class="display-2"> Download The App to access this bookshelf! </h1>
          <p> Via app you can contact books' owners and get new books to read. </p>
          <ul class="download-content__badges">
            <li><a href="https://itunes.apple.com/ae/app/biblosphere/id1445570468?mt=8" title="" class="badge-appstore">App Store</a></li>
            <li><a href="https://play.google.com/store/apps/details?id=com.biblosphere.biblosphere"

                title="" class="badge-googleplay">Play Store</a></li>
          </ul>
        </div>
        <div class="download-content__image" data-aos="fade-up"> <img src="${thumbUrl}">
        </div>
      </div>
    </section>
    <!-- end s-download -->
    <!-- footer
    ================================================== -->
    <footer class="s-footer footer">
      <div class="row footer__top">
        <div class="col-six md-full">
          <h1 class="display-2"> Let's Stay In Touch. </h1>
          <p class="lead"> Subscribe for updates, special offers and more. </p>
        </div>
        <div class="col-six md-full footer__subscribe end">
          <div class="subscribe-form">
            <form id="mc-form" class="group" novalidate="true"> <input value=""

                name="EMAIL" class="email" id="mc-email" placeholder="Email Address"

                required="" type="email"> <input name="subscribe" value="Sign Up"

                type="submit"> <label for="mc-email" class="subscribe-message"></label>
            </form>
          </div>
        </div>
      </div>
      <div class="row footer__bottom">
        <div class="col-five tab-full">
          <div class="footer__logo"> <a href="index.html"> <img src="images/logo.png"

                alt="Homepage"> </a> </div>
          <p> Read books of your neighbors instead of wasting money on new books
            to read once and store forever. </p>
          <ul class="footer__social">
            <li><a href="#0"><i class="fab fa-facebook-f" aria-hidden="true"></i></a><br>
            </li>
            <li><a href="#0"><i class="fab fa-twitter" aria-hidden="true"></i></a><br>
            </li>
            <li><a href="#0"><i class="fab fa-instagram" aria-hidden="true"></i></a><br>
            </li>
          </ul>
        </div>
        <div class="col-six tab-full end">
          <ul class="footer__site-links">
            <li><a class="smoothscroll" href="#home" title="intro">Intro</a></li>
            <li><a class="smoothscroll" href="#about" title="about">About</a></li>
            <li><a class="smoothscroll" href="#features" title="features">Features</a></li>
            <li><a class="smoothscroll" href="#pricing" title="pricing">Pricing</a></li>
          </ul>
          <p class="footer__contact"> Do you have a question? Send us a word: <br>
            <a href="mailto:#0" class="footer__mail-link">support@biblosphere.org</a>
          </p>
          <div class="cl-copyright"> <span><!-- Link back to Colorlib can't be removed. Template is licensed under CC BY 3.0. -->
              Copyright ©
              <script>document.write(new Date().getFullYear());</script> All
              rights reserved | This template is made with by <a href="https://colorlib.com"

                target="_blank">Colorlib</a>
              <!-- Link back to Colorlib can't be removed. Template is licensed under CC BY 3.0. -->
            </span> </div>
        </div>
      </div>
      <div class="go-top"> <a class="smoothscroll" title="Back to Top" href="#top"></a>
      </div>
    </footer>
    <!-- end s-footer -->
    <!-- Java Script
    ================================================== -->
    <script src="js/jquery-3.2.1.min.js"></script>
    <script src="js/plugins.js"></script>
    <script src="js/main.js"></script>
    <script src="https://www.gstatic.com/firebasejs/5.5.9/firebase.js"></script>
    <script>
    // Initialize Firebase
    var config = {
      apiKey: "AIzaSyALK5T0HqUsw-KAQMV9NjaPt-4oyWvpw70",
      authDomain: "biblosphere-210106.firebaseapp.com",
      databaseURL: "https://biblosphere-210106.firebaseio.com",
      projectId: "biblosphere-210106",
      storageBucket: "biblosphere-210106.appspot.com",
      messagingSenderId: "779249096383"
    };
    firebase.initializeApp(config);
    /**
     * The JavaScript code that creates the firebase map goes between the empty script tags below.
     */
    // Initialize Cloud Firestore through Firebase
    var db = firebase.firestore();

    // Disable deprecated features
    db.settings({
       timestampsInSnapshots: true
    });

      function initMap() {

        var map = new google.maps.Map(document.getElementById('map'), {
          zoom: 3,
          center: {lat: 42, lng: 40}
        });

        var markers = [];

        db.collection("shelves").get().then((querySnapshot) => {
          querySnapshot.forEach((doc) => {
            var latLng = new google.maps.LatLng(doc.data().position.latitude,
            doc.data().position.longitude);
            var marker = new google.maps.Marker({'position': latLng});
            markers.push(marker);
          });

          // Add a marker clusterer to manage the markers.
          var markerCluster = new MarkerClusterer(map, markers,
              {imagePath: 'https://developers.google.com/maps/documentation/javascript/examples/markerclusterer/m'});
          
          document.getElementById('counter').innerHTML = markers.length;

        }).catch(function(error) {
            console.error("Error reading document: ", error);
        });
      }
    </script>
    <script src="https://developers.google.com/maps/documentation/javascript/examples/markerclusterer/markerclusterer.js">
    </script>
    <script async="" defer="defer" src="https://maps.googleapis.com/maps/api/js?key=AIzaSyDJR_BnU_JVJyGTfaWcj086UuQxXP3LoTU&callback=initMap">
    </script>
  </body>
</html>
`);
  } catch(err) {
    console.log('Request failed: ', err);
    return res.status(404).send("Shelf info retrieval failed");
  }
});