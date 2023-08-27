import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Ezio/theme/app_theme.dart';
//import 'package:Ezio/user/chat/agora/audio/audio_call.dart';
//import 'package:Ezio/user/chat/agora/video/video_call.dart';
import 'package:Ezio/user/chat/controller/chat_service_controller.dart';
import 'package:Ezio/user/chat/widget/bottom_engine.dart';
import 'package:Ezio/user/chat/widget/chat_list.dart';
import 'package:Ezio/utils/loader.dart';
import 'package:provider/provider.dart';









class DMScreen extends StatefulWidget {
  const DMScreen({super.key, required this.receiverProfilePic, required this.receiverName, required this.receiverID, required this.isOnline, required this.senderName, required this.senderId, required this.receiverFCMToken,});
  final String receiverProfilePic;
  final String receiverName;
  final String receiverID;
  final String receiverFCMToken;
  final String senderName;
  final String senderId;
  final bool isOnline;

  @override
  State<DMScreen> createState() => _DMScreenState();
}

class _DMScreenState extends State<DMScreen> with WidgetsBindingObserver{
  
  
  double keyboardHeight = 0;
  double keyboardTop = 0;

  double calculateBottomPadding(BuildContext context) {

    ///did all these for device keyboard to automatically scroll up when the custom textformfield is tapped
    double screenHeight = MediaQuery.of(context).size.height;
    double minPadding = 0;
    double maxPadding = screenHeight * 0.39; // Adjust the value as needed (0.37 is an example)

    return keyboardHeight > MediaQuery.of(context).padding.bottom + 10 ? maxPadding : minPadding;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final topInset = WidgetsBinding.instance.window.viewInsets.top;
    setState(() {
      keyboardHeight = bottomInset;
      keyboardTop = topInset; 
    });
  }

  @override
  Widget build(BuildContext context) {

    var chatServiceController = Provider.of<ChatServiceController>(context);

    return SafeArea(
      child: Scaffold(
        //resizeToAvoidBottomInset: true,
        backgroundColor: AppTheme().whiteColor,//.lightGreyColor,
        appBar: AppBar(
          toolbarHeight: 80.h,
          backgroundColor: AppTheme().whiteColor,
          centerTitle: false,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Get.back();
            }, 
            icon: Icon(
              CupertinoIcons.back,
              color: AppTheme().blackColor,
              size: 30.r,
            )
          ),
          title: Row( //title
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //profilePic
              CircleAvatar(
                radius: 30.r,
                backgroundColor: AppTheme().opacityBlue,
                child: CircleAvatar(
                  radius: 28.r, 
                  backgroundColor: widget.receiverProfilePic == null ? AppTheme().darkGreyColor : AppTheme().blackColor,
                  //backgroundColor: AppTheme().darkGreyColor,
                  child: widget.receiverProfilePic == null 
                  ?null
                  :ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10.r)), //.circular(20.r),
                    clipBehavior: Clip.antiAlias, //.antiAliasWithSaveLayer,
                    child: CachedNetworkImage(
                      imageUrl: widget.receiverProfilePic,
                      width: 40.w,
                      height: 40.h,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Loader(),
                      errorWidget: (context, url, error) => Icon(
                        Icons.error,
                        color: AppTheme().lightestOpacityBlue,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w,),
              //details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.receiverName,
                      style: GoogleFonts.poppins(
                        color: AppTheme().blackColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    SizedBox(height: 2.h,),
                    Text(
                      widget.isOnline ? 'online' : 'offline',
                      style: GoogleFonts.poppins(
                        color: widget.isOnline? AppTheme().greenColor : AppTheme().darkGreyColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        textStyle: const TextStyle(
                          overflow: TextOverflow.ellipsis
                        )
                      ),
                    ),
                  ]
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                CupertinoIcons.videocam,
                color: AppTheme().blackColor,
                size: 24.r,
              ),
              onPressed: () {
                //Get.to(() => ChatVideoCall());
              },
            ),
            IconButton(
              icon: Icon(
                CupertinoIcons.phone_down,
                color: AppTheme().blackColor,
                size: 24.r,
              ),
              onPressed: () {
                //Get.to(() => ChatVoiceCall());
              },
            ),
            SizedBox(width: 10.w,)  
          ],
        ),
        body: Container(
          //decoration: BoxDecoration(
          //image: DecorationImage(image: AssetImage('asset/img/chat.jpg'))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //chatlist
              ChatList(
                senderName: widget.senderName, 
                senderId: widget.senderId,
                receiverName: widget.receiverName, 
                receiverId: widget.receiverID,
              ),
        
        
              //show image here
              chatServiceController.file != null ?
              //image (remove sizedbox later)
              InkWell(
                onLongPress: (){
                  //set file content to null or cancel image picker from picking file
                  setState(() {
                    chatServiceController.file = null;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 0.h, //25.h
                    horizontal: 10.w  //20.h
                  ),
                  child: SizedBox(
                    height: 400.h,
                    width: double.infinity,
                    child: Card(
                      color: AppTheme().darkGreyColor,
                      semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0.r),
                      ),
                      elevation: 2,
                      child: chatServiceController.isContentImage && chatServiceController.isAnyImageSelected
                      ?Image.file(
                        errorBuilder: (context, url, error) => Icon(
                          Icons.error,
                          color: AppTheme().lightestOpacityBlue,
                        ),
                        chatServiceController.file!,
                        filterQuality: FilterQuality.high,
                        fit: BoxFit.cover, //.contain,
                        width: 65.w,
                        height: 80.h,
                      ) 
                      :SizedBox(), //show content as video
                    ),
                  ),
                ),
              )
              : SizedBox(),
              
              chatServiceController.isRecording ?
              Center(
                child: StreamBuilder<RecordingDisposition>(
                  stream: chatServiceController.recorder.onProgress,
                  builder: (context, snapshot) {
                    final duration = snapshot.hasData ? snapshot.data!.duration : Duration.zero;
                    String twoDigits (int n) => n.toString().padLeft(2, '0');
                    final twoDigitsMinutes =  twoDigits(duration.inMinutes.remainder(60));
                    final twoDigitsSeconds =  twoDigits(duration.inSeconds.remainder(60));

                    return Container(
                      height: 30.h,
                      width: 60.w, //140.w
                      padding: EdgeInsets.symmetric(
                        vertical: 0.h, //0.h
                        horizontal: 5.w  //10.w
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme().lightestOpacityBlue,
                        borderRadius: BorderRadius.circular(30.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 0.1.r,
                            blurRadius: 8.0.r,
                          )
                        ],
                      ),
                      child: Text(
                        '$twoDigitsMinutes:$twoDigitsSeconds',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            color: AppTheme().blackColor,
                            fontWeight: FontWeight.normal,
                            fontSize: 11.sp, //12.sp
                            overflow: TextOverflow.ellipsis
                          )
                        )
                      ),
                    
                    );
                  }
                ),
              ) : SizedBox(),
              //bottom textfield
              Padding(
                padding: EdgeInsets.only(
                  bottom: calculateBottomPadding(context)
                ),
                child: BottomEngine(
                  receiverName: widget.receiverName, 
                  receiverId: widget.receiverID, 
                  receiverPhoto: widget.receiverProfilePic, 
                  chatTextController: chatServiceController.chatTextController, 
                  receiverFCMToken: widget.receiverFCMToken,
                ),
              ),
              //give it small height
              SizedBox(height: 2.h,)
            ],
          ),
        )   
      ),   
    );
  }
}
