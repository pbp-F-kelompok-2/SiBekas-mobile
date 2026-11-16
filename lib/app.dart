import 'package:flutter/material.dart';
import 'core/api_client.dart';
import 'core/theme.dart';
import 'features/auth/login_screen.dart';
import 'features/product/product_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/cart/cart_screen.dart';
import 'features/order/order_screen.dart';
import 'features/review/review_screen.dart';
import 'shared/widgets.dart';

class SiBekasApp extends StatelessWidget {
  const SiBekasApp({required this.api, super.key});
  final ApiClient api;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'SiBekas',
    debugShowCheckedModeBanner: false,
    theme: appTheme(),
    home: AppShell(api: api),
  );
}

class AppShell extends StatefulWidget {
  const AppShell({required this.api, super.key});
  final ApiClient api;
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selected = 0;
  bool _loggingOut = false;
  static const _titles = [
    'Temukan barangmu',
    'Profil saya',
    'Keranjang saya',
    'Pesanan saya',
    'Cerita pembeli',
  ];
  void _login() => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => LoginScreen(api: widget.api)));
  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    try {
      await widget.api.logout();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.api,
    builder: (context, _) {
      final api = widget.api;
      final needsLogin = {1, 2, 3}.contains(_selected) && !api.isLoggedIn;
      final screen = needsLogin
          ? MessagePanel(
              'Masuk untuk membuka ${_titles[_selected].toLowerCase()}.',
              icon: Icons.lock_outline,
              action: FilledButton(
                onPressed: _login,
                child: const Text('Masuk ke akun'),
              ),
            )
          : switch (_selected) {
              0 => ProductScreen(api: api),
              1 => ProfileScreen(api: api),
              2 => CartScreen(api: api),
              3 => OrderScreen(api: api),
              _ => ReviewScreen(api: api),
            };
      return Scaffold(
        appBar: AppBar(
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.eco_outlined, size: 28),
              SizedBox(width: 8),
              Text(
                'SiBekas',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
          actions: [
            if (api.isLoggedIn)
              IconButton(
                tooltip: 'Keluar',
                onPressed: _loggingOut ? null : _logout,
                icon: const Icon(Icons.logout),
              )
            else
              TextButton(onPressed: _login, child: const Text('Masuk')),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SingleChildScrollView(
                key: ValueKey('$_selected-${api.username}'),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (needsLogin)
                      ModuleHeader(
                        _titles[_selected],
                        'Satu akun untuk aplikasi mobile dan website SiBekas.',
                      ),
                    KeyedSubtree(
                      key: ValueKey('screen-$_selected-${api.username}'),
                      child: screen,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selected,
          onDestinationSelected: (value) => setState(() => _selected = value),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              label: 'Katalog',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              label: 'Profil',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_bag_outlined),
              label: 'Keranjang',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              label: 'Pesanan',
            ),
            NavigationDestination(
              icon: Icon(Icons.star_outline),
              label: 'Ulasan',
            ),
          ],
        ),
      );
    },
  );
}
