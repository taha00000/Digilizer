/// Outcome of a visit as shown in a generated report.
enum ReportVisitStatus { done, logged, missed }

/// One row of the report's visit summary table.
///
/// Deliberately a separate type from the Call Reporting `Visit`: features stay
/// isolated (HANDOFF.md §5.7), and the report is a server-rendered summary
/// that will diverge from the live visit list once the real API lands.
class ReportVisit {
  const ReportVisit({
    required this.time,
    required this.doctor,
    required this.type,
    required this.status,
  });

  final String time; // "09:20"
  final String doctor; // "Dr. Anwar"
  final String type; // "Planned" / "Unplanned"
  final ReportVisitStatus status;

  String get statusLabel => switch (status) {
        ReportVisitStatus.done => 'Done',
        ReportVisitStatus.logged => 'Logged',
        ReportVisitStatus.missed => 'Missed',
      };
}

/// The generated Activity Details report.
class ReportOutput {
  const ReportOutput({
    required this.member,
    required this.date,
    required this.visits,
    required this.done,
    required this.planned,
  });

  final String member; // "Gohar Zaman"
  final String date; // "17 Jun 2026"
  final List<ReportVisit> visits;
  final int done; // 6
  final int planned; // 8

  int get completionPct => planned == 0 ? 0 : ((done / planned) * 100).round();
}
