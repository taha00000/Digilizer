import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/bottom_tab_bar.dart';
import '../../../../shared/widgets/cta_button.dart';
import '../../../../shared/widgets/donut_gauge.dart';
import '../../../../shared/widgets/option_sheet.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/report_output.dart';
import '../providers/reports_providers.dart';

/// Activity Details output (`reportOutScreen`) — pick date + member, run the
/// report, then read the visit summary and coverage.
class ReportOutputScreen extends ConsumerWidget {
  const ReportOutputScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final date = ref.watch(reportDateProvider);
    final member = ref.watch(reportMemberProvider);
    final result = ref.watch(reportRunnerProvider);
    final running = result is AsyncLoading;

    Future<void> pick({
      required String title,
      required List<String> options,
      required void Function(String) onPicked,
    }) async {
      final choice = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => _PickerSheet(title: title, options: options),
      );
      if (choice != null) onPicked(choice);
    }

    return AppShell(
      title: 'Activity Details',
      subtitle: 'Call report',
      tab: AppTab.reports,
      onBack: () => context.go('/reports'),
      children: [
        FieldRow(
          label: 'Date',
          value: date,
          onTap: () => pick(
            title: 'Select date',
            options: const [
              '17 Jun 2026',
              '16 Jun 2026',
              '15 Jun 2026',
              '14 Jun 2026',
            ],
            onPicked: (v) => ref.read(reportDateProvider.notifier).state = v,
          ),
        ),
        FieldRow(
          label: 'Team member',
          value: member,
          onTap: () => pick(
            title: 'Select team member',
            options: const [
              'Gohar Zaman · 004324',
              'Raheel Zafar · 004200',
              'Zia Muhammad · 004196',
              'Imran Zafar · 004291',
            ],
            onPicked: (v) => ref.read(reportMemberProvider.notifier).state = v,
          ),
        ),
        const SizedBox(height: 4),
        CtaButton(
          label: running ? 'Generating…' : 'View report',
          onTap: running
              ? null
              : () => ref
                  .read(reportRunnerProvider.notifier)
                  .run(member: member.split(' · ').first),
        ),
        if (result != null) ...[
          const SizedBox(height: 16),
          result.when(
            loading: () => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: CircularProgressIndicator(color: t.primary),
              ),
            ),
            error: (e, _) => AppCard(
              child: Text(
                '$e',
                style: TextStyle(color: t.rose, fontSize: 12.5),
              ),
            ),
            data: (r) => _Output(report: r),
          ),
        ],
      ],
    );
  }
}

/// The prototype's doExport(): PDF / Excel / share link.
///
/// TODO(real-api): PDF and Excel need the server to render the file; the share
/// link needs a signed URL. Until those exist this confirms the choice rather
/// than pretending a file was produced.
Future<void> _export(BuildContext context) async {
  final choice = await OptionSheet.show(
    context,
    title: 'Export report',
    subtitle: 'Choose a format.',
    options: const [
      SheetOption(
        id: 'pdf',
        icon: Icons.picture_as_pdf_outlined,
        title: 'PDF document',
        subtitle: '.pdf',
      ),
      SheetOption(
        id: 'xls',
        icon: Icons.table_chart_outlined,
        title: 'Excel spreadsheet',
        subtitle: '.xlsx',
      ),
      SheetOption(
        id: 'link',
        icon: Icons.link_rounded,
        title: 'Share link',
        subtitle: 'copy link',
      ),
    ],
  );
  if (choice == null || !context.mounted) return;

  final message = switch (choice) {
    'link' => 'Shareable links arrive with the real API.',
    'xls' => 'Excel export arrives with the real API.',
    _ => 'PDF export arrives with the real API.',
  };
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

class _Output extends StatelessWidget {
  const _Output({required this.report});
  final ReportOutput report;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InfoToast(
          lead: 'Report ready.',
          body: '${report.visits.length} visits for ${report.member} on '
              '${report.date}. Pull to refresh for live data.',
        ),
        SectionTitle(
          'Visit summary',
          trailing: SectionLink(
            'Export',
            onTap: () => _export(context),
          ),
        ),
        _VisitTable(visits: report.visits),
        const SectionTitle('Coverage'),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DONE',
                        style: TextStyle(
                          color: t.sub,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.35,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${report.done}',
                        style: TextStyle(
                          color: t.ink,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'COMPLETION',
                        style: TextStyle(
                          color: t.sub,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.35,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${report.completionPct}%',
                        style: TextStyle(
                          color: t.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 42,
                        child: Row(
                          children: [
                            DonutGauge.progress(
                              percent: report.completionPct.toDouble(),
                              color: t.primary,
                              trackColor: t.primarySoft,
                              size: 42,
                              thickness: 6,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${report.done} of ${report.planned}\nplanned',
                                style: TextStyle(
                                  color: t.sub,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Mirrors `.tablecard` from the brand table, with the report's columns.
class _VisitTable extends StatelessWidget {
  const _VisitTable({required this.visits});
  final List<ReportVisit> visits;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            decoration: BoxDecoration(
              color: t.primarySoft,
              border: Border(bottom: BorderSide(color: t.line)),
            ),
            child: Row(
              children: [
                _head(t, 'Time', 2),
                _head(t, 'Doctor', 3),
                _head(t, 'Type', 2),
                _head(t, 'Status', 2),
              ],
            ),
          ),
          for (var i = 0; i < visits.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 13,
              ),
              decoration: BoxDecoration(
                border: i == visits.length - 1
                    ? null
                    : Border(bottom: BorderSide(color: t.line)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      visits[i].time,
                      style: TextStyle(color: t.ink, fontSize: 12.5),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      visits[i].doctor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: t.ink,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      visits[i].type,
                      style: TextStyle(
                        color: t.sub,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: StatusBadge(
                        visits[i].statusLabel,
                        tone: switch (visits[i].status) {
                          ReportVisitStatus.done => BadgeTone.good,
                          ReportVisitStatus.logged => BadgeTone.warn,
                          ReportVisitStatus.missed => BadgeTone.bad,
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _head(AppTokens t, String label, int flex) => Expanded(
        flex: flex,
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: t.primaryDark,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.32,
          ),
        ),
      );
}

/// `.sheet-pop` — the date / team-member picker.
class _PickerSheet extends StatelessWidget {
  const _PickerSheet({required this.title, required this.options});

  final String title;
  final List<String> options;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.line)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: t.line,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: t.ink,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            for (final o in options)
              InkWell(
                onTap: () => Navigator.of(context).pop(o),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 13,
                  ),
                  child: Text(
                    o,
                    style: TextStyle(
                      color: t.ink,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
