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
import 'package:pichat/user/group_chat/controller/group_chat_controller.dart';
import 'package:pichat/user/group_chat/widget/send_options_bottom_sheet.dart';
import 'package:pichat/utils/toast.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';










class BottomEngineForGroup extends StatefulWidget {
  BottomEngineForGroup({super.key, required this.groupName, required this.groupId, required this.groupPhoto, required this.chatTextController,});
  final TextEditingController chatTextController;
  final String groupId;
  final String groupName;
  final String groupPhoto;

  @override
  State<BottomEngineForGroup> createState() => _BottomEngineForGroupState();
}

class _BottomEngineForGroupState extends State<BottomEngineForGroup> {
  
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
    var groupChatController = Provider.of<GroupChatController>(context, listen: false);
    try {
      if(await audioRecord.hasPermission()) {
        await audioRecord.start();
        setState(() {
          groupChatController.isRecording = true;
        });
      }
    }
    catch (e) {
      debugPrint('error: $e');
    }
  }

  Future<void> stopRecording() async{
    var groupChatController = Provider.of<GroupChatController>(context, listen: false);
    try {
      //await audioRecord.stop();
      String? path = await audioRecord.stop();

      setState(() {
        groupChatController.isRecording = false;
        groupChatController.audioPath = path!;
      });
      // ignore: use_build_context_synchronously
      groupChatController.sendAudioToFireStorage(
        contentUrl: groupChatController.audioPath, 
        context: context, 
        groupId: widget.groupId,
        groupName: widget.groupName,
        groupPhoto: widget.groupPhoto, 
        message: groupChatController.messageTextController.text 
      );
    }
    catch (e) {
      debugPrint('error: $e');
    }
  }

  //use 'isRecording' to change icon of recording and its color, then call the "sendAudioToStorage()"


  @override
  Widget build(BuildContext context) {
    var groupChatController = Provider.of<GroupChatController>(context,);

    //only send messages when there is something to send
    Future<void> sendMessage() async{
      if(groupChatController.messageTextController.text.isNotEmpty) {
        //then send the intended message
        groupChatController.sendDirectMessages(
          message: groupChatController.messageTextController.text, 
          groupId: widget.groupId, 
          groupName: widget.groupName, 
          groupPhoto: widget.groupPhoto
        );
        groupChatController.messageTextController.clear();
        //.then((value) => groupChatController.messageTextController.clear());
      }
    }
    
    //for pictues or videos
    Future<void> sendPictureOrVideo() async{   
      //then send the intended message
      groupChatController.sendPictureOrVideoWithOrWithoutAText(
        file: groupChatController.contentFile,
        message: groupChatController.messageTextController.text, 
        groupId: widget.groupId, 
        groupName: widget.groupName, 
        groupPhoto: widget.groupPhoto       
      );
      groupChatController.messageTextController.clear(); 
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
                showSendOptionsBottomSheetForGroup(
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
                  groupChatController.isRecording = !groupChatController.isRecording;
                });

                if(groupChatController.isRecording){
                  startRecording();
                }
                else {
                  stopRecording();
                }
              },
              child: Icon(
                groupChatController.isRecording ? CupertinoIcons.mic_fill : CupertinoIcons.mic,
                color: groupChatController.isRecording ? AppTheme().mainColor: AppTheme().blackColor,
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
                controller: groupChatController.messageTextController,
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
                if(groupChatController.file != null) {
                  sendPictureOrVideo().then((val) {
                    setState(() {
                      groupChatController.isAnyImageSelectedForChat = false;
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
      var groupChatController = Provider.of<GroupChatController>(context, listen: false);
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) { 
        setState(() {
          groupChatController.contentFile = File(pickedImage.path);
          groupChatController.isImageSelectedFromGalleryForChat = true;
          groupChatController.isAnyImageSelectedForChat = true;
          groupChatController.isContentImageForChat = true;
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
      var groupChatController = Provider.of<GroupChatController>(context, listen: false);

      final pickedVideo = await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (pickedVideo != null) { 
        setState(() {
          groupChatController.contentFile = File(pickedVideo.path);
          groupChatController.isImageSelectedFromGalleryForChat = true;
          groupChatController.isAnyImageSelectedForChat = true;
          groupChatController.isContentImageForChat = false;
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




