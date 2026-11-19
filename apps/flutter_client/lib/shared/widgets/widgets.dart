import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n.dart';
import '../../core/design_system/tokens.dart';
import '../../core/networking/api_client.dart';
import '../models/models.dart';

/// Contenedor de página: ancho máximo, márgenes adaptables y desplazamiento vertical.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children, this.maxWidth = FlLayout.maxContentWidth, this.padding});
  final List<Widget> children;
  final double maxWidth;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final side = w < 400 ? FlSpace.l : FlSpace.xl;
    return SingleChildScrollView(
      padding: padding ?? EdgeInsets.fromLTRB(side, FlSpace.s, side, FlSpace.xxxl),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
        ),
      ),
    );
  }
}

class Gap extends StatelessWidget {
  const Gap(this.size, {super.key});
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox(height: size, width: size);
}

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, this.title, this.icon, required this.child, this.trailing, this.color});
  final String? title;
  final IconData? icon;
  final Widget child;
  final Widget? trailing;
  final Color? color;

  @override
  Widget build(BuildContext context) => Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(FlSpace.l),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: FlSpace.m),
                child: Row(children: [
                  if (icon != null) ...[Icon(icon, size: 20, color: context.fl.textSecondary), const Gap(FlSpace.s)],
                  Expanded(child: Semantics(header: true, child: Text(title!, style: context.text.titleMedium))),
                  ?trailing,
                ]),
              ),
            child,
          ]),
        ),
      );
}

/// Insignia de evidencia: SIEMPRE icono + texto, nunca solo color (doc 07 §13.4).
class EvidenceBadge extends StatelessWidget {
  const EvidenceBadge(this.level, {super.key});
  final EvidenceLevel level;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final (icon, bg) = switch (level) {
      EvidenceLevel.validated => (Icons.verified_outlined, context.fl.evidenceValidatedBg),
      EvidenceLevel.boundedEstimate => (Icons.straighten, context.fl.evidenceValidatedBg),
      EvidenceLevel.qualitative => (Icons.lightbulb_outline, context.fl.evidenceLimitedBg),
      EvidenceLevel.insufficientEvidence => (Icons.help_outline, context.fl.evidenceLimitedBg),
      EvidenceLevel.unsupported => (Icons.block, context.fl.warningBg),
    };
    return Pill(icon: icon, label: t.level(level), background: bg);
  }
}

class CompatBadge extends StatelessWidget {
  const CompatBadge(this.status, {super.key});
  final CompatibilityStatus? status;
  @override
  Widget build(BuildContext context) {
    final (icon, bg) = switch (status) {
      CompatibilityStatus.supported => (Icons.check_circle_outline, context.fl.evidenceValidatedBg),
      CompatibilityStatus.conditional => (Icons.rule, context.fl.evidenceLimitedBg),
      CompatibilityStatus.educationalOnly => (Icons.school_outlined, context.fl.accentSoft),
      _ => (Icons.block, context.fl.warningBg),
    };
    return Pill(icon: icon, label: context.t.compat(status), background: bg);
  }
}

class Pill extends StatelessWidget {
  const Pill({super.key, required this.icon, required this.label, required this.background});
  final IconData icon;
  final String label;
  final Color background;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(FlRadius.chip)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: context.fl.textPrimary),
          const SizedBox(width: 6),
          Flexible(child: Text(label, style: context.text.labelLarge?.copyWith(fontSize: 13))),
        ]),
      );
}

/// Aviso con icono + texto. `kind`: info | limitation | warning.
class Notice extends StatelessWidget {
  const Notice(this.text, {super.key, this.kind = 'info', this.icon});
  final String text;
  final String kind;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    final bg = switch (kind) {
      'warning' => context.fl.warningBg,
      'limitation' => context.fl.evidenceLimitedBg,
      _ => context.fl.accentSoft,
    };
    final ic = icon ?? switch (kind) {
      'warning' => Icons.report_gmailerrorred,
      'limitation' => Icons.info_outline,
      _ => Icons.info_outline,
    };
    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.all(FlSpace.m),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(FlRadius.input)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(ic, size: 20, color: context.fl.textPrimary),
          const Gap(FlSpace.s),
          Expanded(child: Text(text, style: context.text.bodyMedium)),
        ]),
      ),
    );
  }
}

