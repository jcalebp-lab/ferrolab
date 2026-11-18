import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n.dart';
import '../../app/providers.dart';
import '../../core/design_system/tokens.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';

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
                      onTap: () => ref.read(simulationProvider.notifier).selectTreatment(tr.id),
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
class ParamsStepScreen extends ConsumerStatefulWidget {
  const ParamsStepScreen({super.key});
  @override
  ConsumerState<ParamsStepScreen> createState() => _ParamsStepScreenState();
}

class _ParamsStepScreenState extends ConsumerState<ParamsStepScreen> {
  late final TextEditingController _temp;
  late final TextEditingController _hold;
  String? _tempErr, _holdErr;

  @override
  void initState() {
    super.initState();
    final s = ref.read(simulationProvider);
    _temp = TextEditingController(text: fmtNum(s.temperatureC));
    _hold = TextEditingController(text: fmtNum(s.holdMin));
  }

  @override
  void dispose() {
    _temp.dispose();
    _hold.dispose();
    super.dispose();
  }

  void _setTemp(double v, InterfaceConventions ui, {bool fromField = false}) {
    if (!fromField) _temp.text = fmtNum(v);
    setState(() => _tempErr = (v < ui.furnaceMinC || v > ui.furnaceMaxC) ? context.t.paramsOutOfUi : null);
    if (_tempErr == null) ref.read(simulationProvider.notifier).setTemperature(v);
  }

  void _setHold(double v, InterfaceConventions ui, {bool fromField = false}) {
    if (!fromField) _hold.text = fmtNum(v);
    setState(() => _holdErr = (v < 0 || v > ui.holdMaxMin) ? context.t.paramsOutOfUi : null);
    if (_holdErr == null) ref.read(simulationProvider.notifier).setHold(v);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final sim = ref.watch(simulationProvider);
    if (!sim.configured) return const _Restart();
    final pairs = ref.watch(pairsProvider(sim.materialId!));
    return _WizardScaffold(
      title: t.homeLabTitle,
      bottom: FilledButton(
        onPressed: _tempErr != null || _holdErr != null
            ? null
            : () {
                ref.read(simulationProvider.notifier).validate();
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
            final dom = pair.temperatureDomain;
            final holdLabel = pair.protocol?.stages.where((s) => s.userHold).firstOrNull?.label;
            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(t.paramsYouControl, style: context.text.titleMedium),
              const Gap(FlSpace.s),
              SectionCard(
                title: t.paramsTemperature,
                icon: Icons.thermostat,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(
                      child: Semantics(
                        label: t.paramsTemperature,
                        value: '${fmtNum(sim.temperatureC)} °C',
                        child: Slider(
                          min: ui.furnaceMinC,
                          max: ui.furnaceMaxC,
                          divisions: ((ui.furnaceMaxC - ui.furnaceMinC) / 5).round(),
                          value: sim.temperatureC.clamp(ui.furnaceMinC, ui.furnaceMaxC),
                          label: '${fmtNum(sim.temperatureC)} °C',
                          onChanged: (v) => _setTemp(v.roundToDouble(), ui),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 112,
                      child: TextField(
                        key: const Key('tempField'),
                        controller: _temp,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                        decoration: InputDecoration(labelText: t.reviewTemperature, suffixText: '°C', errorText: _tempErr, isDense: true),
                        onChanged: (s) {
                          final v = double.tryParse(s);
                          if (v == null) {
                            setState(() => _tempErr = t.paramsInvalidNumber);
                          } else {
                            _setTemp(v, ui, fromField: true);
                          }
                        },
                      ),
                    ),
                  ]),
                  Text(t.paramsFurnaceRange(fmtNum(ui.furnaceMinC), fmtNum(ui.furnaceMaxC)), style: context.text.bodySmall),
                  const Gap(FlSpace.s),
                  Tooltip(
                    message: t.paramsRangeTooltip,
                    child: Notice(
                      dom.usable
                          ? '${t.paramsThermalLimit}: ${fmtNum(dom.min!)}–${fmtNum(dom.max!)} °C'
                          : t.paramsRangeUnpublished,
                      kind: dom.usable ? 'info' : 'limitation',
                    ),
                  ),
                  if (pair.physicalLimitC != null) ...[
                    const Gap(FlSpace.s),
                    Text(t.paramsPhysicalLimit(fmtNum(pair.physicalLimitC!)), style: context.text.bodySmall),
                  ],
                ]),
              ),
              const Gap(FlSpace.m),
              SectionCard(
                title: t.paramsHold,
                icon: Icons.timer_outlined,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    SizedBox(
                      width: 140,
                      child: TextField(
                        key: const Key('holdField'),
                        controller: _hold,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                        decoration: InputDecoration(labelText: t.reviewTime, suffixText: t.paramsMinutes, errorText: _holdErr, isDense: true),
                        onChanged: (s) {
                          final v = double.tryParse(s);
                          if (v == null) {
                            setState(() => _holdErr = t.paramsInvalidNumber);
                          } else {
                            _setHold(v, ui, fromField: true);
                          }
                        },
                      ),
                    ),
                    const Gap(FlSpace.m),
                    for (final d in const [-5.0, 5.0])
                      IconButton(
                        tooltip: '${d > 0 ? '+' : ''}${fmtNum(d)} ${t.paramsMinutes}',
                        onPressed: () => _setHold((sim.holdMin + d).clamp(0, ui.holdMaxMin).toDouble(), ui),
                        icon: Icon(d > 0 ? Icons.add_circle_outline : Icons.remove_circle_outline),
                      ),
                  ]),
                  if (holdLabel != null) ...[const Gap(FlSpace.s), Text(t.paramsHoldStage(holdLabel))],
                  if (!pair.holdDomain.usable) ...[const Gap(FlSpace.s), Notice(t.paramsRangeUnpublished, kind: 'limitation')],
                ]),
              ),
              const Gap(FlSpace.xl),
              Text(t.paramsProtocolDefines, style: context.text.titleMedium),
              const Gap(FlSpace.s),
              _ProtocolCard(pair: pair),
            ]);
          },
        ),
      ],
    );
  }
}

