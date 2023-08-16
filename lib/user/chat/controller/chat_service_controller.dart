import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:pichat/api/api.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:pichat/user/settings/widget/helper_widgets/logout_dialogue_box.dart';
import 'package:pichat/utils/toast.dart';







class ChatServiceController extends ChangeNotifier {

  //for chat list
  final ScrollController messageController = ScrollController();

  double keyboardHeight = 0;
  double keyboardTop = 0;

  //////////////TextEditingControllers here
  final TextEditingController allUsersTextEditingController = TextEditingController();
  final TextEditingController recentChatsTextController = TextEditingController();
  final TextEditingController chatTextController = TextEditingController();
  

  @override
  void dispose() {
    // TODO: implement dispose
    messageController.dispose();
    allUsersTextEditingController.dispose();
    recentChatsTextController.dispose();
    chatTextController.dispose();
    super.dispose();
  }


  //when a user is searching for all users
  bool isSearchingForUsers = false;

  //when a user is trying to searching for recent chats messages
  bool isSearchingRecentChats = false;

  //get the instance of firebaseauth and cloud firestore
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  ///////////////////Set objects for keeping indices in check
  Set<String> selectedDocumentIdForConnectRequest = <String>{};
  Set<String> selectedDocumentIdForAllUsers = <String>{};



  //SEND MESSAGES
  /*Future<void> sendMessage({required String receiverName, required String message}) async{
    //get current user info
    final String? currentUserName = auth.currentUser!.displayName;
    final Timestamp timestamp = Timestamp.now();
    var messageId = (Random().nextInt(100000)).toString();

    //create a new message
    MessageModel newMessage = MessageModel(
      content: message, 
      messageId: messageId, 
      receiverName: receiverName,
      senderName: currentUserName!,
      timestamp: timestamp, 
      isSeen: false
    );

    //construct a chat room id from current user id and receiver's id (did this to ensure uniqueness)
    List<String?> ids = [currentUserName, receiverName];
    ids.sort(); //this ensures that the chat room id is always the same for any pair of users
    String chatRoomId = ids.join('_');  //combines the ids into a single string to make it usable
    
    //add new message to database (note: this idea is only applicable to creating group chats)
    //i'd use my own format for private chats
    await firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').doc(messageId).set(newMessage.toMap());
  }


  //GET MESSAGES
  Stream<QuerySnapshot> getMessage({required String currentUserName, required String receiverName}) {
    //construct a chat room id from current user id and receiver's id (did this to ensure uniqueness)
    List<String?> ids = [currentUserName, receiverName];
    ids.sort(); //this ensures that the chat room id is always the same for any pair of users
    String chatRoomId = ids.join('_');  //combines the ids into a single string to make it usable

    //add new message to database (note: this idea is only applicable to creating group chats)
    //i'd use my own format for private chats
    return firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').orderBy('timestamp', descending: false).snapshots();
  }*/
  


  //sendFriendRequest to a user
  Future sendFriendRequest({required String recipientId}) async {
    try {

      //do this if you want to get any logged in user property 
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(auth.currentUser!.uid)
      .get();
      String userName = snapshot.get('name');
      
      // Add the sender to the receipient's friendRequests collection
      await FirebaseFirestore.instance
      .collection('users')
      .doc(recipientId)
      .collection('friend_request')
      .doc(auth.currentUser!.uid)
      .set({
        //figure out how to add other properties later(very important)
        'name': userName,
        'email': auth.currentUser!.email,
        'id': auth.currentUser!.uid,
        'photo': 'photo'  //getPhotoString
      });
    } 
    catch (e) {
      // Handle any errors that may occur during the request sending
      debugPrint('Error sending friend request: $e');
    }
  }

  //cancelFriendRequest sent to a user
  Future cancelFriendRequest({required String recipientId}) async {
    try {
      // delete/remove current user or sender from receipient friend request collection
      await FirebaseFirestore.instance
      .collection('users')
      .doc(recipientId)
      .collection('friend_request')
      .doc(auth.currentUser!.uid).delete();
    } 
    catch (e) {
      // Handle any errors that may occur during the request sending
      debugPrint('Error cancelling friend request: $e');
    }
  }


