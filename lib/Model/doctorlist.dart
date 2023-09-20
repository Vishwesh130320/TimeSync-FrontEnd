class DoctorList {
  String? username;
  String? email;
  String? role;
  String? id;

  DoctorList({this.username, this.email, this.role});

  DoctorList.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    email = json['email'];
    role = json['role'];
    id = json["id"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['email'] = this.email;
    data['role'] = this.role;
    data["id"]  = this.id;
    return data;
  }
}
