class User {
  String name;
  String password;
  String lastTime;
  String token;
  String email;

  User({
    this.name,
    this.password,
    this.lastTime,
    this.token,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      password: json['password'] as String,
      lastTime: json['last_time'].toString(),
      token: json['token'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'password': password,
      'last_time': lastTime,
      'token': token,
      'email': email,
    };
  }
}
