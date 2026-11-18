import 'package:flutter/material.dart';

class AppColor {
  // Kumpulan warna utama aplikasi biar seragam di semua halaman
  static const Color primary = Color(0xFF3B82F6); // Biru cerah buat tombol & menu bawah
  static const Color primarySoft = Color(0xFF2167E6); // Biru agak tua buat gradasi
  static const Color primaryExtraSoft = Color(0xFFEBF3FF); // Biru muda lembut buat latar kartu
  static const Color secondary = Color(0xFF1B1F24); // Hitam keabuan buat judul teks
  static const Color secondarySoft = Color(0xFF8E9BAE); // Abu-abu buat teks keterangan
  static const Color secondaryExtraSoft = Color(0xFFDCE6F7); // Garis tepi kotak yang tipis
  static const Color success = Color(0xFF16AE26); // Hijau buat status Available
  static const Color error = Color(0xFFD00E0E); // Merah buat tombol hapus & pesan gagal
  static const Color warning = Color(0xFFEB8600); // Oranye buat status Borrowed

  // Gradasi biru dari atas ke bawah khusus buat layar pembuka (Splash Screen)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}