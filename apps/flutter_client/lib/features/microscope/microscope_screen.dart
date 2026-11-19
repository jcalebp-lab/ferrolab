import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n.dart';
import '../../app/providers.dart';
import '../../core/design_system/tokens.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';
import 'microstructure_view.dart';

/// Microscopio virtual (doc 07 §3.6): solo imágenes con licencia verificada y coincidencia documentada.
class MicroscopeScreen extends ConsumerWidget {
  const MicroscopeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final r = ref.watch(simulationProvider).result;
    final m = r?.micrograph;
    final spec = r?.illustration;
    final drawable = spec != null && (spec['family'] == 'gray_cast_iron' || spec['fractions'] != null);
    return Scaffold(
      appBar: AppBar(title: Text(t.microTitle)),
      body: PageBody(maxWidth: 900, children: [
        if (drawable) ...[
          Text(t.microGeneratedTitle, style: context.text.titleLarge),
          const Gap(FlSpace.s),
          Notice(spec['quantitative'] == true ? t.microGeneratedNote : t.microQualitativeNote, kind: 'info',
              icon: Icons.brush_outlined),
          const Gap(FlSpace.m),
          GeneratedMicroscope(spec: spec, height: 640),
          const Gap(FlSpace.m),
          MicroLegend(spec: spec),
          const Gap(FlSpace.xl),
        ],
        if (!drawable && spec != null) ...[
          Notice(t.microReason(spec['reason'] as String? ?? 'not_computed'), kind: 'limitation',
              icon: Icons.image_not_supported_outlined),
          const Gap(FlSpace.xl),
        ],
        if (m != null) ...[
          Text(t.microRealTitle, style: context.text.titleLarge),
          const Gap(FlSpace.s),
          MicrographViewer(m: m),
          const Gap(FlSpace.xl),
        ],
        if (r != null && r.relatedMicrographs.isNotEmpty) ...[
          Text(t.microRelatedTitle, style: context.text.titleLarge),
          const Gap(FlSpace.s),
          Notice(t.microRelatedNote, kind: 'info', icon: Icons.photo_library_outlined),
          const Gap(FlSpace.m),
          for (final x in r.relatedMicrographs) ...[MicrographViewer(m: x), const Gap(FlSpace.xl)],
        ],
        if (m == null && (r == null || r.relatedMicrographs.isEmpty)) ...[
          const Icon(Icons.image_not_supported_outlined, size: 64),
          const Gap(FlSpace.l),
          Text(t.microNoMatch, style: context.text.titleLarge, textAlign: TextAlign.center),
          const Gap(FlSpace.m),
          Text(t.microNoMatchBody, textAlign: TextAlign.center),
        ],
      ]),
    );
  }
}

class MicrographViewer extends ConsumerStatefulWidget {
  const MicrographViewer({super.key, required this.m});
  final MicrographDto m;
  @override
  ConsumerState<MicrographViewer> createState() => _MicrographViewerState();
}

class _MicrographViewerState extends ConsumerState<MicrographViewer> {
  final _tc = TransformationController();
  double _zoom = 1;
  static const _maxZoom = 4.0; // límite: el zoom digital no crea detalle

