import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n.dart';
import '../../app/providers.dart';
import '../../core/design_system/tokens.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';
import '../ai_tutor/tutor_sheet.dart';
import '../simulation/playback.dart';
import '../simulation/thermal_chart.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key, this.fromHistory});
  final SimulationResultDto? fromHistory; // para ver un resultado del historial
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final r = fromHistory ?? ref.watch(simulationProvider).result;
    if (r == null) {
      return Scaffold(appBar: AppBar(), body: Center(
        child: FilledButton(onPressed: () => context.go('/lab/material'), child: Text(t.homeStart))));
    }
    return Scaffold(
      appBar: AppBar(title: Text(t.resultsTitle), actions: [
        IconButton(tooltip: t.homeHistory, onPressed: () => context.push('/history'), icon: const Icon(Icons.history)),
      ]),
      body: ResultsBody(result: r),
    );
  }
}

class ResultsBody extends ConsumerWidget {
  const ResultsBody({super.key, required this.result});
  final SimulationResultDto result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final r = result;
    final pb = Playback.from(r);
    final q = {for (final x in r.quantities) x.code: x};
    final wide = MediaQuery.sizeOf(context).width >= FlLayout.tabletBreakpoint;
    Widget twoCol(List<Widget> items) => wide
        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (final (i, w) in items.indexed) ...[if (i > 0) const Gap(FlSpace.m), Expanded(child: w)],
          ])
        : Column(children: [for (final (i, w) in items.indexed) ...[if (i > 0) const Gap(FlSpace.m), w]]);

    return PageBody(children: [
      // Encabezado: estado científico (no confundir con error de servidor).
      _StatusHeader(r: r),
      const Gap(FlSpace.l),
      SectionCard(
        title: t.resultsSummary,
        icon: Icons.summarize_outlined,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${r.materialName} · ${fmtNum(r.input.targetTemperatureC)} °C · ${fmtNum(r.input.holdTimeMin)} min',
              style: context.text.titleMedium),
          const Gap(FlSpace.s),
          Text(r.explanation.treatmentPurpose),
          const Gap(FlSpace.s),
          Text(r.explanation.qualitativeOutcome, style: context.text.bodyMedium),
          const Gap(FlSpace.s),
          Pill(icon: Icons.lightbulb_outline, label: t.evidence_qualitative, background: context.fl.evidenceLimitedBg),
        ]),
      ),
      const Gap(FlSpace.m),
      if (pb != null)
        SectionCard(title: t.resultsHistory, icon: Icons.show_chart, child: ThermalChart(result: r, playback: pb)),
      const Gap(FlSpace.m),
      SectionCard(
        title: t.resultsTransformations,
        icon: Icons.blur_on,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(t.resultsTransformationsNote, style: context.text.bodySmall),
          const Gap(FlSpace.m),
          twoCol([
            ResultFactCard(q: q[QuantityCode.phaseFractions]!),
            ResultFactCard(q: q[QuantityCode.microconstituentFractions]!),
          ]),
        ]),
      ),
      const Gap(FlSpace.m),
      SectionCard(
        title: t.resultsProperties,
        icon: Icons.construction_outlined,
        child: Column(children: [
          ResultFactCard(q: q[QuantityCode.hardness]!),
          const Gap(FlSpace.m),
          twoCol([
            ResultFactCard(q: q[QuantityCode.grainSize]!),
            ResultFactCard(q: q[QuantityCode.mechanicalProperties]!),
          ]),
        ]),
      ),
      const Gap(FlSpace.m),
      SectionCard(
        title: t.resultsMicroscope,
        icon: Icons.biotech_outlined,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (r.micrograph == null)
            Notice(t.microNoMatch, kind: 'limitation', icon: Icons.image_not_supported_outlined)
          else
            Text('${r.micrograph!.attribution} · ${r.micrograph!.licenseCode}'),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => context.push('/lab/microscope'),
              icon: const Icon(Icons.search),
              label: Text(t.resultsMicroscope),
            ),
          ),
        ]),
      ),
      const Gap(FlSpace.m),
      _Foundation(r: r),
      const Gap(FlSpace.m),
      _KeepLearning(r: r),
      const Gap(FlSpace.l),
      Notice(t.resultsEducationalBanner, kind: 'info', icon: Icons.school_outlined),
    ]);
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.r});
  final SimulationResultDto r;
  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final level = switch (r.status) {
      SimulationStatus.completed => EvidenceLevel.validated,
      SimulationStatus.partialResult => EvidenceLevel.boundedEstimate,
      SimulationStatus.insufficientEvidence => EvidenceLevel.insufficientEvidence,
      _ => EvidenceLevel.unsupported,
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: FlSpace.s, runSpacing: FlSpace.s, children: [
        Pill(icon: Icons.science_outlined, label: t.status(r.status), background: switch (level) {
          EvidenceLevel.unsupported => context.fl.warningBg,
          EvidenceLevel.validated || EvidenceLevel.boundedEstimate => context.fl.evidenceValidatedBg,
          _ => context.fl.evidenceLimitedBg,
        }),
        CompatBadge(r.compatibility),
      ]),
      const Gap(FlSpace.m),
      if (r.status == SimulationStatus.insufficientEvidence) ...[
        Text(t.statusInsufficientBody, style: context.text.bodyLarge),
        const Gap(FlSpace.s),
      ],
      Text(r.explanation.compatibilityReason, style: context.text.bodyMedium),
      for (final w in r.warnings.where((w) => w.blocking)) ...[const Gap(FlSpace.s), Notice(w.message, kind: 'warning')],
      if (r.unreviewed) ...[const Gap(FlSpace.m), const UnreviewedBanner()],
    ]);
  }
}

