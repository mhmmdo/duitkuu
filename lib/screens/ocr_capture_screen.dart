import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:duitkuu/services/ocr_service.dart';
import 'package:duitkuu/theme/app_theme.dart';

class OcrCaptureScreen extends StatefulWidget {
  const OcrCaptureScreen({Key? key}) : super(key: key);

  @override
  State<OcrCaptureScreen> createState() => _OcrCaptureScreenState();
}

class _OcrCaptureScreenState extends State<OcrCaptureScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final OcrService _ocrService = OcrService();
  bool _isProcessing = false;

  /// Ambil foto dari kamera
  Future<void> _captureFromCamera() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _processImage(File(pickedFile.path));
      }
    } catch (e) {
      _showErrorSnackbar('Gagal membuka kamera: $e');
    }
  }

  /// Pilih foto dari galeri
  Future<void> _pickFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _processImage(File(pickedFile.path));
      }
    } catch (e) {
      _showErrorSnackbar('Gagal membuka galeri: $e');
    }
  }

  /// Proses gambar dengan OCR
  Future<void> _processImage(File imageFile) async {
    if (!mounted) return;

    setState(() => _isProcessing = true);

    try {
      final result = await _ocrService.recognizeText(imageFile);

      if (!mounted) return;

      if (result.rawText.isEmpty) {
        _showErrorSnackbar(
          'Tidak ada teks ditemukan. Coba gambar yang lebih jelas.',
        );
      } else {
        // Navigate ke halaman review
        Navigator.pushNamed(
          context,
          '/ocr-review',
          arguments: {'imageFile': imageFile, 'ocrResult': result},
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Gagal memproses gambar: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: const Text('Scan Struk'),
        elevation: 0,
        backgroundColor: AppTheme.white,
      ),
      body: _isProcessing ? _buildProcessingWidget() : _buildCaptureWidget(),
    );
  }

  Widget _buildProcessingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.primaryBlue),
          const SizedBox(height: 24),
          Text('Sedang memproses struk...', style: AppTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Mohon tunggu sebentar',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.darkGray),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureWidget() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.receipt_long,
              size: 64,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 32),

          // Judul
          Text(
            'Scan Struk Belanja',
            style: AppTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Deskripsi
          Text(
            'Ambil foto struk Anda untuk secara otomatis\nmengekstrak informasi pengeluaran',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.darkGray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Tombol Kamera
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _captureFromCamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Ambil dari Kamera'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tombol Galeri
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.image),
              label: const Text('Pilih dari Galeri'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryBlue,
                side: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accentBlueLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.accentBlueLight.withOpacity(0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Tips untuk hasil terbaik:',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...[
                  'Pastikan struk terlihat jelas dan tidak blur',
                  'Ambil foto dengan cahaya yang cukup',
                  'Anda dapat mengedit hasil setelah scan',
                ].map((tip) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Icon(
                            Icons.check_circle,
                            color: AppTheme.successGreen,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(tip, style: AppTheme.bodySmall)),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Jangan dispose _ocrService karena menggunakan singleton
    super.dispose();
  }
}
