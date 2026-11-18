import 'package:flutter/material.dart';
import '../utils/app_color.dart';

// Kotak pop-up tanya "Yakin?" sebelum user hapus data atau keluar akun
class CustomDialog {
  static void showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm, // Aksi yang dijalankan kalau user pencet "Ya"
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(color: AppColor.secondarySoft)),
        actions: [
          // Tombol Batal cuma nutup pop-up
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: AppColor.secondarySoft)),
          ),
          // Tombol Ya nutup pop-up dulu, baru jalanin perintah utamanya
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text("Ya", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}