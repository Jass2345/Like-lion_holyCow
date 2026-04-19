// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credits_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 그룹별 엔딩 크레딧 최초 1회 재생 여부 (SharedPreferences 영속)

@ProviderFor(CreditsShown)
final creditsShownProvider = CreditsShownFamily._();

/// 그룹별 엔딩 크레딧 최초 1회 재생 여부 (SharedPreferences 영속)
final class CreditsShownProvider
    extends $AsyncNotifierProvider<CreditsShown, bool> {
  /// 그룹별 엔딩 크레딧 최초 1회 재생 여부 (SharedPreferences 영속)
  CreditsShownProvider._({
    required CreditsShownFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'creditsShownProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$creditsShownHash();

  @override
  String toString() {
    return r'creditsShownProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CreditsShown create() => CreditsShown();

  @override
  bool operator ==(Object other) {
    return other is CreditsShownProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$creditsShownHash() => r'83505d0afb2a780f1e6706e2e3d24aea8a4406f6';

/// 그룹별 엔딩 크레딧 최초 1회 재생 여부 (SharedPreferences 영속)

final class CreditsShownFamily extends $Family
    with
        $ClassFamilyOverride<
          CreditsShown,
          AsyncValue<bool>,
          bool,
          FutureOr<bool>,
          String
        > {
  CreditsShownFamily._()
    : super(
        retry: null,
        name: r'creditsShownProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 그룹별 엔딩 크레딧 최초 1회 재생 여부 (SharedPreferences 영속)

  CreditsShownProvider call(String groupId) =>
      CreditsShownProvider._(argument: groupId, from: this);

  @override
  String toString() => r'creditsShownProvider';
}

/// 그룹별 엔딩 크레딧 최초 1회 재생 여부 (SharedPreferences 영속)

abstract class _$CreditsShown extends $AsyncNotifier<bool> {
  late final _$args = ref.$arg as String;
  String get groupId => _$args;

  FutureOr<bool> build(String groupId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
