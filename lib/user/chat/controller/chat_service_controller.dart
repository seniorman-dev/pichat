import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pichat/user/model/message.dart';






class ChatServiceController extends ChangeNotifier {

  //get the instance of firebaseauth and cloud firestore
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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
      timestamp: Timestamp.now(), 
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

}