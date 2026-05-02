import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle heading(BuildContext context) => GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle body(BuildContext context) => GoogleFonts.inter(
        color: Theme.of(context).colorScheme.onSurface,
      );
}
