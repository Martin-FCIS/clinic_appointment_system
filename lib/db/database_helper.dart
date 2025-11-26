import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
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

    // ملاحظة: التعامل مع الوقت في SQLite بيكون Text (ISO8601 Strings)
  }

  Future<int> createUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<int> createDoctorDetails(Map<String, dynamic> doctor) async {
    final db = await database;
    return await db.insert('doctors', doctor);
  }

  Future<int> createAppointment(Map<String, dynamic> appointment) async {
    final db = await database;
    return await db.insert('appointments', appointment);
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

  Future<List<Map<String, dynamic>>> getAllDoctors() async {
    final db = await database;
    // هنا بنعمل JOIN عشان نجيب اسم الدكتور من جدول الـ users وتخصصه من جدول الـ doctors
    return await db.rawQuery('''
      SELECT doctors.id, users.name, doctors.specialty, doctors.price 
      FROM doctors
      INNER JOIN users ON doctors.userId = users.id
    ''');
  }


  Future<List<Map<String, dynamic>>> getDoctorAppointments(int doctorId) async {
    final db = await database;
    return await db.query(
      'appointments',
      where: 'doctorId = ?',
      whereArgs: [doctorId],
    );
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