  //acceptFriendRequest of the sender
  Future acceptFriendRequest({required String friendName, required String friendId, required String friendProfilePic,}) async {
    try {

      //do this if you want to get any logged in user property 
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(auth.currentUser!.uid)
      .get();
      String userName = snapshot.get('name');
      String userId = snapshot.get('id');
      String userPhoto = snapshot.get('photo');
      bool userOnline = snapshot.get('isOnline');
      //////////////////////////////////

      // Add sender of the request to the current user or receipient's friend list
      await firestore.collection('users').doc(auth.currentUser!.uid).collection('friends').doc(friendId)
      .set({
      'name': friendName,
      'id': friendId,
      'photo': friendProfilePic,
      });
      // Add receiver of the request or current user to the sender's friend list
      await firestore.collection('users').doc(friendId).collection('friends').doc(auth.currentUser!.uid)
      .set({
      'name': userName,   
      'id': userId, //auth.currentUser!.uid,
      'photo': userPhoto, 
      });

      //Remove sender of the request from the current user / receipient's friendRequests collection
      await FirebaseFirestore.instance
      .collection('users')
      .doc(auth.currentUser!.uid)
      .collection('friend_request')
      .doc(friendId).delete();
    } 
    catch (e) {
      // Handle any errors that may occur during the friend request acceptance
      debugPrint('Error accepting friend request: $e');
    }
  }
  

  //declineFriendRequest of the sender
  Future declineFriendRequest({required String friendId}) async {
    try {
      // Remove sender of the request from receipient/current user friendRequests collection
      await FirebaseFirestore.instance
      .collection('users')
      .doc(auth.currentUser!.uid)
      .collection('friend_request')
      .doc(friendId).delete();
    } catch (e) {
      // Handle any errors that may occur during the friend request decline
      debugPrint('Error declining friend request: $e');
    }
  }

  //remove user from friend list (this will serve as block function)
  Future removeUserFromFriendList({required String friendId}) async{
    try {
      ////remove other user from current user's friend list
      await firestore
      .collection('users')
      .doc(auth.currentUser!.uid)
      .collection('friends')
      .doc(friendId).delete();
      ////remove current user from the other user's friend list
      await firestore
      .collection('users')
      .doc(friendId)
      .collection('friends')
      .doc(auth.currentUser!.uid).delete();
    }
    catch (e) {
      // Handle any errors that may occur during the friend request decline
      debugPrint('Error removing friend request: $e');
    }
  }
  
  //make key board disappear after a message has been sent
  void makeKeyboardDisappear() {
    FocusNode focusNode = FocusNode();
    return focusNode.unfocus();
  }


















                 /**for chat fuctionalitites */
  /////////////////////////////////////////////////////////////////////
  Stream<QuerySnapshot<Map<String, dynamic>>>? recentChatsStream;
  
  //(to be placed inside "sendDirectMessages" function)//
  Future<void> addUserToRecentChats({required String receiverId, required String receiverName, required String receiverPhoto, required String lastMessage, required Timestamp timestamp, required String sentBy}) async{
    //do this if you want to get any logged in user property 
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
    .collection('users')
    .doc(auth.currentUser!.uid)
    .get();
    String userName = snapshot.get('name');
    String userId = snapshot.get('id');
    String userPhoto = snapshot.get('photo');
    //bool userOnline = snapshot.get('isOnline');
    //////////////////////////////////
    
    //add receiver of the text message to my recent chats stream
    await firestore.collection('users')
    .doc(auth.currentUser!.uid)
    .collection('recent_chats')
    .doc(receiverId)
    .set({
      'name': receiverName,
      'id': receiverId,
      'photo': receiverPhoto,
      'lastMessage': lastMessage,
      'sentBy': sentBy,
      'timestamp': timestamp
    });

    //add myself to receiver's recent chat stream  (update isMessageSeen later)
    await firestore.collection('users')
    .doc(receiverId)
    .collection('recent_chats')
    .doc(auth.currentUser!.uid)
    .set({
      'name': userName,
      'id': userId,
      'photo': userPhoto,
      'lastMessage': lastMessage,
      'sentBy': sentBy,
      'timestamp': timestamp,
    });
  }

  //delete recent chats of a chat buddy
  Future<void> deleteUserFromRecentChats({required String friendId}) async{
    await firestore.collection('users')
    .doc(auth.currentUser!.uid)
    .collection('recent_chats').
    doc(friendId).delete();
  }
  
  





  ////check if the image is taken from gallery or not
  bool isImageSelectedFromGallery = false;
  /// check if any image is selected at all
  bool isAnyImageSelected = false;

  //for image or video content
  File? file;
  //check if it is a video or picture content that wants to be sent
  bool isContentImage = false;





