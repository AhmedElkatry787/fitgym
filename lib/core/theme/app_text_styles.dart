import 'package:FitGym/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  /// Lalezar, used for page titles and big numbers.
  static TextStyle display(double fontSize, {Color color = AppColors.textPrimary, double height = 1.2}) {
    return GoogleFonts.lalezar(fontSize: fontSize, height: height, color: color);
  }

  /// IBM Plex Sans Arabic, used for everything else.
  static TextStyle body(
    double fontSize, {
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.ibmPlexSansArabic(fontSize: fontSize, fontWeight: fontWeight, color: color);
  }

  static TextStyle get pageTitle => display(28);

  static TextStyle get sectionTitle => body(17, fontWeight: FontWeight.w700);

  static TextStyle get caption => body(13, color: AppColors.textSecondary);
}
