import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/doctor_model.dart';
import '../../../../models/schedule_model.dart';
import '../../../../models/payment_strategy.dart';
import '../../../../repositories/clinic_repository.dart';
class PatientBookingScreen extends StatefulWidget {
  final int patientId;
  final Doctor doctor;
  final String doctorName;

  const PatientBookingScreen({
    super.key,
    required this.patientId,
    required this.doctor,
    required this.doctorName,
  });

  @override
  State<PatientBookingScreen> createState() => _PatientBookingScreenState();
}

class _PatientBookingScreenState extends State<PatientBookingScreen> {
  final ClinicRepository _repo = ClinicRepository.getInstance();

  DateTime _selectedDate = DateTime.now();
  List<String> _availableSlots = [];
  List<String> _bookedSlots = [];
  String? _selectedTimeSlot;
  bool _isLoadingSlots = false;

  List<Schedule> _doctorSchedules = [];
  PaymentStrategy _paymentMethod = CashPaymentStrategy();

  @override
  void initState() {
    super.initState();
    _fetchDoctorSchedules();
  }

  void _fetchDoctorSchedules() async {
    var schedules = await _repo.getDoctorSchedules(widget.doctor.id!);

    DateTime? firstWorkingDay;
    DateTime now = DateTime.now();

    for (int i = 0; i < 30; i++) {
      DateTime day = now.add(Duration(days: i));
      String dayName = DateFormat('EEEE').format(day);

      bool isWorking = schedules.any((s) => s.day.toLowerCase() == dayName.toLowerCase());

      if (isWorking) {
        firstWorkingDay = day;
        break;
      }
    }

    if (mounted) {
      setState(() {
        _doctorSchedules = schedules;
        if (firstWorkingDay != null) {
          _selectedDate = firstWorkingDay;
        }
      });

      _generateSlotsForDate(_selectedDate);
    }
  }

  bool _isDoctorWorkingOnDate(DateTime date) {
    String dayName = DateFormat('EEEE').format(date);
    return _doctorSchedules.any((s) => s.day.toLowerCase() == dayName.toLowerCase());
  }
  void _generateSlotsForDate(DateTime date) async {
    setState(() {
      _isLoadingSlots = true;
      _availableSlots = [];
      _selectedTimeSlot = null;
    });

    String dayName = DateFormat('EEEE').format(date);

    Schedule? scheduleForToday;
    try {
      scheduleForToday = _doctorSchedules.firstWhere(
              (s) => s.day.toLowerCase() == dayName.toLowerCase()
      );
    } catch (e) {
      scheduleForToday = null;
    }

    if (scheduleForToday != null) {
      // أ. تقسيم الوقت
      List<String> allSlots = _createTimeSlots(
          scheduleForToday.startTime,
          scheduleForToday.endTime
      );

      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      List<String> reserved = await _repo.getReservedTimes(widget.doctor.id!, formattedDate);

      if (mounted) {
        setState(() {
          _availableSlots = allSlots;
          _bookedSlots = reserved;
          _isLoadingSlots = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _availableSlots = [];
          _isLoadingSlots = false;
          _isLoadingSlots = false;
        });
      }
    }
  }

  List<String> _createTimeSlots(String startStr, String endStr) {
    List<String> slots = [];
    TimeOfDay start = _parseTime(startStr);
    TimeOfDay end = _parseTime(endStr);

    int currentMinutes = start.hour * 60 + start.minute;
    int endMinutes = end.hour * 60 + end.minute;

    while (currentMinutes < endMinutes) {
      int h = currentMinutes ~/ 60;
      int m = currentMinutes % 60;
      String slot = "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
      slots.add(slot);
      currentMinutes += 15;
    }
    return slots;
  }

  TimeOfDay _parseTime(String time) {
    var parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
  void _confirmBooking() async {
    if (_selectedTimeSlot == null) return;

    String paymentName = _paymentMethod.getMethodName();

    Map<String, dynamic> appointment = {
      'patientId': widget.patientId,
      'doctorId': widget.doctor.id,
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'time': _selectedTimeSlot,
      'status': 'pending',
      'paymentMethod': paymentName,
    };

    await _repo.bookAppointment(appointment);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking Successful!"), backgroundColor: Colors.green)
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book with Dr. ${widget.doctorName}", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _doctorSchedules.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          CalendarDatePicker(
            initialDate: _selectedDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 30)),
            selectableDayPredicate: (day) => _isDoctorWorkingOnDate(day),
            onDateChanged: (newDate) {
              setState(() => _selectedDate = newDate);
              _generateSlotsForDate(newDate);
            },
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                "Available Slots",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),
          ),

          Expanded(
            child: _isLoadingSlots
                ? const Center(child: CircularProgressIndicator())
                : _availableSlots.isEmpty
                ? const Center(child: Text("No slots available."))
                : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 2.2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _availableSlots.length,
              itemBuilder: (context, index) {
                String slot = _availableSlots[index];
                bool isBooked = _bookedSlots.contains(slot);
                bool isSelected = slot == _selectedTimeSlot;

                return ChoiceChip(
                  label: Text(
                    slot,
                    style: TextStyle(
                        color: isBooked ? Colors.white : (isSelected ? Colors.white : Colors.black),
                        fontSize: 12
                    ),
                  ),
                  selected: isSelected,
                  onSelected: isBooked ? null : (selected) {
                    setState(() => _selectedTimeSlot = slot);
                  },
                  disabledColor: Colors.red.shade300,
                  selectedColor: Colors.blue,
                  backgroundColor: Colors.grey.shade200,
                );
              },
            ),
          ),

          const Divider(),
          const Text("Payment Method", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

          RadioListTile<String>(
            title: const Text("Cash"),
            value: "Cash",
            groupValue: _paymentMethod.getMethodName(),
            onChanged: (val) => setState(() => _paymentMethod = CashPaymentStrategy()),
          ),
          RadioListTile<String>(
            title: const Text("Credit Card"),
            value: "Credit Card",
            groupValue: _paymentMethod.getMethodName(),
            onChanged: (val) => setState(() => _paymentMethod = CreditCardPaymentStrategy()),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedTimeSlot == null ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.all(15)
                ),
                child: const Text("Confirm Booking", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          )
        ],
      ),
    );
  }
}