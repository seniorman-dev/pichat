import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/chat/controller/chat_service_controller.dart';
import 'package:provider/provider.dart';








class FriendRequestButton extends StatefulWidget {
  final String receiverID;
  final String receiverName;
  final String receiverProfilePic;
  final String currentUserId;
  bool isSelected;
  

  FriendRequestButton({super.key, required this.receiverID, required this.receiverName, required this.receiverProfilePic, required this.currentUserId, required this.isSelected});

  @override
  _FriendRequestButtonState createState() => _FriendRequestButtonState();
}

class _FriendRequestButtonState extends State<FriendRequestButton> {
  final bool _isFriend = false;
  bool _isPending = false;


  @override
  Widget build(BuildContext context) {
    var chatServiceController = Provider.of<ChatServiceController>(context);

    Future<void> _sendFriendRequest() async {
      await chatServiceController.sendFriendRequest(recipientId: widget.receiverID);
      setState(() {
        _isPending = true;
        widget.isSelected = true;
      });
    }

    Future<void> _cancelFriendRequest() async {
      await chatServiceController.cancelFriendRequest(recipientId: widget.receiverID);
      setState(() {
        _isPending = false;
        widget.isSelected = true;
      });
    }

    /*Future<void> _acceptFriendRequest() async {
      await chatServiceController.acceptFriendRequest(
        friendName: widget.receiverName, 
        friendId: widget.receiverID, 
        friendProfilePic: widget.receiverProfilePic
      );
      setState(() {
        _isFriend = true;
        widget.isSelected = true;
      });
    }

    Future<void> _declineFriendRequest() async {
      await chatServiceController.declineFriendRequest(friendId: widget.receiverID);
      setState(() {
        _isPending = false;
        widget.isSelected = true;
      });
    }

    Future<void> _removerUserFromFriendList() async {
      await chatServiceController.removeUserFromFriendList(friendId: widget.receiverID);
      setState(() {
        _isPending = false;
      });
    }*/


    if (_isPending) {
      return SizedBox(
        height: 35.h,
        //width: 85.w,
        child: ElevatedButton(
          onPressed: () => _cancelFriendRequest(),
          style: ElevatedButton.styleFrom(
            elevation: 2,
            backgroundColor: AppTheme().mainColor,
            minimumSize: Size.copy(Size(100.w, 50.h)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),                                          
          ),        
          /*icon: Icon(
            chatServiceController.isAdded ? CupertinoIcons.clear_thick_circled: CupertinoIcons.person_crop_circle_fill_badge_plus,
            color: AppTheme().whiteColor,
            size: 18.r,
          ),*/
          child: Text(
            'cancel',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                color: AppTheme().whiteColor,
                fontSize: 10.sp,
                fontWeight: FontWeight.w500
              )
            ),
          )
        ),
      );
    } 
    else {
      return SizedBox(
        height: 35.h,
        //width: 85.w,
        child: ElevatedButton(
          onPressed: () => _sendFriendRequest(),
          style: ElevatedButton.styleFrom(
            elevation: 2,
            backgroundColor: AppTheme().mainColor,
            minimumSize: Size.copy(Size(100.w, 50.h)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),                                          
          ),        
          /*icon: Icon(
            chatServiceController.isAdded ? CupertinoIcons.clear_thick_circled: CupertinoIcons.person_crop_circle_fill_badge_plus,
            color: AppTheme().whiteColor,
            size: 18.r,
          ),*/
          child: Text(
            'connect',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                color: AppTheme().whiteColor,
                fontSize: 10.sp,
                fontWeight: FontWeight.w500
              )
            ),
          )
        ),
      );
    }
  }
}
