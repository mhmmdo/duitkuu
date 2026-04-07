import 'package:flutter/material.dart';
import 'package:duitkuu/models/expense.dart';
import 'package:duitkuu/services/expense_service.dart';
import 'package:duitkuu/theme/app_theme.dart';
import 'package:duitkuu/utils/app_formatter.dart';
import 'package:duitkuu/widgets/components.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final ExpenseService _expenseService = ExpenseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: const Text('Analisis Pengeluaran'),
        elevation: 0,
        backgroundColor: AppTheme.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pengeluaran terbesar per kategori
            SectionHeader(title: 'Pengeluaran per Kategori'),
            const SizedBox(height: 12),
            FutureBuilder<Map<String, int>>(
              future: _expenseService.getTotalByCategory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Belum ada data'));
                }

                final categoryTotals = snapshot.data!;
                final sortedCategories = categoryTotals.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return Column(
                  children: sortedCategories.map((entry) {
                    final total = entry.value;
                    final maxTotal = categoryTotals.values.reduce(
                      (a, b) => a > b ? a : b,
                    );
                    final percentage = (total / maxTotal * 100).toStringAsFixed(
                      1,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCategoryBar(
                        category: entry.key,
                        amount: total,
                        percentage: double.parse(percentage),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 28),

            // Top insight
            SectionHeader(title: 'Insight'),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: FutureBuilder<String?>(
                    future: _expenseService.getHighestCategory(),
                    builder: (context, snapshot) {
                      return StatCard(
                        title: 'Kategori Terboros',
                        value: snapshot.data ?? '-',
                        icon: Icons.trending_up,
                        iconColor: AppTheme.errorRed,
                        backgroundColor: const Color(0xFFFFECEB),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FutureBuilder<Expense?>(
                    future: _expenseService.getHighestExpense(),
                    builder: (context, snapshot) {
                      return StatCard(
                        title: 'Transaksi Tertinggi',
                        value: AppFormatter.formatCurrency(
                          snapshot.data?.harga ?? 0,
                        ),
                        icon: Icons.arrow_upward,
                        iconColor: AppTheme.warningOrange,
                        backgroundColor: const Color(0xFFFFF6E8),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Pengeluaran bulanan
            SectionHeader(title: 'Pengeluaran Bulanan'),
            const SizedBox(height: 12),
            FutureBuilder<Map<String, int>>(
              future: _expenseService.getMonthlyTotals(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Belum ada data'));
                }

                final monthlyData = snapshot.data!;
                final sortedMonths = monthlyData.entries.toList()
                  ..sort((a, b) => b.key.compareTo(a.key));

                return Column(
                  children: sortedMonths.take(6).map((entry) {
                    final month = entry.key;
                    final total = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildMonthlyCard(month: month, total: total),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 28),

            // Summary
            SectionHeader(title: 'Ringkasan'),
            const SizedBox(height: 12),

            FutureBuilder<int>(
              future: _expenseService.getMonthTotal(),
              builder: (context, monthSnapshot) {
                return FutureBuilder<int>(
                  future: _expenseService.getMonthTransactionCount(),
                  builder: (context, countSnapshot) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.mediumGray),
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow(
                            'Total Bulan Ini',
                            AppFormatter.formatCurrency(
                              monthSnapshot.data ?? 0,
                            ),
                            const Color(0xFF2563EB),
                          ),
                          const Divider(height: 24),
                          _buildSummaryRow(
                            'Jumlah Transaksi',
                            '${countSnapshot.data ?? 0}x',
                            const Color(0xFFEC4899),
                          ),
                          const Divider(height: 24),
                          FutureBuilder<int>(
                            future: _expenseService.getTodayTotal(),
                            builder: (context, todaySnapshot) {
                              return _buildSummaryRow(
                                'Total Hari Ini',
                                AppFormatter.formatCurrency(
                                  todaySnapshot.data ?? 0,
                                ),
                                const Color(0xFF06B6D4),
                              );
                            },
                          ),
                          const Divider(height: 24),
                          FutureBuilder<String?>(
                            future: _expenseService
                                .getMostFrequentCategoryThisMonth(),
                            builder: (context, catSnapshot) {
                              return _buildSummaryRow(
                                'Kategori Sering',
                                catSnapshot.data ?? '-',
                                const Color(0xFFF59E0B),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBar({
    required String category,
    required int amount,
    required double percentage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(category, style: AppTheme.bodyMedium),
            Text(
              AppFormatter.formatCurrency(amount),
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: AppTheme.mediumGray,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.primaryBlue,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$percentage%',
          style: AppTheme.bodySmall.copyWith(color: AppTheme.darkGray),
        ),
      ],
    );
  }

  Widget _buildMonthlyCard({required String month, required int total}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.mediumGray),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(month, style: AppTheme.bodyMedium),
          Text(
            AppFormatter.formatCurrency(total),
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.bodyMedium),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
