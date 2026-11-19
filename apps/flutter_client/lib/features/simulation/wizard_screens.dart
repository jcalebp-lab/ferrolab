import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n.dart';
import '../../app/providers.dart';
import '../../core/design_system/tokens.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';
import 'protocol_panels.dart';

class _WizardScaffold extends StatelessWidget {
  const _WizardScaffold({required this.title, required this.children, this.bottom});
  final String title;
  final List<Widget> children;
  final Widget? bottom;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: PageBody(maxWidth: 820, children: children),
        bottomNavigationBar: bottom == null
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(FlSpace.l, FlSpace.s, FlSpace.l, FlSpace.l),
                  child: Center(heightFactor: 1, child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 820), child: bottom)),
                ),
              ),
      );
}

// =================================================================== 1. Material
class MaterialStepScreen extends ConsumerWidget {
  const MaterialStepScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final sim = ref.watch(simulationProvider);
    final mats = ref.watch(materialsProvider);
    return _WizardScaffold(
      title: t.homeLabTitle,
      bottom: FilledButton(
        onPressed: sim.materialId == null ? null : () => context.push('/lab/treatment'),
        child: Text(t.continueLabel),
      ),
      children: [
        StepHeader(step: 1, total: 4, title: t.materialTitle),
        AsyncBody(
          value: mats,
          onRetry: () => ref.invalidate(materialsProvider),
          data: (list) => Column(children: [
            for (final m in list) ...[
              _MaterialCard(m: m, selected: sim.materialId == m.id,
                  onTap: () => ref.read(simulationProvider.notifier).selectMaterial(m.id)),
              const Gap(FlSpace.m),
            ],
          ]),
        ),
      ],
    );
  }
}

class _MaterialCard extends StatelessWidget {
  const _MaterialCard({required this.m, required this.selected, required this.onTap});
  final MaterialDto m;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Semantics(
      selected: selected,
      button: true,
      label: m.displayName,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FlRadius.card),
          side: BorderSide(color: selected ? FlColors.yellowGreen : context.fl.border, width: selected ? 2.5 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(FlRadius.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(FlSpace.l),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: selected ? FlColors.yellowGreen : context.fl.textSecondary),
                const Gap(FlSpace.s),
                Expanded(child: Text(m.displayName, style: context.text.titleLarge)),
                Pill(
                  icon: m.family == MaterialFamily.steel ? Icons.hexagon_outlined : Icons.grain,
                  label: m.family == MaterialFamily.steel ? t.materialSteel : t.materialCastIron,
                  background: context.fl.accentSoft,
                ),
              ]),
              const Gap(FlSpace.s),
              Text(m.description, style: context.text.bodyMedium),
              const Gap(FlSpace.s),
              for (final l in m.limitations.take(1)) Notice(l, kind: 'limitation'),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _showSheet(context),
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: Text(t.materialViewSheet),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void _showSheet(BuildContext context) {
    final t = context.t;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (c) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .75,
        builder: (c, scroll) => ListView(controller: scroll, padding: const EdgeInsets.all(FlSpace.xl), children: [
          Text(m.displayName, style: c.text.headlineSmall),
          const Gap(FlSpace.s),
          Text(m.standardNote, style: c.text.bodySmall),
          const Gap(FlSpace.l),
          Text(m.description, style: c.text.bodyLarge),
          const Gap(FlSpace.l),
          if (m.compositions.isEmpty) Notice(t.materialNoComposition, kind: 'limitation'),
          const Gap(FlSpace.l),
          Text(t.materialInitialCondition, style: c.text.titleMedium),
          for (final ic in m.initialConditions) ...[
            const Gap(FlSpace.s),
            Text(ic.name, style: c.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            Text(ic.description, style: c.text.bodyMedium),
          ],
          const Gap(FlSpace.l),
          Text(t.materialLimitations, style: c.text.titleMedium),
          for (final l in m.limitations) Padding(padding: const EdgeInsets.only(top: 6), child: Text('• $l')),
          const Gap(FlSpace.l),
          Text(t.materialSuggestedReading, style: c.text.titleMedium),
          for (final s in m.suggestedSources) SourceTile(s),
        ]),
      ),
    );
  }
}

