# 🏗️ Arsitektur & Best Practices Duitku

## 📐 Arsitektur Aplikasi

Aplikasi Duitku menggunakan **Clean Architecture dengan MVC Pattern** yang disesuaikan untuk Flutter.

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                    │
│  (Screens, Widgets, UI state management)                │
│  - home_screen.dart                                     │
│  - dashboard_screen.dart                                │
│  - add_edit_expense_screen.dart                          │
│  - transaction_history_screen.dart                       │
│  - analytics_screen.dart                                │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│                   BUSINESS LOGIC LAYER                   │
│  (Services, Controllers, Business rules)                │
│  - expense_service.dart (analytics, calculations)       │
│  - app_formatter.dart (formatting logic)                │
│  - app_theme.dart (UI constants)                        │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│                    DATA ACCESS LAYER                     │
│  (Repository, Database operations)                      │
│  - database_helper.dart (CRUD operations)               │
│  - expense.dart (data models)                           │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│                     DATA SOURCE LAYER                    │
│  (SQLite database)                                      │
└─────────────────────────────────────────────────────────┘
```

## 🎯 Separation of Concerns

### Models Layer (`lib/models/`)

**Tanggung Jawab:** Merepresentasikan struktur data

```dart
class Expense {
  - Properties: id, namaItem, harga, kategori, tanggal, catatan
  - Methods: fromMap(), toMap(), copyWith()
  - Konsern: Data structure & serialization SAJA
}
```

**Prinsip:**

- Model tidak boleh contain business logic
- Model tidak boleh depend pada database layer
- Model adalah pure data class

---

### Database Layer (`lib/databases/`)

**Tanggung Jawab:** Handle semua operasi database

```dart
class DatabaseHelper {
  - Create table & schema
  - CRUD operations
  - Query operations (fetch by criteria)
  - Dummy data insertion
}
```

**Prinsip:**

- Singleton pattern untuk single instance
- Async operations untuk non-blocking
- Error handling built-in
- No business logic here

---

### Service Layer (`lib/services/`)

**Tanggung Jawab:** Business logic & calculations

```dart
class ExpenseService {
  - Get all expenses
  - Search & filter
  - Analytics & statistics
  - Calculations (totals, averages)
  - Data transformation
}
```

**Prinsip:**

- Depend pada DatabaseHelper
- Contains all business rules
- Async operations
- Pure functions untuk calculations

**Analytics Methods:**

```
- getTodayTotal()             → Total pengeluaran hari ini
- getMonthTotal()             → Total pengeluaran bulan ini
- getMonthTransactionCount()  → Jumlah transaksi bulan ini
- getTotalByCategory()        → Total per kategori
- getMonthlyTotals()          → Total per bulan
- getDailyTotals()            → Total per hari
- getHighestCategory()        → Kategori dengan nominal terbesar
- getHighestExpense()         → Transaksi dengan nominal tertinggi
- getMostFrequentCategoryThisMonth() → Kategori paling sering
```

---

### Presentation Layer (`lib/screens/`)

**Tanggung Jawab:** UI & user interaction

```dart
class DashboardScreen {
  - Build UI
  - Handle user input
  - Call service methods
  - Update UI state
  - Show loading/empty states
}
```

**Prinsip:**

- Hanya handle presentation logic
- Depend pada Services, bukan Database
- Use setState untuk state management (simple)
- FutureBuilder untuk async operations
- Proper error handling & UX

---

### Theme Layer (`lib/theme/`)

**Tanggung Jawab:** Konsistensi visual & branding

```dart
class AppTheme {
  - Colors (primary, secondary, accent)
  - Typography (text styles)
  - ThemeData (Material theme)
  - Component styling
}
```

**Prinsip:**

- Centralized design system
- Single source of truth untuk styling
- Easy to rebrand atau update tema

---

### Utils Layer (`lib/utils/`)

**Tanggung Jawab:** Helper functions & constants

```dart
class AppFormatter {
  - Format currency (Rp)
  - Format date/time
  - Format relative date

class AppConstants {
  - Category list
  - Validation messages
  - Success messages
}
```

---

## 🔄 Data Flow

### Scenario: Menambah Pengeluaran Baru

```
User Input (UI)
    ↓
AddEditExpenseScreen.onSaveExpense()
    ↓
Create Expense object
    ↓
ExpenseService.addExpense()
    ↓
DatabaseHelper.insertExpense()
    ↓
SQLite INSERT
    ↓
Response (success/error)
    ↓
UI Update (SnackBar + Navigate back)
    ↓
DashboardScreen refreshes via _loadData()
    ↓
FutureBuilder rebuilds dengan data terbaru
```

### Scenario: Tampilkan Dashboard Stats

```
DashboardScreen.initState()
    ↓
_loadData() - trigger multiple futures
    ↓
Service methods:
  - getTodayTotal()
  - getMonthTotal()
  - getMonthTransactionCount()
  - getMostFrequentCategory()
  - getRecentTransactions()
    ↓
FutureBuilders membuild UI dengan data
    ↓
User refresh → Pull-to-refresh trigger _refreshData()
```

---

## ✅ Best Practices Implementasi

### 1. **Async/Await Pattern**

```dart
// ✅ GOOD - Clear dan readable
Future<int> getMonthTotal() async {
  final expenses = await _dbHelper.getAllExpenses();
  return expenses.fold(0, (sum, e) => sum + e.harga);
}

// ❌ BAD - Berbilang nested callbacks
getMonthTotal().then((total) {
  // nested logic
});
```

### 2. **Error Handling**

```dart
// ✅ GOOD - Try-catch dengan proper error message
try {
  await _expenseService.addExpense(newExpense);
  showSuccessSnackBar();
} catch (e) {
  showErrorSnackBar('Error: $e');
}

// ❌ BAD - Ignore error
await _expenseService.addExpense(newExpense);
```

### 3. **State Management**

```dart
// ✅ GOOD - Simple setState untuk app sederhana ini
setState(() {
  _isLoading = true;
});

// Untuk future operations gunakan FutureBuilder:
FutureBuilder<List<Expense>>(
  future: _expenseService.getAllExpenses(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    return ExpenseList(expenses: snapshot.data!);
  },
)
```

### 4. **Immutability & Model Update**

```dart
// ✅ GOOD - Use copyWith untuk immutability
final updated = expense.copyWith(
  harga: 20000,
  updatedAt: DateTime.now().toIso8601String(),
);
await service.updateExpense(updated);

// ❌ BAD - Mutate object directly
expense.harga = 20000;
await service.updateExpense(expense);
```

### 5. **Singleton Pattern untuk Database**

```dart
// ✅ GOOD - DatabaseHelper adalah singleton
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;  // Always return same instance
  }
}

