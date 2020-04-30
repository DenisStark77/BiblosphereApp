// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a it locale. All the
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
  String get localeName => 'it';

  static m0(month) => "Income: ${month} per month";

  static m1(lang) => "Language: ${lang}";

  static m2(count) => "Limit on taken books: ${count}";

  static m3(count) => "You can take up to ${count} books at a time plus number of books you\'ve given to other people. To take more books return books previously taken.";

  static m4(count, upgrade) => "Limit on taken books: ${count}";

  static m5(count, upgrade) => "You can take up to ${count} books at a time plus number of books you\'ve given to other people. To keep up to ${upgrade} books upgrade to paid plan.";

  static m6(user) => "Owner: ${user}";

  static m7(total) => "Price: ${total}";

  static m8(month) => "Price: ${month} per month";

  static m9(user) => "Book with ${user}";

  static m10(count) => "His books with me (${count})";

  static m11(amount) => "Top-up balance ${amount}";

  static m14(distance) => "Distance: ${distance} km";

  static m15(balance) => "MY BALANCE: ${balance}";

  static m16(amount) => "Enter amount not more than ${amount}";

  static m17(total, month) => "Deposit for books: ${total}, monthly payment ${month}";

  static m18(count) => "My books at this user (${count})";

  static m19(missing, total, month) => "Missing ${missing}. Deposit for books: ${total}, monthly payment ${month}";

  static m21(count) => "All his books (${count})";

  static m22(num) => "Receiving books (${num})";

  static m24(book) => "Can you give me \"${book}\"?";

  static m25(book) => "Can you send me \"${book}\"?";

  static m26(book) => "I\'d like to return \"${book}\"?";

  static m27(book) => "Please, return me \"${book}\"?";

  static m28(num) => "Handover books (${num})";

  static m30(amount) => "Total shared: +${amount}";

  static m31(amount) => "Deposit: ${amount}";

  static m32(amount) => "Monthly pay: ${amount}";

  static m34(platform) => "Subscription will be charged to your ${platform} account on confirmation. Subscriptions will automatically renew unless canceled within 24-hours before the end of the current period. You can cancel anytime with your ${platform} account settings. Any unused portion of a free trial will be forfeited if you purchase a subscription.";

  static m35(balance) => "Balance: ${balance}";

  static m36(user) => "from ${user}";

  static m37(count) => "Limit on wish list: ${count}";

  static m38(count) => "You can keep up to ${count} books in your wish list.";

  static m39(count, upgrade) => "Limit on wish list: ${count}";

  static m40(count, upgrade) => "You can keep up to ${count} books in your wish list. Upgrade to paid plan to increase to ${upgrade}.";

  static m41(user) => "Book with ${user}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "accountCopied" : MessageLookupByLibrary.simpleMessage("Account copied to clipboard"),
    "add" : MessageLookupByLibrary.simpleMessage("Add"),
    "addBook" : MessageLookupByLibrary.simpleMessage("Add book"),
    "addToWishlist" : MessageLookupByLibrary.simpleMessage("Add to Wishlist"),
    "addbookTitle" : MessageLookupByLibrary.simpleMessage("ADD BOOK"),
    "annualDescription" : MessageLookupByLibrary.simpleMessage("Enjoy book sharing with your friends and neighbours for a whole year"),
    "blockUser" : MessageLookupByLibrary.simpleMessage("Bloccare l’Utente abusivo"),
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
    "bookLimitPaid" : m2,
    "bookLimitPaidDesc" : m3,
    "bookLimitTrial" : m4,
    "bookLimitTrialDesc" : m5,
    "bookNotFound" : MessageLookupByLibrary.simpleMessage("This book is not found in Biblosphere. Add it to your wishlist and we\'ll inform you once it\'s available."),
    "bookOwner" : m6,
    "bookPrice" : m7,
    "bookPriceHint" : MessageLookupByLibrary.simpleMessage("Enter book price"),
    "bookPriceLabel" : MessageLookupByLibrary.simpleMessage("Book price"),
    "bookRent" : m8,
    "bookWith" : m9,
    "booksOfUserWithMe" : m10,
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
    "cartRequesterHasToConfirm" : MessageLookupByLibrary.simpleMessage("Your peer has to accept books"),
    "cartRequesterHasToTopup" : MessageLookupByLibrary.simpleMessage("Your peer has to top-up his balance"),
    "cartTopup" : m11,
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
    "displayCurrency" : MessageLookupByLibrary.simpleMessage("Display currency:"),
    "distanceLine" : m14,
    "distanceUnknown" : MessageLookupByLibrary.simpleMessage("Distance: unknown"),
    "emptyAmount" : MessageLookupByLibrary.simpleMessage("Empty amount not accepted"),
    "enterTitle" : MessageLookupByLibrary.simpleMessage("Enter title/author"),
    "exceedAmount" : MessageLookupByLibrary.simpleMessage("Amount exceed available balance"),
    "financeTitle" : m15,
    "findBook" : MessageLookupByLibrary.simpleMessage("Find Book"),
    "findbookTitle" : MessageLookupByLibrary.simpleMessage("FIND BOOK"),
    "hintAuthorTitle" : MessageLookupByLibrary.simpleMessage("Author or title"),
    "hintBookDetails" : MessageLookupByLibrary.simpleMessage("Change book info"),
    "hintChatOpen" : MessageLookupByLibrary.simpleMessage("Start conversation"),
    "hintDeleteBook" : MessageLookupByLibrary.simpleMessage("Delete book"),
    "hintNotMore" : m16,
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
    "introDone" : MessageLookupByLibrary.simpleMessage("FATTO"),
    "introMeet" : MessageLookupByLibrary.simpleMessage("Incontrarsi"),
    "introMeetHint" : MessageLookupByLibrary.simpleMessage("Contatta il proprietario dei libri che ti piacciono e fissa un appuntamento per averli."),
    "introShoot" : MessageLookupByLibrary.simpleMessage("Fai foto"),
    "introShootHint" : MessageLookupByLibrary.simpleMessage("Scatta una foto dei tuoi scaffali e condividili ai vicini e ai turisti. I tuoi libri attraggono il aderenti"),
    "introSkip" : MessageLookupByLibrary.simpleMessage("SALTARE"),
    "introSurf" : MessageLookupByLibrary.simpleMessage("Esplora"),
    "introSurfHint" : MessageLookupByLibrary.simpleMessage("App mostra librerie in 200 km intorno a te in ordine di distanza. Ottieni l\'accesso a un\'ampia varietà di libri."),
    "isbnNotFound" : MessageLookupByLibrary.simpleMessage("Book is not found by ISBN"),
    "km" : MessageLookupByLibrary.simpleMessage(" km"),
    "leaseAgreement" : m17,
    "linkCopied" : MessageLookupByLibrary.simpleMessage("Link copied to clipboard"),
    "loading" : MessageLookupByLibrary.simpleMessage("Loading..."),
    "loginAgree1" : MessageLookupByLibrary.simpleMessage("Cliccando su Registrami confermi di accettare  \n le "),
    "loginAgree2" : MessageLookupByLibrary.simpleMessage("condizioni di utilizzo e l\'informativa "),
    "loginAgree3" : MessageLookupByLibrary.simpleMessage("\nsul trattamento dei "),
    "loginAgree4" : MessageLookupByLibrary.simpleMessage("dati personali "),
    "logout" : MessageLookupByLibrary.simpleMessage("Logout"),
    "memoCopied" : MessageLookupByLibrary.simpleMessage("Memo copied to a clipboard"),
    "menuBalance" : MessageLookupByLibrary.simpleMessage("Balance"),
    "menuMessages" : MessageLookupByLibrary.simpleMessage("Messages"),
    "menuReferral" : MessageLookupByLibrary.simpleMessage("Referral program"),
    "menuSettings" : MessageLookupByLibrary.simpleMessage("Settings"),
    "menuSupport" : MessageLookupByLibrary.simpleMessage("Support"),
    "monthlyDescription" : MessageLookupByLibrary.simpleMessage("Keep more books and enjoy extended wish list with Monthly paid plan"),
    "myBooks" : MessageLookupByLibrary.simpleMessage("My books"),
    "myBooksWithUser" : m18,
    "mybooksTitle" : MessageLookupByLibrary.simpleMessage("MY BOOKS"),
    "negativeAmount" : MessageLookupByLibrary.simpleMessage("Amount should be positive"),
    "no" : MessageLookupByLibrary.simpleMessage("No"),
    "noMessages" : MessageLookupByLibrary.simpleMessage("No messages"),
    "noOperations" : MessageLookupByLibrary.simpleMessage("No operations"),
    "noReferrals" : MessageLookupByLibrary.simpleMessage("No referrals"),
    "notSufficientForAgreement" : m19,
    "nothingToSend" : MessageLookupByLibrary.simpleMessage("Niente da inviare"),
    "ok" : MessageLookupByLibrary.simpleMessage("Ok"),
    "opInAppPurchase" : MessageLookupByLibrary.simpleMessage("Pay In (In-App)"),
    "opInStellar" : MessageLookupByLibrary.simpleMessage("Pay In (Stellar)"),
    "opLeasing" : MessageLookupByLibrary.simpleMessage("Spent/Deposit for book"),
    "opOutStellar" : MessageLookupByLibrary.simpleMessage("Pay Out (Stellar)"),
    "opReferral" : MessageLookupByLibrary.simpleMessage("Referrals pay"),
    "opReward" : MessageLookupByLibrary.simpleMessage("Reward for book"),
    "outputStellarAccount" : MessageLookupByLibrary.simpleMessage("Stellar account for Pay Out:"),
    "outputStellarMemo" : MessageLookupByLibrary.simpleMessage("Memo for payout via Stellar:"),
    "patronDescription" : MessageLookupByLibrary.simpleMessage("Your generous contribution makes this app better and helps to promote book sharing"),
    "paymentError" : MessageLookupByLibrary.simpleMessage("Something went wrong, contact administrator"),
    "perMonth" : MessageLookupByLibrary.simpleMessage("per month"),
    "perYear" : MessageLookupByLibrary.simpleMessage("per year"),
    "planPaid" : MessageLookupByLibrary.simpleMessage("Member"),
    "privacyPolicy" : MessageLookupByLibrary.simpleMessage("Privacy Policy"),
    "profileUserBooks" : m21,
    "receiveBooks" : m22,
    "referralLink" : MessageLookupByLibrary.simpleMessage("Your referral link:"),
    "referralTitle" : MessageLookupByLibrary.simpleMessage("MY REFERRALS"),
    "requestBook" : m24,
    "requestPost" : m25,
    "requestReturn" : m26,
    "requestReturnByOwner" : m27,
    "scanISBN" : MessageLookupByLibrary.simpleMessage("Scan ISBN"),
    "selectDisplayCurrency" : MessageLookupByLibrary.simpleMessage("Choose display currency:"),
    "sendBooks" : m28,
    "settingsTitleGeneral" : MessageLookupByLibrary.simpleMessage("General settings"),
    "settingsTitleIn" : MessageLookupByLibrary.simpleMessage("Get balance"),
    "settingsTitleInStellar" : MessageLookupByLibrary.simpleMessage("Get balance via Stallar"),
    "settingsTitleOutStellar" : MessageLookupByLibrary.simpleMessage("Payout via Stallar"),
    "sharedFeeLine" : m30,
    "sharingMotto" : MessageLookupByLibrary.simpleMessage("Take books from people instead of buying"),
    "showDeposit" : m31,
    "showRent" : m32,
    "snackAllowLocation" : MessageLookupByLibrary.simpleMessage("Please allow access to location for searching and adding books"),
    "snackBookAddedToCart" : MessageLookupByLibrary.simpleMessage("Book was added to the cart"),
    "snackBookImageChanged" : MessageLookupByLibrary.simpleMessage("New cover image is set"),
    "snackBookNotConfirmed" : MessageLookupByLibrary.simpleMessage("Confirm other books before asking new ones"),
    "snackBookNotFound" : MessageLookupByLibrary.simpleMessage("Book not found. Add book manually to the cart."),
    "snackBookPending" : MessageLookupByLibrary.simpleMessage("Previous book handover not confirmed. Please ask your peer to confirm."),
    "snackBookPriceChanged" : MessageLookupByLibrary.simpleMessage("Price is saved"),
    "stellarOutput" : MessageLookupByLibrary.simpleMessage("Pay out to Stellar account:"),
    "subscriptionDisclaimer" : m34,
    "successfulPayment" : MessageLookupByLibrary.simpleMessage("Successful payment"),
    "supportChat" : MessageLookupByLibrary.simpleMessage("Support chat"),
    "supportChatbot" : MessageLookupByLibrary.simpleMessage("There are chat with support chatbot in the message screen. (S)he can answer any questions about Biblosphere application. Or contact me directly in Telegram "),
    "supportGetBalance" : MessageLookupByLibrary.simpleMessage("There are two ways to top-up your balance. First with In-App purchase by card registered in Google Play or App Store. Second by transfering Stellar (XLM) to account given in your Setting screen. Don\'t forget to give memo while transferring."),
    "supportGetBooks" : MessageLookupByLibrary.simpleMessage("Find books whch you like. Message owner of the book to make an apointment. To get book(s) you have to pay a deposit. It will be released once book(s) returned. You can top-up your balance by card via In-App Purchase or by Stellar cryptocurrency. To earn balance share your books and participate in partner program by initing other people in Biblosphere."),
    "supportPayout" : MessageLookupByLibrary.simpleMessage("Once you\'ve earned significant balance in Biblosphere you can withdraw it. Payouts are working via Stellar (XLM) cryptocurrency. You can transfer to your Stellar wallet or use cryptocurrency exchanges to withdraw to your card or online-wallet."),
    "supportReferrals" : MessageLookupByLibrary.simpleMessage("Facilitate book exchange via Biblosphere in your community or office and receive rewards from every transaction they made. To participate share your partner link to friends and colleagues."),
    "supportSignature" : MessageLookupByLibrary.simpleMessage("Denis Stark"),
    "supportText" : MessageLookupByLibrary.simpleMessage("## **Introduction**\n\nThis app intended for people who love books and reading. App helps you to take books from your friends and neigbours instead of buying in the stores. It also helps you to find like minded people with similar reading taste around you.\n\n## **How to add your books**\n\nYou can add you books in three ways:\n- By making photo of your bookshelf (App will recognize books from the image by the bookspines)\n- By scaning ISBN on a book\n- By searching book with author/title\n\n## **How to get books**\n\nApp helps you to find your wished books around you. It\'s simple three step flow: \n- Search book by author/title. \n- Chat with owner of the book and meet for the handover.\n- Return the book\n\nCould not find the book in a proximate distance? Just add it to your wishlist and App will inform you as soon as book is available.\n\n## **Messaging**\n\nApp has integrated messaging to support book sharing among users. Please note that it\'s not intended for general chatting (please use other messangers instead).\nChats are not encrypted. Application bot is monitoring and participating in the chat by sending notifications (marked with #bot_message hashtag).\n\nYou can attach book to the message. Click on the message with book cover to navigate there. \n\n## **Paid subscription**\n\nThe App available free of charge. However there are following expences:\n- cost of development\n- cost of hosting and APIs\n- design and marketing cost\n\nWe will be happy if you join other paying users to support this project and spread book sharing.  \n\n## **Be our partner**\n\nWe are looking for people and organizations to partner with. Our mission to spread book sharing and makes books available for reading. Please contact me on Telegram - [Denis Stark](https://t.me/DenisStark77)\n\n"),
    "supportTitle" : MessageLookupByLibrary.simpleMessage("SUPPORT"),
    "supportTitleChatbot" : MessageLookupByLibrary.simpleMessage("Support Chatbot"),
    "supportTitleGetBalance" : MessageLookupByLibrary.simpleMessage("Top-up balance"),
    "supportTitleGetBooks" : MessageLookupByLibrary.simpleMessage("How to get books"),
    "supportTitlePayout" : MessageLookupByLibrary.simpleMessage("Payouts"),
    "supportTitleReferrals" : MessageLookupByLibrary.simpleMessage("Referral program"),
    "termsOfService" : MessageLookupByLibrary.simpleMessage("Terms of Service"),
    "title" : MessageLookupByLibrary.simpleMessage("Biblosfere"),
    "titleBookSettings" : MessageLookupByLibrary.simpleMessage("ABOUT BOOK"),
    "titleGetBook" : MessageLookupByLibrary.simpleMessage("GET BOOK"),
    "titleMessages" : MessageLookupByLibrary.simpleMessage("MESSAGES"),
    "titleReceiveBooks" : MessageLookupByLibrary.simpleMessage("RECEIVING BOOKS"),
    "titleSendBooks" : MessageLookupByLibrary.simpleMessage("HANDOVER BOOKS"),
    "titleSettings" : MessageLookupByLibrary.simpleMessage("SETTINGS"),
    "titleSupport" : MessageLookupByLibrary.simpleMessage("SUPPORT"),
    "titleUserBooks" : MessageLookupByLibrary.simpleMessage("BOOK EXCHENGE"),
    "transitInitiated" : MessageLookupByLibrary.simpleMessage("Handover process initiated for the book"),
    "typeMsg" : MessageLookupByLibrary.simpleMessage("Scrivi il tuo messaggio..."),
    "userBalance" : m35,
    "userHave" : m36,
    "welcome" : MessageLookupByLibrary.simpleMessage("WELCOME"),
    "wishAdded" : MessageLookupByLibrary.simpleMessage("Book has been added to your wishlist"),
    "wishAlreadyThere" : MessageLookupByLibrary.simpleMessage("This book is already in your wishlist"),
    "wishLimitPaid" : m37,
    "wishLimitPaidDesc" : m38,
    "wishLimitTrial" : m39,
    "wishLimitTrialDesc" : m40,
    "wrongAccount" : MessageLookupByLibrary.simpleMessage("Wrong account"),
    "wrongImageUrl" : MessageLookupByLibrary.simpleMessage("Wrong link"),
    "youBorrowThisBook" : MessageLookupByLibrary.simpleMessage("You borrowed this book"),
    "youHaveThisBook" : MessageLookupByLibrary.simpleMessage("You keep this book"),
    "youLentThisBook" : m41,
    "youTransitThisBook" : MessageLookupByLibrary.simpleMessage("This book is in transit"),
    "youWishThisBook" : MessageLookupByLibrary.simpleMessage("This book in your wishlist")
  };
}
