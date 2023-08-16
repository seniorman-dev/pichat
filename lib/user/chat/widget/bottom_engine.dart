import 'dart:io';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/chat/controller/chat_service_controller.dart';
import 'package:pichat/user/chat/widget/send_picture_or_video_dialogue.dart';
import 'package:pichat/utils/toast.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';








class BottomEngine extends StatefulWidget {
  BottomEngine({super.key, required this.receiverName, required this.receiverId, required this.receiverPhoto, required this.chatTextController,});
  final String receiverName;
  final String receiverId;
  final String receiverPhoto;
  final TextEditingController chatTextController;

  @override
  State<BottomEngine> createState() => _BottomEngineState();
}

class _BottomEngineState extends State<BottomEngine> {
  
  late Record audioRecord;
  late AudioPlayer audioPlayer;

  @override
  void initState() {
    audioPlayer = AudioPlayer();
    audioRecord = Record();
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    audioRecord.dispose();
    super.dispose();
  }

  Future<void> startRecording() async{
    var chatServiceController = Provider.of<ChatServiceController>(context, listen: false);
    try {
      if(await audioRecord.hasPermission()) {
        await audioRecord.start();
        setState(() {
          chatServiceController.isRecording = true;
        });
      }
    }
    catch (e) {
      print('error: $e');
    }
  }

  Future<void> stopRecording() async{
    var chatServiceController = Provider.of<ChatServiceController>(context, listen: false);
    try {
      //await audioRecord.stop();
      String? path = await audioRecord.stop();

      setState(() {
        chatServiceController.isRecording = false;
        chatServiceController.audioPath = path!;
      });
      // ignore: use_build_context_synchronously
      chatServiceController.uploadAudioToFireStorage(
        contentUrl: chatServiceController.audioPath, 
        context: context, 
        receiverId: widget.receiverId, 
        message: chatServiceController.chatTextController.text, 
        receiverName: widget.receiverName, 
        receiverPhoto: widget.receiverPhoto
      );
    }
    catch (e) {
      print('error: $e');
    }
  }

  //use 'isRecording' to change icon of recording and its color, then call the "sendAudioToStorage()"


  @override
  Widget build(BuildContext context) {

    var chatServiceController = Provider.of<ChatServiceController>(context);


    //only send messages when there is something to send
    Future<void> sendMessage() async{
      if(chatServiceController.chatTextController.text.isNotEmpty) {
        //then send the intended message
        chatServiceController.sendDirectMessages(
          receiverId: widget.receiverId, 
          receiverName: widget.receiverName, 
          receiverPhoto: widget.receiverPhoto, 
          message: chatServiceController.chatTextController.text, 
        )
        //.then((val) => textController.clear())
        .then((value) => chatServiceController.makeKeyboardDisappear());
        chatServiceController.chatTextController.clear();
      }
    }

    Future<void> sendPictureOrVideo() async{
      
      //then send the intended message
      chatServiceController.sendPictureOrVideoWithOrWithoutAText(
        receiverId: widget.receiverId, 
        receiverName: widget.receiverName, 
        receiverPhoto: widget.receiverPhoto, 
        message: chatServiceController.chatTextController.text, 
        file: chatServiceController.file  
        )
        .then((value) => chatServiceController.makeKeyboardDisappear()
      );
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
            const SizedBox(width: 5,),
            GestureDetector(
              onTap: (){
                setState(() {
                  chatServiceController.isRecording = !chatServiceController.isRecording;
                });

                if(chatServiceController.isRecording){
                  startRecording();
                }
                else {
                  stopRecording();
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
                CupertinoIcons.location_north_line_fill,
                //Icons.send
              ),
              onPressed: () {
                if(chatServiceController.file != null) {
                  sendPictureOrVideo().then((val) {
                    setState(() {
                      chatServiceController.file = null;
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




