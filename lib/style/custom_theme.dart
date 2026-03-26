import 'package:climbing_companion/core/app_colors.dart';
import 'package:climbing_companion/core/app_size.dart';
import 'package:flutter/material.dart';

abstract class ThemePreferences {
  ThemeData get dark;
  ThemeData get light;
}

class CustomTheme extends ThemePreferences{
  @override
  ThemeData get dark => ThemeData(

  );

  @override
  ThemeData get light => ThemeData(
    fontFamily: 'Inter',
    scaffoldBackgroundColor: Colors.white,
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.white,
      titleTextStyle: const TextStyle(color: Colors.black),
      contentTextStyle: const TextStyle(color: Colors.black),
    ),

    navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)){
          return TextStyle(
            color: Colors.black,
            fontSize: AppSize.sp12,
          );
        }
        return TextStyle(
          color: Colors.white,
          fontSize: AppSize.sp12,
          fontWeight: FontWeight.bold,
        );
      }),
    ),

    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryColor,
      onPrimary: AppColors.black,
      secondary: AppColors.white,
      onSecondary: AppColors.black,
      error: AppColors.primaryColor,
      onError: AppColors.white,
      surface: Color.fromRGBO(255, 240, 240, 1),
      onSurface: AppColors.black,
      surfaceContainerHighest: AppColors.white,
    ),
    primaryColor: AppColors.primaryColor,
    primaryColorDark: AppColors.primaryColor,
    appBarTheme: AppBarTheme(
      iconTheme: IconThemeData(color: AppColors.black),
      backgroundColor: AppColors.white,
    ),
    scrollbarTheme:ScrollbarThemeData(
      interactive: true,
      radius: Radius.circular(AppSize.r10),
      minThumbLength: 100,
    ),
    highlightColor: AppColors.transparent,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity,AppSize.h60),
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.r40),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
      ),
    ),
    splashColor: AppColors.transparent,
    textTheme: TextTheme(

      headlineLarge: TextStyle(
        color: AppColors.black,
        fontSize: AppSize.sp24,
        fontWeight: FontWeight.w600,
      ),

      bodyLarge: TextStyle(
        color: AppColors.black,
        fontSize: AppSize.sp26,
        fontWeight: FontWeight.w600,
      ),

      bodyMedium: TextStyle(
        color: AppColors.black,
        fontSize: AppSize.sp24,
        fontWeight: FontWeight.w600,
      ),

      bodySmall: TextStyle(
        color: AppColors.black,
        fontSize: AppSize.sp20,
        fontWeight: FontWeight.w500,
      ),

      titleLarge: TextStyle(
        color: AppColors.black,
        fontSize: AppSize.sp18,
        fontWeight: FontWeight.w500,
      ),

      titleMedium: TextStyle(
        color: AppColors.black,
        fontSize: AppSize.sp14,
        fontWeight: FontWeight.w500,
      ),

      titleSmall: TextStyle(
        color: AppColors.black,
        fontSize: AppSize.sp12,
        fontWeight: FontWeight.w500,
      ),

    ),
    
    disabledColor: AppColors.gray700,
  );
}