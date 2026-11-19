import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n.dart';
import '../../app/providers.dart';
import '../../core/design_system/tokens.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';

String fmtRange(double? lo, double? hi, String unit, String none) {
  if (lo == null && hi == null) return none;
  if (lo != null && hi != null) return lo == hi ? '${fmtNum(lo)} $unit' : '${fmtNum(lo)}–${fmtNum(hi)} $unit';
  return lo != null ? '≥ ${fmtNum(lo)} $unit' : '≤ ${fmtNum(hi!)} $unit';
}

/// Mensaje principal (uno solo), con el color según su tipo.
class HeadlineNotice extends StatelessWidget {
  const HeadlineNotice(this.h, {super.key});
  final Headline h;
  @override
  Widget build(BuildContext context) => Notice(
        h.message,
        key: const Key('headline'),
        kind: switch (h.kind) { 'warning' => 'warning', 'limitation' => 'limitation', _ => 'info' },
        icon: switch (h.kind) {
          'ok' => Icons.check_circle_outline,
          'warning' => Icons.warning_amber_rounded,
          'limitation' => Icons.science_outlined,
          _ => Icons.info_outline,
        },
      );
}

class LevelBadge extends StatelessWidget {
  const LevelBadge(this.level, {super.key});
  final String? level;
  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final (label, bg) = switch (level) {
      'A' => (t.levelA, context.fl.evidenceValidatedBg),
      'B' => (t.levelB, context.fl.evidenceLimitedBg),
      _ => (t.levelC, context.fl.warningBg),
    };
    return Pill(icon: Icons.layers_outlined, label: label, background: bg);
  }
}

/// «Fundamento científico y limitaciones»: avisos agrupados por causa, sin repetir el mensaje principal.
class LimitationsPanel extends StatelessWidget {
  const LimitationsPanel({super.key, required this.warnings, this.initiallyExpanded = false});
  final List<WarningDto> warnings;
  final bool initiallyExpanded;
  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final groups = <String, List<WarningDto>>{};
    for (final w in warnings) {
      groups.putIfAbsent(w.group ?? 'other', () => []).add(w);
    }
    const order = ['input', 'dependency', 'protocol', 'evidence', 'model', 'review', 'other'];
    String name(String g) => switch (g) {
          'input' => t.groupInput,
          'dependency' => t.groupDependency,
          'protocol' => t.groupProtocol,
          'evidence' => t.groupEvidence,
          'model' => t.groupModel,
          'review' => t.groupReview,
          _ => t.groupOther,
        };
    return ExpansionTile(
      key: const Key('limitationsPanel'),
      initiallyExpanded: initiallyExpanded,
      tilePadding: EdgeInsets.zero,
      leading: const Icon(Icons.fact_check_outlined),
      title: Text(t.lpLimitations),
      subtitle: Text(t.lpLimitationsCount(warnings.length.toString()), style: context.text.bodySmall),
      children: [
        for (final g in order.where(groups.containsKey)) ...[
          Align(alignment: Alignment.centerLeft, child: Text(name(g), style: context.text.labelLarge)),
          const Gap(FlSpace.xs),
          for (final w in groups[g]!)
            Padding(
              padding: const EdgeInsets.only(bottom: FlSpace.s),
              child: Notice(w.message, kind: w.blocking ? 'warning' : (w.severity == 'info' ? 'info' : 'limitation')),
            ),
        ],
      ],
    );
  }
}

