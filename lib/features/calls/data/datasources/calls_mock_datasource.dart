import '../models/calls_snapshot_model.dart';
import '../../domain/entities/visit.dart';
import 'calls_datasource.dart';

/// Placeholder Call Reporting data, matching the approved prototype.
///
/// TODO(real-api): replaced by CallsRemoteDataSource once the client's data
/// structure arrives — see calls_providers.dart for the swap point.
class CallsMockDataSource implements CallsDataSource {
  @override
  Future<CallsSnapshotModel> getToday() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return const CallsSnapshotModel(
      planned: 8,
      done: 6,
      visits: [
        Visit(
          time: '09:20',
          name: 'Dr. Anwar Sheikh',
          specialty: 'Cardiologist',
          type: VisitType.planned,
          status: VisitStatus.done,
        ),
        Visit(
          time: '10:05',
          name: 'Dr. Saleem Raza',
          specialty: 'GP',
          type: VisitType.planned,
          status: VisitStatus.done,
        ),
        Visit(
          time: '11:30',
          name: 'Dr. Iqbal Khan',
          specialty: 'Physician',
          type: VisitType.unplanned,
          status: VisitStatus.logged,
        ),
        Visit(
          time: '12:45',
          name: 'Dr. Rana Tahir',
          specialty: 'Surgeon',
          type: VisitType.planned,
          status: VisitStatus.missed,
        ),
      ],
    );
  }
}