// =================================================================== 2. Tratamiento
class TreatmentStepScreen extends ConsumerWidget {
  const TreatmentStepScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final sim = ref.watch(simulationProvider);
    if (sim.materialId == null) return const _Restart();
    final trts = ref.watch(treatmentsProvider);
    final pairs = ref.watch(pairsProvider(sim.materialId!));
    return _WizardScaffold(
      title: t.homeLabTitle,
      bottom: FilledButton(
        onPressed: sim.treatmentId == null ? null : () => context.push('/lab/params'),
        child: Text(t.continueLabel),
      ),
      children: [
        StepHeader(step: 2, total: 4, title: t.treatmentTitle),
        AsyncBody(
          value: trts,
          onRetry: () => ref.invalidate(treatmentsProvider),
          data: (list) => AsyncBody(
            value: pairs,
            onRetry: () => ref.invalidate(pairsProvider(sim.materialId!)),
            data: (ps) => LayoutBuilder(builder: (context, c) {
              final cols = c.maxWidth > 620 ? 2 : 1;
              final w = (c.maxWidth - FlSpace.m * (cols - 1)) / cols;
              return Wrap(spacing: FlSpace.m, runSpacing: FlSpace.m, children: [
                for (final tr in list)
                  SizedBox(
                    width: w,
                    child: _TreatmentCard(
                      tr: tr,
                      pair: ps.byTreatment(tr.id),
                      selected: sim.treatmentId == tr.id,
                      onTap: () {
                        final n = ref.read(simulationProvider.notifier)..selectTreatment(tr.id);
                        // Carga el protocolo de referencia documentado (temperaturas, tiempos y baño).
                        final ref0 = ps.byTreatment(tr.id)?.referenceProtocol;
                        if (ref0 != null) n.applyProtocol(ref0);
                      },
                    ),
                  ),
              ]);
            }),
          ),
        ),
      ],
    );
  }
}

class _TreatmentCard extends StatelessWidget {
  const _TreatmentCard({required this.tr, required this.pair, required this.selected, required this.onTap});
  final TreatmentDto tr;
  final PairDto? pair;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final unsupported = pair == null || pair!.compatibility == CompatibilityStatus.unsupported;
    return Semantics(
      selected: selected,
      button: true,
      label: '${tr.name}. ${t.compat(pair?.compatibility)}',
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FlRadius.card),
          side: BorderSide(color: selected ? FlColors.yellowGreen : context.fl.border, width: selected ? 2.5 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(FlRadius.card),
          // Una combinación no soportada no desaparece: se puede leer por qué, pero no simular.
          onTap: unsupported ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.all(FlSpace.l),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(tr.name, style: context.text.titleMedium)),
                if (selected) const Icon(Icons.check_circle, color: FlColors.yellowGreen),
              ]),
              const Gap(FlSpace.s),
              CompatBadge(pair?.compatibility),
              const Gap(FlSpace.s),
              Text(tr.purpose, style: context.text.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
              TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: Text(tr.name),
                    content: SingleChildScrollView(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                        CompatBadge(pair?.compatibility),
                        const Gap(FlSpace.s),
                        Text(pair?.reason ?? '', style: c.text.bodyMedium),
                        const Gap(FlSpace.l),
                        Text(t.treatmentPrerequisites, style: c.text.titleMedium),
                        Text(tr.prerequisites),
                        const Gap(FlSpace.l),
                        Text(t.treatmentStages, style: c.text.titleMedium),
                        for (final (i, s) in tr.stages.indexed) Text('${i + 1}. ${s.label}'),
                        const Gap(FlSpace.l),
                        Text(tr.qualitativeOutcome, style: c.text.bodyMedium),
                      ]),
                    ),
                    actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text(t.close))],
                  ),
                ),
                child: Text(t.treatmentWhyNot),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// =================================================================== 3. Parámetros
