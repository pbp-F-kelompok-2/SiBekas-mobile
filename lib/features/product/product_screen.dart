import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../shared/widgets.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({required this.api, super.key});
  final ApiClient api;
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final _search = TextEditingController();
  String _query = '';
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _showProduct(Product product) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (context) => SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(child: ProductImage(product.imageUrl, size: 180)),
          const SizedBox(height: 20),
          Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            rupiah(product.price),
            style: const TextStyle(
              color: forest,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${product.category} • ${product.condition} • Stok ${product.stock}',
          ),
          const SizedBox(height: 8),
          Text('Dijual oleh ${product.seller}'),
          const SizedBox(height: 16),
          Text(product.description),
          const SizedBox(height: 24),
        ],
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const ModuleHeader(
        'Temukan barangmu.',
        'Lebih hemat untukmu, lebih baik untuk bumi. Jelajahi barang preloved dari komunitas UI.',
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextField(
          controller: _search,
          textInputAction: TextInputAction.search,
          onSubmitted: (value) => setState(() => _query = value.trim()),
          decoration: InputDecoration(
            hintText: 'Cari buku, barang kos, dan lainnya...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              tooltip: 'Cari produk',
              onPressed: () => setState(() => _query = _search.text.trim()),
              icon: const Icon(Icons.arrow_forward),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: PagedList<Product>(
          key: ValueKey(_query),
          load: (page) => widget.api.page(
            'products/',
            Product.fromJson,
            page: page,
            query: {if (_query.isNotEmpty) 'q': _query},
          ),
          emptyMessage:
              'Belum ada barang yang cocok. Coba kata pencarian lain.',
          itemBuilder: (product) => Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showProduct(product),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProductImage(product.imageUrl),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.category.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: forest,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            rupiah(product.price),
                            style: const TextStyle(
                              color: forest,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.stock == 0
                                ? 'Sudah terjual'
                                : product.condition,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
