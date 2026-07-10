import 'package:flutter/material.dart';
import '../app_colors.dart';
import 'home_screen.dart';
import 'order_screen.dart';
import 'material_screen.dart';
import 'tools_screen.dart';
import 'project_screen.dart';
import 'planner_screen.dart';
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
      const MaterialScreen(),                 // 1
      const ToolsScreen(),                    // 2
      const ProjectScreen(),                  // 3
      const OrderScreen(),                    // 4
      const PlannerScreen(),                  // 5
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
              label: l10n.material,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.build_outlined),
              activeIcon: const Icon(Icons.build),
              label: l10n.tools,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.palette_outlined),
              activeIcon: const Icon(Icons.palette),
              label: l10n.projects,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_bag_outlined),
              activeIcon: const Icon(Icons.shopping_bag),
              label: l10n.orders,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_today_outlined),
              activeIcon: const Icon(Icons.calendar_today),
              label: l10n.planner,
            ),
          ],
        ),
      ),
    );
  }
}
