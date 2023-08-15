import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/chat/controller/chat_service_controller.dart';
import 'package:provider/provider.dart';







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

  @override
  Widget build(BuildContext context) {

    var chatServiceController = Provider.of<ChatServiceController>(context);


    //only send messages when there is something to send
    void sendMessage() {
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

    void sendPictureOrVideo() {
      
      //then send the intended message
      chatServiceController.sendPictureOrVideoWithOrWithoutAText(
      receiverId: widget.receiverId, 
      receiverName: widget.receiverName, 
      receiverPhoto: widget.receiverPhoto, 
      message: chatServiceController.chatTextController.text, 
      file: chatServiceController.file  
      )
      .then((value) => chatServiceController.makeKeyboardDisappear());
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
              onPressed: () {},
            ),
            SizedBox(width: 5.w,),
            VerticalDivider(color: AppTheme().darkGreyColor,thickness: 1,),
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
                CupertinoIcons.location_north_line_fill
              ),
              onPressed: () {
                if(chatServiceController.file == null) {
                  sendMessage();
                }
                else{
                  sendPictureOrVideo();
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
}




