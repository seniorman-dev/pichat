import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/feeds/controller/feeds_controller.dart';
import 'package:pichat/user/settings/controller/profile_controller.dart';
import 'package:provider/provider.dart';






class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key, required this.onPressedForSavingEveryThing,});
  final VoidCallback onPressedForSavingEveryThing;


  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme().whiteColor,
        appBar: AppBar(
          backgroundColor: AppTheme().whiteColor,
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded),
            color: AppTheme().blackColor,
            onPressed: () {
              Get.back();
            },
          ),
          title: Text(
            'Update Post'
          ),
          titleSpacing: 2,
          titleTextStyle: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: AppTheme().blackColor,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500
            )
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: buildBody(context),
        )
      ),
    );
  }


  Widget buildBody(BuildContext context) {

    var profileController = Provider.of<ProfileController>(context);
    var feedsController = Provider.of<FeedsController>(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 25.w,
        vertical: 20.h,
      ),
      child: Form(
        key: feedsController.formKey,
        autovalidateMode: AutovalidateMode.always,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 70.h),  //80.h

            //image (remove sizedbox later)
            SizedBox(
              height: feedsController.contentFile != null ? MediaQuery.of(context).size.height : null,
              width: feedsController.contentFile != null ? MediaQuery.of(context).size.width : null,  //double.infinity,
              child: Card(
                color: AppTheme().darkGreyColor,
                semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0.r),
                ),
                elevation: 2,
                child: feedsController.isContentImage && feedsController.isAnyImageSelected
                ?Image.file(
                  errorBuilder: (context, url, error) => Icon(
                    Icons.error,
                    color: AppTheme().lightestOpacityBlue,
                  ),
                  feedsController.contentFile!,
                  filterQuality: FilterQuality.high,
                  fit: BoxFit.cover, //.contain,
                  width: 65.w,
                  height: 80.h,
                ) 
                :SizedBox(), //show content as video
              ),
            ),
            SizedBox(height: 30.h,),   

            //textfield
            Container(
              //color: Colors.white,
              //semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
                //shape: RoundedRectangleBorder(
                //borderRadius: BorderRadius.circular(10.0),
              //),
              //elevation: 2,
              decoration: BoxDecoration(
                color: AppTheme().whiteColor,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 0.1.r,
                    blurRadius: 8.0.r,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[                 
                  SizedBox(height: 10.h,),
                  /////TextField///////////
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 20.h
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r)
                      ),
                      alignment: Alignment.center,
                      //height: 65.h, //55.h,
                      child: TextFormField(
                        autofocus: true,
                        controller: feedsController.postTextController,
                        spellCheckConfiguration: SpellCheckConfiguration(),
                        scrollPadding: EdgeInsets.symmetric(
                          horizontal: 10.h,
                          vertical: 5.h
                        ),  //20        
                        scrollPhysics: const BouncingScrollPhysics(),
                        scrollController: ScrollController(),
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        enabled: true,
                        keyboardType: TextInputType.multiline,
                        autocorrect: true,
                        enableSuggestions: true,
                        enableInteractiveSelection: true,
                        cursorColor: AppTheme().blackColor,
                        cursorRadius: Radius.circular(10.r),
                        style: GoogleFonts.poppins(color: AppTheme().blackColor),
                        decoration: InputDecoration(        
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.r),
                            borderSide: BorderSide.none
                          ),       
                          hintText: 'What do you have to say?',
                          hintStyle: GoogleFonts.poppins(color: AppTheme().darkGreyColor, fontSize: 13.sp, fontStyle: FontStyle.italic),              
                          filled: true,
                          fillColor: AppTheme().lightGreyColor,
                          //prefixIcon: Icon(CupertinoIcons.search, color: AppTheme().blackColor,)
                        ),
                        /*validator: (value) {
                          if(value!.isEmpty ) {
                            return "Empty field";
                          }      
                          return null;
                        },*/
                        onChanged: (value) {},
                      ),
                    ),
                  ),
                  //row for the two buttons
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 20.h
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            //width: 100,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                pickVideoFromGallery(context: context,);
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15.0.r))
                                ),
                                side: BorderSide(
                                  color: AppTheme().mainColor,
                                  style: BorderStyle.solid
                                ),
                                backgroundColor: AppTheme().whiteColor,
                                foregroundColor: AppTheme().whiteColor,
                                minimumSize:const Size(double.infinity, 50)
                              ),
                              label: Text(
                                "Video",
                                style: TextStyle(
                                  color: AppTheme().mainColor,
                                  fontSize: 15.sp,
                                ),
                              ), 
                              icon: Icon(
                                CupertinoIcons.videocam,
                                color: AppTheme().mainColor,
                                //size: 30.r
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20.h,
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            //width: 100,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                pickImageFromGallery(context: context,);
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15.0.r)
                                  )
                                ),
                                side: BorderSide(
                                  color: AppTheme().mainColor,
                                    style: BorderStyle.solid
                                  ),
                                  backgroundColor: AppTheme().mainColor,
                                  foregroundColor: AppTheme().mainColor,
                                  minimumSize:const Size(double.infinity, 50)
                                ),
                                label: Text(
                                  "Image",
                                  style: TextStyle(
                                    color: AppTheme().whiteColor,
                                    fontSize: 15.sp,
                                  ),
                                ),
                                icon: Icon(
                                  CupertinoIcons.camera,
                                  color: AppTheme().whiteColor,
                                  //size: 30.r
                                ),
                              ),
                            ),
                          ),
                        ]
                      ),
                    ),
                  ]
                )
              ),
                  
            SizedBox(height: 50.h),

            SizedBox(
              height: 70.h,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme().mainColor,
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  minimumSize: Size.copy(
                    Size(100.w, 55.h),
                  ),
                  maximumSize: Size.copy(
                    Size(100.w, 55.h),
                  ),
                ),
                onPressed: widget.onPressedForSavingEveryThing,
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: AppTheme().whiteColor,
                    fontWeight: FontWeight.w500,  //.bold,
                    fontSize: 16.sp
                  ),
                ),
              ),
            ),
            SizedBox(height: 100.h)
          ]
        )
      )
    );
  }


  //////////////////////////////////////////////////////////////////////////////
  //pick image from gallery
  Future<void> pickImageFromGallery({required BuildContext context}) async {
    // Simulate fetching data asynchronously
    //await Future.delayed(const Duration(seconds: 2));
    try {
      var feedsController = Provider.of<FeedsController>(context, listen: false);
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) { 
        setState(() {
          feedsController.contentFile = File(pickedImage.path);
          feedsController.isImageSelectedFromGallery = true;
          feedsController.isAnyImageSelected = true;
          feedsController.isContentImage = true;
        });
        debugPrint("image was picked from gallery");
      }
      else {
        debugPrint("no image was picked from gallery");
      }
    }
    catch (e) {
      final snackBar = SnackBar(
        backgroundColor: AppTheme().whiteColor, //.lightestOpacityBlue,
        content: Text(
          "Error: $e",
          style: GoogleFonts.poppins(
            color: AppTheme().blackColor
          ),
        )
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      debugPrint("Error Pickig Image From Gallery: $e");
    }
  }

  //pick image from gallery
  Future<void> pickVideoFromGallery({required BuildContext context,}) async {
    // Simulate fetching data asynchronously
    //await Future.delayed(const Duration(seconds: 2));
    try {
      var feedsController = Provider.of<FeedsController>(context, listen: false);
      final pickedVideo = await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (pickedVideo != null) { 
        setState(() {
          feedsController.contentFile = File(pickedVideo.path);
          feedsController.isImageSelectedFromGallery = false;
          feedsController.isAnyImageSelected = false;
          feedsController.isContentImage = false;
        });
        debugPrint('video was picked from gallery');
      }
      else {
        debugPrint("no video was picked from gallery");
      }
    }
    catch (e) {
      final snackBar = SnackBar(
        backgroundColor: AppTheme().whiteColor, //.lightestOpacityBlue,
        content: Text(
          "Error: $e",
          style: GoogleFonts.poppins(
            color: AppTheme().blackColor
          ),
        )
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      debugPrint("Error Pickig Image From Gallery: $e");
    }
  }
}