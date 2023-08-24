import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Ezio/api/api.dart';
import 'package:Ezio/theme/app_theme.dart';
import 'package:Ezio/user/chat/controller/chat_service_controller.dart';
import 'package:Ezio/utils/extract_firstname.dart';
import 'package:provider/provider.dart';








class SendOrCancelRequestButton extends StatefulWidget {
  final String receiverName;
  final String receiverID;
  final String receiverFCMToken;
  bool isSelected;
  

  SendOrCancelRequestButton({super.key, required this.receiverID, required this.isSelected, required this.receiverFCMToken, required this.receiverName,});

  @override
  _SendOrCancelRequestButtonState createState() => _SendOrCancelRequestButtonState();
}

class _SendOrCancelRequestButtonState extends State<SendOrCancelRequestButton> {
  bool _isPending = false;

  @override
  Widget build(BuildContext context) {
    var chatServiceController = Provider.of<ChatServiceController>(context);

    Future<void> _sendFriendRequest() async {
      //did this to retrieve logged in user information
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(chatServiceController.auth.currentUser!.uid)
      .get();
      String userName = snapshot.get('name');
      String userId = snapshot.get('id');
                        ////////////////////////
      await chatServiceController.sendFriendRequest(recipientId: widget.receiverID)
      .then(
        (value) => API().sendPushNotificationWithFirebaseAPI(content: '${getFirstName(fullName: userName)} wants to connect with you 🎈', receiverFCMToken: widget.receiverFCMToken, title: 'Hi, ${widget.receiverName}')
      )
      .then(
        (value) => chatServiceController.firestore.collection('users').doc(widget.receiverID).collection('notifications')
        .doc(userId)
        .set({
          'title': 'Hi, ${getFirstName(fullName: widget.receiverName)}',
          'body': '${getFirstName(fullName: userName)} wants to connect with you 🎈',
          'timestamp': Timestamp.now(),
        })
      );

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


    if (_isPending) {
      return SizedBox(
        height: 35.h,
        //width: 85.w,
        child: ElevatedButton(
          onPressed: () => _cancelFriendRequest(),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: AppTheme().lightestOpacityBlue,
            minimumSize: Size.copy(Size(100.w, 50.h)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),                                          
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
                color: AppTheme().blackColor,
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
            elevation: 0,
            backgroundColor: AppTheme().lightestOpacityBlue,
            minimumSize: Size.copy(Size(100.w, 50.h)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),                                          
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
                color: AppTheme().blackColor,
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






class AcceptRequestButton extends StatefulWidget {
  final String receiverID;
  final String receiverName;
  final String receiverProfilePic;
  final String receiverFCMToken;
  final String receiverEmail;
  bool isSelected;
  

  AcceptRequestButton({super.key, required this.receiverID, required this.receiverName, required this.receiverProfilePic,required this.isSelected, required this.receiverFCMToken, required this.receiverEmail});

  @override
  _AcceptRequestButtonState createState() => _AcceptRequestButtonState();
}

class _AcceptRequestButtonState extends State<AcceptRequestButton> {
  bool _isFriend = false;
  bool _isPending = false;


  @override
  Widget build(BuildContext context) {
    var chatServiceController = Provider.of<ChatServiceController>(context);

    Future<void> _acceptFriendRequest() async {
      await chatServiceController.acceptFriendRequest(
        friendName: widget.receiverName, 
        friendId: widget.receiverID, 
        friendProfilePic: widget.receiverProfilePic, 
        friendEmail: widget.receiverEmail, 
        friendFCMToken: widget.receiverFCMToken
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
        _isFriend = true;
        widget.isSelected = true;
      });
    }


    if (_isFriend) {
      return SizedBox(
        height: 35.h,
        //width: 85.w,
        child: ElevatedButton(
          onPressed: () => _removerUserFromFriendList(),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: AppTheme().lightestOpacityBlue,
            minimumSize: Size.copy(Size(100.w, 50.h)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),                                          
          ),        
          /*icon: Icon(
            chatServiceController.isAdded ? CupertinoIcons.clear_thick_circled: CupertinoIcons.person_crop_circle_fill_badge_plus,
            color: AppTheme().whiteColor,
            size: 18.r,
          ),*/
          child: Text(
            'remove',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                color: AppTheme().blackColor,
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
          onPressed: () => _acceptFriendRequest(),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: AppTheme().lightestOpacityBlue,
            minimumSize: Size.copy(Size(100.w, 50.h)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),                                          
          ),        
          /*icon: Icon(
            chatServiceController.isAdded ? CupertinoIcons.clear_thick_circled: CupertinoIcons.person_crop_circle_fill_badge_plus,
            color: AppTheme().whiteColor,
            size: 18.r,
          ),*/
          child: Text(
            'accept',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                color: AppTheme().blackColor,
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






class DeclineRequestButton extends StatefulWidget {
  final String receiverID;
  bool isSelected;
  

  DeclineRequestButton({super.key, required this.receiverID, required this.isSelected});

  @override
  _DeclineRequestButtonState createState() => _DeclineRequestButtonState();
}

class _DeclineRequestButtonState extends State<AcceptRequestButton> {
  bool _isFriend = false;
  bool _isPending = false;


  @override
  Widget build(BuildContext context) {

    var chatServiceController = Provider.of<ChatServiceController>(context);

    Future<void> _declineFriendRequest() async {
      await chatServiceController.declineFriendRequest(friendId: widget.receiverID);
      setState(() {
        _isPending = false;
        _isFriend = false;
        widget.isSelected = true;
      });
    }


    return SizedBox(
      height: 35.h,
      //width: 85.w,
      child: ElevatedButton(
        onPressed: () => _declineFriendRequest(),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppTheme().lightestOpacityBlue,
          minimumSize: Size.copy(Size(100.w, 50.h)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),                                          
        ),        
        /*icon: Icon(
          chatServiceController.isAdded ? CupertinoIcons.clear_thick_circled: CupertinoIcons.person_crop_circle_fill_badge_plus,
          color: AppTheme().whiteColor,
          size: 18.r,
        ),*/
        child: Text(
          'decline',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: AppTheme().blackColor,
              fontSize: 10.sp,
              fontWeight: FontWeight.w500
            )
          ),
        )
      ),
    );
  }
}

