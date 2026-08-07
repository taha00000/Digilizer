import '../../domain/entities/visit.dart';

/// Data-layer model for the Call Reporting payload. Extends the entity so the
/// mapping is free while JSON parsing stays out of `domain/`.
///
/// TODO(real-api): keys mirror the PROVISIONAL shape from the prototype, not
/// the client's API. Remap [fromJson] when their structure lands.
class CallsSnapshotModel extends CallsSnapshot {
  const CallsSnapshotModel({
    required super.planned,
    required super.done,
    required super.visits,
  });

  factory CallsSnapshotModel.fromJson(Map<String, dynamic> json) {
    return CallsSnapshotModel(
      planned: _int(json['planned']),
      done: _int(json['done']),
      visits: (json['visits'] is List ? json['visits'] as List : const [])
          .map(_visit)
          .toList(),
    );
  }

  /// Serialised for the offline cache; must round-trip through [fromJson].
  Map<String, dynamic> toJson() => {
        'planned': planned,
        'done': done,
        'visits': visits.map(_visitJson).toList(),
      };

  static Map<String, dynamic> _visitJson(Visit v) => {
        'time': v.time,
        'name': v.name,
        'specialty': v.specialty,
        'type': v.type.name,
        'status': v.status.name,
      };

  static int _int(dynamic v) => switch (v) {
        final int i => i,
        final num n => n.round(),
        final String s => int.tryParse(s) ?? 0,
        _ => 0,
      };

  static Visit _visit(dynamic v) {
    final m = v is Map<String, dynamic> ? v : const <String, dynamic>{};
    return Visit(
      time: m['time']?.toString() ?? '',
      name: m['name']?.toString() ?? '',
      specialty: m['specialty']?.toString() ?? '',
      type: m['type']?.toString().toLowerCase() == 'unplanned'
          ? VisitType.unplanned
          : VisitType.planned,
      status: switch (m['status']?.toString().toLowerCase()) {
        'missed' => VisitStatus.missed,
        'logged' => VisitStatus.logged,
        _ => VisitStatus.done,
      },
    );
  }
}
