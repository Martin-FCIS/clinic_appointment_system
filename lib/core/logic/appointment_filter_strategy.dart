import 'package:intl/intl.dart';

abstract class AppointmentFilterStrategy {
  List<Map<String, dynamic>> filter(List<Map<String, dynamic>> appointments,
      DateTime selectedDate);

  List<Map<String, dynamic>> sort(List<Map<String, dynamic>> list) {
    list.sort((a, b) {
      int dateCmp = b['date'].compareTo(a['date']);
      if (dateCmp != 0) return dateCmp;
      try {
        var tA = a['time'].split(':').map(int.parse).toList();
        var tB = b['time'].split(':').map(int.parse).toList();
        if (tB[0] != tA[0]) return tB[0].compareTo(tA[0]);
        return tB[1].compareTo(tA[1]);
      } catch (e) {
        return 0;
      }
    });
    return list;
  }

  List<Map<String, dynamic>> execute(List<Map<String, dynamic>> appointments,DateTime selectedDate) {
    final filteredList = filter(appointments, selectedDate);
    return sort(filteredList);
  }
}

class AllAppointmentsStrategy extends AppointmentFilterStrategy {
  @override
  List<Map<String, dynamic>> filter(List<Map<String, dynamic>> appointments,
      DateTime selectedDate) {
    return List.from(appointments);
  }
}
  class DayAppointmentsStrategy extends AppointmentFilterStrategy {
  @override
  List<Map<String, dynamic>> filter(List<Map<String, dynamic>> appointments, DateTime selectedDate) {
  String targetDate = DateFormat('yyyy-MM-dd').format(selectedDate);
  return appointments.where((app) => app['date'] == targetDate).toList();
  }
}
class WeekAppointmentsStrategy extends AppointmentFilterStrategy {
  @override
  List<Map<String, dynamic>> filter(
      List<Map<String, dynamic>> appointments, DateTime selectedDate) {

    int daysToSubtract = (selectedDate.weekday + 1) % 7;
    DateTime startOfWeek = selectedDate.subtract(Duration(days: daysToSubtract));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
    DateTime startOnly = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    DateTime endOnly = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day);

    return appointments.where((app) {
      try {
        DateTime appDate = DateTime.parse(app['date']);
        DateTime dateOnly = DateTime(appDate.year, appDate.month, appDate.day);

        return (dateOnly.isAtSameMomentAs(startOnly) || dateOnly.isAfter(startOnly)) &&
            (dateOnly.isAtSameMomentAs(endOnly) || dateOnly.isBefore(endOnly));
      } catch (e) {
        return false;
      }
    }).toList();
  }
}
