import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../models/models.dart';
import '../../shared/widgets.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({required this.api, super.key});
  final ApiClient api;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const ModuleHeader(
        'Keranjang saya.',
        'Barang pilihanmu, tersinkron dengan keranjang di website.',
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: RemoteContent<CartData>(
          load: api.cart,
          builder: (cart) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (cart.items.isEmpty)
                const MessagePanel(
                  'Keranjang masih kosong. Tambahkan barang melalui website SiBekas.',
                ),
              for (final item in cart.items)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProductImage(item.product?.imageUrl ?? '', size: 64),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product?.name ?? 'Produk tidak tersedia',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${item.quantity} barang • ${rupiah(item.total)}',
                              ),
                              if (!item.available)
                                Text(
                                  item.reason,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (cart.items.isNotEmpty)
                Card(
                  child: ListTile(
                    title: const Text('Subtotal barang tersedia'),
                    subtitle: Text(
                      '${cart.totalItems} barang • belum termasuk ongkir',
                    ),
                    trailing: Text(
                      rupiah(cart.subtotal),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ],
  );
}
