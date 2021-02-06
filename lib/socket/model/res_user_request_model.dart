class ResUserRequestModel {
  int userId;
  int hotLinkId;
  String userName;
  String channel;
  String token;
  String profilePic;
  String type;
  String title;
  String body;

  ResUserRequestModel(
      {this.userId,
      this.hotLinkId,
      this.userName,
      this.channel,
      this.token,
      this.profilePic,
      this.type,
      this.title,
      this.body});

  ResUserRequestModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    hotLinkId = json['hotLinkId'];
    userName = json['userName'];
    channel = json['channel'];
    token = json['token'];
    profilePic = json['profilePic'];
    type = json['type'];
    title = json['title'];
    body = json['body'];
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'hotLinkId': hotLinkId,
        'userName': userName,
        'channel': channel,
        'token': token,
        'profilePic': profilePic,
        'type': type,
        'title': title,
        'body': body
      };
}
