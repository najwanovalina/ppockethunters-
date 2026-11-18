import 'package:flutter/material.dart';
import '../utils/app_color.dart';

// Cetakan kotak input teks biar nggak perlu bikin desain TextField berulang-ulang
class CustomInput extends StatelessWidget {
  final TextEditingController controller; // Buat nampung teks yang diketik user
  final String label; // Judul kecil di atas kotak input
  final String hint; // Teks contoh tipis di dalam kotak
  final bool obscureText; // Kalau true, teks jadi titik-titik (buat password)
  final Widget? suffixIcon; // Ikon tambahan di ujung kanan (misal ikon mata)
  final TextInputType keyboardType; // Jenis keyboard HP (teks biasa atau email)

  const CustomInput({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14), // Kasih jarak ke kotak input di bawahnya
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Bikin label rata kiri
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColor.secondary),
          ),
          const SizedBox(height: 6), // Jarak antara label dan kotak ketik
          TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 13, color: AppColor.secondarySoft),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              // Bentuk kotak saat belum diklik
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColor.secondaryExtraSoft, width: 1.2),
              ),
              // Bentuk kotak saat lagi diklik/diketik (garisnya jadi biru)
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColor.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}