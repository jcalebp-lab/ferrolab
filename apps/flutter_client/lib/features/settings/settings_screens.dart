import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n.dart';
import '../../app/providers.dart';
import '../../core/design_system/tokens.dart';
import '../../shared/widgets/widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final ach = ref.watch(achievementsProvider);
    final health = ref.watch(healthProvider).value;
    final achNames = {
      Achievement.firstRun: t.achFirstRun,
      Achievement.allMaterials: t.achAllMaterials,
      Achievement.allTreatments: t.achAllTreatments,
      Achievement.practice: t.achPractice,
      Achievement.honest: t.achHonest,
    };
    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: PageBody(maxWidth: 720, children: [
        SectionCard(
          title: t.settingsLanguage,
          icon: Icons.translate,
          child: SegmentedButton<String>(
            segments: const [ButtonSegment(value: 'es', label: Text('Español')), ButtonSegment(value: 'en', label: Text('English'))],
            selected: {s.locale},
            onSelectionChanged: (v) => n.update((x) => x.copyWith(locale: v.first)),
          ),
        ),
        const Gap(FlSpace.m),
        SectionCard(
          title: t.settingsTheme,
          icon: Icons.contrast,
          child: SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(value: ThemeMode.system, label: Text(t.themeSystem)),
              ButtonSegment(value: ThemeMode.light, label: Text(t.themeLight)),
              ButtonSegment(value: ThemeMode.dark, label: Text(t.themeDark)),
            ],
            selected: {s.themeMode},
            onSelectionChanged: (v) => n.update((x) => x.copyWith(themeMode: v.first)),
          ),
        ),
        const Gap(FlSpace.m),
        Card(
          child: Column(children: [
            SwitchListTile(
              title: Text(t.settingsReduceMotion),
              value: s.reduceMotion,
              onChanged: (v) => n.update((x) => x.copyWith(reduceMotion: v)),
            ),
            SwitchListTile(title: Text(t.settingsSound), subtitle: Text(t.settingsSoundNote), value: false, onChanged: null),
            SwitchListTile(
              title: Text(t.settingsNotifications), subtitle: Text(t.settingsNotificationsNote), value: false, onChanged: null),
            SwitchListTile(
              title: Text(t.settingsAchievements),
              subtitle: Text(t.settingsAchievementsNote),
              value: s.achievements,
              onChanged: (v) => n.update((x) => x.copyWith(achievements: v)),
            ),
          ]),
        ),
        if (s.achievements) ...[
          const Gap(FlSpace.m),
          SectionCard(
            title: t.settingsAchievements,
            icon: Icons.emoji_events_outlined,
            child: Wrap(spacing: FlSpace.s, runSpacing: FlSpace.s, children: [
              for (final a in Achievement.values)
                Pill(
                  icon: ach['unlocked_${a.name}'] == true ? Icons.emoji_events : Icons.lock_outline,
                  label: achNames[a]!,
                  background: ach['unlocked_${a.name}'] == true ? context.fl.evidenceValidatedBg : context.fl.surface,
                ),
            ]),
          ),
        ],
        const Gap(FlSpace.m),
        Card(
          child: Column(children: [
            ListTile(
              leading: const Icon(Icons.replay),
              title: Text(t.settingsTutorial),
              onTap: () {
                n.update((x) => x.copyWith(onboardingSeen: false));
                context.go('/welcome');
              },
            ),
            ListTile(leading: const Icon(Icons.menu_book_outlined), title: Text(t.settingsSources), onTap: () => context.push('/sources')),
            ListTile(leading: const Icon(Icons.history), title: Text(t.historyTitle), onTap: () => context.push('/history')),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: Text(t.settingsAdmin),
              onTap: () => context.push('/admin'),
            ),
          ]),
        ),
        const Gap(FlSpace.m),
        SectionCard(title: t.settingsPrivacy, icon: Icons.privacy_tip_outlined, child: Text(t.settingsPrivacyBody)),
        const Gap(FlSpace.m),
        SectionCard(
          title: t.settingsAbout,
          icon: Icons.info_outline,
          child: Text('${t.appTitle} — ${t.appSubtitle}\n'
              'engine ${health?.engineVersion ?? '—'} · dataset ${health?.datasetVersion ?? '—'}'),
        ),
      ]),
    );
  }
}

class SourcesScreen extends ConsumerWidget {
  const SourcesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(title: Text(t.sourcesTitle)),
      body: PageBody(maxWidth: 820, children: [
        Notice(t.sourcesNote, kind: 'limitation'),
        const Gap(FlSpace.l),
        AsyncBody(
          value: ref.watch(sourcesProvider),
          onRetry: () => ref.invalidate(sourcesProvider),
          data: (list) => Column(children: [for (final s in list) SourceTile(s)]),
        ),
      ]),
    );
  }
}
