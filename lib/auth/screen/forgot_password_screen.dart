import 'package:Ezio/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Ezio/auth/controller/auth_controller.dart';
import 'package:Ezio/auth/screen/login_screen.dart';
import 'package:Ezio/auth/screen/successful_reset_password.dart';
import 'package:Ezio/auth/widget/textfield.dart';
import 'package:Ezio/theme/app_theme.dart';
import 'package:Ezio/utils/elevated_button.dart';
import 'package:Ezio/utils/loader.dart';
import 'package:provider/provider.dart';









class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<AuthController>(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme().whiteColor,
        //appBar: CustomAppBar(title: 'Created Events'),
        body: controller.isLoading ? const Loader() : SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          controller: controller.scrollControllerForLogin,
          child: buildBody(context),
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    
    //final size = MediaQuery.of(context).size;
    var controller = Provider.of<AuthController>(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 25.w,
        vertical: 20.h,
      ),
      child: Form(
        key: GlobalKey<FormState>(),//controller.formkeyForLogin,
        child: FocusScope(
          node: controller.focusScopeNodesForLogin,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 150.h,),
              Text(
                'Forgot Password?',
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
              EmailFieldResetPassword(
                textController: controller.resetPasswordController, 
                onSaved: (val) {
                  //controller.loginEmailController.text = val!;
                }, 
                hintText: 'johndoe@example.com', 
                onEditingComplete: () {
                  controller.focusScopeNodesForLogin.nextFocus();
                }, 
                //validator: controller.validateEmail
              ),
              SizedBox(height: 50.h),
              CustomElevatedButton(
                text: 'Reset Password', 
                onPressed: () {
                  if(controller.resetPasswordController.text.isEmpty) {
                    customGetXSnackBar(title: 'Error', subtitle: 'Invalid Credentials');
                  }
                  else {
                    controller.resetPassword()
                    .then((value) => const SuccessfulResetScreen());
                  }
                },
              ),
              SizedBox(height: 20.h,),
              //already have account?
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Have an account?",
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
                      Get.to(() => const LoginScreen());
                    }, 
                  )
                ],
              ),
              SizedBox(height: 20.h,)
            ]
          ),
        ),
      ),
    );
  }
}





