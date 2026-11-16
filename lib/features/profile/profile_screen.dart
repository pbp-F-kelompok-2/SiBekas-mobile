import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../shared/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.api, super.key});
  final ApiClient api;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const ModuleHeader(
        'Profil saya.',
        'Kenalan, terhubung, dan mulai belanja dengan lebih bijak.',
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: RemoteContent<ProfileData>(
          load: api.profile,
          builder: (profile) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 34,
                        backgroundColor: kiwi,
                        child: Icon(
                          Icons.person_outline,
                          color: forest,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profile.fullName.isEmpty
                            ? profile.username
                            : profile.fullName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text('@${profile.username}'),
                      const SizedBox(height: 8),
                      Text(
                        profile.isStaff
                            ? 'Petugas kampus'
                            : 'Anggota komunitas UI',
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Column(
                  children: [
                    for (final row in [
                      ('Email', profile.email),
                      ('Fakultas', profile.faculty),
                      ('NPM', profile.studentId),
                      ('Kontak', profile.phone),
                      ('Alamat', profile.address),
                      ('Tentang saya', profile.bio),
                    ])
                      ListTile(
                        title: Text(row.$1),
                        subtitle: Text(row.$2.isEmpty ? 'Belum diisi' : row.$2),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Barang favorit',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              PagedList<Product>(
                load: (page) => api.page(
                  'profile/favorites/',
                  Product.fromJson,
                  page: page,
                ),
                emptyMessage:
                    'Belum ada barang favorit. Favorit dari website juga akan tampil di sini.',
                itemBuilder: (product) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.favorite_outline, color: forest),
                    title: Text(product.name),
                    subtitle: Text(rupiah(product.price)),
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
