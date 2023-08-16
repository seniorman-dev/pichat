import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/chat/controller/chat_service_controller.dart';
import 'package:pichat/utils/toast.dart';
import 'package:provider/provider.dart';








class AudioWidget extends StatefulWidget {
  const AudioWidget({super.key,});


  @override
  State<AudioWidget> createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget> {


  late AudioPlayer audioPlayer;

  @override
  void initState() {
    audioPlayer = AudioPlayer();
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
  //use 'isRecording' to change icon of recording and its color, then call the "sendAudioToStorage()"
  //put this function in chat list page (initialize all the players oh)
  Future<void> playRecording() async{
    var chatServiceController = Provider.of<ChatServiceController>(context, listen: false);
    try {
      Source urlSourcce = UrlSource(chatServiceController.audioPath);
      //await audioPlayer.pause(); implement
      //await audioPlayer.resume(); implement
      //await audioPlayer.seek(position)
      await audioPlayer.play(
        urlSourcce,
        //volume: 10,
        //mode: PlayerMode.lowLatency
      );
    }
    catch (e) {
      print('error: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    var chatServiceController = Provider.of<ChatServiceController>(context, listen: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              chatServiceController.isPlaying = !chatServiceController.isPlaying;
            });
            if(chatServiceController.isPlaying) {
              audioPlayer.pause();
              //audioPlayer.resume();
              //audioPlayer.stop();
            }
            else {
              playRecording();
            }

          },
          child: Icon(
            chatServiceController.isPlaying  
            ?CupertinoIcons.play_fill //.pause_solid
            :CupertinoIcons.pause_fill, //.play_fill,
            color: AppTheme().whiteColor,
          ),
        ),
        SizedBox(width: 5.w),
        
        Expanded(
          child: LinearProgressIndicator(
            //value: chatServiceController.progress,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme().whiteColor),
            backgroundColor: AppTheme().greyColor,
          ),
        ),
      ],
    );
  }
}


