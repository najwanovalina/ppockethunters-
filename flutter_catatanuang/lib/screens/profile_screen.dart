import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/app_color.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_snackbar.dart';
import 'login_screen.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  Future<void> _kembalikanBarang(
    BuildContext context,
    String uid,
    String borrowDocId,
    String itemId,
    String itemName,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("borrowings")
          .doc(borrowDocId)
          .delete();

      if (itemId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection("items")
            .doc(itemId)
            .update({"status": "Available"});
      }

      if (context.mounted) {
        CustomSnackBar.showSuccess(context, "$itemName berhasil dikembalikan!");
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.showError(context, "Gagal mengembalikan barang: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Silakan login kembali.")));
    }
    String uid = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil", style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.primary)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection("users").doc(uid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final rawData = snapshot.data?.data();
              final userData = rawData is Map<String, dynamic>
                  ? rawData
                  : <String, dynamic>{};
              final name = userData['name']?.toString() ?? 'Siswa';
              final kelas = userData['kelas']?.toString() ?? '-';
              final foto = userData['foto']?.toString() ?? 'https://ui-avatars.com/api/?name=$name&background=3B82F6&color=fff';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColor.secondaryExtraSoft),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColor.primaryExtraSoft,
                      backgroundImage: NetworkImage(foto),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColor.secondary),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColor.primaryExtraSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Kelas $kelas",
                              style: const TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),
          const Text("Lab Overview", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("users").doc(uid).collection("borrowings").snapshots(),
            builder: (context, snapshot) {
              int totalPinjam = snapshot.data?.docs.length ?? 0;
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColor.primaryExtraSoft, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total Peminjaman", style: TextStyle(color: AppColor.secondary, fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text("Riwayat transaksi lab aktif", style: TextStyle(color: AppColor.secondarySoft, fontSize: 12)),
                      ],
                    ),
                    Text(
                      "$totalPinjam Alat",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColor.primary),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),
          const Text("Riwayat Peminjaman", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(uid)
                .collection("borrowings")
                .orderBy("borrow_date", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Text("Belum ada riwayat peminjaman.", style: TextStyle(color: AppColor.secondarySoft));
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final rawData = docs[index].data();
                  final data = rawData is Map<String, dynamic>
                      ? rawData
                      : <String, dynamic>{};
                  final borrowDocId = docs[index].id;
                  final itemId = (data['item_id'] ?? '').toString();
                  final itemName = (data['item_name'] ?? 'Alat').toString();

                  return ListTile(
                    onTap: () => CustomDialog.showConfirmation(
                      context: context,
                      title: "Kembalikan Barang",
                      message: "Apakah Anda yakin ingin mengembalikan $itemName?",
                      onConfirm: () => _kembalikanBarang(context, uid, borrowDocId, itemId, itemName),
                    ),
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColor.secondaryExtraSoft),
                    ),
                    leading: const Icon(Icons.inventory_rounded, color: AppColor.primary),
                    title: Text(itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(
                      "Kode: ${data['code'] ?? '-'} • Tanggal: ${data['borrow_date']?.toString().split('T').first ?? '-'}",
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: const Icon(Icons.assignment_return_outlined, color: AppColor.primary, size: 20),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColor.secondaryExtraSoft),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => CustomDialog.showConfirmation(
                context: context,
                title: "Log out",
                message: "Apakah Anda yakin ingin keluar?",
                onConfirm: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
                },
              ),
              child: const Text("Log out", style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}