import 'package:flutter/material.dart';
import 'package:duitkuu/models/expense.dart';
import 'package:duitkuu/services/expense_service.dart';
import 'package:duitkuu/theme/app_theme.dart';
import 'package:duitkuu/utils/app_constants.dart';
import 'package:duitkuu/widgets/components.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final ExpenseService _expenseService = ExpenseService();
  late Future<List<Expense>> _allExpenses;

  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() {
    setState(() {
      _allExpenses = _expenseService.getAllExpenses();
    });
  }

  Future<List<Expense>> _getFilteredExpenses() async {
    List<Expense> expenses = await _expenseService.getAllExpenses();

    // Filter berdasarkan kategori
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      expenses = expenses
          .where((e) => e.kategori == _selectedCategory)
          .toList();
    }

    // Filter berdasarkan bulan
    if (_selectedMonth != null && _selectedMonth!.isNotEmpty) {
      expenses = expenses
          .where((e) => e.tanggal.startsWith(_selectedMonth!))
          .toList();
    }

    // Search berdasarkan nama
    if (_searchQuery.isNotEmpty) {
      expenses = expenses
          .where(
            (e) =>
                e.namaItem.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return expenses;
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategory = null;
      _selectedMonth = null;
    });
  }

  void _refreshData() {
    _loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        elevation: 0,
        backgroundColor: AppTheme.white,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: 'Cari nama item...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Filter kategori
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      label: _selectedCategory ?? 'Kategori',
                      onTap: () {
                        _showCategoryFilter();
                      },
                    ),
                  ),

                  // Filter bulan
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      label: _selectedMonth ?? 'Bulan',
                      onTap: () {
                        _showMonthFilter();
                      },
                    ),
                  ),

                  // Clear filter
                  if (_searchQuery.isNotEmpty ||
                      _selectedCategory != null ||
                      _selectedMonth != null)
                    GestureDetector(
                      onTap: _clearFilters,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.errorRed),
                        ),
                        child: const Text(
                          'Reset',
                          style: TextStyle(
                            color: AppTheme.errorRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // List transaksi
          Expanded(
            child: FutureBuilder<List<Expense>>(
              future: _getFilteredExpenses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: AppTheme.mediumGray),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada transaksi',
                          style: AppTheme.headlineSmall.copyWith(
                            color: AppTheme.darkGray,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Mulai catat pengeluaran Anda',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.darkGray,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final expenses = snapshot.data!;

                return RefreshIndicator(
                  onRefresh: () async {
                    _refreshData();
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ExpenseItemCard(
                          itemName: expense.namaItem,
                          price: expense.harga,
                          category: expense.kategori,
                          date: expense.tanggal,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/detail',
                              arguments: expense.id,
                            ).then((_) => _refreshData());
                          },
                          onEdit: () {
                            Navigator.pushNamed(
                              context,
                              '/edit',
                              arguments: expense,
                            ).then((_) => _refreshData());
                          },
                          onDelete: () {
                            _showDeleteConfirmation(context, expense.id!);
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.mediumGray),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.darkGrayText),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more, size: 18),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Pilih Kategori', style: AppTheme.titleLarge),
            ),
            Flexible(
              child: ListView(
                children: AppConstants.expenseCategories.map((category) {
                  return ListTile(
                    title: Text(category),
                    trailing: _selectedCategory == category
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedCategory = _selectedCategory == category
                            ? null
                            : category;
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMonthFilter() async {
    final monthlyTotals = await _expenseService.getMonthlyTotals();
    final months = monthlyTotals.keys.toList()..sort((a, b) => b.compareTo(a));

    if (mounted) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Pilih Bulan', style: AppTheme.titleLarge),
              ),
              Flexible(
                child: ListView(
                  children: months.map((month) {
                    return ListTile(
                      title: Text(month),
                      trailing: _selectedMonth == month
                          ? const Icon(Icons.check)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedMonth = _selectedMonth == month
                              ? null
                              : month;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, int expenseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengeluaran?'),
        content: const Text('Anda yakin ingin menghapus pengeluaran ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _expenseService.deleteExpense(expenseId);
              _refreshData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pengeluaran berhasil dihapus'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}
