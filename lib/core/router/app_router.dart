import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/pages/auth_gate_page.dart';
import '../../features/game/pages/game_page.dart';
import '../../features/group/pages/group_lobby_page.dart';
import '../../features/group/pages/group_join_page.dart';
import '../../features/mission/pages/mission_page.dart';
import '../../features/result/pages/result_page.dart';
import '../../features/shop/pages/shop_page.dart';

part 'app_router.g.dart';

/// 라우트 경로 상수
abstract final class AppRoutes {
  static const authGate = '/';
  static const groupJoin = '/group/join';
  static const groupLobby = '/group/lobby';
  static const game = '/game';
  static const shop = '/shop';
  static const mission = '/mission';
  static const result = '/result';
}

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: AppRoutes.authGate,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.authGate,
        builder: (context, state) => const AuthGatePage(),
      ),
      GoRoute(
        path: AppRoutes.groupJoin,
        builder: (context, state) => const GroupJoinPage(),
      ),
      GoRoute(
        path: AppRoutes.groupLobby,
        builder: (context, state) => const GroupLobbyPage(),
      ),
      GoRoute(
        path: AppRoutes.game,
        builder: (context, state) => const GamePage(),
      ),
      GoRoute(
        path: AppRoutes.shop,
        builder: (context, state) => const ShopPage(),
      ),
      GoRoute(
        path: AppRoutes.mission,
        builder: (context, state) => const MissionPage(),
      ),
      GoRoute(
        path: AppRoutes.result,
        builder: (context, state) => const ResultPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('페이지를 찾을 수 없습니다: ${state.error}'),
      ),
    ),
  );
}
