import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_catatanuang/widgets/custom_avatar.dart';
import 'package:flutter_catatanuang/widgets/custom_input.dart';
import '../utils/app_color.dart';
import 'resgister_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  bool isLoading = false;

  void login() async {
    if (emailC.text.isEmpty || passC.text.isEmpty) return;
    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailC.text.trim(),
        password: passC.text,
      );
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 30),
            Center(child: CuteAvatar(size: 90, avatarColor: Colors.pink)),
            const SizedBox(height: 16),
            const Text(
              "Halo Lagi! ✨",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 30),
            CustomInput(controller: emailC, label: "Email", hint: "masukkan email lucu-mu"),
            CustomInput(controller: passC, label: "Password", hint: "******", obscureText: true),
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : login,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Masuk Sekarang"),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Belum punya akun?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                  },
                  child: const Text("Daftar disini 💕"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}