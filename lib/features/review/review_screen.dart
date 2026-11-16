import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../shared/widgets.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({required this.api, super.key});
  final ApiClient api;
  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool _mine = false;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const ModuleHeader(
        'Cerita pembeli.',
        'Pengalaman komunitas membantu kita memilih barang dengan yakin.',
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.api.isLoggedIn)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Hanya ulasan saya'),
                value: _mine,
                onChanged: (value) => setState(() => _mine = value),
              ),
            PagedList<ReviewData>(
              key: ValueKey(_mine),
              load: (page) => widget.api.page(
                'reviews/',
                ReviewData.fromJson,
                page: page,
                query: {if (_mine) 'mine': 'true'},
              ),
              emptyMessage:
                  'Belum ada ulasan. Ulasan dari website akan tampil di sini.',
              itemBuilder: (review) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.productName,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (var star = 1; star <= 5; star++)
                            Icon(
                              star <= review.rating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 20,
                              color: forest,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(review.comment),
                      const SizedBox(height: 12),
                      Text(
                        '@${review.username}${review.edited ? ' • diedit' : ''}',
                        style: const TextStyle(fontSize: 12),
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
