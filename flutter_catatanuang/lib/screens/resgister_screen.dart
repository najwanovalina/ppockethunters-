import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_catatanuang/widgets/custom_input.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  bool isLoading = false;

  void register() async {
    if (nameC.text.isEmpty || emailC.text.isEmpty || passC.text.isEmpty) return;
    setState(() => isLoading = true);
    try {
      UserCredential res = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailC.text.trim(),
        password: passC.text,
      );

      await FirebaseFirestore.instance.collection('users').doc(res.user!.uid).set({
        'name': nameC.text,
        'email': emailC.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buat Akun Imut"), backgroundColor: Colors.transparent, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          CustomInput(controller: nameC, label: "Nama Panggilan", hint: "Contoh: Petal"),
          CustomInput(controller: emailC, label: "Email", hint: "email@gmail.com"),
          CustomInput(controller: passC, label: "Password", hint: "******", obscureText: true),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : register,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Daftar Sekarang !🌸"),
            ),
          ),
        ],
      ),
    );
  }
}