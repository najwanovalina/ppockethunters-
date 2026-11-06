import 'package:flutter/material.dart';
import 'package:flutter_catatanuang/utils/app_color.dart';

class CustomDialog {
  static void showCuteConfirm({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppTheme.bgCream,
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textDark),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.pinkAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text("Ya, Yakin!"),
          ),
        ],
      ),
    );
  }
}