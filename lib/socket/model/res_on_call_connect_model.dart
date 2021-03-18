class ResOnCallConnectModel {
  String channel;
  String token;
  int id;

  ResOnCallConnectModel(
      {this.channel,
        this.token,
        this.id});

  ResOnCallConnectModel.fromJson(Map<String, dynamic> json) {
    channel = json['channel'];
    token = json['token'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() => {
    'channel': channel,
    'token': token,
    'id': id,
  };
}
