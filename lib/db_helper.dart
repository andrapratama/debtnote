import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  static Database? _database;

  DbHelper._internal();

  factory DbHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'catatan_utang.db');
    return await openDatabase(
      path,
      version: 2, // Versi database dinaikkan
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Dijalankan saat DB dibuat pertama kali
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE utang (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal TEXT,
        keterangan TEXT,
        nilai INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE bayar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal TEXT,
        keterangan TEXT,
        nilai INTEGER
      )
    ''');
  }

  // Dijalankan saat ada perubahan versi (misal: dari 1 ke 2)
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Tambahkan tabel 'bayar' jika datang dari versi 1
      await db.execute('''
        CREATE TABLE bayar (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tanggal TEXT,
          keterangan TEXT,
          nilai INTEGER
        )
      ''');
    }
  }

  // --- Operasi Tabel Utang ---

  Future<int> insertUtang(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('utang', row);
  }

  Future<List<Map<String, dynamic>>> getUtangList() async {
    Database db = await database;
    return await db.query('utang', orderBy: "id DESC");
  }

  Future<int> deleteUtang(int id) async {
    Database db = await database;
    return await db.delete('utang', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllUtang() async {
    Database db = await database;
    return await db.delete('utang');
  }

  // --- Operasi Tabel Bayar ---

  Future<int> insertBayar(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('bayar', row);
  }

  Future<List<Map<String, dynamic>>> getBayarList() async {
    Database db = await database;
    return await db.query('bayar', orderBy: "id DESC");
  }

  Future<int> deleteBayar(int id) async {
    Database db = await database;
    return await db.delete('bayar', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllBayar() async {
    Database db = await database;
    return await db.delete('bayar');
  }
}