class ParamsStepScreen extends ConsumerWidget {
  const ParamsStepScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final sim = ref.watch(simulationProvider);
    if (!sim.configured) return const _Restart();
    final pairs = ref.watch(pairsProvider(sim.materialId!));
    final mats = ref.watch(materialsProvider).value ?? const [];
    final trts = ref.watch(treatmentsProvider).value ?? const [];
    final n = ref.read(simulationProvider.notifier);
    return _WizardScaffold(
      title: t.homeLabTitle,
      bottom: FilledButton(
        onPressed: () {
          n.validate();
          context.push('/lab/review');
        },
        child: Text(t.paramsReview),
      ),
      children: [
        StepHeader(step: 3, total: 4, title: t.paramsTitle),
        AsyncBody(
          value: pairs,
          onRetry: () => ref.invalidate(pairsProvider(sim.materialId!)),
          data: (ps) {
            final pair = ps.byTreatment(sim.treatmentId!)!;
            final ui = ps.interface;
            final m = mats.where((x) => x.id == sim.materialId).firstOrNull;
            final tr = trts.where((x) => x.id == sim.treatmentId).firstOrNull;
            final proto = pair.protocolById(sim.protocolId);
            if (proto == null) {
              return Notice(t.paramsRangeUnpublished, kind: 'limitation');
            }
            final pf = proto.param('furnace_temperature');
            final ph = proto.param('hold_time');
            final pb = proto.param('bath_temperature');
            final pbt = proto.param('bath_time');
            final isRef = proto.params.entries.every((e) {
              final v = switch (e.key) {
                'furnace_temperature' => sim.temperatureC,
                'hold_time' => sim.holdMin,
                'bath_temperature' => sim.bathTemperatureC,
                _ => sim.bathTimeMin,
              };
              return e.value.ref == null || v == e.value.ref;
            });
            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // ----------------------------------------------------- material y tratamiento
              SectionCard(
                title: t.lpMaterialPanel,
                icon: Icons.category_outlined,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(m?.displayName ?? sim.materialId!, style: context.text.titleMedium),
                  const Gap(FlSpace.xs),
                  Text(t.lpComposition, style: context.text.labelLarge),
                  Text(
                    (m?.compositions.isEmpty ?? true)
                        ? t.lpCompositionNone
                        : m!.compositions.map((c) => '${c['element']} ${(c['min_wt_pct'] as num).toStringAsFixed(2)}'
                            '–${(c['max_wt_pct'] as num).toStringAsFixed(2)}').join(' · '),
                    style: context.text.bodySmall),
                  if (proto.materialCondition != null) KeyValue(t.lpCondition, proto.materialCondition!),
                ]),
              ),
              const Gap(FlSpace.m),
              SectionCard(
                title: t.lpTreatmentPanel,
                icon: Icons.local_fire_department_outlined,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(tr?.name ?? sim.treatmentId!, style: context.text.titleMedium),
                  if (proto.objective != null) Text(proto.objective!, style: context.text.bodyMedium),
                  const Gap(FlSpace.s),
                  Wrap(spacing: FlSpace.s, runSpacing: FlSpace.s, children: [
                    CompatBadge(pair.compatibility),
                    LevelBadge(pair.resultLevel),
                  ]),
                  if (pair.headline != null) ...[const Gap(FlSpace.s), HeadlineNotice(pair.headline!)],
                ]),
              ),
              const Gap(FlSpace.m),
              // ----------------------------------------------------- protocolo
              SectionCard(
                key: const Key('protocolsCard'),
                title: t.lpProtocols,
                icon: Icons.library_books_outlined,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  ProtocolPicker(protocols: pair.protocols, selectedId: proto.id, onSelect: n.applyProtocol),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.tonalIcon(
                      key: const Key('useRecommended'),
                      onPressed: isRef && proto.isReference ? null : () => n.applyProtocol(pair.referenceProtocol ?? proto),
                      icon: const Icon(Icons.auto_fix_high),
                      label: Text(t.lpUseProtocol),
                    ),
                  ),
                ]),
              ),
              const Gap(FlSpace.m),
              if (sim.treatmentId == 'temper') ...[
                SectionCard(title: t.lpPrior, icon: Icons.history_edu, child: PriorStatePanel(materialId: sim.materialId!)),
                const Gap(FlSpace.m),
              ],
              // ----------------------------------------------------- parámetros
              SectionCard(
                title: t.lpParams,
                icon: Icons.tune,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(t.paramsYouControl, style: context.text.bodySmall),
                  const Gap(FlSpace.m),
                  if (pf != null)
                    ParamField(fieldKey: 'tempField', label: t.pFurnace, icon: Icons.thermostat, param: pf,
                        value: sim.temperatureC, unit: '°C', uiMin: ui.furnaceMinC, uiMax: ui.furnaceMaxC,
                        onChanged: (v) => n.setTemperature(v ?? sim.temperatureC)),
                  if (ph != null) ...[
                    const Gap(FlSpace.l),
                    ParamField(fieldKey: 'holdField', label: t.pHold, icon: Icons.timer_outlined, param: ph,
                        value: sim.holdMin, unit: t.paramsMinutes, uiMax: ui.holdMaxMin,
                        onChanged: (v) => n.setHold(v ?? 0)),
                  ],
                  if (pb != null) ...[
                    const Gap(FlSpace.l),
                    ParamField(fieldKey: 'bathField', label: t.pBath, icon: Icons.hot_tub_outlined, param: pb,
                        value: sim.bathTemperatureC ?? pb.ref, unit: '°C', uiMax: ui.furnaceMaxC,
                        onChanged: (v) => n.setBathTemperature(v ?? pb.ref ?? 0)),
                  ],
                  if (pbt != null) ...[
                    const Gap(FlSpace.l),
                    ParamField(fieldKey: 'bathTimeField', label: t.pBathTime, icon: Icons.hourglass_bottom, param: pbt,
                        value: sim.bathTimeMin, unit: t.paramsMinutes, uiMax: ui.holdMaxMin, allowEmpty: true,
                        emptyLabel: t.pBathEqualize, onChanged: n.setBathTime),
                  ],
                  const Gap(FlSpace.l),
                  KeyValue(t.pMediumLocked, '${proto.medium} 🔒'),
                  if (pair.physicalLimitC != null)
                    Text(t.paramsPhysicalLimit(fmtNum(pair.physicalLimitC!)), style: context.text.bodySmall),
                ]),
              ),
              const Gap(FlSpace.m),
              SectionCard(
                key: const Key('sequenceCard'),
                title: t.lpSequence,
                icon: Icons.timeline,
                child: ThermalSequence(protocol: proto, sim: sim),
              ),
              const Gap(FlSpace.m),
              ProtocolSheet(p: proto),
            ]);
          },
        ),
      ],
    );
  }
}


