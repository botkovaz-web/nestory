import 'package:flutter/material.dart';

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
    // Teraz sa farba berie automaticky z témy
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: onPressed,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Icon(icon, color: Colors.white),
    );
  }
}
