import 'package:Ezio/user/group_chat/agora/video/video_call_group.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Ezio/theme/app_theme.dart';
import 'package:Ezio/user/group_chat/controller/group_chat_controller.dart';
import 'package:Ezio/user/group_chat/widget/group_info_screen.dart';
import 'package:Ezio/user/group_chat/widget/bottom_engine_for_group.dart';
import 'package:Ezio/user/group_chat/widget/chat_list_for_group.dart';
import 'package:Ezio/utils/extract_firstname.dart';
import 'package:Ezio/utils/loader.dart';
import 'package:provider/provider.dart';








class GroupMessagingScreen extends StatefulWidget {
  const GroupMessagingScreen({super.key, required this.groupName, required this.groupId, required this.groupPhoto, required this.groupBio,});
  final String groupName;
  final String groupId;
  final String groupPhoto;
  final String groupBio;

  @override
  State<GroupMessagingScreen> createState() => _GroupMessagingScreenState();
}

class _GroupMessagingScreenState extends State<GroupMessagingScreen> with WidgetsBindingObserver{
  
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
    var groupChatController = Provider.of<GroupChatController>(context);
    
    return SafeArea(
      child: Scaffold(
        //resizeToAvoidBottomInset: true,
        backgroundColor: AppTheme().whiteColor,//.lightGreyColor,
        appBar: AppBar(
          toolbarHeight: 90.h, //80.h,
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
                  backgroundColor: widget.groupPhoto == null ? AppTheme().darkGreyColor : AppTheme().blackColor,
                  //backgroundColor: AppTheme().darkGreyColor,
                  child: widget.groupPhoto == null 
                  ?null
                  :ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10.r)), //.circular(20.r),
                    clipBehavior: Clip.antiAlias, //.antiAliasWithSaveLayer,
                    child: CachedNetworkImage(
                      imageUrl: widget.groupPhoto,
                      width: 40.w,
                      height: 40.h,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Loader(),
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
                    SizedBox(height: 150.h,),
                    //group name
                    Text(
                      widget.groupName,
                      style: GoogleFonts.poppins(
                        color: AppTheme().blackColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500
                      ),
                    ),

                    //SizedBox(height: 2.h,),

                    //names of group members
                    StreamBuilder(
                      stream: groupChatController.groupMembersStream(groupId: widget.groupId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          // Show a loading indicator while waiting for data
                          return Text(
                            '...',
                            style: GoogleFonts.poppins(
                              color: AppTheme().mainColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              textStyle: const TextStyle(
                                overflow: TextOverflow.ellipsis
                              )
                            ),
                          );
                        } 
                        if (snapshot.hasError) {
                          // Handle error if any
                          return Text(
                            '...',
                            style: GoogleFonts.poppins(
                              color: AppTheme().redColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              textStyle: const TextStyle(
                                overflow: TextOverflow.ellipsis
                              )
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Text(
                            '...',
                            style: GoogleFonts.poppins(
                              color: AppTheme().greyColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              textStyle: const TextStyle(
                                overflow: TextOverflow.ellipsis
                              )
                            ),
                          );        
                        }
                        ////////
                        return SizedBox(
                          height: 180.h, //200.h
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal, //Axis.vertical,
                            //padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
                            separatorBuilder: (context, index) {
                              return Text(
                                ', ',
                                style: GoogleFonts.poppins(
                                  color: AppTheme().greyColor,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  textStyle: const TextStyle(
                                    overflow: TextOverflow.ellipsis
                                  )
                                ),
                              );
                            },
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var data = snapshot.data!.docs[index];
                              return Text(
                                getFirstName(fullName: data['memberName'],),
                                style: GoogleFonts.poppins(
                                  color: AppTheme().greyColor,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  textStyle: const TextStyle(
                                    overflow: TextOverflow.ellipsis
                                  )
                                ),
                              );
                            }
                          ),
                        );
                      }
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
              onPressed: () async{
                Get.to(() => ChatVideoCallGroup(groupName: widget.groupName, groupProfilePic: widget.groupPhoto, groupId: widget.groupId,));
              },
            ),
            /*IconButton(
              icon: Icon(
                CupertinoIcons.phone_down,
                color: AppTheme().blackColor,
                size: 24.r,
              ),
              onPressed: () {},
            ),*/
            IconButton(
              icon: Icon(
                Icons.info_outline_rounded,
                color: AppTheme().blackColor,
                size: 24.r,
              ),
              onPressed: () {
                Get.to(() => GroupInfoScreen(
                  groupId: widget.groupId, 
                  groupBio: widget.groupBio, 
                  groupName: widget.groupName, 
                  groupPhoto: widget.groupPhoto,
                ));
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
              //groupchat list
              GroupChatList(
                groupId: widget.groupId,
                groupName: widget.groupName, 
                groupPhoto: widget.groupPhoto,       
              ),
        
              //show image here
              groupChatController.isAnyImageSelectedForChat ?
              //image (remove sizedbox later)
              InkWell(
                onLongPress: (){
                  //set file content to null or cancel image picker from picking file
                  setState(() {
                    groupChatController.contentFile = null;
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
                      child: groupChatController.isContentImageForChat && groupChatController.isAnyImageSelectedForChat
                      ?Image.file(
                        errorBuilder: (context, url, error) => Icon(
                          Icons.error,
                          color: AppTheme().lightestOpacityBlue,
                        ),
                        groupChatController.contentFile!,
                        filterQuality: FilterQuality.high,
                        fit: BoxFit.cover, //.contain,
                        width: 65.w,
                        height: 80.h,
                      ) 
                      :const SizedBox(), //show content as video
                    ),
                  ),
                ),
              )
              : const SizedBox(),
              
        
              //bottom textfield
              Padding(
                padding: EdgeInsets.only(
                  bottom: calculateBottomPadding(context)
                ),
                child: BottomEngineForGroup(             
                  chatTextController: groupChatController.messageTextController, 
                  groupId: widget.groupId, 
                  groupName: widget.groupName, 
                  groupPhoto: widget.groupPhoto,
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