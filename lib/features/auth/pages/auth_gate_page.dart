import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../data/firebase/firebase_providers.dart';
import '../controllers/auth_controller.dart';

/// 앱 진입 시 인증 상태에 따라 라우팅하는 게이트 페이지
class AuthGatePage extends ConsumerWidget {
  const AuthGatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('오류: $e')),
      ),
      data: (user) {
        if (user == null) {
          return const _SignInScreen();
        }
        // 이미 로그인된 경우 그룹 참여 화면으로
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go(AppRoutes.groupJoin);
        });
        return const SizedBox.shrink();
      },
    );
  }
}

class _SignInScreen extends ConsumerWidget {
  const _SignInScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(authControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '💣 BombPass',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                '4명이 함께하는 폭탄 돌리기 게임',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () async {
                  await controller.signInAnonymously();
                  if (context.mounted) context.go(AppRoutes.groupJoin);
                },
                child: const Text('시작하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
