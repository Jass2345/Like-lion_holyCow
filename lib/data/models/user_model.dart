// 변경 후 dart run build_runner build --delete-conflicting-outputs 실행 필요
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String displayName,
    @Default(0) int currency,
    @Default([]) List<String> ownedItemIds,
    @Default([]) List<String> groupIds,
    @Default({}) Map<String, String> groupNicknames,
    String? currentGroupId,
    DateTime? lastCheckInDate,
    DateTime? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(_normalizeUserJson(json));
}

Map<String, dynamic> _normalizeUserJson(Map<String, dynamic> json) {
  final map = Map<String, dynamic>.from(json);
  map['lastCheckInDate'] = _normalizeNullableDateValue(map['lastCheckInDate']);
  map['createdAt'] = _normalizeNullableDateValue(map['createdAt']);
  return map;
}

String? _normalizeNullableDateValue(Object? value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate().toIso8601String();
  if (value is DateTime) return value.toIso8601String();
  if (value is String) return value;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value).toIso8601String();
  }
  throw FormatException('Unsupported date value: $value');
}