class ReviewStepScreen extends ConsumerWidget {
  const ReviewStepScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final sim = ref.watch(simulationProvider);
    if (!sim.configured) return const _Restart();
    final mats = ref.watch(materialsProvider).value ?? const [];
    final trts = ref.watch(treatmentsProvider).value ?? const [];
    final pair = ref.watch(pairsProvider(sim.materialId!)).value?.byTreatment(sim.treatmentId!);
    final m = mats.where((x) => x.id == sim.materialId).firstOrNull;
    final tr = trts.where((x) => x.id == sim.treatmentId).firstOrNull;
    final v = sim.validation;
    final canRun = v?.canRun ?? false;
    return _WizardScaffold(
      title: t.homeLabTitle,
      bottom: Row(children: [
        Expanded(child: OutlinedButton(onPressed: () => context.pop(), child: Text(t.reviewEdit))),
        const Gap(FlSpace.m),
        Expanded(
          flex: 2,
          child: FilledButton(
            key: const Key('startLab'),
            onPressed: canRun && sim.phase == SimPhase.ready
                ? () {
                    ref.read(simulationProvider.notifier).run();
                    context.push('/lab/furnace');
                  }
                : null,
            child: Text(t.reviewStart),
          ),
        ),
      ]),
      children: [
        StepHeader(step: 4, total: 4, title: t.reviewTitle),
        SectionCard(
          child: Column(children: [
            KeyValue(t.reviewMaterial, m?.displayName ?? sim.materialId!),
            KeyValue(t.reviewTreatment, tr?.name ?? sim.treatmentId!, trailing: CompatBadge(pair?.compatibility)),
            KeyValue(t.reviewTemperature, '${fmtNum(sim.temperatureC)} °C'),
            KeyValue(t.reviewTime, '${fmtNum(sim.holdMin)} ${t.paramsMinutes}'),
            if (sim.bathTemperatureC != null) KeyValue(t.pBath, '${fmtNum(sim.bathTemperatureC!)} °C'),
            if (sim.bathTimeMin != null) KeyValue(t.pBathTime, '${fmtNum(sim.bathTimeMin!)} ${t.paramsMinutes}'),
            KeyValue(t.reviewInitial, m?.initialConditions.where((c) => c.id == v?.initialConditionId).firstOrNull?.name
                ?? m?.initialConditions.firstOrNull?.name ?? '—'),
            KeyValue(t.reviewCooling, '${t.reviewAutomatic} 🔒 · ${v?.protocol?.medium ?? '—'}'),
            if (v?.protocol != null) KeyValue(t.lpProtocol, v!.protocol!.name),
          ]),
        ),
        const Gap(FlSpace.l),
        if (sim.phase == SimPhase.validating)
          Row(children: [const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            const Gap(FlSpace.m), Text(t.validating)]),
        if (sim.phase == SimPhase.networkError || sim.phase == SimPhase.apiError)
          ErrorView(error: sim.error!, onRetry: () => ref.read(simulationProvider.notifier).validate()),
        if (v != null) ...[
          Text(canRun ? t.reviewHeadsUp : t.reviewBlocked, style: context.text.titleMedium),
          const Gap(FlSpace.s),
          if (v.headline != null) ...[HeadlineNotice(v.headline!), const Gap(FlSpace.s)],
          Wrap(children: [LevelBadge(v.resultLevel)]),
          const Gap(FlSpace.s),
          if (canRun && v.resultLevel == 'A')
            ...[Notice(t.reviewExpectModel, kind: 'info', icon: Icons.functions), const Gap(FlSpace.s)]
          else if (canRun)
            ...[Notice(t.reviewExpectInsufficient, kind: 'limitation'), const Gap(FlSpace.s)],
          LimitationsPanel(warnings: v.warnings),
        ],
      ],
    );
  }
}

class _Restart extends StatelessWidget {
  const _Restart();
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: FilledButton(onPressed: () => context.go('/lab/material'), child: Text(context.t.homeStart)),
        ),
      );
}
