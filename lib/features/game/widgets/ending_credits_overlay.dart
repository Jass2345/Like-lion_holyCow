import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/group_model.dart';
import '../../result/controllers/result_controller.dart';
import '../../result/models/game_result_model.dart';

class EndingCreditsOverlay extends ConsumerStatefulWidget {
  const EndingCreditsOverlay({
    super.key,
    required this.group,
    required this.onDismissed,
  });

  final GroupModel group;
  final VoidCallback onDismissed;

  @override
  ConsumerState<EndingCreditsOverlay> createState() =>
      _EndingCreditsOverlayState();
}

class _EndingCreditsOverlayState extends ConsumerState<EndingCreditsOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _contentKey = GlobalKey();
  double _contentHeight = 0;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 26),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onDismissed();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _maybeStart() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box =
          _contentKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) setState(() => _contentHeight = box.size.height);
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    _maybeStart();

    final resultAsync = ref.watch(gameResultProvider(widget.group.id));
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final totalDistance = screenHeight + _contentHeight;
              final dy = screenHeight - _controller.value * totalDistance;
              return Transform.translate(
                offset: Offset(0, dy),
                child: child,
              );
            },
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: _CreditsContent(
                  key: _contentKey,
                  group: widget.group,
                  resultAsync: resultAsync,
                ),
              ),
            ),
          ),

          // X 버튼
          Positioned(
            top: topPadding + 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white54, size: 28),
              tooltip: '건너뛰기',
              onPressed: widget.onDismissed,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 크레딧 내용 ───────────────────────────────────────────────

class _CreditsContent extends StatelessWidget {
  const _CreditsContent({
    super.key,
    required this.group,
    required this.resultAsync,
  });

  final GroupModel group;
  final AsyncValue<GameResultModel> resultAsync;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 64),

        // 인트로
        _section(
          child: Column(
            children: [
              const Text('💣', style: TextStyle(fontSize: 72, color: Colors.white)),
              const SizedBox(height: 16),
              const Text(
                'Bombastic',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                group.name,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),

        // 명예의 전당
        _section(
          child: Column(
            children: [
              _heading('🏆 명예의 전당'),
              const SizedBox(height: 32),
              resultAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (result) => _AwardsList(result: result),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),

        // 참여자 목록
        _section(
          child: Column(
            children: [
              _heading('참여자'),
              const SizedBox(height: 24),
              ...group.memberUids.map((uid) {
                final nickname = group.memberNicknames[uid] ?? uid;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    nickname,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 80),

        // 아웃트로
        _section(
          child: const Text(
            '수고하셨습니다 🎉',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 120),
      ],
    );
  }

  Widget _heading(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1,
        ),
        textAlign: TextAlign.center,
      );

  Widget _section({required Widget child}) => Center(child: child);
}

// ── 어워드 목록 ───────────────────────────────────────────────

class _AwardsList extends StatelessWidget {
  const _AwardsList({required this.result});

  final GameResultModel result;

  @override
  Widget build(BuildContext context) {
    final awards = _computeAwards(result);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: awards.map((a) => _AwardItem(award: a)).toList(),
    );
  }

  List<_Award> _computeAwards(GameResultModel result) {
    final players = result.rankList;
    if (players.isEmpty) return [];

    final awards = <_Award>[];

    // 폭탄 러버 — maxHoldingMinutes 최대
    final maxHolding =
        players.map((p) => p.maxHoldingMinutes).reduce((a, b) => a > b ? a : b);
    if (maxHolding > 0) {
      final winners = players
          .where((p) => p.maxHoldingMinutes == maxHolding)
          .map((p) => p.displayName)
          .toList();
      awards.add(_Award(emoji: '🔥', title: '폭탄 러버', subtitle: '폭탄을 가장 오래 들고 있던 사람', winners: winners));
    }

    // 안전제일 — maxHoldingMinutes 최소 (> 0인 경우만)
    final holdingValues =
        players.where((p) => p.maxHoldingMinutes > 0).map((p) => p.maxHoldingMinutes).toList();
    if (holdingValues.isNotEmpty) {
      final minHolding = holdingValues.reduce((a, b) => a < b ? a : b);
      // 폭탄 러버와 동일인이 되지 않도록 분리 (최소 ≠ 최대일 때만)
      if (minHolding != maxHolding) {
        final winners = players
            .where((p) => p.maxHoldingMinutes == minHolding)
            .map((p) => p.displayName)
            .toList();
        awards.add(_Award(emoji: '🛡️', title: '안전제일', subtitle: '폭탄을 가장 적게 들고 있던 사람', winners: winners));
      }
    }

    // 다재다능 — itemUsedCount 최대
    final maxItems =
        players.map((p) => p.itemUsedCount).reduce((a, b) => a > b ? a : b);
    if (maxItems > 0) {
      final winners = players
          .where((p) => p.itemUsedCount == maxItems)
          .map((p) => p.displayName)
          .toList();
      awards.add(_Award(emoji: '🎯', title: '다재다능', subtitle: '아이템을 가장 많이 사용한 사람', winners: winners));
    }

    // 폭탄 배송 — passCount 최대
    final maxPass =
        players.map((p) => p.passCount).reduce((a, b) => a > b ? a : b);
    if (maxPass > 0) {
      final winners = players
          .where((p) => p.passCount == maxPass)
          .map((p) => p.displayName)
          .toList();
      awards.add(_Award(emoji: '📦', title: '폭탄 배송', subtitle: '누구보다 빠르게 폭탄을 넘긴 사람', winners: winners));
    }

    // 패배자 — explodeCount 최대
    final maxExplode =
        players.map((p) => p.explodeCount).reduce((a, b) => a > b ? a : b);
    if (maxExplode > 0) {
      final winners = players
          .where((p) => p.explodeCount == maxExplode)
          .map((p) => p.displayName)
          .toList();
      awards.add(_Award(emoji: '💥', title: '패배자', subtitle: '폭탄과 최후를 같이한 사람', winners: winners));
    }

    return awards;
  }
}

class _Award {
  const _Award({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.winners,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final List<String> winners;
}

class _AwardItem extends StatelessWidget {
  const _AwardItem({required this.award});

  final _Award award;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36),
      child: Column(
        children: [
          Text(award.emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 6),
          Text(
            award.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            award.subtitle,
            style: const TextStyle(fontSize: 13, color: Colors.white54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          ...award.winners.map(
            (name) => Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.amberAccent,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
