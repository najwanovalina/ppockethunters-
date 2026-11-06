import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_catatanuang/widgets/custom_avatar.dart';
import '../utils/app_color.dart';
import 'home_screen.dart';
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
    _checkAuth();
  }

  void _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    User? user = FirebaseAuth.instance.currentUser;
    if (mounted) {
      if (user != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CuteAvatar(size: 100, avatarColor: AppTheme.pinkAccent),
            SizedBox(height: 20),
            Text(
              "PocketHunters! 🌸",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.pinkAccent),
            ),
            Text("Catatan Keuanganku", style: TextStyle(color: AppTheme.textDark)),
          ],
        ),
      ),
    );
  }
}