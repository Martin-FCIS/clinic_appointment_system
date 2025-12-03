import 'package:flutter/material.dart';

import '../../../../repositories/clinic_repository.dart';

class PatientAppointmentsScreen extends StatefulWidget {
  final int patientId;
  const PatientAppointmentsScreen({super.key,required this.patientId});

  @override
  State<PatientAppointmentsScreen> createState() => _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends State<PatientAppointmentsScreen> {
  final ClinicRepository _repo = ClinicRepository.getInstance();
  List<Map<String, dynamic>> _myAppointments = [];
  bool _isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
  }
  void _loadData()async{
    var data = await _repo.getPatientAppointments(widget.patientId);
    if (mounted) {
      setState(() {
        _myAppointments = data;
        _isLoading = false;
      });
    }
  }
  void _cancelAppointment(int appointmentId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancel Appointment?"),
        content: const Text("Are you sure you want to cancel this booking?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _repo.updateAppointmentStatus(appointmentId, 'cancelled');

              _loadData();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Appointment Cancelled"), backgroundColor: Colors.red),
              );
            },
            child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Appointments", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () async {
              _loadData();
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myAppointments.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _myAppointments.length,
          itemBuilder: (context, index) {
            return _buildAppointmentCard(_myAppointments[index]);
          },
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> item) {
    String status = item['status'];
    Color statusColor = _getStatusColor(status);
    IconData statusIcon = _getStatusIcon(status);

    bool canCancel = status != 'cancelled' && status != 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Dr. ${item['doctorName']}",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                item['specialty'],
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                          _buildStatusBadge(status, statusColor, statusIcon),
                        ],
                      ),

                      const SizedBox(height: 15),
                      const Divider(),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          _buildInfoChip(Icons.calendar_today_outlined, item['date']),
                          const SizedBox(width: 15),
                          _buildInfoChip(
                              Icons.access_time_rounded,
                              _formatAppointmentRange(item['time'], context)
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          _buildInfoChip(Icons.monetization_on_outlined, "${item['price']} EGP"),
                          const SizedBox(width: 15),
                          _buildInfoChip(Icons.payment, "${item['paymentMethod']}"),
                        ],
                      ),

                      if (canCancel) ...[
                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () => _cancelAppointment(item['id']),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.red.shade200)
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
                                  SizedBox(width: 4),
                                  Text("Cancel Booking", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
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
    );
  }

  Widget _buildStatusBadge(String status, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            status.toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text("No Appointments Yet", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: const StadiumBorder()),
            child: const Text("Book Now", style: TextStyle(color: Colors.white)),
          )
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved': return Icons.check_circle;
      case 'cancelled': return Icons.cancel;
      case 'completed': return Icons.history;
      default: return Icons.hourglass_bottom;
    }
  }
}