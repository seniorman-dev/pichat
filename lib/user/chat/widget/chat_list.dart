import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/auth/controller/auth_controller.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/chat/controller/chat_service_controller.dart';
import 'package:pichat/utils/error_loader.dart';
import 'package:pichat/utils/extract_firstname.dart';
import 'package:pichat/utils/firestore_timestamp_formatter.dart';
import 'package:pichat/utils/loader.dart';
import 'package:provider/provider.dart';











class ChatList extends StatefulWidget {
  const ChatList({super.key, required this.senderName, required this.receiverName, required this.receiverId, required this.senderId});
  final String senderName;
  final String senderId;
  final String receiverName;
  final String receiverId;

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

    //provider for dependency injection
    var authController = Provider.of<AuthController>(context);
    var chatServiceController = Provider.of<ChatServiceController>(context);
    
    return Expanded(
      child: StreamBuilder(
        stream: chatServiceController.firestore.collection('users')
        .doc(chatServiceController.auth.currentUser!.uid)
        .collection('recent_chats')
        .doc(widget.receiverId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while waiting for data
            return const Loader();
          } 
          if (snapshot.hasError) {
            // Handle error if any
            return const ErrorLoader();
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 25.w,
                vertical: 20.h,
              ),
              child: SizedBox(
                child: Center(
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 150.h,),
                      CircleAvatar(
                        radius: 100.r,
                        backgroundColor: AppTheme().lightestOpacityBlue,
                          child: Icon(
                          CupertinoIcons.text_bubble,
                          color: AppTheme().mainColor,
                          size: 70.r,
                        ),
                      ),
                      SizedBox(height: 30.h),
                      Text(
                        "Start a conversation with ${getFirstName(fullName: widget.receiverName)} 😊",
                        style: GoogleFonts.poppins(
                          color: AppTheme().greyColor,
                          fontSize: 14.sp,
                          //fontWeight: FontWeight.w500
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
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
              controller: messageController,
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              separatorBuilder: (context, index) => SizedBox(height: 10.h,), 
              itemCount: snapshot.data!.docs.length,
              itemBuilder: 
                (context, index, ) {
      
                          //leave this stuff hear to avoid crashing
                //it makes the messages list automatically scroll up after a message has been sent
                /*SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                  messageController.jumpTo(messageController.position.maxScrollExtent);
                });*/
                
                var data = snapshot.data!.docs[index];
      
                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.startToEnd,
                  onDismissed: (direction) => chatServiceController.deleteDirectMessages(messageId: data['messageId'], receiverId: widget.receiverId),
                  child: InkWell(
                    onLongPress: () {
                      //show message info or message statistics alert dialog
                    },
                    child: Column(
                      crossAxisAlignment: data['senderId'] == authController.userID ? CrossAxisAlignment.end : CrossAxisAlignment.start,  ///tweak this instead to suit the chatters
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
                            color: data['senderId'] == authController.userID ? AppTheme().mainColor : AppTheme().lightGreyColor,  ///tweak this instead to suit the chatters
                            borderRadius: BorderRadius.circular(20.r),
                            /*data['senderId'] == authController.userID 
                            ? BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r), bottomLeft: Radius.circular(20.r))
                            : BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r), bottomRight: Radius.circular(20.r))
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                //color: AppTheme().lightGreyColor,
                                spreadRadius: 0.1.r,
                                blurRadius: 8.0.r,
                              )
                            ],*/
                          ),
                          child: Text(
                            data['message'],
                            style: GoogleFonts.poppins(  //urbanist
                              color: data['senderId'] == authController.userID ? AppTheme().whiteColor : AppTheme().blackColor,  //tweak this instead to suit the chatters
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
                          mainAxisAlignment: data['senderId'] == authController.userID ? MainAxisAlignment.end : MainAxisAlignment.start,  //tweak this also
                          children: [
                
                            Text(
                              "${formatDate(timestamp: data['timestamp'])} - ${formatTime(timestamp: data['timestamp'])}",
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                textStyle: const TextStyle(
                                  overflow: TextOverflow.ellipsis
                                )
                              ),
                            ),
                
                            //SizedBox(width: 3.w,),
                
                            /*data['isSeen'] && data['senderId'] == authController.userID
                            ?Icon(
                              Icons.done_all_rounded,
                              color: Colors.grey,
                            )
                            : SizedBox()
                            const Icon(
                              CupertinoIcons.checkmark_alt,
                              color: Colors.grey,
                            ),*/
                
                          ],
                        )
                      ],
                    ),
                  ),
                );
              } 
      
            ),
          );
        }
      ),
    );
  }
}