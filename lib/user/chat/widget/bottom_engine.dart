import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/chat/controller/chat_service_controller.dart';
import 'package:provider/provider.dart';







class BottomEngine extends StatelessWidget {
  BottomEngine({super.key, required this.receiverName, required this.receiverId, required this.receiverPhoto});
  final String receiverName;
  final String receiverId;
  final String receiverPhoto;
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    var controller = Provider.of<ChatServiceController>(context);
    GlobalKey globalKey = GlobalKey();

    FocusNode focusNode = FocusNode(); //for keyboard

    //only send messages when there is something to send
    void sendMessage() async{
      if(textController.text.isNotEmpty) {
        //send message
        controller.sendDirectMessages(
          receiverId: receiverId, 
          receiverName: receiverName, 
          receiverPhoto: receiverPhoto, 
          message: textController.text
        )
        //.then((val) => textController.clear())
        .then((value) => controller.makeKeyboardDisappear());
        textController.clear();
      }
    }

    void showKeyboard() {
      focusNode.requestFocus();
    }

    void hideKeyboard() {
      focusNode.unfocus();
    }
    
    //wrap with positioned
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 20.h, //20.h
        horizontal: 25.w  //20.h
      ),
      child: Container(
        alignment: Alignment.center,
        height: 60.h, //80.h
        //width: 400.w,
        padding: EdgeInsets.symmetric(
          vertical: 2.h, //10.h
          horizontal: 15.w  //15.h
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
                onTap: ()async{
                  await Future.delayed(const Duration(milliseconds: 500));
                  Scrollable.ensureVisible(globalKey.currentContext!, duration: const Duration(milliseconds: 500));
                },       
                scrollPhysics: const BouncingScrollPhysics(),
                scrollController: ScrollController(),
                textInputAction: TextInputAction.newline,
                textCapitalization: TextCapitalization.sentences,
                focusNode: focusNode,
                minLines: 1,
                maxLines: 8,
                enabled: true,
                controller: textController,
                keyboardType: TextInputType.multiline,
                autocorrect: true,
                enableSuggestions: true,
                enableInteractiveSelection: true,
                cursorColor: AppTheme().blackColor,
                style: GoogleFonts.poppins(color: AppTheme().blackColor),
                decoration: InputDecoration(        
                  border: InputBorder.none,        
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.poppins(color: AppTheme().darkGreyColor, fontSize: 13.sp),              
                )
              ),
            ),
            SizedBox(width: 5.w,),
            IconButton(
              icon: const Icon(
                CupertinoIcons.location_north_line_fill
              ),
              onPressed: () => sendMessage(),
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




