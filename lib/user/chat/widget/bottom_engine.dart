import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/chat/controller/chat_service_controller.dart';
import 'package:provider/provider.dart';







class BottomEngine extends StatelessWidget {
  BottomEngine({super.key, required this.receiverName});
  final String receiverName;
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    var controller = Provider.of<ChatServiceController>(context);
    //only send messages when there is something to send
    void sendMessage() async{
      if(textController.text.isNotEmpty) {
        //send message
        //controller.sendMessage(receiverName: receiverName, message: textController.text)
        //.whenComplete(() => textController.clear());
        //clear textcontroller after sending message
      }
    }
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 20.h, //20.h
        horizontal: 25.w  //20.h
      ),
      child: Container(
        alignment: Alignment.center,
        height: 80.h,
        //width: 400.w,
        padding: EdgeInsets.symmetric(
          vertical: 10.h, //30.h
          horizontal: 15.w  //20.h
        ),
        decoration: BoxDecoration(
          color: AppTheme().whiteColor,
          borderRadius: BorderRadius.circular(30.r),
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
              icon: Icon(
                CupertinoIcons.link
              ),
              onPressed: () {},
              //iconSize: 30.r, 
              color: AppTheme().blackColor,
            ),
            SizedBox(width: 5.w,),
            VerticalDivider(color: AppTheme().darkGreyColor,thickness: 1,),
            SizedBox(width: 5.w,),
            Expanded(
              child: TextFormField(          
                scrollPhysics: BouncingScrollPhysics(),
                scrollController: ScrollController(),
                textInputAction: TextInputAction.newline,
                enabled: true,
                controller: textController,
                keyboardType: TextInputType.text,
                autocorrect: true,
                enableSuggestions: true,
                enableInteractiveSelection: true,
                cursorColor: AppTheme().blackColor,
                style: GoogleFonts.poppins(color: AppTheme().blackColor),
                decoration: InputDecoration(        
                  border: InputBorder.none,        
                  hintText: 'Type message...',
                  hintStyle: GoogleFonts.poppins(color: AppTheme().darkGreyColor, fontSize: 13.sp),              
                )
              ),
            ),
            SizedBox(width: 5.w,),
            IconButton(
              icon: Icon(
                CupertinoIcons.location_circle_fill
              ),
              onPressed: () {},
              iconSize: 40.r, 
              color: AppTheme().mainColor,
            ),
            //SizedBox(width: 5.w,),
          ]
        ),
      ),
    );
  }
}