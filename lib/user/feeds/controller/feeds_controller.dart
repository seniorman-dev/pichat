import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';






class FeedsController extends ChangeNotifier {

  final FirebaseAuth firebase = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? get user => firebase.currentUser;
  String get userID => firebase.currentUser!.uid;
  String? get userEmail => firebase.currentUser!.email;

  //for general loading
  bool isLoading = false;
  
  //controller for posting a content on the TL
  final TextEditingController postTextController = TextEditingController();

  //controller for commenting on a post
  final TextEditingController commentTextController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    commentTextController.dispose();
    postTextController.dispose();
    super.dispose();
  }








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

  // Fetch feeds from Firestore using the friend list (feeds for the timeline)
  Stream<QuerySnapshot<Map<String, dynamic>>> getFeeds() async*{
    final friendList = await fetchFriendList();
    yield* firestore
    .collection('feeds')
    .where('id', whereIn: friendList)
    .orderBy('timestamp', descending: true)
    .snapshots();
  }

  // Fetch feeds specifically posted by logged-in user to be displayed on his/her profile
  Stream<QuerySnapshot<Map<String, dynamic>>> getFeedsForUserProfile() async* {
    yield* firestore
    .collection('users')
    .doc(userID)
    .collection('posts')
    .orderBy('timestamp', descending: true)
    .snapshots();
  }

  // Add a post to the timeline
  Future<void> uploadFeed() async{
    //post id
    var postId = (Random().nextInt(100000)).toString();

    //do this if you want to get any logged in user property 
    DocumentSnapshot snapshot = await firestore
    .collection('users')
    .doc(userID)
    .get();
    String userName = snapshot.get('name');
    String userId = snapshot.get('id');
    String userPhoto = snapshot.get('photo');
    bool userOnline = snapshot.get('isOnline');
    //////////////////////////////////
    
    //post the feed to the general TL (where the logged in user and his friends can see the post)
    await firestore
    .collection('feeds')
    .doc(postId)
    .set({
      'postId': postId,
      'posterId': userId,
      'posterName': userName,
      'posterPhoto': userPhoto,
      'postTitle': postTextController.text,
      'postContent': 'imageUrl or videoURL or text or File',
      //'repostedBy': 'nobody',
      'timestamp': Timestamp.now()
    });

    //post the feed to the poster's profile
    await firestore
    .collection('users')
    .doc(userId)
    .collection('posts')
    .doc(postId)
    .set({
      'postId': postId,
      'posterId': userId,
      'posterName': userName,
      'posterPhoto': userPhoto,
      'postTitle': postTextController.text,
      'postContent': 'imageUrl or videoURL or text or File',
      'timestamp': Timestamp.now()
    });

  }







  //Like a post function
  Future<void> likeAPost({required String postId}) async{
    //do this if you want to get any logged in user property 
    DocumentSnapshot snapshot = await firestore
    .collection('users')
    .doc(userID)
    .get();
    String userName = snapshot.get('name');
    String userId = snapshot.get('id');
    String userPhoto = snapshot.get('photo');
    bool userOnline = snapshot.get('isOnline');
    //////////////////////////////////
    
    //like post on the general TL (will call this query snapshot stream in logged in users profile)
    await firestore
    .collection('feeds')
    .doc(postId)
    .collection('likes')
    .doc(userId)
    .set({
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'userLiked': true,
      'timestamp': Timestamp.now()
    });
  }

  //stream of users that liked a post uniquely
  Stream<QuerySnapshot<Map<String, dynamic>>> postLikes({required String postId}) async* {
    yield* firestore
    .collection('feeds')
    .doc(postId)
    .collection('likes')
    .orderBy('timestamp', descending: true)
    .snapshots();
  }

  //Un-Like a post function
  Future<void> unLikeAPost({required String postId}) async{
    //do this if you want to get any logged in user property 
    DocumentSnapshot snapshot = await firestore
    .collection('users')
    .doc(userID)
    .get();
    String userName = snapshot.get('name');
    String userId = snapshot.get('id');
    //////////////////////////////////
    
    ///update userLiked boolean to false
    await firestore
    .collection('feeds')
    .doc(postId)
    .collection('likes')
    .doc(userId)
    .update({
      'userLiked': false,
    });
    
    ///unlike a post on the general TL (will call this query snapshot stream in logged in users profile)
    await firestore
    .collection('feeds')
    .doc(postId)
    .collection('likes')
    .doc(userId)
    .delete();
  }






  //repost a post function
  Future<void> rePostAPost({required String postId, required String posterId, required String postName, required String posterPhoto, required String postTitle, required String postContent}) async{
    //do this if you want to get any logged in user property 
    DocumentSnapshot snapshot = await firestore
    .collection('users')
    .doc(userID)
    .get();
    String userName = snapshot.get('name');
    String userId = snapshot.get('id');
    String userPhoto = snapshot.get('photo');
    bool userOnline = snapshot.get('isOnline');
    //////////////////////////////////
    

    /*await firestore
    .collection('feeds')
    .doc(postId)
    .update({
      'repostedBy': userName
    });*/
    
    //repost the post on the general TL
    await firestore
    .collection('feeds')
    .doc(postId)
    .update({
      'postId': postId,
      'posterId': posterId,
      'posterName': postName,
      'posterPhoto': posterPhoto,
      'postTitle': postTitle,
      'postContent': postContent,
      'isReposted': true,
      'reposterName': userName,
      'reposterId': userId,
      'reposterPhoto': userPhoto,
      'timestamp': Timestamp.now()
    });

    //update the "re-posts" collection reference for posts on the TL (it is this stream that we are going to call for each unique post on the TL or feeds. to dislay their length)
    await firestore
    .collection('feeds')
    .doc(postId)
    .collection('reposts')
    .doc(userId)
    .set({
      'postId': postId,
      'posterId': posterId,
      'posterName': postName,
      'posterPhoto': posterPhoto,
      'postTitle': postTitle,
      'postContent': postContent,
      'isReposted': true,
      'reposterName': userName,
      'reposterId': userId,
      'reposterPhoto': userPhoto,
      'timestamp': Timestamp.now()
    });

    //re-post the feed to the re-poster's profile page
    await firestore
    .collection('users')
    .doc(userId)
    .collection('reposts')
    .doc(postId)
    .set({
      'postId': postId,
      'posterId': posterId,
      'posterName': postName,
      'posterPhoto': posterPhoto,
      'postTitle': postTitle,
      'postContent': postContent,
      'isReposted': true,
      'reposterName': userName,
      'reposterId': userId,
      'reposterPhoto': userPhoto,
      'timestamp': Timestamp.now()
    });
  }

  //stream of users that re-posted a post uniquely on the TL (it is this stream that we are going to call for each unique post on the TL or feeds)
  Stream<QuerySnapshot<Map<String, dynamic>>> repostStream({required String postId}) async* {
    yield* firestore
    .collection('feeds')
    .doc(postId)
    .collection('reposts')
    .orderBy('timestamp', descending: true)
    .snapshots();
  }

  //stream for the re-posts that a logged-in user made by re-posting feeds from the TL
  Stream<QuerySnapshot<Map<String, dynamic>>> repostStreamForUserProfile() async* {
    yield* firestore
    .collection('users')
    .doc(userID)
    .collection('reposts')
    .orderBy('timestamp', descending: true)
    .snapshots();
  }

  //delete a re-post function
  Future<void> deleteRepost({required String postId}) async{
    //do this if you want to get any logged in user property 
    DocumentSnapshot snapshot = await firestore
    .collection('users')
    .doc(userID)
    .get();
    String userName = snapshot.get('name');
    String userId = snapshot.get('id');
    //////////////////////////////////
    ///
    await firestore
    .collection('feeds')
    .doc(postId)
    .update({
      'isReposted': false,
    });
    ///
    await firestore
    .collection('feeds')
    .doc(postId)
    .collection('reposts')
    .doc(userId)
    .update({
      'isReposted': false,
    });
    ///
    await firestore
    .collection('users')
    .doc(userId)
    .collection('reposts')
    .doc(postId)
    .update({
      'isReposted': false,
    });

    
    //delete a re-post on the general TL
    await firestore
    .collection('feeds')
    .doc(postId)
    .collection('reposts')
    .doc(userId)
    .delete();

    //delete a re-post from the re-poster's profile page
    await firestore
    .collection('users')
    .doc(userId)
    .collection('reposts')
    .doc(postId)
    .delete();
  }


  


  //////////Comment on a post
  //comment on a post function
  Future<void> commentOnApost({required String postId}) async{

    //post id
    var commentId = (Random().nextInt(100000)).toString();

    //do this if you want to get any logged in user property 
    DocumentSnapshot snapshot = await firestore
    .collection('users')
    .doc(userID)
    .get();
    String userName = snapshot.get('name');
    String userId = snapshot.get('id');
    String userPhoto = snapshot.get('photo');
    bool userOnline = snapshot.get('isOnline');
    //////////////////////////////////
    
    //comment on a post on the general TL (will call this query snapshot stream in logged in users profile)
    await firestore
    .collection('feeds')
    .doc(postId)
    .collection('comments')
    .doc(commentId)
    .set({
      'postId': postId,
      'comment': commentTextController.text,
      'commentId': commentId,
      'commenterId': userId,
      'commenterName': userName,
      'commenterPhoto': userPhoto,
      'timestamp': Timestamp.now()
    }).whenComplete(() => commentTextController.clear());
  }

  //function that allows the commenter to edit his response on the post (make it mandatory in the ui that only if the "commenterId" matches the currently logged-in user id, will the function execute)
  Future<void> makeCommenterEditHisResponseOnAPost({required String postId, required String commentId}) async{
    await firestore
    .collection('feeds')
    .doc(postId)
    .collection('comments')
    .doc(commentId)
    .update({
      "comment": commentTextController.text
    })
    .whenComplete(() => commentTextController.clear());
  }
  

  //stream of users that commeted a post uniquely
  Stream<QuerySnapshot<Map<String, dynamic>>> postComments({required String postId}) async* {
    yield* firestore
    .collection('feeds')
    .doc(postId)
    .collection('comments')
    .orderBy('timestamp', descending: true)
    .snapshots();
  }

  //delete a particular comment from a post function (make it mandatory in the ui that unless the currently logged-in user id matches the "posterId", this function will not execute)
  Future<void> makePosterDeleteCommentsFromPost({required String postId, required String commentId}) async{
    
    //do this if you want to get any logged in user property 
    DocumentSnapshot snapshot = await firestore
    .collection('users')
    .doc(userID)
    .get();
    String userName = snapshot.get('name');
    String userId = snapshot.get('id');
    //////////////////////////////////
    
    await firestore
    .collection('feeds')
    .doc(postId)
    .collection('comments')
    .doc(commentId)
    .delete();
  }

  //delete a particular comment from a post function (make it mandatory in the ui that unless the currently logged-in user id matches the "commenterId", this function will not execute)
  Future<void> makeCommenterDeleteCommentOnAPost({required String postId, required String commentId}) async{
    
    //do this if you want to get any logged in user property 
    DocumentSnapshot snapshot = await firestore
    .collection('users')
    .doc(userID)
    .get();
    String userName = snapshot.get('name');
    String userId = snapshot.get('id');
    //////////////////////////////////
    
    await firestore
    .collection('feeds')
    .doc(postId)
    .collection('comments')
    .doc(commentId)
    .delete();
  }
  


}
