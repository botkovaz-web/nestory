import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../l10n/app_localizations.dart';
import '../widgets/app_bar_actions.dart';
import 'project_screen.dart';
import 'guide_screen.dart';

class ProjectsHubScreen extends StatelessWidget {
  final int initialTabIndex;
  final Function(int, {int subTab}) onNavigate;

  const ProjectsHubScreen({
    super.key,
    this.initialTabIndex = 0,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      initialIndex: initialTabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.projects),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            NestoryAppBarActions(onNavigate: onNavigate),
          ],
          bottom: TabBar(
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: l10n.myCreation),
              Tab(text: l10n.guides),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ProjectScreen(),
            GuideScreen(),
          ],
        ),
      ),
    );
  }
}