class _ProtocolCard extends StatelessWidget {
  const _ProtocolCard({required this.pair});
  final PairDto pair;
  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = pair.protocol;
    return SectionCard(
      title: t.protocolLocked,
      icon: Icons.lock_outline,
      color: context.fl.accentSoft.withValues(alpha: .35),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t.protocolLockedWhy, style: context.text.bodySmall),
        const Gap(FlSpace.m),
        if (p == null)
          Notice(t.protocolPending, kind: 'limitation')
        else ...[
          KeyValue(t.protocolMedium, p.medium),
          for (final (i, s) in p.stages.indexed) Text('${i + 1}. ${s.label}${s.userHold ? '  ←' : ''}'),
          if (p.reviewStatus != 'published') ...[const Gap(FlSpace.s), Notice(t.protocolPending, kind: 'limitation')],
        ],
      ]),
    );
  }
}

// =================================================================== 4. Revisión
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
            KeyValue(t.reviewInitial, m?.initialConditions.firstOrNull?.name ?? '—'),
            KeyValue(t.reviewCooling, '${t.reviewAutomatic} 🔒 · ${pair?.protocol?.medium ?? '—'}'),
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
          if (canRun && !v.quantitativeEligible) ...[Notice(t.reviewExpectInsufficient, kind: 'limitation'), const Gap(FlSpace.s)],
          for (final w in v.warnings.where((w) => w.severity != 'info'))
            Padding(
              padding: const EdgeInsets.only(bottom: FlSpace.s),
              child: Notice(w.message, kind: w.blocking ? 'warning' : 'limitation'),
            ),
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
