import 'package:flutter/material.dart';

class IconHelper {
  /// Returns a constant IconData for common code points to support tree-shaking.
  /// Falls back to a dynamic IconData if not found (which requires --no-tree-shake-icons).
  static IconData getIcon(int codePoint) {
    switch (codePoint) {
      case 0xe532: return Icons.restaurant;
      case 0xe1d1: return Icons.directions_car;
      case 0xef6e: return Icons.receipt;
      case 0xe40f: return Icons.movie;
      case 0xe25b: return Icons.favorite;
      case 0xe559: return Icons.school;
      case 0xf0170: return Icons.shopping_bag;
      case 0xe111: return Icons.work;
      case 0xe366: return Icons.laptop;
      case 0xe13d: return Icons.category;
      default:
        // Return a constant fallback to allow tree-shaking to succeed.
        // Note: This will prevent custom icons from showing correctly.
        return Icons.help_outline;
    }
  }
}
