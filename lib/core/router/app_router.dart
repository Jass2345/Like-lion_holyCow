import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/views/auth_gate.dart';
import '../../features/home/views/home_page.dart';
import '../../features/game/pages/game_page.dart';
import '../../features/group/pages/group_join_page.dart';
import '../../features/group/pages/group_create_page.dart';
import '../../features/group/pages/nickname_input_page.dart';
import '../../features/mission/pages/mission_page.dart';
import '../../features/result/pages/result_page.dart';
import '../../features/shop/pages/shop_page.dart';

part 'app_router.g.dart';

abstract final class AppRoutes {
  static const authGate = '/';
  static const home = '/home';
  static const groupJoin = '/group/join';
  static const groupCreate = '/group/create';
  static const game = '/game';       // /game/:groupId
  static const nickname = '/group';  // /group/:groupId/nickname
  static const result = '/result';   // /result/:groupId
  // 상점·미션은 게임 내부에서만 접근 가능: /game/:groupId/shop, /game/:groupId/mission
}

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.authGate,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.authGate,
        builder: (context, state) => const AuthGate(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.groupJoin,
        builder: (context, state) => const GroupJoinPage(),
      ),
      GoRoute(
        path: AppRoutes.groupCreate,
        builder: (context, state) => const GroupCreatePage(),
      ),
      GoRoute(
        path: '/group/:groupId/nickname',
        builder: (context, state) => NicknameInputPage(
          groupId: state.pathParameters['groupId']!,
        ),
      ),
      GoRoute(
        path: '${AppRoutes.game}/:groupId',
        builder: (context, state) => GamePage(
          groupId: state.pathParameters['groupId']!,
        ),
        routes: [
          GoRoute(
            path: 'shop',
            builder: (context, state) => ShopPage(
              groupId: state.pathParameters['groupId']!,
            ),
          ),
          GoRoute(
            path: 'mission',
            builder: (context, state) => MissionPage(
              groupId: state.pathParameters['groupId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '${AppRoutes.result}/:groupId',
        builder: (context, state) => ResultPage(
          groupId: state.pathParameters['groupId']!,
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('페이지를 찾을 수 없습니다: ${state.error}'),
      ),
    ),
  );
}
