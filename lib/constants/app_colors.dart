import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppColors {
  // Primary and Secondary Background Colors
  static const Color primaryBackground = Color(0xFFF5F5F5); // Soft white
  static const Color secondaryBackground = Color(0xFFEFEFEF); // Light gray

  // Flowery Relaxing Colors
  static const Color softPink = Color(0xFFF8EDED); // Soft pink
  static const Color pastelBlue = Color(0xFFD7E3FC); // Light pastel blue
  static const Color mintGreen = Color(0xFFE3FCEC); // Light mint green
  static const Color lavender = Color(0xFFEAE6F7); // Light lavender
  static const Color peach = Color(0xFFFFF2E5); // Soft peach

  // Text Colors
  static const Color primaryText = Color(0xFF333333); // Dark gray for primary text
  static const Color secondaryText = Color(0xFF555555); // Medium gray for secondary text
  static const Color headerText = Color(0xFF222222); // Slightly darker gray for headers
}

class AppTextStyles {
  // Header Text Style
  static TextStyle headerStyle = TextStyle(
    fontSize: 24.sp, // Responsive text size using ScreenUtil
    fontWeight: FontWeight.bold,
    color: AppColors.headerText,

  );

  // Normal Text Style
  static TextStyle normalTextStyle = TextStyle(
    fontSize: 16.sp, // Responsive text size
    fontWeight: FontWeight.normal,
    color: AppColors.primaryText,

  );

  // Secondary Text Style
  static TextStyle secondaryTextStyle = TextStyle(
    fontSize: 14.sp, // Slightly smaller text for secondary information
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,

  );
}

class AppThemes {
  // Define a ThemeData to use throughout the app
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.primaryBackground,
    textTheme: TextTheme(
      displayLarge: AppTextStyles.headerStyle,
      bodyLarge: AppTextStyles.normalTextStyle,
      bodyMedium: AppTextStyles.secondaryTextStyle,
    ),
    colorScheme: ColorScheme.light(
      primary: AppColors.lavender,
      secondary: AppColors.mintGreen,
    ),
  );
}
