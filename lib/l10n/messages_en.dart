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

  static m0(month) => "Income: ${month} per month";

  static m1(lang) => "Language: ${lang}";

  static m2(user) => "Owner: ${user}";

  static m3(total) => "Price: ${total}";

  static m4(month) => "Price: ${month} per month";

  static m5(user) => "Book with ${user}";

  static m6(count) => "His books with me (${count})";

  static m7(amount) => "Top-up balance ${amount}";

  static m8(price) => "Trial plan allows to keep only up to 2 books at a time. Upgrade for ${price} per month to have more.";

  static m9(price) => "Trial plan only allows 10 books in the wish list. Upgrade for ${price} per month to have more.";

  static m10(distance) => "Distance: ${distance} km";

  static m11(balance) => "MY BALANCE: ${balance}";

  static m12(amount) => "Enter amount not more than ${amount}";

  static m13(total, month) => "Deposit for books: ${total}, monthly payment ${month}";

  static m14(count) => "My books at this user (${count})";

  static m15(missing, total, month) => "Missing ${missing}. Deposit for books: ${total}, monthly payment ${month}";

  static m16(book) => "You can take my book \"${book}\"";

  static m17(count) => "All his books (${count})";

  static m18(num) => "Receiving books (${num})";

  static m19(book) => "Can you give me \"${book}\"?";

  static m20(book) => "Can you send me \"${book}\"?";

  static m21(book) => "I\'d like to return \"${book}\"?";

  static m22(book) => "Please, return me \"${book}\"?";

  static m23(num) => "Handover books (${num})";

  static m24(name) => "Current plan: ${name}";

  static m25(amount) => "Total shared: +${amount}";

  static m26(amount) => "Deposit: ${amount}";

  static m27(amount) => "Monthly pay: ${amount}";

  static m28(count) => "${count} books have been recognized and added to your catalog.";

  static m29(balance) => "Balance: ${balance}";

  static m30(user) => "from ${user}";

  static m31(user) => "Book with ${user}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "accountCopied" : MessageLookupByLibrary.simpleMessage("Account copied to clipboard"),
    "add" : MessageLookupByLibrary.simpleMessage("Add"),
    "addBook" : MessageLookupByLibrary.simpleMessage("Add book"),
    "addToWishlist" : MessageLookupByLibrary.simpleMessage("Add to Wishlist"),
    "addbookTitle" : MessageLookupByLibrary.simpleMessage("ADD BOOK"),
    "blockUser" : MessageLookupByLibrary.simpleMessage("Block abusive user"),
    "blockedChat" : MessageLookupByLibrary.simpleMessage("User blocked"),
    "bookAdded" : MessageLookupByLibrary.simpleMessage("Book has been added to your library"),
    "bookAlreadyThere" : MessageLookupByLibrary.simpleMessage("This book is already in your library"),
    "bookAround" : MessageLookupByLibrary.simpleMessage("Get book"),
    "bookByPost" : MessageLookupByLibrary.simpleMessage("Receive by post"),
    "bookDeleted" : MessageLookupByLibrary.simpleMessage("Book has been deleted from your library"),
    "bookImageLabel" : MessageLookupByLibrary.simpleMessage("Link to book cover image:"),
    "bookInLibrary" : MessageLookupByLibrary.simpleMessage("Find in library via"),
    "bookIncome" : m0,
    "bookLanguage" : m1,
    "bookNotFound" : MessageLookupByLibrary.simpleMessage("This book is not found in Biblosphere. Add it to your wishlist and we\'ll inform you once it\'s available."),
    "bookOwner" : m2,
    "bookPrice" : m3,
    "bookPriceHint" : MessageLookupByLibrary.simpleMessage("Enter book price"),
    "bookPriceLabel" : MessageLookupByLibrary.simpleMessage("Book price"),
    "bookRent" : m4,
    "bookWith" : m5,
    "booksOfUserWithMe" : m6,
    "buttonConfirmBooks" : MessageLookupByLibrary.simpleMessage("Confirm handover ✓"),
    "buttonGivenBooks" : MessageLookupByLibrary.simpleMessage("Books handed over ✓"),
    "buttonManageBook" : MessageLookupByLibrary.simpleMessage("Open in MY BOOKS"),
    "buttonPayin" : MessageLookupByLibrary.simpleMessage("Get balance"),
    "buttonSearchThirdParty" : MessageLookupByLibrary.simpleMessage("Search in Stores & Libraries"),
    "buttonSkip" : MessageLookupByLibrary.simpleMessage("SKIP"),
    "buttonTransfer" : MessageLookupByLibrary.simpleMessage("Transfer"),
    "buttonUpgrade" : MessageLookupByLibrary.simpleMessage("UPGRADE"),
    "buyBook" : MessageLookupByLibrary.simpleMessage("Buy on"),
    "cart" : MessageLookupByLibrary.simpleMessage("Books you are going to take"),
    "cartAddBooks" : MessageLookupByLibrary.simpleMessage("Add books"),
    "cartBooksAccepted" : MessageLookupByLibrary.simpleMessage("Books accepted"),
    "cartBooksGiven" : MessageLookupByLibrary.simpleMessage("Books handed over"),
    "cartConfirmHandover" : MessageLookupByLibrary.simpleMessage("Confirm that book(s) given"),
    "cartConfirmReceived" : MessageLookupByLibrary.simpleMessage("Confirm that books received"),
    "cartMakeApointment" : MessageLookupByLibrary.simpleMessage("Make an apointment"),
    "cartRequesterHasToConfirm" : MessageLookupByLibrary.simpleMessage("Your peer has to accept books"),
    "cartRequesterHasToTopup" : MessageLookupByLibrary.simpleMessage("Your peer has to top-up his balance"),
    "cartTopup" : m7,
    "chatStatusCompleteFrom" : MessageLookupByLibrary.simpleMessage("Book(s) handed over"),
    "chatStatusCompleteTo" : MessageLookupByLibrary.simpleMessage("Book(s) accepted"),
    "chatStatusHandoverFrom" : MessageLookupByLibrary.simpleMessage("Complete book(s) handover"),
    "chatStatusHandoverTo" : MessageLookupByLibrary.simpleMessage("Confirm book(s) handover"),
    "chatStatusInitialFrom" : MessageLookupByLibrary.simpleMessage("Return book"),
    "chatStatusInitialTo" : MessageLookupByLibrary.simpleMessage("Get book(s)"),
    "chatbotWelcome" : MessageLookupByLibrary.simpleMessage("Hello! I\'m chat-bot of Biblosphere. Please ask me any questions about this app."),
    "chipBooksToAskForReturn" : MessageLookupByLibrary.simpleMessage("Remind"),
    "chipBooksToOffer" : MessageLookupByLibrary.simpleMessage("Offer"),
    "chipBooksToRequest" : MessageLookupByLibrary.simpleMessage("Take"),
    "chipBooksToReturn" : MessageLookupByLibrary.simpleMessage("Return"),
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
    "chooseHoldedBookForChat" : MessageLookupByLibrary.simpleMessage("CHOOSE BOOK"),
    "choosePartnerBookForChat" : MessageLookupByLibrary.simpleMessage("CHOOSE BOOK"),
    "confirmBlockUser" : MessageLookupByLibrary.simpleMessage("Do you want to block this user?"),
    "dialogBookLimit" : m8,
    "dialogWishLimit" : m9,
    "displayCurrency" : MessageLookupByLibrary.simpleMessage("Display currency:"),
    "distanceLine" : m10,
    "distanceUnknown" : MessageLookupByLibrary.simpleMessage("Distance: unknown"),
    "emptyAmount" : MessageLookupByLibrary.simpleMessage("Empty amount not accepted"),
    "enterTitle" : MessageLookupByLibrary.simpleMessage("Enter title/author"),
    "exceedAmount" : MessageLookupByLibrary.simpleMessage("Amount exceed available balance"),
    "financeTitle" : m11,
    "findBook" : MessageLookupByLibrary.simpleMessage("Find Book"),
    "findbookTitle" : MessageLookupByLibrary.simpleMessage("FIND BOOK"),
    "hintAddToWishlist" : MessageLookupByLibrary.simpleMessage("Add to wishlist"),
    "hintAuthorTitle" : MessageLookupByLibrary.simpleMessage("Author or title"),
    "hintBookDetails" : MessageLookupByLibrary.simpleMessage("Change book info"),
    "hintChatOpen" : MessageLookupByLibrary.simpleMessage("Start conversation"),
    "hintConfirmHandover" : MessageLookupByLibrary.simpleMessage("Confirm that you\'ve received this book"),
    "hintDeleteBook" : MessageLookupByLibrary.simpleMessage("Delete book"),
    "hintHolderChatOpen" : MessageLookupByLibrary.simpleMessage("Open chat with person who hold the book"),
    "hintManageBook" : MessageLookupByLibrary.simpleMessage("Open this book in MY BOOKS screen"),
    "hintNotMore" : m12,
    "hintOutptAcount" : MessageLookupByLibrary.simpleMessage("Enter your Stellar account for pay out"),
    "hintOutputMemo" : MessageLookupByLibrary.simpleMessage("Memo for payout transaction"),
    "hintRequestReturn" : MessageLookupByLibrary.simpleMessage("Ask for return"),
    "hintReturn" : MessageLookupByLibrary.simpleMessage("Return book"),
    "hintShareBook" : MessageLookupByLibrary.simpleMessage("Share link"),
    "ifNotFound" : MessageLookupByLibrary.simpleMessage("Add book to wishlist if not found"),
    "imageLinkHint" : MessageLookupByLibrary.simpleMessage("Copy link to bookcover image"),
    "inMyBooks" : MessageLookupByLibrary.simpleMessage("You have this book"),
    "inMyWishes" : MessageLookupByLibrary.simpleMessage("This book in your wishlist"),
    "inputStellarAcount" : MessageLookupByLibrary.simpleMessage("Stellar account for Pay In:"),
    "inputStellarMemo" : MessageLookupByLibrary.simpleMessage("Memo for top-up via Stellar:"),
    "introDone" : MessageLookupByLibrary.simpleMessage("DONE"),
    "introMeet" : MessageLookupByLibrary.simpleMessage("Meet"),
    "introMeetHint" : MessageLookupByLibrary.simpleMessage("Contact the owner of the books you like and arrange an appointment to get some new books to read."),
    "introShoot" : MessageLookupByLibrary.simpleMessage("Add books"),
    "introShootHint" : MessageLookupByLibrary.simpleMessage("Add your books by scanning ISBN to share with neighbours and tourists. Your books attract like minded people."),
    "introSkip" : MessageLookupByLibrary.simpleMessage("SKIP"),
    "introSurf" : MessageLookupByLibrary.simpleMessage("Surf"),
    "introSurfHint" : MessageLookupByLibrary.simpleMessage("App shows bookcases in 200 km around you sorted by distance. Get an access to a wide variety of books."),
    "isbnNotFound" : MessageLookupByLibrary.simpleMessage("Book is not found by ISBN"),
    "km" : MessageLookupByLibrary.simpleMessage(" km"),
    "leaseAgreement" : m13,
    "linkCopied" : MessageLookupByLibrary.simpleMessage("Link copied to clipboard"),
    "loading" : MessageLookupByLibrary.simpleMessage("Loading..."),
    "loginAgree1" : MessageLookupByLibrary.simpleMessage("By clicking sign in button below, you agree \n to our "),
    "loginAgree2" : MessageLookupByLibrary.simpleMessage("end user license agreement"),
    "loginAgree3" : MessageLookupByLibrary.simpleMessage("\nand that you read our "),
    "loginAgree4" : MessageLookupByLibrary.simpleMessage("privacy policy"),
    "logout" : MessageLookupByLibrary.simpleMessage("Logout"),
    "memoCopied" : MessageLookupByLibrary.simpleMessage("Memo copied to a clipboard"),
    "menuBalance" : MessageLookupByLibrary.simpleMessage("Balance"),
    "menuMessages" : MessageLookupByLibrary.simpleMessage("Messages"),
    "menuReferral" : MessageLookupByLibrary.simpleMessage("Referral program"),
    "menuSettings" : MessageLookupByLibrary.simpleMessage("Settings"),
    "menuSupport" : MessageLookupByLibrary.simpleMessage("Support"),
    "myBooks" : MessageLookupByLibrary.simpleMessage("My books"),
    "myBooksWithUser" : m14,
    "mybooksTitle" : MessageLookupByLibrary.simpleMessage("MY BOOKS"),
    "negativeAmount" : MessageLookupByLibrary.simpleMessage("Amount should be positive"),
    "no" : MessageLookupByLibrary.simpleMessage("No"),
    "noMessages" : MessageLookupByLibrary.simpleMessage("No messages"),
    "noOperations" : MessageLookupByLibrary.simpleMessage("No operations"),
    "noReferrals" : MessageLookupByLibrary.simpleMessage("No referrals"),
    "notSufficientForAgreement" : m15,
    "nothingToSend" : MessageLookupByLibrary.simpleMessage("Nothing to send"),
    "offerBook" : m16,
    "ok" : MessageLookupByLibrary.simpleMessage("Ok"),
    "opInAppPurchase" : MessageLookupByLibrary.simpleMessage("Pay In (In-App)"),
    "opInStellar" : MessageLookupByLibrary.simpleMessage("Pay In (Stellar)"),
    "opLeasing" : MessageLookupByLibrary.simpleMessage("Spent/Deposit for book"),
    "opOutStellar" : MessageLookupByLibrary.simpleMessage("Pay Out (Stellar)"),
    "opReferral" : MessageLookupByLibrary.simpleMessage("Referrals pay"),
    "opReward" : MessageLookupByLibrary.simpleMessage("Reward for book"),
    "outputStellarAccount" : MessageLookupByLibrary.simpleMessage("Stellar account for Pay Out:"),
    "outputStellarMemo" : MessageLookupByLibrary.simpleMessage("Memo for payout via Stellar:"),
    "paymentError" : MessageLookupByLibrary.simpleMessage("Something went wrong, contact administrator"),
    "planTrial" : MessageLookupByLibrary.simpleMessage("Trial"),
    "profileUserBooks" : m17,
    "receiveBooks" : m18,
    "recognizeFromCamera" : MessageLookupByLibrary.simpleMessage("Take a photo to recognize books"),
    "recognizeFromGallery" : MessageLookupByLibrary.simpleMessage("Recognize books from gallery photo"),
    "referralLink" : MessageLookupByLibrary.simpleMessage("Your referral link:"),
    "referralTitle" : MessageLookupByLibrary.simpleMessage("MY REFERRALS"),
    "requestBook" : m19,
    "requestPost" : m20,
    "requestReturn" : m21,
    "requestReturnByOwner" : m22,
    "scanISBN" : MessageLookupByLibrary.simpleMessage("Scan ISBN"),
    "selectDisplayCurrency" : MessageLookupByLibrary.simpleMessage("Choose display currency:"),
    "sendBooks" : m23,
    "settingsPlan" : m24,
    "settingsTitleGeneral" : MessageLookupByLibrary.simpleMessage("General settings"),
    "settingsTitleIn" : MessageLookupByLibrary.simpleMessage("Get balance"),
    "settingsTitleInStellar" : MessageLookupByLibrary.simpleMessage("Get balance via Stallar"),
    "settingsTitleOutStellar" : MessageLookupByLibrary.simpleMessage("Payout via Stallar"),
    "sharedFeeLine" : m25,
    "sharingMotto" : MessageLookupByLibrary.simpleMessage("Take books from people instead of buying"),
    "showDeposit" : m26,
    "showRent" : m27,
    "snackAllowLocation" : MessageLookupByLibrary.simpleMessage("Please allow access to location for searching and adding books"),
    "snackBookAddedToCart" : MessageLookupByLibrary.simpleMessage("Book was added to the cart"),
    "snackBookImageChanged" : MessageLookupByLibrary.simpleMessage("New cover image is set"),
    "snackBookNotConfirmed" : MessageLookupByLibrary.simpleMessage("Confirm other books before asking new ones"),
    "snackBookNotFound" : MessageLookupByLibrary.simpleMessage("Book not found. Add book manually to the cart."),
    "snackBookPending" : MessageLookupByLibrary.simpleMessage("Previous book handover not confirmed. Please ask your peer to confirm."),
    "snackBookPriceChanged" : MessageLookupByLibrary.simpleMessage("Price is saved"),
    "snackPaidPlanActivated" : MessageLookupByLibrary.simpleMessage("Your paid plan is activated"),
    "snackRecgnitionStarted" : MessageLookupByLibrary.simpleMessage("Image recognition take up to 2 min. Meanwhile take a next photo."),
    "snackRecognitionDone" : m28,
    "snackWishDeleted" : MessageLookupByLibrary.simpleMessage("Book deleted from your wishlist"),
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
    "transitInitiated" : MessageLookupByLibrary.simpleMessage("Handover process initiated for the book"),
    "typeMsg" : MessageLookupByLibrary.simpleMessage("Type your message..."),
    "userBalance" : m29,
    "userHave" : m30,
    "welcome" : MessageLookupByLibrary.simpleMessage("WELCOME"),
    "wishAdded" : MessageLookupByLibrary.simpleMessage("Book has been added to your wishlist"),
    "wishAlreadyThere" : MessageLookupByLibrary.simpleMessage("This book is already in your wishlist"),
    "wrongAccount" : MessageLookupByLibrary.simpleMessage("Wrong account"),
    "wrongImageUrl" : MessageLookupByLibrary.simpleMessage("Wrong link"),
    "youBorrowThisBook" : MessageLookupByLibrary.simpleMessage("You borrowed this book"),
    "youHaveThisBook" : MessageLookupByLibrary.simpleMessage("You keep this book"),
    "youLentThisBook" : m31,
    "youTransitThisBook" : MessageLookupByLibrary.simpleMessage("This book is in transit"),
    "youWishThisBook" : MessageLookupByLibrary.simpleMessage("This book in your wishlist")
  };
}
