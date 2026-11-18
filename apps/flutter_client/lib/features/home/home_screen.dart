import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n.dart';
import '../../app/providers.dart';
import '../../core/design_system/tokens.dart';
import '../../shared/widgets/widgets.dart';
import '../simulation/furnace_painter.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final health = ref.watch(healthProvider);
    final history = ref.watch(historyProvider);
    final wide = MediaQuery.sizeOf(context).width >= FlLayout.tabletBreakpoint;
    final hero = Card(
      color: context.fl.accentSoft.withValues(alpha: .55),
      child: Padding(
        padding: const EdgeInsets.all(FlSpace.xl),
        child: Flex(
          direction: wide ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: wide ? 3 : 0,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.homeLabTitle.toUpperCase(), style: context.text.labelLarge?.copyWith(letterSpacing: 1.2)),
                const Gap(FlSpace.s),
                Text(t.homeHero, style: context.text.displaySmall),
                const Gap(FlSpace.m),
                Text(t.homeLabBody, style: context.text.bodyLarge),
                const Gap(FlSpace.l),
                FilledButton.icon(
                  key: const Key('homeStart'),
                  onPressed: () => context.push('/lab/material'),
                  icon: const Icon(Icons.local_fire_department_outlined),
                  label: Text(t.homeStart),
                ),
              ]),
            ),
            if (wide) const Gap(FlSpace.xl) else const Gap(FlSpace.l),
            SizedBox(
              width: wide ? 300 : double.infinity,
              height: 190,
              child: CustomPaint(painter: FurnacePainter.idle(Theme.of(context).brightness)),
            ),
          ],
        ),
      ),
    );
    final tiles = [
      (Icons.menu_book_outlined, t.homeLearn, '/learn'),
      (Icons.biotech_outlined, t.homeMicro, '/micrographs'),
      (Icons.quiz_outlined, t.homePractice, '/practice'),
      (Icons.history, t.homeHistory, '/history'),
      (Icons.co_present_outlined, t.homeTeacher, '/teacher'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(t.appTitle, style: context.text.titleLarge?.copyWith(letterSpacing: 2, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(tooltip: t.settings, onPressed: () => context.push('/settings'), icon: const Icon(Icons.settings_outlined)),
        ],
      ),
      body: PageBody(children: [
        Text(t.homeGreeting, style: context.text.titleMedium?.copyWith(color: context.fl.textSecondary)),
        const Gap(FlSpace.m),
        if (health.value?.unreviewed ?? false) ...[const UnreviewedBanner(), const Gap(FlSpace.m)],
        if (health.hasError) ...[ErrorView(error: health.error!, onRetry: () => ref.invalidate(healthProvider)), const Gap(FlSpace.m)],
        hero,
        const Gap(FlSpace.l),
        LayoutBuilder(builder: (context, c) {
          final cols = c.maxWidth > 900 ? 5 : (c.maxWidth > 560 ? 3 : 2);
          final w = (c.maxWidth - FlSpace.m * (cols - 1)) / cols;
          return Wrap(spacing: FlSpace.m, runSpacing: FlSpace.m, children: [
            for (final (icon, label, path) in tiles)
              SizedBox(
                width: w,
                child: Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(FlRadius.card),
                    onTap: () => context.push(path),
                    child: Padding(
                      padding: const EdgeInsets.all(FlSpace.l),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Icon(icon, size: 28),
                        const Gap(FlSpace.m),
                        Text(label, style: context.text.titleMedium),
                      ]),
                    ),
                  ),
                ),
              ),
          ]);
        }),
        if (history.isNotEmpty) ...[
          const Gap(FlSpace.l),
          SectionCard(
            title: t.homeLastSession,
            icon: Icons.history,
            child: Text('${history.first.result.materialName} · ${history.first.result.input.treatmentId} · '
                '${fmtNum(history.first.result.input.targetTemperatureC)} °C · ${t.status(history.first.result.status)}'),
          ),
        ],
        const Gap(FlSpace.l),
        Notice(t.homeBanner, kind: 'info', icon: Icons.school_outlined),
      ]),
    );
  }
}
