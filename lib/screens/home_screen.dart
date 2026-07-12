import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_colors.dart';
import '../l10n/app_localizations.dart';
import '../services/database_service.dart';
import '../models/project_model.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  String _getRandomNestiMessage(BuildContext context, String name, int taskCount) {
    final l10n = AppLocalizations.of(context)!;
    final List<String> messages = [
      l10n.nestiMessage1(name),
      l10n.nestiMessage2,
      l10n.nestiMessage3,
      l10n.nestiMessage4,
      l10n.nestiMessage5,
      l10n.nestiMessage6,
    ];

    if (taskCount > 0) {
      messages.add(l10n.nestiOrdersMessage(taskCount));
    } else {
      messages.add(l10n.nestiNoOrdersMessage);
    }

    return messages[Random().nextInt(messages.length)];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dbService = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () => onNavigate(6), // Naviguje na SettingsScreen
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: dbService.userData,
        builder: (context, userSnapshot) {
          String name = l10n.creator;
          if (userSnapshot.hasData && userSnapshot.data!.exists) {
            name = (userSnapshot.data!.data() as Map<String, dynamic>)['name'] ?? l10n.creator;
          }

          return StreamBuilder<List<ProjectModel>>(
            stream: dbService.activeProjects,
            builder: (context, projectsSnapshot) {
              int activeTasks = projectsSnapshot.hasData ? projectsSnapshot.data!.length : 0;
              String nestiMessage = _getRandomNestiMessage(context, name, activeTasks);

              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${l10n.welcome}, $name!',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.15),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(15),
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                    topLeft: Radius.circular(0),
                                  ),
                                ),
                                child: Text(
                                  nestiMessage,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.green.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Image.asset('assets/nesti_happy.png', height: 80),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(child: _buildDashboardCard(
                                  context,
                                  l10n.inventory,
                                  'assets/nesti_organizing.png',
                                  () => onNavigate(1), 
                                )),
                                const SizedBox(width: 16),
                                Expanded(child: _buildDashboardCard(
                                  context,
                                  l10n.projects,
                                  'assets/nesti_in_basket.png',
                                  () => onNavigate(2), 
                                )),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(child: _buildDashboardCard(
                                  context,
                                  l10n.guides,
                                  'assets/icon_manage.png',
                                  () => onNavigate(4), 
                                )),
                                const SizedBox(width: 16),
                                Expanded(child: _buildDashboardCard(
                                  context,
                                  l10n.planner,
                                  'assets/nesti_planning.png',
                                  () => onNavigate(3),
                                )),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(child: _buildDashboardCard(
                                  context,
                                  l10n.stats,
                                  'assets/icon_grow.png',
                                  () => onNavigate(5),
                                )),
                                const SizedBox(width: 16),
                                Expanded(child: _buildDashboardCard(
                                  context,
                                  l10n.settings,
                                  'assets/nesti_relax.png', 
                                  () => onNavigate(6),
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(child: Image.asset(assetPath, height: 60)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