// Usage
final db1 = DatabaseHelper();
final db2 = DatabaseHelper();
assert(identical(db1, db2));  // true
```

### 6. **String Formatting & Localization**

```dart
// ✅ GOOD - Use AppFormatter untuk consistency
AppFormatter.formatCurrency(25000)  // "Rp 25.000"
AppFormatter.formatDate('2024-01-15')  // "15 Jan 2024"

// ❌ BAD - String concatenation tanpa formatter
"Rp ${expense.harga}"  // User lain butuh parsing ulang
```

### 7. **Widget Reusability**

```dart
// ✅ GOOD - Extract reusable components
class ExpenseItemCard extends StatelessWidget {
  final String itemName;
  final int price;
  // ...
}

// Usage di berbagai screen:
ExpenseItemCard(itemName: 'Kopi', price: 15000)
ExpenseItemCard(itemName: 'Buku', price: 75000)

// ❌ BAD - Duplicate UI code di setiap screen
Container(
  padding: EdgeInsets.all(16),
  decoration: ...,
  child: Column(...)
)
```

### 8. **Validation Pattern**

```dart
// ✅ GOOD - Clear validation di form
FormField<String>(
  validator: (value) {
    if (value == null || value.isEmpty) {
      return AppConstants.errorEmptyName;
    }
    return null;
  },
)

