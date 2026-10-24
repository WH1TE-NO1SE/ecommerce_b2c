import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ========== 颜色体系（Apple AppStore 液态玻璃风格）==========
  static const Color primaryColor = Color(0xFF92A8D1); // 主色：淡蓝紫 #92A8D1
  static const Color primaryLight = Color(0xFFB8C5DD); // 主色浅
  static const Color primaryDark = Color(0xFF7B93BC); // 主色深

  // 辅助色
  static const Color secondaryColor = Color(0xFF74B9FF); // 淡蓝
  static const Color accentColor = Color(0xFFFD79A8); // 粉色点缀

  // 背景色系
  static const Color scaffoldBgColor = Color(0xFFF0F2F5); // 浅灰背景（iOS风格）
  static const Color cardBgColor = Color(0xFFFFFFFF); // 白色卡片
  static const Color glassBgColor = Color(0x33000000); // 玻璃遮罩色

  // 文字色系
  static const Color textPrimary = Color(0xFF1A1A2E); // 深色主文字
  static const Color textSecondary = Color(0xFF8B8BA3); // 灰色次要文字
  static const Color textWhite = Color(0xFFFFFFFF); // 白色文字

  // 功能色
  static const Color priceColor = Color(0xFFFF6B6B); // 价格红
  static const Color successColor = Color(0xFF00B894); // 成功绿
  static const Color warningColor = Color(0xFFFDCB6E); // 警告黄
  static const Color errorColor = Color(0xFFE17055); // 错误橙
  static const Color dividerColor = Color(0xFFE8E8ED); // 分割线

  // ========== 圆角体系 ==========
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusRound = 999.0;

  // ========== 阴影体系（柔和阴影） ==========
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get glassShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  // ========== 主题数据 ==========
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
          primary: primaryColor,
          secondary: secondaryColor,
          surface: cardBgColor,
          error: errorColor,
        ),
        scaffoldBackgroundColor: scaffoldBgColor,
        fontFamily: '.SF Pro Text',

        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: scaffoldBgColor,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),

        // 卡片
        cardTheme: CardTheme(
          color: cardBgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
          margin: EdgeInsets.zero,
        ),

        // 按钮
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: textWhite,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMedium),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMedium),
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: const BorderSide(color: primaryColor, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMedium),
            ),
          ),
        ),

        // 输入框
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardBgColor,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: errorColor, width: 1.5),
          ),
        ),

        // 底部导航栏
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: cardBgColor,
          selectedItemColor: primaryColor,
          unselectedItemColor: textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle:
              TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 11),
        ),

        // TabBar
        tabBarTheme: const TabBarTheme(
          labelColor: primaryColor,
          unselectedLabelColor: textSecondary,
          indicatorColor: primaryColor,
          indicatorSize: TabBarIndicatorSize.label,
        ),

        // 分割线
        dividerTheme: const DividerThemeData(
          color: dividerColor,
          thickness: 0.5,
          space: 1,
        ),

        // BottomSheet
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: cardBgColor,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(radiusXLarge)),
          ),
        ),

        // Dialog
        dialogTheme: DialogTheme(
          backgroundColor: cardBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXLarge),
          ),
        ),

        // Chip
        chipTheme: ChipThemeData(
          backgroundColor: scaffoldBgColor,
          selectedColor: primaryColor.withOpacity(0.15),
          labelStyle: const TextStyle(fontSize: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusRound),
          ),
        ),
      );

  // 黑暗主题
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
          primary: primaryLight,
          secondary: secondaryColor,
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A2E),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF252542),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryLight,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMedium),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF252542),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: Color(0xFF3A3A5C)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: Color(0xFF3A3A5C)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: primaryLight, width: 2),
          ),
        ),
      );
}
