import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/group_chat/controller/group_chat_controller.dart';
import 'package:pichat/user/group_chat/widget/search_textfield.dart';
import 'package:pichat/utils/elevated_button.dart';
import 'package:pichat/utils/toast.dart';
import 'package:provider/provider.dart';
import 'successful_group_creation_screen.dart';









class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  @override
  Widget build(BuildContext context) {
    var groupChatController = Provider.of<GroupChatController>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme().whiteColor,
        appBar: AppBar(
          backgroundColor: AppTheme().whiteColor,
          centerTitle: true,
          elevation: 0,
          title: const Text(
            'New Group'
          ),
          titleSpacing: 2,
          titleTextStyle: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: AppTheme().blackColor,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500
            )
          ),
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
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          controller: groupChatController.createGroupScrollController,
          child: buildBody(context),
        )
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    //dependency injection
    var groupChatController = Provider.of<GroupChatController>(context, listen: false);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 25.w,
        vertical: 20.h
      ),
      child: Form(
        key: groupChatController.formKey,
        autovalidateMode: AutovalidateMode.always,
        child: Column(  //wrap with focus-scope-node and assign its 'focus' if it misbehaves on a real device
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h,),
            //camera circle avatar
            Center(
              child: InkWell(
                onTap: () {
                  pickImageFromGallery(context: context);
                },
                onLongPress: () {
                  setState(() {
                    groupChatController.file = null;
                    groupChatController.isAnyImageSelected = false;
                  });
                  debugPrint('image deleted');
                },
                child: CircleAvatar(
                  radius: 70.r,
                  backgroundColor: AppTheme().opacityBlue,
                  child: CircleAvatar(
                    radius: 68.r,
                    backgroundColor: groupChatController.isAnyImageSelected ? AppTheme().blackColor : AppTheme().whiteColor,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10.r)), //.circular(20.r),
                      clipBehavior: Clip.antiAlias, //.antiAliasWithSaveLayer,
                      child: groupChatController.isAnyImageSelected ?
                      Image.file(
                        errorBuilder: (context, url, error) => Icon(
                          Icons.error,
                            color: AppTheme().lightestOpacityBlue,
                          ),
                        groupChatController.file!,
                        filterQuality: FilterQuality.high,
                        fit: BoxFit.cover, //.contain,
                        width: 80.w,
                        height: 90.h,
                      )
                      :Icon(
                        CupertinoIcons.camera,
                        color: AppTheme().opacityBlue,
                      )      
                    ),
                  )
                ),
              ),
            ),
            SizedBox(height: 40.h,),
            Text(
              'Group Name',
              style: GoogleFonts.poppins(
                color: AppTheme().blackColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                textStyle: const TextStyle(
                  overflow: TextOverflow.ellipsis
                )
              ),
            ),
            SizedBox(height: 10.h,),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r)
              ),
              height: 65.h,
              //width: 100.w,
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,          
                scrollPhysics: const BouncingScrollPhysics(),
                //scrollController: groupChatController.createGroupScrollController, //ScrollController(),
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                enabled: true,
                controller: groupChatController.groupNameController,
                keyboardType: TextInputType.name,
                autocorrect: true,
                enableSuggestions: true,
                enableInteractiveSelection: true,
                cursorColor: AppTheme().blackColor,
                style: GoogleFonts.poppins(color: AppTheme().blackColor),
                decoration: InputDecoration(        
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    borderSide: BorderSide.none
                  ),
                  hintText: 'Enter group name',
                  hintStyle: GoogleFonts.poppins(color: AppTheme().greyColor, fontSize: 13.sp),              
                  filled: true,
                  fillColor: AppTheme().lightGreyColor,
                  prefixIcon: Icon(CupertinoIcons.person, color: AppTheme().blackColor,)
                ),
                //onFieldSubmitted: widget.onChanged,
                //onChanged: (),
              ),
            ),
            //group name text field
            SizedBox(height: 20.h,),
            Text(
              'Group Description',
              style: GoogleFonts.poppins(
                color: AppTheme().blackColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                textStyle: const TextStyle(
                  overflow: TextOverflow.ellipsis
                )
              ),
            ),
            SizedBox(height:10.h,),
            //group bio text field
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r)
              ),
              height: 65.h,
              //width: 100.w,
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,          
                scrollPhysics: const BouncingScrollPhysics(),
                //scrollController: groupChatController.createGroupScrollController, //ScrollController(),
                textInputAction: TextInputAction.newline,
                textCapitalization: TextCapitalization.sentences,
                enabled: true,
                controller: groupChatController.groupBioController,
                keyboardType: TextInputType.multiline,
                autocorrect: true,
                minLines: 1,
                maxLines: 6,
                enableSuggestions: true,
                enableInteractiveSelection: true,
                cursorColor: AppTheme().blackColor,
                style: GoogleFonts.poppins(color: AppTheme().blackColor),
                decoration: InputDecoration(        
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    borderSide: BorderSide.none
                  ),
                  hintText: "What's this group all about ?",
                  hintStyle: GoogleFonts.poppins(color: AppTheme().greyColor, fontSize: 13.sp),              
                  filled: true,
                  fillColor: AppTheme().lightGreyColor,
                  prefixIcon: Icon(CupertinoIcons.square_on_square, color: AppTheme().blackColor,)
                ),
                //onFieldSubmitted: widget.onChanged,
                //onChanged: (),
              ),
            ),
            SizedBox(height: 40.h,),
            //submit button
            CustomElevatedButton(
              text: 'Create Group', 
              onPressed: () {
                if(groupChatController.formKey.currentState!.validate() && groupChatController.groupNameController.text.isNotEmpty && groupChatController.groupBioController.text.isNotEmpty && groupChatController.file != null) {
                  groupChatController.formKey.currentState!.save();
                  groupChatController.createGroupChat(
                    groupName: groupChatController.groupNameController.text, 
                    groupBio: groupChatController.groupBioController.text, 
                  )
                  .then((value) {
                    groupChatController.groupNameController.clear();
                    groupChatController.groupBioController.clear();
                    setState(() {
                      groupChatController.isAnyImageSelected = false;
                    });
                    Get.to(() => GroupCreatedSuccessScreen());
                  });
                }
                else {
                  getToast(context: context, text: 'Incomplete credentials'); 
                }
              }
            )
          ],
        ),
      ),
    );
  }

  //pick image from gallery
  Future<void> pickImageFromGallery({required BuildContext context}) async {
    // Simulate fetching data asynchronously
    //await Future.delayed(const Duration(seconds: 2));
    try {
      var groupChatController = Provider.of<GroupChatController>(context, listen: false);
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) { 
        setState(() {
          groupChatController.file = File(pickedImage.path);
          groupChatController.isAnyImageSelected = true;
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

}