// ❌ BAD - Silent validation yang bikin user kebingungan
if (value.isEmpty) return;
```

---

## 🧪 Testing Recommendations

### Unit Test (Services)

```dart
test('getTotalByCategory should return map correctly', () async {
  // Setup
  await service.addExpense(expense1);
  await service.addExpense(expense2);

  // Act
  final result = await service.getTotalByCategory();

  // Assert
  expect(result['Makanan'], 40000);
});
```

### Widget Test (UI Components)

```dart
testWidgets('ExpenseItemCard displays correctly', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ExpenseItemCard(itemName: 'Kopi', price: 15000),
      ),
    ),
  );

  expect(find.text('Kopi'), findsOneWidget);
  expect(find.text('Rp 15.000'), findsOneWidget);
});
```

### Integration Test (Full Flow)

```dart
void main() {
  testWidgets('Add expense full flow', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Tap FAB
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Fill form
    await tester.enterText(find.byType(TextField).first, 'Kopi');
    // ... fill other fields

    // Submit
    await tester.tap(find.text('Simpan Pengeluaran'));
    await tester.pumpAndSettle();

    // Verify
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
```

---

## 🚀 Performance Optimization

### 1. **Lazy Loading**

```dart
// Jangan load semua data sekaligus di startup
// Load per-halaman atau on-demand
```

### 2. **Caching**

```dart
// DatabaseHelper sudah cache database connection
static Database? _database;  // Cache instance
```

### 3. **Query Optimization**

```dart
// Use specific queries instead of fetch all
.where('kategori = ?')  // Filter di database level
vs
.where((e) => e.kategori == 'Makanan')  // Filter di Dart (slower)
```

### 4. **UI Rendering**

```dart
// Use const constructors
const SizedBox(height: 16);  // Better than SizedBox(height: 16)

// Use ListView.builder untuk long lists
ListView.builder(
  itemBuilder: (_, i) => ExpenseItemCard(...),
)
// vs ListView() - load semua item sekaligus (slow)
```

---

## 📚 Code Organization Best Practices

### Per-File Responsibility

- **Model file** → 1 class saja
- **Service file** → Related methods saja
- **Screen file** → 1 screen saja (+ helper widgets)
- **Widget file** → Related UI components

### Naming Conventions

- **Files** → snake_case: `database_helper.dart`
- **Classes** → PascalCase: `DatabaseHelper`
- **Methods/Variables** → camelCase: `getTotalByCategory()`
- **Constants** → camelCase dalam class, UPPER_CASE untuk global

### Import Organization

```dart
// System imports
import 'dart:async';

// Package imports
import 'package:flutter/material.dart';

// Project imports
import 'package:duitkuu/models/expense.dart';

// Relative imports (avoid)
import '../services/expense_service.dart';  // Use package imports instead
```

---

## � OCR Receipt Parsing Architecture

### Overview

OCR Parsing menggunakan **Google MLKit Text Recognition** untuk on-device text extraction dari foto struk, kemudian **ReceiptParser** melakukan intelligent parsing dengan confidence scoring.

```
Receipt Image
    ↓
OcrCaptureScreen (photo capture)
    ↓
OcrService.recognizeText() (Google MLKit)
    ↓
Raw text extracted
    ↓
ReceiptParser.parseReceipt() (intelligent parsing)
    ↓
ParsedReceipt (dengan confidence scores)
    ↓
OcrReviewScreen (user review & edit)
    ↓
Expense record(s) saved to database
```

### Components

#### 1. **OcrService** (`lib/services/ocr_service.dart`)

**Tanggung Jawab:** OCR wrapper menggunakan Google MLKit

```dart
class OcrService {
  // Singleton instance
  static final OcrService _instance = OcrService._internal();
  late final TextRecognizer _textRecognizer;

  // Main method
  Future<OcrResult> recognizeText(File imageFile)
    → Returns OcrResult with raw text + ParsedReceipt

  // Helper
  Future<void> dispose()
    → Clean up TextRecognizer resources
}
```

**Alur:**

1. Input image file dari gallery/camera
2. Initialize InputImage dari file
3. Process dengan MLKit TextRecognizer
4. Extract raw text
5. Pass ke ReceiptParser untuk intelligent parsing
6. Return OcrResult dengan ParsedReceipt + confidence scores

#### 2. **ReceiptParser** (`lib/services/receipt_parser.dart`)

**Tanggung Jawab:** Intelligent text parsing dengan confidence scoring

```dart
class ReceiptParser {
  // Main entry point
  static ParsedReceipt parseReceipt(String rawText)
    → Full parsing pipeline dengan confidence calculation
}
```

**Parsing Pipeline:**

```
Step 1: Text Normalization
├─ Lowercase conversion
├─ Fix common OCR mistakes (lO→lo, S→5, B→8)
├─ Clean excess whitespace
├─ Remove currency symbols (Rp, RP, etc)
└─ Split into normalized lines

Step 2: Line-by-line Analysis
├─ Skip empty/short lines
├─ Skip irrelevant keywords (telp, alamat, ppn, etc)
├─ Skip pure numeric lines
└─ Process valid lines

Step 3: Field Extraction
├─ Store Name (first 5 lines, no digits, 5-50 chars)
├─ Date (regex patterns: dd/mm/yyyy, yyyy/mm/dd, month name)
├─ Total Amount (largest number OR keyword matching)
└─ Items (name + price extraction with validation)

Step 4: Confidence Scoring
├─ Store Name Score: 0.9 (no digits) or 0.6 (has digits)
├─ Date Score: 0.95 (format match) or 0.90 (month name)
├─ Total Score: 0.95 (keyword found) or 0.70 (fallback)
├─ Item Score: 0.85 (single price) or 0.70 (multiple)
└─ Overall Score: Average of all scores

Step 5: Validation & Fallback
├─ Price range: 100-500k untuk items, 50k+ untuk total
├─ Item name: minimum 3 letters, max 50 chars
├─ Deduplicate items dengan Set tracking
└─ Generate issue notes jika confidence rendah
```

**Key Methods:**

```dart
// Main function
static ParsedReceipt parseReceipt(String rawText)

// Normalization
static List<String> _normalizeText(String rawText)
  → Lowercase, fix OCR mistakes, clean whitespace

// Parsing functions
static Map<String, dynamic>? _parseStoreName(String line)
static Map<String, dynamic>? _parseDate(String lineLower)
static Map<String, dynamic>? _parseTotal(String line, String lineLower)
static Map<String, dynamic>? _parseItem(String line, String lineLower)

// Category suggestion
static String? _suggestCategory(String itemName)
  → Heuristic-based category assignment (Makanan, Minuman, Transport, etc)

// Utilities
static bool _containsRelevantKeyword(String text)
static int _extractNumericValue(String priceStr)
```

#### 3. **ParsedReceipt Model** (`lib/models/parsed_receipt_model.dart`)

**Data Structure:**

```dart
class ParsedReceipt {
  // Extracted fields with confidence
  String? storeName;
  double storeNameConfidence;  // 0.0-1.0

  String? date;
  double dateConfidence;

  int? totalAmount;
  double totalConfidence;

  List<ParsedReceiptItem> items;
  double itemsConfidence;  // Average of item confidences

  double overallConfidence;  // Average of all scores
  String? notes;  // Issue descriptions

  // Helpers
  bool get isLowConfidence => overallConfidence < 0.6
  bool get isMediumConfidence => overallConfidence >= 0.6 && < 0.8
  bool get isHighConfidence => overallConfidence >= 0.8

  String getConfidenceLevelText()
  String getConfidenceColorKey()
}

class ParsedReceiptItem {
  String name;
  int price;
  double confidence;  // Item-specific confidence
  String? suggestedCategory;  // Auto-suggested category
  String? notes;
}
```

#### 4. **OcrReviewScreen** (`lib/screens/ocr_review_screen.dart`)

**Tanggung Jawab:** User review & manual editing dengan confidence indicators

**Features:**

- Overall confidence indicator dengan color coding (green/orange/red)
- Per-field confidence badges
- Per-item confidence scores
- Smart warning banners:
  - **Low confidence** (< 60%): Merah warning, detailed message
  - **Medium confidence** (60-80%): Oranye info
  - **High confidence** (> 80%): No warning icon (optional green checkmark)
- Editable form fields dengan confidence colors
- Add/remove items functionality
- Save button to finalize

### Confidence Scoring Strategy

**Overall Confidence = Average(storeNameConf, dateConf, totalConf, itemsConf)**

**Per-Field Scoring:**

| Field      | High (0.9+)               | Medium (0.6-0.8)        | Low (< 0.6)            |
| ---------- | ------------------------- | ----------------------- | ---------------------- | --- |
| Store Name | No digits in name (0.9)   | Has digits (0.6)        | Too short/long         | -   |
| Date       | Format match regex (0.95) | Month name match (0.90) | No date found (0.0)    |
| Total      | Keyword match (0.95)      | Multiple prices (0.70)  | Single price (0.70)    |
| Item       | Single price (0.85)       | Multiple prices (0.70)  | Low name quality (0.5) |

**Confidence Adjustment Factors:**

- Item name very long (>20 chars): × 0.9
- Item name good length (5-20): × 1.0
- Item name short (<5): × 0.8

### Fallback & Error Handling

```dart
// Empty parsing result
ParsedReceipt(items: [])

// Missing fields
GeneratedIssue: "Nama toko kurang jelas"
GeneratedIssue: "Tanggal kurang jelas"
GeneratedIssue: "Total pembayaran kurang jelas"
GeneratedIssue: "Detail item kurang akurat"
GeneratedIssue: "Tidak ada item yang terdeteksi"

// User can still save incomplete data
// But warned about quality via confidence score
```

### Usage Example

```dart
// 1. Capture image (OcrCaptureScreen)
final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);

// 2. Process with OCR
final ocrService = OcrService();
final ocrResult = await ocrService.recognizeText(File(pickedFile.path));

// 3. Access parsed result with confidence
final receipt = ocrResult.parsedReceipt;
print('Store: ${receipt.storeName} (${receipt.storeNameConfidence * 100}%)');
print('Overall confidence: ${receipt.overallConfidence * 100}%');

// 4. Display in review screen
Navigator.pushNamed(
  context,
  '/ocr-review',
  arguments: {'imageFile': imageFile, 'ocrResult': ocrResult},
);

// 5. User edits, then saves
// Confidence scores guide user which fields need attention
```

### Performance Notes

- ✅ On-device processing (no network required)
- ✅ Latin script recognition (Indonesian compatible)
- ⚠️ First run: ~2-3s (MLKit initialization)
- ⚠️ Subsequent runs: ~1-2s (processing only)
- ✅ Parsing: <100ms (pure Dart, very fast)

### Known Limitations & Improvements

**Current Accuracy: ~75-85% depending on receipt quality**

**Factors affecting accuracy:**

- Receipt image quality (blur, lighting)
- Font size & clarity
- Receipt format (thermal printer vs. laser)

**Possible improvements (future):**

- Better OCR correction using Levenshtein distance
- ML model for category classification
- Price validation against known stores
- Receipt template recognition
- Historical data for better predictions

---

## �🔐 Security Considerations

### Data Security

- ✅ All data stored locally (SQLite) - tidak kirim ke server
- ✅ Sensitive data tidak di-hardcode
- ✅ Time-sensitive operations di-validate

### Best Practices

```dart
// ✅ GOOD - Secure date handling
final dateString = selectedDate.toString().split(' ')[0];  // YYYY-MM-DD

// ✅ GOOD - Validate input sebelum save
if (int.tryParse(hargaController.text) == null) {
  showError('Invalid price');
}

// ❌ BAD - Trust user input tanpa validate
int harga = int.parse(hargaController.text);  // Bisa crash
```

---

## 🔄 Maintenance & Future Development

### Adding New Feature

1. Add model property (if needed)
2. Update DatabaseHelper schema
3. Add service method
4. Create/update UI screen
5. Add routing if needed
6. Update theme/constants if needed

### Updating Existing Feature

1. Check all dependent code
2. Update model
3. Update database migration (if schema changes)
4. Update service logic
5. Test all screens using feature
6. Update documentation

---

## 📖 Further Reading

- [Flutter Architecture Official Guide](https://flutter.dev/docs/development/data-and-backend/state-mgmt)
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture)
- [SQLite Best Practices](https://www.sqlite.org/bestpractice.html)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)

---

**Remember:** Code is read more often than it's written. Make it clean, readable, and maintainable! 🚀
