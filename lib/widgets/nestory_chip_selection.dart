import 'package:flutter/material.dart';

class NestoryChipSelection extends StatelessWidget {
  final String title;
  final List<String> allItems;
  final List<String> selectedItems;
  final Function(List<String>) onChanged;

  const NestoryChipSelection({
    super.key,
    required this.title,
    required this.allItems,
    required this.selectedItems,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: -4,
          children: allItems.map((name) {
            final isSelected = selectedItems.contains(name);
            return FilterChip(
              label: Text(name, style: const TextStyle(fontSize: 11)),
              selected: isSelected,
              onSelected: (selected) {
                final newList = List<String>.from(selectedItems);
                selected ? newList.add(name) : newList.remove(name);
                onChanged(newList);
              },
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
      ],
    );
  }
}
