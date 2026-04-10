import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_model.freezed.dart';
part 'group_model.g.dart';

enum GroupStatus { waiting, playing, finished }

@freezed
class GroupModel with _$GroupModel {
  const factory GroupModel({
    required String id,
    required String joinCode,
    required List<String> memberUids,   // 고정 순서 (index = 전달 순서)
    required GroupStatus status,
    required DateTime createdAt,
    DateTime? gameStartedAt,
    DateTime? gameEndedAt,
  }) = _GroupModel;

  factory GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(json);
}
