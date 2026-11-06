import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_catatanuang/utils/app_color.dart';
import '../widgets/custom_dialog.dart';

class DetailTransactionScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> transactionData;

  const DetailTransactionScreen({
    super.key,
    required this.docId,
    required this.transactionData,
  });

  @override
  State<DetailTransactionScreen> createState() => _DetailTransactionScreenState();
}

class _DetailTransactionScreenState extends State<DetailTransactionScreen> {
  late TextEditingController titleC;
  late TextEditingController amountC;
  late String selectedType;
  bool isEditing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleC = TextEditingController(text: widget.transactionData['title'] ?? '');
    amountC = TextEditingController(
      text: (widget.transactionData['amount'] ?? 0).toString(),
    );
    selectedType = widget.transactionData['type'] ?? 'Pengeluaran';
  }

  @override
  void dispose() {
    titleC.dispose();
    amountC.dispose();
    super.dispose();
  }


  Future<void> updateTransaction() async {
    if (titleC.text.trim().isEmpty || amountC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Judul dan Nominal tidak boleh kosong yap!"),
          backgroundColor: AppTheme.pinkAccent,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .doc(widget.docId)
          .update({
        'title': titleC.text.trim(),
        'amount': double.tryParse(amountC.text.trim()) ?? 0,
        'type': selectedType,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Catatan berhasil diperbarui! ✨"),
            backgroundColor: AppTheme.purplePastel,
          ),
        );
        setState(() => isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memperbarui: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> deleteTransaction() async {
    CustomDialog.showCuteConfirm(
      context: context,
      title: "Hapus Catatan? 🗑️",
      message: "Apakah kamu yakin ingin menghapus catatan transaksi ini?",
      onConfirm: () async {
        try {
          String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('transactions')
              .doc(widget.docId)
              .delete();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Catatan berhasil dihapus! 🗑️"),
                backgroundColor: AppTheme.pinkAccent,
              ),
            );
            Navigator.pop(context); 
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Gagal menghapus: $e")),
            );
          }
        }
      },
    );
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text(
          "Detail Catatan Keuangan",
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
        actions: [
          IconButton(
            icon: Icon(
              isEditing ? Icons.close : Icons.edit_rounded,
              color: AppTheme.pinkAccent,
            ),
            onPressed: () {
              setState(() => isEditing = !isEditing);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Judul Transaksi",
                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.pinkSoft, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1AFFB7B2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: TextField(
                  controller: titleC,
                  enabled: isEditing,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: "Masukkan judul...",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Nominal (Rp)",
                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.pinkSoft, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1AFFB7B2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: TextField(
                  controller: amountC,
                  enabled: isEditing,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "0",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Tipe Transaksi",
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 10),
          Row(
            children: ['Pengeluaran', 'Pemasukan'].map((type) {
              bool selected = selectedType == type;
              return Expanded(
                child: GestureDetector(
                  onTap: isEditing ? () => setState(() => selectedType = type) : null,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: selected
                          ? (type == 'Pemasukan' ? AppTheme.mintGreen : AppTheme.pinkSoft)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? Colors.transparent
                            : AppTheme.pinkAccent.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: (type == 'Pemasukan'
                                        ? AppTheme.mintGreen
                                        : AppTheme.pinkSoft)
                                    .withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        type == 'Pemasukan' ? "📥 Pemasukan" : "📤 Pengeluaran",
                        style: TextStyle(
                          color: AppTheme.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 36),
          
         
          if (isEditing)
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.pinkAccent,
                  shadowColor: AppTheme.pinkSoft,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                onPressed: isLoading ? null : updateTransaction,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Simpan Perubahan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            )
          else
            SizedBox(
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.pinkAccent, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                onPressed: deleteTransaction,
                child: const Text(
                  "Hapus Catatan 🗑️",
                  style: TextStyle(
                    color: AppTheme.pinkAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}