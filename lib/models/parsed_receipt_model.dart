/// Model untuk hasil parsing receipt OCR dengan confidence scores
class ParsedReceipt {
  final String? storeName;
  final double storeNameConfidence; // 0.0 - 1.0

  final String? date;
  final double dateConfidence;

  final int? totalAmount;
  final double totalConfidence;

  final List<ParsedReceiptItem> items;
  final double itemsConfidence; // rata-rata confidence items

  final double overallConfidence; // rata-rata semua confidence
  final String? notes; // catatan parsing (misal: "Low confidence detected")

  ParsedReceipt({
    this.storeName,
    this.storeNameConfidence = 0.0,
    this.date,
    this.dateConfidence = 0.0,
    this.totalAmount,
    this.totalConfidence = 0.0,
    required this.items,
    this.itemsConfidence = 0.0,
    this.overallConfidence = 0.0,
    this.notes,
  });

  /// Confidence assessment
  bool get isLowConfidence => overallConfidence < 0.6;
  bool get isMediumConfidence =>
      overallConfidence >= 0.6 && overallConfidence < 0.8;
  bool get isHighConfidence => overallConfidence >= 0.8;

  /// Get confidence level text for UI
  String getConfidenceLevelText() {
    if (isHighConfidence) {
      return 'Tinggi (${(overallConfidence * 100).toStringAsFixed(0)}%)';
    } else if (isMediumConfidence) {
      return 'Sedang (${(overallConfidence * 100).toStringAsFixed(0)}%)';
    } else {
      return 'Rendah (${(overallConfidence * 100).toStringAsFixed(0)}%)';
    }
  }

  /// Get color for confidence indicator
  String getConfidenceColorKey() {
    if (isHighConfidence) return 'high';
    if (isMediumConfidence) return 'medium';
    return 'low';
  }
}

/// Model untuk parsed receipt item
class ParsedReceiptItem {
  final String name;
  final int price;
  final double confidence; // 0.0 - 1.0
  String? suggestedCategory;
  String? notes;

  ParsedReceiptItem({
    required this.name,
    required this.price,
    required this.confidence,
    this.suggestedCategory,
    this.notes,
  });

  bool get isHighConfidence => confidence >= 0.8;
  bool get isMediumConfidence => confidence >= 0.6 && confidence < 0.8;
  bool get isLowConfidence => confidence < 0.6;
}
