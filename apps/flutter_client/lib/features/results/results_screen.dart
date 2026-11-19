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
import '../microscope/microstructure_view.dart';
import '../simulation/thermal_chart.dart';
import 'diagrams.dart';
import '../simulation/protocol_panels.dart';

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
          Text(r.protocolCard?.expected ?? r.explanation.qualitativeOutcome, style: context.text.bodyMedium),
          if (r.protocolCard != null) ...[
            const Gap(FlSpace.s),
            Text('${t.lpProtocol}: ${r.protocolCard!.name}', style: context.text.bodySmall),
          ],
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
      if (r.illustration != null) ...[
        SectionCard(
          key: const Key('generatedMicroCard'),
          title: t.microGeneratedTitle,
          icon: Icons.biotech_outlined,
          child: _GeneratedMicroSummary(spec: r.illustration!),
        ),
        const Gap(FlSpace.m),
      ],
      if (r.diagrams.isNotEmpty) ...[
        SectionCard(
          key: const Key('diagramsCard'),
          title: t.diagTitle,
          icon: Icons.stacked_line_chart,
          child: TransformationDiagrams(diagrams: r.diagrams),
        ),
        const Gap(FlSpace.m),
      ],
      if (r.modelEstimate != null && r.modelEstimate!['critical_temperatures_c'] != null) ...[
        _ModelDetails(est: r.modelEstimate!),
        const Gap(FlSpace.m),
      ],
      SectionCard(
        title: t.microRealTitle,
        icon: Icons.photo_library_outlined,
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
      if (r.headline != null) ...[HeadlineNotice(r.headline!), const Gap(FlSpace.s)],
      Wrap(spacing: FlSpace.s, runSpacing: FlSpace.s, children: [LevelBadge(r.resultLevel)]),
      const Gap(FlSpace.s),
      Text(r.explanation.compatibilityReason, style: context.text.bodyMedium),
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
            label: '$title: ${q.reason}',
            child: Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
              Text('—', style: context.text.headlineSmall),
              const Gap(FlSpace.s),
              Expanded(child: Text(q.reason, style: context.text.bodyMedium)),
            ]),
          ),
        ] else ...[
          if (q.single != null) _fact(context, null, q.single!),
          if (q.group != null) for (final e in q.group!.entries) _fact(context, e.key, e.value),
        ],
      ]),
    );
  }

  String _label(BuildContext context, String key) {
    final t = context.t;
    return switch (key) {
      'yield_strength' => t.mechYield,
      'tensile_strength' => t.mechTensile,
      'tensile_strength_min' => t.mechTensileMin,
      _ => t.constituent(key),
    };
  }

  Widget _grain(BuildContext context, ResultFact f) {
    final t = context.t;
    final u = f.uncertainty ?? const {};
    String one(Object? v) => (v as num).toStringAsFixed(1);
    final lo = u['min'] as num?, hi = u['max'] as num?;
    final extra = (u['extrapolation'] as List?)?.isNotEmpty ?? false;
    return Padding(
      padding: const EdgeInsets.only(bottom: FlSpace.s),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t.grainAstm(one(f.value)), style: context.text.headlineSmall),
        if (u['austenite_um'] != null) Text(t.grainAustenite(one(u['austenite_um'])), style: context.text.bodyMedium),
        if (u['ferrite_um'] != null)
          Text(t.grainFerrite(one(u['ferrite_um']), one(u['ferrite_g'])), style: context.text.bodyMedium),
        if (lo != null && hi != null && (hi - lo).abs() >= .05)
          Text('${t.factBand}: G ${one(lo)}–${one(hi)}', style: context.text.bodySmall),
        if (extra) Text(t.grainExtrapolated, style: context.text.bodySmall),
        Wrap(spacing: FlSpace.s, runSpacing: FlSpace.xs, children: [
          EvidenceBadge(f.evidenceLevel),
          Pill(icon: Icons.source_outlined, label: t.kind(f.evidenceKind), background: context.fl.accentSoft),
        ]),
        Text('${f.method} · ${f.sourceIds.join(', ')}', style: context.text.bodySmall),
      ]),
    );
  }

  Widget _fact(BuildContext context, String? key, ResultFact f) {
    final t = context.t;
    if (f.unit == 'ASTM_G') return _grain(context, f);
    final frac = f.unit == 'fraction';
    String fmt(num v) => frac ? '${(v * 100).toStringAsFixed(1)} %' : '${fmtNum(v.toDouble().roundToDouble())} ${f.unit}';
    final value = fmt(f.value);
    final u = f.uncertainty;
    final hrc = u?['hrc'] as num?;
    final lo = u?['min'] as num?, hi = u?['max'] as num?;
    String? band;
    if (lo != null && hi != null && (hi - lo).abs() > (frac ? 0.0005 : 0.5)) {
      band = t.factBandValue(fmt(lo), fmt(hi));
      final hl = u?['hrc_min'] as num?, hh = u?['hrc_max'] as num?;
      if (!frac && (hl != null || hh != null)) {
        band = '$band  (${hl != null ? '${hl.round()}' : '<20'}–${hh != null ? '${hh.round()}' : '<20'} HRC)';
      }
    }
    final surf = u?['surface_hv'] as num?;
    return Padding(
      padding: const EdgeInsets.only(bottom: FlSpace.s),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(key == null ? value : '${_label(context, key)}: $value', style: context.text.headlineSmall),
        if (hrc != null) Text('≈ ${hrc.round()} HRC', style: context.text.titleMedium),
        if (band != null) Text('${t.factBand}: $band', style: context.text.bodySmall),
        if (surf != null) Text('${t.modelSurface}: ${fmtNum(surf.toDouble().roundToDouble())} HV'
            '${u?['surface_hrc'] != null ? ' ≈ ${(u!['surface_hrc'] as num).round()} HRC' : ''}', style: context.text.bodySmall),
        if (u != null && lo == null) Text('± $u', style: context.text.bodySmall),
        Wrap(spacing: FlSpace.s, runSpacing: FlSpace.xs, children: [
          EvidenceBadge(f.evidenceLevel),
          Pill(icon: Icons.source_outlined, label: t.kind(f.evidenceKind), background: context.fl.accentSoft),
        ]),
        Text('${f.method}${f.fractionBasis != null ? ' · ${f.fractionBasis}' : ''} · ${f.sourceIds.join(', ')}'
            '${f.modelVersion != null ? ' · ${f.modelVersion}' : ''}', style: context.text.bodySmall),
        if (f.validity?['locator'] != null)
          Text('${t.factOtherSpecimen}: ${f.validity!['locator']}', style: context.text.bodySmall),
      ]),
    );
  }

  void _explain(BuildContext context) {
    final t = context.t;
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(t.quantity(q.code)),
        content: Text(q.reason),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text(t.close))],
      ),
    );
  }
}

