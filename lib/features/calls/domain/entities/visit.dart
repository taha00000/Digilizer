/// Whether a visit was on the day's plan or added in the field.
enum VisitType { planned, unplanned }

/// How the visit ended.
enum VisitStatus { done, logged, missed }

/// One doctor/chemist call.
class Visit {
  const Visit({
    required this.time,
    required this.name,
    required this.specialty,
    required this.type,
    required this.status,
  });

  final String time; // "09:20"
  final String name; // "Dr. Anwar Sheikh"
  final String specialty; // "Cardiologist"
  final VisitType type;
  final VisitStatus status;
}

/// The Call Reporting screen's payload.
class CallsSnapshot {
  const CallsSnapshot({
    required this.planned,
    required this.done,
    required this.visits,
  });

  final int planned;
  final int done;
  final List<Visit> visits;

  /// Share of the day's plan completed, as a whole percent.
  int get completionPct => planned == 0 ? 0 : ((done / planned) * 100).round();
}
