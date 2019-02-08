class Subscription {
  String device;
  String platform;
  String appid;
  String region;

  Subscription({this.device, this.platform, this.appid, this.region});

  Subscription.fromJson(Map<String, dynamic> json) {
    device = json['device'];
    platform = json['platform'];
    appid = json['appid'];
    region = json['region'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['device'] = this.device;
    data['platform'] = this.platform;
    data['appid'] = this.appid;
    data['region'] = this.region;
    return data;
  }
}