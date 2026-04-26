import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ColorPickerWidget extends StatelessWidget {

  const ColorPickerWidget({
    required this.selectedColorValue, required this.onSelected, super.key,
  });
  final int selectedColorValue;
  final ValueChanged<int> onSelected;

  static const List<Color> colors = [
    Colors.red, Colors.orange, Colors.amber, Colors.yellow, Colors.lime,
    Colors.green, Colors.teal, Colors.cyan, Colors.blue, Colors.indigo,
    Colors.purple, Colors.pink
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: colors.map((color) {
          final isSelected = color.toARGB32() == selectedColorValue;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => onSelected(color.toARGB32()),
              customBorder: const CircleBorder(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
