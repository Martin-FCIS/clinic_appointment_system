import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../core/utils/security_utils.dart';
import '../models/user_factory.dart';
import '../models/user_model.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;

  static Database? _database;

  DatabaseHelper._();

  static DatabaseHelper getInstance() {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('clinic.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Role: 1=Admin, 2=Doctor, 3=Patient
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        role INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE doctors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        specialty TEXT NOT NULL,
        price REAL NOT NULL,
        status TEXT DEFAULT 'pending', -- (New) حالة الدكتور: pending, approved, rejected
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        doctorId INTEGER NOT NULL, -- مربوط بجدول الدكاترة
        day TEXT NOT NULL,       -- "Saturday", "Monday"
        startTime TEXT NOT NULL, -- "10:00"
        endTime TEXT NOT NULL,   -- "14:00"
        FOREIGN KEY (doctorId) REFERENCES doctors (id) ON DELETE CASCADE
      )
    ''');

    // Status: 'pending', 'confirmed', 'completed', 'cancelled'
    await db.execute('''
      CREATE TABLE appointments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patientId INTEGER NOT NULL,
        doctorId INTEGER NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        FOREIGN KEY (patientId) REFERENCES users (id),
        FOREIGN KEY (doctorId) REFERENCES doctors (id)
      )
    ''');
    String adminPass = SecurityUtils.hashPassword("admin123");
    User adminUser = UserFactory.createUser(
      name: 'System Admin',
      email: 'admin@clinic.com',
      password: adminPass,
      role: RoleType.ADMIN,
    );
    await db.insert('users', adminUser.toMap());
    print("✅ Default Admin Created Successfully using Factory");


    // ملاحظة: التعامل مع الوقت في SQLite بيكون Text (ISO8601 Strings)
  }
      //auth
  Future<int> createUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }
  Future<bool> isEmailExists(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }
  Future<User?> getUserById(int id) async {
    final db = await database;
    var result = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id]
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<int> saveDoctorProfile(Map<String, dynamic> doctorData) async {
    final db = await database;

    var result = await db.query(
        'doctors',
        where: 'userId = ?',
        whereArgs: [doctorData['userId']]
    );

    if (result.isEmpty) {
      return await db.insert('doctors', doctorData);
    } else {
      var dataToUpdate = Map<String, dynamic>.from(doctorData);
      dataToUpdate.remove('id');
      return await db.update(
          'doctors',
          dataToUpdate,
          where: 'userId = ?',
          whereArgs: [doctorData['userId']]
      );
    }
  }
  Future<Map<String, dynamic>?> getDoctorDetails(int userId) async {
    final db = await database;
    var res = await db.query(
        'doctors',
        where: 'userId = ?',
        whereArgs: [userId]
    );
    return res.isNotEmpty ? res.first : null;
  }

  Future<int> addSchedule(Map<String, dynamic> schedule) async {
    final db = await database;
    return await db.insert('schedules', schedule);
  }
  Future<List<Map<String, dynamic>>> getDoctorSchedules(int doctorId) async {
    final db = await database;
    return await db.query(
        'schedules',
        where: 'doctorId = ?',
        whereArgs: [doctorId]
    );
  }
  Future<int> deleteSchedule(int scheduleId) async {
    final db = await database;
    return await db.delete(
        'schedules',
        where: 'id = ?',
        whereArgs: [scheduleId]
    );
  }
  Future<int> deleteSchedulesByDoctorId(int doctorId) async {
    final db = await database;
    return await db.delete(
        'schedules',
        where: 'doctorId = ?',
        whereArgs: [doctorId]
    );
  }

  Future<int> createAppointment(Map<String, dynamic> appointment) async {
    final db = await database;
    return await db.insert('appointments', appointment);
  }
  Future<List<Map<String, dynamic>>> getAllDoctors() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT doctors.id, users.name, doctors.specialty, doctors.price 
      FROM doctors
      INNER JOIN users ON doctors.userId = users.id
      WHERE doctors.status = 'approved'  -- (New) الشرط ده مهم جداً
    ''');
  }

  Future<int> updateAppointmentStatus(int appointmentId, String newStatus) async {
    final db = await database;
    return await db.update(
      'appointments',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [appointmentId],
    );
  }
  Future<List<Map<String, dynamic>>> getPatientAppointments(int patientId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT appointments.*, users.name as doctorName, doctors.specialty 
      FROM appointments
      INNER JOIN doctors ON appointments.doctorId = doctors.id
      INNER JOIN users ON doctors.userId = users.id
      WHERE appointments.patientId = ?
    ''', [patientId]);
  }

  Future<List<Map<String, dynamic>>> getDoctorAppointments(int doctorId) async {
    final db = await database;
    return await db.query(
      'appointments',
      where: 'doctorId = ?',
      whereArgs: [doctorId],
    );
  }
  Future<List<Map<String, dynamic>>> getPendingDoctors() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT doctors.id, users.name, doctors.specialty, doctors.status
      FROM doctors
      INNER JOIN users ON doctors.userId = users.id
      WHERE doctors.status = 'pending'
    ''');
  }
  Future<int> updateDoctorStatus(int doctorId, String newStatus) async {
    final db = await database;
    return await db.update(
      'doctors',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [doctorId],
    );
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
