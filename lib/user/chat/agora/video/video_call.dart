import 'package:Ezio/auth/controller/auth_controller.dart';
import 'package:Ezio/theme/app_theme.dart';
import 'package:Ezio/user/chat/agora/const/app_id.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';









class ChatVideoCall extends StatefulWidget {
  const ChatVideoCall({Key? key, required this.receiverName, required this.receiverProfilePic, required this.receiverId, required this.roomId}) : super(key: key);
  final String receiverName;
  final String receiverId;
  final String receiverProfilePic;
  final String roomId;

  @override
  State<ChatVideoCall> createState() => _ChatVideoCallState();
}

class _ChatVideoCallState extends State<ChatVideoCall> {
  //var sessionId = (Random().nextInt(100000)).toString();
  final RtcEngine engine = createAgoraRtcEngine();
  late AgoraClient client;
  

  @override
  void initState() {
    super.initState();
    initAgora();
  } 

  void initAgora() async {
    final AgoraClient clientDeets = AgoraClient(
      enabledPermission: [
        Permission.audio,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.camera,
        Permission.accessNotificationPolicy,
        Permission.microphone,
        Permission.sensors,
        Permission.videos
      ],
      agoraEventHandlers: AgoraRtcEventHandlers(
        onLeaveChannel: (connection, stats) {
          debugPrint("$connection $stats");
        },
        onJoinChannelSuccess: (connection, elapsed) {
          debugPrint("$connection $elapsed");
        },
      ),
      agoraConnectionData: AgoraConnectionData(
        screenSharingEnabled: true,
        uid: 0,
        appId: agora_app_id,
        channelName: widget.roomId,
        username: "me",
        tokenUrl: "https://agora-token-server-5ta9.onrender.com/rtc/${widget.roomId}/1/uid/0/?expiry=45",
        //tempToken: "007eJxTYGj8+q1/l1reLP6JHWdUvv7/eLsjbuK/G3/Wz7Mo3xbX/mqnAkOiqYF5ckqyoZG5uYGJcXKyZWqqoYWRcZqBsZlJWlKahUPN45SGQEaGV11LmRkZIBDE52HISizISC2JT0ksy0xhYAAADi4n9A==",
      )
    );

    setState(() {
      client = clientDeets;
    });

    await client.initialize();
  }

  Future<void> endCall() async{
    var authController = Provider.of<AuthController>(context, listen: false);
    Timestamp timestamp = Timestamp.now();
    //var sessionId = (Random().nextInt(100000)).toString();
    await authController
    .firestore
    .collection('users')
    .doc(authController.userID)
    .collection('calls')
    .doc(sessionIdVideo)
    .set({
      'name': widget.receiverName,
      'receiverProfilePic': widget.receiverProfilePic,
      'sessionId': sessionIdVideo,
      'timestamp': timestamp,
      'type': 'video'
    });
    await authController
    .firestore
    .collection('users')
    .doc(widget.receiverId)
    .collection('calls')
    .doc(sessionIdVideo)
    .set({
      'name': widget.receiverName,
      'receiverProfilePic': widget.receiverProfilePic,
      'sessionId': sessionIdVideo,
      'timestamp': timestamp,
      'type': 'video'
    })
    .then((value) {
      engine.leaveChannel();
    })
    .then((value) {
      Get.back();
    });
    debugPrint('left channel');
  }

  @override
  Widget build(BuildContext context) {
    var authController = Provider.of<AuthController>(context);
    return
      Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: AppTheme().blackColor,
        body: SafeArea(
          child: Stack(
            children: [
              AgoraVideoViewer(
                client: client,
                layoutType: Layout.floating,
                enableHostControls: true, // Add this to enable host controls
                showNumberOfUsers: true,
              ),
              AgoraVideoButtons(
                client: client,
                addScreenSharing: true, // Add this to enable screen sharing
                autoHideButtons: true,
                onDisconnect: () {
                  endCall();
                },
                screenSharingButtonWidget: CircleAvatar(
                  radius: 30.r,
                  backgroundColor: AppTheme().lightestOpacityBlue,  //.opacityBlue,
                  child: Icon(
                    Icons.screen_share_sharp,
                    size: 20.r,
                    color: AppTheme().mainColor,
                  )                   
                ),
                switchCameraButtonChild: CircleAvatar(
                  radius: 30.r,
                  backgroundColor: AppTheme().lightestOpacityBlue,  //.opacityBlue,
                  child: Icon(
                    Icons.switch_camera_rounded,
                    size: 20.r,
                    color: AppTheme().mainColor,
                  )                   
                ),
                muteButtonChild: CircleAvatar(
                  radius: 30.r,
                  backgroundColor: AppTheme().lightestOpacityBlue,  //.opacityBlue,
                  child: Icon(
                    Icons.mic_rounded,
                    size: 20.r,
                    color: AppTheme().mainColor,
                  )                   
                ),
                disableVideoButtonChild: CircleAvatar(
                  radius: 30.r,
                  backgroundColor: AppTheme().lightestOpacityBlue,  //.opacityBlue,
                  child: Icon(
                    CupertinoIcons.video_camera_solid,
                    size: 20.r,
                    color: AppTheme().mainColor,
                  )                   
                ),
                disconnectButtonChild: CircleAvatar(
                  radius: 40.r,
                  backgroundColor: AppTheme().redColor,
                  child: Icon(
                    CupertinoIcons.phone_down_fill,
                    size: 40.r,
                    color: AppTheme().whiteColor,
                  )                   
                ),
              ),
              
            ],
          ),
        ),
    );
  }
}