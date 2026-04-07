import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:duitkuu/theme/app_theme.dart';
import 'package:duitkuu/screens/splash_screen.dart';
import 'package:duitkuu/screens/home_screen.dart';
import 'package:duitkuu/screens/add_edit_expense_screen.dart';
import 'package:duitkuu/screens/transaction_detail_screen.dart';
import 'package:duitkuu/screens/settings_screen.dart';
import 'package:duitkuu/screens/ocr_capture_screen.dart';
import 'package:duitkuu/screens/ocr_review_screen.dart';
import 'package:duitkuu/screens/about_screen.dart';
import 'package:duitkuu/models/expense.dart';
import 'package:duitkuu/services/ocr_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Duitku - Pencatat Pengeluaran',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/add': (context) => const AddEditExpenseScreen(),
        '/edit': (context) {
          final expense = ModalRoute.of(context)!.settings.arguments as Expense;
          return AddEditExpenseScreen(expense: expense);
        },
        '/detail': (context) {
          final expenseId = ModalRoute.of(context)!.settings.arguments as int;
          return TransactionDetailScreen(expenseId: expenseId);
        },
        '/settings': (context) => const SettingsScreen(),
        '/history': (context) => const HomeScreen(),
        '/ocr': (context) => const OcrCaptureScreen(),
        '/ocr-review': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return OcrReviewScreen(
            imageFile: args['imageFile'],
            ocrResult: args['ocrResult'],
          );
        },
        '/about': (context) => const AboutScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
