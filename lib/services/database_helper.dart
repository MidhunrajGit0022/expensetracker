import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/category.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expenses.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE expenses (
      id TEXT PRIMARY KEY,
      title TEXT,
      amount REAL,
      date TEXT,
      categoryId TEXT,
      type TEXT
    )
    ''');
    await db.execute('''
    CREATE TABLE categories (
      id TEXT PRIMARY KEY,
      name TEXT,
      color INTEGER,
      icon INTEGER
    )
    ''');
    await _createSettingsTable(db);
    await _populateDefaultCategories(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createSettingsTable(db);
    }
    if (oldVersion < 3) {
      await db.execute(
        "ALTER TABLE expenses ADD COLUMN type TEXT DEFAULT 'expense'",
      );
    }
    if (oldVersion < 4) {
      await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT,
        color INTEGER,
        icon INTEGER
      )
      ''');
      await _populateDefaultCategories(db);
    }
  }

  Future<void> _populateDefaultCategories(Database db) async {
    final List<Map<String, dynamic>> defaults = [
      {
        'id': 'food',
        'name': 'Food',
        'color': 0xFFFB8C00,
        'icon': 0xe25a,
      }, // orange, fastfood
      {
        'id': 'transport',
        'name': 'Transport',
        'color': 0xFF2196F3,
        'icon': 0xe1d1,
      }, // blue, directions_car
      {
        'id': 'shopping',
        'name': 'Shopping',
        'color': 0xFF9C27B0,
        'icon': 0xe59c,
      }, // purple, shopping_bag
      {
        'id': 'entertainment',
        'name': 'Entertainment',
        'color': 0xFFFF5252,
        'icon': 0xe405,
      }, // redAccent, movie
      {
        'id': 'health',
        'name': 'Health',
        'color': 0xFF4CAF50,
        'icon': 0xe3e3,
      }, // green, medical_services
      {
        'id': 'education',
        'name': 'Education',
        'color': 0xFF3F51B5,
        'icon': 0xe559,
      }, // indigo, school
      {
        'id': 'others',
        'name': 'Others',
        'color': 0xFF9E9E9E,
        'icon': 0xe402,
      }, // grey, more_horiz
    ];

    for (var cat in defaults) {
      await db.insert(
        'categories',
        cat,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> _createSettingsTable(Database db) async {
    await db.execute('''
    CREATE TABLE settings (
      key TEXT PRIMARY KEY,
      value TEXT
    )
    ''');
  }

  Future<void> insertExpense(Expense expense) async {
    final db = await instance.database;
    await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Expense>> getExpenses() async {
    final db = await instance.database;
    final result = await db.query('expenses', orderBy: 'date DESC');
    return result.map((json) => Expense.fromMap(json)).toList();
  }

  Future<void> deleteExpense(String id) async {
    final db = await instance.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertCategory(Category category) async {
    final db = await instance.database;
    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Category>> getCategories() async {
    final db = await instance.database;
    final result = await db.query('categories');
    return result.map((json) => Category.fromMap(json)).toList();
  }

  Future<void> deleteCategory(String id) async {
    final db = await instance.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setSalary(double salary) async {
    final db = await instance.database;
    await db.insert('settings', {
      'key': 'salary',
      'value': salary.toString(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<double> getSalary() async {
    final db = await instance.database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['salary'],
    );
    if (result.isNotEmpty) {
      return double.tryParse(result.first['value'] as String) ?? 0.0;
    }
    return 0.0;
  }

  Future<void> setTheme(bool isDark) async {
    final db = await instance.database;
    await db.insert('settings', {
      'key': 'isDark',
      'value': isDark.toString(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool> getTheme() async {
    final db = await instance.database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['isDark'],
    );
    if (result.isNotEmpty) {
      return result.first['value'] == 'true';
    }
    return true; // Default to dark
  }

  Future<void> setLocale(String languageCode) async {
    final db = await instance.database;
    await db.insert('settings', {
      'key': 'locale',
      'value': languageCode,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String> getLocale() async {
    final db = await instance.database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['locale'],
    );
    if (result.isNotEmpty) {
      return result.first['value'] as String;
    }
    return 'en'; // Default to English
  }
}
