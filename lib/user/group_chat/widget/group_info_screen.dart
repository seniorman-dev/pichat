import 'dart:io';
import 'package:Ezio/utils/snackbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Ezio/auth/controller/auth_controller.dart';
import 'package:Ezio/main_page/screen/main_page.dart';
import 'package:Ezio/theme/app_theme.dart';
import 'package:Ezio/user/group_chat/controller/group_chat_controller.dart';
import 'package:Ezio/user/group_chat/widget/add_user_to_group.dart';
import 'package:Ezio/utils/error_loader.dart';
import 'package:Ezio/utils/extract_firstname.dart';
import 'package:Ezio/utils/firestore_timestamp_formatter.dart';
import 'package:Ezio/utils/loader.dart';
import 'package:Ezio/utils/toast.dart';
import 'package:provider/provider.dart';










class GroupInfoScreen extends StatefulWidget {

  const GroupInfoScreen({super.key, required this.groupId, required this.groupName, required this.groupPhoto, required this.groupBio});
  final String groupId;
  final String groupName;
  final String groupPhoto;
  final String groupBio;

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  //pick image from gallery
  Future<void> pickImageFromGallery({required BuildContext context}) async {
    // Simulate fetching data asynchronously
    //await Future.delayed(const Duration(seconds: 2));
    try {
      var groupChatController = Provider.of<GroupChatController>(context, listen: false);
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) { 
        setState(() {
          groupChatController.updateGroupPic = File(pickedImage.path);
          groupChatController.isUpdateImageSelected = true;
        });
        debugPrint("image was picked from gallery");
        //update it sharps
        groupChatController.updateGroupPicture(groupId: widget.groupId, groupName: widget.groupName)
        .then((value) => customGetXSnackBar(title: 'Nice', subtitle: 'Image updated successfully'));
      }
      else {
        debugPrint("no image was picked from gallery");
      }
    }
    catch (e) {
      customGetXSnackBar(title: 'Uh-Oh', subtitle: 'Error picking image from gallery: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    
    final size = MediaQuery.of(context).size;
    var authController = Provider.of<AuthController>(context);
    var groupChatController = Provider.of<GroupChatController>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme().whiteColor,
        appBar: AppBar(
          backgroundColor: AppTheme().whiteColor,
          centerTitle: true,
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
          title: const Text(
            'Group Info'
          ),
          titleSpacing: 2,
          titleTextStyle: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: AppTheme().blackColor,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500
            )
          ),
          actions: [
            InkWell(
              onTap: () {
                Get.to(() =>
                  AddUserToGroup(
                    groupId: widget.groupId, 
                    groupName: widget.groupName, 
                    groupPhoto: widget.groupPhoto,
                  )
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 27.w,
                  //vertical: 20.h,
                ), 
                child: Icon(
                  CupertinoIcons.person_crop_circle_badge_plus, 
                  color: AppTheme().blackColor,
                ),
              )
            ),
          ],
        ),
        body:
            //body gan gan
            //wrap with singlechild scrollview if any
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(height: 20.h,),
                Center(
                  child: InkWell(
                    onTap: () => pickImageFromGallery(context: context),
                    onLongPress: () {
                      /*setState(() {
                        groupChatController.updateGroupPic = null;
                        groupChatController.isUpdateImageSelected = false;
                      });
                      debugPrint('image deleted');*/
                    },
                    child: CircleAvatar(
                      radius: 70.r,
                      backgroundColor: AppTheme().opacityBlue,
                      child: CircleAvatar(
                        radius: 68.r,
                        backgroundColor:AppTheme().blackColor,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(10.r)), //.circular(20.r),
                          clipBehavior: Clip.antiAlias, //.antiAliasWithSaveLayer,
                          child: CachedNetworkImage(
                            imageUrl: widget.groupPhoto,
                            width: 90.w,
                            height: 90.h,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Loader(),
                            errorWidget: (context, url, error) => Icon(
                              Icons.error,
                              color: AppTheme().lightestOpacityBlue,
                            ),
                          ),
                        ) 
                      ),       
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Center(
                  child: Text(
                    widget.groupName,
                    style: GoogleFonts.poppins(
                      color: AppTheme().blackColor,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      textStyle: TextStyle(
                        overflow: TextOverflow.visible
                      )
                    ),
                  ),
                ),

                SizedBox(height: 10.h,),

                //GROUP DESCRIPTION
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 20.h, //0.h
                    horizontal: 25.w  //15.w
                  ),
                  child: TextFormField(
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        color: AppTheme().greyColor, //.blackColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500
                      )
                    ),
                    initialValue: widget.groupBio,
                    spellCheckConfiguration: SpellCheckConfiguration(),
                    scrollPadding: EdgeInsets.symmetric(
                      horizontal: 10.h,
                      vertical: 5.h
                    ), //20        
                    scrollPhysics: const BouncingScrollPhysics(),
                    scrollController: ScrollController(),
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    enabled: true,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 10,
                    autocorrect: true,
                    enableSuggestions: true,
                    enableInteractiveSelection: true,
                    cursorColor: AppTheme().blackColor,
                    cursorRadius: Radius.circular(10.r),
                    decoration: InputDecoration(        
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.r),
                        borderSide: BorderSide.none
                      ),       
                      hintText: 'Group Description',
                      hintStyle: GoogleFonts.poppins(color: AppTheme().greyColor, fontSize: 14.sp,),              
                      filled: true,
                      fillColor: AppTheme().lightGreyColor,
                      suffixIcon: InkWell(
                        onTap: () {
                          groupChatController.updateGroupBio(groupId: widget.groupId,)
                          .then((value) => debugPrint('group description updated'));
                        },
                        child: Icon(
                          CupertinoIcons.share_solid,
                          //size: 35.r, 
                          color: AppTheme().blackColor,
                        )
                      )
                    ),            
                    onChanged: (value) {
                      groupChatController.groupBioController.text = value;
                    }
                  ),
                ),
                       
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 25.w,
                    vertical: 10.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Participants",
                        style: GoogleFonts.poppins(
                          color: AppTheme().blackColor,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      //total number of members
                      StreamBuilder(
                        stream: groupChatController.groupMembersStream(groupId: widget.groupId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Text(
                              "...",
                              style: GoogleFonts.poppins(
                                color: AppTheme().mainColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500
                              ),
                            );
                          } 
                          else if (snapshot.hasError) {
                            return Text(
                              "...",
                              style: GoogleFonts.poppins(
                                color: AppTheme().redColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500
                              ),
                            );
                          }
                          else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Text(
                              "0",
                              style: GoogleFonts.poppins(
                                color: AppTheme().mainColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500
                              ),
                            );                  
                          }
                          int totalParticipants = snapshot.data!.docs.length;
                          return Text(
                            "$totalParticipants",
                            style: GoogleFonts.poppins(
                              color: AppTheme().greyColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500
                            ),
                          );
                        }
                      ),
                    ],
                  ),
                ), 

                //SizedBox(height: 10.h,),

                //members stream
                StreamBuilder(
                  stream: groupChatController.groupMembersStream(groupId: widget.groupId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Show a loading indicator while waiting for data
                      return const Loader();
                    } 
                    else if (snapshot.hasError) {
                      // Handle error if any
                      return const ErrorLoader();
                    }
                    else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {                  
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 25.w,
                          vertical: 20.h,
                        ),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            //mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 210.h,),
                              CircleAvatar(
                                radius: 100.r,
                                backgroundColor: AppTheme().lightestOpacityBlue,
                                child: Icon(
                                  CupertinoIcons.person_crop_circle_badge_exclam,
                                  color: AppTheme().mainColor,
                                  size: 70.r,
                                ),
                              ),
                              SizedBox(height: 50.h),
                              Text(
                                "No members found",
                                style: GoogleFonts.poppins(
                                  color: AppTheme().greyColor,
                                  fontSize: 14.sp,
                                  //fontWeight: FontWeight.w500
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }               
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      //padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
                      separatorBuilder: (context, index) => SizedBox(width: 10.w),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {    

                        var data = snapshot.data!.docs[index];
                        return Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          background: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                CupertinoIcons.delete_simple,
                                color: AppTheme().redColor                     
                              ),
                              SizedBox(width: 20.w,),
                            ]
                          ),
                          onDismissed: (direction) {
                            if(data['memberType'] == 'Admin') {
                              groupChatController.removeFriendFromGroupChat(
                                groupId: widget.groupId, 
                                friendId: data['memberId']
                              )
                              .then((value) 
                                
                              => customGetXSnackBar(title: 'Removal', subtitle: 'you removed ${data['memberName']}')
                            );
                            }
                            else {
                              customGetXSnackBar(title: 'Uh-Oh', subtitle: 'only admin can remove members');
                            }
                          },
                          child: InkWell(
                            onTap: () {    
                              //remove pop up to show more about user        
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 25.w,
                                vertical: 20.h,
                              ),
                              child: Container(
                                /*padding: EdgeInsets.symmetric(
                                  vertical: 20.h, //20.h
                                  horizontal: 15.w  //15.h
                                ),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: AppTheme().whiteColor,
                                  borderRadius: BorderRadius.circular(30.r), //20.r
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 0.1.r,
                                      blurRadius: 8.0.r,
                                    )
                                  ],
                                ),*/
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 40.r,
                                      backgroundColor: AppTheme().opacityBlue,
                                      child: CircleAvatar(
                                      radius: 38.r,
                                      backgroundColor: data['memberPhoto'] == null ? AppTheme().darkGreyColor : AppTheme().blackColor,
                                      child: data['memberPhoto'] != null
                                      ?ClipRRect(
                                        borderRadius: BorderRadius.all(Radius.circular(10.r)), //.circular(20.r),
                                        clipBehavior: Clip.antiAlias, //.antiAliasWithSaveLayer,
                                        child: CachedNetworkImage(
                                          imageUrl: data['memberPhoto'],
                                          width: 50.w,
                                          height: 50.h,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Loader(),
                                          errorWidget: (context, url, error) => Icon(
                                            Icons.error,
                                            color: AppTheme().lightestOpacityBlue,
                                          ),
                                        ),
                                      ) : null
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        //SizedBox(height: 10.h),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              getFirstName(fullName: data['memberName'],),
                                              style: GoogleFonts.poppins(
                                                color: AppTheme().blackColor,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                                textStyle: TextStyle(
                                                  overflow: TextOverflow.ellipsis
                                                )
                                              ),
                                            ),
                                            data['memberType'] == 'Admin' 
                                            ?Text(
                                              data['memberType'],
                                              style: GoogleFonts.poppins(
                                                color: AppTheme().mainColor,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w500,
                                                textStyle: TextStyle(
                                                  overflow: TextOverflow.ellipsis
                                                )
                                              ),
                                            )
                                            :SizedBox(),
                                          ],
                                        ),
                                        SizedBox(height: 5.h),
                                        Text(
                                          data['memberEmail'],
                                          style: GoogleFonts.poppins(
                                            color: AppTheme().greyColor,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.normal,
                                            //fontWeight: FontWeight.w500,
                                            textStyle: TextStyle(
                                              overflow: TextOverflow.ellipsis
                                            )
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),         
                          ),
                        ),
                        );              
                      }                                      
                    );    
                  }            
                ),
                SizedBox(height: 10.h),
                GestureDetector(
                  onTap: () {
                    //exit group
                    groupChatController.exitFromGroupChat(groupId: widget.groupId)
                    .then((value) => Get.offAll(() => MainPage()));
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 25.w,
                      vertical: 20.h,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        color: AppTheme().opacityBlue
                      ),
                      alignment: Alignment.centerLeft,
                      height: 68.h, //68.h,
                      //width: 100.w,
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(CupertinoIcons.delete_right_fill, color: AppTheme().blackColor,),
                          SizedBox(width: 13.w,),                    
                          Text(
                            'Exit Group',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                color: AppTheme().blackColor,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                overflow: TextOverflow.visible
                              )
                            ),
                          ),                         
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h,),
                
                //creation date
                /*StreamBuilder(
                  stream: groupChatController.createdAt(groupId: groupId),
                  builder: (context, snapshot) {
                    var data = snapshot.data!.data();
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Text(
                          '...',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              color: AppTheme().greyColor,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.normal,
                              overflow: TextOverflow.visible
                            )
                          ),
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return Center(
                        child: Text(
                          '...',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              color: AppTheme().opacityBlue,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.normal,
                              overflow: TextOverflow.visible
                            )
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          '...',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              color: AppTheme().redColor,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.normal,
                              overflow: TextOverflow.visible
                            )
                          ),
                        ),
                      );
                    }
                    if(snapshot.hasData){
                      if(data != null) {           
                        return Center(
                          child: Text(
                            'Created ${formatDate(timestamp: data['createdAt'])}',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                color: AppTheme().greyColor,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.normal,
                                overflow: TextOverflow.visible
                              )
                            ),
                          ),
                        );
                      }
                      else {
                        return Center(
                        child: Text(
                          'Data not found',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              color: AppTheme().blackColor,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.normal,
                              overflow: TextOverflow.visible
                            )
                          ),
                        ),
                      );
                      }
                    }
                    return SizedBox();
                  }
                ),*/
              
                SizedBox(
                  height: 5.h,
                )
                /////////////
              ],
            ),
      ),
    );
  }
}
