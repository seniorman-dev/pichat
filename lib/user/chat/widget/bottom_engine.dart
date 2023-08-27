import 'dart:io';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:Ezio/api/api.dart';
import 'package:Ezio/theme/app_theme.dart';
import 'package:Ezio/user/chat/controller/chat_service_controller.dart';
import 'package:Ezio/user/chat/widget/send_picture_or_video_dialogue.dart';
import 'package:Ezio/utils/toast.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';











class BottomEngine extends StatefulWidget {
  BottomEngine({super.key, required this.receiverName, required this.receiverId, required this.receiverPhoto, required this.chatTextController, required this.receiverFCMToken,});
  final String receiverName;
  final String receiverId;
  final String receiverPhoto;
  final String receiverFCMToken;
  final TextEditingController chatTextController;

  @override
  State<BottomEngine> createState() => _BottomEngineState();
}

class _BottomEngineState extends State<BottomEngine> {
  

  FlutterLocalNotificationsPlugin fln = FlutterLocalNotificationsPlugin();


  @override
  void initState() {
    initRecording();
    super.initState();
  }

  @override
  void dispose() {
    var chatServiceController = Provider.of<ChatServiceController>(context, listen: false);
    chatServiceController.recorder.closeRecorder();
    super.dispose();
  }

  Future<void> initRecording() async{
    var chatServiceController = Provider.of<ChatServiceController>(context, listen: false);
    final status = await Permission.microphone.request();
    if(status != PermissionStatus.granted) {
      throw RecordingPermissionException ('Permission not granted');
    }
    await chatServiceController.recorder.openRecorder();
    chatServiceController.recorder.setSubscriptionDuration(Duration(milliseconds: 500));
  }

  Future<void> startRecording() async{
    var chatServiceController = Provider.of<ChatServiceController>(context, listen: false);
    try {
      await chatServiceController.recorder.startRecorder(toFile: 'audio');
      setState(() {
        chatServiceController.isRecording = true;
      });
    }
    catch (e) {
      throw ('error: $e');
    }
  }

  Future<void> stopRecording() async{
    var chatServiceController = Provider.of<ChatServiceController>(context, listen: false);
    try {

      Timestamp serverTimestamp = Timestamp.now();

      //did this to get the name and email of the current user
      DocumentSnapshot senderSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(chatServiceController.auth.currentUser!.uid)
      .get();
      String name = senderSnapshot.get('name');
      String userEmail = senderSnapshot.get('email');

      final filePath = await chatServiceController.recorder.stopRecorder();
      final file = File(filePath!);
      debugPrint("Recorded file File: $file");

      setState(() {
        chatServiceController.isRecording = false;
        chatServiceController.audioPath = filePath;
      });

      //////THIS IS WHERE IMAGE/VIDEO UPLOADING IMPLEMETATION COMES IN
      //name of the folder we are first storing the file to
      String? folderName = userEmail;
      //name the file we are sending to firebase cloud storage
      String fileName = "${serverTimestamp}dm_audio";
      //set the storage reference as "" and the "filename" as the image reference
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child('$folderName/$fileName');
      //upload the image to the cloud storage
      firebase_storage.UploadTask uploadTask = ref.putFile(file);
      //call the object and then show that it has already been uploaded to the cloud storage or bucket
      firebase_storage.TaskSnapshot taskSnapshot = 
      await uploadTask
      .whenComplete(() => debugPrint("content uploaded succesfully to fire storage"));
      //get the imageUrl from the above taskSnapshot
      String contentUrl = await taskSnapshot.ref.getDownloadURL();

      // ignore: use_build_context_synchronously
      chatServiceController.uploadAudioToFireStorage(
        contentUrl: contentUrl, 
        context: context, 
        receiverId: widget.receiverId, 
        message: chatServiceController.chatTextController.text, 
        receiverName: widget.receiverName, 
        receiverPhoto: widget.receiverPhoto
      );
    }
    catch (e) {
      throw ('error: $e');
    }
  }

  //use 'isRecording' to change icon of recording and its color, then call the "sendAudioToStorage()"


