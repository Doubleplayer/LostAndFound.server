class RegisterInfo {
  String email;
  String vnum;
  String lastTime;

  RegisterInfo({
    this.email,
    this.vnum,
    this.lastTime,
  });

  factory RegisterInfo.fromJson(Map<String, dynamic> json) {
    return RegisterInfo(
      email: json['email'] as String,
      vnum: json['vnum'] as String,
      lastTime: json['last_time'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'vnum': vnum,
      'last_time': lastTime,
    };
  }
}
