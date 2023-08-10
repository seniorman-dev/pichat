
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/settings/controller/profile_controller.dart';
import 'package:pichat/utils/error_loader.dart';
import 'package:pichat/utils/firestore_timestamp_formatter.dart';
import 'package:pichat/utils/loader.dart';
import 'package:provider/provider.dart';










class EditProfileScreen extends StatefulWidget {
  EditProfileScreen({super.key, required this.isProfileUpdated, required this.name, required this.email, required this.photo, required this.dateOfBirth,});
  final String name;
  final String email;
  final String photo;
  final String dateOfBirth;
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
          title: const Text(
            'Edit Profile'
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
            //photo circle avatar
            InkWell(
              onTap: () {
                //open bottom sheet
              },
              child: Center(
                child: CircleAvatar(
                  radius: 50.r,
                  backgroundColor: AppTheme().mainColor,
                  child: CircleAvatar(
                    radius: 48.r,
                    backgroundColor: AppTheme().darkGreyColor,
                  ),
                ),
              ),
            ),
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
                borderRadius: BorderRadius.circular(20.r)
              ),
              alignment: Alignment.center,
              height: 55.h,
              //padding: EdgeInsets.all(8),
              //width: 100.w,
              child: TextFormField(
                spellCheckConfiguration: SpellCheckConfiguration(),
                scrollPadding: EdgeInsets.symmetric(
                  horizontal: 10.h,
                  vertical: 5.w
                ),  //20        
                scrollPhysics: const BouncingScrollPhysics(),
                scrollController: ScrollController(),
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                enabled: true,
                initialValue: widget.name,
                keyboardType: TextInputType.name,
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
                  hintText: 'Full name',
                  hintStyle: GoogleFonts.poppins(color: AppTheme().darkGreyColor, fontSize: 13.sp),              
                  filled: true,
                  fillColor: AppTheme().lightGreyColor,
                  //prefixIcon: Icon(CupertinoIcons.search, color: AppTheme().blackColor,)
                ),
                validator: (value) {
                  //https://www.t.ng
                  if(value!.isEmpty ) {
                    return 'Enter you full name';
                  }
                  if(value.characters.length < 6) {
                    return 'Name is too short';
                  }
                  return null;
                },
                onChanged: (value) {},
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
                borderRadius: BorderRadius.circular(20.r)
              ),
              alignment: Alignment.center,
              height: 55.h,
              //padding: EdgeInsets.all(8),
              //width: 100.w,
              child: TextFormField(
                spellCheckConfiguration: SpellCheckConfiguration(),
                scrollPadding: EdgeInsets.symmetric(
                  horizontal: 10.h,
                  vertical: 5.w
                ),  //20        
                scrollPhysics: const BouncingScrollPhysics(),
                scrollController: ScrollController(),
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                enabled: true,
                initialValue: widget.email,
                keyboardType: TextInputType.emailAddress,
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
                  hintText: 'Email Address',
                  hintStyle: GoogleFonts.poppins(color: AppTheme().darkGreyColor, fontSize: 13.sp),              
                  filled: true,
                  fillColor: AppTheme().lightGreyColor,
                  //prefixIcon: Icon(CupertinoIcons.search, color: AppTheme().blackColor,)
                ),
                validator: (value) {
                  //https://www.t.ng
                  if(value!.isEmpty ) {
                    return 'Enter your valid email address';
                  }
                  if(value.characters.length < 10) {
                    return 'Invalid link';
                  }
                  return null;
                },
                onChanged: (value) {},
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
              height: 55.h,
              //padding: EdgeInsets.all(8),
              //width: 100.w,
              child: TextFormField(
                controller: controller.userBio,
                spellCheckConfiguration: SpellCheckConfiguration(),
                scrollPadding: EdgeInsets.symmetric(
                  horizontal: 10.h,
                  vertical: 5.w
                ),  //20        
                scrollPhysics: const BouncingScrollPhysics(),
                scrollController: ScrollController(),
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
                enabled: true,
                keyboardType: TextInputType.text,
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
                  hintText: 'Brief Biography',
                  hintStyle: GoogleFonts.poppins(color: AppTheme().darkGreyColor, fontSize: 13.sp),              
                  filled: true,
                  fillColor: AppTheme().lightGreyColor,
                  //prefixIcon: Icon(CupertinoIcons.search, color: AppTheme().blackColor,)
                ),
                validator: (value) {
                  //https://www.t.ng
                  if(value!.isEmpty ) {
                    return "a little brief about yourself wouldn't hurt";
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
              height: 55.h,
              //padding: EdgeInsets.all(8),
              //width: 100.w,
              child: TextFormField(
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
                  hintText: 'Paste URL',
                  hintStyle: GoogleFonts.poppins(color: AppTheme().darkGreyColor, fontSize: 13.sp),              
                  filled: true,
                  fillColor: AppTheme().lightGreyColor,
                  //prefixIcon: Icon(CupertinoIcons.search, color: AppTheme().blackColor,)
                ),
                validator: (value) {
                  //https://www.t.ng
                  if(value!.isEmpty ) {
                    return 'Paste a link to any of your socials';
                  }
                  if(value.characters.length < 16) {
                    return 'Invalid link';
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
                  backgroundColor: AppTheme().lightestOpacityBlue,
                  content: Text(
                    "Date Picked: $savedDate",
                    style: TextStyle(
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
                height: 55.h,
                padding: EdgeInsets.all(10),
                //width: 100.w,
                child: Text(
                  //widget.dateOfBirth,
                  controller.selectedDate!.isEmpty ? 'Select Date' : controller.selectedDate!,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: controller.selectedDate!.isEmpty ? AppTheme().darkGreyColor : AppTheme().blackColor,
                      fontSize: 13.sp
                    )
                  ),
                ),
              ),
            ),

            SizedBox(height: 40.h,),

            SizedBox(
              height: 65.h, //55.h,
              width: double.infinity,
              child: ElevatedButton( 
                onPressed: () {
                  if(/*controller.formKey.currentState!., && widget.photo.isNtEmpty &&*/  controller.selectedDate!.isNotEmpty && controller.userBio.text.isNotEmpty && controller.userLink.text.isNotEmpty) {
                    ////set 'update profile' to true and update necessary things
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
                  widget.isProfileUpdated ? 'Edit Profile' : 'Update Profile',
                  style: TextStyle(
                    color: AppTheme().whiteColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),     
            ),      
      
            SizedBox(height: 20.w)
          ],
        ),
      )
    );
  }
}