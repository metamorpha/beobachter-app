import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Einziges Theme der App: hell, kontraststark, Inter (US-601).
/// Bewusst kein Dark Theme — die App wird überwiegend draußen genutzt.
abstract final class AppTheme {
  static const fontFamily = 'Inter';

  static const _primary = Color(0xFF1B6B3A);

  static final ColorScheme _scheme = ColorScheme.fromSeed(
    seedColor: _primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: _primary,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFD3EEDB),
    onPrimaryContainer: const Color(0xFF0B3A1D),
    secondaryContainer: const Color(0xFFE2EAE4),
    onSecondaryContainer: const Color(0xFF1C2B21),
    surface: Colors.white,
    onSurface: const Color(0xFF121A15),
    onSurfaceVariant: const Color(0xFF47524A),
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: const Color(0xFFF5F7F5),
    surfaceContainer: const Color(0xFFEEF2EF),
    surfaceContainerHigh: const Color(0xFFE7ECE8),
    surfaceContainerHighest: const Color(0xFFDFE5E0),
    outline: const Color(0xFF7D8880),
    outlineVariant: const Color(0xFFD2D9D4),
    error: const Color(0xFFB91C1C),
    onError: Colors.white,
  );

  static ThemeData get light {
    final scheme = _scheme;
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      brightness: Brightness.light,
    );
    final text = base.textTheme.copyWith(
      headlineSmall: base.textTheme.headlineSmall
          ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3),
      titleLarge: base.textTheme.titleLarge
          ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.2),
      titleMedium:
          base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall:
          base.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: base.textTheme.labelLarge
          ?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
      labelMedium: base.textTheme.labelMedium
          ?.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
      labelSmall: base.textTheme.labelSmall?.copyWith(
          fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.8),
      bodySmall: base.textTheme.bodySmall?.copyWith(fontSize: 13),
    );

    final roundedM = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.m));
    const buttonMin = Size(AppSizes.tap, AppSizes.tap);

    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: scheme.surfaceContainerLow,
      extensions: const [AppColors.light],
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
        // iOS behält die native Wisch-zurück-Geste (Navigation unverändert).
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: Colors.black26,
        centerTitle: false,
        toolbarHeight: 64,
        titleTextStyle: text.titleLarge?.copyWith(color: scheme.onSurface),
        shape: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonMin,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          shape: roundedM,
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonMin,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          shape: roundedM,
          side: BorderSide(color: scheme.outline),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: buttonMin,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          shape: roundedM,
          textStyle: text.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: buttonMin),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        highlightElevation: 4,
        extendedSizeConstraints:
            const BoxConstraints.tightFor(height: AppSizes.primaryAction),
        extendedPadding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        extendedTextStyle: text.labelLarge?.copyWith(fontSize: 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.l + 4)),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.l),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.s + 2)),
        side: BorderSide(color: scheme.outlineVariant),
        labelStyle: text.labelLarge?.copyWith(fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        showCheckmark: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainer,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l, vertical: AppSpacing.m + 2),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        titleTextStyle: text.headlineSmall?.copyWith(color: scheme.onSurface),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.onPrimaryContainer,
        unselectedLabelColor: scheme.onSurfaceVariant,
        labelStyle: text.labelLarge,
        unselectedLabelStyle: text.labelLarge,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.m),
        ),
        overlayColor: WidgetStatePropertyAll(
            scheme.primary.withValues(alpha: 0.06)),
      ),
      dividerTheme:
          DividerThemeData(color: scheme.outlineVariant, thickness: 1),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 600),
        textStyle: text.bodySmall?.copyWith(color: Colors.white),
      ),
      progressIndicatorTheme:
          ProgressIndicatorThemeData(color: scheme.primary),
    );
  }
}
