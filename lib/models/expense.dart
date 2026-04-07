class Expense {
  final int? id;
  final String namaItem;
  final int harga;
  final String kategori;
  final String tanggal;
  final String? catatan;
  final String? fotoPath; // Path ke foto struk/item
  final String? transactionId; // ID untuk group items dari struk yang sama
  final String createdAt;
  final String updatedAt;

  Expense({
    this.id,
    required this.namaItem,
    required this.harga,
    required this.kategori,
    required this.tanggal,
    this.catatan,
    this.fotoPath,
    this.transactionId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Konversi dari Map (dari Database) ke Model Expense
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      namaItem: map['nama_item'],
      harga: map['harga'],
      kategori: map['kategori'],
      tanggal: map['tanggal'],
      catatan: map['catatan'],
      fotoPath: map['foto_path'],
      transactionId: map['transaction_id'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  /// Konversi dari Model Expense ke Map (untuk Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_item': namaItem,
      'harga': harga,
      'kategori': kategori,
      'tanggal': tanggal,
      'catatan': catatan,
      'foto_path': fotoPath,
      'transaction_id': transactionId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Copy with method untuk update data
  Expense copyWith({
    int? id,
    String? namaItem,
    int? harga,
    String? kategori,
    String? tanggal,
    String? catatan,
    String? fotoPath,
    String? transactionId,
    String? createdAt,
    String? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      namaItem: namaItem ?? this.namaItem,
      harga: harga ?? this.harga,
      kategori: kategori ?? this.kategori,
      tanggal: tanggal ?? this.tanggal,
      catatan: catatan ?? this.catatan,
      fotoPath: fotoPath ?? this.fotoPath,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
