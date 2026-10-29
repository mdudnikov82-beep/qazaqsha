import 'package:flutter/material.dart';

import '../data/database/tables.dart' show AppPalette;

/// Design tokens from the Qazaqsha mockups (light and dark palettes).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.surface,
    required this.ink,
    required this.muted,
    required this.line,
    required this.track,
    required this.accent,
    required this.accentSoft,
    required this.sky,
    required this.goldSoft,
    required this.goldText,
    required this.flame,
    required this.ok,
    required this.okSoft,
    required this.okText,
    required this.bad,
    required this.badSoft,
    required this.badText,
    required this.lockIcon,
    this.brand = primary,
    this.brandDeep = primaryShadow,
    this.onBrandMuted = const Color(0xFFCDEFF6),
  });

  // Same in both themes: white text on these passes contrast.
  static const primary = Color(0xFF00789A);
  static const primaryShadow = Color(0xFF005C76);
  static const gold = Color(0xFFF5B800);
  static const onGold = Color(0xFF13232E);
  static const okButton = Color(0xFF1B7F4E);
  static const badButton = Color(0xFFB3261E);

  final Color bg;
  final Color surface;
  final Color ink;
  final Color muted;
  final Color line;
  final Color track;
  final Color accent;
  final Color accentSoft;
  final Color sky;
  final Color goldSoft;
  final Color goldText;
  final Color flame;
  final Color ok;
  final Color okSoft;
  final Color okText;
  final Color bad;
  final Color badSoft;
  final Color badText;
  final Color lockIcon;

  /// Header and main-button colour of the current palette; white text on
  /// it passes contrast. [brandDeep] is its shadow, [onBrandMuted] the
  /// light secondary text on it.
  final Color brand;
  final Color brandDeep;
  final Color onBrandMuted;

  static const light = AppColors(
    bg: Color(0xFFF4F8FA),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF13232E),
    muted: Color(0xFF50606B),
    line: Color(0xFFDCE6EB),
    track: Color(0xFFE3ECF0),
    accent: Color(0xFF00789A),
    accentSoft: Color(0xFFE0F4F8),
    sky: Color(0xFF00AFCA),
    goldSoft: Color(0xFFFFF3CC),
    goldText: Color(0xFF9A6A00),
    flame: Color(0xFFE07A00),
    ok: Color(0xFF1B7F4E),
    okSoft: Color(0xFFE3F4EA),
    okText: Color(0xFF0F5A36),
    bad: Color(0xFFB3261E),
    badSoft: Color(0xFFFBE6E4),
    badText: Color(0xFF8C1D18),
    lockIcon: Color(0xFF6E7C86),
  );

  static const dark = AppColors(
    bg: Color(0xFF0D171D),
    surface: Color(0xFF16252E),
    ink: Color(0xFFE7EFF3),
    muted: Color(0xFF9DB0BB),
    line: Color(0xFF263843),
    track: Color(0xFF263843),
    accent: Color(0xFF7FD8EA),
    accentSoft: Color(0xFF0F3644),
    sky: Color(0xFF2EC4DE),
    goldSoft: Color(0xFF3A2F0C),
    goldText: Color(0xFFF5C842),
    flame: Color(0xFFFF9A3C),
    ok: Color(0xFF3DBA7C),
    okSoft: Color(0xFF12301F),
    okText: Color(0xFF8FE3B5),
    bad: Color(0xFFEF6A62),
    badSoft: Color(0xFF3A1715),
    badText: Color(0xFFFFA39C),
    lockIcon: Color(0xFF8597A1),
  );

  @override
  AppColors copyWith({
    Color? bg,
    Color? surface,
    Color? accent,
    Color? accentSoft,
    Color? sky,
    Color? brand,
    Color? brandDeep,
    Color? onBrandMuted,
  }) => AppColors(
    bg: bg ?? this.bg,
    surface: surface ?? this.surface,
    ink: ink,
    muted: muted,
    line: line,
    track: track,
    accent: accent ?? this.accent,
    accentSoft: accentSoft ?? this.accentSoft,
    sky: sky ?? this.sky,
    goldSoft: goldSoft,
    goldText: goldText,
    flame: flame,
    ok: ok,
    okSoft: okSoft,
    okText: okText,
    bad: bad,
    badSoft: badSoft,
    badText: badText,
    lockIcon: lockIcon,
    brand: brand ?? this.brand,
    brandDeep: brandDeep ?? this.brandDeep,
    onBrandMuted: onBrandMuted ?? this.onBrandMuted,
  );

  /// Colours of [palette] in [brightness].
  static AppColors of(AppPalette palette, Brightness brightness) {
    final base = brightness == Brightness.dark ? dark : light;
    final d = brightness == Brightness.dark;
    return switch (palette) {
      AppPalette.teal => base,
      AppPalette.steppe => base.copyWith(
        brand: const Color(0xFF8C5A00),
        brandDeep: const Color(0xFF6B4400),
        onBrandMuted: const Color(0xFFF6E3BD),
        accent: d ? const Color(0xFFF0C674) : const Color(0xFF8C5A00),
        accentSoft: d ? const Color(0xFF3A2B0C) : const Color(0xFFFBF0D9),
        sky: d ? const Color(0xFFE6A93A) : const Color(0xFFC98A12),
      ),
      AppPalette.tianshan => base.copyWith(
        brand: const Color(0xFF24508F),
        brandDeep: const Color(0xFF1A3D6E),
        onBrandMuted: const Color(0xFFD6E6FA),
        accent: d ? const Color(0xFF9CC3F5) : const Color(0xFF24508F),
        accentSoft: d ? const Color(0xFF13284A) : const Color(0xFFE3EEFB),
        sky: d ? const Color(0xFF6AA6F0) : const Color(0xFF3D7BD9),
      ),
      AppPalette.nauryz => base.copyWith(
        brand: const Color(0xFF1E7A4C),
        brandDeep: const Color(0xFF166339),
        onBrandMuted: const Color(0xFFD3F0DF),
        accent: d ? const Color(0xFF7FDCA9) : const Color(0xFF1E7A4C),
        accentSoft: d ? const Color(0xFF0F3020) : const Color(0xFFE3F5EA),
        sky: d ? const Color(0xFF4CCB8A) : const Color(0xFF2EB872),
      ),
      AppPalette.night => base.copyWith(
        brand: const Color(0xFF3B3280),
        brandDeep: const Color(0xFF2A2360),
        onBrandMuted: const Color(0xFFDCD8F5),
        accent: d ? const Color(0xFFB3A8FF) : const Color(0xFF3B3280),
        accentSoft: d ? const Color(0xFF1E1A44) : const Color(0xFFECEAFB),
        sky: d ? const Color(0xFF8F82FF) : const Color(0xFF6C5CE7),
        bg: d ? const Color(0xFF0B0A1A) : null,
        surface: d ? const Color(0xFF17152E) : null,
      ),
    };
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      ink: l(ink, other.ink),
      muted: l(muted, other.muted),
      line: l(line, other.line),
      track: l(track, other.track),
      accent: l(accent, other.accent),
      accentSoft: l(accentSoft, other.accentSoft),
      sky: l(sky, other.sky),
      goldSoft: l(goldSoft, other.goldSoft),
      goldText: l(goldText, other.goldText),
      flame: l(flame, other.flame),
      ok: l(ok, other.ok),
      okSoft: l(okSoft, other.okSoft),
      okText: l(okText, other.okText),
      bad: l(bad, other.bad),
      badSoft: l(badSoft, other.badSoft),
      badText: l(badText, other.badText),
      lockIcon: l(lockIcon, other.lockIcon),
      brand: l(brand, other.brand),
      brandDeep: l(brandDeep, other.brandDeep),
      onBrandMuted: l(onBrandMuted, other.onBrandMuted),
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

/// A palette, its name and the level that unlocks it.
const paletteInfo = <AppPalette, ({String title, int level})>{
  AppPalette.teal: (title: 'Бирюза', level: 1),
  AppPalette.steppe: (title: 'Дала · Степь', level: 3),
  AppPalette.tianshan: (title: 'Тянь-Шань', level: 5),
  AppPalette.nauryz: (title: 'Наурыз', level: 7),
  AppPalette.night: (title: 'Түн · Ночь', level: 10),
};

abstract final class AppTheme {
  static final light = build(AppPalette.teal, Brightness.light);
  static final dark = build(AppPalette.teal, Brightness.dark);

  static ThemeData build(AppPalette palette, Brightness brightness) =>
      _build(AppColors.of(palette, brightness), brightness);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.brand,
      onPrimary: Colors.white,
      secondary: AppColors.gold,
      onSecondary: AppColors.onGold,
      error: c.bad,
      onError: Colors.white,
      surface: c.surface,
      onSurface: c.ink,
      onSurfaceVariant: c.muted,
      outline: c.line,
      outlineVariant: c.line,
      surfaceContainerHighest: c.track,
    );
    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: 'Nunito',
      scaffoldBackgroundColor: c.bg,
      extensions: [c],
    );
    final text = base.textTheme.apply(bodyColor: c.ink, displayColor: c.ink);
    return base.copyWith(
      textTheme: text.copyWith(
        headlineMedium: text.headlineMedium?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        bodyLarge: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        bodyMedium: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w900),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.bg,
        foregroundColor: c.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: c.ink,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.accentSoft,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11,
            fontWeight: s.contains(WidgetState.selected)
                ? FontWeight.w900
                : FontWeight.w700,
            color: s.contains(WidgetState.selected) ? c.accent : c.muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected) ? c.accent : c.muted,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.brand,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c.line, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c.line, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c.sky, width: 2),
        ),
        hintStyle: TextStyle(color: c.muted, fontWeight: FontWeight.w600),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surface,
        selectedColor: c.ink,
        side: BorderSide(color: c.line),
        labelStyle: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          color: c.ink,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          color: c.bg,
        ),
        shape: const StadiumBorder(),
        showCheckmark: false,
      ),
    );
  }
}
