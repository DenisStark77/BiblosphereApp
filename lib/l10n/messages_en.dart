// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static m0(count) => "${Intl.plural(count, zero: 'No books', one: '${count} book', other: '${count} books')}";

  static m1(month) => "Income: ${month} per month";

  static m2(lang) => "Language: ${lang}";

  static m3(user) => "Owner: ${user}";

  static m4(total) => "Price: ${total}";

  static m5(month) => "Price: ${month} per month";

  static m6(user) => "Book with ${user}";

  static m7(count) => "His books with me (${count})";

  static m8(name, title) => "Book \'${title}\' belong to user \'${name}\'. Press outbox button below to initiate return.";

  static m9(name, title) => "User \'${name}\' offer you his book \'${title}\'. Please arrange handover and confirm on receive. Or reject in case you are not interested.";

  static m10(name, title) => "User \'${name}\' has accepted your request for his book \'${title}\'. Please arrange handover and confirm on receive.";

  static m11(name, title) => "Wait for user \'${name}\' to accept your request of his book \'${title}\'. Chat to facilitate.";

  static m12(name, title) => "User \'${name}\' has rejected your request for his book \'${title}\'. You can chat to get explamations.";

  static m13(name, title) => "User \'${name}\' wish to return your book \'${title}\'. Please arrange handover.";

  static m14(amount) => "Top-up balance ${amount}";

  static m15(distance) => "Distance: ${distance} km";

  static m16(balance) => "MY BALANCE: ${balance}";

  static m17(amount) => "Enter amount not more than ${amount}";

  static m18(total, month) => "Deposit for books: ${total}, monthly payment ${month}";

  static m19(name, title) => "Your book \'${title}\' now with user \'${name}\'. Chat with him to remind about return.";

  static m20(count) => "My books at this user (${count})";

  static m21(missing, total, month) => "Missing ${missing}. Deposit for books: ${total}, monthly payment ${month}";

  static m22(name, title) => "You\'ve offered book \'${title}\' to user \'${name}\'. Please chat to arrange handover.";

  static m23(name, title) => "User \'${name}\' confirmed handover of book \'${title}\'. You can see this book in your MY LENT books.";

  static m24(name, title) => "User \'${name}\' rejected your offer for book \'${title}\'. You can chat to get details.";

  static m25(name, title) => "User \'${name}\' request your book \'${title}\'. Please accept or reject. Chat for more details.";

  static m26(name, title) => "Please arrange handover of book \'${title}\' to user \'${name}\'. Chat to coordinate.";

  static m27(name, title) => "User \'${name}\' canceled request for your book \'${title}\'.";

  static m28(name, title) => "Handover of book \'${title}\' to user \'${name}\' confirmed. You can see this book in MY LENT books.";

  static m29(name, title) => "Arrange handover of book \'${title}\' to user \'${name}\'. Chat to facilitate.";

  static m30(name, title) => "User \'${name}\' confirmed handover of the book \'${title}\'.";

  static m31(count) => "All his books (${count})";

  static m32(num) => "Receiving books (${num})";

  static m33(book) => "Can you give me \"${book}\"?";

  static m34(book) => "Can you send me \"${book}\"?";

  static m35(book) => "I\'d like to return \"${book}\"?";

  static m36(book) => "Please, return me \"${book}\"?";

  static m37(num) => "Handover books (${num})";

  static m38(amount) => "Total shared: +${amount}";

  static m39(count) => "${Intl.plural(count, zero: 'No bookshelves', one: '${count} bookshelf', other: '${count} bookshelves')}";

  static m40(amount) => "Deposit: ${amount}";

  static m41(amount) => "Monthly pay: ${amount}";

  static m42(balance) => "Balance: ${balance}";

  static m43(user) => "from ${user}";

  static m44(count) => "${Intl.plural(count, zero: 'No wishes', one: '${count} wish', other: '${count} wishes')}";

  static m45(name, title) => "${name} wish to read your book \'${title}\'";

  static m46(user) => "Book with ${user}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "accountCopied" : MessageLookupByLibrary.simpleMessage("Account copied to clipboard"),
    "add" : MessageLookupByLibrary.simpleMessage("Add"),
    "addBook" : MessageLookupByLibrary.simpleMessage("Add book"),
    "addShelf" : MessageLookupByLibrary.simpleMessage("Add your bookshelf"),
    "addToCart" : MessageLookupByLibrary.simpleMessage("Add book to your cart"),
    "addToOutbox" : MessageLookupByLibrary.simpleMessage("Add book to your outbox"),
    "addToWishlist" : MessageLookupByLibrary.simpleMessage("Add to Wishlist"),
    "addYourBook" : MessageLookupByLibrary.simpleMessage("Add your book"),
    "addYourBookshelf" : MessageLookupByLibrary.simpleMessage("Add your bookshelf"),
    "addbookTitle" : MessageLookupByLibrary.simpleMessage("ADD BOOK"),
    "blockUser" : MessageLookupByLibrary.simpleMessage("Block abusive user"),
    "blockedChat" : MessageLookupByLibrary.simpleMessage("User blocked"),
    "bookAdded" : MessageLookupByLibrary.simpleMessage("Book has been added to your library"),
    "bookAlreadyThere" : MessageLookupByLibrary.simpleMessage("This book is already in your library"),
    "bookAround" : MessageLookupByLibrary.simpleMessage("Get book"),
    "bookByPost" : MessageLookupByLibrary.simpleMessage("Receive by post"),
    "bookCount" : m0,
    "bookDeleted" : MessageLookupByLibrary.simpleMessage("Book has been deleted from your library"),
    "bookImageLabel" : MessageLookupByLibrary.simpleMessage("Link to book cover image:"),
    "bookInLibrary" : MessageLookupByLibrary.simpleMessage("Find in library via"),
    "bookIncome" : m1,
    "bookLanguage" : m2,
    "bookNotFound" : MessageLookupByLibrary.simpleMessage("This book is not found in Biblosphere. Add it to your wishlist and we\'ll inform you once it\'s available."),
    "bookOwner" : m3,
    "bookPrice" : m4,
    "bookPriceHint" : MessageLookupByLibrary.simpleMessage("Enter book price"),
    "bookPriceLabel" : MessageLookupByLibrary.simpleMessage("Book price"),
    "bookRent" : m5,
    "bookWith" : m6,
    "books" : MessageLookupByLibrary.simpleMessage("Books"),
    "booksOfUserWithMe" : m7,
    "bookshelves" : MessageLookupByLibrary.simpleMessage("Bookshelves"),
    "borrow" : MessageLookupByLibrary.simpleMessage("Borrow"),
    "borrowedBookText" : m8,
    "buttonConfirmBooks" : MessageLookupByLibrary.simpleMessage("Confirm handover ✓"),
    "buttonGivenBooks" : MessageLookupByLibrary.simpleMessage("Books handed over ✓"),
    "buttonPayin" : MessageLookupByLibrary.simpleMessage("Get balance"),
    "buttonTransfer" : MessageLookupByLibrary.simpleMessage("Transfer"),
    "buyBook" : MessageLookupByLibrary.simpleMessage("Buy on"),
    "cart" : MessageLookupByLibrary.simpleMessage("Books you are going to take"),
    "cartAddBooks" : MessageLookupByLibrary.simpleMessage("Add books"),
    "cartBooksAccepted" : MessageLookupByLibrary.simpleMessage("Books accepted"),
    "cartBooksGiven" : MessageLookupByLibrary.simpleMessage("Books handed over"),
    "cartConfirmHandover" : MessageLookupByLibrary.simpleMessage("Confirm that book(s) given"),
    "cartConfirmReceived" : MessageLookupByLibrary.simpleMessage("Confirm that books received"),
    "cartMakeApointment" : MessageLookupByLibrary.simpleMessage("Make an apointment"),
    "cartOfferConfirmReject" : m9,
    "cartRequestAccepted" : m10,
    "cartRequestCancel" : m11,
    "cartRequestRejected" : m12,
    "cartRequesterHasToConfirm" : MessageLookupByLibrary.simpleMessage("Your peer has to accept books"),
    "cartRequesterHasToTopup" : MessageLookupByLibrary.simpleMessage("Your peer has to top-up his balance"),
    "cartReturnConfirm" : m13,
    "cartTopup" : m14,
    "chat" : MessageLookupByLibrary.simpleMessage("CHAT"),
    "chatStatusCompleteFrom" : MessageLookupByLibrary.simpleMessage("Book(s) handed over"),
    "chatStatusCompleteTo" : MessageLookupByLibrary.simpleMessage("Book(s) accepted"),
    "chatStatusHandoverFrom" : MessageLookupByLibrary.simpleMessage("Complete book(s) handover"),
    "chatStatusHandoverTo" : MessageLookupByLibrary.simpleMessage("Confirm book(s) handover"),
    "chatStatusInitialFrom" : MessageLookupByLibrary.simpleMessage("Return book"),
    "chatStatusInitialTo" : MessageLookupByLibrary.simpleMessage("Get book(s)"),
    "chatbotWelcome" : MessageLookupByLibrary.simpleMessage("Hello! I\'m chat-bot of Biblosphere. Please ask me any questions about this app."),
    "chipBorrowed" : MessageLookupByLibrary.simpleMessage("Borrowed"),
    "chipHisBooks" : MessageLookupByLibrary.simpleMessage("His(her) books"),
    "chipHisBooksWithMe" : MessageLookupByLibrary.simpleMessage("His(her) books with me"),
    "chipLeasing" : MessageLookupByLibrary.simpleMessage("Spent"),
    "chipLent" : MessageLookupByLibrary.simpleMessage("Lent"),
    "chipMyBooks" : MessageLookupByLibrary.simpleMessage("My books"),
    "chipMyBooksWithHim" : MessageLookupByLibrary.simpleMessage("My books with him(her)"),
    "chipPayin" : MessageLookupByLibrary.simpleMessage("Pay In"),
    "chipPayout" : MessageLookupByLibrary.simpleMessage("Pay Out"),
    "chipReferrals" : MessageLookupByLibrary.simpleMessage("Referrals"),
    "chipReward" : MessageLookupByLibrary.simpleMessage("Rewards"),
    "chipTransit" : MessageLookupByLibrary.simpleMessage("Transit"),
    "chipWish" : MessageLookupByLibrary.simpleMessage("Wishes"),
    "confirmBlockUser" : MessageLookupByLibrary.simpleMessage("Do you want to block this user?"),
    "confirmReportPhoto" : MessageLookupByLibrary.simpleMessage("Do you want to report this photo as abusive?"),
    "deleteShelf" : MessageLookupByLibrary.simpleMessage("Delete your bookshelf"),
    "displayCurrency" : MessageLookupByLibrary.simpleMessage("Display currency:"),
    "distanceLine" : m15,
    "distanceUnknown" : MessageLookupByLibrary.simpleMessage("Distance: unknown"),
    "drawerHeader" : MessageLookupByLibrary.simpleMessage("Choose mode"),
    "earn" : MessageLookupByLibrary.simpleMessage("Earn"),
    "emptyAmount" : MessageLookupByLibrary.simpleMessage("Empty amount not accepted"),
    "enterTitle" : MessageLookupByLibrary.simpleMessage("Enter title/author"),
    "exceedAmount" : MessageLookupByLibrary.simpleMessage("Amount exceed available balance"),
    "explore" : MessageLookupByLibrary.simpleMessage("Explore"),
    "favorite" : MessageLookupByLibrary.simpleMessage("Add shelf to favorite"),
    "financeTitle" : m16,
    "findBook" : MessageLookupByLibrary.simpleMessage("Find Book"),
    "findbookTitle" : MessageLookupByLibrary.simpleMessage("FIND BOOK"),
    "hintAuthorTitle" : MessageLookupByLibrary.simpleMessage("Author or title"),
    "hintBookDetails" : MessageLookupByLibrary.simpleMessage("Change book info"),
    "hintChatOpen" : MessageLookupByLibrary.simpleMessage("Start conversation"),
    "hintDeleteBook" : MessageLookupByLibrary.simpleMessage("Delete book"),
    "hintNotMore" : m17,
    "hintOutptAcount" : MessageLookupByLibrary.simpleMessage("Enter your Stellar account for pay out"),
    "hintRequestReturn" : MessageLookupByLibrary.simpleMessage("Ask for return"),
    "hintReturn" : MessageLookupByLibrary.simpleMessage("Return book"),
    "hintShareBook" : MessageLookupByLibrary.simpleMessage("Share link"),
    "ifNotFound" : MessageLookupByLibrary.simpleMessage("Add book to wishlist if not found"),
    "imageLinkHint" : MessageLookupByLibrary.simpleMessage("Copy link to bookcover image"),
    "importToBooks" : MessageLookupByLibrary.simpleMessage("Import to available books:"),
    "importToWishlist" : MessageLookupByLibrary.simpleMessage("Import to Wishlist:"),
    "importYouBooks" : MessageLookupByLibrary.simpleMessage("Import your books to Biblosphere"),
    "inMyBooks" : MessageLookupByLibrary.simpleMessage("You have this book"),
    "inMyWishes" : MessageLookupByLibrary.simpleMessage("This book in your wishlist"),
    "inputStellarAcount" : MessageLookupByLibrary.simpleMessage("Stellar account for Pay In:"),
    "inputStellarMemo" : MessageLookupByLibrary.simpleMessage("Memo for top-up via Stellar:"),
    "introDone" : MessageLookupByLibrary.simpleMessage("DONE"),
    "introMeet" : MessageLookupByLibrary.simpleMessage("Meet"),
    "introMeetHint" : MessageLookupByLibrary.simpleMessage("Contact the owner of the books you like and arrange an appointment to get some new books to read."),
    "introShoot" : MessageLookupByLibrary.simpleMessage("Shoot"),
    "introShootHint" : MessageLookupByLibrary.simpleMessage("Shoot your bookcase and share with neighbours and tourists. Your books attract likeminded people."),
    "introSkip" : MessageLookupByLibrary.simpleMessage("SKIP"),
    "introSurf" : MessageLookupByLibrary.simpleMessage("Surf"),
    "introSurfHint" : MessageLookupByLibrary.simpleMessage("App shows bookcases in 200 km around you sorted by distance. Get an access to a wide variety of books."),
    "isbnNotFound" : MessageLookupByLibrary.simpleMessage("Book is not found by ISBN"),
    "km" : MessageLookupByLibrary.simpleMessage(" km"),
    "leaseAgreement" : m18,
    "lentBookText" : m19,
    "linkCopied" : MessageLookupByLibrary.simpleMessage("Link copied to clipboard"),
    "linkToGoodreads" : MessageLookupByLibrary.simpleMessage("Link your Goodreads"),
    "linkYourAccount" : MessageLookupByLibrary.simpleMessage("Link your Goodreads account"),
    "loadPhotoOfShelf" : MessageLookupByLibrary.simpleMessage("Load shelf photo from gallery"),
    "loading" : MessageLookupByLibrary.simpleMessage("Loading..."),
    "loginAgree1" : MessageLookupByLibrary.simpleMessage("By clicking sign in button below, you agree \n to our "),
    "loginAgree2" : MessageLookupByLibrary.simpleMessage("end user license agreement"),
    "loginAgree3" : MessageLookupByLibrary.simpleMessage("\nand that you read our "),
    "loginAgree4" : MessageLookupByLibrary.simpleMessage("privacy policy"),
    "logout" : MessageLookupByLibrary.simpleMessage("Logout"),
    "makePhotoOfShelf" : MessageLookupByLibrary.simpleMessage("Make a photo of your bookshelf"),
    "meet" : MessageLookupByLibrary.simpleMessage("Meet"),
    "memoCopied" : MessageLookupByLibrary.simpleMessage("Memo copied to a clipboard"),
    "menuBalance" : MessageLookupByLibrary.simpleMessage("Balance"),
    "menuMessages" : MessageLookupByLibrary.simpleMessage("Messages"),
    "menuReferral" : MessageLookupByLibrary.simpleMessage("Referral program"),
    "menuSettings" : MessageLookupByLibrary.simpleMessage("Settings"),
    "menuSupport" : MessageLookupByLibrary.simpleMessage("Support"),
    "messageOwner" : MessageLookupByLibrary.simpleMessage("Message owner"),
    "messageRecepient" : MessageLookupByLibrary.simpleMessage("Chat with book recipient."),
    "myBooks" : MessageLookupByLibrary.simpleMessage("My books"),
    "myBooksItem" : MessageLookupByLibrary.simpleMessage("My books"),
    "myBooksTitle" : MessageLookupByLibrary.simpleMessage("MY BOOKS"),
    "myBooksWithUser" : m20,
    "myBookshelvesItem" : MessageLookupByLibrary.simpleMessage("My bookshelves"),
    "myBookshelvesTitle" : MessageLookupByLibrary.simpleMessage("MY BOOKSHELVES"),
    "myBorrowedBooksItem" : MessageLookupByLibrary.simpleMessage("Borrowed books"),
    "myBorrowedBooksTitle" : MessageLookupByLibrary.simpleMessage("BORROWED BOOKS"),
    "myCartTitle" : MessageLookupByLibrary.simpleMessage("MY CART"),
    "myLendedBooksItem" : MessageLookupByLibrary.simpleMessage("Lent books"),
    "myLendedBooksTitle" : MessageLookupByLibrary.simpleMessage("LENT BOOKS"),
    "myOutboxTitle" : MessageLookupByLibrary.simpleMessage("MY OUTBOX"),
    "myWishlistItem" : MessageLookupByLibrary.simpleMessage("My wishlist"),
    "myWishlistTitle" : MessageLookupByLibrary.simpleMessage("MY WISHLIST"),
    "mybooksTitle" : MessageLookupByLibrary.simpleMessage("MY BOOKS"),
    "negativeAmount" : MessageLookupByLibrary.simpleMessage("Amount should be positive"),
    "no" : MessageLookupByLibrary.simpleMessage("No"),
    "noBooks" : MessageLookupByLibrary.simpleMessage("You don\'t have any books in Biblosphere. Add it manually or import from Goodreads."),
    "noBookshelves" : MessageLookupByLibrary.simpleMessage("You don\'t have any bookshelves in Biblosphere. Make a photo of your bookshelf to share with neighbours."),
    "noBorrowedBooks" : MessageLookupByLibrary.simpleMessage("You do not have any borrowed books"),
    "noItemsInCart" : MessageLookupByLibrary.simpleMessage("Your cart is empty. Add books from the list of the books or your matched wishes."),
    "noItemsInOutbox" : MessageLookupByLibrary.simpleMessage("Your outbox is empty. Wait for people to request your books or offer your books in matched books."),
    "noLendedBooks" : MessageLookupByLibrary.simpleMessage("You do not have any lent books"),
    "noMatchForBooks" : MessageLookupByLibrary.simpleMessage("Here you\'ll see people who wish your books once they are registered. To make it happen add more books and spread the word about Biblosphere."),
    "noMatchForWishlist" : MessageLookupByLibrary.simpleMessage("Hey, right now nodody around you has the books from your wishlist. They will be shown here once someone registers them.\nSpread the word about Biblosphere to make it happen sooner. And add more books to your wishlist."),
    "noMessages" : MessageLookupByLibrary.simpleMessage("No messages"),
    "noOperations" : MessageLookupByLibrary.simpleMessage("No operations"),
    "noReferrals" : MessageLookupByLibrary.simpleMessage("No referrals"),
    "noWishes" : MessageLookupByLibrary.simpleMessage("You don\'t have any books in your wishlist. Add it manually or import from Goodreads."),
    "notBooks" : MessageLookupByLibrary.simpleMessage("Hey, this does not look like a bookshelf to me."),
    "notSufficientForAgreement" : m21,
    "nothingToSend" : MessageLookupByLibrary.simpleMessage("Nothing to send"),
    "ok" : MessageLookupByLibrary.simpleMessage("Ok"),
    "opInAppPurchase" : MessageLookupByLibrary.simpleMessage("Pay In (In-App)"),
    "opInStellar" : MessageLookupByLibrary.simpleMessage("Pay In (Stellar)"),
    "opLeasing" : MessageLookupByLibrary.simpleMessage("Spent/Deposit for book"),
    "opOutStellar" : MessageLookupByLibrary.simpleMessage("Pay Out (Stellar)"),
    "opReferral" : MessageLookupByLibrary.simpleMessage("Referrals pay"),
    "opReward" : MessageLookupByLibrary.simpleMessage("Reward for book"),
    "outbox" : MessageLookupByLibrary.simpleMessage("Books you are giving away"),
    "outboxOfferAccepted" : m22,
    "outboxOfferConfirmed" : m23,
    "outboxOfferRejected" : m24,
    "outboxRequestAcceptReject" : m25,
    "outboxRequestAccepted" : m26,
    "outboxRequestCanceled" : m27,
    "outboxRequestConfirmed" : m28,
    "outboxReturnAccepted" : m29,
    "outboxReturnConfirmed" : m30,
    "outputStellarAccount" : MessageLookupByLibrary.simpleMessage("Stellar account for Pay Out:"),
    "outputStellarMemo" : MessageLookupByLibrary.simpleMessage("Memo for payout via Stellar:"),
    "paymentError" : MessageLookupByLibrary.simpleMessage("Something went wrong, contact administrator"),
    "people" : MessageLookupByLibrary.simpleMessage("People"),
    "profileUserBooks" : m31,
    "read" : MessageLookupByLibrary.simpleMessage("Read"),
    "receiveBooks" : m32,
    "recentWishes" : MessageLookupByLibrary.simpleMessage("Recent wishes:"),
    "referralLink" : MessageLookupByLibrary.simpleMessage("Your referral link:"),
    "referralTitle" : MessageLookupByLibrary.simpleMessage("MY REFERRALS"),
    "reportShelf" : MessageLookupByLibrary.simpleMessage("Report an objectionable content"),
    "reportedPhoto" : MessageLookupByLibrary.simpleMessage("This photo is reported as an objectionable content."),
    "requestBook" : m33,
    "requestPost" : m34,
    "requestReturn" : m35,
    "requestReturnByOwner" : m36,
    "scanISBN" : MessageLookupByLibrary.simpleMessage("Scan ISBN"),
    "seeLocation" : MessageLookupByLibrary.simpleMessage("See location"),
    "selectDisplayCurrency" : MessageLookupByLibrary.simpleMessage("Choose display currency:"),
    "sendBooks" : m37,
    "settings" : MessageLookupByLibrary.simpleMessage("Settings"),
    "share" : MessageLookupByLibrary.simpleMessage("Share"),
    "shareBooks" : MessageLookupByLibrary.simpleMessage("I\'m sharing my books on Biblosphere. Join me to read it."),
    "shareBookshelf" : MessageLookupByLibrary.simpleMessage("That\'s my bookshelf. Join Biblosphere to share books and find like-minded people."),
    "shareShelf" : MessageLookupByLibrary.simpleMessage("Share your bookshelf"),
    "shareWishlist" : MessageLookupByLibrary.simpleMessage("I\'m sharing my book wishlist on Biblosphere. Join me."),
    "sharedFeeLine" : m38,
    "sharingMotto" : MessageLookupByLibrary.simpleMessage("Take books from people instead of buying"),
    "shelfAdded" : MessageLookupByLibrary.simpleMessage("New bookshelf has been added"),
    "shelfCount" : m39,
    "shelfDeleted" : MessageLookupByLibrary.simpleMessage("Bookshelf has been deleted"),
    "shelfSettings" : MessageLookupByLibrary.simpleMessage("Bookshelf settings"),
    "shelves" : MessageLookupByLibrary.simpleMessage("Shelves"),
    "showDeposit" : m40,
    "showRent" : m41,
    "snackAllowLocation" : MessageLookupByLibrary.simpleMessage("Please allow access to location for searching and adding books"),
    "snackBookAddedToCart" : MessageLookupByLibrary.simpleMessage("Book was added to the cart"),
    "snackBookAlreadyInTransit" : MessageLookupByLibrary.simpleMessage("Book is booked by another user. Choose another one."),
    "snackBookImageChanged" : MessageLookupByLibrary.simpleMessage("New cover image is set"),
    "snackBookNotConfirmed" : MessageLookupByLibrary.simpleMessage("Confirm other books before asking new ones"),
    "snackBookNotFound" : MessageLookupByLibrary.simpleMessage("Book not found. Add book manually to the cart."),
    "snackBookPending" : MessageLookupByLibrary.simpleMessage("Previous book handover not confirmed. Please ask your peer to confirm."),
    "snackBookPriceChanged" : MessageLookupByLibrary.simpleMessage("Price is saved"),
    "stellarOutput" : MessageLookupByLibrary.simpleMessage("Pay out to Stellar account:"),
    "successfulPayment" : MessageLookupByLibrary.simpleMessage("Successful payment"),
    "supportChat" : MessageLookupByLibrary.simpleMessage("Support chat"),
    "supportChatbot" : MessageLookupByLibrary.simpleMessage("There are chat with support chatbot in the message screen. (S)he can answer any questions about Biblosphere application. Or contact me directly in Telegram "),
    "supportGetBalance" : MessageLookupByLibrary.simpleMessage("There are two ways to top-up your balance. First with In-App purchase by card registered in Google Play or App Store. Second by transfering Stellar (XLM) to account given in your Setting screen. Don\'t forget to give memo while transferring."),
    "supportGetBooks" : MessageLookupByLibrary.simpleMessage("Find books whch you like. Message owner of the book to make an apointment. To get book(s) you have to pay a deposit. It will be released once book(s) returned. You can top-up your balance by card via In-App Purchase or by Stellar cryptocurrency. To earn balance share your books and participate in partner program by initing other people in Biblosphere."),
    "supportPayout" : MessageLookupByLibrary.simpleMessage("Once you\'ve earned significant balance in Biblosphere you can withdraw it. Payouts are working via Stellar (XLM) cryptocurrency. You can transfer to your Stellar wallet or use cryptocurrency exchanges to withdraw to your card or online-wallet."),
    "supportReferrals" : MessageLookupByLibrary.simpleMessage("Facilitate book exchange via Biblosphere in your community or office and receive rewards from every transaction they made. To participate share your partner link to friends and colleagues."),
    "supportSignature" : MessageLookupByLibrary.simpleMessage("Denis Stark"),
    "supportTitle" : MessageLookupByLibrary.simpleMessage("SUPPORT"),
    "supportTitleChatbot" : MessageLookupByLibrary.simpleMessage("Support Chatbot"),
    "supportTitleGetBalance" : MessageLookupByLibrary.simpleMessage("Top-up balance"),
    "supportTitleGetBooks" : MessageLookupByLibrary.simpleMessage("How to get books"),
    "supportTitlePayout" : MessageLookupByLibrary.simpleMessage("Payouts"),
    "supportTitleReferrals" : MessageLookupByLibrary.simpleMessage("Referral program"),
    "title" : MessageLookupByLibrary.simpleMessage("BIBLOSPHERE"),
    "titleBookSettings" : MessageLookupByLibrary.simpleMessage("ABOUT BOOK"),
    "titleGetBook" : MessageLookupByLibrary.simpleMessage("GET BOOK"),
    "titleMessages" : MessageLookupByLibrary.simpleMessage("MESSAGES"),
    "titleReceiveBooks" : MessageLookupByLibrary.simpleMessage("RECEIVING BOOKS"),
    "titleSendBooks" : MessageLookupByLibrary.simpleMessage("HANDOVER BOOKS"),
    "titleSettings" : MessageLookupByLibrary.simpleMessage("SETTINGS"),
    "titleSupport" : MessageLookupByLibrary.simpleMessage("SUPPORT"),
    "titleUserBooks" : MessageLookupByLibrary.simpleMessage("BOOK EXCHENGE"),
    "transitAccept" : MessageLookupByLibrary.simpleMessage("Accept"),
    "transitCancel" : MessageLookupByLibrary.simpleMessage("Cancel"),
    "transitConfirm" : MessageLookupByLibrary.simpleMessage("Confirm"),
    "transitInitiated" : MessageLookupByLibrary.simpleMessage("Handover process initiated for the book"),
    "transitOk" : MessageLookupByLibrary.simpleMessage("Ok"),
    "transitReject" : MessageLookupByLibrary.simpleMessage("Reject"),
    "typeMsg" : MessageLookupByLibrary.simpleMessage("Type your message..."),
    "useCurrentLocation" : MessageLookupByLibrary.simpleMessage("Use current location for import"),
    "userBalance" : m42,
    "userHave" : m43,
    "welcome" : MessageLookupByLibrary.simpleMessage("WELCOME"),
    "wishAdded" : MessageLookupByLibrary.simpleMessage("Book has been added to your wishlist"),
    "wishAlreadyThere" : MessageLookupByLibrary.simpleMessage("This book is already in your wishlist"),
    "wishCount" : m44,
    "wishDeleted" : MessageLookupByLibrary.simpleMessage("Book has been deleted from your wishlist"),
    "wishToRead" : m45,
    "wished" : MessageLookupByLibrary.simpleMessage("Wished"),
    "wrongAccount" : MessageLookupByLibrary.simpleMessage("Wrong account"),
    "wrongImageUrl" : MessageLookupByLibrary.simpleMessage("Wrong link"),
    "youBorrowThisBook" : MessageLookupByLibrary.simpleMessage("You borrowed this book"),
    "youHaveThisBook" : MessageLookupByLibrary.simpleMessage("You keep this book"),
    "youLentThisBook" : m46,
    "youTransitThisBook" : MessageLookupByLibrary.simpleMessage("This book is in transit"),
    "youWishThisBook" : MessageLookupByLibrary.simpleMessage("This book in your wishlist"),
    "yourBiblosphere" : MessageLookupByLibrary.simpleMessage("Your Biblosphere"),
    "yourGoodreads" : MessageLookupByLibrary.simpleMessage("Your Goodreads"),
    "zoom" : MessageLookupByLibrary.simpleMessage("ZOOM")
  };
}
