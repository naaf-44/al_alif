class ImageModel {
  String? date;
  List<String>? images;
  String? time;
  String? key;

  ImageModel({this.date, this.images, this.time, this.key});

  ImageModel.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    images = json['images'].cast<String>();
    time = json['time'];
    key = json['key'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['images'] = this.images;
    data['time'] = this.time;
    data['key'] = this.key;
    return data;
  }
}
