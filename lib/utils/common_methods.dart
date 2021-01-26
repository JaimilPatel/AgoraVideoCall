import 'package:agoravideocall/ui/call/video_call_screen.dart';
import 'package:flutter/material.dart';

//Common Methods For Navigation From Splash To Home Screen
Widget navigationToNextScreen() {
  return VideoCallingScreen(isForOutGoing: true);
}

String getFormatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  var twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  var twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  if (duration.inHours > 0) {
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds hrs";
  }
  return "$twoDigitMinutes:$twoDigitSeconds mins";
}