/// Tarjeta de resultado científico (doc 08 §5.5). Ausencia = «—» + explicación; nunca 0.
class ResultFactCard extends StatelessWidget {
  const ResultFactCard({super.key, required this.q});
  final QuantityResult q;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final title = t.quantity(q.code).toUpperCase();
    return Container(
      key: Key('fact_${q.code.wire}'),
      padding: const EdgeInsets.all(FlSpace.l),
      decoration: BoxDecoration(
        color: q.available ? context.fl.evidenceValidatedBg.withValues(alpha: .4) : context.fl.surface,
        borderRadius: BorderRadius.circular(FlRadius.input),
        border: Border.all(color: context.fl.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(title, style: context.text.labelLarge?.copyWith(letterSpacing: .8))),
          IconButton(
            tooltip: t.resultsWhatsMissing,
            visualDensity: VisualDensity.compact,
            onPressed: () => _explain(context),
            icon: const Icon(Icons.help_outline, size: 20),
          ),
        ]),
        if (!q.available) ...[
          Semantics(
            label: '$title: ${t.resultsUnavailable}',
            child: Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
              Text('—', style: context.text.headlineSmall),
              const Gap(FlSpace.s),
              Expanded(child: Text(t.resultsUnavailable, style: context.text.bodyMedium)),
            ]),
          ),
          if (q.reason != t.resultsUnavailable) ...[
            const Gap(FlSpace.xs),
            Text(q.reason, style: context.text.bodySmall),
          ],
          const Gap(FlSpace.s),
          EvidenceBadge(q.level),
        ] else ...[
          if (q.single != null) _fact(context, null, q.single!),
          if (q.group != null) for (final e in q.group!.entries) _fact(context, e.key, e.value),
        ],
      ]),
    );
  }

  Widget _fact(BuildContext context, String? key, ResultFact f) {
    final t = context.t;
    final value = f.unit == 'fraction' ? '${(f.value * 100).toStringAsFixed(1)} %' : '${fmtNum(f.value)} ${f.unit}';
    return Padding(
      padding: const EdgeInsets.only(bottom: FlSpace.s),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(key == null ? value : '$key: $value', style: context.text.headlineSmall),
        if (f.uncertainty != null) Text('± ${f.uncertainty}', style: context.text.bodySmall),
        Wrap(spacing: FlSpace.s, runSpacing: FlSpace.xs, children: [
          EvidenceBadge(f.evidenceLevel),
          Pill(icon: Icons.source_outlined, label: t.kind(f.evidenceKind), background: context.fl.accentSoft),
        ]),
        Text('${f.method}${f.fractionBasis != null ? ' · ${f.fractionBasis}' : ''} · ${f.sourceIds.join(', ')}'
            '${f.modelVersion != null ? ' · ${f.modelVersion}' : ''}', style: context.text.bodySmall),
      ]),
    );
  }

  void _explain(BuildContext context) {
    final t = context.t;
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(t.quantity(q.code)),
        content: Text(q.available ? q.reason : '${q.reason}\n\n${t.resultsWhatsMissingBody}'),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text(t.close))],
      ),
    );
  }
}

