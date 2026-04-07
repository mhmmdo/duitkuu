import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:duitkuu/models/parsed_receipt_model.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  String? _apiKey;

  GeminiService._internal();

  factory GeminiService() {
    return _instance;
  }

  /// Set Gemini API key (dari user settings)
  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  /// Check jika API key sudah di-set
  bool hasApiKey() {
    return _apiKey != null && _apiKey!.isNotEmpty;
  }

  /// Parse receipt text menggunakan Gemini API
  Future<ParsedReceipt> parseReceiptWithGemini(String rawText) async {
    if (!hasApiKey()) {
      throw Exception('Gemini API key tidak di-set');
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey!,
      );

      final prompt =
          '''
Analisis teks OCR dari struk belanja berikut dan ekstrak informasi strukturnya.

Teks OCR:
"""
$rawText
"""

Berikan respons dalam format JSON dengan struktur berikut (HANYA JSON, tanpa teks lain):
{
  "storeName": "nama toko/merchant atau null",
  "date": "tanggal dalam format YYYY-MM-DD atau null",
  "totalAmount": jumlah total pembayaran atau null,
  "items": [
    {
      "name": "nama item",
      "price": harga item sebagai angka
    }
  ],
  "confidence": 0.0 sampai 1.0 (confidence score keseluruhan)
}

Catatan:
- Ekstrak dengan akurat nama toko/merchant dari struk
- Tanggal harus format YYYY-MM-DD, jika ada gunakan tanggal terkini jika tidak ditemukan
- Total adalah jumlah akhir yang harus dibayar (bukan subtotal/diskon/pajak)
- Items hanya yang dibeli (skip alamat, no telepon, promo, diskon, pajak, dll)
- Harga items harus angka positif (dalam Rupiah, tanpa Rp)
- Confidence: tinggi (0.8-1.0) jika parsing jelas, medium (0.5-0.8) jika ada ambiguitas
- Jika OCR sangat buruk/tidak jelas, kembalikan JSON kosong/minimal dengan confidence rendah
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Gemini tidak memberikan respons');
      }

      // Parse JSON response
      return _parseGeminiResponse(response.text!);
    } catch (e) {
      throw Exception('Error parsing dengan Gemini: $e');
    }
  }

  /// Parse Gemini JSON response
  ParsedReceipt _parseGeminiResponse(String jsonResponse) {
    try {
      // Clean JSON dari markdown jika ada
      String cleanedJson = jsonResponse;
      if (cleanedJson.contains('```json')) {
        cleanedJson = cleanedJson
            .replaceAll('```json', '')
            .replaceAll('```', '');
      } else if (cleanedJson.contains('```')) {
        cleanedJson = cleanedJson.replaceAll('```', '');
      }
      cleanedJson = cleanedJson.trim();

      // Parse dengan jsonDecode (built-in Dart)
      final jsonMap = jsonDecode(cleanedJson) as Map<String, dynamic>;

      // Extract data
      final storeName = jsonMap['storeName'] as String?;
      final date = jsonMap['date'] as String?;
      final totalAmount = _parseNumber(jsonMap['totalAmount']);
      final confidence = _parseDouble(jsonMap['confidence']) ?? 0.8;

      // Parse items
      final items = <ParsedReceiptItem>[];
      final itemsList = jsonMap['items'] as List?;

      if (itemsList != null && itemsList.isNotEmpty) {
        for (final item in itemsList) {
          if (item is Map<String, dynamic>) {
            final name = item['name'] as String?;
            final price = _parseNumber(item['price']);

            if (name != null && name.isNotEmpty && price != null && price > 0) {
              items.add(
                ParsedReceiptItem(
                  name: name,
                  price: price,
                  confidence: confidence,
                ),
              );
            }
          }
        }
      }

      // Auto-calculate total dari items jika items ada
      int? calculatedTotal = totalAmount;
      if (items.isNotEmpty &&
          (calculatedTotal == null || calculatedTotal <= 0)) {
        calculatedTotal = items.fold<int>(0, (sum, item) => sum + item.price);
      }

      return ParsedReceipt(
        storeName: storeName,
        date: date,
        totalAmount: calculatedTotal,
        items: items,
        storeNameConfidence: confidence,
        dateConfidence: confidence,
        totalConfidence: confidence,
        notes: items.isEmpty
            ? 'Items parsing error, please add manually'
            : 'Parsed with Gemini AI',
      );
    } catch (e) {
      throw Exception('Failed to parse Gemini response: $e');
    }
  }

  /// Parse JSON string safely
  Map<String, dynamic> _parseJsonString(String jsonString) {
    try {
      // Simple JSON parser untuk kasus sederhana
      // Ini tidak ideal tapi lebih reliable daripada jsonDecode yang error handling-nya ketat

      final map = <String, dynamic>{};

      // Extract key-value pairs
      final pattern = RegExp(r'"(\w+)"\s*:\s*([^,}]+)');
      for (final match in pattern.allMatches(jsonString)) {
        final key = match.group(1);
        final value = match.group(2)?.trim();

        if (key != null && value != null) {
          // Try parse value
          if (value == 'null') {
            map[key] = null;
          } else if (value.startsWith('"') && value.endsWith('"')) {
            map[key] = value.substring(1, value.length - 1);
          } else if (value.startsWith('[')) {
            // Parse array
            map[key] = _parseJsonArray(value);
          } else {
            // Try as number
            try {
              if (value.contains('.')) {
                map[key] = double.parse(value);
              } else {
                map[key] = int.parse(value);
              }
            } catch (_) {
              map[key] = value;
            }
          }
        }
      }

      return map;
    } catch (e) {
      return {};
    }
  }

  /// Parse JSON array
  List<dynamic> _parseJsonArray(String arrayString) {
    try {
      final items = <Map<String, dynamic>>[];

      // Extract objects dari array
      final objectPattern = RegExp(r'\{[^{}]*\}');
      for (final match in objectPattern.allMatches(arrayString)) {
        final objStr = match.group(0) ?? '';
        final obj = <String, dynamic>{};

        // Parse object properties
        final propPattern = RegExp(r'"(\w+)"\s*:\s*([^,}]+)');
        for (final propMatch in propPattern.allMatches(objStr)) {
          final key = propMatch.group(1);
          final value = propMatch.group(2)?.trim();

          if (key != null && value != null) {
            if (value == 'null') {
              obj[key] = null;
            } else if (value.startsWith('"') && value.endsWith('"')) {
              obj[key] = value.substring(1, value.length - 1);
            } else {
              try {
                obj[key] = int.parse(value);
              } catch (_) {
                try {
                  obj[key] = double.parse(value);
                } catch (_) {
                  obj[key] = value;
                }
              }
            }
          }
        }

        if (obj.isNotEmpty) {
          items.add(obj);
        }
      }

      return items;
    } catch (e) {
      return [];
    }
  }

  /// Parse number dari berbagai format
  int? _parseNumber(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;
    if (value is double) return value.toInt();

    if (value is String) {
      try {
        return int.parse(value.replaceAll(RegExp(r'[^0-9]'), ''));
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  /// Parse double
  double? _parseDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;
    if (value is int) return value.toDouble();

    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return null;
      }
    }

    return null;
  }
}
