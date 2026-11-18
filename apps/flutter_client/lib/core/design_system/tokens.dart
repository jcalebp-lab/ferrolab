// Tokens del Design System FERROLAB (doc 08 §2). Los HEX son propuestas del
// proyecto, no estándares. Ningún widget debe usar colores HEX directamente.
import 'package:material_ui/material_ui.dart';

abstract final class FlColors {
  static const sulphurYellow = Color(0xFFE9E74A);
  static const peachRed = Color(0xFFFF725E);
  static const yellowGreen = Color(0xFFA9C84B);
  static const lightGreen = Color(0xFFBDECC1);
  static const ink = Color(0xFF17241D);
  static const inkSecondary = Color(0xFF54635B);
  static const surfaceBase = Color(0xFFFAFBF7);
  static const surfaceCard = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF141C19);
  static const surfaceDarkCard = Color(0xFF1E2824);
  static const inkOnDark = Color(0xFFF5FAF7);
  static const inkOnDarkSecondary = Color(0xFFB5C2BB);
  static const borderLight = Color(0xFFDDE3DC);
  static const borderDark = Color(0xFF34413B);
  // Semánticos: siempre acompañados de icono + texto (doc 08 §2.1).
  static const info = Color(0xFF3C6E91);
  static const errorRed = Color(0xFFB3261E);
}

abstract final class FlSpace {
  static const xs = 4.0, s = 8.0, m = 12.0, l = 16.0, xl = 24.0, xxl = 32.0, xxxl = 48.0;
}

abstract final class FlRadius {
  static const chip = 8.0, input = 14.0, card = 20.0, panel = 28.0;
}

abstract final class FlLayout {
  static const maxContentWidth = 1160.0;
  static const minTouch = 48.0;
  static const tabletBreakpoint = 720.0;
  static const desktopBreakpoint = 1040.0;
}

/// Lenguaje visual del metal caliente (doc 08 §6). Es ILUSTRATIVO: no es una
/// conversión fiable de temperatura a color (termometría óptica).
abstract final class FlGlow {
  static const stops = <(double, Color)>[
    (20, Color(0xFF8A9096)), // gris
    (500, Color(0xFF8A9096)),
    (650, Color(0xFF6E1A12)), // rojo oscuro
    (800, Color(0xFFC0281A)), // rojo
    (950, Color(0xFFF06A1C)), // naranja
    (1150, Color(0xFFFFC93A)), // amarillo
    (1400, Color(0xFFFFF6DE)), // blanco
  ];

  static Color forTemperature(double c) {
    if (c <= stops.first.$1) return stops.first.$2;
    for (var i = 1; i < stops.length; i++) {
      final (t1, c1) = stops[i];
      final (t0, c0) = stops[i - 1];
      if (c <= t1) return Color.lerp(c0, c1, (c - t0) / (t1 - t0))!;
    }
    return stops.last.$2;
  }
}

@immutable
class FerrolabTokens extends ThemeExtension<FerrolabTokens> {
  const FerrolabTokens({
    required this.surface,
    required this.card,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentSoft,
    required this.evidenceLimitedBg,
    required this.evidenceValidatedBg,
    required this.warningBg,
  });

  final Color surface, card, border, textPrimary, textSecondary, accentSoft;
  final Color evidenceLimitedBg, evidenceValidatedBg, warningBg;

  static const light = FerrolabTokens(
    surface: FlColors.surfaceBase,
    card: FlColors.surfaceCard,
    border: FlColors.borderLight,
    textPrimary: FlColors.ink,
    textSecondary: FlColors.inkSecondary,
    accentSoft: FlColors.lightGreen,
    evidenceLimitedBg: Color(0xFFF3F1DA),
    evidenceValidatedBg: Color(0xFFE2F3DA),
    warningBg: Color(0xFFFFE6E1),
  );

  static const dark = FerrolabTokens(
    surface: FlColors.surfaceDark,
    card: FlColors.surfaceDarkCard,
    border: FlColors.borderDark,
    textPrimary: FlColors.inkOnDark,
    textSecondary: FlColors.inkOnDarkSecondary,
    accentSoft: Color(0xFF2B3D33),
    evidenceLimitedBg: Color(0xFF34331F),
    evidenceValidatedBg: Color(0xFF26361F),
    warningBg: Color(0xFF402622),
  );

  @override
  FerrolabTokens copyWith() => this;

  @override
  FerrolabTokens lerp(ThemeExtension<FerrolabTokens>? other, double t) => t < .5 ? this : (other as FerrolabTokens);
}

extension FlThemeX on BuildContext {
  FerrolabTokens get fl => Theme.of(this).extension<FerrolabTokens>()!;
  TextTheme get text => Theme.of(this).textTheme;
}
