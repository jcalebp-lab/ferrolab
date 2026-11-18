import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n.dart';
import '../../app/providers.dart';
import '../../core/design_system/tokens.dart';
import '../../shared/widgets/widgets.dart';

class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});
  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final k = ref.watch(knowledgeProvider);
    final trts = ref.watch(treatmentsProvider);
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.learnTitle),
          bottom: TabBar(isScrollable: true, tabAlignment: TabAlignment.start, tabs: [
            Tab(text: t.learnGlossary),
            Tab(text: t.learnConcepts),
            Tab(text: t.learnFaq),
            Tab(text: t.learnTreatments),
            Tab(text: t.learnDiagrams),
          ]),
        ),
        body: AsyncBody(
          value: k,
          onRetry: () => ref.invalidate(knowledgeProvider),
          data: (entries) {
            Widget list(String cat) {
              final items = entries
                  .where((e) => e.category == cat)
                  .where((e) => _query.isEmpty || '${e.title} ${e.body}'.toLowerCase().contains(_query.toLowerCase()))
                  .toList();
              return PageBody(maxWidth: 820, children: [
                TextField(
                  decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: t.learnSearch),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const Gap(FlSpace.m),
                if (entries.any((e) => e.reviewStatus != 'published')) ...[const UnreviewedBanner(), const Gap(FlSpace.m)],
                for (final e in items)
                  Card(
                    margin: const EdgeInsets.only(bottom: FlSpace.s),
                    child: ListTile(
                      title: Text(e.title, style: context.text.titleMedium),
                      subtitle: Text(e.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/learn/${e.slug}'),
                    ),
                  ),
              ]);
            }

            return TabBarView(children: [
              list('glossary'),
              list('concept'),
              list('faq'),
              AsyncBody(
                value: trts,
                data: (ts) => PageBody(maxWidth: 820, children: [
                  for (final tr in ts)
                    Padding(
                      padding: const EdgeInsets.only(bottom: FlSpace.m),
                      child: SectionCard(
                        title: tr.name,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(tr.purpose),
                          const Gap(FlSpace.s),
                          Text('${t.treatmentPrerequisites}: ${tr.prerequisites}', style: context.text.bodySmall),
                          const Gap(FlSpace.s),
                          for (final (i, s) in tr.stages.indexed) Text('${i + 1}. ${s.label}'),
                          const Gap(FlSpace.s),
                          Text(tr.qualitativeOutcome),
                        ]),
                      ),
                    ),
                ]),
              ),
              PageBody(maxWidth: 820, children: [
                Notice(t.learnDiagramsBody, kind: 'limitation', icon: Icons.ssid_chart),
                const Gap(FlSpace.l),
                for (final slug in const ['ttt', 'cct', 'diagrama-fe-c'])
                  if (entries.where((e) => e.slug == slug).firstOrNull case final e?)
                    Padding(
                      padding: const EdgeInsets.only(bottom: FlSpace.m),
                      child: SectionCard(title: e.title, child: Text(e.body)),
                    ),
              ]),
            ]);
          },
        ),
      ),
    );
  }
}

class KnowledgeDetailScreen extends ConsumerWidget {
  const KnowledgeDetailScreen({super.key, required this.slug});
  final String slug;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final k = ref.watch(knowledgeProvider);
    return Scaffold(
      appBar: AppBar(),
      body: AsyncBody(
        value: k,
        onRetry: () => ref.invalidate(knowledgeProvider),
        data: (entries) {
          final e = entries.where((x) => x.slug == slug).firstOrNull;
          if (e == null) return Center(child: Text(t.internalError));
          final related = entries.where((x) => e.related.contains(x.slug)).toList();
          return PageBody(maxWidth: 760, children: [
            Text(e.title, style: context.text.headlineSmall),
            const Gap(FlSpace.l),
            Text(e.body, style: context.text.bodyLarge),
            if (e.reviewStatus != 'published') ...[const Gap(FlSpace.l), const UnreviewedBanner()],
            if (related.isNotEmpty) ...[
              const Gap(FlSpace.xl),
              Text(t.learnRelated, style: context.text.titleMedium),
              Wrap(spacing: FlSpace.s, children: [
                for (final r in related) ActionChip(label: Text(r.title), onPressed: () => context.push('/learn/${r.slug}')),
              ]),
            ],
            if (e.sources.isNotEmpty) ...[
              const Gap(FlSpace.xl),
              Text(t.resultsSuggestedReading, style: context.text.titleMedium),
              for (final s in e.sources) SourceTile(s),
            ],
          ]);
        },
      ),
    );
  }
}

