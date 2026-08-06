import '../../domain/entities/auth_session.dart';

/// Data-layer model — the boundary between the API's JSON and our domain
/// entity.
///
/// TODO(real-api): the field names below mirror the PROVISIONAL shape from the
/// prototype, not the client's API. When their data structure arrives, remap
/// [fromJson] to their keys; nothing outside this file needs to change.
/// At that point consider regenerating this with json_serializable.
class AuthSessionModel {
  const AuthSessionModel({
    required this.userId,
    required this.displayName,
    required this.company,
    required this.accountCode,
    required this.token,
  });

  final String userId;
  final String displayName;
  final String company;
  final String accountCode;
  final String token;

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      userId: json['userId']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      accountCode: json['accountCode']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'displayName': displayName,
        'company': company,
        'accountCode': accountCode,
        'token': token,
      };

  AuthSession toEntity() => AuthSession(
        userId: userId,
        displayName: displayName,
        company: company,
        accountCode: accountCode,
        token: token,
      );
}
