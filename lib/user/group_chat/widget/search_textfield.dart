import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/theme/app_theme.dart';





class SearchTextFieldForGroup extends StatefulWidget {
  const SearchTextFieldForGroup({super.key, required this.textController, this.onChanged, required this.hintText});
  final TextEditingController textController;
  final void Function(String)? onChanged;
  final String hintText;

  @override
  State<SearchTextFieldForGroup> createState() => _SearchTextFieldForGroupState();
}

class _SearchTextFieldForGroupState extends State<SearchTextFieldForGroup> {

  /*@override
  void dispose() {
    // TODO: implement dispose
    widget.textController.dispose();
    super.dispose();
  }*/


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r)
      ),
      height: 65.h,
      //width: 100.w,
      child: TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,          
        scrollPhysics: const BouncingScrollPhysics(),
        scrollController: ScrollController(),
        textInputAction: TextInputAction.done,
        textCapitalization: TextCapitalization.sentences,
        enabled: true,
        controller: widget.textController,
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
          hintText: widget.hintText,
          hintStyle: GoogleFonts.poppins(color: AppTheme().darkGreyColor, fontSize: 13.sp),              
          filled: true,
          fillColor: AppTheme().lightGreyColor,
          prefixIcon: Icon(CupertinoIcons.search, color: AppTheme().blackColor,)
        ),
        //onFieldSubmitted: widget.onChanged,
        onChanged: widget.onChanged,
      ),
    );
  }
}