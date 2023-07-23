import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/auth/controller/auth_controller.dart';
import 'package:pichat/auth/screen/login_screen.dart';
import 'package:pichat/auth/widget/textfield.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/utils/elevated_button.dart';
import 'package:pichat/utils/loader.dart';
import 'package:provider/provider.dart';








class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<AuthController>(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme().whiteColor,
        //appBar: CustomAppBar(title: 'Created Events'),
        body: controller.isLoading ? Loader() : SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: buildBody(context),
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var controller = Provider.of<AuthController>(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 25.w,
        vertical: 20.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.h,),
          Text(
            'Create  Account',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                color: AppTheme().blackColor,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold               
              )
            ),
          ),
          SizedBox(height: 50.h),
          Text(
            'Your Full Name',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                color: AppTheme().blackColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.bold //.w500               
              )
            ),
          ),
          SizedBox(height: 10.h,),
          CustomTextField4(
            textController: controller.registerNameController, 
            onSaved: (val) {
              controller.registerNameController.text = val!;
            }, 
            hintText: 'e.g John Doe', 
          ),
          SizedBox(height: 20.h),
          Text(
            'Your Email',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                color: AppTheme().blackColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.bold //.w500               
              )
            ),
          ),
          SizedBox(height: 10.h,),
          CustomTextField(
            textController: controller.registerEmailController, 
            onSaved: (val) {
              controller.registerEmailController.text = val!;
            }, 
            hintText: 'johndoe@example.com', 
            validator: controller.validateEmail
          ),
          SizedBox(height: 20.h),
          Text(
            'Password',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                color: AppTheme().blackColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.bold //.w500               
              )
            ),
          ),
          SizedBox(height: 10.h,),
          CustomTextField2(
            textController: controller.registerPasswordController, 
            onSaved: (val) {
              controller.registerPasswordController.text = val!;
            }, 
            hintText: 'enter your password', 
          ),
          SizedBox(height: 20.h),
          Text(
            'Confirm Password',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                color: AppTheme().blackColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.bold //.w500               
              )
            ),
          ),
          SizedBox(height: 10.h,),
          CustomTextField3(
            textController: controller.registerConfirmPasswordController, 
            onSaved: (val) {
              controller.registerConfirmPasswordController.text = val!;
            }, 
            hintText: 'confirm your password', 
          ),
          SizedBox(height: 30.h),
          //terms and condition check box
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Checkbox(
                //mouseCursor: MouseCursor.uncontrolled,
                checkColor: AppTheme().whiteColor,
                activeColor: AppTheme().mainColor,
                value: controller.isChecked,
                shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.circular(3.r)
                ),
                side: BorderSide(
                  color: AppTheme().darkGreyColor
                ), 
                onChanged: (value) {
                  setState(() {
                    controller.isChecked = value!;
                  });
                  debugPrint("${controller.isChecked}");
                }
              ),
              Text(
                'I agree to the Terms & Conditions \nand Privacy Policy',
                style: GoogleFonts.poppins(
                  color: Colors.grey, //AppTheme().darkGreyColor,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
          SizedBox(height: 30.h),
          CustomElevatedButton(
            text: 'Create account', 
            onPressed: () {
              setState(() {
                controller.isLoading = true;
              });
              controller.signUp();
              setState(() {
                controller.isLoading = false;
              });
            },
          ),
          SizedBox(height: 20.h,),
          //already have account?
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account?',
                style: GoogleFonts.poppins(
                  color: Colors.grey, //AppTheme().darkGreyColor,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500
                ),
              ),
              SizedBox(width: 2.w,),
              TextButton(
                child: Text(
                  'Login',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: AppTheme().mainColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                      decoration: TextDecoration.underline
                    ),
                  ),
                ),
                onPressed: () {
                  Get.offAll(() => LoginScreen());
                }, 
              )
            ],
          ),
          SizedBox(height: 20.h,)
        ]
      ),
    );
  }
}


