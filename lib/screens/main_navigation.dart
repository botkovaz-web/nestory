import 'package:flutter/material.dart';
import '../app_colors.dart';
import 'home_screen.dart';
import 'order_screen.dart';
import 'material_screen.dart';
import 'tools_screen.dart';
import 'project_screen.dart';

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
    final List<Widget> _screens = [
      HomeScreen(onNavigate: _onItemTapped), // 0
      const MaterialScreen(),                 // 1
      const ToolsScreen(),                    // 2
      const ProjectScreen(),                  // 3
      const OrderScreen(),                    // 4
      const Center(child: Text('Štatistiky (Pripravujeme)')), // 5 (Placeholder)
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Domov',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Materiál',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.build_outlined),
              activeIcon: Icon(Icons.build),
              label: 'Pomôcky',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.palette_outlined),
              activeIcon: Icon(Icons.palette),
              label: 'Projekty',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag),
              label: 'Objednávky',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Štatistiky',
            ),
          ],
        ),
      ),
    );
  }
}
