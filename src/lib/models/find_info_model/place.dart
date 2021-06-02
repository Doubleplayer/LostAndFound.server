class Place {
  double latitude;
  double lontitude;

  Place({this.latitude, this.lontitude});

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      latitude: json['latitude'] as double,
      lontitude: json['lontitude'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'lontitude': lontitude,
    };
  }
}
