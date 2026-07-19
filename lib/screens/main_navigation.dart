import 'package:flutter/material.dart';
import '../app_colors.dart';
import 'home_screen.dart';
import 'inventory_screen.dart';
import 'projects_hub_screen.dart';
import 'planner_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';
import '../l10n/app_localizations.dart';
import '../services/database_service.dart';
import '../widgets/premium_paywall.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  int _inventoryInitialTab = 0;
  int _projectsInitialTab = 0;
  final _dbService = DatabaseService();

  void _onNavigate(int index, {int subTab = 0}) async {
    if (index == 3 || index == 4) {
      final isPremium = await _dbService.isPremium.first;
      if (!isPremium) {
        if (mounted) showPremiumPaywall(context);
        return;
      }
    }

    setState(() {
      _selectedIndex = index;
      if (index == 1) _inventoryInitialTab = subTab;
      if (index == 2) _projectsInitialTab = subTab;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final List<Widget> _screens = [
      HomeScreen(onNavigate: _onNavigate), 
      InventoryScreen(key: ValueKey('inv_$_inventoryInitialTab'), initialTabIndex: _inventoryInitialTab, onNavigate: _onNavigate), 
      ProjectsHubScreen(key: ValueKey('proj_$_projectsInitialTab'), initialTabIndex: _projectsInitialTab, onNavigate: _onNavigate), 
      PlannerScreen(onNavigate: _onNavigate), 
      StatsScreen(onNavigate: _onNavigate),   
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex > 4 ? 0 : _selectedIndex,
          onTap: (index) => _onNavigate(index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.dashboard_outlined), activeIcon: const Icon(Icons.dashboard), label: l10n.home),
            BottomNavigationBarItem(icon: const Icon(Icons.inventory_2_outlined), activeIcon: const Icon(Icons.inventory_2), label: l10n.inventory),
            BottomNavigationBarItem(icon: const Icon(Icons.palette_outlined), activeIcon: const Icon(Icons.palette), label: l10n.projects),
            BottomNavigationBarItem(icon: const Icon(Icons.calendar_today_outlined), activeIcon: const Icon(Icons.calendar_today), label: l10n.planner),
            BottomNavigationBarItem(icon: const Icon(Icons.bar_chart_outlined), activeIcon: const Icon(Icons.bar_chart), label: l10n.stats),
          ],
        ),
      ),
    );
  }
}
