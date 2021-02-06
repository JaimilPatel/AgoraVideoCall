class SocketConstants {
  //Default events
  static const String eventConnect = "connect";
  static const String eventConnecting = "connecting";
  static const String eventDisconnect = "disconnect";
  static const String eventError = "error";
  static const String eventMessage = "message";
  static const String eventConnectTimeout = "connect_timeout";
  static const String onSocketError = "onSocketError";

  //Video Call  events
  static const String emitJoinRoom = "emitJoinRoom";
  static const String onUserRequest = "onUserRequest";
  static const String onUserJoin = "onUserJoin";
  static const String emitCancelCall = "emitCancelCall";
  static const String onCancelCall = "onCancelCall";
  static const String emitGuideAccept = "emitGuideAccept";
  static const String onGuideAccept = "onGuideAccept";
  static const String onHotLinkConnectionFail = "onHotLinkConnectionFail";

}
