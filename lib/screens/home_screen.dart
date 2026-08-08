import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../app_colors.dart';
import '../l10n/app_localizations.dart';
import '../services/database_service.dart';
import '../models/project_model.dart';
import '../models/material_model.dart';
import '../widgets/premium_paywall.dart';
import '../widgets/app_bar_actions.dart';

class HomeScreen extends StatelessWidget {
  final Function(int, {int subTab}) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  String _getRandomNestiMessage(BuildContext context, String name) {
    final l10n = AppLocalizations.of(context)!;
    final List<String> messages = [
      l10n.nestiMessage1(name),
      l10n.nestiMessage2,
      l10n.nestiMessage3,
      l10n.nestiMessage4,
      l10n.nestiMessage5,
      l10n.nestiMessage6,
    ];
    return messages[Random().nextInt(messages.length)];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dbService = DatabaseService();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          NestoryAppBarActions(onNavigate: onNavigate),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: dbService.userData,
        builder: (context, userSnapshot) {
          String name = l10n.creator;
          bool isPremium = false;
          if (userSnapshot.hasData && userSnapshot.data!.exists) {
            final data = userSnapshot.data!.data() as Map<String, dynamic>;
            name = data['name'] ?? l10n.creator;
            isPremium = data['isPremium'] ?? false;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- SEKCIA NESTI (VRCH) ---
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${l10n.welcome}, $name!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withAlpha(40),
                              borderRadius: const BorderRadius.only(topRight: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                            ),
                            child: Text(
                              _getRandomNestiMessage(context, name), 
                              style: TextStyle(
                                fontSize: 13, 
                                fontStyle: FontStyle.italic, 
                                color: isDark ? theme.colorScheme.onSurface : Colors.green.shade900
                              )
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Image.asset('assets/nesti_happy.png', height: 70),
                  ],
                ),
                
                const SizedBox(height: 32),

                // --- RÝCHLY PREHĽAD (STATUS BAR) ---
                StreamBuilder<List<ProjectModel>>(
                  stream: dbService.activeProjects,
                  builder: (context, projSnap) {
                    return StreamBuilder<List<MaterialModel>>(
                      stream: dbService.materials,
                      builder: (context, matSnap) {
                        int activeProjects = projSnap.data?.length ?? 0;
                        int materialsCount = matSnap.data?.length ?? 0;

                        return Row(
                          children: [
                            _buildMiniSummary(context, l10n.inProgress, activeProjects.toString(), Icons.play_circle_outline, Colors.orange),
                            const SizedBox(width: 12),
                            _buildMiniSummary(context, l10n.itemsInStock, materialsCount.toString(), Icons.inventory_2_outlined, AppColors.accent),
                          ],
                        );
                      }
                    );
                  }
                ),

                const SizedBox(height: 32),

                // --- NAJBLIŽŠÍ TERMÍN ---
                Text(l10n.upcomingDeadline, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                StreamBuilder<List<ProjectModel>>(
                  stream: dbService.projects,
                  builder: (context, snapshot) {
                    final projectsWithDeadlines = (snapshot.data ?? [])
                        .where((p) => p.deadline != null && p.status != 'Hotovo')
                        .toList();
                    
                    if (projectsWithDeadlines.isEmpty) {
                      return _buildEmptySection(l10n.noDeadlines, Icons. calendar_today_outlined);
                    }

                    // Zoradíme podľa dátumu
                    projectsWithDeadlines.sort((a, b) => a.deadline!.compareTo(b.deadline!));
                    final nextProject = projectsWithDeadlines.first;
                    final daysLeft = nextProject.deadline!.difference(DateTime.now()).inDays;

                    return _buildActionCard(
                      context,
                      title: nextProject.name,
                      subtitle: '${DateFormat('dd.MM.yyyy').format(nextProject.deadline!)} (${daysLeft < 0 ? l10n.overdue : l10n.daysLeft(daysLeft)})',
                      icon: Icons.timer_outlined,
                      color: daysLeft < 3 ? Colors.redAccent : Colors.blueAccent,
                      onTap: () => onNavigate(2),
                    );
                  }
                ),

                const SizedBox(height: 32),

                // --- RÝCHLE AKCIE ---
                Text(l10n.quickActions, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildQuickAction(context, l10n.addMaterial, Icons.add_circle_outline, () => onNavigate(1, subTab: 0)),
                    const SizedBox(width: 12),
                    _buildQuickAction(context, l10n.addProject, Icons.note_add_outlined, () => onNavigate(2, subTab: 0)),
                  ],
                ),

                const SizedBox(height: 40),
                Center(child: Image.asset('assets/nesti_watching.png', height: 80, opacity: const AlwaysStoppedAnimation(0.5))),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniSummary(BuildContext context, String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(isDark ? 30 : 5), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withAlpha(30), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary.withAlpha(30),
          foregroundColor: theme.colorScheme.primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  Widget _buildEmptySection(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withAlpha(50)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey.withAlpha(100), size: 20),
          const SizedBox(width: 10),
          Text(message, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}
