import 'package:flutter/material.dart';
import 'package:duitkuu/services/app_settings.dart';
import 'package:duitkuu/services/gemini_service.dart';
import 'package:duitkuu/databases/database_helper.dart';
import 'package:duitkuu/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppSettings _settings = AppSettings();
  final GeminiService _geminiService = GeminiService();
  late TextEditingController _apiKeyController;
  bool _showApiKey = false;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(
      text: _settings.getGeminiApiKey() ?? '',
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _saveApiKey() {
    final key = _apiKeyController.text.trim();

    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API Key tidak boleh kosong'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    // Simpan
    _settings.setGeminiApiKey(key);
    _geminiService.setApiKey(key);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('API Key berhasil disimpan!'),
        backgroundColor: AppTheme.successGreen,
      ),
    );

    Navigator.pop(context);
  }

  void _clearApiKey() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus API Key?'),
        content: const Text(
          'API Key akan dihapus dan OCR improvement tidak akan berfungsi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              _settings.clearGeminiApiKey();
              _apiKeyController.clear();
              Navigator.pop(context);
              setState(() {});

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('API Key dihapus'),
                  backgroundColor: AppTheme.warningOrange,
                ),
              );
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  void _resetDatabase() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Database?'),
        content: const Text(
          '⚠️ Semua data transaksi akan dihapus dan tidak bisa dikembalikan!\n\n'
          'Database akan kosong dan ready untuk data baru.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final dbHelper = DatabaseHelper();
                await dbHelper.resetDatabase();
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Database berhasil di-reset!'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Error: $e'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Reset Semua Data',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasApiKey = _settings.hasValidApiKey();

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: const Text('Pengaturan'),
        elevation: 0,
        backgroundColor: AppTheme.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gemini API Section
            Text('Gemini AI Configuration', style: AppTheme.titleLarge),
            const SizedBox(height: 12),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppTheme.mediumGray),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: hasApiKey
                                ? AppTheme.successGreen
                                : AppTheme.warningOrange,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          hasApiKey ? 'API Key Terkonfigurasi' : 'Belum Setup',
                          style: AppTheme.bodyMedium.copyWith(
                            color: hasApiKey
                                ? AppTheme.successGreen
                                : AppTheme.warningOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Deskripsi
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentCyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fungsi:',
                            style: AppTheme.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '• Meningkatkan akurasi OCR struk belanja\n'
                            '• Parsing otomatis nama toko, tanggal, total\n'
                            '• Ekstrak items dari struk dengan lebih akurat',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // API Key Input
                    TextField(
                      controller: _apiKeyController,
                      obscureText: !_showApiKey,
                      decoration: InputDecoration(
                        labelText: 'Google Gemini API Key',
                        hintText: 'AIzaSy...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showApiKey
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => _showApiKey = !_showApiKey);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Link help
                    GestureDetector(
                      onTap: () {
                        // TODO: Open link
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Buka: https://ai.google.dev/\n'
                              'Klik "Get API Key" → Buat project → Copy API Key',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.primaryBlue.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.help_outline,
                              size: 18,
                              color: AppTheme.primaryBlue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Bagaimana cara dapat API Key?',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_outward,
                              size: 16,
                              color: AppTheme.primaryBlue,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveApiKey,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Simpan API Key'),
                          ),
                        ),
                        if (hasApiKey) ...[
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: _clearApiKey,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.errorRed,
                              side: const BorderSide(color: AppTheme.errorRed),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Icon(Icons.delete),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Reset Database Section
            Text('⚠️ Database', style: AppTheme.titleLarge),
            const SizedBox(height: 12),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: AppTheme.errorRed.withOpacity(0.3),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reset Semua Data Transaksi',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hapus semua data lama dan mulai fresh. Gunakan ini jika database lama sudah tidak diperlukan.',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.darkGray,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _resetDatabase,
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('Reset Database'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorRed,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Info Section
            Text('ℹ️ Informasi', style: AppTheme.titleLarge),
            const SizedBox(height: 12),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppTheme.mediumGray),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem(
                      icon: Icons.cloud_off,
                      title: 'Fully Offline',
                      desc:
                          'Tanpa API Key, OCR tetap bekerja offline dengan MLKit',
                    ),
                    const Divider(),
                    _buildInfoItem(
                      icon: Icons.cloud_upload,
                      title: 'Optional Online',
                      desc:
                          'Gunakan Gemini hanya jika ingin akurasi lebih tinggi',
                    ),
                    const Divider(),
                    _buildInfoItem(
                      icon: Icons.security,
                      title: 'Privacy',
                      desc: 'API Key disimpan lokal di device Anda saja',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.darkGray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
