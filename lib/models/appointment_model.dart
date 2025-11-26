class Appointment {
  final int? id;
  final int patientId;
  final int doctorId;
  final String date;  // "2023-10-25"
  final String time;  // "10:00 AM"
  final String status; // pending, confirmed...

  Appointment({
    this.id,
    required this.patientId,
    required this.doctorId,
    required this.date,
    required this.time,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'date': date,
      'time': time,
      'status': status,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      patientId: map['patientId'],
      doctorId: map['doctorId'],
      date: map['date'],
      time: map['time'],
      status: map['status'],
    );
  }
}