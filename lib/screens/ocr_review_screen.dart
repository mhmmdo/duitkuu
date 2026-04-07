import 'dart:io';
import 'package:flutter/material.dart';
import 'package:duitkuu/models/expense.dart';
import 'package:duitkuu/models/parsed_receipt_model.dart';
import 'package:duitkuu/services/expense_service.dart';
import 'package:duitkuu/services/ocr_service.dart';
import 'package:duitkuu/services/gemini_service.dart';
import 'package:duitkuu/services/app_settings.dart';
import 'package:duitkuu/theme/app_theme.dart';
import 'package:duitkuu/utils/app_constants.dart';
import 'package:duitkuu/utils/app_formatter.dart';

class OcrReviewScreen extends StatefulWidget {
  final File imageFile;
  final OcrResult ocrResult;

  const OcrReviewScreen({
    Key? key,
    required this.imageFile,
    required this.ocrResult,
  }) : super(key: key);

  @override
  State<OcrReviewScreen> createState() => _OcrReviewScreenState();
}

class _OcrReviewScreenState extends State<OcrReviewScreen> {
  final ExpenseService _expenseService = ExpenseService();
  final GeminiService _geminiService = GeminiService();
  final AppSettings _settings = AppSettings();

  late List<ParsedReceiptItem> _items;
  late TextEditingController _totalController;
  late TextEditingController _storeController;
  late TextEditingController _dateController;
  late ParsedReceipt _parsedReceipt;
  bool _isSaving = false;
  bool _isImproving = false;

  @override
  void initState() {
    super.initState();
    // Gunakan ParsedReceipt dari ocrResult
    _parsedReceipt = widget.ocrResult.parsedReceipt;
    _items = List.from(_parsedReceipt.items);

    _totalController = TextEditingController(
      text: _parsedReceipt.totalAmount?.toString() ?? '',
    );
    _storeController = TextEditingController(
      text: _parsedReceipt.storeName ?? '',
    );
    _dateController = TextEditingController(
      text: _parsedReceipt.date ?? DateTime.now().toString().split(' ')[0],
    );
  }

  @override
  void dispose() {
    _totalController.dispose();
    _storeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _saveExpenses() async {
    if (_items.isEmpty) {
      _showSnackbar('Tambahkan minimal satu item', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      for (final item in _items) {
        if (item.name.isEmpty || item.price <= 0) {
          continue;
        }

        final now = DateTime.now().toString().split('.')[0];
        final expense = Expense(
          namaItem: item.name,
          harga: item.price,
          kategori: item.suggestedCategory ?? 'Lainnya',
          tanggal: _dateController.text,
          catatan: item.notes ?? '',
          createdAt: now,
          updatedAt: now,
        );

        await _expenseService.addExpense(expense);
      }

      if (mounted) {
        _showSnackbar('${_items.length} item berhasil disimpan!');
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Gagal menyimpan: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorRed : AppTheme.successGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _improveWithGemini() async {
    // Check jika punya API key
    if (!_settings.hasValidApiKey()) {
      _showApiKeyDialog();
      return;
    }

    setState(() => _isImproving = true);

    try {
      _showSnackbar('Meningkatkan akurasi dengan Gemini AI...');

      final rawText = widget.ocrResult.rawText;
      final improvedReceipt = await _geminiService.parseReceiptWithGemini(
        rawText,
      );

      if (mounted) {
        setState(() {
          _parsedReceipt = improvedReceipt;
          _items = List.from(improvedReceipt.items);
          _storeController.text = improvedReceipt.storeName ?? '';
          _dateController.text =
              improvedReceipt.date ?? DateTime.now().toString().split(' ')[0];
          _totalController.text = improvedReceipt.totalAmount?.toString() ?? '';
        });

        _showSnackbar('Hasil ditingkatkan dengan Gemini AI!');
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Gagal improve: $e\nGunakan hasil MLKit', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isImproving = false);
      }
    }
  }

  void _showApiKeyDialog() {
    final keyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setup Gemini API'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan Google Gemini API Key untuk meningkatkan akurasi OCR.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: keyController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'API Key (misal: AIzaSy...)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '💡 Dapatkan API Key dari: https://ai.google.dev/',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () {
              if (keyController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Masukkan API Key')),
                );
                return;
              }

              _settings.setGeminiApiKey(keyController.text);
              _geminiService.setApiKey(keyController.text);
              Navigator.pop(context);

              // Langsung improve
              _improveWithGemini();
            },
            child: const Text('Simpan & Improve'),
          ),
        ],
      ),
    );
  }

