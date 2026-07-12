import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../l10n/app_localizations.dart';
import '../services/database_service.dart';
import '../models/project_model.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dbService = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.stats),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<ProjectModel>>(
        stream: dbService.projects,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          double totalRevenue = 0;
          int completedOrders = 0;
          int pendingOrders = 0;

          if (snapshot.hasData) {
            for (var project in snapshot.data!) {
              if (project.isForCustomer) {
                if (project.status == 'Hotovo') {
                  totalRevenue += project.price;
                  completedOrders++;
                } else {
                  pendingOrders++;
                }
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
        color: Colors.white.withAlpha(180),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(75)),
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
