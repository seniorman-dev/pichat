import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pichat/api/api.dart';
import 'package:pichat/user/settings/widget/helper_widgets/logout_dialogue_box.dart';
import 'package:pichat/utils/extract_firstname.dart';
import 'package:pichat/utils/toast.dart';
import 'package:provider/provider.dart';











class GroupChatController extends ChangeNotifier {

  //get the instance of firebaseauth and cloud firestore
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  double keyboardHeight = 0;
  double keyboardTop = 0;

  //list to store all the indices of friends to be added to a group
  List<int> selectedIndicesForFriends= [];

  //for group chat list
  final ScrollController messageScrollController = ScrollController();
  //for creating new group
  final ScrollController createGroupScrollController = ScrollController();
  //for textformfields to automatically scroll to the next seamlessly
  final FocusScopeNode focusScopeNode = FocusScopeNode();

  
  //messages text controller
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController groupBioController = TextEditingController();
  final TextEditingController messageTextController = TextEditingController();
  final TextEditingController groupSearchTextController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    groupNameController.dispose();
    groupBioController.dispose();
    groupSearchTextController.dispose();
    messageTextController.dispose();
    messageScrollController.dispose();
    createGroupScrollController.dispose();
    focusScopeNode.dispose();
    super.dispose();
  }



  //(to be placed inside "sendDirectMessages" function)//
  Future<void> addGroupToRecentChats({required String groupId, required String groupName, required String groupPhoto, required String lastMessage, required Timestamp timestamp, required String sentBy}) async{
    await firestore.collection('users')
    .doc(userID)
    .collection('recent_chats')
    .doc(groupId) 
    .set({
      'name': groupName,
      'id': groupId,
      'photo': groupPhoto,
      'lastMessage': lastMessage,
      'sentBy': sentBy, //person that sent the very last message
      'timestamp': timestamp
    });
  }


  ////////////////create group chat/////////////////////////////
  Future<void> createGroupChat({required String groupName, required String groupBio,}) async{
    
    try {


      //did this to get the details of the group creator or admin 
      DocumentSnapshot admin = await FirebaseFirestore.instance
      .collection('users')
      .doc(auth.currentUser!.uid)
      .get();
      String adminId = admin.get('id');
      String adminName = admin.get('name');
      String adminEmail = admin.get('email');
      String adminPhoto = admin.get('photo');
      //bool isAdminOnline = admin.get('isOnline');
      /////////////////////////////////////////////
      

      /////store selected photo////
      //did this to get the name and email of the current user
    
      //////THIS IS WHERE IMAGE/VIDEO UPLOADING IMPLEMETATION COMES IN
      //name of the folder we are first storing the file to
      String? folderName = adminEmail;
      //name the file we are sending to firebase cloud storage
      String fileName = "${DateTime.now().millisecondsSinceEpoch}group_chat_profile_image";
      //set the storage reference as "users_photos" and the "filename" as the image reference
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child('$folderName/$fileName');
      //upload the image to the cloud storage
      firebase_storage.UploadTask uploadTask = ref.putFile(file!);
      //call the object and then show that it has already been uploaded to the cloud storage or bucket
      firebase_storage.TaskSnapshot taskSnapshot = 
      await uploadTask
      .whenComplete(() => debugPrint("content uploaded succesfully to fire storage"));
      //get the imageUrl from the above taskSnapshot
      String groupPhotoUrl = await taskSnapshot.ref.getDownloadURL();
      ////////////////////////////
      //last message
      String lastMessage = "You created this group";
      //serve timestamp of cloud firestore
      Timestamp timestamp = Timestamp.now();

      //for identifying groups uniquely
      var groupId = (Random().nextInt(100000)).toString();
    
      //create group chat collection
      await firestore
      .collection('groups')
      .doc(groupId)
      .set({
        'groupId': groupId,
        'groupName': groupName,
        'groupBio': groupBio,
        'groupPhoto': groupPhotoUrl,
        'groupCreator': adminName,
        'groupMembersIdList': [
          adminId
        ],
        'groupMembersDetails': [
          {
            'memberId': adminId,
            'memberName': adminName,
            'memberPhoto': adminPhoto,
            'memberEmail': adminEmail,
            'memberType': 'Admin',
          }
        ],
        'timestamp': timestamp
      });

      //addGroupToRecentChats(groupId: groupId, groupName: groupName, groupPhoto: groupPhotoUrl, lastMessage: lastMessage, timestamp: timestamp, sentBy: adminId);

    }
    catch(e) {
      debugPrint('Error creating group: $e');
    }  
  }

  //delete a group 
  Future<void> deleteGroup({required String groupId}) async{
    //create group chat collection
    await firestore
    .collection('groups')
    .doc(groupId)
    .delete();
  }



  ////////////////send direct messages//////////////////////////////////
  Future<void> sendDirectMessages({required String message, required String groupId, required String groupName, required String groupPhoto}) async{
    
    //server timestamp
    Timestamp timestamp = Timestamp.now();

    //for identifying messages or messages documents uniquely 
    var messageId = (Random().nextInt(100000)).toString();

    //did this to get the details of the sender 
    DocumentSnapshot senderSnapshot = await FirebaseFirestore.instance
    .collection('users')
    .doc(auth.currentUser!.uid)
    .get();
    String senderName = senderSnapshot.get('name');
    String senderId = senderSnapshot.get('id');
    String senderPhoto = senderSnapshot.get('photo');
    /////////////////////////////////////////////

    
    //add the message to the group chat messages (message stream)
    await firestore
    .collection('groups')
    .doc(groupId)
    .collection('messages')
    .doc(messageId)
    .set({
      'senderId': senderId,
      'senderName': senderName,
      'senderPhoto': senderPhoto,
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
    .collection('groups')
    .doc(groupId)
    .collection('messages')
    .doc(messageId)
    .get();
    String lastMessageSent = snapshot.get('message');
    String sentBy = snapshot.get('senderId');
    Timestamp timeofLastMessageSnet = snapshot.get('timestamp');
    /////////////////////////////////////////////


    //add this for everyone's "recent_chats" collection
    /*await firestore.collection('users')
    .doc(userID)
    .collection('recent_chats')
    .doc(groupId)
    .set({
      'name': groupName,
      'id': groupId,
      'photo': groupPhoto,
      'lastMessage': lastMessageSent,
      'sentBy': sentBy,
      'timestamp': timeofLastMessageSnet
    });*/

    //function that adds who ever you are chatting with to 'recent_chats" and vice-versa
    /*addGroupToRecentChats(
      timestamp: timeofLastMessageSnet, 
      lastMessage: lastMessageSent, 
      sentBy: sentBy, 
      groupId: groupId, 
      groupName: groupName, 
      groupPhoto: groupPhoto
    );*/
    //call FCM REST API to send a message notification to the receiver of the message, if he/she is in background mode (will implement foreground mode later)
    //API().sendPushNotificationWithFirebaseAPI(content: lastMessageSent, receiverFCMToken: FCMToken, title: name);
    
    // Scroll to the newly added message to make it visible.
    messageScrollController.jumpTo(messageScrollController.position.maxScrollExtent);
  }







  //for group chat creation
  File? file;
  bool isAnyImageSelected = false;
  //for text field in "create group" screen
  final GlobalKey<FormState> formKey = GlobalKey();




  /////////////////////////////////////////////////////////////////////////////////////
  //////////sending images, videos and audios in conjunction with texts///////
  ////check if the image is taken from gallery or not
  bool isImageSelectedFromGalleryForChat = false;
  /// check if any image is selected at all
  bool isAnyImageSelectedForChat = false;
  //for image or video content
  File? contentFile;
  //check if it is a video or picture content that wants to be sent
  bool isContentImageForChat = false;



  ////////////////send direct messages for group chat
  Future<void> sendPictureOrVideoWithOrWithoutAText({
    required File? file,
    //gotten from the text controller used to send message
    required String message,
    required String groupId, 
    required String groupName, 
    required String groupPhoto
  }) async{
    Timestamp timestamp = Timestamp.now();
    //for identifying messages or messages documents uniquely 
    var messageId = (Random().nextInt(100000)).toString();
    
    //did this to get the details of the sender 
    DocumentSnapshot senderSnapshot = await FirebaseFirestore.instance
    .collection('users')
    .doc(auth.currentUser!.uid)
    .get();
    String senderName = senderSnapshot.get('name');
    String senderId = senderSnapshot.get('id');
    String senderPhoto = senderSnapshot.get('photo');
    String senderEmail = senderSnapshot.get('email');
    /////////////////////////////////////////////
    
    //////THIS IS WHERE IMAGE/VIDEO UPLOADING IMPLEMETATION COMES IN
    //name of the folder we are first storing the file to
    String? folderName = userEmail;
    //name the file we are sending to firebase cloud storage
    String fileName = "${DateTime.now().millisecondsSinceEpoch}group_messages_$groupName";
    //set the storage reference as "users_photos" and the "filename" as the image reference
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child('$folderName/$fileName');
    //upload the image to the cloud storage
    firebase_storage.UploadTask uploadTask = ref.putFile(contentFile!);
    //call the object and then show that it has already been uploaded to the cloud storage or bucket
    firebase_storage.TaskSnapshot taskSnapshot = 
    await uploadTask
    .whenComplete(() => debugPrint("content uploaded succesfully to fire storage"));
    //get the imageUrl from the above taskSnapshot
    String contentUrl = await taskSnapshot.ref.getDownloadURL();

    //NOW, WE CHECK IF THE CONTENT ABOUT TO BE SENT IS AN IMAGE OR VIDEO
    if (isContentImageForChat) {
      await firestore
      .collection('groups')
      .doc(groupId)
      .collection('messages')
      .doc(messageId)
      .set({
        'senderId': senderId,
        'senderName': senderName,
        'senderPhoto': senderPhoto,
        'messageId': messageId,
        'message': message,
        'image': contentUrl,
        'video': 'non',
        'audio': 'non',
        'messageType': 'image',
        'isSeen': false,
        'timestamp': timestamp,
      });
    
      //did this to get the last message sent from any of the chatters (messages stream)
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('groups')
      .doc(groupId)
      .collection('messages')
      .doc(messageId)
      .get();
      String lastMessageSent = snapshot.get('message');
      String sentBy = snapshot.get('senderId');
      Timestamp timeofLastMessageSnet = snapshot.get('timestamp');
      /////////////////////////////////////////////
      
      //function that adds who ever you are chatting with to 'recent_chats" and vice-versa
      /*addGroupToRecentChats(
        timestamp: timeofLastMessageSnet, 
        lastMessage: '📷 Image ~ $lastMessageSent', 
        sentBy: sentBy, 
        groupId: groupId, 
        groupName: groupName, 
        groupPhoto: groupPhoto
      );*/
  
      //call FCM REST API to send a message notification to the receiver of the message, if he/she is in background mode (will implement foreground mode later)
      //API().sendPushNotificationWithFirebaseAPI(content: '📷 Image ~ $lastMessageSent', receiverFCMToken: FCMToken, title: name);
    
      // Scroll to the newly added message to make it visible.
      messageScrollController.jumpTo(messageScrollController.position.maxScrollExtent);
      // to see what the url looks like
      debugPrint("Image URL: $contentUrl");
    }
    //THIS WILL EXECUTE IF THE CONTENT IS A VIDEO
    else {
      await firestore
      .collection('groups')
      .doc(groupId)
      .collection('messages')
      .doc(messageId)
      .set({
        'senderId': senderId,
        'senderName': senderName,
        'senderPhoto': senderPhoto,
        'messageId': messageId,
        'message': message,
        'image': 'non',
        'video': contentUrl,
        'audio': 'non',
        'messageType': 'video',
        'isSeen': false,
        'timestamp': timestamp,
      });
    

      //did this to get the last message sent from any of the chatters (messages stream)
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('groups')
      .doc(groupId)
      .collection('messages')
      .doc(messageId)
      .get();
      String lastMessageSent = snapshot.get('message');
      String sentBy = snapshot.get('senderId');
      Timestamp timeofLastMessageSnet = snapshot.get('timestamp');
      /////////////////////////////////////////////
      
      //function that adds who ever you are chatting with to 'recent_chats" and vice-versa
      /*addGroupToRecentChats(
        timestamp: timeofLastMessageSnet, 
        lastMessage: '🎬 Video ~ $lastMessageSent', 
        sentBy: sentBy, 
        groupId: groupId, 
        groupName: groupName, 
        groupPhoto: groupPhoto
      )*/
  
      //call FCM REST API to send a message notification to the receiver of the message, if he/she is in background mode (will implement foreground mode later)
      //API().sendPushNotificationWithFirebaseAPI(content: '📷 Image ~ $lastMessageSent', receiverFCMToken: FCMToken, title: name);
    
      // Scroll to the newly added message to make it visible.
      messageScrollController.jumpTo(messageScrollController.position.maxScrollExtent);
      // to see what the url looks like
      debugPrint("Video URL: $contentUrl");
    }

  }

  //delete direct message when texting
  Future<void> deleteDirectMessagesFromGroup({required String messageId, required String groupId}) async{
    await firestore
    .collection('groups')
    .doc(groupId)
    .collection('messages')
    .doc(messageId)
    .delete();
  }

  //mark message as seen or read
  Future<void> markMessageAsSeen({required String messageId, required String groupId}) async {
    try {
      /////////////////////////////////////////////
      await firestore
      .collection('groups')
      .doc(groupId)
      .collection('messages')
      .doc(messageId)
      .update({'isSeen': true});
    } catch (error) {
      debugPrint('Error marking message as seen: $error');
    }
  }



  ////////////////add friends to the group chat
  Future<void> addFriendToGroupChat({required String groupId, required String groupName, required String groupPhoto, required String friendId, required String friendName, required String friendPhoto,}) async{

    try {
      //do this if you want to get any logged in user property 
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(auth.currentUser!.uid)
      .get();
      String userName = snapshot.get('name');
      String userId = snapshot.get('id');
      String userPhoto = snapshot.get('photo');
      String userEmail = snapshot.get('email');
      //bool userOnline = snapshot.get('isOnline');
      //////////////////////////////////
      
      //last message
      String lastMessage = "You were added to this group by ${getFirstName(fullName: userName)}";
      //serve timestamp
      Timestamp timestamp = Timestamp.now();
      //create group chat collection
      await firestore
      .collection('groups')
      .doc(groupId)
      .update({
        'groupMembersIdList': [
          userId
        ],
        'groupMembersDetails': FieldValue.arrayUnion([
          {
            'memberId': userId,
            'memberName': userName,
            'memberEmail': userEmail,
            'memberPhoto': userPhoto,
            'memberType': 'Member',
          }
        ]),
        //'timestamp': timestamp
      });
    }
    catch(e) {
      debugPrint('Error adding friend to group: $e');
    }
  }

  ////////////////remove friends to the group chat
  Future<void> removeFriendFromGroupChat({required String groupId, required String groupName, required String groupPhoto, required String friendId, required String friendName, required String friendPhoto, required String friendEmail}) async{

    try {
      
      //serve timestamp
      Timestamp timestamp = Timestamp.now();
      //create group chat collection
      await firestore
      .collection('groups')
      .doc(groupId)
      .update({
        'groupMembersIdList': FieldValue.arrayRemove([friendId]),
        'groupMembersDetails': FieldValue.arrayRemove([
          {
            'memberId': friendId,
            'memberName': friendName,
            'memberEmail': friendEmail,
            'memberPhoto': friendPhoto,
            'memberType': 'Member',
          }
        ]),
      });
    }
    catch(e) {
      debugPrint('Error removing friend from group: $e');
    }
  }



  //////////////////////////////to send audio//////////////////////////////////
  bool isPlaying = false;
  bool isRecording = false;
  String audioPath = "" ;  //save to db
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  //bool isTimeElasped = false;


  //upload and save audio to fire storage
  Future<void> sendAudioToFireStorage({
    required String contentUrl, 
    required BuildContext context, 
    required String groupId,
    required String groupName,
    required String groupPhoto, 
    required String message,
  }) async{
    try {

      Timestamp timestamp = Timestamp.now();
      //for identifying messages or messages documents uniquely 
      var messageId = (Random().nextInt(100000)).toString();

      //do this if you want to get any logged in user property 
      DocumentSnapshot senderSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(auth.currentUser!.uid)
      .get();
      String senderName = senderSnapshot.get('name');
      String senderId = senderSnapshot.get('id');
      String senderPhoto = senderSnapshot.get('photo');
      String senderEmail = senderSnapshot.get('email');
      //bool userOnline = snapshot.get('isOnline');
      //////////////////////////////////

      //add the messages to the collection
      await firestore
      .collection('groups')
      .doc(groupId)
      .collection('messages')
      .doc(messageId)
      .set({
        'senderId': senderId,
        'senderName': senderName,
        'senderPhoto': senderPhoto,
        'messageId': messageId,
        'message': message,
        'image': 'non',
        'video': 'non',
        'audio': contentUrl,
        'messageType': 'audio',
        'isSeen': false,
        'timestamp': timestamp,
      });
    

      //did this to get the last message sent from any of the chatters (messages stream)
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('groups')
      .doc(groupId)
      .collection('messages')
      .doc(messageId)
      .get();
      String lastMessageSent = snapshot.get('message');
      String sentBy = snapshot.get('senderId');
      Timestamp timeofLastMessageSnet = snapshot.get('timestamp');
      /////////////////////////////////////////////
      
      //function that adds who ever you are chatting with to 'recent_chats" and vice-versa
      /*addGroupToRecentChats(
        timestamp: timeofLastMessageSnet, 
        lastMessage: '🎵 Audio ', 
        sentBy: sentBy, 
        groupId: groupId, 
        groupName: groupName, 
        groupPhoto: groupPhoto
      );*/

      //call FCM REST API to send a message notification to the receiver of the message, if he/she is in background mode (will implement foreground mode later)
      //API().sendPushNotificationWithFirebaseAPI(content: '🎵 Audio ', receiverFCMToken: FCMToken, title: name);
    
      // Scroll to the newly added message to make it visible.
      messageScrollController.jumpTo(messageScrollController.position.maxScrollExtent);
      // to see what the url looks like
      debugPrint("audio url: $contentUrl");
    }
    on FirebaseException catch (e) {
      getToast(context: context, text: 'Error uploading audio: $e');
    }
  }

  
  //to get list of messages in a group
  Stream<QuerySnapshot<Map<String, dynamic>>> groupMessagesStream({required String groupId}) async*{
    yield* firestore
    .collection('groups')
    .doc(groupId)
    .collection('messages')
    .orderBy('timestamp',)
    .snapshots();
  }
  
  Stream<QuerySnapshot<Map<String, dynamic>>>? userGroupStream;

  //filtered group list for logged-in user (i.e, groups where logged-in user is a member)
  Stream<QuerySnapshot<Map<String, dynamic>>> userGroupListStream() async*{
    yield* firestore
    .collection('groups')
    .where('groupMembersIdList', arrayContains: userID)
    .snapshots();
  }




  ///////////
  //filtered group list for logged-in user (i.e, groups where logged-in user is a member)
  Stream<QuerySnapshot<Map<String, dynamic>>> filteredUserGroupListStreamForSearching() async*{
     
    yield* firestore
    .collection('groups')
    .where('groupMembersIdList', arrayContains: userID)
    .where('groupName', isEqualTo: groupSearchTextController.text)
    .snapshots();

    //to get snapshot of the members of all the groups present
    /*QuerySnapshot groupsSnapshot = await firestore.collection('groups').get();
    for (DocumentSnapshot groupDoc in groupsSnapshot.docs) {
      CollectionReference membersCollection = groupDoc.reference.collection('members');
      QuerySnapshot membersSnapshot = await membersCollection.get();

      for (DocumentSnapshot memberDoc in membersSnapshot.docs) {
        //String memberName = memberDoc.get('memberName');
        String memberId = memberDoc.get('memberId');
        //String memberPhoto = memberDoc.get('memberPhoto');
        //String memberType = memberDoc.get('memberType');
    
        // Now you have the member information for each member in each group
        yield* firestore
        .collection('groups')
        .where('groupName', isEqualTo: messageTextController.text)
        .where('memberId', isEqualTo: memberId)
        .orderBy('timestamp', descending: true)
        .snapshots();
      }
    }*/
  }

  //stream for group members
  /*Stream<QuerySnapshot<Map<String, dynamic>>> groupMembersStream({required String groupId}) async*{
    yield*
    firestore
    .collection('groups')
    .doc(groupId)
    .collection('members')
    .orderBy('timestamp', descending: true)
    .snapshots();
  }*/
  
}