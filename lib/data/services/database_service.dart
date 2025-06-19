import 'package:mediremind/data/models/drug_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class DatabaseService {
  static final DatabaseService instance = DatabaseService._constructor();
  static Database? _db;

  // Drugs table
  final String _drugsTableName = "drugs";
  final String _drugsId = "id";
  final String _drugsName = "name";
  final String _drugsDosage = "dosage";
  final String _drugsHour = "hour";
  final String _drugsFrequency = "frequency";
  final String _drugsIsTaken = "is_taken";


  // DatabaseService's Constructor
  DatabaseService._constructor();

  Future<Database?> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db;
  }

  /// Setup the database and provide space to save database in device directory
  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    // Join path to database
    final databasePath = join(databaseDirPath, "masterDatabase.db");
    // Open database
    final database = await openDatabase(
      databasePath,
      version: 2,
      // Define logic when database is being created
      onCreate: (db, version) {

        // Create drugs table
        db.execute('''
          CREATE TABLE $_drugsTableName (
            $_drugsId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_drugsName TEXT NOT NULL,
            $_drugsDosage TEXT NOT NULL,
            $_drugsHour TEXT NOT NULL,
            $_drugsFrequency TEXT NOT NULL,
            $_drugsIsTaken INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
      // Handle database upgrades
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          // Add drugs table for existing databases
          db.execute('''
            CREATE TABLE $_drugsTableName (
              $_drugsId INTEGER PRIMARY KEY AUTOINCREMENT,
              $_drugsName TEXT NOT NULL,
              $_drugsDosage TEXT NOT NULL,
              $_drugsHour TEXT NOT NULL,
              $_drugsFrequency TEXT NOT NULL,
              $_drugsIsTaken INTEGER NOT NULL DEFAULT 0
            )
          ''');
        }
      },
    );
    return database;
  }

  // CRUD Operations for Drugs

  // CREATE - Add a new drug
  Future<int> addDrug(Drug drug) async {
    final db = await database;
    return await db!.insert(_drugsTableName, drug.toMap());
  }

  // READ - Get all drugs
  Future<List<Drug>> getAllDrugs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(_drugsTableName);
    return List.generate(maps.length, (i) => Drug.fromMap(maps[i]));
  }

  // READ - Get drug by ID
  Future<Drug?> getDrugById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      _drugsTableName,
      where: '$_drugsId = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Drug.fromMap(maps.first);
    }
    return null;
  }

  // READ - Get drugs by taken status
  Future<List<Drug>> getDrugsByStatus(bool isTaken) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      _drugsTableName,
      where: '$_drugsIsTaken = ?',
      whereArgs: [isTaken ? 1 : 0],
    );
    return List.generate(maps.length, (i) => Drug.fromMap(maps[i]));
  }

  // UPDATE - Modify a drug
  Future<int> updateDrug(Drug drug) async {
    final db = await database;
    return await db!.update(
      _drugsTableName,
      drug.toMap(),
      where: '$_drugsId = ?',
      whereArgs: [drug.id],
    );
  }

  // UPDATE - Toggle drug taken status
  Future<int> toggleDrugStatus(int id) async {
    final db = await database;
    final drug = await getDrugById(id);
    if (drug != null) {
      return await db!.update(
        _drugsTableName,
        {'is_taken': drug.isTaken ? 0 : 1},
        where: '$_drugsId = ?',
        whereArgs: [id],
      );
    }
    return 0;
  }

  // DELETE - Remove a drug by ID
  Future<int> deleteDrug(int id) async {
    final db = await database;
    return await db!.delete(
      _drugsTableName,
      where: '$_drugsId = ?',
      whereArgs: [id],
    );
  }

  // DELETE - Remove all drugs
  Future<int> deleteAllDrugs() async {
    final db = await database;
    return await db!.delete(_drugsTableName);
  }

  // UTILITY - Reset all drugs to not taken
  Future<int> resetAllDrugsStatus() async {
    final db = await database;
    return await db!.update(
      _drugsTableName,
      {'is_taken': 0},
    );
  }

  // UTILITY - Get count of drugs
  Future<int> getDrugsCount() async {
    final db = await database;
    final count = await db!.rawQuery('SELECT COUNT(*) FROM $_drugsTableName');
    return Sqflite.firstIntValue(count) ?? 0;
  }

  // UTILITY - Get count of taken drugs
  Future<int> getTakenDrugsCount() async {
    final db = await database;
    final count = await db!.rawQuery(
        'SELECT COUNT(*) FROM $_drugsTableName WHERE $_drugsIsTaken = 1'
    );
    return Sqflite.firstIntValue(count) ?? 0;
  }
}