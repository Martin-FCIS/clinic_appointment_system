import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
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
        status TEXT DEFAULT 'pending',
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        doctorId INTEGER NOT NULL, 
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
    paymentMethod TEXT NOT NULL, 
    FOREIGN KEY (patientId) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (doctorId) REFERENCES doctors (id) ON DELETE CASCADE
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
    var result = await db.query('users', where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int userId) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> saveDoctorProfile(Map<String, dynamic> doctorData) async {
    final db = await database;

    var result = await db.query('doctors',
        where: 'userId = ?', whereArgs: [doctorData['userId']]);

    if (result.isEmpty) {
      return await db.insert('doctors', doctorData);
    } else {
      var dataToUpdate = Map<String, dynamic>.from(doctorData);
      dataToUpdate.remove('id');
      return await db.update('doctors', dataToUpdate,
          where: 'userId = ?', whereArgs: [doctorData['userId']]);
    }
  }

  Future<Map<String, dynamic>?> getDoctorDetails(int userId) async {
    final db = await database;
    var res =
        await db.query('doctors', where: 'userId = ?', whereArgs: [userId]);
    return res.isNotEmpty ? res.first : null;
  }

  Future<int> addSchedule(Map<String, dynamic> schedule) async {
    final db = await database;
    return await db.insert('schedules', schedule);
  }

  Future<List<Map<String, dynamic>>> getDoctorSchedules(int doctorId) async {
    final db = await database;
    return await db
        .query('schedules', where: 'doctorId = ?', whereArgs: [doctorId]);
  }

  Future<int> deleteSchedule(int scheduleId) async {
    final db = await database;
    return await db
        .delete('schedules', where: 'id = ?', whereArgs: [scheduleId]);
  }

  Future<int> deleteSchedulesByDoctorId(int doctorId) async {
    final db = await database;
    return await db
        .delete('schedules', where: 'doctorId = ?', whereArgs: [doctorId]);
  }

  Future<int> createAppointment(Map<String, dynamic> appointment) async {
    final db = await database;
    return await db.insert('appointments', appointment);
  }

  Future<List<Map<String, dynamic>>> getAllDoctors() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT doctors.id, users.name, doctors.userId, doctors.status,doctors.specialty, doctors.price 
      FROM doctors
      INNER JOIN users ON doctors.userId = users.id
      WHERE doctors.status = 'approved' 
    ''');
  }

  Future<int> updateAppointmentStatus(
      int appointmentId, String newStatus) async {
    final db = await database;
    return await db.update(
      'appointments',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [appointmentId],
    );
  }

  Future<int> rescheduleAppointment(
      int appointmentId, String newDate, String newTime) async {
    final db = await database;
    return await db.update(
      'appointments',
      {
        'date': newDate,
        'time': newTime,
        'status': 'approved',
      },
      where: 'id = ?',
      whereArgs: [appointmentId],
    );
  }

  Future<List<Map<String, dynamic>>> getPatientAppointments(
      int patientId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT appointments.*, users.name as doctorName, doctors.specialty,doctors.price 
      FROM appointments
      INNER JOIN doctors ON appointments.doctorId = doctors.id
      INNER JOIN users ON doctors.userId = users.id
      WHERE appointments.patientId = ?
    ''', [patientId]);
  }

  Future<List<Map<String, dynamic>>> getDoctorAppointments(int doctorId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT appointments.*, users.name as patientName 
      FROM appointments
      INNER JOIN users ON appointments.patientId = users.id
      WHERE appointments.doctorId = ?
      ORDER BY appointments.id DESC
    ''', [doctorId]);
  }

  Future<List<Map<String, dynamic>>> getPendingDoctors() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT doctors.id, users.name, doctors.specialty,doctors.price, doctors.status
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

  Future<List<Map<String, dynamic>>> getAllAppointments() async {
    final db = await database;

    await updateExpiredAppointments();

    return await db.rawQuery('''
      SELECT 
        appointments.*, 
        patientUser.name as patientName, 
        doctorUser.name as doctorName,
        doctors.specialty as specialty,
        doctors.price as price
      FROM appointments
      -- Join to get Patient Info
      INNER JOIN users AS patientUser ON appointments.patientId = patientUser.id
      -- Join to get Doctor Info (link appointment -> doctor -> user)
      INNER JOIN doctors ON appointments.doctorId = doctors.id
      INNER JOIN users AS doctorUser ON doctors.userId = doctorUser.id
      
      ORDER BY appointments.date DESC, appointments.time DESC
    ''');
  }

  Future<void> updateExpiredAppointments() async {
    final db = await database;
    List<Map<String, dynamic>> appointments = await db.rawQuery('''
      SELECT * FROM appointments 
      WHERE status IN ('approved', 'pending')
    ''');

    DateTime now = DateTime.now();

    for (var app in appointments) {
      try {
        String dateStr = app['date'];
        String timeStr = app['time'];

        DateTime appDate = DateTime.parse(dateStr);
        List<String> timeParts = timeStr.split(':');
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);

        DateTime appointmentDateTime =
            DateTime(appDate.year, appDate.month, appDate.day, hour, minute);

        if (appointmentDateTime.isBefore(now)) {
          String currentStatus = app['status'];
          String newStatus;

          if (currentStatus == 'approved') {
            newStatus = 'completed';
          } else {
            newStatus = 'cancelled';
          }

          await db.update(
            'appointments',
            {'status': newStatus},
            where: 'id = ?',
            whereArgs: [app['id']],
          );

          print(
              "✅ Appointment ${app['id']} updated from $currentStatus to $newStatus");
        }
      } catch (e) {
        print("Error processing appointment ${app['id']}: $e");
      }
    }
  }

  Future<List<String>> getReservedTimes(int doctorId, String date) async {
    final db = await database;
    var result = await db.query(
      'appointments',
      columns: ['time'],
      where: 'doctorId = ? AND date = ? AND status != ?',
      whereArgs: [doctorId, date, 'cancelled'],
    );

    return result.map((e) => e['time'] as String).toList();
  }

  Future<Map<String, dynamic>?> getDoctorAndUserInfo(int doctorId) async {
    final db = await database;
    var res = await db.rawQuery('''
    SELECT 
      T1.id, 
      T1.userId, 
      T1.specialty, 
      T1.price, 
      T1.status, 
      T2.name, 
      T2.email
    FROM doctors T1
    INNER JOIN users T2 ON T1.userId = T2.id
    WHERE T1.id = ?
  ''', [doctorId]);

    if (res.isNotEmpty) {
      return res.first;
    }
    return null;
  }

  Future<int> updateDoctorData(
      int doctorId, String specialty, double price) async {
    final db = await database;
    return await db.update(
      'doctors',
      {
        'specialty': specialty,
        'price': price,
      },
      where: 'id = ?',
      whereArgs: [doctorId],
    );
  }

  Future<int> deleteDoctorAndUser(int doctorId) async {
    final db = await database;

    var doctorResult = await db.query('doctors',
        columns: ['userId'], where: 'id = ?', whereArgs: [doctorId]);

    if (doctorResult.isEmpty) return 0; // Doctor not found

    final userId = doctorResult.first['userId'] as int;

    return await deleteUser(userId);
  }

  Future<int> getUsersCount() async {
    final db = await database;
    var result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getDoctorsCount() async {
    final db = await database;
    var result = await db.rawQuery('SELECT COUNT(*) as count FROM doctors');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getPatientsCount() async {
    final db = await database;
    var result =
        await db.rawQuery('SELECT COUNT(*) as count FROM users WHERE role = 3');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getPendingDoctorsCount() async {
    final db = await database;
    var result = await db.rawQuery(
        "SELECT COUNT(*) as count FROM doctors WHERE status = 'pending'");
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getPendingAppointmentsCount() async {
    final db = await database;
    var result = await db.rawQuery(
        "SELECT COUNT(*) as count FROM appointments WHERE status = 'pending' ");
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
