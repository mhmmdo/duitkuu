import 'package:flutter/material.dart';
import 'package:duitkuu/models/expense.dart';
import 'package:duitkuu/services/expense_service.dart';
import 'package:duitkuu/theme/app_theme.dart';
import 'package:duitkuu/utils/app_formatter.dart';
import 'package:duitkuu/widgets/components.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ExpenseService _expenseService = ExpenseService();
  late Future<int> _todayTotal;
  late Future<int> _monthTotal;
  late Future<int> _monthTransactionCount;
  late Future<String?> _mostFrequentCategory;
  late Future<List<Expense>> _recentTransactions;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _todayTotal = _expenseService.getTodayTotal();
      _monthTotal = _expenseService.getMonthTotal();
      _monthTransactionCount = _expenseService.getMonthTransactionCount();
      _mostFrequentCategory = _expenseService
          .getMostFrequentCategoryThisMonth();
      _recentTransactions = _expenseService.getRecentTransactions(limit: 5);
    });
  }

  void _refreshData() {
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: const Text("Dashboard"),
        elevation: 0,
        backgroundColor: AppTheme.lightGray,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/about');
              },
              icon: const Icon(Icons.info_outline),
              color: AppTheme.darkGrayText,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshData();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header greeting
                _buildGreeting(),
                const SizedBox(height: 24),

                // Total bulan ini
                FutureBuilder<int>(
                  future: _monthTotal,
                  builder: (context, snapshot) {
                    return HighlightCard(
                      title: 'Total Bulan Ini',
                      value: AppFormatter.formatCurrency(snapshot.data ?? 0),
                      subtitle: 'Pengeluaran total',
                      bgColor: AppTheme.primaryBlue,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Row stats
                Row(
                  children: [
                    Expanded(
                      child: FutureBuilder<int>(
                        future: _todayTotal,
                        builder: (context, snapshot) {
                          return StatCard(
                            title: 'Hari Ini',
                            value: AppFormatter.formatCurrency(
                              snapshot.data ?? 0,
                            ),
                            icon: Icons.today,
                            iconColor: AppTheme.accentCyan,
                            backgroundColor: const Color(0xFFCFFAFE),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FutureBuilder<int>(
                        future: _monthTransactionCount,
                        builder: (context, snapshot) {
                          return StatCard(
                            title: 'Transaksi',
                            value: '${snapshot.data ?? 0}x',
                            icon: Icons.receipt,
                            iconColor: const Color(0xFFEC4899),
                            backgroundColor: const Color(0xFFFCE7F3),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Kategori terbanyak
                FutureBuilder<String?>(
                  future: _mostFrequentCategory,
                  builder: (context, snapshot) {
                    return StatCard(
                      title: 'Kategori Sering',
                      value: snapshot.data ?? '-',
                      icon: Icons.category,
                      iconColor: const Color(0xFFF59E0B),
                      backgroundColor: const Color(0xFFFEF3DD),
                    );
                  },
                ),
                const SizedBox(height: 28),

                // Transaksi terbaru
                SectionHeader(
                  title: 'Transaksi Terbaru',
                  actionText: 'Lihat Semua',
                  onActionTap: () {
                    Navigator.pushNamed(context, '/history');
                  },
                ),
                const SizedBox(height: 12),

                FutureBuilder<List<Expense>>(
                  future: _recentTransactions,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inbox,
                                size: 48,
                                color: AppTheme.mediumGray,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Belum ada transaksi',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.darkGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: List.generate(snapshot.data!.length, (index) {
                        final expense = snapshot.data![index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ExpenseItemCard(
                            itemName: expense.namaItem,
                            price: expense.harga,
                            category: expense.kategori,
                            date: expense.tanggal,
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
                      }),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add').then((_) => _refreshData());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    late String greeting;

    if (hour < 12) {
      greeting = '🌅 Pagi!';
    } else if (hour < 17) {
      greeting = '☀️ Siang!';
    } else {
      greeting = '🌙 Malam!';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.darkGray),
        ),
        const SizedBox(height: 4),
        Text('Siap ngatur uang hari ini?', style: AppTheme.headlineMedium),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, int expenseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengeluaran?'),
        content: const Text(
          'Anda yakin ingin menghapus pengeluaran ini? Tindakan ini tidak dapat dibatalkan.',
        ),
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