/// Lista de protocolos del par (referencia primero) para elegir variante.
class ProtocolPicker extends StatelessWidget {
  const ProtocolPicker({super.key, required this.protocols, required this.selectedId, required this.onSelect});
  final List<ProtocolCard> protocols;
  final String? selectedId;
  final ValueChanged<ProtocolCard> onSelect;
  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final p in protocols)
        Padding(
          padding: const EdgeInsets.only(bottom: FlSpace.s),
          child: InkWell(
            key: Key('protocol_${p.id}'),
            borderRadius: BorderRadius.circular(FlRadius.input),
            onTap: () => onSelect(p),
            child: Container(
              padding: const EdgeInsets.all(FlSpace.m),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(FlRadius.input),
                border: Border.all(color: p.id == selectedId ? Theme.of(context).colorScheme.primary : context.fl.border,
                    width: p.id == selectedId ? 2 : 1),
                color: p.id == selectedId ? context.fl.accentSoft.withValues(alpha: .5) : null,
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(p.id == selectedId ? Icons.radio_button_checked : Icons.radio_button_off, size: 20),
                  const Gap(FlSpace.s),
                  Expanded(child: Text(p.name, style: context.text.titleSmall)),
                ]),
                if (p.objective != null) ...[const Gap(FlSpace.xs), Text(p.objective!, style: context.text.bodySmall)],
                const Gap(FlSpace.xs),
                Wrap(spacing: FlSpace.xs, runSpacing: FlSpace.xs, children: [
                  if (p.isReference) Pill(icon: Icons.star_outline, label: t.lpReference, background: context.fl.accentSoft),
                  Pill(icon: p.verified ? Icons.verified_outlined : Icons.help_outline,
                      label: p.verified ? t.lpVerified : t.lpUnverified,
                      background: p.verified ? context.fl.evidenceValidatedBg : context.fl.warningBg),
                  Pill(icon: Icons.flag_outlined, label: t.goal(p.goal), background: context.fl.surface),
                  if (p.materialCondition != null)
                    Pill(icon: Icons.layers_outlined, label: p.materialCondition!, background: context.fl.surface),
                ]),
              ]),
            ),
          ),
        ),
    ]);
  }
}

/// Un parámetro numérico del protocolo: campo, botones, intervalo documentado y fundamento de la cifra.
class ParamField extends StatefulWidget {
  const ParamField({super.key, required this.fieldKey, required this.label, required this.icon, required this.param,
      required this.value, required this.unit, required this.onChanged, this.uiMin = 0, this.uiMax = 1600,
      this.step = 5, this.allowEmpty = false, this.emptyLabel});
  final String fieldKey, label, unit;
  final IconData icon;
  final ProtocolParam param;
  final double? value;
  final ValueChanged<double?> onChanged;
  final double uiMin, uiMax, step;
  final bool allowEmpty;
  final String? emptyLabel;
  @override
  State<ParamField> createState() => _ParamFieldState();
}

class _ParamFieldState extends State<ParamField> {
  late final TextEditingController _c = TextEditingController(text: widget.value == null ? '' : fmtNum(widget.value!));
  String? _err;

  @override
  void didUpdateWidget(covariant ParamField old) {
    super.didUpdateWidget(old);
    final txt = widget.value == null ? '' : fmtNum(widget.value!);
    if (double.tryParse(_c.text) != widget.value && _c.text != txt) _c.text = txt;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _set(double? v) {
    if (v != null && (v < widget.uiMin || v > widget.uiMax)) {
      setState(() => _err = context.t.paramsOutOfUi);
      return;
    }
    setState(() => _err = null);
    widget.onChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = widget.param;
    final v = widget.value;
    final outside = v != null && !p.inRange(v);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(widget.icon, size: 20),
        const Gap(FlSpace.s),
        Expanded(child: Text(widget.label, style: context.text.titleSmall)),
      ]),
      const Gap(FlSpace.s),
      Row(children: [
        SizedBox(
          width: 150,
          child: TextField(
            key: Key(widget.fieldKey),
            controller: _c,
            enabled: p.editable,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            decoration: InputDecoration(labelText: widget.label, suffixText: widget.unit, errorText: _err, isDense: true,
                hintText: widget.allowEmpty ? widget.emptyLabel : null),
            onChanged: (s) {
              if (s.isEmpty && widget.allowEmpty) return _set(null);
              final d = double.tryParse(s);
              if (d == null) {
                setState(() => _err = t.paramsInvalidNumber);
              } else {
                _set(d);
              }
            },
          ),
        ),
        if (p.editable)
          for (final d in [-widget.step, widget.step])
            IconButton(
              tooltip: '${d > 0 ? '+' : ''}${fmtNum(d)} ${widget.unit}',
              onPressed: () {
                final nv = ((v ?? p.ref ?? 0) + d).clamp(widget.uiMin, widget.uiMax).toDouble();
                _c.text = fmtNum(nv);
                _set(nv);
              },
              icon: Icon(d > 0 ? Icons.add_circle_outline : Icons.remove_circle_outline),
            ),
        if (!p.editable) const Padding(padding: EdgeInsets.only(left: FlSpace.s), child: Icon(Icons.lock_outline, size: 18)),
      ]),
      const Gap(FlSpace.xs),
      Text(t.pRange(fmtRange(p.min, p.max, widget.unit, p.basis == 'pending' ? t.basis('pending') : '—')),
          style: context.text.bodySmall),
      if (p.ref != null) Text(t.pRef('${fmtNum(p.ref!)} ${widget.unit}'), style: context.text.bodySmall),
      Text(t.basis(p.basis), style: context.text.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
      if (p.rule != null) Text(p.rule!, style: context.text.bodySmall),
      if (outside) ...[const Gap(FlSpace.xs), Notice(t.pOutside, kind: 'warning')],
    ]);
  }
}

