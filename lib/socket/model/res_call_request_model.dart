class ResCallRequestModel {
  int? id;
  String? channel;
  String? token;

  ResCallRequestModel({this.id, this.channel, this.token});

  ResCallRequestModel.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id']);
    channel = json['channel'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'channel': channel,
        'token': token,
      };
}
