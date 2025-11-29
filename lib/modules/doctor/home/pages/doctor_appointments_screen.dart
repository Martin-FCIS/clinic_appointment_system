import 'package:clinic_appointment_system/repositories/clinic_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // تأكد من وجود المكتبة دي

class DoctorAppointmentsScreen extends StatefulWidget {
  final int doctorId;
  const DoctorAppointmentsScreen({super.key, required this.doctorId});

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  final ClinicRepository _repository = ClinicRepository.getInstance();
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final data = await _repository.getDoctorAppointments(widget.doctorId);
    if (mounted) {
      setState(() {
        _appointments = data;
        _isLoading = false;
      });
    }
  }

  // دالة تغيير الحالة (Accept/Decline)
  void _updateStatus(int appointmentId, String status) async {
    await _repository.updateAppointmentStatus(appointmentId, status);
    _loadAppointments();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Appointment marked as $status"),
          backgroundColor: status == 'approved' ? Colors.blue : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // 🔥 1. دالة إعادة الجدولة (Reschedule Logic)
  // ============================================================
  void _rescheduleAppointment(int id, String newDate, String newTime) async {
    // تأكد إن الدالة دي موجودة في Repo و DatabaseHelper
    await _repository.rescheduleAppointment(id, newDate, newTime);
    _loadAppointments();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment Rescheduled Successfully!"), backgroundColor: Colors.green),
      );
    }
  }

  // ============================================================
  // 🔥 2. دالة عرض الديالوج (Date & Time Picker)
  // ============================================================
  void _showRescheduleDialog(Map<String, dynamic> item) {
    // لا تسمح بالتعديل لو الحجز ملغي أو منتهي
    if (item['status'] == 'cancelled' || item['status'] == 'completed') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot edit cancelled or completed appointments"), backgroundColor: Colors.grey),
      );
      return;
    }

    TextEditingController dateController = TextEditingController(text: item['date']);
    TextEditingController timeController = TextEditingController(text: item['time']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reschedule Appointment"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // اختيار التاريخ
            TextField(
              controller: dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "New Date",
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.parse(item['date']),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (pickedDate != null) {
                  dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                }
              },
            ),
            const SizedBox(height: 15),
            // اختيار الوقت
            TextField(
              controller: timeController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "New Time",
                prefixIcon: Icon(Icons.access_time),
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                TimeOfDay initialTime;
                try {
                  var parts = item['time'].split(':');
                  initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
                } catch (e) {
                  initialTime = TimeOfDay.now();
                }

                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: initialTime,
                );

                if (pickedTime != null) {
                  // تحويل الوقت لصيغة HH:mm للتخزين
                  String formattedTime =
                      '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                  timeController.text = formattedTime;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _rescheduleAppointment(item['id'], dateController.text, timeController.text);
            },
            child: const Text("Save Changes"),
          ),
        ],
      ),
    );
  }

  // دالة تنسيق العرض (من - إلى)
  String _formatAppointmentRange(String startTime, BuildContext context) {
    try {
      final parts = startTime.split(':');
      final start = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      final startInMinutes = start.hour * 60 + start.minute;
      final endInMinutes = startInMinutes + 15;
      final end = TimeOfDay(hour: endInMinutes ~/ 60, minute: endInMinutes % 60);
      return "${start.format(context)} - ${end.format(context)}";
    } catch (e) {
      return startTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("My Appointments", style: TextStyle(fontSize: 30, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            tooltip: "Add Dummy Data",
            onPressed: () async {
              //await _repository.addDummyData(widget.doctorId);
              _loadAppointments();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Dummy data added!"), backgroundColor: Colors.blue),
              );
            },
          )
        ],
        backgroundColor: Colors.blue,
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadAppointments,
        child: _appointments.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _appointments.length,
          itemBuilder: (context, index) {
            return _buildAppointmentCard(_appointments[index]);
          },
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> item) {
    bool isPending = item['status'] == 'pending';
    Color statusColor = _getStatusColor(item['status']);

    // استخراج طريقة الدفع (مع قيمة احتياطية)
    String paymentMethod = item['paymentMethod'] ?? 'Cash';
    IconData paymentIcon = paymentMethod == 'Credit Card' ? Icons.credit_card : Icons.money;

    // هنا بنستخدم InkWell عشان نخلي الكارت كله قابل للضغط
    return InkWell(
      onTap: () => _showRescheduleDialog(item), // ✅ الدالة بقت موجودة فوق
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 6, color: statusColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue.shade50,
                                  radius: 20,
                                  child: Text(
                                    item['patientName'][0].toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['patientName'],
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item['status'].toUpperCase(),
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // أيقونة القلم عشان الدكتور يعرف إنه يقدر يعدل
                            const Icon(Icons.edit_calendar, color: Colors.grey, size: 20),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // السطر الثاني: التاريخ والوقت
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(item['date'], style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                            const SizedBox(width: 20),
                            const Icon(Icons.access_time_outlined, size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            // استخدام دالتك لعرض الوقت
                            Text(
                                _formatAppointmentRange(item['time'], context),
                                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // 🔥 السطر الثالث: طريقة الدفع (الجديد)
                        Row(
                          children: [
                            Icon(paymentIcon, size: 16, color: Colors.blueGrey),
                            const SizedBox(width: 6),
                            Text(
                                "Payment: $paymentMethod",
                                style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 13)
                            ),
                          ],
                        ),

                        // أزرار التحكم (تظهر فقط لو الحالة Pending)
                        if (isPending) ...[
                          const SizedBox(height: 15),
                          const Divider(),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _updateStatus(item['id'], 'cancelled'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text("Decline"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _updateStatus(item['id'], 'approved'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text("Accept"),
                                ),
                              ),
                            ],
                          )
                        ]
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          Text("No Reservations Yet", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'completed': return Colors.grey;
      default: return Colors.orange;
    }
  }
}