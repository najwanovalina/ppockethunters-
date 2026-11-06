import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/app_color.dart';
import '../widgets/custom_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});


  static const List<Color> avatarColors = [
    AppTheme.pinkAccent,
    AppTheme.purplePastel,
    AppTheme.mintGreen,
    AppTheme.pinkSoft,
    AppTheme.yellowCream,
  ];

  void _showEditProfileDialog(
    BuildContext context,
    String uid,
    String currentName,
    int currentColorValue,
  ) {
    TextEditingController nameC = TextEditingController(text: currentName);
    int selectedColorValue = currentColorValue;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppTheme.bgCream,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text(
                "Edit Profil 🌸",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
            
                    CuteAvatar(
                      size: 70,
                      avatarColor: Color(selectedColorValue),
                    ),
                    const SizedBox(height: 16),

                
                    TextField(
                      controller: nameC,
                      decoration: InputDecoration(
                        labelText: "Nama Profil",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

      
                    const Text(
                      "Pilih Warna Avatar 🎨",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: avatarColors.map((color) {
                        bool isSelected = selectedColorValue == color.toARGB32();
                        return GestureDetector(
                          onTap: () {
                            setStateDialog(() {
                              selectedColorValue = color.toARGB32();
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: AppTheme.textDark, width: 2.5)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.pinkAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    if (nameC.text.trim().isNotEmpty) {
                      await FirebaseFirestore.instance.collection('users').doc(uid).set({
                        'name': nameC.text.trim(),
                        'avatarColor': selectedColorValue,
                      }, SetOptions(merge: true));

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Profil berhasil diperbarui! ✨"),
                            backgroundColor: AppTheme.pinkAccent,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text("Simpan ✨", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? '';

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text(
          "Profil & Statistik ",
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('transactions')
            .snapshots(),
        builder: (context, snapshot) {
          double totalPemasukan = 0;
          double totalPengeluaran = 0;

          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              var data = doc.data() as Map<String, dynamic>;
              double amount = (data['amount'] ?? 0).toDouble();
              if (data['type'] == 'Pemasukan') {
                totalPemasukan += amount;
              } else {
                totalPengeluaran += amount;
              }
            }
          }

          double totalTransaksi = totalPemasukan + totalPengeluaran;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
                builder: (context, userSnap) {
                  String name = 'Sahabat Imut';
                  int colorValue = AppTheme.pinkAccent.toARGB32();

                  if (userSnap.hasData && userSnap.data!.exists) {
                    var data = userSnap.data!.data() as Map<String, dynamic>?;
                    name = data?['name'] ?? 'Sahabat Imut';
                    colorValue = data?['avatarColor'] ?? AppTheme.pinkAccent.toARGB32();
                  }

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.pinkSoft.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        CuteAvatar(
                          size: 75,
                          avatarColor: Color(colorValue),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'email@pocketcute.com',
                          style: TextStyle(color: AppTheme.textDark.withValues(alpha: 0.6)),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.pinkAccent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            _showEditProfileDialog(context, uid, name, colorValue);
                          },
                          icon: const Icon(Icons.edit, size: 16, color: AppTheme.pinkAccent),
                          label: const Text(
                            "Edit Profil ✏️",
                            style: TextStyle(
                              color: AppTheme.pinkAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              const Text(
                "Grafik Keuangan Bulanan 📊",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                height: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.pinkSoft.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: totalTransaksi == 0
                    ? const Center(
                        child: Text(
                          "Belum ada data grafik 🐾",
                          style: TextStyle(color: AppTheme.textDark),
                        ),
                      )
                    : PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              color: AppTheme.mintGreen,
                              value: totalPemasukan == 0 ? 1 : totalPemasukan,
                              title: 'Pemasukan',
                              radius: 55,
                              titleStyle: const TextStyle(
                                fontSize: 7,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 37, 33, 33)                              ),
                            ),
                            PieChartSectionData(
                              color: AppTheme.pinkSoft,
                              value: totalPengeluaran == 0 ? 1 : totalPengeluaran,
                              title: 'Pengeluaran',
                              radius: 55,
                              titleStyle: const TextStyle(
                                fontSize: 7,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 28, 26, 26),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              const SizedBox(height: 24),
              const Text(
                "Ringkasan Catatan 📝",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.mintGreen.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Total Masuk 📥", style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 6),
                          Text(
                            "Rp ${totalPemasukan.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.pinkSoft.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Total Keluar 📤", style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 6),
                          Text(
                            "Rp ${totalPengeluaran.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}