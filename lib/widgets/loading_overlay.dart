import 'package:flutter/material.dart';

/// 전체 화면 로딩 오버레이 공통 위젯
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          const ColoredBox(
            color: Color(0x80000000),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
