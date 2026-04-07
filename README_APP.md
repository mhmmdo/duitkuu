# 📱 Duitku - Aplikasi Pencatat Pengeluaran Personal

Aplikasi Flutter modern untuk mencatat dan menganalisis pengeluaran pribadi secara offline menggunakan SQLite.

## 🎯 Fitur Utama

✅ **Tambah/Edit/Hapus Pengeluaran** - Kelola data pengeluaran dengan mudah  
✅ **Dashboard Analytics** - Lihat ringkasan pengeluaran Anda  
✅ **Riwayat Transaksi** - Kelola semua transaksi dengan search dan filter  
✅ **Analisis Detailed** - Statistik pengeluaran per kategori dan bulanan  
✅ **Offline First** - Semua data tersimpan lokal di SQLite  
✅ **Modern UI** - Desain clean, fresh dengan tema biru elektrik  
✅ **Responsive** - Bekerja sempurna di berbagai ukuran layar

## 📁 Struktur Folder

```
lib/
├── main.dart                          # Entry point aplikasi
├── models/
│   └── expense.dart                   # Model data pengeluaran
├── databases/
│   └── database_helper.dart           # SQLite database operations
├── services/
│   └── expense_service.dart           # Business logic & analytics
├── screens/
│   ├── home_screen.dart               # Bottom navigation
│   ├── dashboard_screen.dart          # Halaman utama
│   ├── add_edit_expense_screen.dart    # Form input pengeluaran
│   ├── transaction_history_screen.dart # Riwayat dengan filter
│   └── analytics_screen.dart          # Analisis statistik
├── widgets/
│   └── components.dart                # Reusable UI components
├── theme/
│   └── app_theme.dart                 # Theme data & color palette
└── utils/
    ├── app_formatter.dart             # Format currency & date
    └── app_constants.dart             # Constants & messages
```

## 🎨 Desain & Tema

### Palet Warna (Biru Modern)

- **Primary Blue** (`#2563EB`) - Warna utama
- **Primary Dark** (`#1D4ED8`) - Biru tua
- **Primary Light** (`#3B82F6`) - Biru cerah
- **Accent Cyan** (`#06B6D4`) - Aksen cyan
- **Accent Light** (`#93C5FD`) - Biru muda
- **White** (`#FFFFFF`) - Background
- **Light Gray** (`#F8FAFC`) - Background terang
- **Dark Gray** (`#475569`) - Text secondary

### Karakteristik Visual

- Border radius besar (16-20px)
- Shadow halus dan subtle
- Spacing lega untuk breathing room
- Typography tegas dan mudah dibaca
- Card-based layout
- Gradient dan smooth transitions

## 📊 Struktur Data

### Expense Model

```javascript
{
  id: int (auto increment, primary key)
  nama_item: string (required)
  harga: int (required)
  kategori: string (required)
  tanggal: string/date (required, format: YYYY-MM-DD)
  catatan: string (optional)
  created_at: timestamp
  updated_at: timestamp
}
```

### Kategori Default

- 🍔 Makanan
- 🥤 Minuman
- 🚗 Transport
- 🛍️ Belanja
- 🏠 Kebutuhan
- 🎬 Hiburan
- 💫 Lainnya

## 🚀 Cara Menggunakan

### 1. Setup Project

```bash
cd duitkuu
flutter pub get
```

### 2. Jalankan Aplikasi

```bash
flutter run
```

### 3. Build APK (Android)

```bash
flutter build apk --release
```

## 📱 Halaman & Fitur Detail

### 1. Dashboard Screen

**Tampilan Utama** - Greeting dengan ikon emoji berdasarkan waktu

- **Card Total Bulan Ini** - Total pengeluaran bulan berjalan
- **Stat Cards** - Pengeluaran hari ini, jumlah transaksi, kategori sering
- **Transaksi Terbaru** - List 5 transaksi terakhir
- **FAB** - Tombol tambah pengeluaran

**Fitur:**

- Pull to refresh
- Edit/hapus dari daftar terbaru
- Navigate ke halaman detail

### 2. Add/Edit Expense Screen

**Form Input Lengkap** dengan validasi real-time

- Input nama item
- Input harga (numeric)
- Dropdown kategori
- Date picker (calendar)
- Textarea catatan optional
- Validasi: nama tidak boleh kosong, harga > 0

**Fitur:**

- Auto-populate saat edit
- Loading state saat submit
- Success/error messages
- Batal button

### 3. Transaction History Screen

**Daftar Semua Transaksi** dengan filtering canggih

- Search bar untuk cari nama item
- Filter kategori (dropdown)
- Filter bulan (dari data yang ada)
- Pull to refresh
- Edit/hapus per item

**Fitur:**

- Real-time search
- Multiple filter kombinasi
- Clear all filters button
- Empty state handling

### 4. Analytics Screen

**Statistik & Insights Mendalam**

- Bar chart pengeluaran per kategori
- Insights: kategori terboros, transaksi tertinggi
- Pengeluaran bulanan (6 bulan terakhir)
- Summary: total, jumlah transaksi, kategori sering

