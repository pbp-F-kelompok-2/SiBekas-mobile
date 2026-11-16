# Pemeriksaan Checkpoint 1

Tenggat: **20 November 2026, 23.59 WIB**. Pengumpulan akhir: **9 Desember 2026, 23.59 WIB**.

| Syarat PAS | Bukti implementasi |
| --- | --- |
| Repositori Flutter terpisah dari web | `pbp-F-kelompok-2/SiBekas-mobile`, platform Android dan iOS |
| README anggota, deskripsi, modul, aktor, integrasi | [README](../README.md) |
| Scoping dan pemilik modul | Lima modul sesuai modul PTS; rincian pekerjaan lanjutan di README |
| Endpoint DRF setiap modul berjalan | [Kontrak API](api.md), serializer/view di repo web, pengujian `tests.test_mobile_api` |
| Setiap modul mempunyai halaman | `lib/features/{product,profile,cart,order,review}/` |
| Navigasi bekerja | `NavigationBar` lima tujuan; screen privat meminta login |
| Kerangka mengambil JSON nyata | HTTP async dari PWS; tidak ada fixture di `lib/` |
| Rancangan UI | [Wireframe lima modul](wireframes.svg); tautan Figma menyusul sesuai kelonggaran CP1 |

## Verifikasi lokal

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

Pengujian Flutter menggunakan respons HTTP tiruan hanya di folder `test/`, untuk memeriksa login, header token, logout, token ditolak, pengolahan JSON, navigasi lima modul, filter pencarian dan retry. Data pada aplikasi yang dijalankan berasal dari endpoint Django.

Backend: `python manage.py check`, `python manage.py makemigrations --check --dry-run`, `python manage.py test`. Suite API memeriksa kontrak publik, query tidak valid, token sungguhan, penolakan akun nonaktif, pembatasan data akun, barang tidak tersedia, peran staff, dan CSRF sesi website.

Hasil verifikasi setup: **189 tes Django lulus** (termasuk 17 tes API baru), **8 tes Flutter lulus**, `flutter analyze` tanpa temuan, dan APK debug berhasil dibangun. CI backend untuk commit `7ffd5ac` juga lulus. API root, produk, kategori dan ulasan di PWS sudah mengembalikan 200 JSON; profil, keranjang dan pesanan tanpa token mengembalikan 401 JSON. Saat verifikasi, katalog dan ulasan PWS belum memiliki data; respons kosong ditampilkan dengan keadaan kosong pada aplikasi.

Contoh tampilan katalog tersedia di [docs/previews](previews/README.md), dirender menggunakan fixture pengujian dan bukan data produksi. Rancangan kelima modul tersedia pada wireframe. Kerangka iOS disertakan; build iOS belum diverifikasi karena lingkungan pengerjaan Windows.

## Uji manual dengan akun sendiri

1. Buka Katalog; cari produk yang sama di web dan mobile.
2. Buka Profil/Keranjang/Pesanan sebelum login; pastikan ada ajakan masuk.
3. Login memakai akun website. Periksa nama dan isi keranjang/pesanan cocok dengan web.
4. Tambahkan favorit atau ubah keranjang melalui website, kemudian tekan Perbarui di mobile.
5. Beralih antara Pembelian dan Penjualan; buka Ulasan dan filter Hanya ulasan saya.
6. Matikan jaringan; periksa pesan error dan Coba lagi. Logout; data privat tidak boleh tetap terlihat.

Fitur transaksi lengkap, CRUD mobile, desain Figma final, APK release di GitHub Releases dan Bitrise, serta video bonus diselesaikan pada tahap pengumpulan akhir. APK debug untuk verifikasi build bukan APK release pengumpulan akhir.
