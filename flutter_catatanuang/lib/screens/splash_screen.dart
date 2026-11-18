import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_color.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Tunggu 3 detik pas layar pembuka tampil
    Timer(const Duration(seconds: 3), () {
      if (!context.mounted) return; // Hindari memakai context setelah layar ditutup

      // Arahkan ke login karena MainNavigationScreen tidak tersedia.
      const destination = LoginScreen();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => destination),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColor.primaryGradient), // Latar gradasi biru
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center, // Taruh logo & judul tepat di tengah layar
          children: [
            Icon(Icons.science_outlined, size: 90, color: Colors.white),
            SizedBox(height: 16),
            Text("LabSync", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 4),
            Text("ALL IN ONE LAB INVENTORY", style: TextStyle(fontSize: 11, color: Colors.white70, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }
}