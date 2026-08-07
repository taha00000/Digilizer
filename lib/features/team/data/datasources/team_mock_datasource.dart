import '../../domain/entities/team.dart';
import 'team_datasource.dart';

/// Placeholder team data, matching the approved prototype's TEAM array.
///
/// TODO(real-api): replaced by TeamRemoteDataSource once the client's data
/// structure arrives — see team_providers.dart for the swap point.
class TeamMockDataSource implements TeamDataSource {
  static const _members = [
    TeamMember(
      initials: 'GZ',
      name: 'Gohar Zaman',
      role: 'Assoc. Director',
      code: '004324',
      achPct: 75,
      sales: '6.5M',
      target: '8.7M',
      goLM: '15',
      goLY: '109',
      tone: AchievementTone.good,
    ),
    TeamMember(
      initials: 'RZ',
      name: 'Raheel Zafar',
      role: 'Marketing Mgr',
      code: '004200',
      achPct: 59,
      sales: '3.9M',
      target: '6.7M',
      goLM: '1',
      goLY: '97',
      tone: AchievementTone.watch,
    ),
    TeamMember(
      initials: 'ZM',
      name: 'Zia Muhammad',
      role: 'Product Mgr',
      code: '004196',
      achPct: 51,
      sales: '3.8M',
      target: '7.4M',
      goLM: '4',
      goLY: '40',
      tone: AchievementTone.watch,
    ),
    TeamMember(
      initials: 'IZ',
      name: 'Imran Zafar',
      role: 'Comm. Officer',
      code: '004291',
      achPct: 49,
      sales: '3.3M',
      target: '6.5M',
      goLM: '16',
      goLY: '42',
      tone: AchievementTone.behind,
    ),
  ];

  @override
  Future<TeamSnapshot> getTeam() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return const TeamSnapshot(
      zone: ZoneSummary(
        achievementPct: 58.24,
        sales: '30.1M',
        target: '51.7M',
        goLY: '+59.9%',
      ),
      members: _members,
    );
  }

  @override
  Future<RepDetail> getRep(String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    // The prototype only details Gohar Zaman; fall back to him so every row
    // opens to something rather than an empty screen.
    final m = _members.firstWhere(
      (e) => e.code == code,
      orElse: () => _members.first,
    );

    return RepDetail(
      name: m.name,
      code: m.code,
      role: m.role,
      achPct: m.achPct,
      sales: m.sales,
      target: m.target,
      goLY: '+${m.goLY}%',
      products: const [
        ProductSale(
          brand: 'Vlep',
          form: 'Tablets 500mg',
          achPct: 77,
          target: '3.7M',
          sales: '2.9M',
          goLM: 25,
          goLY: 68,
          targetUnits: '2,172',
          salesUnits: '1,686',
        ),
        ProductSale(
          brand: 'Cubriva',
          form: 'Capsules',
          achPct: 73,
          target: '2.0M',
          sales: '1.5M',
          goLM: 5,
          goLY: 132,
          targetUnits: '1,040',
          salesUnits: '760',
        ),
        ProductSale(
          brand: 'Carlep',
          form: 'Syrup',
          achPct: 96,
          target: '627K',
          sales: '602K',
          goLM: 46,
          goLY: 467,
          targetUnits: '418',
          salesUnits: '402',
        ),
        ProductSale(
          brand: 'Seipil',
          form: 'Tablets',
          achPct: 62,
          target: '2.3M',
          sales: '1.4M',
          goLM: 12,
          goLY: 55,
          targetUnits: '1,200',
          salesUnits: '690',
        ),
      ],
    );
  }
}
