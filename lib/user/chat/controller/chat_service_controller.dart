import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';






class ChatServiceController extends ChangeNotifier {

  final ScrollController messageController = ScrollController();

  double keyboardHeight = 0;
  double keyboardTop = 0;

  @override
  void dispose() {
    // TODO: implement dispose
    messageController.dispose();
    super.dispose();
  }

  //////////////TextEditingControllers here
  //final allUsersTextEditingController = TextEditingController();


  //when a user is searching for users
  bool isSearching = false;

  //when a user is trying to searching for resent chats
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
      //get logged in user's name from local storage
      String getUserName() {
        final box = GetStorage();
        return box.read('name') ?? ''; // Return an empty string if data is not found
      }
      // Add the sender to the receipient's friendRequests collection
      await FirebaseFirestore.instance
      .collection('users')
      .doc(recipientId)
      .collection('friend_request')
      .doc(auth.currentUser!.uid)
      .set({
        //figure out how to add other properties later(very important)
        'name': getUserName(),
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
  
  //(to be placed inside "sendDirectMessages" function)//
  Future<void> addUserToRecentChats({required String receiverId, required String receiverName, required String receiverPhoto, required String lastMessage, required Timestamp timestamp}) async{
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
  
  //send direct messages
  Future<void> sendDirectMessages({
    required String receiverId,
    required String receiverName,
    required String receiverPhoto,
    required String message  //gotten from the text controller used to send message
  }) async{

    Timestamp timestamp = Timestamp.now();
    var messageId = (Random().nextInt(100000)).toString();

    //add message to current user / sender collection (update isSeen later)
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
    Timestamp timeofLastMessageSnet = snapshot.get('timestamp');
    /////////////////////////////////////////////

    //function that adds who ever you are chatting with to 'recent_chats" and vice-versa
    addUserToRecentChats(timestamp: timeofLastMessageSnet, lastMessage: lastMessageSent, receiverId: receiverId, receiverName: receiverName, receiverPhoto: receiverPhoto);
  }
  
  //delete direct message when texting
  Future<void> deleteDirectMessages({required String messageId, required String receiverId}) async{
    //do this if you want to get any logged in user property 
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
    .collection('users')
    .doc(auth.currentUser!.uid)
    .get();
    String userId = snapshot.get('id');

    //add message to current user / sender collection (update isSeen later)
    await firestore.collection('users')
    .doc(userId)
    .collection('recent_chats')
    .doc(receiverId)
    .collection('messages')
    .doc(messageId)
    .delete();
    
    //add message to friend / receiver's  collection (update isSeen later)
    await firestore.collection('users')
    .doc(receiverId)
    .collection('recent_chats')
    .doc(userId)
    .collection('messages')
    .doc(messageId)
    .delete();
  }

  //to make a currently logged in user go offline or come online depending on the app's life cycle
  Future<void> updateOnlineStatus({required bool isOnline}) async{
    await firestore.collection('users').doc(auth.currentUser!.uid).update({"isOnline": isOnline});
  }

  //to check if a message sent by a user is seen by the opposite or not
  Future<void> updateisSeenStatus({required bool isSeen, required String receiverId,}) async{
    await firestore.collection('users')
    .doc(receiverId)
    .collection('recent_chats')
    .doc(auth.currentUser!.uid)
    .collection('messages')
    .doc()
    .update({"isSeen": isSeen});
  }

  //geolocator functionality




}