class _Foundation extends StatelessWidget {
  const _Foundation({required this.r});
  final SimulationResultDto r;
  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = r.protocol;
    return SectionCard(
      title: t.resultsFoundation,
      icon: Icons.account_tree_outlined,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ExpansionTile(
          initiallyExpanded: true,
          tilePadding: EdgeInsets.zero,
          title: Text(t.resultsWarnings),
          children: [
            for (final w in r.warnings)
              Padding(
                padding: const EdgeInsets.only(bottom: FlSpace.s),
                child: Notice(w.message, kind: w.blocking ? 'warning' : (w.severity == 'info' ? 'info' : 'limitation')),
              ),
          ],
        ),
        if (p != null)
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(t.resultsProtocol),
            children: [
              KeyValue(t.protocolMedium, p.medium),
              KeyValue('ID', '${p.id} · ${p.version} · ${p.reviewStatus}'),
              for (final s in p.stages)
                KeyValue('${s.ordinal}', '${s.label} · ${s.endTemperatureC != null ? '${fmtNum(s.endTemperatureC!)} °C' : s.endTemperatureBasis}'
                    ' · ${s.durationS != null ? fmtDuration(s.durationS!) : s.durationBasis}'),
            ],
          ),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(t.resultsAssumptions),
          children: [for (final a in r.assumptions) Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('• $a'))],
        ),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(t.resultsSources),
          children: [
            for (final s in r.evidence) ...[
              Text(switch (s.usage) {
                'supports_value' => t.resultsSupportsValue,
                'supports_limit' => t.resultsSupportsLimit,
                _ => t.resultsSuggestedReading,
              }, style: context.text.labelLarge),
              SourceTile(s),
            ],
          ],
        ),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(t.resultsVersions),
          children: [
            KeyValue('dataset_version', r.datasetVersion),
            KeyValue('protocol_version', r.protocolVersion ?? '—'),
            KeyValue('engine_version', r.engineVersion),
            KeyValue('model_version', r.modelVersion ?? '—'),
            KeyValue('request_id', r.requestId ?? '—'),
            KeyValue('request_hash', r.requestHash.substring(0, 16)),
          ],
        ),
      ]),
    );
  }
}

