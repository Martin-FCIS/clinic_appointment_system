import 'package:clinic_appointment_system/db/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/const_variables.dart';
import '../models/doctor_model.dart';
import '../models/schedule_model.dart';
import '../models/user_model.dart';

//facade
class ClinicRepository {
  static ClinicRepository? _instance;

  ClinicRepository._();

  static ClinicRepository getInstance() {
    _instance ??= ClinicRepository._();
    return _instance!;
  }

  final DatabaseHelper _databaseHelper = DatabaseHelper.getInstance();

  //shared pref
  static const String _specialtiesKey='SPECIALTIES_LIST';
  Future<List<String>> getSpecialties() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedList = prefs.getStringList(_specialtiesKey);

    if (savedList == null || savedList.isEmpty) {
      await prefs.setStringList(_specialtiesKey, ConstVariables.speciality);
      return ConstVariables.speciality;
    }
    return savedList;
  }
  Future<void> addSpecialty(String newSpecialty) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> currentList = await getSpecialties();
    if (!currentList.contains(newSpecialty)) {
      currentList.add(newSpecialty);
      await prefs.setStringList(_specialtiesKey, currentList);
    }
  }
  //user
  Future<int> registerUser(User user) async {
    return await _databaseHelper.createUser(user.toMap());
  }

  Future<User?> login(String email, String password) async {
    final map = await _databaseHelper.loginUser(email, password);
    return map != null ? User.fromMap(map) : null;
  }

  Future<User?> getUserById(int id) async {
    var map = await _databaseHelper.getUserById(id);
    return map;
  }

  Future<bool> isEmailExists(String email) async {
    return await _databaseHelper.isEmailExists(email);
  }

  Future<int> updateUser(User user) async {
    return await _databaseHelper.updateUser(user);
  }

  Future<int> deleteUser(int id) async {
    return await _databaseHelper.deleteUser(id);
  }

  //doctor
  Future<Doctor?> getDoctorDetails(int userId) async {
    final map = await _databaseHelper.getDoctorDetails(userId);
    return map != null ? Doctor.fromMap(map) : null;
  }

  Future<int> saveDoctorProfile(Doctor doctor) async {
    return await _databaseHelper.saveDoctorProfile(doctor.toMap());
  }

  //doctor schedules
  Future<List<Schedule>> getDoctorSchedules(int doctorId) async {
    final List<Map<String, dynamic>> maps =
        await _databaseHelper.getDoctorSchedules(doctorId);
    return maps.map((e) => Schedule.fromMap(e)).toList();
  }

  Future<int> addSchedule(Schedule schedule) async {
    return await _databaseHelper.addSchedule(schedule.toMap());
  }

  Future<int> deleteSchedule(int scheduleId) async {
    return await _databaseHelper.deleteSchedule(scheduleId);
  }

  Future<int> clearDoctorSchedules(int doctorId) async {
    return await _databaseHelper.deleteSchedulesByDoctorId(doctorId);
  }

  //doctor appointments
  Future<List<Map<String, dynamic>>> getDoctorAppointments(int doctorId) async {
    await _databaseHelper.updateExpiredAppointments();
    return await _databaseHelper.getDoctorAppointments(doctorId);
  }

  Future<List<Map<String, dynamic>>> getAllAppointments() async {
    return await _databaseHelper.getAllAppointments();
  }

  Future<int> updateAppointmentStatus(int id, String status) async {
    return await _databaseHelper.updateAppointmentStatus(id, status);
  }

  //patient
  Future<List<Map<String, dynamic>>> getAllApprovedDoctors() async {
    return await _databaseHelper.getAllDoctors();
  }

  //patient appointments
  Future<List<Map<String, dynamic>>> getPatientAppointments(
      int patientId) async {
    await _databaseHelper.updateExpiredAppointments();
    return await _databaseHelper.getPatientAppointments(patientId);
  }

  Future<int> bookAppointment(Map<String, dynamic> appointment) async {
    return await _databaseHelper.createAppointment(appointment);
  }

  Future<List<String>> getReservedTimes(int doctorId, String date) async {
    return await _databaseHelper.getReservedTimes(doctorId, date);
  }

  Future<int> rescheduleAppointment(int id, String date, String time) async {
    return await _databaseHelper.rescheduleAppointment(id, date, time);
  }

  Future<List<Map<String, dynamic>>> getPendingDoctors() async {
    return await _databaseHelper.getPendingDoctors();
  }

  Future<int> updateDoctorStatus(int doctorId, String status) async {
    return await _databaseHelper.updateDoctorStatus(doctorId, status);
  }

  Future<Map<String, dynamic>?> getDoctorById(int doctorId) async {
    return await _databaseHelper.getDoctorAndUserInfo(doctorId);
  }

  Future<int> updateDoctor(int doctorId, String specialty, double price) async {
    return await _databaseHelper.updateDoctorData(doctorId, specialty, price);
  }

  Future<int> deleteDoctor(int doctorId) async {
    return await _databaseHelper.deleteDoctorAndUser(doctorId);
  }

  Future<int> getUsersCount() async {
    return await _databaseHelper.getUsersCount();
  }

  Future<int> getDoctorsCount() async {
    return await _databaseHelper.getDoctorsCount();
  }

  Future<int> getPatientsCount() async {
    return await _databaseHelper.getPatientsCount();
  }

  Future<int> getPendingAppointmentsCount() async {
    return await _databaseHelper.getPendingAppointmentsCount();
  }

  Future<int> getPendingDoctorsCount() async {
    return await _databaseHelper.getPendingDoctorsCount();
  }

}