/// Pantalla de error: distingue red (reintentar) de error de API (código de soporte).
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, this.onRetry});
  final Object error;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final String msg;
    String? support;
    if (error is NetworkException) {
      msg = t.networkError;
    } else if (error is ApiException) {
      final e = error as ApiException;
      msg = e.status == 429 ? t.rateLimited : (e.status >= 500 ? t.internalError : e.message);
      support = e.requestId;
    } else {
      msg = t.internalError;
    }
    return Padding(
      padding: const EdgeInsets.all(FlSpace.l),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Notice(msg, kind: 'warning', icon: error is NetworkException ? Icons.wifi_off : null),
        if (support != null) Padding(
          padding: const EdgeInsets.only(top: FlSpace.s),
          child: SelectableText(t.supportCode(support), style: context.text.bodySmall),
        ),
        if (onRetry != null) ...[
          const Gap(FlSpace.m),
          OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: Text(t.networkRetry)),
        ],
      ]),
    );
  }
}

/// Muestra un `AsyncValue` con carga, error (con reintento) y datos.
class AsyncBody<T> extends ConsumerWidget {
  const AsyncBody({super.key, required this.value, required this.data, this.onRetry});
  final AsyncValue<T> value;
  final Widget Function(T) data;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context, WidgetRef ref) => value.when(
        data: data,
        loading: () => Padding(
          padding: const EdgeInsets.all(FlSpace.xxl),
          child: Center(child: Semantics(label: context.t.loading, child: const CircularProgressIndicator())),
        ),
        error: (e, _) => ErrorView(error: e, onRetry: onRetry),
      );
}

class StepHeader extends StatelessWidget {
  const StepHeader({super.key, required this.step, required this.total, required this.title});
  final int step, total;
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: FlSpace.l),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(context.t.stepOf(step, total), style: context.text.bodySmall),
          const Gap(FlSpace.xs),
          LinearProgressIndicator(value: step / total, minHeight: 4, borderRadius: BorderRadius.circular(4),
              color: FlColors.yellowGreen, backgroundColor: context.fl.border),
          const Gap(FlSpace.m),
          Semantics(header: true, child: Text(title, style: context.text.headlineSmall)),
        ]),
      );
}

class KeyValue extends StatelessWidget {
  const KeyValue(this.k, this.v, {super.key, this.trailing});
  final String k, v;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 130, child: Text(k, style: context.text.bodySmall)),
          Expanded(child: Text(v, style: context.text.bodyMedium)),
          ?trailing,
        ]),
      );
}

class SourceTile extends StatelessWidget {
  const SourceTile(this.s, {super.key});
  final SourceRef s;
  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final meta = [s.authors, if (s.year != null) '${s.year}', s.edition, s.doi != null ? 'DOI ${s.doi}' : null]
        .whereType<String>()
        .join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FlSpace.s),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(s.verified ? Icons.verified_outlined : Icons.menu_book_outlined, size: 20,
            color: context.fl.textSecondary),
        const Gap(FlSpace.s),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.title, style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            if (meta.isNotEmpty) Text(meta, style: context.text.bodySmall),
            if (s.locator != null) Text(s.locator!, style: context.text.bodySmall),
            if (s.url != null) SelectableText(s.url!, style: context.text.bodySmall),
            Text(s.verified ? t.sourceVerified : t.sourceUnverified, style: context.text.bodySmall),
          ]),
        ),
      ]),
    );
  }
}

String fmtNum(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

String fmtDuration(double seconds) {
  final s = seconds.round();
  final h = s ~/ 3600, m = (s % 3600) ~/ 60, r = s % 60;
  if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}m';
  return '${m}m ${r.toString().padLeft(2, '0')}s';
}
