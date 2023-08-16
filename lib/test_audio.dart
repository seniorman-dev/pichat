import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';





class TestAudio extends StatefulWidget {
  const TestAudio({super.key});

  @override
  State<TestAudio> createState() => _TestAudioState();
}

class _TestAudioState extends State<TestAudio> {

  late Record audioRecord;
  late AudioPlayer audioPlayer;
  bool isRecording = false;
  String audioPath = "" ;  //save to db

  @override
  void initState() {
    audioPlayer = AudioPlayer();
    audioRecord = Record();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    audioPlayer.dispose();
    audioRecord.dispose();
    super.dispose();
  }

  Future<void> startRecording() async{
    try {
      if(await audioRecord.hasPermission()) {
        await audioRecord.start();
        setState(() {
          isRecording = true;
        });
      }
    }
    catch (e) {
      print('error: $e');
    }
  }

  Future<void> stopRecording() async{
    try {
      //await audioRecord.stop();
      String? path = await audioRecord.stop();
      setState(() {
        isRecording = false;
        audioPath = path!;
      });
    }
    catch (e) {
      print('error: $e');
    }
  }

  void toggleAudioRecording () {
    setState(() {
      isRecording = !isRecording;
    });
    if (isRecording) {
      stopRecording();
    }
    else {
      startRecording();
    }
  }

  Future<void> playRecording() async{
    try {
      Source urlSourcce = UrlSource(audioPath);
      //await audioPlayer.pause(); implement
      //await audioPlayer.resume(); implement
      //await audioPlayer.seek(position)
      await audioPlayer.play(
        urlSourcce,
        //volume: 5,
        //mode: PlayerMode.lowLatency
      );
    }
    catch (e) {
      print('error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 200.h,),
              if(isRecording)
              Text('Recording'),


              ElevatedButton(
                onPressed: startRecording, 
                child: Text('START')
              ),
              ElevatedButton(
                onPressed: stopRecording, 
                child: Text('STOP')
              ),
              if(isRecording == false && audioPath.isNotEmpty)
              ElevatedButton(
                onPressed: playRecording, 
                child: Text('PLAY RECORDING')
              )
            ],
          )
        ),
      ),
    );
  }
}