import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n.dart';
import '../../app/providers.dart';
import '../../core/design_system/tokens.dart';
import '../../core/networking/api_client.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';

/// Panel privado (FR-23). Ocultar botones NO es seguridad: cada operación la
/// autoriza el backend por rol. El token se guarda solo en memoria.
class AdminSession {
  AdminSession({required this.token, required this.role, this.email});
  final String token, role;
  final String? email;
}

class AdminSessionNotifier extends Notifier<AdminSession?> {
  @override
  AdminSession? build() => null;

  Future<void> loginWithToken(String token) async {
    final me = await ref.read(apiClientProvider).get('/api/v1/admin/me', bearer: token.trim());
    state = AdminSession(token: token.trim(), role: me['role'] as String, email: me['email'] as String?);
  }

  Future<void> loginWithPassword(HealthDto h, String email, String password) async {
    final uri = Uri.parse('${h.supabaseUrl}/auth/v1/token').replace(queryParameters: {'grant_type': 'password'});
    final j = await ref.read(apiClientProvider).postAbsolute(uri, {'email': email, 'password': password},
        {'apikey': h.supabaseAnonKey!});
    await loginWithToken(j['access_token'] as String);
  }

  void logout() => state = null;
}

final adminSessionProvider = NotifierProvider<AdminSessionNotifier, AdminSession?>(AdminSessionNotifier.new);

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final session = ref.watch(adminSessionProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.adminTitle), actions: [
        if (session != null) ...[
          Center(child: Text(t.adminRole(session.role))),
          IconButton(tooltip: t.adminLogout, onPressed: () => ref.read(adminSessionProvider.notifier).logout(),
              icon: const Icon(Icons.logout)),
        ],
      ]),
      body: session == null ? const _Login() : _Dashboard(session: session),
    );
  }
}

class _Login extends ConsumerStatefulWidget {
  const _Login();
  @override
  ConsumerState<_Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<_Login> {
  final _email = TextEditingController(), _pw = TextEditingController(), _tok = TextEditingController();
  Object? _err;
  bool _busy = false;

  Future<void> _go(Future<void> Function() f) async {
    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      await f();
    } on Object catch (e) {
      setState(() => _err = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final h = ref.watch(healthProvider);
    return AsyncBody(
      value: h,
      onRetry: () => ref.invalidate(healthProvider),
      data: (health) => PageBody(maxWidth: 460, children: [
        const Gap(FlSpace.l),
        if (!health.adminAvailable) Notice(t.adminNotConfigured, kind: 'limitation'),
        if (health.adminAvailable && health.supabaseUrl != null && health.supabaseAnonKey != null) ...[
          TextField(controller: _email, decoration: InputDecoration(labelText: t.adminEmail), autofillHints: const [AutofillHints.email]),
          const Gap(FlSpace.m),
          TextField(controller: _pw, obscureText: true, decoration: InputDecoration(labelText: t.adminPassword)),
          const Gap(FlSpace.m),
          FilledButton(
            onPressed: _busy ? null : () => _go(() => ref.read(adminSessionProvider.notifier)
                .loginWithPassword(health, _email.text, _pw.text)),
            child: Text(t.adminLogin),
          ),
        ],
        if (health.adminAvailable && health.adminDevLogin) ...[
          const Gap(FlSpace.xl),
          Text(t.adminDevToken, style: context.text.titleMedium),
          Text(t.adminDevTokenHint, style: context.text.bodySmall),
          const Gap(FlSpace.s),
          TextField(key: const Key('devToken'), controller: _tok, obscureText: true, maxLines: 1),
          const Gap(FlSpace.m),
          OutlinedButton(
            onPressed: _busy ? null : () => _go(() => ref.read(adminSessionProvider.notifier).loginWithToken(_tok.text)),
            child: Text(t.adminLogin),
          ),
        ],
        if (_err != null) ErrorView(error: _err!),
      ]),
    );
  }
}

class _Dashboard extends StatefulWidget {
  const _Dashboard({required this.session});
  final AdminSession session;
  @override
  State<_Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<_Dashboard> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final pages = [
      _Records(session: widget.session),
      _Releases(session: widget.session),
      _Audit(session: widget.session),
    ];
    final dests = [
      (Icons.inventory_2_outlined, t.adminRecords),
      (Icons.publish_outlined, t.adminReleases),
      (Icons.receipt_long_outlined, t.adminAudit),
    ];
    final wide = MediaQuery.sizeOf(context).width >= FlLayout.tabletBreakpoint;
    if (wide) {
      return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        NavigationRail(
          selectedIndex: _tab,
          labelType: NavigationRailLabelType.all,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: [for (final (i, l) in dests) NavigationRailDestination(icon: Icon(i), label: Text(l))],
        ),
        const VerticalDivider(width: 1),
        Expanded(child: pages[_tab]),
      ]);
    }
    return Column(children: [
      Expanded(child: pages[_tab]),
      NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [for (final (i, l) in dests) NavigationDestination(icon: Icon(i), label: l)],
      ),
    ]);
  }
}

