
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/auth/controller/auth_controller.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/chat/controller/chat_service_controller.dart';
import 'package:pichat/user/chat/widget/audio/audio_player_widget.dart';
import 'package:pichat/user/chat/widget/video/video_player_widget.dart';
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

  /*final ScrollController messageController = ScrollController();*/


  

  @override
  Widget build(BuildContext context) {

    //provider for dependency injection
    var authController = Provider.of<AuthController>(context);
    var chatServiceController = Provider.of<ChatServiceController>(context);
    //bool _shouldAutoScroll = true;
    
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

          //it makes messages list automatically scroll up after a message has been sent
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
            chatServiceController.messageController.jumpTo(chatServiceController.messageController.position.maxScrollExtent);
          });


          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 15.w, //15.w
              vertical: 5.h  //20.h
            ),
            child: ListView.separated(
              /*padding: EdgeInsets.symmetric(
                horizontal: 10.w, //20.w
                vertical: 10.h  //20.h
              ),*/
              controller: chatServiceController.messageController,
              //keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              separatorBuilder: (context, index) => SizedBox(height: 10.h,), 
              itemCount: snapshot.data!.docs.length,
              itemBuilder: 
                (context, index, ) {
                
                var data = snapshot.data!.docs[index];
                
                //to check if message is seen
                bool isSeen = data['isSeen'] ?? false; // Default to false if not present;
                
                // Check if the current message's date is different from the previous message's date
                bool showDateHeader = true;
                if (index > 0) {
                  var previousData = snapshot.data!.docs[index - 1];
                  var currentDate = formatDate(timestamp: data['timestamp']);
                  var previousDate = formatDate(timestamp: previousData['timestamp']);
                  showDateHeader = currentDate != previousDate;
                  chatServiceController.markMessageAsSeen(messageId: data['messageId'], receiverId: widget.receiverId);
                }
                
          
                return Dismissible(
                  key: UniqueKey(),
                  direction: data['senderId'] == authController.userID ? DismissDirection.endToStart : DismissDirection.endToStart,
                  onDismissed: (direction) => chatServiceController.deleteDirectMessages(messageId: data['messageId'], receiverId: widget.receiverId),
                  background: Row(
                    mainAxisAlignment: data['senderId'] == authController.userID ? MainAxisAlignment.end : MainAxisAlignment.end,
                    children: [
                      Icon(
                        CupertinoIcons.delete_simple,
                        color: AppTheme().redColor                     
                      )
                    ]
                  ),
                  child: InkWell(
                    /*onTap: () {
                      chatServiceController.markMessageAsSeen(messageId: data['messageId'], receiverId: widget.receiverId);
                    },*/
                    onLongPress: () {
                      //show message info or message statistics alert dialog
                    },
                    child: Column(
                      crossAxisAlignment: data['senderId'] == authController.userID ? CrossAxisAlignment.end : CrossAxisAlignment.start,  ///tweak this instead to suit the chatters
                      children: [
                          
                        // Show the date header if needed
                        if (showDateHeader)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 30.h, 
                                horizontal: 120.w
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                height: 30.h,
                                //width: 150.w,
                                padding: EdgeInsets.symmetric(
                                  //vertical: 0.h, //20.h
                                  horizontal: 5.w  //15.h
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme().lightGreyColor,
                                  borderRadius: BorderRadius.circular(10.r),
                                  /*boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      //color: AppTheme().lightGreyColor,
                                      spreadRadius: 0.1.r,
                                      blurRadius: 8.0.r,
                                    )
                                  ],*/
                                ),
                                child: Text(
                                  formatDate(timestamp: data['timestamp']),
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        
                        //the real container gan gan
                        Container(
                          alignment: Alignment.bottomLeft,
                          //height: 80.h,
                          width: 225.w,
                          padding: data['messageType'] == 'image' || data['messageType'] == 'video' 
                          ?EdgeInsets.symmetric(
                            vertical: 1.h,
                            horizontal: 1.w
                          )
                          :EdgeInsets.symmetric(
                            vertical: 10.h, //15.h
                            horizontal: 10.w  //15.h
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
                          child: Column(
                            children: [
                              data['messageType'] == 'text' ?
                              Text(
                                data['message'],
                                style: GoogleFonts.poppins(  //urbanist
                                  color: data['senderId'] == authController.userID ? AppTheme().whiteColor : AppTheme().blackColor,  //tweak this instead to suit the chatters
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                  textStyle: TextStyle(
                                    overflow: TextOverflow.visible
                                  )
                                ),
                              )
                              :data['messageType'] == 'image' ?
                              SizedBox(
                                height: 300.h,
                                width: 240.w,//MediaQuery.of(context).size.width, //double.infinity,
                                child: Card(
                                  color: AppTheme().lightGreyColor,
                                  semanticContainer: true,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0.r), //20.r
                                  ),
                                  elevation: 0,
                                  child: CachedNetworkImage(
                                    imageUrl: data['image'],
                                    //width: 50.w,
                                    //height: 50.h,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Loader(),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.error,
                                      color: AppTheme().lightestOpacityBlue,
                                    ),
                                  ),
                                ),
                              )
                              //implement video player widget (VideoPlayerWidget)
                              :data['video'] == 'video' ?
                              VideoPlayerItem(videoUrl: data['video']) 
                              //Substitute for audio widget
                              : AudioWidget(senderId: data['senderId'],),
                              SizedBox(height: 3.h,),
                              data['messageType'] == 'image' || data['messageType'] == 'video'
                              ?
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 10.h
                                ),
                                child: Text(
                                  data['message'],
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.poppins(  //urbanist
                                    color: data['senderId'] == authController.userID ? AppTheme().whiteColor : AppTheme().blackColor,  //tweak this instead to suit the chatters
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500,
                                    textStyle: TextStyle(
                                      overflow: TextOverflow.visible
                                    )
                                  ),
                                ),
                              )
                              : SizedBox()
                            ],
                          )  
                        ),
                        SizedBox(height: 5.h,),
          
                        
                        //Time and isSeen icon feature
                        Row(
                          mainAxisAlignment: data['senderId'] == authController.userID ? MainAxisAlignment.end : MainAxisAlignment.start,  //tweak this also
                          children: [
                
                            Text(
                              formatTime(timestamp: data['timestamp']),
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                textStyle: const TextStyle(
                                  overflow: TextOverflow.ellipsis
                                )
                              ),
                            ),
                
                            SizedBox(width: 3.w,),
                            
                            // Display ticks based on the 'isSeen' status
                            if(data['senderId'] == authController.userID)
                              isSeen
                              ?Icon(
                                Icons.done_all_rounded,
                                color: Colors.grey,
                                size: 20.r,
                              )
                              :Icon(
                                CupertinoIcons.checkmark_alt,
                                color: Colors.grey,
                                size: 20.r,
                              ),
                
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