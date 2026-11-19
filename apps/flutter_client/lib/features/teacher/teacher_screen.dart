import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n.dart';
import '../../app/providers.dart';
import '../../core/design_system/tokens.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';

/// Código de actividad (FR-20): codifica SOLO la configuración; no identifica a nadie.
abstract final class ActivityCode {
  static const _materials = ['aisi_1045', 'aisi_8620', 'en_gjl_250'];
  static const _treatments = ['quench', 'temper', 'quench_temper', 'anneal', 'normalize', 'austemper', 'martemper'];

  static String encode(SimulationInput i) {
    final raw = '1|${_materials.indexOf(i.materialId)}|${_treatments.indexOf(i.treatmentId)}|'
        '${i.targetTemperatureC.round()}|${i.holdTimeMin.round()}';
    return 'FL-${base64Url.encode(utf8.encode(raw)).replaceAll('=', '')}';
  }

  static SimulationInput? decode(String code) {
    try {
      var b = code.trim().replaceFirst(RegExp('^FL-', caseSensitive: false), '');
      while (b.length % 4 != 0) {
        b += '=';
      }
      final p = utf8.decode(base64Url.decode(b)).split('|');
      if (p.length != 5 || p[0] != '1') return null;
      final m = int.parse(p[1]), tr = int.parse(p[2]);
      final temp = double.parse(p[3]), hold = double.parse(p[4]);
      if (m < 0 || m >= 3 || tr < 0 || tr >= 6 || temp < 20 || temp > 1600 || hold < 0 || hold > 1440) return null;
      return SimulationInput(materialId: _materials[m], treatmentId: _treatments[tr], targetTemperatureC: temp, holdTimeMin: hold);
    } on Object {
      return null;
    }
  }
}

class TeacherScreen extends ConsumerStatefulWidget {
  const TeacherScreen({super.key});
  @override
  ConsumerState<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends ConsumerState<TeacherScreen> {
  final _code = TextEditingController();
  String? _created, _err;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final sim = ref.watch(simulationProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.teacherTitle)),
      body: PageBody(maxWidth: 720, children: [
        Notice(t.teacherIntro, kind: 'info', icon: Icons.co_present_outlined),
        const Gap(FlSpace.l),
        SectionCard(
          title: t.teacherCreate,
          icon: Icons.qr_code_2,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (!sim.configured) Text(t.teacherNoConfig)
            else ...[
              Text('${sim.materialId} · ${sim.treatmentId} · ${fmtNum(sim.temperatureC)} °C · ${fmtNum(sim.holdMin)} min'),
              const Gap(FlSpace.m),
              FilledButton(
                onPressed: () => setState(() => _created = ActivityCode.encode(sim.input!)),
                child: Text(t.teacherCreate),
              ),
            ],
            if (_created != null) ...[
              const Gap(FlSpace.m),
              Text(t.teacherCode, style: context.text.bodySmall),
              Row(children: [
                Expanded(child: SelectableText(_created!, style: context.text.headlineSmall)),
                IconButton(onPressed: () => Clipboard.setData(ClipboardData(text: _created!)), icon: const Icon(Icons.copy)),
              ]),
            ],
          ]),
        ),
        const Gap(FlSpace.m),
        SectionCard(
          title: t.teacherEnter,
          icon: Icons.input,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextField(controller: _code, decoration: InputDecoration(hintText: 'FL-…', errorText: _err)),
            const Gap(FlSpace.m),
            FilledButton(
              onPressed: () {
                final cfg = ActivityCode.decode(_code.text);
                if (cfg == null) {
                  setState(() => _err = t.teacherInvalid);
                  return;
                }
                ref.read(simulationProvider.notifier).loadConfig(cfg);
                context.push('/lab/params');
              },
              child: Text(t.teacherLoad),
            ),
          ]),
        ),
      ]),
    );
  }
}
