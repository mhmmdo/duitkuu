import 'package:flutter/material.dart';
import 'package:duitkuu/models/expense.dart';
import 'package:duitkuu/services/expense_service.dart';
import 'package:duitkuu/theme/app_theme.dart';
import 'package:duitkuu/utils/app_formatter.dart';

class TransactionDetailScreen extends StatefulWidget {
  final int expenseId;

  const TransactionDetailScreen({Key? key, required this.expenseId})
    : super(key: key);

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final ExpenseService _expenseService = ExpenseService();
  late Future<Expense?> _expenseFuture;

  @override
  void initState() {
    super.initState();
    _loadExpense();
  }

  void _loadExpense() {
    _expenseFuture = _expenseService.getExpenseById(widget.expenseId);
  }

  void _deleteExpense(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${expense.namaItem}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await _expenseService.deleteExpense(expense.id!);
              if (mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaksi berhasil dihapus')),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        elevation: 0,
        backgroundColor: AppTheme.white,
      ),
      body: FutureBuilder<Expense?>(
        future: _expenseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: AppTheme.mediumGray),
                  const SizedBox(height: 16),
                  Text(
                    'Transaksi tidak ditemukan',
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppTheme.darkGray,
                    ),
                  ),
                ],
              ),
            );
          }

          final expense = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card utama dengan info harga dan kategori
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppTheme.mediumGray),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama item
                        Text(
                          expense.namaItem,
                          style: AppTheme.headlineMedium,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),

                        // Harga
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.primaryBlue.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Harga',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.darkGray,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppFormatter.formatCurrency(expense.harga),
                                style: AppTheme.headlineLarge.copyWith(
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Kategori dan Tanggal
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoBox(
                                label: 'Kategori',
                                value: expense.kategori,
                                icon: Icons.category,
                                color: AppTheme.accentBlueLight,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoBox(
                                label: 'Tanggal',
                                value: AppFormatter.formatDate(expense.tanggal),
                                icon: Icons.calendar_today,
                                color: AppTheme.warningOrange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Detail lanjutan
                if (expense.catatan != null && expense.catatan!.isNotEmpty) ...[
                  Text('Catatan', style: AppTheme.titleLarge),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppTheme.mediumGray),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(expense.catatan!, style: AppTheme.bodyMedium),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Info metadata
                Text('Informasi Transaksi', style: AppTheme.titleLarge),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppTheme.mediumGray),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (expense.id != null)
                          _buildMetadataRow(
                            label: 'ID',
                            value: 'TXN-${expense.id}',
                          ),
                        if (expense.createdAt != null) ...[
                          const Divider(),
                          _buildMetadataRow(
                            label: 'Dibuat',
                            value: _formatDateTime(expense.createdAt!),
                          ),
                        ],
                        if (expense.updatedAt != null) ...[
                          const Divider(),
                          _buildMetadataRow(
                            label: 'Diupdate',
                            value: _formatDateTime(expense.updatedAt!),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol aksi
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/edit',
                            arguments: expense,
                          ).then((_) => _loadExpense());
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBlue,
                          side: const BorderSide(color: AppTheme.primaryBlue),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteExpense(expense),
                        icon: const Icon(Icons.delete),
                        label: const Text('Hapus'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorRed,
                          side: const BorderSide(color: AppTheme.errorRed),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoBox({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(color: AppTheme.darkGray),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(color: AppTheme.darkGray),
        ),
        Text(
          value,
          style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  String _formatDateTime(String datetime) {
    try {
      final dt = DateTime.parse(datetime);
      return '${AppFormatter.formatDate(dt.toString())} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return datetime;
    }
  }
}
