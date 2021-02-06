import 'package:flutter/material.dart';

class ConsoleLogUtils {
  static Function printLog(dynamic printMessage) {
    debugPrint(printMessage);
  }
}