class _Foundation extends StatelessWidget {
  const _Foundation({required this.r});
  final SimulationResultDto r;

  /// Micrografías reales mostradas con este resultado: se citan siempre (autor, licencia y página de origen).
  List<MicrographDto> get _micrographs {
    final seen = <String>{};
    return [if (r.micrograph != null) r.micrograph!, ...r.relatedMicrographs].where((m) => seen.add(m.id)).toList();
  }
  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = r.protocol;
    return SectionCard(
      title: t.resultsFoundation,
      icon: Icons.account_tree_outlined,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        LimitationsPanel(warnings: r.warnings, initiallyExpanded: true),
        if (r.protocolCard != null) ProtocolSheet(p: r.protocolCard!),
        if (p != null && r.protocolCard == null)
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(t.resultsProtocol),
            children: [
              KeyValue(t.protocolMedium, p.medium),
              KeyValue('ID', '${p.id} · ${p.version}'),
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
            if (_micrographs.isNotEmpty) ...[
              const Gap(FlSpace.s),
              Text(t.resultsMicrographRefs, style: context.text.labelLarge),
              for (final m in _micrographs)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: FlSpace.xs),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(m.attribution, style: context.text.bodyMedium),
                    Text('${m.author} · ${m.licenseCode} — ${m.licenseUrl}', style: context.text.bodySmall),
                    if (m.pageUrl != null) SelectableText(m.pageUrl!, style: context.text.bodySmall),
                  ]),
                ),
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


