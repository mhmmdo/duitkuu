class AppConstants {
  // Kategori pengeluaran
  static const List<String> expenseCategories = [
    'Makanan',
    'Minuman',
    'Transport',
    'Belanja',
    'Kebutuhan',
    'Hiburan',
    'Lainnya',
  ];

  // Pesan validasi
  static const String errorEmptyName = 'Nama item tidak boleh kosong';
  static const String errorInvalidPrice =
      'Harga harus angka dan lebih besar dari 0';
  static const String errorEmptyCategory = 'Kategori wajib dipilih';
  static const String errorEmptyDate = 'Tanggal wajib dipilih';

  // Success messages
  static const String successAdd = 'Pengeluaran berhasil ditambahkan';
  static const String successUpdate = 'Pengeluaran berhasil diperbarui';
  static const String successDelete = 'Pengeluaran berhasil dihapus';
}