const _entities = ['materials', 'treatments', 'material-treatments', 'protocols', 'initial-conditions', 'sources',
  'evidence', 'physical-guards', 'model-versions', 'micrographs', 'knowledge', 'practice-questions'];
const _keyFields = {'material-treatments': ['material_id', 'treatment_id'], 'knowledge': ['slug']};

String _keyOf(String entity, Json item) => (_keyFields[entity] ?? const ['id']).map((f) => item[f]).join(':');

class _Records extends ConsumerStatefulWidget {
  const _Records({required this.session});
  final AdminSession session;
  @override
  ConsumerState<_Records> createState() => _RecordsState();
}

class _RecordsState extends ConsumerState<_Records> {
  String _entity = 'materials';
  String? _status;
  late Future<Json> _f = _load();

  Future<Json> _load() => ref.read(apiClientProvider).get('/api/v1/admin/$_entity',
      query: {'limit': '500', 'status': ?_status}, bearer: widget.session.token);

  void _reload() => setState(() => _f = _load());

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return PageBody(children: [
      Wrap(spacing: FlSpace.m, runSpacing: FlSpace.s, crossAxisAlignment: WrapCrossAlignment.center, children: [
        DropdownButton<String>(
          value: _entity,
          items: [for (final e in _entities) DropdownMenuItem(value: e, child: Text(e))],
          onChanged: (v) {
            _entity = v!;
            _reload();
          },
        ),
        for (final s in [null, 'draft', 'reviewed', 'published', 'retired'])
          ChoiceChip(label: Text(s ?? '*'), selected: _status == s, onSelected: (_) {
            _status = s;
            _reload();
          }),
        OutlinedButton.icon(
          onPressed: () => _openEditor(context, null),
          icon: const Icon(Icons.add),
          label: Text(t.adminNew),
        ),
      ]),
      const Gap(FlSpace.m),
      FutureBuilder<Json>(
        future: _f,
        builder: (c, s) {
          if (s.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (s.hasError) return ErrorView(error: s.error!, onRetry: _reload);
          final items = (s.data!['items'] as List).cast<Json>();
          return Column(children: [
            for (final it in items)
              Card(
                margin: const EdgeInsets.only(bottom: FlSpace.s),
                child: ListTile(
                  title: Text(_keyOf(_entity, it)),
                  subtitle: Text((it['display_name'] ?? it['title_es'] ?? it['name_es'] ?? it['title'] ?? it['claim_es'] ?? '').toString(),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Text('${it['review_status']} · r${(it['_meta'] as Json)['revision']}'),
                  onTap: () => _openEditor(context, it),
                ),
              ),
          ]);
        },
      ),
    ]);
  }

  Future<void> _openEditor(BuildContext context, Json? item) async {
    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(
        builder: (_) => _RecordEditor(session: widget.session, entity: _entity, item: item)));
    if (changed ?? false) _reload();
  }
}

/// Editor genérico: campos simples como formulario; estructuras como JSON. Validación en el servidor.
class _RecordEditor extends ConsumerStatefulWidget {
  const _RecordEditor({required this.session, required this.entity, this.item});
  final AdminSession session;
  final String entity;
  final Json? item;
  @override
  ConsumerState<_RecordEditor> createState() => _RecordEditorState();
}

