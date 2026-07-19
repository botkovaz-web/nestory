import 'package:flutter/material.dart';

class NestoryCounter extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onAdd;
  final VoidCallback onSub;
  final Color? color;

  const NestoryCounter({
    super.key,
    required this.label,
    required this.value,
    required this.onAdd,
    required this.onSub,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onSub,
              child: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '$value',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color ?? Colors.black87,
                ),
              ),
            ),
            GestureDetector(
              onTap: onAdd,
              child: const Icon(Icons.add_circle_outline, size: 20, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
