import 'package:duitkuu/models/parsed_receipt_model.dart';

/// Parser untuk OCR receipt text dengan normalisasi dan confidence scoring
class ReceiptParser {
  // Keywords untuk abaikan (metadata, bukan item)
  static const List<String> _irrelevantKeywords = [
    'telp',
    'phone',
    'no.',
    'no ',
    'alamat',
    'pukul',
    'jam',
    'kasir',
    'cashier',
    'operator',
    'terima kasih',
    'terimakasih',
    'thank you',
    'thanks',
    'item',
    'qty',
    'kuantitas',
    'jumlah',
    'kembalian',
    'change',
    'cash',
    'tunai',
    'bayar',
    'payment',
    'diskon',
    'discount',
    'ppn',
    'pajak',
    'tax',
    'tanda',
    'tangan',
    'ttd',
    'stempel',
    'stamp',
    'signature',
    'barcode',
    'qrcode',
    'invoice',
    'no invoice',
    'receipt',
    'struk',
    'bukti',
    'saldo',
    'balance',
    'subtotal',
    'sub total',
    'service',
    'tip',
  ];

  // Keywords untuk deteksi total pembayaran (prioritas tinggi)
  static const List<String> _totalKeywords = [
    'total',
    'total bayar',
    'totalbayar',
    'grand total',
    'grandtotal',
    'jumlah bayar',
    'jumlahbayar',
    'amount',
    'total charge',
    'payable',
    'bayar',
  ];

