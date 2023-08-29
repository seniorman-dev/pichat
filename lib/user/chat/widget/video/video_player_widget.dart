import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:Ezio/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
//import 'package:cached_video_player/cached_video_player.dart';






class VideoPlayerItem extends StatefulWidget {
  const VideoPlayerItem({Key? key, required this.videoUrl}) : super(key: key);
  final String videoUrl;

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {

  //bool isPlaying = false;

  //late CachedVideoPlayerController videoPlayerController;

  @override
  void initState() {
    // TODO: implement initState
    /*videoPlayerController = CachedVideoPlayerController
    .network(widget.videoUrl)
    ..initialize()
    .then(
      (value) {
        videoPlayerController.setVolume(1);
      }
    );*/
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    //videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      /*onDoubleTap: () {
        videoPlayerController.play();
      },
      onTap: () {
        if(isPlaying ){
          videoPlayerController.pause();
          setState(() {
            isPlaying = false;
          });
        }
        else{
          videoPlayerController.play();
          setState(() {
            isPlaying = true;
          });
        }
      },*/
      child: AspectRatio(
        aspectRatio: 16/9,
        child: BetterPlayer.network(
          widget.videoUrl,
          betterPlayerConfiguration: BetterPlayerConfiguration(
            aspectRatio: 16 / 9,
            autoPlay: true,
            allowedScreenSleep: true,
            fullScreenByDefault: false,
          ),
        ),
        /*Stack(
          children: [
            CachedVideoPlayer(videoPlayerController),
            Align(
              alignment: Alignment.center,
              child: IconButton(
                onPressed: () {
                  if(isPlaying ){
                    videoPlayerController.pause();
                    setState(() {
                      isPlaying = false;
                    });
                  }
                  else{
                    videoPlayerController.play();
                    setState(() {
                      isPlaying = true;
                    });
                  }
                }, 
                icon: Icon(
                  isPlaying 
                  ?CupertinoIcons.pause_circle
                  :CupertinoIcons.play_circle, 
                  color: isPlaying ? Colors.transparent : AppTheme().whiteColor,
                )
              ),
            ),
          ],
        ),*/
      ),
    );
  }
}