class _GeneratedMicroSummary extends StatelessWidget {
  const _GeneratedMicroSummary({required this.spec});
  final Map<String, dynamic> spec;
  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final hasPicture = spec['family'] == 'gray_cast_iron' || spec['fractions'] != null;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Notice(spec['quantitative'] == true ? t.microGeneratedNote : t.microQualitativeNote, kind: 'info',
          icon: Icons.brush_outlined),
      const Gap(FlSpace.s),
      if (!hasPicture)
        Notice(t.microReason(spec['reason'] as String? ?? 'not_computed'), kind: 'limitation',
            icon: Icons.image_not_supported_outlined)
      else ...[
        GeneratedMicroscope(spec: spec, height: 340),
        const Gap(FlSpace.s),
        MicroLegend(spec: spec),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            key: const Key('openMicroscope'),
            onPressed: () => context.push('/lab/microscope'),
            icon: const Icon(Icons.open_in_full),
            label: Text(t.microOpen),
          ),
        ),
      ],
    ]);
  }
}

class _ModelDetails extends StatelessWidget {
  const _ModelDetails({required this.est});
  final Map<String, dynamic> est;
  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final crit = (est['critical_temperatures_c'] as Map).cast<String, num>();
    final comp = ((est['composition_nominal_wt_pct'] as Map?) ?? const {}).cast<String, num>();
    final prior = est['prior_state'] as Map?;
    String c(String k) => crit[k] == null ? '—' : '${crit[k]!.round()} °C';
    return SectionCard(
      key: const Key('modelDetails'),
      title: t.modelTitle,
      icon: Icons.functions,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(t.modelSpecimen, style: context.text.bodySmall),
        if (est['cooling_rate_700c_k_s'] != null)
          Text(t.modelCooling(fmtNum(((est['cooling_rate_700c_k_s'] as num) * 100).round() / 100))),
        if (est['bath_temperature_c'] != null) Text(t.modelBath(fmtNum((est['bath_temperature_c'] as num).toDouble()))),
        if (est['austenite_fraction_at_hold'] != null)
          Text(t.modelAustenite(((est['austenite_fraction_at_hold'] as num) * 100).toStringAsFixed(0))),
        if (prior != null && prior['fractions'] != null) ...[
          const Gap(FlSpace.s),
          Text(t.modelPrior, style: context.text.titleSmall),
          for (final e in (prior['fractions'] as Map).cast<String, num>().entries.where((e) => e.value >= .005))
            KeyValue(t.constituent(e.key), '${(e.value * 100).toStringAsFixed(1)} %'),
          if (prior['hardness_hv'] != null)
            KeyValue(t.q_hardness, '${(prior['hardness_hv'] as num).round()} HV'
                '${prior['hardness_hrc'] != null ? ' ≈ ${(prior['hardness_hrc'] as num).round()} HRC' : ''}'),
        ],
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(t.modelCritical),
          children: [
            KeyValue('Ac1 (Andrews)', c('ac1_c')),
            KeyValue('Ac3 (Andrews)', c('ac3_c')),
            KeyValue('Ae1 (Grange / Li)', c('ae1_li_c')),
            KeyValue('Ae3 (Grange / Li)', c('ae3_li_c')),
            KeyValue('Bs (Li)', c('bs_li_c')),
            KeyValue('Ms (Andrews)', c('ms_model_c')),
          ],
        ),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(t.modelComposition),
          children: [for (final e in comp.entries) KeyValue(e.key, e.value.toString())],
        ),
      ]),
    );
  }
}
