import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:duitkuu/models/expense.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'duitkuu.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create table saat database dibuat pertama kali
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_item TEXT NOT NULL,
        harga INTEGER NOT NULL,
        kategori TEXT NOT NULL,
        tanggal TEXT NOT NULL,
        catatan TEXT,
        foto_path TEXT,
        transaction_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Insert dummy data
    await _insertDummyData(db);
  }

  /// Handle database upgrade dari versi lama ke baru
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add foto_path column ke tabel yang sudah ada
      await db
          .execute('''
        ALTER TABLE expenses ADD COLUMN foto_path TEXT
      ''')
          .catchError((e) {
            print('Error adding foto_path column: $e');
          });
    }
    if (oldVersion < 3) {
      // Add transaction_id column untuk group items
      await db
          .execute('''
        ALTER TABLE expenses ADD COLUMN transaction_id TEXT
      ''')
          .catchError((e) {
            print('Error adding transaction_id column: $e');
          });
    }
  }

  /// Insert dummy data untuk testing
  Future<void> _insertDummyData(Database db) async {
    final now = DateTime.now();
    final today = now.toString().split(' ')[0];
    final yesterday = now
        .subtract(const Duration(days: 1))
        .toString()
        .split(' ')[0];
    final twoDaysAgo = now
        .subtract(const Duration(days: 2))
        .toString()
        .split(' ')[0];

    final createdAt = DateTime.now().toIso8601String();

    await db.insert('expenses', {
      'nama_item': 'Kopi Pagi',
      'harga': 15000,
      'kategori': 'Minuman',
      'tanggal': today,
      'catatan': 'Kopi di kafe langganan',
      'created_at': createdAt,
      'updated_at': createdAt,
    });

    await db.insert('expenses', {
      'nama_item': 'Nasi Goreng Mie',
      'harga': 25000,
      'kategori': 'Makanan',
      'tanggal': today,
      'catatan': 'Makan siang di rumah makan',
      'created_at': createdAt,
      'updated_at': createdAt,
    });

    await db.insert('expenses', {
      'nama_item': 'Bensin Motor',
      'harga': 50000,
      'kategori': 'Transport',
      'tanggal': today,
      'catatan': 'Isi bensin premium',
      'created_at': createdAt,
      'updated_at': createdAt,
    });

    await db.insert('expenses', {
      'nama_item': 'Buku Programming',
      'harga': 75000,
      'kategori': 'Belanja',
      'tanggal': yesterday,
      'catatan': 'Buku Flutter Advanced',
      'created_at': createdAt,
      'updated_at': createdAt,
    });

    await db.insert('expenses', {
      'nama_item': 'Tiket Bioskop',
      'harga': 45000,
      'kategori': 'Hiburan',
      'tanggal': yesterday,
      'catatan': 'Nonton film bersama teman',
      'created_at': createdAt,
      'updated_at': createdAt,
    });

    await db.insert('expenses', {
      'nama_item': 'Pembelian Kebutuhan Rumah',
      'harga': 120000,
      'kategori': 'Kebutuhan',
      'tanggal': twoDaysAgo,
      'catatan': 'Sabun, sampo, pasta gigi',
      'created_at': createdAt,
      'updated_at': createdAt,
    });
  }

  /// Get semua expenses
  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final result = await db.query('expenses', orderBy: 'tanggal DESC');
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  /// Get expense by ID
  Future<Expense?> getExpenseById(int id) async {
    final db = await database;
    final result = await db.query('expenses', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Expense.fromMap(result.first);
    }
    return null;
  }

  /// Insert expense
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update expense
  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  /// Delete expense
  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  /// Get expenses by tanggal
  Future<List<Expense>> getExpensesByDate(String date) async {
    final db = await database;
    final result = await db.query(
      'expenses',
      where: 'tanggal = ?',
      whereArgs: [date],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  /// Get expenses dalam range tanggal
  Future<List<Expense>> getExpensesByDateRange(
    String startDate,
    String endDate,
  ) async {
    final db = await database;
    final result = await db.query(
      'expenses',
      where: 'tanggal BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: 'tanggal DESC',
    );
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  /// Get expenses by kategori
  Future<List<Expense>> getExpensesByCategory(String category) async {
    final db = await database;
    final result = await db.query(
      'expenses',
      where: 'kategori = ?',
      whereArgs: [category],
      orderBy: 'tanggal DESC',
    );
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  /// Search expenses by nama_item
  Future<List<Expense>> searchExpenses(String query) async {
    final db = await database;
    final result = await db.query(
      'expenses',
      where: 'nama_item LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'tanggal DESC',
    );
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  /// Reset database - hapus semua data
  Future<void> resetDatabase() async {
    final db = await database;
    await db.delete('expenses');
  }
}
