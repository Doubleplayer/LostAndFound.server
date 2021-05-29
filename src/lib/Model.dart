import 'dart:ffi';

class LostInfoModel {
  int id;
  String name;
  String discrip;
  String category;
  List<List<double>> path;
  String time;
  int if_find;
  String user_name;
  String contact_info;
  String picture;
  LostInfoModel();
  LostInfoModel.fromJson(this.id, this.name, this.discrip, this.path, this.time,
      this.if_find, this.user_name, this.contact_info, this.picture);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'discrip': discrip,
      'category': category,
      'path': path,
      'time': time,
      'if_find': if_find,
      'user_name': user_name,
      'contact_info': contact_info,
      'picture': picture,
    };
  }
}
