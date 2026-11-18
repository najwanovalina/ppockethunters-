import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../utils/app_color.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_snackbar.dart';

class InventarisScreen extends StatelessWidget {
  const InventarisScreen({super.key});

  void _showFormModal(BuildContext context, {Map<String, dynamic>? oldData}) {
    final isEdit = oldData != null;
    final nameC = TextEditingController(text: oldData?['item_name'] ?? '');
    final catC = TextEditingController(text: oldData?['category'] ?? 'Elektronika');
    final codeC = TextEditingController(text: oldData?['code'] ?? '');
    final specC = TextEditingController(text: oldData?['spesification'] ?? '');
    final imgC = TextEditingController(
      text: oldData?['image'] ?? 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=600',
    );
    String status = (oldData?['status'] ?? 'Available').toString().trim();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? "Edit Inventaris" : "Tambah Inventaris",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColor.primary),
                ),
                const SizedBox(height: 16),
                CustomInput(controller: nameC, label: "Nama Item", hint: "Contoh: Router Mikrotik"),
                CustomInput(controller: catC, label: "Kategori", hint: "Elektronika / Jaringan / Komputer / Sensor"),
                CustomInput(controller: codeC, label: "Kode Serial", hint: "Contoh: LAB-NET-01"),
                CustomInput(controller: specC, label: "Spesifikasi", hint: "Contoh: 5 Port Gigabit"),
                CustomInput(controller: imgC, label: "URL Gambar", hint: "https://..."),
                DropdownButtonFormField<String>(
                  value: status.toLowerCase() == 'borrowed' ? 'Borrowed' : 'Available',
                  decoration: InputDecoration(
                    labelText: "Status",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ["Available", "Borrowed"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setModalState(() => status = val!),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (nameC.text.trim().isEmpty || codeC.text.trim().isEmpty) {
                        CustomSnackBar.showError(context, "Nama item dan kode serial wajib diisi");
                        return;
                      }

                      try {
                        final String itemId = isEdit
                            ? (oldData['item_id']?.toString() ?? const Uuid().v1())
                            : const Uuid().v1();

                        await FirebaseFirestore.instance.collection("items").doc(itemId).set({
                          "item_id": itemId,
                          "item_name": nameC.text.trim(),
                          "category": catC.text.trim().isEmpty ? "Elektronika" : catC.text.trim(),
                          "code": codeC.text.trim(),
                          "status": status,
                          "image": imgC.text.trim(),
                          "spesification": specC.text.trim(),
                          "created_at": isEdit
                              ? (oldData['created_at'] ?? DateTime.now().toIso8601String())
                              : DateTime.now().toIso8601String(),
                        });

                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          CustomSnackBar.showSuccess(
                            context,
                            isEdit ? "Data berhasil diperbarui" : "Data berhasil ditambahkan",
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          CustomSnackBar.showError(context, "Gagal menyimpan: $e");
                        }
                      }
                    },
                    child: Text(
                      isEdit ? "Simpan Perubahan" : "Simpan Data",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventaris", style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.primary)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.primary,
        onPressed: () => _showFormModal(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("items").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text("Belum ada data inventaris"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = Map<String, dynamic>.from(docs[index].data() as Map<dynamic, dynamic>);
              final itemId = docs[index].id;
              final status = (item['status'] ?? 'Available').toString().trim();
              final isAvailable = status.toLowerCase() != 'borrowed';

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (routeContext) => DetailInventarisScreen(itemId: itemId),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColor.secondaryExtraSoft),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          item['image']?.toString() ?? '',
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 64,
                            height: 64,
                            color: AppColor.primaryExtraSoft,
                            child: const Icon(Icons.biotech, color: AppColor.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['item_name']?.toString() ?? '-',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColor.secondary),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: (isAvailable ? AppColor.success : AppColor.warning).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isAvailable ? AppColor.success : AppColor.warning,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColor.primary, size: 22),
                        onPressed: () => _showFormModal(
                          context,
                          oldData: {
                            ...item,
                            'item_id': itemId,
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColor.error, size: 22),
                        onPressed: () => CustomDialog.showConfirmation(
                          context: context,
                          title: "Hapus Data",
                          message: "Yakin ingin menghapus ${item['item_name']}?",
                          onConfirm: () async {
                            await FirebaseFirestore.instance.collection("items").doc(itemId).delete();
                            if (context.mounted) CustomSnackBar.showSuccess(context, "Data berhasil dihapus");
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DetailInventarisScreen extends StatelessWidget {
  final String itemId;

  const DetailInventarisScreen({
    super.key,
    required this.itemId,
  });

  Future<void> _ajukanPinjam(BuildContext context, Map<String, dynamic> item) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final borrowId = const Uuid().v1();

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("borrowings")
          .doc(borrowId)
          .set({
        "borrowId": borrowId,
        "item_id": itemId,
        "item_name": item['item_name'] ?? '-',
        "code": item['code'] ?? '-',
        "image": item['image'] ?? '',
        "borrow_date": DateTime.now().toIso8601String(),
      });

      await FirebaseFirestore.instance
          .collection("items")
          .doc(itemId)
          .update({"status": "Borrowed"});

      if (context.mounted) {
        CustomSnackBar.showSuccess(context, "Pengajuan peminjaman berhasil!");
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.showError(context, "Gagal meminjam: $e");
      }
    }
  }

  Future<void> _kembalikanBarang(BuildContext context, String itemName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final borrowQuery = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("borrowings")
          .where("item_id", isEqualTo: itemId)
          .get();

      for (final doc in borrowQuery.docs) {
        await doc.reference.delete();
      }

      await FirebaseFirestore.instance
          .collection("items")
          .doc(itemId)
          .update({"status": "Available"});

      if (context.mounted) {
        CustomSnackBar.showSuccess(context, "$itemName berhasil dikembalikan!");
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.showError(context, "Gagal mengembalikan: $e");
      }
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColor.secondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColor.secondary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Inventaris',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.primary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColor.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('items').doc(itemId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Data inventaris tidak ditemukan'));
          }

          final item = snapshot.data!.data() as Map<String, dynamic>;
          final imageUrl = item['image']?.toString() ?? '';
          final itemName = item['item_name']?.toString() ?? 'Alat';
          final status = (item['status'] ?? 'Available').toString().trim();
          final isAvailable = status.toLowerCase() != 'borrowed';

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 220,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColor.primaryExtraSoft,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.image_not_supported, color: AppColor.primary, size: 40),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              itemName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColor.secondary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (isAvailable ? AppColor.success : AppColor.warning).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isAvailable ? AppColor.success : AppColor.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _infoRow('Kategori', item['category']?.toString() ?? '-'),
                      _infoRow('Kode Serial', item['code']?.toString() ?? '-'),
                      _infoRow('Status', status),
                      _infoRow('Spesifikasi', item['spesification']?.toString() ?? '-'),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColor.secondaryExtraSoft)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAvailable ? AppColor.primary : AppColor.warning,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => CustomDialog.showConfirmation(
                      context: context,
                      title: isAvailable ? "Ajukan Peminjaman" : "Kembalikan Barang",
                      message: isAvailable
                          ? "Yakin ingin meminjam $itemName?"
                          : "Apakah Anda yakin ingin mengembalikan $itemName?",
                      onConfirm: () => isAvailable
                          ? _ajukanPinjam(context, item)
                          : _kembalikanBarang(context, itemName),
                    ),
                    icon: Icon(
                      isAvailable ? Icons.handshake_outlined : Icons.assignment_return_outlined,
                      color: Colors.white,
                    ),
                    label: Text(
                      isAvailable ? "Ajukan Peminjaman" : "Kembalikan Barang",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}