class _RecordEditorState extends ConsumerState<_RecordEditor> {
  final _ctrl = <String, TextEditingController>{};
  final _bools = <String, bool?>{};
  Json? _item;
  Object? _err;
  String? _msg;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _init();
  }

  void _init() {
    _ctrl.clear();
    _bools.clear();
    final src = _item ?? <String, dynamic>{};
    if (_item == null) {
      _ctrl['__json'] = TextEditingController(text: '{\n  \n}');
      return;
    }
    for (final e in src.entries) {
      if (e.key.startsWith('_') || e.key == 'review_status') continue;
      final v = e.value;
      if (v is bool) {
        _bools[e.key] = v;
      } else if (v is Map || v is List) {
        _ctrl[e.key] = TextEditingController(text: const JsonEncoder.withIndent('  ').convert(v));
      } else {
        _ctrl[e.key] = TextEditingController(text: v?.toString() ?? '');
      }
    }
  }

  Object? _parse(String k, String text) {
    final orig = _item?[k];
    if (orig is Map || orig is List) return jsonDecode(text);
    if (text.isEmpty) return null;
    if (orig is num || num.tryParse(text) != null && orig == null) return num.tryParse(text) ?? text;
    return text;
  }

  Future<void> _run(Future<Json> Function(ApiClient) f, String ok) async {
    setState(() {
      _err = null;
      _msg = null;
    });
    try {
      final j = await f(ref.read(apiClientProvider));
      setState(() {
        _item = j;
        _msg = ok;
        _init();
      });
    } on FormatException catch (e) {
      setState(() => _err = ApiException(422, 'json', e.message));
    } on Object catch (e) {
      setState(() => _err = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tok = widget.session.token;
    final item = _item;
    final base = '/api/v1/admin/${widget.entity}';
    return Scaffold(
      appBar: AppBar(title: Text(item == null ? t.adminNew : _keyOf(widget.entity, item))),
      body: PageBody(maxWidth: 820, children: [
        if (item != null) ...[
          Pill(icon: Icons.flag_outlined, label: '${item['review_status']} · r${(item['_meta'] as Json)['revision']}',
              background: context.fl.accentSoft),
          const Gap(FlSpace.m),
        ],
        for (final e in _bools.entries)
          SwitchListTile(title: Text(e.key), value: e.value ?? false, onChanged: (v) => setState(() => _bools[e.key] = v)),
        for (final e in _ctrl.entries) ...[
          TextField(
            controller: e.value,
            maxLines: (e.value.text.length > 80 || e.value.text.contains('\n')) ? null : 1,
            minLines: 1,
            style: e.key == '__json' || (item?[e.key] is Map || item?[e.key] is List)
                ? const TextStyle(fontFamily: 'monospace', fontSize: 13)
                : null,
            decoration: InputDecoration(labelText: e.key == '__json' ? 'JSON' : e.key),
          ),
          const Gap(FlSpace.m),
        ],
        if (_msg != null) Notice(_msg!, kind: 'info'),
        if (_err != null) _AdminError(_err!),
        const Gap(FlSpace.m),
        Notice(t.adminReviewWarning, kind: 'limitation'),
        const Gap(FlSpace.m),
        Wrap(spacing: FlSpace.s, runSpacing: FlSpace.s, children: [
          FilledButton(
            onPressed: () => _run((api) async {
              if (item == null) return api.post(base, jsonDecode(_ctrl['__json']!.text) as Object, bearer: tok);
              final changes = <String, Object?>{
                for (final e in _ctrl.entries) e.key: _parse(e.key, e.value.text),
                for (final e in _bools.entries) e.key: e.value,
              };
              return api.patch('$base/${_keyOf(widget.entity, item)}',
                  {'revision': (item['_meta'] as Json)['revision'], 'changes': changes}, bearer: tok);
            }, t.adminSaved),
            child: Text(t.adminSave),
          ),
          if (item != null)
            for (final (to, label) in [('reviewed', t.adminReview), ('draft', t.adminToDraft), ('retired', t.adminRetire)])
              OutlinedButton(
                onPressed: () => _run((api) => api.post('$base/${_keyOf(widget.entity, item)}/transition',
                    {'to': to, 'revision': (item['_meta'] as Json)['revision']}, bearer: tok), label),
                child: Text(label),
              ),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(t.close)),
        ]),
      ]),
    );
  }
}

