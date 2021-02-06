class ResUserJoinModel {
  String channel;
  String token;
  String guideProfilePic;
  String guideName;
  int guideId;
  int hotLinkId;

  ResUserJoinModel(
      {this.channel,
      this.token,
      this.guideProfilePic,
      this.guideName,
      this.guideId,
      this.hotLinkId});

  ResUserJoinModel.fromJson(Map<String, dynamic> json) {
    channel = json['channel'];
    token = json['token'];
    guideProfilePic = json['guideProfilePic'];
    guideName = json['guideName'];
    guideId = json['guideId'];
    hotLinkId = json['hotLinkId'];
  }

  Map<String, dynamic> toJson() => {
        'channel': channel,
        'token': token,
        'guideProfilePic': guideProfilePic,
        'guideName': guideName,
        'guideId': guideId,
        'hotLinkId': hotLinkId
      };
}
