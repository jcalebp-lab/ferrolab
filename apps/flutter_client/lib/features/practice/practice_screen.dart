import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n.dart';
import '../../app/providers.dart';
import '../../core/design_system/tokens.dart';
import '../../shared/widgets/widgets.dart';

/// Modo práctica (FR-18): preguntas del catálogo publicado; sin calificación oficial.
class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});
  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  int _i = 0, _correct = 0;
  int? _chosen;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final qs = ref.watch(practiceProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.practiceTitle)),
      body: AsyncBody(
        value: qs,
        onRetry: () => ref.invalidate(practiceProvider),
        data: (list) {
          if (list.isEmpty) return const SizedBox.shrink();
          final done = _i >= list.length;
          return PageBody(maxWidth: 720, children: [
            Text(t.practiceIntro, style: context.text.bodySmall),
            const Gap(FlSpace.m),
            const Gap(FlSpace.s),
            if (done) ...[
              Text(t.practiceScore(_correct, list.length), style: context.text.headlineSmall),
              const Gap(FlSpace.l),
              FilledButton(
                onPressed: () => setState(() {
                  _i = 0;
                  _correct = 0;
                  _chosen = null;
                }),
                child: Text(t.practiceRestart),
              ),
            ] else ...[
              Text('${_i + 1} / ${list.length}', style: context.text.bodySmall),
              const Gap(FlSpace.s),
              Text(list[_i].prompt, style: context.text.titleLarge),
              const Gap(FlSpace.l),
              for (final (k, o) in list[_i].options.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: FlSpace.s),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      backgroundColor: _chosen == null
                          ? null
                          : (k == list[_i].correctIndex
                              ? context.fl.evidenceValidatedBg
                              : (k == _chosen ? context.fl.warningBg : null)),
                    ),
                    onPressed: _chosen != null
                        ? null
                        : () {
                            setState(() => _chosen = k);
                            if (k == list[_i].correctIndex) {
                              _correct++;
                              ref.read(achievementsProvider.notifier).onPracticeCorrect();
                            }
                          },
                    child: Row(children: [
                      if (_chosen != null && k == list[_i].correctIndex) const Icon(Icons.check, size: 18),
                      if (_chosen == k && k != list[_i].correctIndex) const Icon(Icons.close, size: 18),
                      const Gap(FlSpace.s),
                      Expanded(child: Text(o)),
                    ]),
                  ),
                ),
              if (_chosen != null) ...[
                const Gap(FlSpace.m),
                Notice('${_chosen == list[_i].correctIndex ? t.practiceCorrect : t.practiceIncorrect} ${list[_i].feedback}',
                    kind: _chosen == list[_i].correctIndex ? 'info' : 'limitation'),
                if (list[_i].relatedSlug != null)
                  TextButton(onPressed: () => context.push('/learn/${list[_i].relatedSlug}'), child: Text(t.learnRelated)),
                const Gap(FlSpace.m),
                FilledButton(
                  onPressed: () => setState(() {
                    _i++;
                    _chosen = null;
                  }),
                  child: Text(t.practiceNext),
                ),
              ],
            ],
          ]);
        },
      ),
    );
  }
}
