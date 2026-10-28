import 'package:flutter/material.dart';

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
  AppColors copyWith() => this;

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
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

abstract final class AppTheme {
  static final light = _build(AppColors.light, Brightness.light);
  static final dark = _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
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
          backgroundColor: AppColors.primary,
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
