import 'package:flutter/material.dart';
import '../app_colors.dart';
import 'home_screen.dart';
import 'inventory_screen.dart';
import 'project_screen.dart';
import 'planner_screen.dart';
import 'stats_screen.dart';
import '../l10n/app_localizations.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final List<Widget> _screens = [
      HomeScreen(onNavigate: _onItemTapped), // 0
      const InventoryScreen(),                // 1
      const ProjectScreen(),                  // 2
      const PlannerScreen(),                  // 3
      const StatsScreen(),                    // 4
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          selectedFontSize: 10,
          unselectedFontSize: 9,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard),
              label: l10n.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.inventory_2_outlined),
              activeIcon: const Icon(Icons.inventory_2),
              label: l10n.inventory,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.auto_awesome_mosaic_outlined),
              activeIcon: const Icon(Icons.auto_awesome_mosaic),
              label: l10n.projects,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_today_outlined),
              activeIcon: const Icon(Icons.calendar_today),
              label: l10n.planner,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart_outlined),
              activeIcon: const Icon(Icons.bar_chart),
              label: l10n.stats,
            ),
          ],
        ),
      ),
    );
  }
}
