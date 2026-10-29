import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qazaqsha/app/theme.dart';
import 'package:qazaqsha/data/database/tables.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (max(la, lb) + 0.05) / (min(la, lb) + 0.05);
}

double max(double a, double b) => a > b ? a : b;
double min(double a, double b) => a < b ? a : b;

void main() {
  test('every palette keeps white text readable on its header', () {
    for (final p in AppPalette.values) {
      for (final b in Brightness.values) {
        final c = AppColors.of(p, b);
        expect(
          _contrast(c.brand, Colors.white),
          greaterThanOrEqualTo(4.5),
          reason: '$p $b',
        );
        expect(
          _contrast(c.ink, c.surface),
          greaterThanOrEqualTo(4.5),
          reason: '$p $b',
        );
      }
    }
  });

  test('palettes differ, unlock in level order, teal is free', () {
    final brands = {
      for (final p in AppPalette.values)
        AppColors.of(p, Brightness.light).brand,
    };
    expect(brands, hasLength(AppPalette.values.length));
    expect(paletteInfo[AppPalette.teal]!.level, 1);
    final levels = [for (final p in AppPalette.values) paletteInfo[p]!.level];
    expect(levels, [...levels]..sort());
  });
}