class _KeepLearning extends ConsumerWidget {
  const _KeepLearning({required this.r});
  final SimulationResultDto r;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    return SectionCard(
      title: t.resultsKeepLearning,
      icon: Icons.school_outlined,
      child: Wrap(spacing: FlSpace.s, runSpacing: FlSpace.s, children: [
        FilledButton.icon(
          key: const Key('tutorButton'),
          onPressed: () => showTutorSheet(context, input: r.input),
          icon: const Icon(Icons.help_center_outlined),
          label: Text(t.tutorExplain),
        ),
        OutlinedButton.icon(
          onPressed: () => _whatIf(context, ref),
          icon: const Icon(Icons.alt_route),
          label: Text(t.resultsWhatIf),
        ),
        OutlinedButton.icon(
          onPressed: () {
            ref.read(historyProvider.notifier).save(r);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.resultsSaved)));
          },
          icon: const Icon(Icons.bookmark_add_outlined),
          label: Text(t.resultsSave),
        ),
        OutlinedButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: _summary(context)));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.resultsCopied)));
          },
          icon: const Icon(Icons.copy_all_outlined),
          label: Text(t.resultsCopy),
        ),
        TextButton.icon(
          onPressed: () => context.go('/lab/material'),
          icon: const Icon(Icons.restart_alt),
          label: Text(t.resultsNewRun),
        ),
      ]),
    );
  }

  /// Exportación de texto (FR-24): incluye versiones, advertencias y fuentes.
  String _summary(BuildContext context) {
    final t = context.t;
    final b = StringBuffer()
      ..writeln('FERROLAB — ${t.resultsTitle}')
      ..writeln('${r.materialName} · ${r.input.treatmentId} · ${fmtNum(r.input.targetTemperatureC)} °C · ${fmtNum(r.input.holdTimeMin)} min')
      ..writeln('${t.status(r.status)} · ${t.compat(r.compatibility)}')
      ..writeln('dataset=${r.datasetVersion} protocol=${r.protocolVersion ?? '-'} engine=${r.engineVersion} model=${r.modelVersion ?? '-'}');
    for (final q in r.quantities) {
      b.writeln('${t.quantity(q.code)}: ${q.available ? '(ver app)' : '— ${t.resultsUnavailable}'}');
    }
    b.writeln('\n${t.resultsWarnings}:');
    for (final w in r.warnings) {
      b.writeln('- ${w.message}');
    }
    b.writeln('\n${t.resultsSources}:');
    for (final s in r.evidence) {
      b.writeln('- ${s.title}${s.authors != null ? ' (${s.authors})' : ''} [${s.verificationStatus}]');
    }
    b.writeln('\n${t.resultsEducationalBanner}');
    return b.toString();
  }

  void _whatIf(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final i = r.input;
    final options = <(String, SimulationInput)>[
      for (final d in const [-50.0, 50.0])
        if (i.targetTemperatureC + d >= 20 && i.targetTemperatureC + d <= 1600)
          ('${d > 0 ? '+' : ''}${fmtNum(d)} °C', SimulationInput(materialId: i.materialId, treatmentId: i.treatmentId,
              initialConditionId: i.initialConditionId, targetTemperatureC: i.targetTemperatureC + d, holdTimeMin: i.holdTimeMin)),
      ('${t.paramsHold} ×2', SimulationInput(materialId: i.materialId, treatmentId: i.treatmentId,
          initialConditionId: i.initialConditionId, targetTemperatureC: i.targetTemperatureC, holdTimeMin: i.holdTimeMin * 2)),
      for (final tr in const ['quench', 'temper', 'anneal', 'normalize', 'austemper', 'martemper'])
        if (tr != i.treatmentId)
          (tr, SimulationInput(materialId: i.materialId, treatmentId: tr, initialConditionId: i.initialConditionId,
              targetTemperatureC: i.targetTemperatureC, holdTimeMin: i.holdTimeMin)),
    ];
    final names = {for (final x in ref.read(treatmentsProvider).value ?? <TreatmentDto>[]) x.id: x.name};
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (c) => ListView(padding: const EdgeInsets.all(FlSpace.l), children: [
        Text(t.resultsWhatIf, style: c.text.titleLarge),
        Text(t.resultsWhatIfBody, style: c.text.bodySmall),
        const Gap(FlSpace.m),
        for (final (label, input) in options)
          ListTile(
            leading: const Icon(Icons.compare_arrows),
            title: Text(names[label] ?? label),
            onTap: () async {
              Navigator.pop(c);
              try {
                final other = await ref.read(repositoryProvider).simulate(input, ref.read(localeProvider));
                ref.read(compareProvider.notifier).set(r, other);
                if (context.mounted) context.push('/compare');
              } on Object catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
          ),
      ]),
    );
  }
}
