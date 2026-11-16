import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/theme.dart';

class ModuleHeader extends StatelessWidget {
  const ModuleHeader(this.title, this.description, {super.key});
  final String title, description;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BARANG LAMA, CERITA BARU',
          style: TextStyle(
            color: forest,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(color: Color(0xFF615C51), height: 1.5),
        ),
      ],
    ),
  );
}

class MessagePanel extends StatelessWidget {
  const MessagePanel(
    this.message, {
    this.icon = Icons.inbox_outlined,
    this.action,
    super.key,
  });
  final String message;
  final IconData icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(28),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 44, color: forest),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center),
        if (action != null) ...[const SizedBox(height: 16), action!],
      ],
    ),
  );
}

class RemoteContent<T> extends StatefulWidget {
  const RemoteContent({required this.load, required this.builder, super.key});
  final Future<T> Function() load;
  final Widget Function(T data) builder;
  @override
  State<RemoteContent<T>> createState() => _RemoteContentState<T>();
}

class _RemoteContentState<T> extends State<RemoteContent<T>> {
  late Future<T> _future;
  @override
  void initState() {
    super.initState();
    _future = widget.load();
  }

  Future<void> _reload() async {
    setState(() => _future = widget.load());
    try {
      await _future;
    } catch (_) {
      /* FutureBuilder displays the error. */
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
    future: _future,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Padding(
          padding: EdgeInsets.all(48),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (snapshot.hasError) {
        return MessagePanel(
          snapshot.error.toString(),
          icon: Icons.wifi_off_rounded,
          action: FilledButton(
            onPressed: _reload,
            child: const Text('Coba lagi'),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _reload,
              icon: const Icon(Icons.refresh),
              label: const Text('Perbarui'),
            ),
          ),
          widget.builder(snapshot.data as T),
        ],
      );
    },
  );
}

class PagedList<T> extends StatefulWidget {
  const PagedList({
    required this.load,
    required this.itemBuilder,
    required this.emptyMessage,
    super.key,
  });
  final Future<ApiPage<T>> Function(int page) load;
  final Widget Function(T item) itemBuilder;
  final String emptyMessage;
  @override
  State<PagedList<T>> createState() => _PagedListState<T>();
}

class _PagedListState<T> extends State<PagedList<T>> {
  final List<T> _items = [];
  int _page = 0;
  bool _loading = false, _hasNext = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch({bool reset = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final nextPage = reset ? 1 : _page + 1;
    try {
      final data = await widget.load(nextPage);
      if (!mounted) return;
      setState(() {
        if (reset) _items.clear();
        _items.addAll(data.items);
        _page = nextPage;
        _hasNext = data.hasNext;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: _loading ? null : () => _fetch(reset: true),
          icon: const Icon(Icons.refresh),
          label: const Text('Perbarui'),
        ),
      ),
      ..._items.map(widget.itemBuilder),
      if (_loading)
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      if (_error != null)
        MessagePanel(
          _error!,
          icon: Icons.wifi_off_rounded,
          action: FilledButton(
            onPressed: _fetch,
            child: const Text('Coba lagi'),
          ),
        ),
      if (!_loading && _error == null && _items.isEmpty)
        MessagePanel(widget.emptyMessage),
      if (!_loading && _error == null && _hasNext && _items.isNotEmpty)
        OutlinedButton(onPressed: _fetch, child: const Text('Muat berikutnya')),
    ],
  );
}

class ProductImage extends StatelessWidget {
  const ProductImage(this.url, {this.size = 88, super.key});
  final String url;
  final double size;
  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: const Color(0xFFE1EDE4),
      width: size,
      height: size,
      child: const Icon(Icons.shopping_bag_outlined, color: forest),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: url.isEmpty
          ? placeholder
          : Image.network(
              url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, error, stackTrace) => placeholder,
            ),
    );
  }
}
