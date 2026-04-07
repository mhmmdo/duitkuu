import 'package:duitkuu/databases/database_helper.dart';
import 'package:duitkuu/models/expense.dart';

class ExpenseService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Get semua expenses
  Future<List<Expense>> getAllExpenses() {
    return _dbHelper.getAllExpenses();
  }

  /// Get expense by ID
  Future<Expense?> getExpenseById(int id) {
    return _dbHelper.getExpenseById(id);
  }

  /// Tambah expense baru
  Future<int> addExpense(Expense expense) {
    return _dbHelper.insertExpense(expense);
  }

  /// Update expense
  Future<int> updateExpense(Expense expense) {
    return _dbHelper.updateExpense(expense);
  }

  /// Hapus expense
  Future<int> deleteExpense(int id) {
    return _dbHelper.deleteExpense(id);
  }

  /// Cari expenses
  Future<List<Expense>> searchExpenses(String query) {
    return _dbHelper.searchExpenses(query);
  }

  /// Get expenses by kategori
  Future<List<Expense>> getExpensesByCategory(String category) {
    return _dbHelper.getExpensesByCategory(category);
  }

  /// Get expenses by tanggal spesifik
  Future<List<Expense>> getExpensesByDate(String date) {
    return _dbHelper.getExpensesByDate(date);
  }

  /// Get expenses dalam range tanggal
  Future<List<Expense>> getExpensesByDateRange(
    String startDate,
    String endDate,
  ) {
    return _dbHelper.getExpensesByDateRange(startDate, endDate);
  }

  // ==================== ANALYTICS ====================

  /// Total pengeluaran hari ini
  Future<int> getTodayTotal() async {
    final today = DateTime.now().toString().split(' ')[0];
    final expenses = await _dbHelper.getExpensesByDate(today);
    return expenses.fold<int>(0, (sum, expense) => sum + expense.harga);
  }

  /// Total pengeluaran bulan ini
  Future<int> getMonthTotal() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(
      now.year,
      now.month,
      1,
    ).toString().split(' ')[0];
    final endOfMonth = DateTime(
      now.year,
      now.month + 1,
      0,
    ).toString().split(' ')[0];

    final expenses = await _dbHelper.getExpensesByDateRange(
      startOfMonth,
      endOfMonth,
    );
    return expenses.fold<int>(0, (sum, expense) => sum + expense.harga);
  }

  /// Total pengeluaran per bulan (untuk analisis)
  Future<Map<String, int>> getMonthlyTotals() async {
    final allExpenses = await _dbHelper.getAllExpenses();
    final monthlyMap = <String, int>{};

    for (final expense in allExpenses) {
      final monthKey = expense.tanggal.substring(0, 7); // YYYY-MM
      monthlyMap[monthKey] = (monthlyMap[monthKey] ?? 0) + expense.harga;
    }

    return monthlyMap;
  }

  /// Total pengeluaran per kategori
  Future<Map<String, int>> getTotalByCategory() async {
    final allExpenses = await _dbHelper.getAllExpenses();
    final categoryMap = <String, int>{};

    for (final expense in allExpenses) {
      categoryMap[expense.kategori] =
          (categoryMap[expense.kategori] ?? 0) + expense.harga;
    }

    return categoryMap;
  }

  /// Total pengeluaran per hari
  Future<Map<String, int>> getDailyTotals() async {
    final allExpenses = await _dbHelper.getAllExpenses();
    final dailyMap = <String, int>{};

    for (final expense in allExpenses) {
      dailyMap[expense.tanggal] =
          (dailyMap[expense.tanggal] ?? 0) + expense.harga;
    }

    return dailyMap;
  }

  /// Kategori dengan nominal terbesar
  Future<String?> getHighestCategory() async {
    final categoryTotals = await getTotalByCategory();
    if (categoryTotals.isEmpty) return null;

    String? highestCategory;
    int maxAmount = 0;

    categoryTotals.forEach((category, amount) {
      if (amount > maxAmount) {
        maxAmount = amount;
        highestCategory = category;
      }
    });

    return highestCategory;
  }

  /// Pengeluaran tertinggi (single transaction)
  Future<Expense?> getHighestExpense() async {
    final allExpenses = await _dbHelper.getAllExpenses();
    if (allExpenses.isEmpty) return null;

    Expense? highest = allExpenses.first;
    for (final expense in allExpenses) {
      if (highest != null && expense.harga > highest.harga) {
        highest = expense;
      }
    }

    return highest;
  }

  /// Jumlah transaksi bulan ini
  Future<int> getMonthTransactionCount() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(
      now.year,
      now.month,
      1,
    ).toString().split(' ')[0];
    final endOfMonth = DateTime(
      now.year,
      now.month + 1,
      0,
    ).toString().split(' ')[0];

    final expenses = await _dbHelper.getExpensesByDateRange(
      startOfMonth,
      endOfMonth,
    );
    return expenses.length;
  }

  /// Jumlah transaksi hari ini
  Future<int> getTodayTransactionCount() async {
    final today = DateTime.now().toString().split(' ')[0];
    final expenses = await _dbHelper.getExpensesByDate(today);
    return expenses.length;
  }

  /// Get transaksi terbaru (untuk dashboard)
  Future<List<Expense>> getRecentTransactions({int limit = 5}) async {
    final allExpenses = await _dbHelper.getAllExpenses();
    return allExpenses.take(limit).toList();
  }

  /// Kategorikan transaksi hari ini
  Future<Map<String, int>> getTodayByCategory() async {
    final today = DateTime.now().toString().split(' ')[0];
    final todayExpenses = await _dbHelper.getExpensesByDate(today);
    final categoryMap = <String, int>{};

    for (final expense in todayExpenses) {
      categoryMap[expense.kategori] =
          (categoryMap[expense.kategori] ?? 0) + expense.harga;
    }

    return categoryMap;
  }

  /// Kategori paling sering dalam bulan ini
  Future<String?> getMostFrequentCategoryThisMonth() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(
      now.year,
      now.month,
      1,
    ).toString().split(' ')[0];
    final endOfMonth = DateTime(
      now.year,
      now.month + 1,
      0,
    ).toString().split(' ')[0];

    final monthExpenses = await _dbHelper.getExpensesByDateRange(
      startOfMonth,
      endOfMonth,
    );

    if (monthExpenses.isEmpty) return null;

    final categoryCount = <String, int>{};
    for (final expense in monthExpenses) {
      categoryCount[expense.kategori] =
          (categoryCount[expense.kategori] ?? 0) + 1;
    }

    String? mostFrequent;
    int maxCount = 0;

    categoryCount.forEach((category, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequent = category;
      }
    });

    return mostFrequent;
  }
}