**Fitur:**

- Progress bar per kategori dengan persentase
- Color-coded insight cards
- Monthly trends
- Real-time calculation

### 5. Home Screen

**Bottom Navigation** untuk switch antar halaman

- Dashboard (home icon)
- Riwayat (history icon)
- Analisis (analytics icon)

## 💾 Database Operations

### Create Operation

```dart
final expense = Expense(
  namaItem: 'Kopi Pagi',
  harga: 15000,
  kategori: 'Minuman',
  tanggal: '2024-01-15',
  catatan: 'Kopi espresso',
  createdAt: DateTime.now().toIso8601String(),
  updatedAt: DateTime.now().toIso8601String(),
);
await expenseService.addExpense(expense);
```

### Read Operations

```dart
// Get semua expense
List<Expense> all = await expenseService.getAllExpenses();

// Get by kategori
List<Expense> makanan = await expenseService.getExpensesByCategory('Makanan');

// Search by nama
List<Expense> results = await expenseService.searchExpenses('kopi');

// Get by tanggal range
List<Expense> monthly = await expenseService.getExpensesByDateRange('2024-01-01', '2024-01-31');
```

### Update Operation

```dart
final updated = expense.copyWith(
  harga: 20000,
  updatedAt: DateTime.now().toIso8601String(),
);
await expenseService.updateExpense(updated);
```

### Delete Operation

```dart
await expenseService.deleteExpense(expenseId);
```

## 📊 Analytics & Calculations

### Methods Tersedia

```dart
// Dashboard stats
int todayTotal = await expenseService.getTodayTotal();
int monthTotal = await expenseService.getMonthTotal();
int transactionCount = await expenseService.getMonthTransactionCount();

// Analytics
Map<String, int> byCategory = await expenseService.getTotalByCategory();
Map<String, int> byMonth = await expenseService.getMonthlyTotals();
Map<String, int> byDay = await expenseService.getDailyTotals();

String? highestCategory = await expenseService.getHighestCategory();
Expense? highestExpense = await expenseService.getHighestExpense();
```

## 🎯 Format Data

### Format Currency (Rupiah)

```dart
AppFormatter.formatCurrency(25000)
// Output: "Rp 25.000"
```

### Format Tanggal

```dart
AppFormatter.formatDate('2024-01-15')           // "15 Jan 2024"
AppFormatter.formatDateWithDay('2024-01-15')   // "Senin, 15 Jan 2024"
AppFormatter.formatDateShort('2024-01-15')     // "15/01"
AppFormatter.formatMonth('2024-01-15')         // "Januari 2024"
AppFormatter.formatDateRelative('2024-01-15')  // "Hari ini" / "Kemarin" / "15 Jan 2024"
```

## 🔧 Teknologi & Dependencies

- **Flutter** - Framework UI cross-platform
- **Dart** - Programming language
- **SQLite** (`sqflite`) - Database lokal
- **Intl** - Localization & formatting
- **Path** - File path handling

## 📝 Dummy Data

Aplikasi sudah include dummy data saat pertama kali dibuka:

- Kopi, Nasi Goreng, Bensin (hari ini)
- Buku, Tiket Bioskop (kemarin)
- Pembelian kebutuhan (2 hari lalu)

## 🛠️ Customization

### Ubah Warna Tema

Edit `lib/theme/app_theme.dart`:

```dart
static const Color primaryBlue = Color(0xFF2563EB); // Ubah warna sini
```

### Tambah Kategori Baru

Edit `lib/utils/app_constants.dart`:

```dart
static const List<String> expenseCategories = [
  'Makanan',
  'Minuman',
  'Transport',
  'Kategori Baru', // Tambah di sini
];
```

### Ubah Format Tanggal

Edit `lib/utils/app_formatter.dart` - sesuaikan format di method yang relevan

## 📱 Compatibility

- **Android** - API 21+ (Tested on Android 11+)
- **iOS** - iOS 11.0+
- **Web** - Support (with limitations)

## 🐛 Troubleshooting

### Database Error

- Hapus app dan reinstall
- Atau manual delete database di `/data/data/com.example.duitkuu/databases/duitkuu.db`

### Localization Error

- Pastikan intl package sudah ter-import
- Jalankan `flutter pub get` ulang

### Build Error

- Bersihkan build: `flutter clean`
- Get dependencies ulang: `flutter pub get`

## 📈 Roadmap Fitur Masa Depan

- [ ] Dark mode support
- [ ] Export data to CSV
- [ ] Backup & restore
- [ ] Budget limit & notifikasi
- [ ] Multi-language support
- [ ] Cloud sync
- [ ] Monthly report PDF
- [ ] Widget/shortcut
- [ ] Custom categories
- [ ] Recurring expenses

## 📄 License

Private project - Personal Use Only

## 👨‍💻 Author

Created for personal finance tracking

---

**Selamat menggunakan Duitku! 💰**
Semoga membantu Anda mengatur keuangan dengan lebih baik! 🚀
