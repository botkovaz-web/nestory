import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../l10n/app_localizations.dart';
import 'material_screen.dart';
import 'tools_screen.dart';

class InventoryScreen extends StatelessWidget {
  final int initialTabIndex;
  const InventoryScreen({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      initialIndex: initialTabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.inventory),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: l10n.material),
              Tab(text: l10n.tools),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MaterialScreen(),
            ToolsScreen(),
          ],
        ),
      ),
    );
  }
}