  ////////////////send direct messages
  Future<void> sendPictureOrVideoWithOrWithoutAText({
    required File? file,
    required String receiverId,
    required String receiverName,
    required String receiverPhoto,
    required String message  //gotten from the text controller used to send message
  }) async{
    Timestamp timestamp = Timestamp.now();
    //for identifying messages or messages documents uniquely 
    var messageId = (Random().nextInt(100000)).toString();
    
    //did this to get the FCM Token of the receiver 
    DocumentSnapshot receiverSnapshot = await FirebaseFirestore.instance
    .collection('users')
    .doc(receiverId)
    .get();
    String FCMToken = receiverSnapshot.get('FCMToken');
    /////////////////////////////////////////////
    
    //did this to get the name and email of the current user
    DocumentSnapshot senderSnapshot = await FirebaseFirestore.instance
    .collection('users')
    .doc(auth.currentUser!.uid)
    .get();
    String name = senderSnapshot.get('name');
    String userEmail = senderSnapshot.get('email');
    
    //////THIS IS WHERE IMAGE/VIDEO UPLOADING IMPLEMETATION COMES IN
    //name of the folder we are first storing the file to
    String? folderName = userEmail;
    //name the file we are sending to firebase cloud storage
    String fileName = "${DateTime.now().millisecondsSinceEpoch}direct_messages";
    //set the storage reference as "users_photos" and the "filename" as the image reference
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child('$folderName/$fileName');
    //upload the image to the cloud storage
    firebase_storage.UploadTask uploadTask = ref.putFile(file!);
    //call the object and then show that it has already been uploaded to the cloud storage or bucket
    firebase_storage.TaskSnapshot taskSnapshot = 
    await uploadTask
    .whenComplete(() => debugPrint("content uploaded succesfully to fire storage"));
    //get the imageUrl from the above taskSnapshot
    String contentUrl = await taskSnapshot.ref.getDownloadURL();

    //NOW, WE CHECK IF THE CONTENT ABOUT TO BE SENT IS AN IMAGE OR VIDEO
    if (isContentImage) {
      await firestore.collection('users')
      .doc(auth.currentUser!.uid)
      .collection('recent_chats')
      .doc(receiverId)
      .collection('messages')
      .doc(messageId)
      .set({
        'senderId': auth.currentUser!.uid,
        'messageId': messageId,
        'image': contentUrl,
        'video': 'non',
        'audio': 'non',
        'message': message,
        'messageType': 'image',
        'isSeen': false,
        'timestamp': timestamp,
      });
    
      //add message to friend / receiver's  collection (update isSeen later)
      await firestore.collection('users')
      .doc(receiverId)
      .collection('recent_chats')
      .doc(auth.currentUser!.uid)
      .collection('messages')
      .doc(messageId)
      .set({
        'senderId': auth.currentUser!.uid,
        'messageId': messageId,
        'image': contentUrl,
        'video': 'non',
        'audio': 'non',
        'message': message,
        'messageType': 'image',
        'isSeen': false,
        'timestamp': timestamp,
      });

      //did this to get the last message sent from any of the chatters (messages stream)
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(auth.currentUser!.uid)
      .collection('recent_chats')
      .doc(receiverId)
      .collection('messages')
      .doc(messageId)
      .get();
      String lastMessageSent = snapshot.get('message');
      String sentBy = snapshot.get('senderId');
      Timestamp timeofLastMessageSent = snapshot.get('timestamp');
      /////////////////////////////////////////////

      //function that adds who ever you are chatting with to 'recent_chats" and vice-versa
      addUserToRecentChats(timestamp: timeofLastMessageSent, lastMessage: '📷 Image ~ $lastMessageSent', receiverId: receiverId, receiverName: receiverName, receiverPhoto: receiverPhoto, sentBy: sentBy);
      //call FCM REST API to send a message notification to the receiver of the message, if he/she is in background mode (will implement foreground mode later)
      API().sendPushNotificationWithFirebaseAPI(content: '📷 Image ~ $lastMessageSent', receiverFCMToken: FCMToken, title: name);
    
      // Scroll to the newly added message to make it visible.
      messageController.jumpTo(messageController.position.maxScrollExtent);
      // to see what the url looks like
      debugPrint("Image URL: $contentUrl");
    }
    //THIS WILL EXECUTE IF THE CONTENT IS A VIDEO
    else {
      await firestore.collection('users')
      .doc(auth.currentUser!.uid)
      .collection('recent_chats')
      .doc(receiverId)
      .collection('messages')
      .doc(messageId)
      .set({
        'senderId': auth.currentUser!.uid,
        'messageId': messageId,
        'video': contentUrl,
        'image': 'non',
        'audio': 'non',
        'message': message,
        'messageType': 'video',
        'isSeen': false,
        'timestamp': timestamp,
      });
    
      //add message to friend / receiver's  collection (update isSeen later)
      await firestore.collection('users')
      .doc(receiverId)
      .collection('recent_chats')
      .doc(auth.currentUser!.uid)
      .collection('messages')
      .doc(messageId)
      .set({
        'senderId': auth.currentUser!.uid,
        'messageId': messageId,
        'video': contentUrl,
        'image': 'non',
        'audio': 'non',
        'message': message,
        'messageType': 'video',
        'isSeen': false,
        'timestamp': timestamp,
      });

       //did this to get the last message sent from any of the chatters (messages stream)
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('recent_chats')
        .doc(receiverId)
        .collection('messages')
        .doc(messageId)
        .get();
        String lastMessageSent = snapshot.get('message');
        String sentBy = snapshot.get('senderId');
        Timestamp timeofLastMessageSent = snapshot.get('timestamp');
        /////////////////////////////////////////////

      //function that adds who ever you are chatting with to 'recent_chats" and vice-versa
      addUserToRecentChats(timestamp: timeofLastMessageSent, lastMessage: '🎬 Video ~ $lastMessageSent', receiverId: receiverId, receiverName: receiverName, receiverPhoto: receiverPhoto, sentBy: sentBy);
      //call FCM REST API to send a message notification to the receiver of the message, if he/she is in background mode (will implement foreground mode later)
      API().sendPushNotificationWithFirebaseAPI(content: '🎬 Video ~ $lastMessageSent', receiverFCMToken: FCMToken, title: name);
    
      // Scroll to the newly added message to make it visible.
      messageController.jumpTo(messageController.position.maxScrollExtent);
      debugPrint("Image URL: $contentUrl");
    }

  }



