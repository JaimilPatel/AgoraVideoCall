import 'dart:convert';

import 'package:agoravideocall/utils/console_log_utils.dart';
import 'package:agoravideocall/utils/constants/api_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'model/res_user_join_model.dart';
import 'socket_constants.dart';

io.Socket _socketInstance;
BuildContext buildContext;
String channelName;
String channelToken;
ResUserJoinModel resUserJoinModel;

dynamic initSocketManager(BuildContext context) {
  buildContext = context;
  if (_socketInstance != null) return;
  _socketInstance = io.io(
    "${ApiConstants.socketUrl}?${ApiConstants.socketAuthorization}=token",
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
  _socketInstance?.on(SocketConstants.onUserRequest, handleRequestUserData);
  _socketInstance?.on(SocketConstants.onUserJoin, handleJoinUserData);
  _socketInstance?.on(SocketConstants.onCancelCall, handleOnCancelCall);
  _socketInstance?.on(SocketConstants.onGuideAccept, handleOnGuideAccept);
  _socketInstance?.on(
      SocketConstants.onHotLinkConnectionFail, handleHotLinkConnectionFail);
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

void handleRequestUserData(dynamic response) {
  ConsoleLogUtils.printLog("===> handleRequestUserData....................");
}

void handleJoinUserData(dynamic response) async {
  ConsoleLogUtils.printLog("===> handleJoinUserData....................");
}

void handleHotLinkConnectionFail(dynamic response) {
  ConsoleLogUtils.printLog(
      "===> handleHotLinkConnectionFail....................");
}

void handleOnGuideAccept(dynamic response) {
  ConsoleLogUtils.printLog("===> handleOnGuideAccept....................");
}

void handleOnCancelCall(dynamic response) async {
  ConsoleLogUtils.printLog("===> handleOnCancelCall....................");
}
