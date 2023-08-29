import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';






class NotificationsController extends ChangeNotifier{

  final FirebaseAuth firebase = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? get user => firebase.currentUser;
  String get userID => firebase.currentUser!.uid;
  String? get userDisplayName => firebase.currentUser!.displayName;
  String? get userEmail => firebase.currentUser!.email;
  bool isLoading = false;

  //delete notification from user db
  Future<void> deleteNotification() async{
    await firestore
    .doc(userID)
    .collection('notifications')
    .doc(userID)
    .delete();
  }
}