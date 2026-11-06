import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_input.dart';

class EditTransactionScreen extends StatefulWidget {
  final Map<String, dynamic> transactionData;

  const EditTransactionScreen({super.key, required this.transactionData});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TextEditingController titleC;
  late TextEditingController amountC;
  late String selectedType;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleC = TextEditingController(text: widget.transactionData['title']);
    amountC = TextEditingController(text: widget.transactionData['amount'].toString());
    selectedType = widget.transactionData['type'] ?? 'Pengeluaran';
  }

  Future<void> updateTransaction() async {
    if (titleC.text.isEmpty || amountC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Form wajib diisi")),
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("transactions")
          .doc(widget.transactionData['transaction_id'])
          .update({
        "title": titleC.text,
        "amount": int.parse(amountC.text),
        "type": selectedType,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transaksi berhasil diperbarui")),
      );
      Navigator.pop(context); 
      Navigator.pop(context); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    titleC.dispose();
    amountC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Transaksi"), backgroundColor: Theme.of(context).scaffoldBackgroundColor, elevation: 0),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(20),
          children: [
          CustomInput(controller: titleC, label: "Judul Transaksi", hint: "Edit Judul"),
          CustomInput(controller: amountC, label: "Nominal (Rp)", hint: "Edit Nominal", keyboardType: TextInputType.number),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: selectedType,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
            items: ['Pemasukan', 'Pengeluaran']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) => setState(() => selectedType = val!),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: isLoading ? null : updateTransaction,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
          ],
        ),
      ),
    );
  }
}