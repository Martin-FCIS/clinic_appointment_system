import 'package:clinic_appointment_system/core/routes/app_routes_name.dart';
import 'package:clinic_appointment_system/repositories/clinic_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/logic/appointment_filter_strategy.dart';
import '../../../../core_widgets/appointment_card.dart';
enum FilterType { all, day, week }
class AdminAppointmentsScreen extends StatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  State<AdminAppointmentsScreen> createState() =>
      _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends State<AdminAppointmentsScreen> {
  final ClinicRepository _repository = ClinicRepository.getInstance();
  List<Map<String, dynamic>> _allAppointments = [];
  List<Map<String, dynamic>> _displayedAppointments = [];
  bool _isLoading = true;
  FilterType _currentFilter = FilterType.all;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final data = await _repository.getAllAppointments();
    if (mounted) {
      setState(() {
        _allAppointments = data;
        _isLoading = false;
        _applyFilter();
      });
    }
  }
  void _applyFilter() {
    setState(() {
      AppointmentFilterStrategy strategy;
      switch(_currentFilter){
        case FilterType.day:
          strategy = DayAppointmentsStrategy();
          break;
        case FilterType.week:
          strategy=WeekAppointmentsStrategy();
          break;
        case FilterType.all:
        default:
          strategy=AllAppointmentsStrategy();
          break;
      }
      _displayedAppointments=strategy.execute(_allAppointments, _selectedDate);
    });
  }
  void _setFilter(FilterType type) {
    setState(() {
      _currentFilter = type;
      _applyFilter();
    });
  }
  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      _applyFilter();
    });
  }
  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _applyFilter();
      });
    }
  }

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

  void _rescheduleAppointment(int id, String newDate, String newTime) async {
    await _repository.rescheduleAppointment(id, newDate, newTime);
    _loadAppointments();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Appointment Rescheduled Successfully!"),
            backgroundColor: Colors.green),
      );
    }
  }

  void _showRescheduleDialog(Map<String, dynamic> item) {
    if (item['status'] == 'cancelled' || item['status'] == 'completed') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Cannot edit cancelled or completed appointments"),
            backgroundColor: Colors.grey),
      );
      return;
    }

    TextEditingController dateController =
        TextEditingController(text: item['date']);
    TextEditingController timeController =
        TextEditingController(text: item['time']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reschedule Appointment"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                  dateController.text =
                      DateFormat('yyyy-MM-dd').format(pickedDate);
                }
              },
            ),
            const SizedBox(height: 15),
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
                  initialTime = TimeOfDay(
                      hour: int.parse(parts[0]), minute: int.parse(parts[1]));
                } catch (e) {
                  initialTime = TimeOfDay.now();
                }

                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: initialTime,
                );

                if (pickedTime != null) {
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
              _rescheduleAppointment(
                  item['id'], dateController.text, timeController.text);
            },
            child: const Text("Save Changes"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(
                context, AppRoutesName.adminHomeScreen);
          },
          icon: Icon(Icons.arrow_back),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("All Appointments", // Changed Title
            style: TextStyle(fontSize: 24, color: Colors.white)),
        backgroundColor: Colors.blue,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator()):RefreshIndicator(
                    onRefresh: _loadAppointments,
                    child: _displayedAppointments.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _displayedAppointments.length,
                            itemBuilder: (context, index) {
                              final item=_displayedAppointments[index];
                              return  AppointmentCard(
                                item: item,
                                isDoctorView: true,
                                isAdmin: true,
                                onStatusChange: (status) => _updateStatus(item['id'], status),
                                onTap: () => _showRescheduleDialog(item),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
  Widget _buildFilterHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFilterChip("All", FilterType.all),
              const SizedBox(width: 10),
              _buildFilterChip("Day", FilterType.day),
              const SizedBox(width: 10),
              _buildFilterChip("Week", FilterType.week),
            ],
          ),
          if (_currentFilter != FilterType.all) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                  onPressed: () => _changeDate(_currentFilter == FilterType.week ? -7 : -1),
                ),
                InkWell(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade200)),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          _currentFilter == FilterType.day
                              ? DateFormat('EEE, d MMM yyyy').format(_selectedDate)
                              : "Week: ${DateFormat('d MMM').format(_selectedDate)}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 18),
                  onPressed: () => _changeDate(_currentFilter == FilterType.week ? 7 : 1),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }
  Widget _buildFilterChip(String label, FilterType type) {
    bool isSelected = _currentFilter == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => _setFilter(type),
      selectedColor: Colors.blue,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      backgroundColor: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month_outlined,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          Text("No Reservations Found",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
