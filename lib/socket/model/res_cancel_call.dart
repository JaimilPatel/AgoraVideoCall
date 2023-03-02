class ResCancelCall {
  String? msg;
  String? role;
  int? hotLinkId;
  bool? isCallAccepted;

  ResCancelCall({this.msg, this.role, this.hotLinkId, this.isCallAccepted});

  ResCancelCall.fromJson(Map<String, dynamic> json) {
    msg = json['channel'];
    role = json['role'];
    hotLinkId = json['hotLinkId'];
    isCallAccepted = json['isCallAccepted'];
  }

  Map<String, dynamic> toJson() => {
        'msg': msg,
        'role': role,
        'hotLinkId': hotLinkId,
        'isCallAccepted': isCallAccepted,
      };
}
