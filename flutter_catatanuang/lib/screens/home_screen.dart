import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';
import '../utils/app_color.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_avatar.dart';
import 'add_transactions.dart';
import 'detail_transaction.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
        
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
              builder: (context, snapshot) {
                String name = 'Sahabat Imut';
                if (snapshot.hasData && snapshot.data!.exists) {
                  var data = snapshot.data!.data() as Map<String, dynamic>?;
                  name = data?['name'] ?? 'Sahabat Imut';
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                  
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ProfileScreen()),
                            );
                          },
                          child: const CuteAvatar(size: 45, avatarColor: AppTheme.pinkSoft),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Selamat Datang, 🌸",
                              style: TextStyle(fontSize: 12, color: AppTheme.textDark),
                            ),
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded, color: AppTheme.pinkAccent),
                      onPressed: () {
                        CustomDialog.showCuteConfirm(
                          context: context,
                          title: "Logout? 🐾",
                          message: "Apakah kamu mau keluar dari aplikasi?",
                          onConfirm: () async {
                            await FirebaseAuth.instance.signOut();
                            if (context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

      
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('transactions')
                  .snapshots(),
              builder: (context, snapshot) {
                double total = 0;
                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    var data = doc.data() as Map<String, dynamic>;
                    double amount = (data['amount'] ?? 0).toDouble();
                    if (data['type'] == 'Pemasukan') {
                      total += amount;
                    } else {
                      total -= amount;
                    }
                  }
                }

                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.pinkAccent,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.pinkSoft.withValues(alpha: 0.6),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Sisa Saldo Kamu 💰",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Rp ${total.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
            const Text(
              "Riwayat Transaksi Real-time ",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: ['Semua', 'Pemasukan', 'Pengeluaran'].map((filter) {
                bool selected = selectedFilter == filter;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedFilter = filter),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.purplePastel : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? Colors.transparent
                              : AppTheme.pinkAccent.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: AppTheme.purplePastel.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          filter == 'Semua'
                              ? "✨ Semua"
                              : (filter == 'Pemasukan' ? "📥 Masuk" : "📤 Keluar"),
                          style: TextStyle(
                            fontSize: 12,
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

            const SizedBox(height: 16),

    
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('transactions')
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.pinkAccent),
                  );
                }

                var allDocs = snapshot.data?.docs ?? [];

      
                var docs = allDocs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  if (selectedFilter == 'Semua') return true;
                  return data['type'] == selectedFilter;
                }).toList();

                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Text(
                        "Belum ada catatan $selectedFilter 🐾",
                        style: const TextStyle(color: AppTheme.textDark),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    var doc = docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    bool isMasuk = data['type'] == 'Pemasukan';

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.pinkSoft.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isMasuk ? AppTheme.mintGreen : AppTheme.pinkSoft,
                          child: Text(isMasuk ? "📥" : "📤"),
                        ),
                        title: Text(
                          data['title'] ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        subtitle: Text(
                          data['type'] ?? '',
                          style: const TextStyle(color: AppTheme.textDark),
                        ),
                        trailing: Text(
                          "${isMasuk ? '+' : '-'} Rp ${data['amount']}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isMasuk ? AppTheme.mintGreen : AppTheme.pinkAccent,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailTransactionScreen(
                                docId: doc.id,
                                transactionData: data,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.pinkAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Catat 🌸",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}