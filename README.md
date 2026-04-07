# Duitkuu - Pencatat Pengeluaran Pribadi

[![Flutter](https://img.shields.io/badge/Flutter-3.11+-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11+-0175C2?style=flat-square&logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

**Duitkuu** adalah aplikasi mobile berbasis Flutter yang membantu Anda mengelola pengeluaran pribadi dengan mudah dan efisien. Dilengkapi dengan fitur **OCR (Optical Character Recognition)** untuk scan receipt otomatis dan **AI Gemini** untuk analisis pengeluaran cerdas, semuanya disimpan secara lokal di perangkat Anda.

<img src="demo/about.png" alt="Demo" width="300"/>

## Fitur Utama

- **Dashboard Interaktif** - Visualisasi pengeluaran dengan grafik dan statistik
- **Scan Receipt dengan OCR** - Ambil foto receipt dan data otomatis terekstrak
- **AI-Powered Receipt Parser** - Gemini AI membantu parse receipt complex
- **Kategori & Label** - Organisir pengeluaran dengan kategori yang fleksibel
- **Analytics Lengkap** - Laporan pengeluaran bulanan dan trend keuangan
- **Data Lokal** - Semua data disimpan lokal di perangkat, privasi terjamin
- **Desain Modern** - UI/UX yang intuitif dan responsif
- **Pengaturan Fleksibel** - Customize sesuai preferensi Anda
- **Dukungan Bahasa Indonesia** - Interface dalam bahasa lokal

## Mulai Cepat

### Prasyarat

- Flutter 3.11+ ([Download](https://flutter.dev/docs/get-started/install))
- Dart SDK 3.11+
- Android SDK (untuk Android) atau Xcode (untuk iOS)
- Git

### Instalasi

1. **Clone Repository**

   ```bash
   git clone https://github.com/yourusername/duitkuu.git
   cd duitkuu
   ```

2. **Install Dependencies**

   ```bash
   flutter pub get
   ```

3. **Setup Google Generative AI (Optional)**
   - Buat API key di [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Tambahkan ke `lib/services/gemini_service.dart`

4. **Jalankan Aplikasi**
   ```bash
   flutter run
   ```

## Penggunaan

### Menambah Pengeluaran

1. Tap tombol **+** di halaman utama
2. Pilih kategori dan masukkan jumlah
3. Tambahkan deskripsi dan tanggal
4. Simpan pengeluaran

### Scan Receipt

1. Buka menu **Scan Receipt**
2. Ambil foto receipt menggunakan kamera
3. Review data yang terekstrak oleh OCR
4. Edit jika diperlukan dan simpan

### Melihat Analytics

1. Buka tab **Analytics** di dashboard
2. Lihat visualisasi pengeluaran per kategori
3. Analisis trend pengeluaran bulanan

## Struktur Proyek

```
lib/
├── main.dart                 # Entry point aplikasi
├── screens/                  # UI Screens
│   ├── home_screen.dart
│   ├── dashboard_screen.dart
│   ├── add_edit_expense_screen.dart
│   ├── ocr_capture_screen.dart
│   ├── ocr_review_screen.dart
│   ├── analytics_screen.dart
│   ├── settings_screen.dart
│   └── about_screen.dart
├── models/                   # Data models
│   └── expense.dart
├── services/                 # Business logic
│   ├── expense_service.dart
│   ├── ocr_service.dart
│   ├── gemini_service.dart
│   └── receipt_parser.dart
├── databases/                # Database management
│   └── database_helper.dart
├── widgets/                  # Reusable widgets
├── theme/                    # Theme & styling
└── utils/                    # Utility functions
```

## Tech Stack

| Kategori         | Teknologi                      |
| ---------------- | ------------------------------ |
| **Framework**    | Flutter 3.11+                  |
| **Language**     | Dart 3.11+                     |
| **Database**     | SQLite (sqflite)               |
| **OCR**          | Google ML Kit Text Recognition |
| **AI**           | Google Generative AI (Gemini)  |
| **Camera/Image** | image_picker                   |
| **Lokalisasi**   | intl (Bahasa Indonesia)        |

## Dependencies Utama

```yaml
flutter: # Framework utama
sqflite: # Database lokal
image_picker: # Akses kamera & galeri
google_mlkit_text_recognition: # OCR
google_generative_ai: # Gemini AI
intl: # Internationalization
```

Lihat `pubspec.yaml` untuk daftar lengkap dependencies.

## Keamanan & Privasi

- Semua data disimpan **lokal** di perangkat
- **Tidak ada** pengiriman data ke server eksternal
- Privasi finansial Anda terjamin
- Kamera hanya digunakan saat scan receipt

## Laporan Bug & Fitur

Punya saran atau menemukan bug? [Buat issue](https://github.com/yourusername/duitkuu/issues) di repository ini.

## Kontribusi

Kontribusi sangat diterima! Silakan:

1. Fork repository
2. Buat branch fitur baru (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buka Pull Request

## Lisensi

Project ini dilisensikan di bawah lisensi MIT - lihat file [LICENSE](LICENSE) untuk detail.

## Penulis

**Duitkuu Development Team**

Dibuat untuk memudahkan pengelolaan keuangan pribadi Anda.

## Hubungi Kami

- Email: [your-email@example.com](mailto:your-email@example.com)
- GitHub: [@yourusername](https://github.com/yourusername)

---

**Disclaimer:** Aplikasi ini dirancang untuk tracking pengeluaran pribadi. Untuk kebutuhan bisnis, gunakan solusi accounting profesional.

<p align="center">
  Made using Flutter & Dart
</p>
