import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n.dart';
import '../../app/providers.dart';
import '../../core/design_system/tokens.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';

/// Microscopio virtual (doc 07 §3.6): solo imágenes con licencia verificada y coincidencia documentada.
class MicroscopeScreen extends ConsumerWidget {
  const MicroscopeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final m = ref.watch(simulationProvider).result?.micrograph;
    return Scaffold(
      appBar: AppBar(title: Text(t.microTitle)),
      body: PageBody(maxWidth: 900, children: [
        if (m == null) ...[
          const Icon(Icons.image_not_supported_outlined, size: 64),
          const Gap(FlSpace.l),
          Text(t.microNoMatch, style: context.text.titleLarge, textAlign: TextAlign.center),
          const Gap(FlSpace.m),
          Text(t.microNoMatchBody, textAlign: TextAlign.center),
        ] else
          MicrographViewer(m: m),
      ]),
    );
  }
}

class MicrographViewer extends StatefulWidget {
  const MicrographViewer({super.key, required this.m});
  final MicrographDto m;
  @override
  State<MicrographViewer> createState() => _MicrographViewerState();
}

class _MicrographViewerState extends State<MicrographViewer> {
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
      ClipRRect(
        borderRadius: BorderRadius.circular(FlRadius.card),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: InteractiveViewer(
            transformationController: _tc,
            minScale: 1,
            maxScale: _maxZoom,
            onInteractionEnd: (_) => setState(() => _zoom = _tc.value.getMaxScaleOnAxis()),
            child: Image.network(m.imageUrl, fit: BoxFit.contain, semanticLabel: m.alt,
                errorBuilder: (c, e, s) => Center(child: Text(t.internalError))),
          ),
        ),
      ),
      const Gap(FlSpace.s),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(tooltip: t.microZoomOut, onPressed: () => _set(_zoom / 1.5), icon: const Icon(Icons.zoom_out)),
        Text('${t.microDigitalZoom}: ${_zoom.toStringAsFixed(1)}×'),
        IconButton(tooltip: t.microZoomIn, onPressed: () => _set(_zoom * 1.5), icon: const Icon(Icons.zoom_in)),
      ]),
      Text(m.calibrated && m.scaleBarUm != null ? t.microScaleCalibrated(fmtNum(m.scaleBarUm!)) : t.microScaleMissing,
          textAlign: TextAlign.center, style: context.text.bodySmall),
      const Gap(FlSpace.l),
      SectionCard(
        title: t.microAttribution,
        child: Column(children: [
          KeyValue(t.microAttribution, '${m.author} · ${m.licenseCode}'),
          KeyValue('', m.attribution),
          KeyValue('URL', m.licenseUrl),
          KeyValue('Técnica / Method', '${m.imagingMethod}${m.magnificationX != null ? ' · ${fmtNum(m.magnificationX!)}×' : ''}'),
          KeyValue('Match', m.matchQuality),
        ]),
      ),
    ]);
  }
}

class MicrographLibraryScreen extends ConsumerWidget {
  const MicrographLibraryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final list = ref.watch(micrographsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.homeMicro)),
      body: PageBody(maxWidth: 900, children: [
        AsyncBody(
          value: list,
          onRetry: () => ref.invalidate(micrographsProvider),
          data: (items) => items.isEmpty
              ? Column(children: [
                  const Icon(Icons.photo_library_outlined, size: 64),
                  const Gap(FlSpace.l),
                  Text(t.microLibraryEmpty, textAlign: TextAlign.center, style: context.text.titleMedium),
                  const Gap(FlSpace.m),
                  Text(t.microNoMatchBody, textAlign: TextAlign.center),
                ])
              : Column(children: [for (final m in items) ...[MicrographViewer(m: m), const Gap(FlSpace.xl)]]),
        ),
      ]),
    );
  }
}