IconData stageIcon(ProtocolStageCard s) => switch (s.role) {
      'preheat' => Icons.local_fire_department_outlined,
      'austenitize' || 'austenitize_2' || 'subcritical' || 'temper' => Icons.whatshot_outlined,
      'soak' => Icons.timer_outlined,
      'transfer' => Icons.open_with,
      'quench' => Icons.water_drop_outlined,
      'bath' || 'equalize' => Icons.hot_tub_outlined,
      'furnace_cool' => Icons.trending_down,
      _ => Icons.air,
    };

/// Secuencia térmica completa: horno → sostenimiento → traslado → baño/enfriamiento → enfriamiento final.
class ThermalSequence extends StatelessWidget {
  const ThermalSequence({super.key, required this.protocol, required this.sim});
  final ProtocolCard protocol;
  final SimState sim;
  @override
  Widget build(BuildContext context) {
    final t = context.t;
    String temp(ProtocolStageCard s) {
      if (s.param == 'furnace_temperature') return '${fmtNum(sim.temperatureC)} °C';
      if (s.param == 'bath_temperature') {
        final b = sim.bathTemperatureC ?? protocol.param('bath_temperature')?.ref;
        return b == null ? '—' : '${fmtNum(b)} °C';
      }
      if (s.temperatureC != null) return '${fmtNum(s.temperatureC!)} °C';
      if (s.tMin != null || s.tMax != null) return fmtRange(s.tMin, s.tMax, '°C', '—');
      if (s.untilC != null) return '→ ${fmtNum(s.untilC!)} °C';
      return s.temperatureMode == 'ambient' ? t.seqAmbient : '';
    }

    String time(ProtocolStageCard s) {
      if (s.timeParam == 'hold_time') return '${fmtNum(sim.holdMin)} ${t.paramsMinutes}';
      if (s.timeParam == 'bath_time') {
        final b = sim.bathTimeMin ?? protocol.param('bath_time')?.ref;
        return b == null ? t.seqUntilEqualized : '${fmtNum(b)} ${t.paramsMinutes}';
      }
      if (s.durationMode == 'until_equalized') return t.seqUntilEqualized;
      if (s.durationS != null) return fmtDuration(s.durationS!);
      if (s.rateCPerH != null) return '${fmtNum(s.rateCPerH!)} °C/h';
      if (s.kind == 'transfer') return '≈ 5 s';
      return '';
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final (i, s) in protocol.stages.indexed) ...[
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: [
            CircleAvatar(radius: 16, backgroundColor: s.isBath ? context.fl.accentSoft : context.fl.surface,
                child: Icon(stageIcon(s), size: 18)),
            if (i < protocol.stages.length - 1) Container(width: 2, height: 28, color: context.fl.border),
          ]),
          const Gap(FlSpace.m),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${s.ordinal}. ${s.label}', style: context.text.titleSmall),
              Wrap(spacing: FlSpace.m, children: [
                if (temp(s).isNotEmpty) Text(temp(s), style: context.text.bodyMedium),
                if (time(s).isNotEmpty) Text(time(s), style: context.text.bodyMedium),
                if (s.medium != null) Text('${t.medium(s.medium!)}${s.mediumNote != null ? ' · ${s.mediumNote}' : ''}',
                    style: context.text.bodySmall),
              ]),
              if (s.purpose != null) Text(s.purpose!, style: context.text.bodySmall),
              if (s.startCondition != null) Text('${t.seqStart}: ${s.startCondition}', style: context.text.bodySmall),
              const Gap(FlSpace.s),
            ]),
          ),
        ]),
      ],
    ]);
  }
}

