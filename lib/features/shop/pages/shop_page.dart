import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/shop_controller.dart';

class ShopPage extends ConsumerWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(shopItemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('상점')),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (items) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                title: Text(item.name),
                subtitle: Text(item.description),
                trailing: ElevatedButton(
                  onPressed: item.isAvailable
                      ? () => ref
                          .read(shopControllerProvider.notifier)
                          .purchaseItem(item)
                      : null,
                  child: Text('💰 ${item.price}'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
