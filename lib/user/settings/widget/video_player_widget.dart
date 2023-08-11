import 'package:flutter/material.dart';
import 'package:pichat/utils/loader.dart';
import 'package:video_player/video_player.dart';






class VideoPlayerWidget extends StatelessWidget {
  final String videoUrl;

  VideoPlayerWidget({required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    
    //pare the string to a URI first
    final Uri url = Uri.parse(videoUrl);

    return VideoPlayerController
    .networkUrl(
      url,
      videoPlayerOptions: VideoPlayerOptions(
        allowBackgroundPlayback: false,
        mixWithOthers: false
      )
    ).value.isInitialized
    ?VideoPlayer(
      VideoPlayerController.networkUrl(url),
    )
    :Loader();
  }
}
