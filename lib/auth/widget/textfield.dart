import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/auth/controller/auth_controller.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:provider/provider.dart';







//for email
class CustomTextField extends StatelessWidget {
  const CustomTextField({super.key, required this.textController, required this.onSaved, required this.hintText,});
  final TextEditingController textController;
  final void Function(String?)? onSaved;
  final String hintText;
  //final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {

    var controller = Provider.of<AuthController>(context);

    return Container(
      decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.r)
      ),
      //height: 70.h,
      width: double.infinity,
      child: TextFormField(
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            color: AppTheme().blackColor,
            fontSize: 13.sp
          )
        ),
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,          
        scrollPhysics: const BouncingScrollPhysics(),
        scrollController: ScrollController(),
        textInputAction: TextInputAction.next,
        enabled: true,
        controller: textController,
        keyboardType: TextInputType.emailAddress,
        autocorrect: true,
        enableSuggestions: true,
        enableInteractiveSelection: true,
        cursorColor: AppTheme().blackColor,
        //style: GoogleFonts.poppins(color: AppTheme().blackColor),
        decoration: InputDecoration(        
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide.none
          ),       
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(color: AppTheme().darkGreyColor, fontSize: 13.sp),              
          filled: true,
          fillColor: AppTheme().lightestOpacityBlue,
          //prefixIcon: Icon(CupertinoIcons.search, color: AppTheme().blackColor,)
        ),
        onSaved: onSaved,
        //validator: validator
      ),
    );
  }
}



//for password
class CustomTextField2 extends StatefulWidget {
  const CustomTextField2({super.key, required this.textController, required this.onSaved, required this.hintText,});
  final TextEditingController textController;
  final void Function(String?)? onSaved;
  final String hintText;

  @override
  State<CustomTextField2> createState() => _CustomTextField2State();
}

class _CustomTextField2State extends State<CustomTextField2> {
  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<AuthController>(context);
    return Container(
      decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.r)
      ),
      //height: 70.h,
      width: double.infinity,
      child: TextFormField(
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            color: AppTheme().blackColor,
            fontSize: 13.sp
          )
        ),
        autofocus: true,      
        textCapitalization: TextCapitalization.sentences,    
        scrollPhysics: const BouncingScrollPhysics(),
        scrollController: ScrollController(),
        obscureText: controller.blindText1,
        textInputAction: TextInputAction.next,
        enabled: true,
        controller: widget.textController,
        keyboardType: TextInputType.visiblePassword,
        autocorrect: true,
        enableSuggestions: true,
        enableInteractiveSelection: true,
        cursorColor: AppTheme().blackColor,
        //style: GoogleFonts.poppins(color: AppTheme().blackColor),
        decoration: InputDecoration(        
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide.none
          ),       
          hintText: widget.hintText,
          hintStyle: GoogleFonts.poppins(color: AppTheme().darkGreyColor, fontSize: 13.sp),              
          filled: true,
          fillColor: AppTheme().lightestOpacityBlue,
          suffixIcon: InkWell(
            onTap: () {
              setState(() {
                controller.blindText1 = !controller.blindText1;
              });
              debugPrint("${controller.blindText1}");
            },
            child: controller.blindText1
            ?Icon(Icons.visibility_rounded, color: AppTheme().mainColor,) 
            //SvgPicture.asset('assets/svg/visible.svg', height: 5, width: 5,) 
            :Icon(Icons.visibility_off_rounded, color: AppTheme().mainColor,) 
            //SvgPicture.asset('assets/svg/invisible.svg', height: 5, width: 5,),
          ), 
        ),
        onSaved: widget.onSaved,
      ),
    );
  }
}

//for confirm password
class CustomTextField3 extends StatefulWidget {
  const CustomTextField3({super.key, required this.textController, required this.onSaved, required this.hintText,});
  final TextEditingController textController;
  final void Function(String?)? onSaved;
  final String hintText;

  @override
  State<CustomTextField3> createState() => _CustomTextField3State();
}

class _CustomTextField3State extends State<CustomTextField3> {
  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<AuthController>(context);
    return Container(
      decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.r)
      ),
      //height: 70.h,
      width: double.infinity,
      child: TextFormField(
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            color: AppTheme().blackColor,
            fontSize: 13.sp
          )
        ),
        autofocus: true,      
        textCapitalization: TextCapitalization.sentences,              
        scrollPhysics: const BouncingScrollPhysics(),
        scrollController: ScrollController(),
        obscureText: controller.blindText2,
        textInputAction: TextInputAction.done,
        enabled: true,
        controller: widget.textController,
        keyboardType: TextInputType.visiblePassword,
        autocorrect: true,
        enableSuggestions: true,
        enableInteractiveSelection: true,
        cursorColor: AppTheme().blackColor,
        //style: GoogleFonts.poppins(color: AppTheme().blackColor),
        decoration: InputDecoration(        
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide.none
          ),       
          hintText: widget.hintText,
          hintStyle: GoogleFonts.poppins(color: AppTheme().darkGreyColor, fontSize: 13.sp),              
          filled: true,
          fillColor: AppTheme().lightestOpacityBlue,
          suffixIcon: InkWell(
            onTap: () {
              setState(() {
                controller.blindText2 = !controller.blindText2;
              });
              debugPrint("${controller.blindText2}");
            },
            child: controller.blindText2
            ?Icon(Icons.visibility_rounded, color: AppTheme().mainColor,) 
            //SvgPicture.asset('assets/svg/visible.svg', height: 5, width: 5,) 
            :Icon(Icons.visibility_off_rounded, color: AppTheme().mainColor,) 
            //SvgPicture.asset('assets/svg/invisible.svg', height: 5, width: 5,),
          ), 
        ),
        onSaved: widget.onSaved,
      ),
    );
  }
}


