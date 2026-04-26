import 'package:flutter/material.dart';

class IconPickerWidget extends StatelessWidget {

  const IconPickerWidget({
    required this.selectedIconCode, required this.onSelected, super.key,
  });
  final int selectedIconCode;
  final ValueChanged<int> onSelected;

  static const List<IconData> icons = [
    Icons.restaurant, Icons.directions_car, Icons.receipt, Icons.movie, Icons.favorite,
    Icons.school, Icons.shopping_bag, Icons.work, Icons.laptop, Icons.category,
    Icons.home, Icons.pets, Icons.flight, Icons.sports_soccer, Icons.fitness_center,
    Icons.local_cafe, Icons.music_note, Icons.phone, Icons.local_hospital, Icons.savings,
    Icons.card_giftcard, Icons.beach_access, Icons.build, Icons.brush, Icons.science,
    Icons.language, Icons.group, Icons.star, Icons.bolt, Icons.child_care
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: icons.map((icon) {
        final isSelected = icon.codePoint == selectedIconCode;
        return InkWell(
          onTap: () => onSelected(icon.codePoint),
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? theme.colorScheme.primary : Colors.grey.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 24,
            ),
          ),
        );
      }).toList(),
    );
  }
}
