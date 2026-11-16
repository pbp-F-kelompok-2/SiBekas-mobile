import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../models/models.dart';
import '../../shared/widgets.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({required this.api, super.key});
  final ApiClient api;
  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String _role = 'buyer';
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const ModuleHeader(
        'Pesanan saya.',
        'Pantau perjalanan barang menuju cerita barunya.',
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'buyer',
                  label: Text('Pembelian'),
                  icon: Icon(Icons.shopping_bag_outlined),
                ),
                ButtonSegment(
                  value: 'seller',
                  label: Text('Penjualan'),
                  icon: Icon(Icons.storefront_outlined),
                ),
              ],
              selected: {_role},
              onSelectionChanged: (values) =>
                  setState(() => _role = values.first),
            ),
            PagedList<OrderData>(
              key: ValueKey(_role),
              load: (page) => widget.api.page(
                'orders/',
                OrderData.fromJson,
                page: page,
                query: {'role': _role},
              ),
              emptyMessage:
                  'Belum ada pesanan ${_role == 'buyer' ? 'pembelian' : 'penjualan'}.',
              itemBuilder: (order) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.number,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Chip(label: Text(order.status)),
                      const SizedBox(height: 8),
                      ...order.itemNames.map((name) => Text(name)),
                      const Divider(height: 24),
                      Text(order.delivery),
                      const SizedBox(height: 4),
                      Text(
                        rupiah(order.total),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
