import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get heading => GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      );

  static TextStyle get body => GoogleFonts.inter(
        color: Colors.black,
      );
}