  @override
  Widget build(BuildContext context) {

    var chatServiceController = Provider.of<ChatServiceController>(context);


    //only send messages when there is something to send
    Future<void> sendMessage() async{
      //do this if you want to get any logged in user property 
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(chatServiceController.auth.currentUser!.uid)
      .get();
      String userName = snapshot.get('name');
      String userId = snapshot.get('id');

      if(chatServiceController.chatTextController.text.isNotEmpty) {
        //then send the intended message
        chatServiceController.sendDirectMessages(
          receiverId: widget.receiverId, 
          receiverName: widget.receiverName, 
          receiverPhoto: widget.receiverPhoto, 
          message: chatServiceController.chatTextController.text, 
        )
        .then((value) => chatServiceController.makeKeyboardDisappear())
        .then((value) {API().sendPushNotificationWithFirebaseAPI(receiverFCMToken: widget.receiverFCMToken, title: userName, content: chatServiceController.chatTextController.text);});
        //API().sendPushNotificationWithFirebaseAPI(receiverFCMToken: widget.receiverFCMToken, title: userName, content: chatServiceController.chatTextController.text);
        chatServiceController.chatTextController.clear();
        //API().showFLNP(title: userName, body: chatServiceController.chatTextController.text, fln: fln);
      }
    }

    Future<void> sendPictureOrVideo() async{
      //do this if you want to get any logged in user property 
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(chatServiceController.auth.currentUser!.uid)
      .get();
      String userName = snapshot.get('name');
      //then send the intended message
      chatServiceController.sendPictureOrVideoWithOrWithoutAText(
        receiverId: widget.receiverId, 
        receiverName: widget.receiverName, 
        receiverPhoto: widget.receiverPhoto, 
        message: chatServiceController.chatTextController.text, 
        file: chatServiceController.file  
        )
        .then((value) => chatServiceController.makeKeyboardDisappear()
      )
      .then((value) {API().sendPushNotificationWithFirebaseAPI(receiverFCMToken: widget.receiverFCMToken, title: userName, content: '📷/🎬 content'); });
      //API().sendPushNotificationWithFirebaseAPI(receiverFCMToken: widget.receiverFCMToken, title: userName, content: '📷/🎬 content'); 
      chatServiceController.chatTextController.clear();
    }


    
    //wrap with positioned
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 0.h, //25.h
        horizontal: 10.w  //20.h
      ),
      child: Container(
        alignment: Alignment.center,
        height: 70.h, //60.h
        //width: 400.w,
        padding: EdgeInsets.symmetric(
          vertical: 0.h, //2.h
          horizontal: 10.w  //15.h
        ),
        decoration: BoxDecoration(
          color: AppTheme().whiteColor,
          borderRadius: BorderRadius.circular(20.r), //30.r
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              //color: AppTheme().lightGreyColor,
              spreadRadius: 0.1.r,
              blurRadius: 8.0.r,
            )
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                CupertinoIcons.link
              ),
              color: AppTheme().blackColor,
              //iconSize: 30.r, 
              onPressed: () {
                //open dialog for picking video, image or file document
                showSendOptionsBottomSheet(
                  context: context, 
                  onPressedForImage: () {
                    pickImageFromGallery(context: context);
                    setState(() {});
                  }, 
                  onPressedForVideo: () {
                    pickVideoFromGallery(context: context);
                    setState(() {});
                  }, 
                );
              },
            ),
            const SizedBox(width: 3,),
            GestureDetector(
              onTap: () async{
                /*setState(() {
                  chatServiceController.isRecording = !chatServiceController.isRecording;
                });*/

                if(chatServiceController.isRecording){
                  await stopRecording();
                  setState(() {
                    chatServiceController.isRecording = false;
                  });
                }
                else {
                  await startRecording();
                  setState(() {
                    chatServiceController.isRecording = true;
                  });
                }
              },
              child: Icon(
                chatServiceController.isRecording ? CupertinoIcons.mic_fill : CupertinoIcons.mic,
                color: chatServiceController.isRecording ? AppTheme().mainColor: AppTheme().blackColor,
              ),
            ),
            SizedBox(width: 5.w,),
            VerticalDivider(color: AppTheme().darkGreyColor, thickness: 1,),
            SizedBox(width: 5.w,),
            Expanded(
              child: TextFormField( 
                //autofocus: true,  
                onTap: () {},       
                scrollPhysics: const BouncingScrollPhysics(),
                scrollController: ScrollController(),
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 10,
                enabled: true,
                controller: chatServiceController.chatTextController,
                keyboardType: TextInputType.multiline,
                autocorrect: true,
                enableSuggestions: true,
                enableInteractiveSelection: true,
                cursorColor: AppTheme().blackColor,
                style: GoogleFonts.poppins(color: AppTheme().blackColor),
                decoration: InputDecoration(        
                  border: InputBorder.none,        
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.poppins(color: AppTheme().darkGreyColor, fontSize: 14.sp),              
                )
              ),
            ),
            SizedBox(width: 5.w,),
            IconButton(
              icon: const Icon(
                Icons.send_rounded,
                //Icons.send
              ),
              onPressed: () {
                if(chatServiceController.file != null) {
                  sendPictureOrVideo().then((val) {
                    setState(() {
                      chatServiceController.isAnyImageSelected = false;
                    });
                  });
                }
                else{
                  sendMessage();
                }
              },
              //iconSize: 30.r, //40.r, 
              color: AppTheme().mainColor,
            ),
            //SizedBox(width: 5.w,),
          ]
        ),
      ),
    );
  }
  






  //////////////////////////////////////////////////////////////////////////////
  //pick image from gallery
  Future<void> pickImageFromGallery({required BuildContext context}) async {
    // Simulate fetching data asynchronously
    //await Future.delayed(const Duration(seconds: 2));
    try {
      var chatServiceController = Provider.of<ChatServiceController>(context, listen: false);
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) { 
        setState(() {
          chatServiceController.file = File(pickedImage.path);
          chatServiceController.isImageSelectedFromGallery = true;
          chatServiceController.isAnyImageSelected = true;
          chatServiceController.isContentImage = true;
        });
        debugPrint("image was picked from gallery");
      }
      else {
        debugPrint("no image was picked from gallery");
      }
    }
    catch (e) {
      getToast(context: context, text: 'Error picking image from gallery: $e');
    }
  }

  //pick image from gallery
  Future<void> pickVideoFromGallery({required BuildContext context,}) async {
    // Simulate fetching data asynchronously
    //await Future.delayed(const Duration(seconds: 2));
    try {
      var chatServiceController = Provider.of<ChatServiceController>(context, listen: false);
      final pickedVideo = await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (pickedVideo != null) { 
        setState(() {
          chatServiceController.file = File(pickedVideo.path);
          chatServiceController.isImageSelectedFromGallery = false;
          chatServiceController.isAnyImageSelected = false;
          chatServiceController.isContentImage = false;
        });
        debugPrint('video was picked from gallery');
      }
      else {
        debugPrint("no video was picked from gallery");
      }
    }
    catch (e) {
      getToast(context: context, text: 'Error picking video from gallery: $e');
    }
  }
}




