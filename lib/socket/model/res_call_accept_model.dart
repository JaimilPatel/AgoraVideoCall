class ResCallAcceptModel {
  String channel;
  String token;
  int id;

  ResCallAcceptModel(
      {this.channel,
      this.token,
      this.id});

  ResCallAcceptModel.fromJson(Map<String, dynamic> json) {
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
