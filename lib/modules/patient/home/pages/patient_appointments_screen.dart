import 'package:clinic_appointment_system/modules/core_widgets/appointment_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/logic/appointment_filter_strategy.dart';
import '../../../../repositories/clinic_repository.dart';

enum FilterType { all, day, week }

class PatientAppointmentsScreen extends StatefulWidget {
  final int patientId;

  const PatientAppointmentsScreen({super.key, required this.patientId});

  @override
  State<PatientAppointmentsScreen> createState() =>
      _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends State<PatientAppointmentsScreen> {
  final ClinicRepository _repo = ClinicRepository.getInstance();
  List<Map<String, dynamic>> _allAppointments = [];
  List<Map<String, dynamic>> _displayedAppointments = [];
  bool _isLoading = true;
  FilterType _currentFilter = FilterType.all;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    var data = await _repo.getPatientAppointments(widget.patientId);
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

  void _cancelAppointment(int appointmentId) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            title: const Text("Cancel Appointment?"),
            content: const Text(
                "Are you sure you want to cancel this booking?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _repo.updateAppointmentStatus(
                      appointmentId, 'cancelled');

                  _loadData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Appointment Cancelled"),
                          backgroundColor: Colors.red),
                    );
                  }
                },
                child: const Text(
                    "Yes, Cancel", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Appointments",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      body: Column(
          children: [
          _buildFilterHeader(),
      Expanded(child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _displayedAppointments.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _displayedAppointments.length,
          itemBuilder: (context, index) {
            final item=_displayedAppointments[index];
            return AppointmentCard(item: item, isDoctorView: false,onCancel: () {
              _cancelAppointment(item['id']);
            },);
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
                        border: Border.all(color: Colors.blue.shade200)
                    ),
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
          Icon(Icons.calendar_month_outlined, size: 80,
              color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text("No Appointments Yet", style: TextStyle(fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, shape: const StadiumBorder()),
            child: const Text(
                "Book Now", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}