import 'package:flutter/material.dart';
import 'package:duitkuu/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        elevation: 0,
        backgroundColor: AppTheme.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // App logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryBlue, Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.wallet_giftcard,
                size: 50,
                color: AppTheme.white,
              ),
            ),
            const SizedBox(height: 24),

            // App name & version
            Text(
              'Duitku',
              style: AppTheme.headlineLarge.copyWith(fontSize: 36),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accentBlueLight.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Versi 1.1',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'ATUR UANGMU, ATUR HIDUPMU',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.darkGray,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Deskripsi aplikasi
            _buildInfoCard(
              icon: Icons.info_outline,
              title: 'Tentang Duitku',
              description:
                  'Aplikasi pencatatan pengeluaran pribadi berbasis mobile yang membantu Anda mengelola keuangan sehari-hari secara sederhana, cepat, dan offline. Semua data disimpan lokal di perangkat Anda.',
              iconColor: AppTheme.primaryBlue,
              backgroundColor: const Color(0xFFE0E7FF),
            ),
            const SizedBox(height: 16),

            // Developer
            _buildInfoCard(
              icon: Icons.person,
              title: 'Pengembang',
              description:
                  'Dibuat oleh:\nMuhammad Ridho as Biru Laut\nFull Stack Dev find\nme on instagram @cn.doo',
              iconColor: const Color(0xFF8B5CF6),
              backgroundColor: const Color(0xFFF3E8FF),
            ),
            const SizedBox(height: 16),

            // Fitur saat ini
            _buildInfoCard(
              icon: Icons.check_circle,
              title: 'Fitur Saat Ini',
              description:
                  'Pencatatan pengeluaran\nFilter & cari transaksi\nAnalisis pengeluaran\nData offline lokal',
              iconColor: const Color(0xFF10B981),
              backgroundColor: const Color(0xFFECFDF5),
            ),
            const SizedBox(height: 16),

            // Roadmap
            _buildRoadmapCard(),
            const SizedBox(height: 16),

            // Catatan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentBlueLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.accentBlueLight.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.privacy_tip,
                        color: AppTheme.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Catatan Penting',
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aplikasi ini bersifat offline dan fokus pada penggunaan pribadi. Semua data disimpan aman di perangkat Anda dan tidak akan pernah dikirim ke server.',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.darkGrayText,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Settings Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
                icon: const Icon(Icons.settings),
                label: const Text('Gemini AI'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCyan,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Thank you message
            Column(
              children: [
                Text(
                  'Terima kasih telah menggunakan Duitku!',
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.flutter_dash, color: AppTheme.primaryBlue),
                    const SizedBox(width: 8),
                    Text(
                      'Built with Flutter',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.darkGray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTheme.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.darkGrayText,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3DD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.warningOrange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.warningOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.rocket_launch,
                  color: AppTheme.warningOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Rencana Mendatang',
                style: AppTheme.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warningOrange.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ROADMAP 2026',
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.warningOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...[
            'Scan struk (OCR) [Soon]',
            'Peningkatan akurasi OCR dengan AI',
            'Analisis keuangan lebih detail & insights',
            'Pengelolaan budget per kategori',
            'Cloud backup & sinkronisasi data',
            'Prediksi pengeluaran dengan ML',
            'Fitur berbagi budget keluarga',
          ].map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                item,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.darkGrayText,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
