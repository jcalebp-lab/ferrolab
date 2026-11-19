import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n.dart';
import '../../app/providers.dart';
import '../../core/design_system/tokens.dart';
import '../../shared/widgets/widgets.dart';

/// Bienvenida y tutorial de 3 pasos, siempre saltable (doc 07 §3.1). No pide cuenta ni permisos.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int step = 0; // 0 = bienvenida, 1..3 = pasos

  void _finish() {
    ref.read(settingsProvider.notifier).update((s) => s.copyWith(onboardingSeen: true));
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final s = ref.watch(settingsProvider);
    final steps = [
      (Icons.category_outlined, t.onbStep1Title, t.onbStep1Body),
      (Icons.tune, t.onbStep2Title, t.onbStep2Body),
      (Icons.fact_check_outlined, t.onbStep3Title, t.onbStep3Body),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(t.appTitle, style: context.text.titleLarge?.copyWith(letterSpacing: 1.5)),
        actions: [
          TextButton(
            onPressed: () => ref.read(settingsProvider.notifier).update((x) => x.copyWith(locale: s.locale == 'es' ? 'en' : 'es')),
            child: Text(s.locale == 'es' ? 'English' : 'Español'),
          ),
        ],
      ),
      body: PageBody(maxWidth: 560, children: [
        const Gap(FlSpace.l),
        if (step == 0) ...[
          Center(child: Image.asset('assets/logo.png', height: 200, semanticLabel: 'FERROLAB')),
          const Gap(FlSpace.xl),
          Text(t.welcomeHeadline, style: context.text.displaySmall),
          const Gap(FlSpace.m),
          Text(t.welcomeBody, style: context.text.bodyLarge),
          const Gap(FlSpace.xl),
          FilledButton(onPressed: () => setState(() => step = 1), child: Text(t.welcomeStart)),
        ] else ...[
          Icon(steps[step - 1].$1, size: 56, color: context.fl.textSecondary),
          const Gap(FlSpace.l),
          Text(steps[step - 1].$2, style: context.text.headlineSmall),
          const Gap(FlSpace.m),
          Text(steps[step - 1].$3, style: context.text.bodyLarge),
          const Gap(FlSpace.xl),
          Row(children: [
            for (var i = 1; i <= 3; i++)
              Container(
                margin: const EdgeInsets.only(right: 6),
                width: i == step ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == step ? FlColors.yellowGreen : context.fl.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ]),
          const Gap(FlSpace.xl),
          FilledButton(onPressed: step < 3 ? () => setState(() => step++) : _finish,
              child: Text(step < 3 ? t.next : t.homeStart)),
        ],
        const Gap(FlSpace.s),
        TextButton(onPressed: _finish, child: Text(t.welcomeSkip)),
        const Gap(FlSpace.l),
        Text(t.welcomeFree, textAlign: TextAlign.center, style: context.text.bodySmall),
      ]),
    );
  }
}
