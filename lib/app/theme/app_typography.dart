import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const String fontFamily = 'sans-serif';

  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 64,
    height: 1.05,
    fontWeight: FontWeight.w300,
    letterSpacing: 1.5,
    color: AppColors.ivory,
  );

  static const TextStyle heroTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 52,
    height: 1.08,
    fontWeight: FontWeight.w400,
    letterSpacing: 2.0,
    color: AppColors.ivory,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    height: 1.15,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.2,
    color: AppColors.ivory,
  );

  static const TextStyle productTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 1.2,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
    color: AppColors.ivory,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.6,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const TextStyle navigation = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    color: AppColors.black,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.5,
    color: AppColors.gold,
  );
}