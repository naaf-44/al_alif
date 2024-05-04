class AdminAuthModel {
  Admin? admin;

  AdminAuthModel({this.admin});

  AdminAuthModel.fromJson(Map<String, dynamic> json) {
    admin = json['admin'] != null ? new Admin.fromJson(json['admin']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.admin != null) {
      data['admin'] = this.admin!.toJson();
    }
    return data;
  }
}

class Admin {
  Auth? auth;
  String? shareUrl;

  Admin({this.auth, this.shareUrl});

  Admin.fromJson(Map<String, dynamic> json) {
    auth = json['auth'] != null ? new Auth.fromJson(json['auth']) : null;
    shareUrl = json['shareUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.auth != null) {
      data['auth'] = this.auth!.toJson();
      data['shareUrl'] = this.shareUrl;
    }
    return data;
  }
}

class Auth {
  String? password;
  String? username;

  Auth({this.password, this.username});

  Auth.fromJson(Map<String, dynamic> json) {
    password = json['password'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['password'] = this.password;
    data['username'] = this.username;
    return data;
  }
}
