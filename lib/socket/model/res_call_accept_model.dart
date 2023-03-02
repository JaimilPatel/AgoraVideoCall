class ResCallAcceptModel {
  String? channel;
  String? token;
  int? id;
  int? otherUserId;

  ResCallAcceptModel({this.channel, this.token, this.id, this.otherUserId});

  ResCallAcceptModel.fromJson(Map<String, dynamic> json) {
    channel = json['channel'];
    token = json['token'];
    id = json['id'];
    otherUserId = int.parse(json['otherUserId']);
  }

  Map<String, dynamic> toJson() => {
        'channel': channel,
        'token': token,
        'id': id,
        'otherUserId': otherUserId,
      };
}
