import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'credits_controller.g.dart';

/// 그룹별 엔딩 크레딧 최초 1회 재생 여부 (SharedPreferences 영속)
@riverpod
class CreditsShown extends _$CreditsShown {
  late final String _groupId;

  @override
  Future<bool> build(String groupId) async {
    _groupId = groupId;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('credits_shown_$groupId') ?? false;
  }

  /// 크레딧을 봤음으로 영구 기록
  Future<void> markShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('credits_shown_$_groupId', true);
    state = const AsyncData(true);
  }

  /// 다시보기 — SharedPreferences는 유지, 현 세션만 재생
  void showAgain() {
    state = const AsyncData(false);
  }
}
