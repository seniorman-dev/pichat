import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';






class FeedsController extends ChangeNotifier {

  final FirebaseAuth firebase = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? get user => firebase.currentUser;
  String get userID => firebase.currentUser!.uid;
  String? get userDisplayName => firebase.currentUser!.displayName;
  String? get userEmail => firebase.currentUser!.email;
  bool isLoading = false;

  Future<List<String>> fetchFriendList() async {

    final friendsCollection = await firestore
    .collection('users') // Assuming 'users' is the collection containing user documents
    .doc(userID)
    .collection('friends') // Assuming 'friends' is the sub-collection of the user document
    .get();

    // Extract the friend IDs from the documents in the 'friends' sub-collection
    final friendList = friendsCollection.docs.map((doc) => doc.id).toList();

    // Add the current user's ID to the friend list so their own posts will also be included
    friendList.add(userID);

    return friendList;
  }

  // Fetch feeds from Firestore using the friend list
  Stream<QuerySnapshot<Map<String, dynamic>>> getFeeds() async* {
    final friendList = await fetchFriendList();
    yield* FirebaseFirestore.instance
    .collection('feeds')
    .where('userId', whereIn: friendList)
    .orderBy('timestamp', descending: true)
    .snapshots();
  }

  // Add a post to the timeline
  


}
