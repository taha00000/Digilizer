import '../../domain/entities/report_output.dart';
import 'reports_datasource.dart';

/// Placeholder report output, matching the prototype's visit table.
///
/// TODO(real-api): replaced by ReportsRemoteDataSource once the client's data
/// structure arrives — see reports_providers.dart for the swap point.
class ReportsMockDataSource implements ReportsDataSource {
  @override
  Future<ReportOutput> runActivityReport({
    required String member,
    required String date,
  }) async {
    // Slightly longer than the other mocks: this stands in for a report the
    // server has to generate, so the CTA's pending state is worth seeing.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return ReportOutput(
      member: member,
      date: date,
      done: 6,
      planned: 8,
      visits: const [
        ReportVisit(
          time: '09:20',
          doctor: 'Dr. Anwar',
          type: 'Planned',
          status: ReportVisitStatus.done,
        ),
        ReportVisit(
          time: '10:05',
          doctor: 'Dr. Saleem',
          type: 'Planned',
          status: ReportVisitStatus.done,
        ),
        ReportVisit(
          time: '11:30',
          doctor: 'Dr. Iqbal',
          type: 'Unplanned',
          status: ReportVisitStatus.logged,
        ),
        ReportVisit(
          time: '12:45',
          doctor: 'Dr. Rana',
          type: 'Planned',
          status: ReportVisitStatus.missed,
        ),
      ],
    );
  }
}
