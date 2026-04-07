import 'package:intl/intl.dart';

class AppFormatter {
  /// Format harga ke Rupiah (Rp)
  static String formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Format tanggal ke format readable (dd MMM yyyy)
  static String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('dd MMM yyyy', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }

  /// Format tanggal ke format readable dengan hari (EEEE, dd MMM yyyy)
  static String formatDateWithDay(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('EEEE, dd MMM yyyy', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }

  /// Format tanggal ke format pendek (dd/MM)
  static String formatDateShort(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('dd/MM', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }

  /// Format bulan (MMMM yyyy)
  static String formatMonth(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('MMMM yyyy', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }

  /// Format hanya bulan dan tahun dari string tipe "2024-12"
  static String formatMonthFromKey(String monthKey) {
    try {
      final date = DateTime.parse('$monthKey-01');
      final formatter = DateFormat('MMMM yyyy', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return monthKey;
    }
  }

  /// Get nama hari (Senin, Selasa, etc)
  static String getDayName(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('EEEE', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return '';
    }
  }

  /// Cek apakah tanggal adalah hari ini
  static bool isToday(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final today = DateTime.now();
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    } catch (e) {
      return false;
    }
  }

  /// Cek apakah tanggal adalah kemarin
  static bool isYesterday(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      return date.year == yesterday.year &&
          date.month == yesterday.month &&
          date.day == yesterday.day;
    } catch (e) {
      return false;
    }
  }

  /// Format tanggal relatif (Hari ini, Kemarin, atau tanggal)
  static String formatDateRelative(String dateString) {
    if (isToday(dateString)) {
      return 'Hari ini';
    } else if (isYesterday(dateString)) {
      return 'Kemarin';
    } else {
      return formatDate(dateString);
    }
  }
}
