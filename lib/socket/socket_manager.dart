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

io.Socket _socketInstance;
BuildContext buildContext;
String channelName;
String channelToken;
ResCallAcceptModel resCallAcceptModel;

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
  _socketInstance.connect();
  socketGlobalListeners();
}

dynamic reInitializeAndConnectSocket() {
  disconnectSocket();
  initSocketManager(buildContext);
}

dynamic disconnectSocket() {
  _socketInstance?.clearListeners();
  _socketInstance?.disconnect();
}

dynamic socketGlobalListeners() {
  _socketInstance?.on(SocketConstants.eventConnect, onConnect);
  _socketInstance?.on(SocketConstants.eventDisconnect, onDisconnect);
  _socketInstance?.on(SocketConstants.onSocketError, onConnectError);
  _socketInstance?.on(SocketConstants.eventConnectTimeout, onConnectError);
  _socketInstance?.on(SocketConstants.onCallRequest, handleOnCallRequest);
  _socketInstance?.on(SocketConstants.onCallRequest, handleOnCallRequest);
  _socketInstance?.on(SocketConstants.onAcceptCall, handleOnAcceptCall);
  _socketInstance?.on(SocketConstants.onRejectCall, handleOnRejectCall);
}

dynamic deInitialize() {
  disconnectSocket();
  _socketInstance = null;
}

bool isConnected() {
  if (_socketInstance != null) {
    return _socketInstance?.connected;
  }
  return false;
}

bool emit(String event, Map<String, dynamic> data) {
  ConsoleLogUtils.printLog("===> emit $data");
  _socketInstance?.emit(event, jsonDecode(json.encode(data)));
  return _socketInstance?.connected;
}

dynamic on(String event, Function fn) {
  _socketInstance?.on(event, fn);
}

dynamic off(String event, [Function fn]) {
  _socketInstance?.off(event, fn);
}

dynamic onConnect(_) {
  ConsoleLogUtils.printLog("===> connected socket....................");
}

dynamic onDisconnect(_) {
  ConsoleLogUtils.printLog("===> Disconnected socket....................");
}

dynamic onConnectError(error) {
  ConsoleLogUtils.printLog(
      "===> ConnectError socket.................... $error");
}

void handleOnCallConnect(dynamic response) async {
  ConsoleLogUtils.printLog("===> handleOnCallConnect....................");
  if (response != null) {
    final data = ResCallAcceptModel.fromJson(response);
    resCallAcceptModel = data;
    channelName = data.channel;
    channelToken = data.token;
    NavigationUtils.push(buildContext, RouteConstants.routePickUpScreen,
        arguments: {
          ArgParams.resCallAcceptModel: data,
          ArgParams.resCallRequestModel: ResCallRequestModel(),
          ArgParams.isForOutGoing: true,
        });
  }
}

void handleOnCallRequest(dynamic response) {
  ConsoleLogUtils.printLog("===> handleOnCallRequest....................");
  if (response != null) {
    final data = ResCallRequestModel.fromJson(response);
    NavigationUtils.push(buildContext, RouteConstants.routePickUpScreen,
        arguments: {
          ArgParams.resCallAcceptModel: ResCallAcceptModel(),
          ArgParams.resCallRequestModel: data,
          ArgParams.isForOutGoing: false,
        });
  }
}

void handleOnAcceptCall(dynamic response) async {
  ConsoleLogUtils.printLog("===> handleOnAcceptCall....................");
  NavigationUtils.pushReplacement(buildContext, RouteConstants.routeVideoCall,
      arguments: {
        ArgParams.channelKey: channelName,
        ArgParams.channelTokenKey: channelToken,
        ArgParams.resCallAcceptModel: resCallAcceptModel,
        ArgParams.resCallRequestModel: ResCallRequestModel(),
        ArgParams.isForOutGoing: true,
      });
}

void handleOnRejectCall(dynamic response) {
  ConsoleLogUtils.printLog("===> handleOnRejectCall....................");
  NavigationUtils.pushAndRemoveUntil(
    buildContext,
    RouteConstants.routeCommon,
  );
}
