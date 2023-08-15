import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/utils/toast.dart';
import 'package:provider/provider.dart';
import '../../settings/controller/profile_controller.dart';










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

  //global key for form field
  GlobalKey formKey = GlobalKey<FormState>();
  //for post textformfield


  //picked content (whether image or video)
  File? contentFile;

  ////check if the image is taken from gallery or not
  bool isImageSelectedFromGallery = false;
  /// check if any image is selected at all
  bool isAnyImageSelected = false;
  //check if it is a video or picture content that wants to be uploaded
  bool isContentImage = false;
  //check if a posted content is liked and reposted
  bool isLiked = false;
  bool isReposted = false;


  @override
  void dispose() {
    // TODO: implement dispose
    commentTextController.dispose();
    postTextController.dispose();
    super.dispose();
  }






  // Fetch feeds from Firestore using the friend list (feeds for the timeline)
  Stream<QuerySnapshot<Map<String, dynamic>>> getFeeds() async*{
    //final friendList = await fetchFriendList();
    yield* firestore
    .collection('feeds')
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

  // Fetch logged-in user's connects to be displayed on his/her profile
  Stream<QuerySnapshot<Map<String, dynamic>>> userFriends() async* {
    yield* firestore
    .collection('users')
    .doc(userID)
    .collection('friends')
    //.orderBy('timestamp', descending: true)
    .snapshots();
  }


  
  //uploads the image, video & other contents to the cloud and the stores the image url to firestore database
  Future<void> uploadContentToDatbase({required File? file, required BuildContext context}) async {
    try {
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
      //bool userOnline = snapshot.get('isOnline');
    
      //name of the folder we are first storing the file to
      String? folderName = userEmail;
      //name the file we are sending to firebase cloud storage
      String fileName = "${DateTime.now().millisecondsSinceEpoch}post";
      //set the storage reference as "users_photos" and the "filename" as the image reference
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child('$folderName/$fileName');
      //upload the image to the cloud storage
      firebase_storage.UploadTask uploadTask = ref.putFile(file!);
      //call the object and then show that it has already been uploaded to the cloud storage or bucket
      firebase_storage.TaskSnapshot taskSnapshot = 
      await uploadTask
      .whenComplete(() => debugPrint("image uploaded succesfully to fire storage"));
      //get the imageUrl from the above taskSnapshot
      String contentUrl = await taskSnapshot.ref.getDownloadURL();
    
      //check if the content about to be posted is an image or not, then post to general feeds
      if(isContentImage) {
        //(this one catch)
        await firestore
        .collection('feeds')
        .doc(postId)
        .set({
          'postId': postId,
          'posterId': userId,
          'posterName': userName,
          'posterPhoto': userPhoto,
          'postTitle': postTextController.text,
          'postContent': contentUrl,
          'isImage':true,
          'timestamp': Timestamp.now()
        });

        //post the feed to the poster's profile (this one catch)
        await firestore
        .collection('users')
        .doc(userID)
        .collection('posts')
        .doc(postId)
        .set({
          'postId': postId,
          'posterId': userId,
          'posterName': userName,
          'posterPhoto': userPhoto,
          'postTitle': postTextController.text,
          'postContent': contentUrl,
          'isImage':true,
          'timestamp': Timestamp.now()
        });

      }
      //video content
      else {
        await firestore
        .collection('feeds')
        .doc(postId)
        .set({
          'postId': postId,
          'posterId': userId,
          'posterName': userName,
          'posterPhoto': userPhoto,
          'postTitle': postTextController.text,
          'postContent': contentUrl,
          'isImage': false,
          'timestamp': Timestamp.now()
        });

        //post the feed to the poster's profile
        await firestore
        .collection('users')
        .doc(userID)
        .collection('posts')
        .doc(postId)
        .set({
          'postId': postId,
          'posterId': userId,
          'posterName': userName,
          'posterPhoto': userPhoto,
          'postTitle': postTextController.text,
          'postContent': contentUrl,
          'isImage': false,
          'timestamp': Timestamp.now()
        });
      }
      // to see what the url looks like
      debugPrint("ContentURL: $contentUrl");
    }
    catch(e) {
      getToast(context: context, text:"Error: $e" );
    }
  }

  Future<void> letPosterDeletePost({required BuildContext context, required String postId,}) async{
    try {
      await firestore
      .collection('feeds')
      .doc(postId)
      .delete();
      //
      await firestore
      .collection('users')
      .doc(userID)
      .collection('posts')
      .doc(postId)
      .delete();
    }
    catch (e) {
      getToast(context: context, text:"Error: $e" );
    }
  }






  //check is a post is liked
  bool isPostLiked = false;
  //check if a post is re-posted
  bool isPostReposted = false;


  //list to store all the indices of reposted post liked
  List<int> selectedIndicesForLikes= [];
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
    //bool userOnline = snapshot.get('isOnline');
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
      'isLiked': true,
      'timestamp': Timestamp.now()
    });
    
    //this is what we will show in the user profile
    await firestore
    .collection('users')
    .doc(userID)
    .collection('posts')
    .doc(postId)
    .collection('likes')
    .doc(userId)
    .set({
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'isLiked': true,
      'timestamp': Timestamp.now()
    });

  }

  //stream of users that liked a post uniquely (for feeds screen)
  Stream<QuerySnapshot<Map<String, dynamic>>> postLikes({required String postId}) async* {
    yield* firestore
    .collection('feeds')
    .doc(postId)
    .collection('likes')
    .orderBy('timestamp', descending: true)
    .snapshots();
  }

  //for user profile
  Stream<QuerySnapshot<Map<String, dynamic>>> postLikesForUserProfile({required String postId}) async* {
    yield* firestore
    .collection('users')
    .doc(userID)
    .collection('posts')
    .doc(postId)
    .collection('likes')
    .orderBy('timestamp', descending: true)
    .snapshots();
  }
  /////////////for liking and unliking icon
  Stream<DocumentSnapshot<Map<String, dynamic>>> postLikesForUserProfileDoc({required String postId}) async* {
    yield* firestore
    .collection('users')
    .doc(userID)
    .collection('posts')
    .doc(postId)
    .collection('likes')
    .doc(userID)
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

    ///update 'userLiked' to false
    await firestore
    .collection('users')
    .doc(userID)
    .collection('posts')
    .doc(postId)
    .collection('likes')
    .doc(userId)
    .update({     
      'userLiked': false,
    });

    ////delete the whole thing (unlike)
    await firestore
    .collection('users')
    .doc(userID)
    .collection('posts')
    .doc(postId)
    .collection('likes')
    .doc(userId).delete();
  }




  //list to store all the indices of reposted post liked
  List<int> selectedIndicesForReposts= [];
  ////////////////////////////////////////////////////////////////////////////////////////////
  //repost a post function
  Future<void> rePostAPost({required bool isImage, required String postId, required String posterId, required String posterName, required String posterPhoto, required String postTitle, required String postContent}) async{
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
    var repostId = (Random().nextInt(100000)).toString();

    //just to show who reposted on the feeds screen
    /*await firestore
    .collection('feeds')
    .doc(postId)
    .update({
      'reposters': FieldValue.arrayUnion([
        {
          'reposterName': userName,
          'reposterId': userId,
          'reposterPhoto': userPhoto,
        }
      ])
    });*/
    
    //repost the post on the general TL (to allow user to only repost once)
    await firestore
    .collection('feeds')
    .doc(userID)
    .set({
      'postId': postId,
      'repostId': repostId,
      'posterId': posterId,
      'posterName': posterName,
      'posterPhoto': posterPhoto,
      'postTitle': postTitle,
      'postContent': postContent,
      'isReposted': true,
      'isImage': isImage,
      'timestamp': Timestamp.now(),
      'reposterName': userName,
      'reposterId': userId,
      'reposterPhoto': userPhoto,
    });

    //update the "re-posts" collection reference for posts on the TL (it is this stream that we are going to call for each unique post on the TL or feeds. to dislay their length)
    await firestore
    .collection('feeds')
    .doc(postId)
    .collection('reposts')
    .doc(userId)
    .set({
      'postId': postId,
      'repostId': repostId,
      'posterId': posterId,
      'posterName': posterName,
      'posterPhoto': posterPhoto,
      'postTitle': postTitle,
      'postContent': postContent,
      'isReposted': true,
      'isImage': isImage,
      'reposterName': userName,
      'reposterId': userId,
      'reposterPhoto': userPhoto,
      'timestamp': Timestamp.now()
    });

    //re-post the feed to the re-poster's profile page or wall
    await firestore
    .collection('users')
    .doc(userId)
    .collection('reposts')
    .doc(postId)
    .set({
      'postId': postId,
      'repostId': repostId,
      'posterId': posterId,
      'posterName': posterName,
      'posterPhoto': posterPhoto,
      'postTitle': postTitle,
      'postContent': postContent,
      'isReposted': true,
      'isImage': isImage,
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

  /////////////for re-posting icon(to do and undo)
  Stream<DocumentSnapshot<Map<String, dynamic>>> repostForUserProfileDoc({required String postId}) async* {
    yield* firestore
    .collection('users')
    .doc(userID)
    .collection('reposts')
    .doc(postId)
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
    String userPhoto = snapshot.get('photo');
    //////////////////////////////////
    
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

    //deletes the main reposted post from the TL(i used the poster's document id to tail it)
    await firestore
    .collection('feeds')
    .doc(userID)
    .delete();
    
    
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


  

                 //*Comment on a post**//
  /////////////////////////////////////////////////////////////////////
  //comment on a post function
  Future<void> commentOnApost({required String postId, required String posterName}) async{

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
      'posterName': posterName,
      'comment': commentTextController.text,
      'commentId': commentId,
      'commenterId': userId,
      'commenterName': userName,
      'commenterPhoto': userPhoto,
      'userCommented': true,
      'timestamp': Timestamp.now()
    }).whenComplete(() => commentTextController.clear());
    
    //call this stream in logged in user profile
    await firestore
    .collection('users')
    .doc(userID)
    .collection('posts')
    .doc(postId)
    .collection('comments')
    .doc(commentId)
    .set({
      'postId': postId,
      'posterName': posterName,
      'comment': commentTextController.text,
      'commentId': commentId,
      'commenterId': userId,
      'commenterName': userName,
      'commenterPhoto': userPhoto,
      'userCommented': true,
      'timestamp': Timestamp.now()
    });
  }
  


  //list to store all the indices of comments liked
  List<int> selectedItems = [];

  ////boolean affiliated to this function below
  bool isCommentLiked = false;
  //for comments on a feed
  Future<void> likeACommentUnderAPost({required String postId, required String commentId}) async {
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
    
    await firestore
    .collection('feeds')
    .doc(postId)
    .collection('comments')
    .doc(commentId)
    .collection('likes')
    .doc(userId)
    .set({
      'userName': userName,
      'userId': userId,
      'userPhoto': userPhoto,
      'timestamp': Timestamp.now()
    });
  }

  //the stream affiliated to the above function
  //stream of users that commeted a post uniquely(for user profile)
  Stream<QuerySnapshot<Map<String, dynamic>>> usersWhoLikedACommentUnderAPostStream({required String postId, required String commentId}) async* {
    yield*
    firestore
    .collection('feeds')
    .doc(postId)
    .collection('comments')
    .doc(commentId)
    .collection('likes')
    .orderBy('timestamp', descending: true)
    .snapshots();
  }




  //for comments on a feed
  Future<void> unlikeACommentUnderAPost({required String postId, required String commentId}) async {
    //do this if you want to get any logged in user property 
    DocumentSnapshot snapshot = await firestore
    .collection('users')
    .doc(userID)
    .get();

    String userId = snapshot.get('id');
    //////////////////////////////////
    
    await firestore
    .collection('feeds')
    .doc(postId)
    .collection('comments')
    .doc(commentId)
    .collection('likes')
    .doc(userId)
    .delete();
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

  //stream of users that commeted a post uniquely(for user profile)
  Stream<QuerySnapshot<Map<String, dynamic>>> postCommentsForUserProfile({required String postId}) async* {
    yield*
    firestore
    .collection('users')
    .doc(userID)
    .collection('posts')
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

    await firestore
    .collection('users')
    .doc(userID)
    .collection('posts')
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
    
    ///update userComment boolean to false
    await firestore
    .collection('feeds')
    .doc(postId)
    .collection('comments')
    .doc(commentId)
    .update({
      'userCommented': false,
    });

    //then delete the whole thing
    await firestore
    .collection('feeds')
    .doc(postId)
    .collection('comments')
    .doc(commentId)
    .delete();



    ///update 'userCommented' to false (we will call this stream in the user profile)
    await firestore
    .collection('users')
    .doc(userID)
    .collection('posts')
    .doc(postId)
    .collection('comments')
    .doc(commentId)
    .update({     
      'userCommented': false,
    });

    ////delete the whole thing (unlike)
    await firestore
    .collection('users')
    .doc(userID)
    .collection('posts')
    .doc(postId)
    .collection('comments')
    .doc(commentId)
    .delete();

  }
  


}
