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









class ChatVideoCallGroup extends StatefulWidget {
  const ChatVideoCallGroup({Key? key, required this.groupName, required this.groupProfilePic}) : super(key: key);
  final String groupName;
  final String groupProfilePic;

  @override
  State<ChatVideoCallGroup> createState() => _ChatVideoCallGroupState();
}

class _ChatVideoCallGroupState extends State<ChatVideoCallGroup> {
  //var sessionId = (Random().nextInt(100000)).toString();
  final RtcEngine engine = createAgoraRtcEngine();
  final AgoraClient client = AgoraClient(
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
      channelName: sessionIdForGroupVideo,
      username: "me",
      tokenUrl: "https://agora-token-server-5ta9.onrender.com/rtc/jetify/1/uid/1/?expiry=45",
      //tempToken: "007eJxTYGj8+q1/l1reLP6JHWdUvv7/eLsjbuK/G3/Wz7Mo3xbX/mqnAkOiqYF5ckqyoZG5uYGJcXKyZWqqoYWRcZqBsZlJWlKahUPN45SGQEaGV11LmRkZIBDE52HISizISC2JT0ksy0xhYAAADi4n9A==",
    ),
  );

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  void initAgora() async {
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
    .doc(sessionIdForGroupVideo)
    .set({
      'name': widget.groupName,
      'receiverProfilePic': widget.groupProfilePic,
      'sessionId': sessionIdForGroupVideo,
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