  void _showRemoveItem(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Item?'),
        content: Text('Hapus "${_items[index].name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _items.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _updateTotalFromItems();
    });
  }

  void _updateTotalFromItems() {
    if (_items.isEmpty) return;

    final total = _items.fold<int>(0, (sum, item) => sum + item.price);
    setState(() {
      _totalController.text = total.toString();
    });
  }

  void _addNewItem() {
    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        String price = '';
        String? category = 'Lainnya';

        return AlertDialog(
          title: const Text('Tambah Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nama Item',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => name = value,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => price = value,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.expenseCategories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (value) => category = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (name.isEmpty || price.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Isi semua field')),
                  );
                  return;
                }

                setState(() {
                  _items.add(
                    ParsedReceiptItem(
                      name: name,
                      price: int.parse(price),
                      confidence: 1.0, // User input = high confidence
                      suggestedCategory: category,
                    ),
                  );
                  _updateTotalFromItems();
                });

                Navigator.pop(context);
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotesField(ParsedReceiptItem item) {
    final notesController = TextEditingController(text: item.notes ?? '');
    return TextField(
      controller: notesController,
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Catatan',
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onChanged: (value) {
        setState(() {
          item.notes = value;
        });
      },
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return AppTheme.successGreen;
    if (confidence >= 0.6) return AppTheme.warningOrange;
    return AppTheme.errorRed;
  }

  String _getConfidenceText(double confidence) {
    return '${(confidence * 100).toStringAsFixed(0)}%';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.lightGray,
        appBar: AppBar(
          title: const Text('Review Scan'),
          elevation: 0,
          backgroundColor: AppTheme.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview gambar
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.mediumGray),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(widget.imageFile, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 24),

              // Overall Confidence Indicator
              _buildConfidenceIndicator(),
              const SizedBox(height: 16),

              // Warning/Info banner based on confidence
              if (_parsedReceipt.isLowConfidence) _buildLowConfidenceWarning(),
              if (_parsedReceipt.isMediumConfidence)
                _buildMediumConfidenceWarning(),
              if (!_parsedReceipt.isLowConfidence) const SizedBox(height: 0),
              const SizedBox(height: 16),

              // Form info dengan confidence indicators
              _buildForm(),
              const SizedBox(height: 24),

              // Items list
              Text('Item Belanja', style: AppTheme.titleLarge),
              const SizedBox(height: 12),
              if (_items.isEmpty)
                Center(
                  child: Text(
                    'Tidak ada item. Tambahkan item baru.',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.darkGray,
                    ),
                  ),
                )
              else
                ..._items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildItemCard(index, item),
                  );
                }),
              const SizedBox(height: 16),

              // Tombol tambah item
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _addNewItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Item'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBlue,
                    side: const BorderSide(color: AppTheme.primaryBlue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Tombol improve dengan Gemini
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isImproving ? null : _improveWithGemini,
                  icon: _isImproving
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_fix_high),
                  label: Text(
                    _isImproving ? 'Improving...' : 'Improve dengan Gemini',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentCyan,
                    side: BorderSide(color: AppTheme.accentCyan),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Tombol simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveExpenses,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: AppTheme.mediumGray,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.white,
                            ),
                          ),
                        )
                      : const Text('Simpan ke Database'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfidenceIndicator() {
    final confidence = _parsedReceipt.overallConfidence;
    final confidenceText = _parsedReceipt.getConfidenceLevelText();
    final colorKey = _parsedReceipt.getConfidenceColorKey();

    final color = colorKey == 'high'
        ? AppTheme.successGreen
        : colorKey == 'medium'
        ? AppTheme.warningOrange
        : AppTheme.errorRed;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Akurasi Scan', style: AppTheme.titleLarge),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    confidenceText,
                    style: AppTheme.bodyMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: confidence,
                minHeight: 8,
                backgroundColor: AppTheme.mediumGray.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            if (_parsedReceipt.notes != null) ...[
              const SizedBox(height: 12),
              Text(
                _parsedReceipt.notes!,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.darkGray,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLowConfidenceWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.errorRed.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber, color: AppTheme.errorRed, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Akurasi Rendah',
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.errorRed,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hasil scan kurang akurat. Mohon periksa dan edit semua detail dengan hati-hati sebelum menyimpan.',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.darkGray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediumConfidenceWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warningOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warningOrange.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppTheme.warningOrange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Hasil scan mungkin belum akurat. Mohon review dan edit sebelum menyimpan.',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.darkGray),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFormField(
              label: 'Nama Toko (Opsional)',
              controller: _storeController,
              icon: Icons.store,
              confidence: _parsedReceipt.storeNameConfidence,
            ),
            const SizedBox(height: 12),
            _buildFormField(
              label: 'Tanggal',
              controller: _dateController,
              icon: Icons.calendar_today,
              readOnly: true,
              confidence: _parsedReceipt.dateConfidence,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  _dateController.text = picked.toString().split(' ')[0];
                }
              },
            ),
            const SizedBox(height: 12),
            _buildFormField(
              label: 'Total (Opsional)',
              controller: _totalController,
              icon: Icons.money,
              keyboardType: TextInputType.number,
              confidence: _parsedReceipt.totalConfidence,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required double confidence,
    bool readOnly = false,
    TextInputType? keyboardType,
    VoidCallback? onTap,
  }) {
    final color = _getConfidenceColor(confidence);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTheme.bodyMedium),
            if (confidence > 0)
              Chip(
                label: Text(
                  _getConfidenceText(confidence),
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: color.withOpacity(0.2),
                labelStyle: TextStyle(color: color, fontSize: 12),
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          onTap: onTap,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: color.withOpacity(0.5),
                width: confidence > 0 ? 1.5 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(int index, ParsedReceiptItem item) {
    final color = _getConfidenceColor(item.confidence);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: AppTheme.bodyLarge,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(
                              _getConfidenceText(item.confidence),
                              style: const TextStyle(fontSize: 11),
                            ),
                            backgroundColor: color.withOpacity(0.2),
                            labelStyle: TextStyle(color: color, fontSize: 11),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppFormatter.formatCurrency(item.price),
                        style: AppTheme.titleLarge.copyWith(
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _removeItem(index),
                  icon: const Icon(Icons.delete),
                  color: AppTheme.errorRed,
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: item.suggestedCategory ?? 'Lainnya',
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: AppConstants.expenseCategories
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        item.suggestedCategory = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: _buildNotesField(item)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
