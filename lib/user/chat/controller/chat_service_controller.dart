import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pichat/user/model/message.dart';






class ChatServiceController extends ChangeNotifier {

  //////////////TextEditingControllers here
  final allUsersTextEditingController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    allUsersTextEditingController.dispose();
    super.dispose();
  }

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

  //delete recent chats
  Future<void> deleteRecentChats({required String friendId}) async{
    await firestore.collection('users').doc(auth.currentUser!.uid).collection('recent_chats').doc(friendId).delete();
  }

  //SEND MESSAGES
  Future<void> sendMessage({required String receiverName, required String message}) async{
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
  }



  //sendFriendRequest
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

  //cancelFriendRequest
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

  //acceptFriendRequest
  Future acceptFriendRequest({required String friendName, required String friendId, required String friendProfilePic,}) async {
    try {
      String getUserName() {
        final box = GetStorage();
        return box.read('name') ?? ''; // Return an empty string if data is not found
      }
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
      'name': getUserName(),
      'id': auth.currentUser!.uid,
      'photo': 'photo',  //getPhotoString
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
  

  //declineFriendRequest
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

  //remove user from friend list
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


  
  
}