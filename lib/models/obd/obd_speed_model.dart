class ObdSpeedModel {
  // 2022.06.24 Lunaric : speed & time mandatory to calculate acceleration (derivative), decelerationTime optional to rapidStop
  final double speed;
  final DateTime time;
  DateTime? decelerationTime;

  ObdSpeedModel({
    required this.speed,
    required this.time,
    this.decelerationTime,
  });

  factory ObdSpeedModel.fromJson(Map<String, dynamic> json) {
    return ObdSpeedModel(
      speed: json['speed'],
      time: json['time'],
    );
  }
}
