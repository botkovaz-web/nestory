import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_colors.dart';
import '../l10n/app_localizations.dart';
import '../services/stats_service.dart';
import '../models/event_model.dart';
import '../widgets/app_bar_actions.dart';

class StatsScreen extends StatelessWidget {
  final Function(int, {int subTab}) onNavigate;
  const StatsScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statsService = StatsService();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.stats),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          NestoryAppBarActions(onNavigate: onNavigate),
        ],
      ),
      body: StreamBuilder<StatsData>(
        stream: statsService.statsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData) {
            return const Center(child: Text('Žiadne dáta k dispozícii.'));
          }

          final stats = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HLAVNÝ SÚHRN
                _buildSummaryCard(l10n, stats.totalIncome, stats.totalExpenses, stats.netProfit),
                const SizedBox(height: 24),
                
                // ROZPIS PRÍJMOV
                Text('Zdroje príjmov', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildSmallStatCard(l10n.revenueOrders, stats.projectRevenue, Icons.shopping_bag_outlined, Colors.blue)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSmallStatCard(l10n.revenueEvents, stats.eventSales, Icons.festival_outlined, Colors.orange)),
                  ],
                ),
                
                const SizedBox(height: 32),
                Text(l10n.eventHistory, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                if (stats.pastEvents.isEmpty)
                  Text(l10n.noEvents, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                
                ...stats.pastEvents.map((event) => _buildEventExpansionCard(context, event)),
                
                const SizedBox(height: 32),
                Center(child: Image.asset('assets/nesty_stats.png', height: 100)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(AppLocalizations l10n, double income, double expenses, double profit) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent, AppColors.accent.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: AppColors.accent.withAlpha(50), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Text(l10n.netProfit.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Text('${profit.toStringAsFixed(2)} €', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(l10n.totalIncome, income),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildSummaryItem(l10n.totalExpenses, expenses),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 4),
        Text('${value.toStringAsFixed(2)} €', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSmallStatCard(String title, double value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(180),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text('${value.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEventExpansionCard(BuildContext context, EventModel event) {
    final l10n = AppLocalizations.of(context)!;
    double profit = event.sales - event.expenses;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(180),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: const Icon(Icons.festival, color: Colors.orange),
        title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(DateFormat('dd.MM.yyyy').format(event.date), style: const TextStyle(fontSize: 12)),
        trailing: Text(
          '${profit >= 0 ? '+' : ''}${profit.toStringAsFixed(2)} €',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: profit >= 0 ? Colors.green : Colors.red,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                _buildDetailRow(l10n.revenue, '${event.sales.toStringAsFixed(2)} €'),
                _buildDetailRow(l10n.totalExpenses, '${event.expenses.toStringAsFixed(2)} €'),
                _buildDetailRow('Čistý zisk', '${profit.toStringAsFixed(2)} €', color: profit >= 0 ? Colors.green : Colors.red),
                if (event.location.isNotEmpty) _buildDetailRow(l10n.location, event.location),
                const SizedBox(height: 12),
                Text('${l10n.itemsSold}:', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                const SizedBox(height: 4),
                if (event.inventory.isEmpty)
                  Text(l10n.noInventory, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ...event.inventory.entries.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.key, style: const TextStyle(fontSize: 12)),
                      Text(
                        '${item.value['sold']} / ${item.value['taken']}',
                        style: TextStyle(
                          fontSize: 12, 
                          fontWeight: FontWeight.bold,
                          color: (item.value['sold'] ?? 0) > 0 ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}
