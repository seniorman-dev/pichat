import 'package:Ezio/theme/app_theme.dart';
import 'package:Ezio/user/chat/controller/chat_service_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';






class MessageReplyPreview extends StatefulWidget {
  const MessageReplyPreview({super.key, required this.text});
  final String text;

  @override
  State<MessageReplyPreview> createState() => _MessageReplyPreviewState();
}

class _MessageReplyPreviewState extends State<MessageReplyPreview> {
  void cancelReply({required BuildContext context}) {
    var chatServiceController = Provider.of<ChatServiceController>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {

    var chatServiceController = Provider.of<ChatServiceController>(context);

    return Container(
      decoration: BoxDecoration(
        //shape: BoxShape.circle,
        color: AppTheme().backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        )
      ),
      width: double.infinity, //350.w,
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 10.h
      ),
      alignment: Alignment.center,
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 5,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.bottomLeft,
                //specify if the message being replied to is a text, image or video
                child: Text(
                  widget.text,
                  style: GoogleFonts.poppins(
                    color: AppTheme().blackColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    textStyle: const TextStyle(
                      overflow: TextOverflow.ellipsis
                    )
                  )
                )
              ),
              InkWell(
                onTap: () => cancelReply(context: context),
                child: Icon(Icons.close_rounded, size: 20.r, color: AppTheme().mainColor) 
              )
            ],
          )
        ],
      )
    );
  }
}