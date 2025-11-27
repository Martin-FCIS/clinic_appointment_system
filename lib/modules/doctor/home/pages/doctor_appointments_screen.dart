import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../db/database_helper.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  final int doctorId;
  const DoctorAppointmentsScreen({super.key,required this.doctorId});

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadAppointments();
  }
  Future<void> _loadAppointments() async {
    final data = await DatabaseHelper.getInstance().getDoctorAppointments(widget.doctorId);
    if(mounted) {
      setState(() {
        _appointments = data;
        _isLoading = false;
      });
    }
  }
  void _updateStatus(int appointmentId, String status) async {
    await DatabaseHelper.getInstance().updateAppointmentStatus(appointmentId, status);
    _loadAppointments(); // Refresh list
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Appointment marked as $status"),
        backgroundColor: status == 'approved' ? Colors.blue : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text("ِMy Appointments", style: TextStyle(fontSize: 30, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            tooltip: "Add Dummy Data",
            onPressed: () async {
              await DatabaseHelper.getInstance().insertDummyAppointments(widget.doctorId);
              _loadAppointments();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Dummy data added! Pull to refresh if needed."),backgroundColor: Colors.blue,),
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

    return Container(
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
                        ],
                      ),

                      const SizedBox(height: 15),

                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(item['date'], style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                          const SizedBox(width: 20),
                          const Icon(Icons.access_time_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(item['time'], style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
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
                                  padding: const EdgeInsets.symmetric(vertical: 12),
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
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
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
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          Text(
            "No Reservations Yet",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 5),
          const Text(
            "When patients book appointments,\nthey will appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.orange;
    }
  }
}
