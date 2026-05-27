import 'package:flutter/material.dart';

class C {
  static const g900 = Color(0xFF052E15);
  static const g800 = Color(0xFF0D4A24);
  static const g700 = Color(0xFF166534);
  static const g600 = Color(0xFF16A34A);
  static const g500 = Color(0xFF22C55E);
  static const g400 = Color(0xFF4ADE80);
  static const g300 = Color(0xFF86EFAC);
  static const g100 = Color(0xFFDCFCE7);
  static const a700 = Color(0xFFB45309);
  static const a600 = Color(0xFFD97706);
  static const a500 = Color(0xFFF59E0B);
  static const a400 = Color(0xFFFBBF24);
  static const a300 = Color(0xFFFCD34D);
  static const a100 = Color(0xFFFEF3C7);
  static const r600 = Color(0xFFDC2626);
  static const r500 = Color(0xFFEF4444);
  static const r400 = Color(0xFFF87171);
  static const r100 = Color(0xFFFEE2E2);
  static const v600 = Color(0xFF7C3AED);
  static const v500 = Color(0xFF8B5CF6);
  static const v400 = Color(0xFFA78BFA);
  static const v100 = Color(0xFFEDE9FE);
  static const t600 = Color(0xFF0891B2);
  static const t500 = Color(0xFF06B6D4);
  static const t400 = Color(0xFF22D3EE);
  static const t100 = Color(0xFFCFFAFE);
  static const dark1 = Color(0xFF030A06);
  static const dark2 = Color(0xFF0A1A0F);
  static const dark3 = Color(0xFF0F2317);
  static const dark4 = Color(0xFF162D1E);
  static const card = Color(0xFF1A3526);
  static const card2 = Color(0xFF1F3D2C);
  static const card3 = Color(0xFF243F2F);
  static const white = Color(0xFFFFFFFF);
  static const white90 = Color(0xE6FFFFFF);
  static const white70 = Color(0xB3FFFFFF);
  static const white40 = Color(0x66FFFFFF);
  static const white20 = Color(0x33FFFFFF);
  static const white10 = Color(0x1AFFFFFF);
  static const white05 = Color(0x0DFFFFFF);
}

class T {
  static const _serif = 'Playfair Display';
  static const _sans = 'Plus Jakarta Sans';

  static TextStyle hero(double sz) => TextStyle(
        fontFamily: _serif,
        fontSize: sz,
        fontWeight: FontWeight.w700,
        color: C.white,
        height: 1.15,
        letterSpacing: -0.5,
      );

  static TextStyle head(double sz, {Color? c}) => TextStyle(
        fontFamily: _sans,
        fontSize: sz,
        fontWeight: FontWeight.w700,
        color: c ?? C.white,
        height: 1.25,
        letterSpacing: -0.3,
      );

  static TextStyle sub(double sz, {Color? c}) => TextStyle(
        fontFamily: _sans,
        fontSize: sz,
        fontWeight: FontWeight.w600,
        color: c ?? C.white70,
      );

  static TextStyle body(double sz, {Color? c}) => TextStyle(
        fontFamily: _sans,
        fontSize: sz,
        fontWeight: FontWeight.w400,
        color: c ?? C.white70,
        height: 1.6,
      );

  static TextStyle lbl({Color? c}) => TextStyle(
        fontFamily: _sans,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: c ?? C.white40,
        letterSpacing: 1.5,
      );

  static const btn = TextStyle(
    fontFamily: _sans,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: C.white,
    letterSpacing: 0.2,
  );
}

class D {
  static BoxDecoration card({double r = 20}) => BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: C.white10),
      );

  static BoxDecoration glow(Color color, {double r = 20}) => BoxDecoration(
        color: C.card2,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      );

  static BoxDecoration heroCard(double r) => BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A4D32), Color(0xFF0D3320)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: C.g500.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: C.g500.withValues(alpha: 0.25),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      );

  static const BoxDecoration fab = BoxDecoration(
    gradient: LinearGradient(
      colors: [C.g400, C.g600],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.all(Radius.circular(26)),
    boxShadow: [
      BoxShadow(
        color: Color(0x9922C55E),
        blurRadius: 32,
        offset: Offset(0, 14),
      ),
    ],
  );
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: C.dark2,
    colorScheme: const ColorScheme.dark(
      primary: C.g500,
      onPrimary: C.white,
      primaryContainer: C.g800,
      onPrimaryContainer: C.g300,
      secondary: C.a500,
      onSecondary: C.dark1,
      surface: C.dark2,
      onSurface: C.white,
      error: C.r500,
      onError: C.white,
    ),
    fontFamily: 'Plus Jakarta Sans',
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: C.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: T.head(18),
      iconTheme: const IconThemeData(color: C.white, size: 22),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: C.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: C.white10),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: C.card,
      hintStyle: T.body(14, c: C.white40),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: C.white20),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: C.white20),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: C.g500, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: C.g500,
        foregroundColor: C.white,
        elevation: 0,
        textStyle: T.btn,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
  );
}
