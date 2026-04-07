import 'package:flutter/material.dart';
import 'package:duitkuu/screens/dashboard_screen.dart';
import 'package:duitkuu/screens/transaction_history_screen.dart';
import 'package:duitkuu/screens/analytics_screen.dart';
import 'package:duitkuu/screens/about_screen.dart';
import 'package:duitkuu/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionHistoryScreen(),
    const AnalyticsScreen(),
    const AboutScreen(),
  ];

  void _showActionMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Pilih Aksi', style: AppTheme.titleLarge),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle),
              title: const Text('Input Manual'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/add');
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Scan Struk (OCR)'),
              subtitle: const Text('Ambil foto struk belanja'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/ocr');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        height: 70,
        elevation: 8,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Dashboard
            _buildNavItem(index: 0, icon: Icons.home, label: 'Dashboard'),
            // Riwayat
            _buildNavItem(index: 1, icon: Icons.history, label: 'Riwayat'),
            // Space untuk FAB
            const SizedBox(width: 60),
            // Analisis
            _buildNavItem(index: 2, icon: Icons.analytics, label: 'Analisis'),
            // About
            _buildNavItem(index: 3, icon: Icons.info, label: 'About'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showActionMenu,
        backgroundColor: AppTheme.primaryBlue,
        elevation: 8,
        child: const Icon(Icons.add, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedIndex = index);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryBlue : AppTheme.darkGray,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppTheme.primaryBlue : AppTheme.darkGray,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
