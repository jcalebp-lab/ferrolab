import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n.dart';
import '../../app/providers.dart';
import '../../core/design_system/tokens.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';

/// Tutor educativo: explica, nunca calcula. Funciona sin IA (modo editorial).
Future<void> showTutorSheet(BuildContext context, {SimulationInput? input}) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (c) => FractionallySizedBox(heightFactor: .85, child: _TutorSheet(input: input)),
    );

class _TutorSheet extends ConsumerStatefulWidget {
  const _TutorSheet({this.input});
  final SimulationInput? input;
  @override
  ConsumerState<_TutorSheet> createState() => _TutorSheetState();
}

class _TutorSheetState extends ConsumerState<_TutorSheet> {
  final _q = TextEditingController();
  Future<TutorResponseDto>? _future;

  @override
  void initState() {
    super.initState();
    if (widget.input != null) {
      _future = ref.read(repositoryProvider).tutorExplain(widget.input!, ref.read(localeProvider));
    }
  }

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  void _ask(String q) {
    if (q.trim().isEmpty) return;
    setState(() => _future = ref.read(repositoryProvider).tutorAsk(q.trim(), widget.input, ref.read(localeProvider)));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final quick = [t.tutorQuick1, t.tutorQuick2, t.tutorQuick3, t.tutorQuick4, t.tutorQuick5];
    return ListView(padding: const EdgeInsets.fromLTRB(FlSpace.xl, 0, FlSpace.xl, FlSpace.xl), children: [
      Text(t.tutorTitle, style: context.text.headlineSmall),
      const Gap(FlSpace.s),
      Text(t.tutorPrivacy, style: context.text.bodySmall),
      const Gap(FlSpace.m),
      Wrap(spacing: FlSpace.s, runSpacing: FlSpace.s, children: [
        for (final q in quick) ActionChip(label: Text(q), onPressed: () => _ask(q)),
      ]),
      const Gap(FlSpace.m),
      Row(children: [
        Expanded(
          child: TextField(
            controller: _q,
            maxLength: 500,
            decoration: InputDecoration(hintText: t.tutorAskHint, counterText: ''),
            onSubmitted: _ask,
          ),
        ),
        const Gap(FlSpace.s),
        FilledButton(onPressed: () => _ask(_q.text), child: Text(t.tutorAsk)),
      ]),
      const Gap(FlSpace.l),
      if (_future != null)
        FutureBuilder<TutorResponseDto>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Padding(padding: EdgeInsets.all(FlSpace.xl), child: Center(child: CircularProgressIndicator()));
            }
            if (snap.hasError) return ErrorView(error: snap.error!);
            final r = snap.data!;
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Pill(
                icon: r.isAi ? Icons.auto_awesome_outlined : Icons.menu_book_outlined,
                label: r.isAi ? t.tutorAiMode : t.tutorEditorialMode,
                background: context.fl.accentSoft,
              ),
              if (r.notice != null) ...[const Gap(FlSpace.s), Text(r.notice!, style: context.text.bodySmall)],
              const Gap(FlSpace.m),
              Text(r.summary, style: context.text.titleMedium),
              for (final e in r.explanations) ...[
                const Gap(FlSpace.m),
                Text(e.claim, style: context.text.bodyLarge),
                if (e.sourceIds.isNotEmpty) Text(e.sourceIds.join(' · '), style: context.text.bodySmall),
              ],
              if (r.limitations.isNotEmpty) ...[
                const Gap(FlSpace.l),
                for (final l in r.limitations)
                  Padding(padding: const EdgeInsets.only(bottom: FlSpace.s), child: Notice(l, kind: 'limitation')),
              ],
              if (r.related.isNotEmpty) ...[
                const Gap(FlSpace.m),
                Wrap(spacing: FlSpace.s, children: [
                  for (final s in r.related)
                    ActionChip(
                      avatar: const Icon(Icons.menu_book_outlined, size: 16),
                      label: Text(s),
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/learn/$s');
                      },
                    ),
                ]),
              ],
            ]);
          },
        ),
    ]);
  }
}