  void _set(double z) {
    setState(() => _zoom = z.clamp(1, _maxZoom));
    _tc.value = Matrix4.identity()..scaleByDouble(_zoom, _zoom, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final m = widget.m;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (m.specimen != null) ...[
        Notice(t.microSpecimen(m.specimen!), kind: m.matchQuality == 'illustrative' ? 'limitation' : 'info',
            icon: Icons.science_outlined),
        const Gap(FlSpace.s),
      ],
      ClipRRect(
        borderRadius: BorderRadius.circular(FlRadius.card),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: ColoredBox(
            color: Colors.black,
            child: InteractiveViewer(
              transformationController: _tc,
              minScale: 1,
              maxScale: _maxZoom,
              onInteractionEnd: (_) => setState(() => _zoom = _tc.value.getMaxScaleOnAxis()),
              child: Image.network(
                m.displayUrl(ref.watch(apiClientProvider).baseUrl),
                fit: BoxFit.contain,
                semanticLabel: m.alt,
                loadingBuilder: (c, child, p) => p == null
                    ? child
                    : const Center(child: CircularProgressIndicator()),
                errorBuilder: (c, e, s) => Center(
                    child: Padding(padding: const EdgeInsets.all(FlSpace.l),
                        child: Text(t.microLoadError, style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center))),
              ),
            ),
          ),
        ),
      ),
      const Gap(FlSpace.s),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(tooltip: t.microZoomOut, onPressed: () => _set(_zoom / 1.5), icon: const Icon(Icons.zoom_out)),
        Text('${t.microDigitalZoom}: ${_zoom.toStringAsFixed(1)}×'),
        IconButton(tooltip: t.microZoomIn, onPressed: () => _set(_zoom * 1.5), icon: const Icon(Icons.zoom_in)),
      ]),
      Text(m.calibrated && m.scaleBarUm != null ? t.microScaleCalibrated(fmtNum(m.scaleBarUm!))
          : (m.magnificationX != null ? t.microOriginalMag(fmtNum(m.magnificationX!)) : t.microScaleMissing),
          textAlign: TextAlign.center, style: context.text.bodySmall),
      if (m.constituents.isNotEmpty) ...[
        const Gap(FlSpace.s),
        Wrap(alignment: WrapAlignment.center, spacing: FlSpace.xs, runSpacing: FlSpace.xs, children: [
          for (final c in m.constituents)
            Pill(icon: Icons.blur_on, label: t.constituent(c), background: context.fl.accentSoft),
        ]),
      ],
      const Gap(FlSpace.s),
      Text(m.alt, style: context.text.bodyMedium),
      const Gap(FlSpace.s),
      ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(t.microAttribution),
        subtitle: Text('${m.author} · ${m.licenseCode}', style: context.text.bodySmall),
        children: [
          KeyValue(t.microAuthor, m.author),
          KeyValue(t.microLicense, '${m.licenseCode} — ${m.licenseUrl}'),
          if (m.pageUrl != null) KeyValue(t.microSourcePage, m.pageUrl!),
          KeyValue(t.microMethod, switch (m.imagingMethod) {
            'sem' => t.microMethodSem,
            'tem' => t.microMethodTem,
            'optical' => t.microMethodOptical,
            _ => m.imagingMethod,
          }),
          if (m.preparation != null) KeyValue(t.microPreparation, m.preparation!),
          KeyValue(t.microMatch, t.microMatchLabel(m.matchQuality)),
          KeyValue('', m.attribution),
        ],
      ),
    ]);
  }
}

class MicrographLibraryScreen extends ConsumerStatefulWidget {
  const MicrographLibraryScreen({super.key});
  @override
  ConsumerState<MicrographLibraryScreen> createState() => _MicrographLibraryScreenState();
}

class _MicrographLibraryScreenState extends ConsumerState<MicrographLibraryScreen> {
  String? _filter;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final list = ref.watch(micrographsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.homeMicro)),
      body: PageBody(maxWidth: 900, children: [
        AsyncBody(
          value: list,
          onRetry: () => ref.invalidate(micrographsProvider),
          data: (items) {
            if (items.isEmpty) {
              return Column(children: [
                const Icon(Icons.photo_library_outlined, size: 64),
                const Gap(FlSpace.l),
                Text(t.microLibraryEmpty, textAlign: TextAlign.center, style: context.text.titleMedium),
                const Gap(FlSpace.m),
                Text(t.microNoMatchBody, textAlign: TextAlign.center),
              ]);
            }
            final cons = <String>{for (final m in items) ...m.constituents}.toList()..sort();
            final shown = _filter == null ? items : items.where((m) => m.constituents.contains(_filter)).toList();
            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Notice(t.microLibraryNote(items.length.toString()), kind: 'info', icon: Icons.photo_library_outlined),
              const Gap(FlSpace.m),
              Wrap(spacing: FlSpace.xs, runSpacing: FlSpace.xs, children: [
                ChoiceChip(label: Text(t.microFilterAll), selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null)),
                for (final c in cons)
                  ChoiceChip(label: Text(t.constituent(c)), selected: _filter == c,
                      onSelected: (_) => setState(() => _filter = c)),
              ]),
              const Gap(FlSpace.l),
              for (final m in shown) ...[MicrographViewer(key: ValueKey(m.id), m: m), const Gap(FlSpace.xl)],
            ]);
          },
        ),
      ]),
    );
  }
}