/// Ficha del protocolo: objetivo, condición, resultado esperado, restricciones, supuestos, lo que falta y fuentes.
class ProtocolSheet extends StatelessWidget {
  const ProtocolSheet({super.key, required this.p, this.initiallyExpanded = false});
  final ProtocolCard p;
  final bool initiallyExpanded;
  @override
  Widget build(BuildContext context) {
    final t = context.t;
    Widget list(String title, List<String> items, {IconData icon = Icons.chevron_right}) => items.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(bottom: FlSpace.s),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: context.text.labelLarge),
              for (final x in items)
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(icon, size: 16),
                  const Gap(FlSpace.xs),
                  Expanded(child: Text(x, style: context.text.bodySmall)),
                ]),
            ]),
          );
    return ExpansionTile(
      key: const Key('protocolSheet'),
      initiallyExpanded: initiallyExpanded,
      tilePadding: EdgeInsets.zero,
      leading: const Icon(Icons.menu_book_outlined),
      title: Text(t.lpSheet),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (p.objective != null) KeyValue(t.lpObjective, p.objective!),
            if (p.materialCondition != null) KeyValue(t.lpCondition, p.materialCondition!),
            KeyValue(t.pMediumLocked, '${p.medium} 🔒'),
            if (p.expected != null) KeyValue(t.lpExpected, p.expected!),
            const Gap(FlSpace.s),
            list(t.lpPublished, p.publishedResults, icon: Icons.science_outlined),
            list(t.lpRestrictions, p.restrictions, icon: Icons.rule),
            list(t.lpAssumptions, p.assumptions, icon: Icons.lightbulb_outline),
            list(t.lpMissing, p.missing, icon: Icons.search),
            Text(t.lpSources, style: context.text.labelLarge),
            for (final s in p.sources)
              Padding(
                padding: const EdgeInsets.only(top: FlSpace.xs),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(s.verified ? Icons.verified_outlined : Icons.help_outline, size: 16),
                  const Gap(FlSpace.xs),
                  Expanded(
                    child: Text('${s.authors != null ? '${s.authors} — ' : ''}${s.title}${s.year != null ? ' (${s.year})' : ''}'
                        '${s.url != null ? '\n${s.url}' : ''}${s.verified ? '' : '\n${t.lpUnverified}'}',
                        style: context.text.bodySmall),
                  ),
                ]),
              ),
          ]),
        ),
      ],
    );
  }
}

/// Revenido: de dónde sale la pieza templada.
class PriorStatePanel extends ConsumerWidget {
  const PriorStatePanel({super.key, required this.materialId});
  final String materialId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final sim = ref.watch(simulationProvider);
    final quenches = ref.watch(historyProvider)
        .where((e) => e.result.input.materialId == materialId && e.result.input.treatmentId == 'quench')
        .toList();
    final n = ref.read(simulationProvider.notifier);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SegmentedButton<String>(
        key: const Key('priorMode'),
        segments: [
          ButtonSegment(value: 'reference', label: Text(t.priorReference)),
          ButtonSegment(value: 'history', label: Text(t.priorHistory), enabled: quenches.isNotEmpty),
          ButtonSegment(value: 'theory', label: Text(t.priorTheory)),
        ],
        selected: {sim.priorMode},
        onSelectionChanged: (s) {
          if (s.first == 'history' && quenches.isNotEmpty) {
            n.setPrior('history', fromHistory: quenches.first.result.input);
          } else {
            n.setPrior(s.first);
          }
        },
      ),
      const Gap(FlSpace.s),
      if (quenches.isEmpty) Text(t.priorHistoryEmpty, style: context.text.bodySmall),
      if (sim.priorMode == 'history')
        for (final e in quenches.take(5))
          ListTile(
            dense: true,
            leading: Icon(sim.priorTemperatureC == e.result.input.targetTemperatureC
                ? Icons.radio_button_checked
                : Icons.radio_button_off),
            title: Text('${fmtNum(e.result.input.targetTemperatureC)} °C · ${fmtNum(e.result.input.holdTimeMin)} '
                '${t.paramsMinutes}'),
            subtitle: Text(e.savedAt.toLocal().toString().substring(0, 16)),
            onTap: () => n.setPrior('history', fromHistory: e.result.input),
          ),
    ]);
  }
}
