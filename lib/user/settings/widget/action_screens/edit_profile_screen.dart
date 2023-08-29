import 'dart:io';
import 'package:Ezio/utils/snackbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Ezio/auth/controller/auth_controller.dart';
import 'package:Ezio/theme/app_theme.dart';
import 'package:Ezio/user/settings/controller/profile_controller.dart';
import 'package:Ezio/user/settings/widget/helper_widgets/upload_photo_bottom_sheet.dart';
import 'package:Ezio/utils/loader.dart';
import 'package:provider/provider.dart';
import '../success_screens/successful_profile_update_screen.dart';










class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.isProfileUpdated, required this.name, required this.email, required this.photo, required this.dateOfBirth, required this.bio, required this.link, required this.selectedCountry, required this.selectedGender,});
  final String name;
  final String email;
  final String photo;
  final String dateOfBirth;
  final String bio;
  final String link;
  final bool isProfileUpdated;
  final String selectedCountry;
  final String selectedGender;


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
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
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
          controller: profileController.scrollController,
          child: buildBody(context),
        )
      ),
    );
  }

  Widget buildBody(BuildContext context) {

    var controller = Provider.of<ProfileController>(context);
    var authController = Provider.of<AuthController>(context);
    //check if date is already selected
    String checkDate = widget.isProfileUpdated ? widget.dateOfBirth : 'Select Date';
    //check if country is selected
    String checkCountry = widget.isProfileUpdated ? widget.selectedCountry : 'Select Country';
    //check if gender is selected
    //String checkGender = widget.isProfileUpdated ? widget.selectedGender : 'Select Gender';
    var profileController = Provider.of<ProfileController>(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 25.w,
        vertical: 20.h,
      ),
      child: Form(
        key: controller.formKey,
        autovalidateMode: AutovalidateMode.always,
        child: FocusScope(
          node: controller.focusScopeNode,
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
                      radius: 70.r,
                      backgroundColor: AppTheme().opacityBlue,
                      child: CircleAvatar(
                        radius: 68.r,
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
                              controller.isImageSelectedFromGallery ? controller.imageFromGallery! : controller.imageFromCamera!,
                              filterQuality: FilterQuality.high,
                              fit: BoxFit.cover, //.contain,
                              width: 80.w,
                              height: 90.h,
                            )
                          : CachedNetworkImage(
                              imageUrl: widget.photo,
                              width: 90.w,
                              height: 90.h,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Loader(),
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
                        elevation: 2,
                        backgroundColor: AppTheme().whiteColor,
                        child: Icon(
                          size: 24.r,
                          CupertinoIcons.camera_fill, //camera_alt,
                          color: AppTheme().blackColor,
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
                                customGetXSnackBar(title: 'Uh-Oh', subtitle: 'No image was selected');
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
                height: 70.h, //70.h,
                padding: const EdgeInsets.all(16),
                //width: 100.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(CupertinoIcons.person, color: AppTheme().blackColor,),
                    SizedBox(width: 13.w,),
                    Text(
                      widget.name,
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: AppTheme().blackColor,
                          fontSize: 13.sp
                        )
                      ),
                    ),
                  ],
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
                height: 70.h, //70.h,
                padding: const EdgeInsets.all(16),
                //width: 100.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(CupertinoIcons.envelope, color: AppTheme().blackColor,),
                    SizedBox(width: 13.w,),
                    Text(
                      widget.email,
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: AppTheme().blackColor,
                          fontSize: 13.sp
                        )
                      ),
                    ),
                  ],
                ),
              ),
        
              SizedBox(height: 20.h),
              
              //Select Gender
              Text(
                //posts
                'Gender',
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
              //Select Gender
              Row(
                children: [
                  //male radio widget
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        color: AppTheme().lightGreyColor
                      ),
                      alignment: Alignment.center,
                      height: 74.h, //68.h,
                      //padding: EdgeInsets.all(10),
                      //width: 100.w,
                      child: RadioListTile(
                        enableFeedback: true,
                        toggleable: true,
                        tileColor: AppTheme().lightGreyColor,
                        activeColor: AppTheme().blackColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0.r)
                          )
                        ),
                        value:  'Male',
                        groupValue: controller.gender,
                        onChanged: (value) {
                          setState(() {
                            controller.gender = value; //.toString();
                            controller.isActivated = true;
                          });
                  
                          debugPrint("User selected $value");
                        },
                        title: Text(
                          'Male',
                          style: GoogleFonts.poppins(
                            color: AppTheme().blackColor,
                            fontSize: 15.sp,
                            //fontWeight: FontWeight.w500,
                          ),
                        ),
                      )             
                    ),
                  ),
        
                  SizedBox(width: 15.w,),
        
                  //female radio widget
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        color: AppTheme().lightGreyColor
                      ),
                      alignment: Alignment.center,
                      height: 74.h, //68.h,
                      //padding: EdgeInsets.all(15),
                      //width: 100.w,
                      child: RadioListTile(
                        enableFeedback: true,
                        toggleable: true,
                        tileColor: AppTheme().lightGreyColor,
                        activeColor: AppTheme().blackColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0.r)
                          )
                        ),
                        value: 'Female', 
                        groupValue: controller.gender, 
                        onChanged: (value) {
                          setState(() {
                            controller.gender = value;
                            controller.isActivated = true;
                          });
                          debugPrint("User selected $value");
                        },
                        title: Text(
                          'Female',
                          style: GoogleFonts.poppins(
                            color: AppTheme().blackColor,
                            fontSize: 15.sp,
                            //fontWeight: FontWeight.w500,
                          ),
                        ),
                      )             
                    ),
                  ),
        
                ],
              ),
        
              SizedBox(height: 20.h,),
        
              //country///////////
              Text(
                //posts
                'Country',
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
                height: 70.h, //70.h,
                //padding: EdgeInsets.all(8),
                //width: 100.w,
                child: Row(
                  children: [
                    CountryCodePicker(
                      flagDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      enabled: true,
                      showFlagDialog: true,
                      showFlagMain: true,
                      showFlag: true,
                      textStyle: GoogleFonts.poppins(),
                      onChanged: (CountryCode countryCode) {
                        setState(() {
                          controller.selectedCountryCode = countryCode;
                          controller.selectedCountry = controller.selectedCountryCode!.name;
                        });
                        debugPrint('Country Selected: ${controller.selectedCountry}');
                      },
                      initialSelection: 'NG', // You can set an initial country code
                      favorite: const ['NG'], // Specify favorite country codes
                      showCountryOnly: false, // Set to true to show only the country name
                      showOnlyCountryWhenClosed: false, // Set to true to only show the country when closed
                    ),
                    SizedBox(width: 10.w,),
                    controller.selectedCountryCode == null ?
                    Text(
                      checkCountry,
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: AppTheme().blackColor,
                          fontSize: 15.sp
                        )
                      ),
                    )
                    :Text(
                      '${controller.selectedCountryCode!.name}',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: AppTheme().blackColor,
                          fontSize: 15.sp
                        )
                      ),
                    ),
                  ],
                ),
              ),
              //////////////////////////////
              
              SizedBox(height: 20.h,),
        
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
                //height: 70.h, //55.h,
                //padding: EdgeInsets.all(8),
                //width: 100.w,
                child: TextFormField(
                  //autofocus: true,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: AppTheme().blackColor,
                      fontSize: 13.sp
                    )
                  ),
                  initialValue: widget.bio,
                  spellCheckConfiguration: const SpellCheckConfiguration(),      
                  scrollPhysics: const BouncingScrollPhysics(),
                  //scrollController: profileController.scrollController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next, 
                  enabled: true,
                  keyboardType: TextInputType.multiline,
                  autocorrect: true,
                  enableSuggestions: true,
                  enableInteractiveSelection: true,
                  cursorColor: AppTheme().blackColor,
                  cursorRadius: Radius.circular(10.r),
                  //style: GoogleFonts.poppins(color: AppTheme().blackColor),
                  decoration: InputDecoration(        
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      borderSide: BorderSide.none
                    ),       
                    hintText: 'Biography',
                    hintStyle: GoogleFonts.poppins(color: AppTheme().darkGreyColor, fontSize: 13.sp),              
                    filled: true,
                    fillColor: AppTheme().lightGreyColor,
                    prefixIcon: Icon(CupertinoIcons.person, color: AppTheme().blackColor,)
                  ),
                  validator: (value) {
                    if(value!.isEmpty ) {
                      return "Empty field";
                    }
                    if(value.characters.length < 16) {
                      return 'Bio is too short';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    controller.userBio.text = value;
                  },
                  onEditingComplete: () {
                    controller.focusScopeNode.nextFocus();
                  },
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
                //height: 70.h, //55.h,
                //padding: EdgeInsets.all(8),
                //width: 100.w,
                child: TextFormField(
                  //autofocus: true,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: AppTheme().blackColor,
                      fontSize: 13.sp
                    )
                  ),
                  initialValue: widget.link,
                  spellCheckConfiguration: const SpellCheckConfiguration(),        
                  scrollPhysics: const BouncingScrollPhysics(),
                  //scrollController: profileController.scrollController,
                  textInputAction: TextInputAction.done,
                  enabled: true,
                  keyboardType: TextInputType.url,
                  autocorrect: true,
                  enableSuggestions: true,
                  enableInteractiveSelection: true,
                  cursorColor: AppTheme().blackColor,
                  cursorRadius: Radius.circular(10.r),
                  //style: GoogleFonts.poppins(color: AppTheme().blackColor),
                  decoration: InputDecoration(        
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      borderSide: BorderSide.none
                    ),       
                    hintText: 'Paste affiliated link',
                    hintStyle: GoogleFonts.poppins(color: AppTheme().darkGreyColor, fontSize: 13.sp),              
                    filled: true,
                    fillColor: AppTheme().lightGreyColor,
                    prefixIcon: Icon(CupertinoIcons.link, color: AppTheme().blackColor,)
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
                  onChanged: (value) {
                    controller.userLink.text = value;
                  },
                  onEditingComplete: () {
                    controller.focusScopeNode.nextFocus();
                  },
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
                    firstDate: DateTime(1950), //DateTime.now(),
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
                  padding: const EdgeInsets.all(10),
                  //width: 100.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(CupertinoIcons.calendar, color: AppTheme().blackColor,),
                      SizedBox(width: 13.w,),
                      Text(
                        //widget.isProfileUpdated 
                        //? widget.dateOfBirth :
                        controller.selectedDate!.isEmpty ? checkDate : controller.selectedDate!,
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            color: controller.selectedDate!.isEmpty ? AppTheme().greyColor : AppTheme().blackColor,
                            fontSize: 13.sp
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        
              SizedBox(height: 50.h,),
        
              SizedBox(
                height: 70.h, //55.h,
                width: double.infinity,
                child: ElevatedButton( 
                  onPressed: () {
                    if(controller.formKey.currentState!.validate()) {
                      controller.formKey.currentState!.save();
                      controller.updateUserProfile(
                        name: widget.name, 
                        email: widget.email, 
                        biography: controller.userBio.text, 
                        url: controller.userLink.text, 
                        dob: controller.selectedDate!,
                        gender: controller.gender!,
                        isProfileUpdated: true, 
                        context: context
                      ).then((value) => Get.to(() => const ProfileUpdatedSuccessScreen()));
                    }
                    else {
                      customGetXSnackBar(title: 'Uh-Oh', subtitle: 'Invalid Credentials');
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
              
              SizedBox(height: 50.h)
            ],
          ),
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
          profileController.imageFromCamera = File(pickedImage.path);
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