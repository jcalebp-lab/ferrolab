import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n.dart';
import '../../app/providers.dart';
import '../../core/design_system/tokens.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';
import 'furnace_painter.dart';
import 'playback.dart';
import 'thermal_chart.dart';

class FurnaceScreen extends ConsumerWidget {
  const FurnaceScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final sim = ref.watch(simulationProvider);
    final r = sim.result;
    Widget body;
    if (sim.phase == SimPhase.running || (r == null && sim.error == null)) {
      body = PageBody(maxWidth: 900, children: [
        SizedBox(height: 260, child: CustomPaint(painter: FurnacePainter.idle(Theme.of(context).brightness))),
        const Gap(FlSpace.l),
        Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          const Gap(FlSpace.m),
          Text(t.furnaceRunning),
        ])),
      ]);
    } else if (r == null) {
      // Error de red: la configuración se conserva y se puede reintentar sin duplicar.
      body = PageBody(children: [ErrorView(error: sim.error!, onRetry: () => ref.read(simulationProvider.notifier).run())]);
    } else {
      final pb = Playback.from(r);
      body = pb == null
          ? PageBody(maxWidth: 900, children: [
              // Rechazo científico: no se anima como si hubiera cálculo (doc 10 §13).
              Notice(t.status(r.status), kind: 'warning'),
              const Gap(FlSpace.m),
              for (final w in r.warnings.where((w) => w.severity != 'info'))
                Padding(padding: const EdgeInsets.only(bottom: FlSpace.s), child: Notice(w.message, kind: 'limitation')),
              const Gap(FlSpace.l),
              FilledButton(onPressed: () => context.pushReplacement('/lab/results'), child: Text(t.furnaceSeeResults)),
            ])
          : _Player(result: r, playback: pb);
    }
    return Scaffold(appBar: AppBar(title: Text(t.furnaceTitle)), body: body);
  }
}

class _Player extends StatefulWidget {
  const _Player({required this.result, required this.playback});
  final SimulationResultDto result;
  final Playback playback;
  @override
  State<_Player> createState() => _PlayerState();
}

class _PlayerState extends State<_Player> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
        duration: Duration(milliseconds: (widget.playback.totalDisplay * 1000).round()));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.of(context).disableAnimations) {
        _c.value = 1; // movimiento reducido: estado final sin animación
      } else {
        _c.forward();
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final reduced = MediaQuery.of(context).disableAnimations;
    final pb = widget.playback;
    final r = widget.result;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final displayT = _c.value * pb.totalDisplay;
        final f = pb.frameAt(displayT);
        final wide = MediaQuery.sizeOf(context).width >= FlLayout.desktopBreakpoint;
        final furnace = SectionCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(
              height: 250,
              child: CustomPaint(
                painter: FurnacePainter(
                  visualTemp: f.visualTemp,
                  inFurnace: f.segment.inFurnace,
                  brightness: Theme.of(context).brightness,
                  stageKind: f.segment.kind,
                  pulse: (displayT * 2) % 1,
                ),
              ),
            ),
            const Gap(FlSpace.s),
            Text(t.furnaceVisualDisclaimer, textAlign: TextAlign.center, style: context.text.bodySmall),
            const Gap(FlSpace.m),
            _Readout(frame: f, playback: pb, result: r),
            const Gap(FlSpace.m),
            if (reduced) Notice(t.furnaceReducedMotion, kind: 'info'),
            _Controls(controller: _c, reduced: reduced),
          ]),
        );
        final chart = SectionCard(
          title: t.chartTitle,
          icon: Icons.show_chart,
          child: ThermalChart(result: r, playback: pb, cursorDisplayT: displayT),
        );
        final cta = FilledButton.icon(
          key: const Key('seeResults'),
          onPressed: () => context.pushReplacement('/lab/results'),
          icon: const Icon(Icons.fact_check_outlined),
          label: Text(t.furnaceSeeResults),
        );
        return PageBody(maxWidth: 1160, children: [
          if (wide)
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: furnace),
              const Gap(FlSpace.l),
              Expanded(child: chart),
            ])
          else ...[furnace, const Gap(FlSpace.l), chart],
          const Gap(FlSpace.l),
          cta,
        ]);
      },
    );
  }
}

class _Readout extends StatelessWidget {
  const _Readout({required this.frame, required this.playback, required this.result});
  final PlaybackFrame frame;
  final Playback playback;
  final SimulationResultDto result;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final label = result.protocol?.labelFor(frame.segment.labelKey) ?? frame.segment.labelKey;
    String temp;
    String? phys;
    if (playback.physical) {
      temp = '${frame.temperatureC!.round()} °C';
      phys = fmtDuration(frame.physicalTimeS!);
    } else {
      final s = frame.segment.schematic!;
      temp = switch (s.endLevel) {
        SchematicLevel.target => t.furnaceYourTarget(fmtNum(s.endTemperatureC!)),
        SchematicLevel.ambient => t.furnaceAmbient,
        SchematicLevel.bath => t.furnaceBath,
      };
      phys = s.durationS != null ? t.furnaceYourHold(fmtNum(s.durationS! / 60)) : t.furnaceDurationUnpublished;
    }
    Widget cell(String k, String v, {bool big = false}) => Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(k, style: context.text.bodySmall),
            Text(v,
                style: (big ? context.text.titleLarge : context.text.bodyLarge)
                    ?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
          ]),
        );
    return Semantics(
      liveRegion: true,
      label: '${t.furnaceStage}: $label. ${t.furnaceTemp}: $temp',
      child: Column(children: [
        Row(children: [cell(t.furnaceStage, label), cell(t.furnaceTemp, temp, big: playback.physical)]),
        const Gap(FlSpace.s),
        Row(children: [
          cell(t.furnacePhysicalTime, phys),
          cell(t.furnaceAnimTime, '${frame.displayTimeS.toStringAsFixed(1)} / ${playback.totalDisplay.toStringAsFixed(1)} s'),
        ]),
        const Gap(FlSpace.xs),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            playback.physical ? t.furnaceSpeed(playback.speedFactor!.toStringAsFixed(0)) : t.furnaceSchematicSpeed,
            style: context.text.bodySmall,
          ),
        ),
      ]),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.controller, required this.reduced});
  final AnimationController controller;
  final bool reduced;
  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final playing = controller.isAnimating;
    return Wrap(alignment: WrapAlignment.center, spacing: FlSpace.s, children: [
      if (!reduced)
        IconButton.filledTonal(
          tooltip: playing ? t.furnacePause : t.furnacePlay,
          onPressed: () => playing ? controller.stop() : controller.forward(),
          icon: Icon(playing ? Icons.pause : Icons.play_arrow),
        ),
      if (!reduced)
        IconButton.filledTonal(
          tooltip: t.furnaceRestart,
          onPressed: () => controller.forward(from: 0),
          icon: const Icon(Icons.replay),
        ),
      // Saltar NO recalcula: va a la última muestra del mismo historial.
      IconButton.filledTonal(
        tooltip: t.furnaceSkip,
        onPressed: () {
          controller.stop();
          controller.value = 1;
        },
        icon: const Icon(Icons.skip_next),
      ),
    ]);
  }
}
