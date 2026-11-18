import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/app_color.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_snackbar.dart';
import 'root_nav_screen.dart';
import 'resgister_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool hidePassword = true;
  String selectedRole = 'peminjam';

  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      CustomSnackBar.showError(context, 'Email dan password wajib diisi');
      return;
    }

    setState(() => isLoading = true);

    try {
      if (selectedRole == 'admin') {
        if (email != 'admin@gmail.com' || password != 'admin123') {
          CustomSnackBar.showError(context, 'Email atau password Admin salah!');
          return;
        }

        UserCredential credential;
        try {
          credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
            credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );
          } else {
            rethrow;
          }
        }

        final uid = credential.user!.uid;
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'user_id': uid,
          'name': 'Admin Lab',
          'email': email,
          'kelas': 'Admin',
          'role': 'admin',
          'foto': 'https://ui-avatars.com/api/?name=Admin+Lab&background=3B82F6&color=fff',
        }, SetOptions(merge: true));

        if (!mounted) return;
        CustomSnackBar.showSuccess(context, 'Berhasil masuk sebagai ADMIN!');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const RootNavScreen()),
          (_) => false,
        );
        return;
      }

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        final userRole = (userDoc.data()?['role'] ?? 'peminjam')
            .toString()
            .trim()
            .toLowerCase();

        if (userRole == 'admin') {
          await FirebaseAuth.instance.signOut();
          if (!mounted) return;
          CustomSnackBar.showError(
            context,
            'Akun ini adalah Admin, silakan pilih section Admin!',
          );
          return;
        }
      }

      if (!mounted) return;
      CustomSnackBar.showSuccess(context, 'Berhasil masuk sebagai PEMINJAM!');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const RootNavScreen()),
        (_) => false,
      );
    } catch (_) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Email atau kata sandi salah');
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _roleOption({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final isSelected = selectedRole == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedRole = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColor.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColor.primary
                  : AppColor.secondaryExtraSoft,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColor.secondarySoft,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isSelected ? Colors.white : AppColor.secondarySoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: AppColor.primaryExtraSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.biotech_rounded,
                size: 80,
                color: AppColor.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Log in',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Masuk Sebagai',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColor.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _roleOption(
                  value: 'peminjam',
                  label: 'Peminjam',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(width: 12),
                _roleOption(
                  value: 'admin',
                  label: 'Admin',
                  icon: Icons.admin_panel_settings_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomInput(
              controller: emailController,
              label: 'Email Address',
              hint: 'Masukkan email',
              keyboardType: TextInputType.emailAddress,
            ),
            CustomInput(
              controller: passwordController,
              label: 'Password',
              hint: 'Masukkan password',
              obscureText: hidePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  hidePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColor.secondarySoft,
                ),
                onPressed: () => setState(() => hidePassword = !hidePassword),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isLoading ? null : loginUser,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Belum punya akun? ',
                  style: TextStyle(color: AppColor.secondarySoft, fontSize: 13),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                      color: AppColor.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}