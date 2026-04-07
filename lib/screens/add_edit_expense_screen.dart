import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:duitkuu/models/expense.dart';
import 'package:duitkuu/services/expense_service.dart';
import 'package:duitkuu/theme/app_theme.dart';
import 'package:duitkuu/utils/app_constants.dart';
import 'package:duitkuu/utils/app_formatter.dart';

/// Model untuk temporary item (sebelum disave ke DB)
class TransactionItem {
  String name;
  int price;
  String category;
  String? notes;

  TransactionItem({
    required this.name,
    required this.price,
    required this.category,
    this.notes,
  });
}

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddEditExpenseScreen({Key? key, this.expense}) : super(key: key);

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  late TextEditingController _storeNameController;
  late TextEditingController _notesController;
  late TextEditingController _tanggalController;

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  File? _selectedImage;
  List<TransactionItem> _items = [];

  final ExpenseService _expenseService = ExpenseService();
  final ImagePicker _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  bool _isEditMode = false;
  Expense? _existingExpense;

  @override
  void initState() {
    super.initState();
    _storeNameController = TextEditingController();
    _notesController = TextEditingController();
    _tanggalController = TextEditingController(
      text: AppFormatter.formatDate(DateTime.now().toString().split(' ')[0]),
    );
    _selectedDate = DateTime.now();
    _items = [];

    // Load existing expense jika mode edit
    if (widget.expense != null) {
      _isEditMode = true;
      _existingExpense = widget.expense;
      _loadExistingExpense();
    }
  }

  void _loadExistingExpense() {
    final expense = widget.expense!;

    // Load basic info
    _storeNameController.text = expense.namaItem;
    _notesController.text = expense.catatan ?? '';
    _tanggalController.text = AppFormatter.formatDate(expense.tanggal);

    try {
      _selectedDate = DateTime.parse(expense.tanggal);
    } catch (_) {
      _selectedDate = DateTime.now();
    }

    // Load photo
    if (expense.fotoPath != null && expense.fotoPath!.isNotEmpty) {
      _selectedImage = File(expense.fotoPath!);
    }

    // Convert existing expense back to TransactionItem for editing
    _items = [
      TransactionItem(
        name: expense.namaItem,
        price: expense.harga,
        category: expense.kategori,
        notes: expense.catatan,
      ),
    ];
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _notesController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tanggalController.text = AppFormatter.formatDate(
          picked.toString().split(' ')[0],
        );
      });
    }
  }

  Future<void> _pickImage() async {
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
              child: Text('Pilih Sumber Foto', style: AppTheme.titleLarge),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil dari Kamera'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await _imagePicker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 85,
                );
                if (pickedFile != null) {
                  setState(() => _selectedImage = File(pickedFile.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Pilih dari Galeri'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await _imagePicker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 85,
                );
                if (pickedFile != null) {
                  setState(() => _selectedImage = File(pickedFile.path));
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _removeImage() {
    setState(() => _selectedImage = null);
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    String selectedCategory = AppConstants.expenseCategories[0];
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Item *',
                  hintText: 'Contoh: Kopi, Nasi, dll',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga *',
                  hintText: 'Contoh: 25000',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) => DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  items: AppConstants.expenseCategories
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(
                      () => selectedCategory = value ?? selectedCategory,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isEmpty || priceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Isi nama dan harga item')),
                );
                return;
              }

              final price = int.tryParse(priceController.text) ?? 0;
              if (price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Harga harus lebih dari 0')),
                );
                return;
              }

              setState(() {
                _items.add(
                  TransactionItem(
                    name: nameController.text,
                    price: price,
                    category: selectedCategory,
                    notes: notesController.text.isNotEmpty
                        ? notesController.text
                        : null,
                  ),
                );
              });

              Navigator.pop(context);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTransaction() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tambahkan minimal 1 item')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now().toIso8601String();
      final dateString = _selectedDate.toString().split(' ')[0];

      if (_isEditMode && _existingExpense != null) {
        // MODE EDIT: Update existing expense
        final expense = Expense(
          id: _existingExpense!.id,
          namaItem: _items[0].name,
          harga: _items[0].price,
          kategori: _items[0].category,
          tanggal: dateString,
          catatan: _items[0].notes,
          fotoPath: _selectedImage?.path,
          transactionId: _existingExpense!.transactionId,
          createdAt: _existingExpense!.createdAt,
          updatedAt: now,
        );

        await _expenseService.updateExpense(expense);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Item berhasil diupdate!'),
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // MODE CREATE: Create new transaction with multiple items
        final transactionId = const Uuid().v4();

        for (final item in _items) {
          final expense = Expense(
            namaItem: item.name,
            harga: item.price,
            kategori: item.category,
            tanggal: dateString,
            catatan: item.notes,
            fotoPath: _selectedImage?.path,
            transactionId: transactionId,
            createdAt: now,
            updatedAt: now,
          );

          await _expenseService.addExpense(expense);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${_items.length} item berhasil disimpan!'),
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = _items.fold<int>(0, (sum, item) => sum + item.price);

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Pengeluaran' : 'Input Pengeluaran'),
        elevation: 0,
        backgroundColor: AppTheme.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama Toko
              Text('Nama Toko / Tempat (Opsional)', style: AppTheme.titleLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _storeNameController,
                decoration: InputDecoration(
                  hintText: 'Contoh: Indomaret, Warung Makan, dll',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Tanggal
              Text('Tanggal', style: AppTheme.titleLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tanggalController,
                readOnly: true,
                onTap: _selectDate,
                decoration: InputDecoration(
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Foto Struk
              Text('Foto Struk (Opsional)', style: AppTheme.titleLarge),
              const SizedBox(height: 8),
              if (_selectedImage != null)
                Column(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.mediumGray),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _removeImage,
                        icon: const Icon(Icons.delete),
                        label: const Text('Hapus Foto'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorRed,
                          side: const BorderSide(color: AppTheme.errorRed),
                        ),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Ambil Foto Struk'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Catatan Umum
              Text('Catatan Umum (Opsional)', style: AppTheme.titleLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Catatan untuk transaksi ini...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Items Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Daftar Item', style: AppTheme.titleLarge),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _items.length.toString(),
                      style: AppTheme.labelSmall.copyWith(
                        color: AppTheme.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_items.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.mediumGray),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 48,
                          color: AppTheme.mediumGray,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada item',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.darkGray,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tekan tombol di bawah untuk tambah item',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.darkGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: List.generate(_items.length, (index) {
                    final item = _items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildItemCard(index, item),
                    );
                  }),
                ),
              const SizedBox(height: 16),

              // Tombol Tambah Item
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showAddItemDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Total Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Transaksi',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      AppFormatter.formatCurrency(totalPrice),
                      style: AppTheme.headlineSmall.copyWith(
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTransaction,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.white,
                            ),
                          ),
                        )
                      : Text(
                          _isEditMode
                              ? 'Update Pengeluaran'
                              : 'Simpan Transaksi',
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Tombol Batal
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(int index, TransactionItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.mediumGray),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                onPressed: () {
                  setState(() => _items.removeAt(index));
                },
                icon: const Icon(Icons.delete),
                color: AppTheme.errorRed,
              ),
            ],
          ),
          const Divider(),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlueLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.category,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (item.notes != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.notes!,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.darkGray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
