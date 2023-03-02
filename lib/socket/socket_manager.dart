import 'dart:convert';

import 'package:agoravideocall/utils/console_log_utils.dart';
import 'package:agoravideocall/utils/constants/api_constants.dart';
import 'package:agoravideocall/utils/constants/arg_constants.dart';
import 'package:agoravideocall/utils/constants/route_constants.dart';
import 'package:agoravideocall/utils/navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'model/res_call_accept_model.dart';
import 'model/res_call_request_model.dart';
import 'socket_constants.dart';

io.Socket? _socketInstance;
BuildContext? buildContext;
String? channelName;
String? channelToken;
ResCallAcceptModel? resCallAcceptModel;

//Initialize Socket Connection
dynamic initSocketManager(BuildContext context) {
  buildContext = context;
  if (_socketInstance != null) return;
  _socketInstance = io.io(
    "${ApiConstants.socketUrl}",
    <String, dynamic>{
      ApiConstants.transportsHeader: [
        ApiConstants.webSocketOption,
        ApiConstants.pollingOption
      ],
    },
  );
  _socketInstance?.connect();
  socketGlobalListeners();
}

//Socket Global Listener Events
dynamic socketGlobalListeners() {
  _socketInstance?.on(SocketConstants.eventConnect, onConnect);
  _socketInstance?.on(SocketConstants.eventDisconnect, onDisconnect);
  _socketInstance?.on(SocketConstants.onSocketError, onConnectError);
  _socketInstance?.on(SocketConstants.eventConnectTimeout, onConnectError);
  _socketInstance?.on(SocketConstants.onCallRequest, handleOnCallRequest);
  _socketInstance?.on(SocketConstants.onAcceptCall, handleOnAcceptCall);
  _socketInstance?.on(SocketConstants.onRejectCall, handleOnRejectCall);
}

//To Emit Event Into Socket
bool? emit(String event, Map<String, dynamic> data) {
  ConsoleLogUtils.printLog("===> emit $data");
  _socketInstance?.emit(event, jsonDecode(json.encode(data)));
  return _socketInstance?.connected;
}

//Get This Event After Successful Connection To Socket
dynamic onConnect(_) {
  ConsoleLogUtils.printLog("===> connected socket....................");
}

//Get This Event After Connection Lost To Socket Due To Network Or Any Other Reason
dynamic onDisconnect(_) {
  ConsoleLogUtils.printLog("===> Disconnected socket....................");
}

//Get This Event After Connection Error To Socket With Error
dynamic onConnectError(error) {
  ConsoleLogUtils.printLog(
      "===> ConnectError socket.................... $error");
}

//Get This Event When Someone Received Call From Other User
void handleOnCallRequest(dynamic response) {
  if (response != null) {
    final data = ResCallRequestModel.fromJson(response);
    NavigationUtils.push(buildContext!, RouteConstants.routePickUpScreen,
        arguments: {
          ArgParams.resCallAcceptModel: ResCallAcceptModel(),
          ArgParams.resCallRequestModel: data,
          ArgParams.isForOutGoing: false,
        });
  }
}

//Get This Event When Other User Accepts Your Call
void handleOnAcceptCall(dynamic response) async {
  if (response != null) {
    final data = ResCallAcceptModel.fromJson(response);
    resCallAcceptModel = data;
    channelName = data.channel;
    channelToken = data.token;
    NavigationUtils.pushReplacement(
        buildContext!, RouteConstants.routeVideoCall,
        arguments: {
          ArgParams.channelKey: data.channel,
          ArgParams.channelTokenKey: data.token,
          ArgParams.resCallAcceptModel: data,
          ArgParams.resCallRequestModel: ResCallRequestModel(),
          ArgParams.isForOutGoing: true,
        });
  }
}

//Get This Event When Someone Rejects Call
void handleOnRejectCall(dynamic response) {
  NavigationUtils.pushAndRemoveUntil(
    buildContext!,
    RouteConstants.routeCommon,
  );
}
