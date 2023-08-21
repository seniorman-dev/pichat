import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/chat/agora/const/app_id.dart';






class ChatVideoCall extends StatefulWidget {
  const ChatVideoCall({Key? key}) : super(key: key);

  @override
  State<ChatVideoCall> createState() => _ChatVideoCallState();
}

class _ChatVideoCallState extends State<ChatVideoCall> {
  final AgoraClient client = AgoraClient(
    agoraConnectionData: AgoraConnectionData(
      screenSharingEnabled: true,
      uid: 0,
      appId: agora_app_id,
      channelName: "jetify",
      username: "user1_user2",
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

  @override
  Widget build(BuildContext context) {
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
                  Get.back();
                },
              ),
            ],
          ),
        ),
    );
  }
}