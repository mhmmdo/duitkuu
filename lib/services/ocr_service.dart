import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:duitkuu/models/parsed_receipt_model.dart';
import 'package:duitkuu/services/receipt_parser.dart';

class OcrResult {
  final String rawText;
  final ParsedReceipt parsedReceipt;

  // Backward compatibility - untuk UI lama
  @Deprecated('Use parsedReceipt instead')
  final List<String> items;

  @Deprecated('Use parsedReceipt.totalAmount instead')
  final int? total;

  @Deprecated('Use parsedReceipt.storeName instead')
  final String? storeName;

  @Deprecated('Use parsedReceipt.date instead')
  final String? date;

  @Deprecated('Use parsedReceipt.items instead')
  final List<OcrItem> extractedItems;

  OcrResult({
    required this.rawText,
    required this.parsedReceipt,
    this.items = const [],
    this.total,
    this.storeName,
    this.date,
    required this.extractedItems,
  });
}

class OcrItem {
  String name;
  int price;
  String? category;
  String? notes;

  OcrItem({required this.name, required this.price, this.category, this.notes});

  Map<String, dynamic> toMap() {
    return {'name': name, 'price': price, 'category': category, 'notes': notes};
  }
}

class OcrService {
  static final OcrService _instance = OcrService._internal();
  late final TextRecognizer _textRecognizer;

  OcrService._internal() {
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }

  factory OcrService() {
    return _instance;
  }

  /// Recognize text dari gambar dan parse dengan confidence scores
  Future<OcrResult> recognizeText(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      final rawText = recognizedText.text;

      // Gunakan ReceiptParser untuk parsing dengan confidence scores
      final parsedReceipt = ReceiptParser.parseReceipt(rawText);

      // Convert untuk backward compatibility dengan OcrItem
      final extractedItems = parsedReceipt.items
          .map(
            (item) => OcrItem(
              name: item.name,
              price: item.price,
              category: item.suggestedCategory,
              notes: item.notes,
            ),
          )
          .toList();

      return OcrResult(
        rawText: rawText,
        parsedReceipt: parsedReceipt,
        items: [], // deprecated
        total: parsedReceipt.totalAmount,
        storeName: parsedReceipt.storeName,
        date: parsedReceipt.date,
        extractedItems: extractedItems,
      );
    } catch (e) {
      debugPrint('OCR Error: $e');
      return OcrResult(
        rawText: '',
        parsedReceipt: ParsedReceipt(items: []),
        extractedItems: [],
      );
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _textRecognizer.close();
  }
}
