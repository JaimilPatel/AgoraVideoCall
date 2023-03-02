import 'dart:async';

import 'package:agoravideocall/utils/constants/app_constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dialog_utils.dart';
import 'localization/localization.dart';

//Check Connectivity With Network
final Connectivity _connectivity = Connectivity();
String? _connectionStatus;
Future<bool> checkNetworkConnection(BuildContext context) async {
  String connectionStatus;

  try {
    connectionStatus = (await _connectivity.checkConnectivity()).toString();
  } on PlatformException catch (_) {
    connectionStatus = Localization.of(context)!.internetConnectionFailed;
  }

  _connectionStatus = connectionStatus;
  if (_connectionStatus == AppConstants.mobileConnectionStatus ||
      _connectionStatus == AppConstants.wifiConnectionStatus) {
    return true;
  } else {
    DialogUtils.showAlertDialog(
        context, Localization.of(context)!.internetNotConnected);
    return false;
  }
}
