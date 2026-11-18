import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n.dart';
import '../../app/providers.dart';
import '../../core/design_system/tokens.dart';
import '../../shared/widgets/widgets.dart';

/// Dirección del servidor FERROLAB (necesaria en Android/iOS: la app no calcula localmente).
class ServerCard extends ConsumerStatefulWidget {
  const ServerCard({super.key});
  @override
  ConsumerState<ServerCard> createState() => _ServerCardState();
}

class _ServerCardState extends ConsumerState<ServerCard> {
  late final TextEditingController _c =
      TextEditingController(text: ref.read(settingsProvider).serverUrl ?? '');
  String? _msg, _err;
  bool _busy = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = context.t;
    final raw = _c.text.trim().replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.tryParse(raw);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https')) || uri.host.isEmpty) {
      setState(() => _err = t.settingsServerInvalid);
      return;
    }
    setState(() {
      _busy = true;
      _err = null;
      _msg = null;
    });
    ref.read(settingsProvider.notifier).update((s) => s.copyWith(serverUrl: raw));
    await _test();
  }

  Future<void> _test() async {
    final t = context.t;
    _invalidateCatalog();
    try {
      final h = await ref.read(healthProvider.future);
      if (mounted) setState(() => _msg = t.settingsServerOk('${h.datasetVersion} · engine ${h.engineVersion}'));
    } on Object catch (e) {
      if (mounted) setState(() => _err = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _invalidateCatalog() {
    for (final p in [healthProvider, materialsProvider, treatmentsProvider, knowledgeProvider, practiceProvider,
      sourcesProvider, micrographsProvider]) {
      ref.invalidate(p);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final current = ref.watch(apiClientProvider).baseUrl;
    return SectionCard(
      title: t.settingsServer,
      icon: Icons.dns_outlined,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(t.settingsServerNote, style: context.text.bodySmall),
        const Gap(FlSpace.m),
        TextField(
          key: const Key('serverField'),
          controller: _c,
          keyboardType: TextInputType.url,
          autocorrect: false,
          decoration: InputDecoration(labelText: t.settingsServer, hintText: t.settingsServerHint, errorText: _err),
        ),
        const Gap(FlSpace.s),
        Text(t.settingsServerCurrent(current), style: context.text.bodySmall),
        const Gap(FlSpace.m),
        Wrap(spacing: FlSpace.s, runSpacing: FlSpace.s, children: [
          FilledButton(onPressed: _busy ? null : _save, child: Text(t.settingsServerSave)),
          TextButton(
            onPressed: _busy
                ? null
                : () {
                    _c.clear();
                    ref.read(settingsProvider.notifier).update((s) => s.copyWith(clearServer: true));
                    setState(() {
                      _busy = true;
                      _err = null;
                    });
                    _test();
                  },
            child: Text(t.settingsServerReset),
          ),
        ]),
        if (_msg != null) ...[const Gap(FlSpace.s), Notice(_msg!, kind: 'info', icon: Icons.check_circle_outline)],
      ]),
    );
  }
}
