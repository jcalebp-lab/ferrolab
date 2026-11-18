import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/design_system/theme.dart';
import 'l10n.dart';
import 'providers.dart';
import 'router.dart';

class FerrolabApp extends ConsumerWidget {
  const FerrolabApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      onGenerateTitle: (c) => c.t.appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: s.themeMode,
      locale: Locale(s.locale),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
      routerConfig: router,
      builder: (context, child) {
        // Reducir movimiento: preferencia del sistema O de la app.
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(disableAnimations: mq.disableAnimations || s.reduceMotion),
          child: child!,
        );
      },
    );
  }
}