  // Pattern untuk deteksi tanggal
  static final RegExp _datePattern1 = RegExp(
    r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})',
  );
  static final RegExp _datePattern2 = RegExp(
    r'(\d{4})[/-](\d{1,2})[/-](\d{1,2})',
  );
  static final RegExp _datePatternMonthName = RegExp(
    r'(\d{1,2})\s+(januari|februari|maret|april|mei|juni|juli|agustus|september|oktober|november|desember|jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)',
    caseSensitive: false,
  );

  // Pattern untuk harga/angka
  static final RegExp _pricePattern = RegExp(
    r'(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?)|\d{2,}',
  );

  /// Main parsing function
  static ParsedReceipt parseReceipt(String rawText) {
    // Step 1: Normalisasi teks
    final normalizedLines = _normalizeText(rawText);

    // Step 2: Identifikasi section-section
    String? storeName;
    double storeNameConfidence = 0.0;

    String? date;
    double dateConfidence = 0.0;

    int? total;
    double totalConfidence = 0.0;

    final List<ParsedReceiptItem> items = [];
    double itemsConfidence = 0.0;

    // Step 3: Parse line by line
    final List<String> potentialItems = [];
    final Set<String> seenItems = {};

    for (int i = 0; i < normalizedLines.length; i++) {
      final line = normalizedLines[i];
      final lineLower = line.toLowerCase();

      // Skip line kosong atau terlalu pendek
      if (line.isEmpty || line.length < 3) continue;

      // Skip jika mengandung keyword irrelevant
      if (_containsRelevantKeyword(lineLower)) continue;

      // --- DETEKSI NAMA TOKO (baris awal, tanpa angka)
      if (storeName == null && i < 5) {
        final storeCandidate = _parseStoreName(line);
        if (storeCandidate != null) {
          storeName = storeCandidate['name'];
          storeNameConfidence = storeCandidate['confidence'];
        }
      }

      // --- DETEKSI TANGGAL
      if (date == null) {
        final dateMatch = _parseDate(lineLower);
        if (dateMatch != null) {
          date = dateMatch['date'];
          dateConfidence = dateMatch['confidence'];
        }
      }

      // --- DETEKSI TOTAL PEMBAYARAN
      if (total == null) {
        final totalMatch = _parseTotal(line, lineLower);
        if (totalMatch != null) {
          total = totalMatch['amount'];
          totalConfidence = totalMatch['confidence'];
        }
      }

      // --- DETEKSI ITEM BELANJA
      final itemMatch = _parseItem(line, lineLower);
      if (itemMatch != null && !seenItems.contains(itemMatch['name'])) {
        items.add(
          ParsedReceiptItem(
            name: itemMatch['name'],
            price: itemMatch['price'],
            confidence: itemMatch['confidence'],
            suggestedCategory: itemMatch['category'],
          ),
        );
        seenItems.add(itemMatch['name']);
      }
    }

    // Step 4: Hitung overall confidence
    final confidences = <double>[
      storeNameConfidence,
      dateConfidence,
      totalConfidence,
      if (items.isNotEmpty)
        items.map((e) => e.confidence).reduce((a, b) => (a + b) / 2),
    ];

    final double overallConfidence = confidences.isEmpty
        ? 0.0
        : confidences.reduce((a, b) => (a + b) / 2);

    final double itemsAvgConfidence = items.isEmpty
        ? 0.0
        : items.map((e) => e.confidence).reduce((a, b) => (a + b) / 2);

    // Step 5: Generate notes jika ada issue
    String? notes;
    final List<String> issues = [];

    if (storeNameConfidence < 0.5) issues.add('Nama toko kurang jelas');
    if (dateConfidence < 0.5) issues.add('Tanggal kurang jelas');
    if (totalConfidence < 0.5) issues.add('Total pembayaran kurang jelas');
    if (itemsAvgConfidence < 0.6) issues.add('Detail item kurang akurat');
    if (items.isEmpty) issues.add('Tidak ada item yang terdeteksi');

    if (issues.isNotEmpty) {
      notes = issues.join(', ');
    }

    return ParsedReceipt(
      storeName: storeName,
      storeNameConfidence: storeNameConfidence,
      date: date,
      dateConfidence: dateConfidence,
      totalAmount: total,
      totalConfidence: totalConfidence,
      items: items,
      itemsConfidence: itemsAvgConfidence,
      overallConfidence: overallConfidence,
      notes: notes,
    );
  }

  /// Normalisasi teks OCR
  static List<String> _normalizeText(String rawText) {
    // Lowercase
    var text = rawText.toLowerCase();

    // Perbaiki common OCR mistakes
    text = text.replaceAll(RegExp(r'[lI1]\s*[oO0]'), 'lo'); // "lO" -> "lo"
    text = text.replaceAll(RegExp(r'[rn]([aeiou])'), r'rn$1'); // "rn" pattern
    text = text.replaceAll(
      RegExp(r'[S](\d)'),
      r'5$1',
    ); // "S" terlihat seperti "5"
    text = text.replaceAll(
      RegExp(r'[B](\d)'),
      r'8$1',
    ); // "B" terlihat seperti "8"

    // Rapikan spasi berlebih
    text = text.replaceAll(RegExp(r'\s+'), ' ');

    // Rapikan simbol mata uang
    text = text.replaceAll('rp', '');
    text = text.replaceAll('Rp', '');
    text = text.replaceAll('RP', '');
    text = text.replaceAll(RegExp(r'Rp\.'), '');
    text = text.replaceAll(RegExp(r'\$'), '');

    // Split menjadi lines dan bersihkan
    final lines = text.split('\n');
    return lines
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  /// Periksa apakah line mengandung keyword irrelevant
  static bool _containsRelevantKeyword(String text) {
    return _irrelevantKeywords.any((keyword) => text.contains(keyword));
  }

  /// Parse nama toko dari line
  static Map<String, dynamic>? _parseStoreName(String line) {
    final lineLower = line.toLowerCase();

    // Nama toko biasanya:
    // - Tidak mengandung angka
    // - Panjang 5-50 karakter
    // - Di awal document
    if (line.length >= 5 && line.length <= 50) {
      final digitCount = line.replaceAll(RegExp(r'[0-9]'), '').length;
      if (digitCount > 5 && !_containsRelevantKeyword(lineLower)) {
        // Tinggi confidence jika tidak ada angka sama sekali
        final hasNumbers = RegExp(r'\d').hasMatch(line);
        final confidence = hasNumbers ? 0.6 : 0.9;

        return {'name': _cleanStoreName(line), 'confidence': confidence};
      }
    }

    return null;
  }

  /// Bersihkan nama toko dari karakter aneh
  static String _cleanStoreName(String name) {
    return name.replaceAll(RegExp(r'[^a-z0-9\s\-&]'), '').trim();
  }

  /// Parse tanggal dari line
  static Map<String, dynamic>? _parseDate(String lineLower) {
    // Try pattern 1: dd/mm/yyyy atau dd-mm-yyyy
    final match1 = _datePattern1.firstMatch(lineLower);
    if (match1 != null) {
      return {'date': match1.group(0), 'confidence': 0.95};
    }

    // Try pattern 2: yyyy/mm/dd atau yyyy-mm-dd
    final match2 = _datePattern2.firstMatch(lineLower);
    if (match2 != null) {
      return {'date': match2.group(0), 'confidence': 0.95};
    }

    // Try pattern 3: 15 januari 2024 atau 15 jan 2024
    final match3 = _datePatternMonthName.firstMatch(lineLower);
    if (match3 != null) {
      return {'date': match3.group(0), 'confidence': 0.90};
    }

    return null;
  }

  /// Parse total pembayaran dari line
  static Map<String, dynamic>? _parseTotal(String line, String lineLower) {
    // Cek apakah line mengandung keyword total
    final isTotalKeywordPresent = _totalKeywords.any(
      (keyword) => lineLower.contains(keyword),
    );

    // Extract semua numbers dari line
    final priceMatches = _pricePattern.allMatches(line);
    if (priceMatches.isEmpty) return null;

    int? amount;
    double confidence = 0.0;

    if (priceMatches.length == 1) {
      // Single price = potential total
      final priceStr = priceMatches.last.group(0)!;
      final cleanPrice = _extractNumericValue(priceStr);

      if (cleanPrice > 50000 && cleanPrice < 1000000000) {
        amount = cleanPrice;
        // Confidence lebih tinggi jika ada keyword total
        confidence = isTotalKeywordPresent ? 0.95 : 0.70;
      }
    } else if (priceMatches.length > 1) {
      // Multiple prices = ambil yang terbesar
      int maxPrice = 0;
      for (final match in priceMatches) {
        final price = _extractNumericValue(match.group(0)!);
        if (price > maxPrice) maxPrice = price;
      }

      if (maxPrice > 50000 && maxPrice < 1000000000) {
        amount = maxPrice;
        // Confidence lebih tinggi jika ada keyword total
        confidence = isTotalKeywordPresent ? 0.90 : 0.60;
      }
    }

    if (amount == null) return null;

    return {'amount': amount, 'confidence': confidence};
  }

  /// Parse item belanja dari line
  static Map<String, dynamic>? _parseItem(String line, String lineLower) {
    // Skip jika mengandung keyword irrelevant
    if (_containsRelevantKeyword(lineLower)) return null;

    // Skip jika hanya angka/spasi
    if (RegExp(r'^[\d\s\-\+\.x,]*$').hasMatch(lineLower)) return null;

    // Extract harga
    final priceMatches = _pricePattern.allMatches(line);
    if (priceMatches.isEmpty) return null;

    int? price;
    String itemName = line;
    double confidence = 0.0;

    if (priceMatches.length == 1) {
      // Single price = normal item
      final priceStr = priceMatches.last.group(0)!;
      final cleanPrice = _extractNumericValue(priceStr);

      // Validasi range harga item (100 - 500k)
      if (cleanPrice >= 100 && cleanPrice <= 500000) {
        price = cleanPrice;
        confidence = 0.85;

        // Bersihkan nama item
        itemName = line.replaceAll(priceMatches.last.group(0)!, '').trim();
      }
    } else if (priceMatches.length > 1) {
      // Multiple prices = ambil yang terakhir/terbesar untuk item
      final priceStr = priceMatches.last.group(0)!;
      final cleanPrice = _extractNumericValue(priceStr);

      if (cleanPrice >= 100 && cleanPrice <= 500000) {
        price = cleanPrice;
        confidence = 0.70; // Lower confidence untuk multiple prices

        // Bersihkan nama item
        itemName = line.replaceAll(priceMatches.last.group(0)!, '').trim();
      }
    }

    if (price == null || itemName.isEmpty) return null;

    // Validasi item name
    final letterCount = itemName.replaceAll(RegExp(r'[^a-z]'), '').length;
    if (letterCount < 3) return null;

    // Bersihkan quantity suffix
    itemName = itemName.replaceAll(RegExp(r'\s+[\d\s\.x\/]+$'), '').trim();

    // Bersihkan karakter aneh
    itemName = itemName.replaceAll(RegExp(r'[^a-z0-9\s\-.]'), '').trim();

    // Trim panjang ke 50 karakter max
    if (itemName.length > 50) {
      itemName = itemName.substring(0, 50);
    }

    if (itemName.length < 3) return null;

    // Suggest category berdasarkan keywords
    final suggestedCategory = _suggestCategory(itemName);

    // Adjust confidence berdasarkan kualitas item name
    if (itemName.length > 20) {
      confidence *= 0.9; // Slightly lower untuk nama yang sangat panjang
    } else if (itemName.length >= 5) {
      confidence *= 1.0; // Full confidence
    } else {
      confidence *= 0.8; // Lower untuk nama pendek
    }

    return {
      'name': itemName,
      'price': price,
      'confidence': confidence,
      'category': suggestedCategory,
    };
  }

  /// Suggest kategori berdasarkan item name
  static String? _suggestCategory(String itemName) {
    final name = itemName.toLowerCase();

    // Minuman
    if (name.contains(
      RegExp(
        r'\b(kopi|teh|susu|jus|juice|air|minum|cola|sprite|fanta|aqua|mineral|es)\b',
      ),
    )) {
      return 'Minuman';
    }

    // Makanan
    if (name.contains(
      RegExp(
        r'\b(makan|nasi|roti|kue|cake|snack|makanan|burger|pizza|ayam|beras|sayur)\b',
      ),
    )) {
      return 'Makanan';
    }

    // Transport
    if (name.contains(
      RegExp(
        r'\b(bensin|bahan bakar|bbm|parkir|ongkir|grab|gojek|taksi|bus|kereta|transport)\b',
      ),
    )) {
      return 'Transport';
    }

    // Belanja
    if (name.contains(
      RegExp(r'\b(pakaian|baju|sepatu|tas|jam|aksesori|barang|belanja)\b'),
    )) {
      return 'Belanja';
    }

    // Kebutuhan
    if (name.contains(
      RegExp(
        r'\b(listrik|air|pulsa|internet|tagihan|bayar|utilitas|kebutuhan)\b',
      ),
    )) {
      return 'Kebutuhan';
    }

    // Hiburan
    if (name.contains(
      RegExp(
        r'\b(tiket|film|bioskop|game|musik|entertainment|hiburan|nonton)\b',
      ),
    )) {
      return 'Hiburan';
    }

    return null;
  }

  /// Extract numeric value dari price string
  static int _extractNumericValue(String priceStr) {
    // Remove semua non-digit
    final numericOnly = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(numericOnly) ?? 0;
  }
}
