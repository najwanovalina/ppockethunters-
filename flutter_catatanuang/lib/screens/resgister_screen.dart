import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/app_color.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_snackbar.dart';
import 'root_nav_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final kelasController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool hidePassword = true;

  // Proses bikin akun baru sekaligus nyimpen biodata user ke Firestore
  Future<void> registerUser() async {
    if (nameController.text.isEmpty ||
        kelasController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      CustomSnackBar.showError(context, "Semua form wajib diisi");
      return;
    }

    setState(() => isLoading = true);
    try {
      // 1. Daftarkan email & password ke Firebase Auth
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // 2. Ambil ID unik user, lalu simpan nama & kelasnya ke database Firestore
      final uid = credential.user!.uid;
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "user_id": uid,
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "kelas": kelasController.text.trim(),
        "created_at": DateTime.now().toIso8601String(),
        "foto": "https://ui-avatars.com/api/?name=${nameController.text.trim()}&background=3B82F6&color=fff",
      });

      if (!mounted) return;
      CustomSnackBar.showSuccess(context, "Berhasil mendaftar!");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RootNavScreen()));
    } catch (e) {
      CustomSnackBar.showError(context, "Gagal mendaftar: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: AppColor.primary)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        children: [
          const Center(
            child: Text("Sign up", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColor.primary)),
          ),
          const SizedBox(height: 24),
          CustomInput(controller: nameController, label: "Nama Lengkap", hint: "Masukkan nama lengkap"),
          CustomInput(controller: kelasController, label: "Kelas", hint: "Contoh: XI RPL 4"),
          CustomInput(
            controller: emailController,
            label: "Email Address",
            hint: "Masukkan email",
            keyboardType: TextInputType.emailAddress,
          ),
          CustomInput(
            controller: passwordController,
            label: "Password",
            hint: "Buat password",
            obscureText: hidePassword,
            suffixIcon: IconButton(
              icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility, color: AppColor.secondarySoft),
              onPressed: () => setState(() => hidePassword = !hidePassword),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: isLoading ? null : registerUser,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Sign up", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}