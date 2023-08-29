import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Ezio/theme/app_theme.dart';
import 'package:Ezio/user/chat/controller/chat_service_controller.dart';
import 'package:provider/provider.dart';










class AudioWidget extends StatefulWidget {
  const AudioWidget({super.key, required this.senderId,});
  final String senderId;


  @override
  State<AudioWidget> createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget> {

  AudioPlayer audioPlayer = AudioPlayer();


  @override
  void initState() {
    var chatServiceController = Provider.of<ChatServiceController>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
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
      await audioPlayer.play(urlSourcce);
      //await audioPlayer.pause(); implement
      //await audioPlayer.resume(); implement
      //await audioPlayer.seek(position)
    }
    catch (e) {
      debugPrint('error: $e');
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
             await audioPlayer.pause();
              setState(() {
                chatServiceController.isPlaying = false;
              });
            }
            else {
              playRecording();
              setState(() {
                chatServiceController.isPlaying = true;
              });
            }
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


