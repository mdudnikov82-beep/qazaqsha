import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Icon names stored in the dictionary → Material icons.
const _categoryIcons = <String, IconData>{
  'waving_hand': Icons.waving_hand_rounded,
  'family_restroom': Icons.family_restroom_rounded,
  'pin': Icons.pin_rounded,
  'palette': Icons.palette_rounded,
  'schedule': Icons.schedule_rounded,
  'calendar_month': Icons.calendar_month_rounded,
  'restaurant': Icons.restaurant_rounded,
  'local_cafe': Icons.local_cafe_rounded,
  'pets': Icons.pets_rounded,
  'park': Icons.park_rounded,
  'accessibility_new': Icons.accessibility_new_rounded,
  'medical_services': Icons.medical_services_rounded,
  'home': Icons.home_rounded,
  'checkroom': Icons.checkroom_rounded,
  'location_city': Icons.location_city_rounded,
  'directions_car': Icons.directions_car_rounded,
  'work': Icons.work_rounded,
  'school': Icons.school_rounded,
  'directions_run': Icons.directions_run_rounded,
  'auto_awesome': Icons.auto_awesome_rounded,
  'help': Icons.help_rounded,
  'link': Icons.link_rounded,
  'music_note': Icons.music_note_rounded,
  'bookmark': Icons.bookmark_rounded,
};

IconData categoryIcon(String name) =>
    _categoryIcons[name] ?? Icons.category_rounded;

/// Rounded progress bar from the design.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.height = 12,
    this.color,
    this.trackColor,
    this.semanticsLabel,
  });

  final double value;
  final double height;
  final Color? color;
  final Color? trackColor;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: semanticsLabel,
      value: '${(value.clamp(0, 1) * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: trackColor ?? c.track),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value.clamp(0, 1),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color ?? c.sky,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small rounded badge: streak, XP.
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.icon,
    required this.text,
    required this.background,
    required this.foreground,
    this.iconColor,
    this.semanticsLabel,
  });

  final IconData icon;
  final String text;
  final Color background;
  final Color foreground;
  final Color? iconColor;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      excludeSemantics: semanticsLabel != null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: iconColor ?? foreground),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// White (dark: slate) rounded card used across screens.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
    this.onTap,
    this.radius = 20,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? context.colors.surface,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Loading / error wrapper for screens that wait on several providers.
class LoadingScaffold extends StatelessWidget {
  const LoadingScaffold({super.key, this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: error == null
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Не удалось загрузить данные: $error',
                  textAlign: TextAlign.center,
                ),
              ),
      ),
    );
  }
}
