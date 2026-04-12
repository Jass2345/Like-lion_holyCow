import 'package:bomb_pass/data/firebase/firebase_providers.dart';
import 'package:bomb_pass/data/models/shop_item_model.dart';
import 'package:bomb_pass/data/repositories/shop_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shop_controller.g.dart';

class OwnedInventoryItem {
  const OwnedInventoryItem({required this.item, required this.count});

  final ShopItemModel item;
  final int count;
}

/// 상점 아이템 목록 (실시간)
@riverpod
Stream<List<ShopItemModel>> shopItems(Ref ref) {
  return ref.watch(shopRepositoryProvider).watchShopItems();
}

final groupOwnedInventoryProvider =
    Provider.family<List<OwnedInventoryItem>, String>((ref, groupId) {
  final items = ref.watch(shopItemsProvider).asData?.value ?? const <ShopItemModel>[];
  final ownedItemCounts = ref.watch(groupOwnedItemCountsProvider(groupId));

  return items
      .where((item) => ownedItemCounts.containsKey(item.id))
      .map(
        (item) => OwnedInventoryItem(
          item: item,
          count: ownedItemCounts[item.id] ?? 0,
        ),
      )
      .toList();
});

final groupOwnedInventoryTotalCountProvider =
    Provider.family<int, String>((ref, groupId) {
  final inventory = ref.watch(groupOwnedInventoryProvider(groupId));
  return inventory.fold<int>(0, (sum, entry) => sum + entry.count);
});

@riverpod
class ShopController extends _$ShopController {
  @override
  AsyncValue<ShopItemModel?> build() => const AsyncData(null);

  /// 랜덤박스 구매 — Cloud Function 호출, 성공 시 state에 획득 아이템 저장
  Future<ShopItemModel?> purchaseRandomBox({required String groupId}) async {
    state = const AsyncLoading();
    final next = await AsyncValue.guard(() async {
      return ref
          .read(shopRepositoryProvider)
          .purchaseRandomBox(groupId: groupId);
    });
    if (ref.mounted) state = next;
    return next.asData?.value;
  }
}
