import 'package:flutter/material.dart';

/// 应用 Material 主题
class AppMaterialTheme {
  /// 创建应用浅色主题
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _AppColors.accent,
      brightness: Brightness.light,
    ).copyWith(
      primary: _AppColors.accent,
      onPrimary: Colors.white,
      surface: _AppColors.surface,
      onSurface: _AppColors.text,
      onSurfaceVariant: _AppColors.subtleText,
      surfaceContainerLowest: _AppColors.background,
      surfaceContainerLow: _AppColors.surfaceSoft,
      surfaceContainer: _AppColors.surfaceSoft,
      surfaceContainerHigh: _AppColors.surfaceSoft,
      surfaceContainerHighest: _AppColors.surfaceSoft,
      outline: _AppColors.outline,
      outlineVariant: _AppColors.outline,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _AppColors.background,
    );
  }

  /// 创建应用深色主题
  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _AppColors.accent,
      brightness: Brightness.dark,
    ).copyWith(
      primary: _AppColors.accent,
      surface: const Color(0xFF18181B),
      onSurface: const Color(0xFFFAFAFA),
      onSurfaceVariant: const Color(0xFFA1A1AA),
      surfaceContainerLowest: const Color(0xFF111113),
      surfaceContainerLow: const Color(0xFF202024),
      surfaceContainer: const Color(0xFF27272A),
      surfaceContainerHigh: const Color(0xFF2F2F33),
      surfaceContainerHighest: const Color(0xFF3F3F46),
      outline: const Color(0xFF3F3F46),
      outlineVariant: const Color(0xFF3F3F46),
    );

    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF111113),
    );
  }

  /// 构建 Material 主题
  ///
  /// [colorScheme] 颜色方案
  /// [scaffoldBackgroundColor] 页面背景色
  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Color scaffoldBackgroundColor,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackgroundColor,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
          minimumSize: const Size.square(44),
          tapTargetSize: MaterialTapTargetSize.padded,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

/// 应用主题颜色
class _AppColors {
  static const Color accent = Color(0xFFF09199);
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF4F4F5);
  static const Color text = Color(0xFF11181C);
  static const Color subtleText = Color(0xFF71717A);
  static const Color outline = Color(0xFFE4E4E7);
}