//for name
class CustomTextField4 extends StatelessWidget {
  const CustomTextField4({super.key, required this.textController, required this.onSaved, required this.hintText});
  final TextEditingController textController;
  final void Function(String?)? onSaved;
  final String hintText;


  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<AuthController>(context);
    return Container(
      decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.r)
      ),
      //height: 70.h,
      width: double.infinity,
      child: TextFormField(
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            color: AppTheme().blackColor,
            fontSize: 13.sp
          )
        ),
        autofocus: true,     
        textCapitalization: TextCapitalization.sentences,              
        scrollPhysics: const BouncingScrollPhysics(),
        scrollController: ScrollController(),
        textInputAction: TextInputAction.next,
        enabled: true,
        controller: textController,
        keyboardType: TextInputType.name,
        autocorrect: true,
        enableSuggestions: true,
        enableInteractiveSelection: true,
        cursorColor: AppTheme().blackColor,
        //style: GoogleFonts.poppins(color: AppTheme().blackColor),
        decoration: InputDecoration(        
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide.none
          ),       
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(color: AppTheme().darkGreyColor, fontSize: 13.sp),              
          filled: true,
          fillColor: AppTheme().lightestOpacityBlue,
          //prefixIcon: Icon(CupertinoIcons.search, color: AppTheme().blackColor,)
        ),
        onSaved: onSaved,
      ),
    );
  }
}






//////////////////////////////////For Login Screen
//for email
class EmailFieldLogin extends StatelessWidget {
  const EmailFieldLogin({super.key, required this.textController, required this.onSaved, required this.hintText,});
  final TextEditingController textController;
  final void Function(String?)? onSaved;
  final String hintText;
  //final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {

    var controller = Provider.of<AuthController>(context);

    return Container(
      decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.r)
      ),
      //height: 70.h,
      width: double.infinity,
      child: TextFormField(
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            color: AppTheme().blackColor,
            fontSize: 13.sp
          )
        ),
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,          
        scrollPhysics: const BouncingScrollPhysics(),
        scrollController: ScrollController(),
        textInputAction: TextInputAction.next,
        enabled: true,
        controller: textController,
        keyboardType: TextInputType.emailAddress,
        autocorrect: true,
        enableSuggestions: true,
        enableInteractiveSelection: true,
        cursorColor: AppTheme().blackColor,
        //style: GoogleFonts.poppins(color: AppTheme().blackColor),
        decoration: InputDecoration(        
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide.none
          ),       
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(color: AppTheme().darkGreyColor, fontSize: 13.sp),              
          filled: true,
          fillColor: AppTheme().lightestOpacityBlue,
          //prefixIcon: Icon(CupertinoIcons.search, color: AppTheme().blackColor,)
        ),
        onSaved: onSaved,
        //validator: validator
      ),
    );
  }
}

//for password
class  PasswordFieldLogin extends StatefulWidget {
  const PasswordFieldLogin({super.key, required this.textController, required this.onSaved, required this.hintText,});
  final TextEditingController textController;
  final void Function(String?)? onSaved;
  final String hintText;

  @override
  State<PasswordFieldLogin> createState() => _PasswordFieldLoginState();
}

class _PasswordFieldLoginState extends State<PasswordFieldLogin> {
  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<AuthController>(context);
    return Container(
      decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.r)
      ),
      //height: 70.h,
      width: double.infinity,
      child: TextFormField(
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            color: AppTheme().blackColor,
            fontSize: 13.sp
          )
        ),
        autofocus: true,      
        textCapitalization: TextCapitalization.sentences,              
        scrollPhysics: const BouncingScrollPhysics(),
        scrollController: ScrollController(),
        obscureText: controller.blindText3,
        textInputAction: TextInputAction.done,
        enabled: true,
        controller: widget.textController,
        keyboardType: TextInputType.visiblePassword,
        autocorrect: true,
        enableSuggestions: true,
        enableInteractiveSelection: true,
        cursorColor: AppTheme().blackColor,
        //style: GoogleFonts.poppins(color: AppTheme().blackColor),
        decoration: InputDecoration(        
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide.none
          ),       
          hintText: widget.hintText,
          hintStyle: GoogleFonts.poppins(color: AppTheme().darkGreyColor, fontSize: 13.sp),              
          filled: true,
          fillColor: AppTheme().lightestOpacityBlue,
          suffixIcon: InkWell(
            onTap: () {
              setState(() {
                controller.blindText3 = !controller.blindText3;
              });
              debugPrint("${controller.blindText3}");
            },
            child: controller.blindText3
            ?Icon(Icons.visibility_rounded, color: AppTheme().mainColor,) 
            //SvgPicture.asset('assets/svg/visible.svg', height: 5, width: 5,) 
            :Icon(Icons.visibility_off_rounded, color: AppTheme().mainColor,) 
            //SvgPicture.asset('assets/svg/invisible.svg', height: 5, width: 5,),
          ), 
        ),
        onSaved: widget.onSaved,
      ),
    );
  }
}