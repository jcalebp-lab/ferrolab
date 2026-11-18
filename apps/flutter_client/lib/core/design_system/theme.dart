import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final t = dark ? FerrolabTokens.dark : FerrolabTokens.light;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: FlColors.sulphurYellow,
    onPrimary: FlColors.ink, // nunca blanco sobre colores de marca (contraste)
    secondary: FlColors.yellowGreen,
    onSecondary: FlColors.ink,
    tertiary: FlColors.peachRed,
    onTertiary: FlColors.ink,
    error: FlColors.errorRed,
    onError: Colors.white,
    surface: t.surface,
    onSurface: t.textPrimary,
    surfaceContainerHighest: t.card,
    outline: t.border,
  );
  // Tipografía de sistema (SF en Apple; Roboto/Segoe/etc. en otras). No se empaquetan fuentes.
  final base = Typography.material2021(platform: TargetPlatform.android).englishLike.apply(
    bodyColor: t.textPrimary,
    displayColor: t.textPrimary,
  );
  final text = base.copyWith(
    displaySmall: base.displaySmall?.copyWith(fontSize: 36, fontWeight: FontWeight.w700, height: 1.1),
    headlineSmall: base.headlineSmall?.copyWith(fontSize: 28, fontWeight: FontWeight.w700),
    titleLarge: base.titleLarge?.copyWith(fontSize: 21, fontWeight: FontWeight.w600),
    titleMedium: base.titleMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w600),
    bodyLarge: base.bodyLarge?.copyWith(fontSize: 16, height: 1.45),
    bodyMedium: base.bodyMedium?.copyWith(fontSize: 15, height: 1.45),
    labelLarge: base.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
    bodySmall: base.bodySmall?.copyWith(fontSize: 13, color: t.textSecondary),
  );
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(FlRadius.input));
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: t.surface,
    textTheme: text,
    extensions: [t],
    appBarTheme: AppBarTheme(
      backgroundColor: t.surface,
      foregroundColor: t.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge,
    ),
    cardTheme: CardThemeData(
      color: t.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FlRadius.card),
        side: BorderSide(color: t.border),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: FlColors.sulphurYellow,
        foregroundColor: FlColors.ink,
        disabledBackgroundColor: t.border,
        disabledForegroundColor: t.textSecondary,
        minimumSize: const Size(FlLayout.minTouch, FlLayout.minTouch),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: shape,
        textStyle: text.labelLarge?.copyWith(fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: t.textPrimary,
        minimumSize: const Size(FlLayout.minTouch, FlLayout.minTouch),
        side: BorderSide(color: t.border),
        shape: shape,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: dark ? FlColors.lightGreen : const Color(0xFF2F5A2F),
        minimumSize: const Size(FlLayout.minTouch, FlLayout.minTouch),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: t.card,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(FlRadius.input), borderSide: BorderSide(color: t.border)),
      enabledBorder:
          OutlineInputBorder(borderRadius: BorderRadius.circular(FlRadius.input), borderSide: BorderSide(color: t.border)),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FlRadius.chip)),
      side: BorderSide(color: t.border),
      labelStyle: text.labelLarge?.copyWith(fontSize: 13),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: dark ? FlColors.sulphurYellow : FlColors.ink,
      thumbColor: FlColors.sulphurYellow,
      inactiveTrackColor: t.border,
      overlayColor: FlColors.sulphurYellow.withValues(alpha: .2),
    ),
    dividerTheme: DividerThemeData(color: t.border, space: 1),
    focusColor: FlColors.sulphurYellow.withValues(alpha: .35),
  );
}
