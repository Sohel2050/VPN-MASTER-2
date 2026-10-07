import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:winsguard/core/utils/extensions/theme_extension.dart';

/// A utility class that defines the text styles used throughout the application,
/// following the Material Design type scale.
extension AppTextStyles on BuildContext{

  // Primary text style.
  TextStyle get primary => GoogleFonts.inter(
    fontSize: 13.sp,
    fontWeight: FontWeight.w600,
    color: colors.textPrimary,
  );


  // Subtitle text style.
  TextStyle get subtitle => GoogleFonts.inter(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: colors.textPrimary,
  );


  // Style for text within secondary buttons.
  TextStyle get secondaryButtonStyle =>
      GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: colors.textSecondary
  );

  // Style for app bar titles.
  TextStyle get appBarTextStyles =>
      GoogleFonts.inter(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary
      );

  // Display styles are reserved for short, important text or numerals.
  TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 57.sp,
    fontWeight: FontWeight.bold,
    color: colors.textPrimary,
  );

  TextStyle get displayMedium => GoogleFonts.inter(
    fontSize: 45.sp,
    fontWeight: FontWeight.bold,
    color: colors.textPrimary,
  );

  TextStyle get displaySmall => GoogleFonts.inter(
    fontSize: 36.sp,
    fontWeight: FontWeight.bold,
    color: colors.textPrimary,
  );

  // Headline styles are best for short, high-emphasis text.
  TextStyle get headlineLarge => GoogleFonts.inter(
    fontSize: 32.sp,
    fontWeight: FontWeight.w600,
    color: colors.textPrimary,
  );

  TextStyle get headlineMedium => GoogleFonts.inter(
    fontSize: 28.sp,
    fontWeight: FontWeight.w600,
    color: colors.textPrimary,
  );

  TextStyle get headlineSmall => GoogleFonts.inter(
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    color: colors.textPrimary,
  );

  // Title styles are smaller than headline styles, for medium-emphasis text.
  TextStyle get titleLarge => GoogleFonts.inter(
    fontSize: 22.sp,
    fontWeight: FontWeight.w500,
    color: colors.textPrimary,
  );

  TextStyle get titleMedium => GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: colors.textPrimary,
  );

  TextStyle get titleSmall => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: colors.textPrimary,
  );

  // Body styles are used for longer passages of text.
  TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    color: colors.textPrimary,
  );

  TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: colors.textSecondary,
  );

  TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: colors.textSecondary,
  );

  // Label styles are used for smaller, utility text, such as in buttons or captions.
  TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: colors.textPrimary,
  );

  TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: colors.textPrimary,
  );

  TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    color: colors.textPrimary,
  );

  // Caption style, often used for annotations or to introduce a headline.
  TextStyle get caption => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: colors.textSecondary,
  );
}
