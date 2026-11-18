import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n.dart';
import '../../app/providers.dart';
import '../../core/design_system/tokens.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';
import '../results/results_screen.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});
  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _sel = <int>{};

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final h = ref.watch(historyProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.historyTitle), actions: [
        if (_sel.length == 2)
          TextButton.icon(
            onPressed: () {
              final l = _sel.toList()..sort();
              ref.read(compareProvider.notifier).set(h[l[0]].result, h[l[1]].result);
              context.push('/compare');
            },
            icon: const Icon(Icons.compare_arrows),
            label: Text(t.resultsCompare),
          ),
      ]),
      body: PageBody(maxWidth: 820, children: [
        Notice(t.historyLocalNote, kind: 'info', icon: Icons.phone_android),
        const Gap(FlSpace.l),
        if (h.isEmpty) Text(t.historyEmpty, textAlign: TextAlign.center),
        if (h.isNotEmpty) Text(t.historySelectTwo, style: context.text.bodySmall),
        for (final (i, e) in h.indexed)
          Card(
            margin: const EdgeInsets.only(top: FlSpace.s),
            child: CheckboxListTile(
              value: _sel.contains(i),
              onChanged: (v) => setState(() => v! ? (_sel.length < 2 ? _sel.add(i) : null) : _sel.remove(i)),
              title: Text('${e.result.materialName} · ${e.result.input.treatmentId}'),
              subtitle: Text('${fmtNum(e.result.input.targetTemperatureC)} °C · ${fmtNum(e.result.input.holdTimeMin)} min · '
                  '${t.status(e.result.status)} · ${e.savedAt.toLocal().toString().substring(0, 16)}'),
              secondary: IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => ResultsScreen(fromHistory: e.result))),
              ),
            ),
          ),
        if (h.isNotEmpty) ...[
          const Gap(FlSpace.xl),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: FlColors.errorRed),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  content: Text(t.historyDeleteConfirm),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t.cancel)),
                    FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(t.confirm)),
                  ],
                ),
              );
              if (ok ?? false) {
                await ref.read(historyProvider.notifier).clear();
                setState(_sel.clear);
              }
            },
            icon: const Icon(Icons.delete_outline),
            label: Text(t.historyDelete),
          ),
        ],
      ]),
    );
  }
}

/// Comparador (FR-16): solo se comparan magnitudes con la misma unidad; ausencias como «—».
class CompareScreen extends ConsumerWidget {
  const CompareScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final pair = ref.watch(compareProvider);
    if (pair == null) return Scaffold(appBar: AppBar(title: Text(t.compareTitle)));
    final (a, b) = pair;
    String cell(SimulationResultDto r, QuantityCode q) {
      final x = r.quantities.firstWhere((e) => e.code == q);
      if (!x.available) return '—';
      final f = x.single ?? x.group!.values.first;
      return '${fmtNum(f.value)} ${f.unit}';
    }

    String? diff(QuantityCode q) {
      final x = a.quantities.firstWhere((e) => e.code == q).single;
      final y = b.quantities.firstWhere((e) => e.code == q).single;
      if (x == null || y == null || x.unit != y.unit) return null; // escalas incompatibles: no se comparan
      return '${(y.value - x.value) >= 0 ? '+' : ''}${fmtNum(y.value - x.value)} ${x.unit}';
    }

    final rows = <(String, String, String)>[
      (t.reviewTreatment, a.input.treatmentId, b.input.treatmentId),
      (t.reviewTemperature, '${fmtNum(a.input.targetTemperatureC)} °C', '${fmtNum(b.input.targetTemperatureC)} °C'),
      (t.reviewTime, '${fmtNum(a.input.holdTimeMin)} min', '${fmtNum(b.input.holdTimeMin)} min'),
      ('Estado / Status', t.status(a.status), t.status(b.status)),
      ('', t.compat(a.compatibility), t.compat(b.compatibility)),
      for (final q in QuantityCode.values) (t.quantity(q), cell(a, q), cell(b, q)),
    ];
    final aWarn = a.warnings.map((w) => w.code).toSet(), bWarn = b.warnings.map((w) => w.code).toSet();
    return Scaffold(
      appBar: AppBar(title: Text(t.compareTitle)),
      body: PageBody(maxWidth: 900, children: [
        Notice(t.compareNote, kind: 'info'),
        const Gap(FlSpace.l),
        Table(
          columnWidths: const {0: FlexColumnWidth(1.2), 1: FlexColumnWidth(), 2: FlexColumnWidth()},
          border: TableBorder(horizontalInside: BorderSide(color: context.fl.border)),
          children: [
            TableRow(children: [const SizedBox(), Text('A', style: context.text.titleMedium), Text('B', style: context.text.titleMedium)]),
            for (final (k, x, y) in rows)
              TableRow(children: [
                Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(k, style: context.text.bodySmall)),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(x)),
                Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(y)),
              ]),
          ],
        ),
        const Gap(FlSpace.l),
        Text(t.compareDifferent, style: context.text.titleMedium),
        for (final q in QuantityCode.values)
          if (diff(q) case final d?) Text('${t.quantity(q)}: $d'),
        for (final w in b.warnings.where((w) => !aWarn.contains(w.code))) ...[
          const Gap(FlSpace.s), Notice('B: ${w.message}', kind: 'limitation')],
        for (final w in a.warnings.where((w) => !bWarn.contains(w.code))) ...[
          const Gap(FlSpace.s), Notice('A: ${w.message}', kind: 'limitation')],
      ]),
    );
  }
}
