import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final String value;
  final String? currentSelection;
  final ValueChanged<String?> onSelectionChanged;

  CategoryChip({
    required this.label,
    required this.value,
    required this.currentSelection,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: FilterChip(
        label: Text(label),
        selected: currentSelection == value,
        onSelected: (selected) => onSelectionChanged(selected ? value : null),
      ),
    );
  }
}