import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/chat/controller/chat_service_controller.dart';
import 'package:pichat/utils/toast.dart';
import 'package:provider/provider.dart';








class AudioWidget extends StatefulWidget {
  const AudioWidget({super.key, required this.senderId,});
  final String senderId;


  @override
  State<AudioWidget> createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget> {


  late AudioPlayer audioPlayer;

  @override
  void initState() {
    var chatServiceController = Provider.of<ChatServiceController>(context, listen: false);
    audioPlayer = AudioPlayer();
    audioPlayer.onPlayerStateChanged.listen((event) {
      event == PlayerState.playing;
      /*setState(() {
        event == PlayerState.playing;
      });*/
    });
    //duration event listener
    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        chatServiceController.duration = newDuration;
      });
    });
    //position event listener
    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        chatServiceController.position = newPosition;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  String formatAudioTime({required int seconds}) {
    return "${Duration(seconds: seconds)}".split('.')[0].padLeft(6, '0'); //8, 0
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
          onTap: () async{
            if(chatServiceController.isPlaying) {
              //don't mind the dead code,it's because of StatelessWidget
              await audioPlayer.pause();
              setState(() {
                chatServiceController.isPlaying = false;
              });
            }
            else {
              playRecording();
              //await audioPlayer.play(UrlSource(widget.message));
              setState(() {
                chatServiceController.isPlaying = true;
              });
            }
            //////
            /*setState(() {
              chatServiceController.isPlaying = !chatServiceController.isPlaying;
            });
            if(chatServiceController.isPlaying) {
              audioPlayer.pause();
              //audioPlayer.resume();
              //audioPlayer.stop();
            }
            else {
              playRecording();
            }*/

          },
          child: Icon(
            chatServiceController.isPlaying 
            ?CupertinoIcons.pause_solid
            :CupertinoIcons.play_fill,
            color: widget.senderId == chatServiceController.auth.currentUser!.uid ? AppTheme().whiteColor : AppTheme().blackColor,
          ),
        ),
        //SizedBox(width: 5.w),
        
        Expanded(
          child: Slider(
            min: 0,
            max: chatServiceController.duration.inSeconds.toDouble(),
            activeColor: widget.senderId == chatServiceController.auth.currentUser!.uid ? AppTheme().whiteColor : AppTheme().blackColor,
            inactiveColor: AppTheme().greyColor, 
            value: chatServiceController.position.inSeconds.toDouble(),
            onChanged: (double value) {
              final position = Duration(seconds: value.toInt());
              audioPlayer.seek(position);
              audioPlayer.resume();
            },
          ),
        ),
        Text(
          formatAudioTime(seconds: chatServiceController.position.inSeconds),  //starting time
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.normal,
            color: widget.senderId == chatServiceController.auth.currentUser!.uid ? AppTheme().whiteColor : AppTheme().blackColor,
          ),
        )
      ],
    );
  }
}