class _AdminError extends StatelessWidget {
  const _AdminError(this.e);
  final Object e;
  @override
  Widget build(BuildContext context) {
    if (e is ApiException) {
      final x = e as ApiException;
      final detail = x.details.isEmpty ? '' : '\n${const JsonEncoder.withIndent('  ').convert(x.details)}';
      return Notice('${x.status} ${x.code}: ${x.message}$detail', kind: 'warning');
    }
    return ErrorView(error: e);
  }
}

class _Releases extends ConsumerStatefulWidget {
  const _Releases({required this.session});
  final AdminSession session;
  @override
  ConsumerState<_Releases> createState() => _ReleasesState();
}

class _ReleasesState extends ConsumerState<_Releases> {
  final _version = TextEditingController(), _notes = TextEditingController();
  late Future<Json> _f = _load();
  Json? _report;
  Object? _err;

  Future<Json> _load() => ref.read(apiClientProvider).get('/api/v1/admin/releases', bearer: widget.session.token);

  Future<void> _call(String path, Object body, {bool preview = false}) async {
    setState(() {
      _err = null;
      _report = null;
    });
    try {
      final j = await ref.read(apiClientProvider).post(path, body, bearer: widget.session.token);
      setState(() {
        _report = j;
        if (!preview) _f = _load();
      });
      if (!preview) {
        ref.invalidate(healthProvider);
        ref.invalidate(materialsProvider);
      }
    } on Object catch (e) {
      setState(() => _err = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final body = {'version': _version.text.trim(), if (_notes.text.isNotEmpty) 'notes': _notes.text};
    return PageBody(maxWidth: 900, children: [
      SectionCard(
        title: t.adminPublish,
        icon: Icons.publish_outlined,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextField(controller: _version, decoration: InputDecoration(labelText: t.adminVersion), onChanged: (_) => setState(() {})),
          const Gap(FlSpace.s),
          TextField(controller: _notes, decoration: const InputDecoration(labelText: 'Notas / Notes')),
          const Gap(FlSpace.m),
          Wrap(spacing: FlSpace.s, children: [
            OutlinedButton(onPressed: () => _call('/api/v1/admin/releases/preview', body, preview: true), child: Text(t.adminPreview)),
            FilledButton(onPressed: () => _call('/api/v1/admin/releases', body), child: Text(t.adminPublish)),
          ]),
          if (_err != null) ...[const Gap(FlSpace.m), _AdminError(_err!)],
          if (_report != null) ...[
            const Gap(FlSpace.m),
            Text(t.adminReport, style: context.text.titleMedium),
            SelectableText(const JsonEncoder.withIndent('  ').convert(_report), style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          ],
        ]),
      ),
      const Gap(FlSpace.l),
      FutureBuilder<Json>(
        future: _f,
        builder: (c, s) {
          if (s.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (s.hasError) return ErrorView(error: s.error!);
          return Column(children: [
            for (final r in (s.data!['items'] as List).cast<Json>())
              Card(
                margin: const EdgeInsets.only(bottom: FlSpace.s),
                child: ListTile(
                  title: Text(r['semantic_version'] as String),
                  subtitle: Text('${(r['checksum'] as String).substring(0, 12)}… · ${r['created_at']}'
                      '${r['contains_unreviewed_content'] == true ? ' · unreviewed' : ''}'),
                  trailing: r['is_active'] == true
                      ? Pill(icon: Icons.check, label: t.adminActive, background: context.fl.evidenceValidatedBg)
                      : TextButton(onPressed: () => _call('/api/v1/admin/releases/${r['id']}/activate', const {}),
                          child: Text(t.adminActivate)),
                ),
              ),
          ]);
        },
      ),
    ]);
  }
}

class _Audit extends ConsumerWidget {
  const _Audit({required this.session});
  final AdminSession session;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.read(apiClientProvider).get('/api/v1/admin/audit', query: {'limit': '200'}, bearer: session.token);
    return FutureBuilder<Json>(
      future: f,
      builder: (c, s) {
        if (s.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
        if (s.hasError) return ErrorView(error: s.error!);
        return PageBody(maxWidth: 900, children: [
          for (final a in (s.data!['items'] as List).cast<Json>())
            ListTile(
              dense: true,
              title: Text('${a['action']} · ${a['entity_type']} · ${a['entity_id']}'),
              subtitle: Text('${a['ts']} · ${a['actor_id'] ?? 'system'}'),
            ),
        ]);
      },
    );
  }
}
