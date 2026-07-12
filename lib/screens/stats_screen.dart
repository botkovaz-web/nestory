import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_colors.dart';
import '../l10n/app_localizations.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.stats),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          double totalRevenue = 0;
          int completedOrders = 0;
          int pendingOrders = 0;

          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              double price = (data['price'] ?? 0).toDouble();
              String status = data['status'] ?? '';
              
              if (status == 'Odoslané' || status == 'Hotovo') {
                totalRevenue += price;
                completedOrders++;
              } else {
                pendingOrders++;
              }
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildStatCard(l10n.completedOrders, completedOrders.toString(), Icons.check_circle_outline, Colors.green),
                const SizedBox(height: 16),
                _buildStatCard(l10n.pendingOrders, pendingOrders.toString(), Icons.hourglass_empty, Colors.orange),
                const SizedBox(height: 16),
                _buildStatCard(l10n.totalRevenue, '${totalRevenue.toStringAsFixed(2)} €', Icons.euro, AppColors.accent),
                const SizedBox(height: 32),
                Image.asset('assets/icon_grow.png', height: 120),
                const SizedBox(height: 16),
                Text(l10n.statsComingSoon, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
