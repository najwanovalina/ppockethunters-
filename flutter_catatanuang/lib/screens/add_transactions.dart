import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_catatanuang/widgets/custom_input.dart';
import '../utils/app_color.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final titleC = TextEditingController();
  final amountC = TextEditingController();
  String selectedType = 'Pengeluaran';
  bool isLoading = false;

  void saveTransaction() async {
    if (titleC.text.isEmpty || amountC.text.isEmpty) return;
    setState(() => isLoading = true);

    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .add({
            'title': titleC.text,
            'amount': double.tryParse(amountC.text) ?? 0,
            'type': selectedType,
            'created_at': DateTime.now().toIso8601String(),
          });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Catatan Keuangan")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CustomInput(
            controller: titleC,
            label: "Judul Transaksi",
            hint: "Beli Jajanan Ice Cream",
          ),
          CustomInput(
            controller: amountC,
            label: "Nominal (Rp)",
            hint: "15000",
            keyboardType: TextInputType.number,
          ),
          const Text(
            "Tipe Transaksi",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['Pengeluaran', 'Pemasukan'].map((type) {
              bool selected = selectedType == type;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedType = type),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.pinkAccent : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.pinkSoft),
                    ),
                    child: Center(
                      child: Text(
                        type,
                        style: TextStyle(
                          color: selected ? Colors.white : AppTheme.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : saveTransaction,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Simpan Catatan"),
            ),
          ),
        ],
      ),
    );
  }
}