  ////////////////send direct messages
  Future<void> sendDirectMessages({
    required String receiverId,
    required String receiverName,
    required String receiverPhoto,
    required String message  //gotten from the text controller used to send message
  }) async{

    Timestamp timestamp = Timestamp.now();
    //for identifying messages or messages documents uniquely 
    var messageId = (Random().nextInt(100000)).toString();
    
    //did this to get the FCM Token of the receiver 
    DocumentSnapshot receiverSnapshot = await FirebaseFirestore.instance
    .collection('users')
    .doc(receiverId)
    .get();
    String FCMToken = receiverSnapshot.get('FCMToken');
    /////////////////////////////////////////////
    
    //did this to get the name and email of the current user
    DocumentSnapshot senderSnapshot = await FirebaseFirestore.instance
    .collection('users')
    .doc(auth.currentUser!.uid)
    .get();
    String name = senderSnapshot.get('name');
    String userEmail = senderSnapshot.get('email');


    //add message to current user / sender collection   
    await firestore.collection('users')
    .doc(auth.currentUser!.uid)
    .collection('recent_chats')
    .doc(receiverId)
    .collection('messages')
    .doc(messageId)
    .set({
      'senderId': auth.currentUser!.uid,
      'messageId': messageId,
      'message': message,
      'image': 'non',
      'video': 'non',
      'audio': 'non',
      'messageType': 'text',
      'isSeen': false,
      'timestamp': timestamp,
    });
    
    //add message to friend / receiver's  collection (update isSeen later)
    await firestore.collection('users')
    .doc(receiverId)
    .collection('recent_chats')
    .doc(auth.currentUser!.uid)
    .collection('messages')
    .doc(messageId)
    .set({
      'senderId': auth.currentUser!.uid,
      'messageId': messageId,
      'message': message,
      'image': 'non',
      'video': 'non',
      'audio': 'non',
      'messageType': 'text',
      'isSeen': false,
      'timestamp': timestamp,
    });

    //did this to get the last message sent from any of the chatters (messages stream)
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
    .collection('users')
    .doc(auth.currentUser!.uid)
    .collection('recent_chats')
    .doc(receiverId)
    .collection('messages')
    .doc(messageId)
    .get();
    String lastMessageSent = snapshot.get('message');
    String sentBy = snapshot.get('senderId');
    Timestamp timeofLastMessageSnet = snapshot.get('timestamp');
    /////////////////////////////////////////////

    //function that adds who ever you are chatting with to 'recent_chats" and vice-versa
    addUserToRecentChats(timestamp: timeofLastMessageSnet, lastMessage: lastMessageSent, receiverId: receiverId, receiverName: receiverName, receiverPhoto: receiverPhoto, sentBy: sentBy);
    //call FCM REST API to send a message notification to the receiver of the message, if he/she is in background mode (will implement foreground mode later)
    API().sendPushNotificationWithFirebaseAPI(content: lastMessageSent, receiverFCMToken: FCMToken, title: name);
    
    // Scroll to the newly added message to make it visible.
    messageController.jumpTo(messageController.position.maxScrollExtent);
    ////////////////////////////////////////////////////////////////////
  }
  

