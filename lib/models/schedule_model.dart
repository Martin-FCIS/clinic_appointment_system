class Schedule {
  final int? id;
  final int doctorId;
  final String day;
  final String startTime;
  final String endTime;

  Schedule(
      {this.id,
      required this.doctorId,
      required this.day,
      required this.startTime,
      required this.endTime});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorId': doctorId,
      'day': day,
      'startTime': startTime,
      'endTime': endTime
    };
  }
  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'],
      doctorId: map['doctorId'],
      day: map['day'],
      startTime: map['startTime'],
      endTime: map['endTime'],
    );
  }
}
