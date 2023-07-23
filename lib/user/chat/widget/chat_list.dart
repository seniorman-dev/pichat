import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/theme/app_theme.dart';






class ChatList extends StatefulWidget {
  const ChatList({super.key, required this.senderName, required this.receiverName});
  final String senderName;
  final String receiverName;

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {

    //it makes messages list automatically scroll up after a message has been sent
    final ScrollController messageController = ScrollController();
    @override
    void dispose() {
      // TODO: implement dispose
      messageController.dispose();
      super.dispose();
    }

    //it makes messages list automatically scroll up after a message has been sent
    /*SchedulerBinding.instance.addPersistentFrameCallback((timeStamp) {
      messageController.jumpTo(messageController.position.maxScrollExtent);
    });*/
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 15.w, //20.w
        vertical: 5.h  //20.h
      ),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: 10.w, //20.w
          vertical: 10.h  //20.h
        ),
        //controller: messageController,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        separatorBuilder: (context, index) => SizedBox(height: 10.h,), 
        itemCount: 10,
        itemBuilder: (context, index) {
          return InkWell(
            onLongPress: () {
              //show message info or message statistics alert dialog
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,  ///tweak this instead to suit the chatters
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  //height: 80.h,
                  width: 200.w,
                  padding: EdgeInsets.symmetric(
                    vertical: 15.h, //20.h
                    horizontal: 15.w  //15.h
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme().mainColor,  ///tweak this instead to suit the chatters
                    borderRadius: BorderRadius.circular(20.r),  ///tweak this instead to suit the chatters
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        //color: AppTheme().lightGreyColor,
                        spreadRadius: 0.1.r,
                        blurRadius: 8.0.r,
                      )
                    ],
                  ),
                  child: Text(
                    'New Chat',
                    style: GoogleFonts.poppins(
                      color: AppTheme().whiteColor,  //tweak this instead to suit the chatters
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                        /*textStyle: TextStyle(
                          overflow: TextOverflow.ellipsis
                        )*/
                    ),
                  ),
                ),
                SizedBox(height: 5.h,),
                //Time and isSeen icon feature
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,  //tweak this also
                  children: [
                    Text(
                      '12:09',
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        textStyle: TextStyle(
                          overflow: TextOverflow.ellipsis
                        )
                      ),
                    ),
                    SizedBox(width: 3.w,),
                    /*Icon(
                      Icons.done_all_rounded,
                      color: Colors.grey,
                    ),*/
                    Icon(
                      CupertinoIcons.checkmark_alt,
                      color: Colors.grey,
                    ),
                  ],
                )
              ],
            ),
          );
        }     
      ),
    );
  }
}