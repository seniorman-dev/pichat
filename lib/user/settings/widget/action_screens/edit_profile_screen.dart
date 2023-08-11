import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pichat/auth/controller/auth_controller.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/settings/controller/profile_controller.dart';
import 'package:pichat/user/settings/widget/helper_widgets/upload_photo_bottom_sheet.dart';
import 'package:pichat/utils/loader.dart';
import 'package:pichat/utils/toast.dart';
import 'package:provider/provider.dart';
import '../success_screens/successful_profile_update_screen.dart';










class EditProfileScreen extends StatefulWidget {
  EditProfileScreen({super.key, required this.isProfileUpdated, required this.name, required this.email, required this.photo, required this.dateOfBirth, required this.bio, required this.link,});
  final String name;
  final String email;
  final String photo;
  final String dateOfBirth;
  final String bio;
  final String link;
  final bool isProfileUpdated;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {


  @override
  Widget build(BuildContext context) {

    var profileController = Provider.of<ProfileController>(context);

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
            widget.isProfileUpdated ? 'Edit Profile' : 'Update Profile'
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

    var controller = Provider.of<ProfileController>(context);
    var authController = Provider.of<AuthController>(context);
    //check Date
    String checkDate = widget.isProfileUpdated ? widget.dateOfBirth : 'Select Date';
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 25.w,
        vertical: 20.h,
      ),
      child: Form(
        key: controller.formKey,
        autovalidateMode: AutovalidateMode.always,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 20.h),

            //////photo circle avatar
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 55.r,
                    backgroundColor: AppTheme().mainColor,
                    child: CircleAvatar(
                      radius: 53.r,
                      backgroundColor: controller.isAnyImageSelected ? AppTheme().blackColor : AppTheme().blackColor,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10.r)), //.circular(20.r),
                        clipBehavior: Clip.antiAlias, //.antiAliasWithSaveLayer,
                        child: controller.isAnyImageSelected 
                        ? Image.file(
                            errorBuilder: (context, url, error) => Icon(
                              Icons.error,
                              color: AppTheme().lightestOpacityBlue,
                            ),
                            controller.imageFromGallery!,
                            filterQuality: FilterQuality.high,
                            fit: BoxFit.cover, //.contain,
                            width: 65.w,
                            height: 80.h,
                          )
                        : CachedNetworkImage(
                            imageUrl: widget.photo,
                            width: 65.w,
                            height: 80.h,
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
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: FloatingActionButton.small(
                      enableFeedback: true,
                      elevation: 0,
                      backgroundColor: AppTheme().mainColor,
                      child: Icon(
                        size: 24.r,
                        CupertinoIcons.camera_fill, //camera_alt,
                        color: AppTheme().whiteColor,
                      ),
                      onPressed: () {
                        //Open bottom sheet to select image
                        takePhotoBottomSheet(
                          context: context, 
                          onPressedForCamera: () {
                            pickImageFromCamera(context: context);
                          }, 
                          onPressedForGallery: () {
                            pickImageFromGallery(context: context);
                          }, 
                          onPressedForSavingImage: () {
                            if(controller.isAnyImageSelected) {
                              controller.isImageSelectedFromGallery 
                              ? controller.uploadImageToFirebaseStorage(imageFile: controller.imageFromGallery!).whenComplete(() => Get.back()) 
                              : controller.uploadImageToFirebaseStorage(imageFile: controller.imageFromCamera!).whenComplete(() => Get.back());
                            }
                            else {
                              getToast(context: context, text: 'No image was selected');
                            }
                            
                          }
                        );

                      },
                    ),
                  ),
                ],
              ),
            ),
            ///////////////////////////////
          
            SizedBox(height: 40.h,),

            //name field
            Text(
              //posts
              'Name',
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
                borderRadius: BorderRadius.circular(20.r),
                color: AppTheme().lightGreyColor
              ),
              alignment: Alignment.centerLeft,
              height: 68.h, //70.h,
              padding: EdgeInsets.all(10),
              //width: 100.w,
              child: Text(
                widget.name,
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    color: AppTheme().blackColor,
                    fontSize: 13.sp
                  )
                ),
              ),
            ),

            SizedBox(height: 20.h,),

            //email field
            Text(
              //posts
              'Email Address',
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
                borderRadius: BorderRadius.circular(20.r),
                color: AppTheme().lightGreyColor
              ),
              alignment: Alignment.centerLeft,
              height: 68.h, //70.h,
              padding: EdgeInsets.all(10),
              //width: 100.w,
              child: Text(
                widget.email,
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    color: AppTheme().blackColor,
                    fontSize: 13.sp
                  )
                ),
              ),
            ),

            SizedBox(height: 20.h),

            //bio field
            Text(
              //posts
              'Biography',
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
              alignment: Alignment.center,
              //height: 65.h, //55.h,
              //padding: EdgeInsets.all(8),
              //width: 100.w,
              child: TextFormField(
                focusNode: controller.focusNodes[2],
                onEditingComplete: () {
                  FocusScope.of(context).requestFocus(controller.focusNodes[2]);
                },
                controller: controller.userBio,
                spellCheckConfiguration: SpellCheckConfiguration(),
                scrollPadding: EdgeInsets.symmetric(
                  horizontal: 10.h,
                  vertical: 5.h
                ),  //20        
                scrollPhysics: const BouncingScrollPhysics(),
                scrollController: ScrollController(),
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next, //.newline,
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
                  hintText: 'Biography',
                  hintStyle: GoogleFonts.poppins(color: AppTheme().darkGreyColor, fontSize: 13.sp),              
                  filled: true,
                  fillColor: AppTheme().lightGreyColor,
                  //prefixIcon: Icon(CupertinoIcons.search, color: AppTheme().blackColor,)
                ),
                validator: (value) {
                  //https://www.t.ng
                  if(value!.isEmpty ) {
                    return "Empty field";
                  }
                  if(value.characters.length < 16) {
                    return 'Bio is too short';
                  }
                  return null;
                },
                //onFieldSubmitted: (value) {},
                onChanged: (value) {},
              ),
            ),

            SizedBox(height: 20.h),

            //url field
            Text(
              //posts
              'URL',
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
              alignment: Alignment.center,
              //height: 65.h, //55.h,
              //padding: EdgeInsets.all(8),
              //width: 100.w,
              child: TextFormField( 
                focusNode: controller.focusNodes[3],
                onEditingComplete: () {
                  FocusScope.of(context).requestFocus(controller.focusNodes[3]);
                },
                controller: controller.userLink,
                spellCheckConfiguration: SpellCheckConfiguration(),
                scrollPadding: EdgeInsets.symmetric(
                  horizontal: 10.h,
                  vertical: 5.w
                ),  //20        
                scrollPhysics: const BouncingScrollPhysics(),
                scrollController: ScrollController(),
                textInputAction: TextInputAction.next,
                enabled: true,
                keyboardType: TextInputType.url,
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
                  hintText: 'Paste affiliated link',
                  hintStyle: GoogleFonts.poppins(color: AppTheme().darkGreyColor, fontSize: 13.sp),              
                  filled: true,
                  fillColor: AppTheme().lightGreyColor,
                  //prefixIcon: Icon(CupertinoIcons.search, color: AppTheme().blackColor,)
                ),
                validator: (value) {
                  //https://www.t.ng
                  if(value!.isEmpty ) {
                    return 'Paste an affiliated link';
                  }
                  if(value.characters.contains('https://')) {
                    return 'Invalid Link';
                  }
                  if(value.characters.length < 16) {
                    return 'Link is too short';
                  }
                  return null;
                },
                onChanged: (value) {},
              ),
            ),

            SizedBox(height: 20.h),

            //DOB field
            Text(
              //posts
              'Date of Birth',
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
            
            //Date Picker
            InkWell(
              onTap: () async{
                var datePicked = await DatePicker.showSimpleDatePicker(
                  context,
                  //initialDate: DateTime(2023),
                  firstDate: DateTime.now(),
                  //lastDate: DateTime(2012),
                  dateFormat: "dd-MMMM-yyyy",
                  locale: DateTimePickerLocale.en_us,
                  looping: true,
                  pickerMode: DateTimePickerMode.date,
                  backgroundColor: AppTheme().whiteColor,
                  confirmText: 'OK',
                  cancelText: 'Cancel',
                  //textColor: AppTheme.opacityOfMainColor
                );

                var savedDate = "$datePicked".substring(0, 10);

                final snackBar = SnackBar(
                  backgroundColor: AppTheme().whiteColor, //.lightestOpacityBlue,
                  content: Text(
                    "Date Picked: $savedDate",
                    style: GoogleFonts.poppins(
                      color: AppTheme().blackColor
                    ),
                  )
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                debugPrint(savedDate);

                //set the state
                setState(() {
                  controller.selectedDate = savedDate;    //save 'selectedDate' to firebase
                });

                debugPrint("this is the selected date : ${controller.selectedDate}");

              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: AppTheme().lightGreyColor
                ),
                alignment: Alignment.centerLeft,
                height: 70.h, //65.h,
                padding: EdgeInsets.all(10),
                //width: 100.w,
                child: Text(
                  //widget.isProfileUpdated 
                  //? widget.dateOfBirth :
                  controller.selectedDate!.isEmpty ? checkDate : controller.selectedDate!,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: controller.selectedDate!.isEmpty ? AppTheme().darkGreyColor : AppTheme().blackColor,
                      fontSize: 13.sp
                    )
                  ),
                ),
              ),
            ),

            SizedBox(height: 50.h,),

            SizedBox(
              height: 70.h, //55.h,
              width: double.infinity,
              child: ElevatedButton( 
                onPressed: () {
                  if(controller.formKey.currentState!.validate() && widget.name.isNotEmpty && widget.email.isNotEmpty && controller.userBio.text.isNotEmpty && controller.userLink.text.isNotEmpty) {
                    ////set 'isProfileUpdated' to true and update necessary things
                    controller.updateUserProfile(
                      name: widget.name, 
                      email: widget.email, 
                      biography: controller.userBio.text, 
                      url: controller.userLink.text, 
                      dob: controller.selectedDate!, 
                      //photo: widget.photo, 
                      isProfileUpdated: true
                    ).then((value) => Get.to(() => ProfileUpdatedSuccessScreen()));
                  }
                  else {
                    final snackBar = SnackBar(
                      backgroundColor: AppTheme().whiteColor,
                      content: Text(
                        "Invalid Credentials",
                        style: GoogleFonts.poppins(
                          color: AppTheme().blackColor
                        ),
                      )
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                style: ElevatedButton.styleFrom(
                  elevation: 3,
                  backgroundColor: AppTheme().mainColor,
                  minimumSize: Size.copy(Size(100.w, 50.h)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  )
                ), 
                child: Text(
                  widget.isProfileUpdated ? 'Save' : 'Update',
                  style: TextStyle(
                    color: AppTheme().whiteColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),     
            ),      
      
            SizedBox(height: 40.h)
          ],
        ),
      )
    );
  }
  





  //////////////////////////////////////////////////////////////////////////////
  //pick image from gallery
  Future<void> pickImageFromGallery({required BuildContext context}) async {
    try {
      var profileController = Provider.of<ProfileController>(context, listen: false);
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          profileController.imageFromGallery = File(pickedImage.path);
          profileController.isImageSelectedFromGallery = true;
          profileController.isAnyImageSelected = true;
        });
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

  //pick image from camera
  Future<void> pickImageFromCamera({required BuildContext context}) async {
    try {
      var profileController = Provider.of<ProfileController>(context, listen: false);
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedImage != null) {
        setState(() {
          profileController.imageFromGallery = File(pickedImage.path);
          profileController.isImageSelectedFromGallery = false;
          profileController.isAnyImageSelected = true;
        });
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
      debugPrint("Error Pickig Image From Camera: $e");
    }
  }

}