import 'package:flutter/material.dart';
import '../app_colors.dart';

class NestoryFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final String? heroTag;
  final IconData icon;

  const NestoryFAB({
    super.key,
    required this.onPressed,
    this.heroTag,
    this.icon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: onPressed,
      backgroundColor: AppColors.accent,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Icon(icon, color: Colors.white),
    );
  }
}