  //delete direct message when texting
  Future<void> deleteDirectMessages({required String messageId, required String receiverId}) async{
    //do this if you want to get any logged in user property 
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
    .collection('users')
    .doc(auth.currentUser!.uid)
    .get();
    String userId = snapshot.get('id');

    await firestore.collection('users')
    .doc(userId)
    .collection('recent_chats')
    .doc(receiverId)
    .collection('messages')
    .doc(messageId)
    .delete();
    
  
    await firestore.collection('users')
    .doc(receiverId)
    .collection('recent_chats')
    .doc(userId)
    .collection('messages')
    .doc(messageId)
    .delete();
  }
  
  //mark message as seen or read
  Future<void> markMessageAsSeen({required String messageId, required String receiverId}) async {
    try {
      /////////////////////////////////////////////
      await firestore
        .collection('users')
        .doc(receiverId)
        .collection('recent_chats')
        .doc(auth.currentUser!.uid)
        .collection('messages')
        .doc(messageId)
        .update({'isSeen': true});
    } catch (error) {
      print('Error marking message as seen: $error');
    }
  }
  

  


  bool isPlaying = false;
  bool isRecording = false;
  String audioPath = "" ;  //save to db

  //upload and save to fire storage
  Future<void> uploadAudioToFireStorage({required String contentUrl, required BuildContext context, required String receiverId, required String message, required String receiverName, required String receiverPhoto}) async{
    try {

      Timestamp timestamp = Timestamp.now();
      //for identifying messages or messages documents uniquely 
      var messageId = (Random().nextInt(100000)).toString();

      //did this to get the FCM Token of the receiver 
      DocumentSnapshot receiverSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(receiverId)
      .get();
      String FCMToken = receiverSnapshot.get('FCMToken');
      
      //did this to get the name and email of the current user
      DocumentSnapshot senderSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userID)
      .get();
      String name = senderSnapshot.get('name');
      String userEmail = senderSnapshot.get('email');

      await firestore.collection('users')
      .doc(auth.currentUser!.uid)
      .collection('recent_chats')
      .doc(receiverId)
      .collection('messages')
      .doc(messageId)
      .set({
        'senderId': auth.currentUser!.uid,
        'messageId': messageId,
        'image': 'non',
        'audio': contentUrl,
        'video': 'non',
        'message': message,
        'messageType': 'audio',
        'isSeen': false,
        'timestamp': timestamp,
      });
    
      //add message to friend / receiver's  collection (update isSeen later)
      await firestore.collection('users')
      .doc(receiverId)
      .collection('recent_chats')
      .doc(auth.currentUser!.uid)
      .collection('messages')
      .doc(messageId)
      .set({
        'senderId': auth.currentUser!.uid,
        'messageId': messageId,
        'image': 'non',
        'audio': contentUrl,
        'video': 'non',
        'message': message,
        'messageType': 'audio',
        'isSeen': false,
        'timestamp': timestamp,
      });

      //did this to get the last message sent from any of the chatters (messages stream)
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(auth.currentUser!.uid)
      .collection('recent_chats')
      .doc(receiverId)
      .collection('messages')
      .doc(messageId)
      .get();
      String lastMessageSent = snapshot.get('message');
      String sentBy = snapshot.get('senderId');
      Timestamp timeofLastMessageSent = snapshot.get('timestamp');
      /////////////////////////////////////////////

      //function that adds who ever you are chatting with to 'recent_chats" and vice-versa
      addUserToRecentChats(timestamp: timeofLastMessageSent, lastMessage: '🎵 Audio ', receiverId: receiverId, receiverName: receiverName, receiverPhoto: receiverPhoto, sentBy: sentBy);
      //call FCM REST API to send a message notification to the receiver of the message, if he/she is in background mode (will implement foreground mode later)
      API().sendPushNotificationWithFirebaseAPI(content: '🎵 Audio ', receiverFCMToken: FCMToken, title: name);
    
      // Scroll to the newly added message to make it visible.
      messageController.jumpTo(messageController.position.maxScrollExtent);
      // to see what the url looks like
      debugPrint("audio url: $contentUrl");
    }
    on FirebaseException catch (e) {
      getToast(context: context, text: 'Error uploading audio: $e');
    }
  }


}