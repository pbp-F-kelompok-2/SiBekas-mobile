# Kontrak API Checkpoint 1

Base URL PWS: `https://faris-salman-sibekas.pws.cs.ui.ac.id/api/v1/`.
Implementasi berada pada repositori [SiBekas](https://github.com/pbp-F-kelompok-2/SiBekas), memakai model/database web yang sama. Semua path berikut relatif terhadap base URL dan diakhiri `/`.

## Endpoint yang diimplementasikan

| Pemilik/modul | Method | Path | Akses dan perilaku |
| --- | --- | --- | --- |
| Bersama | GET | `/` | Publik; versi API dan daftar modul |
| Rachelin / Profile | POST | `auth/login/` | Publik; JSON `username`, `password`, menghasilkan `token` dan `profile`; dibatasi 10 request/menit per IP |
| Rachelin / Profile | POST | `auth/logout/` | Login; mencabut token, respons 204 tanpa body |
| Rachelin / Profile | GET, PATCH | `profile/` | Profil akun saat ini; PATCH divalidasi memakai aturan form website |
| Rachelin / Profile | GET | `profile/favorites/` | Daftar produk favorit akun saat ini |
| Jehezkiel / Product | GET | `products/` | Publik; daftar produk; filter `q`, `category` (slug), `condition`, `min_price`, `max_price` |
| Jehezkiel / Product | GET | `products/<int:id>/` | Publik; satu produk |
| Jehezkiel / Product | GET | `categories/` | Publik; daftar kategori |
| Rheza / Cart | GET | `cart/` | Keranjang akun saat ini; subtotal dihitung server, barang tidak tersedia dikecualikan |
| Faris / Order | GET | `orders/` | Pesanan pembelian akun saat ini; `role=seller` untuk penjualan, `role=staff` khusus petugas |
| Faris / Order | GET | `orders/<uuid:id>/` | Invoice milik pembeli yang login; akun lain mendapat 404 |
| Alfan / Review | GET | `reviews/` | Publik; filter `product=<int:id>`; `mine=true` membutuhkan login |

## Autentikasi dan respons

1. POST `auth/login/` dengan `Content-Type: application/json`. Akun yang sama dapat dipakai di web dan mobile; akun nonaktif ditolak.
2. Simpan token hanya dalam memori aplikasi. Request berikutnya membawa `Authorization: Token <token>` dan `Accept: application/json`.
3. POST `auth/logout/` mencabut token di server. Jangan mencoba membaca JSON dari respons 204. Token yang ditolak (401) mengembalikan mobile ke keadaan belum login.
4. Gunakan HTTPS untuk PWS. SessionAuthentication tetap tersedia bagi klien website dan **tetap memeriksa CSRF** saat menulis. TokenAuthentication merupakan pilihan tambahan untuk klien mobile; tidak ada penonaktifan CSRF global.

List produk, kategori, favorit, pesanan dan ulasan memakai paginasi DRF, 20 baris/halaman:

```json
{"count": 0, "next": null, "previous": null, "results": []}
```

Di atas adalah contoh bentuk respons; isi `results` mengikuti jumlah data sebenarnya. Kirim `page=2` untuk halaman berikutnya; sertakan kembali filter yang aktif. Aplikasi menyediakan tombol **Muat berikutnya** dan **Perbarui**.

Produk berisi `id`, `name`, `slug`, `description`, `price` (integer Rupiah), `stock`, `condition`, `condition_display`, `brand`, `weight_grams`, `image_url`, `category` (`id`, `name`, `slug`, atau null), `seller_id`, `seller_name`, `created_at`, `updated_at`. Tidak ada pembungkus `pk`/`fields` serializer Django lama.

Keranjang berbentuk `{"items": [...], "subtotal": 90000, "total_items": 2}`. Item berisi `id`, objek `product` (dapat null bila produk dihapus), `quantity`, `line_total`, `available`, dan `unavailable_reason`. Subtotal hanya mencakup barang tersedia dan belum mencakup ongkir.

Profil hanya berisi informasi akun peminta: `username`, `email`, `is_staff`, `full_name`, `faculty`, `student_id`, `phone_number`, `address`, `bio`. Field akun dan peran hanya dapat dibaca. PATCH menggunakan validasi form web; untuk profil yang belum lengkap, lengkapi seluruh field wajib dalam satu request.

Pesanan memuat `id` (UUID), `number`, `status`, `status_display`, `delivery_method`, `delivery_method_display`, `subtotal`, `shipping_cost`, `total`, `payment_status`, `tracking_number`, `created_at`, dan `items`. Daftar publik tidak mengekspos alamat/nomor telepon pembeli. Ulasan memuat `id`, `product_id`, `product_name`, `username`, `rating`, `comment`, `edited`, `created_at`.

Status: 200 berhasil; 204 logout; 400 input salah; 401 belum login/token ditolak; 403 izin/CSRF ditolak; 404 objek atau halaman tidak ditemukan; 405 method belum disediakan; 429 batas login. Error umum berbentuk `{"detail": "..."}` dan error validasi berbentuk objek pesan per field. Loading, error jaringan, error server, dan daftar kosong ditampilkan terpisah pada mobile.

## Batas checkpoint

Endpoint baca setiap modul dan autentikasi sudah diimplementasikan. Endpoint POST/PATCH/DELETE produk, mutasi keranjang/favorit, checkout/transisi pesanan, serta tulis ulasan **merupakan pekerjaan lanjutan** masing-masing pemilik modul. Method tersebut belum tersedia pada endpoint baca (405), bukan diisi dummy yang mengaku berhasil. Django tetap menjadi otoritas stok, harga, pemilik objek, dan verified purchase ketika fitur tulis dikembangkan.

## Menjalankan dan memeriksa backend lokal

Di repositori Django, gunakan Python 3.12+ dan virtual environment, lalu:

```powershell
python -m pip install -r requirements.txt
python manage.py migrate
python manage.py check
python manage.py test tests.test_mobile_api
python manage.py runserver 0.0.0.0:8000
```

`migrate` juga membuat tabel token bawaan DRF. API tidak membutuhkan perubahan pada model bisnis web. Periksa `http://127.0.0.1:8000/api/v1/` dan `/api/v1/products/` lewat browser. Daftar akun melalui website terlebih dahulu; jangan menaruh akun/password produksi di kode, README, fixture, atau repositori mobile.

Untuk deployment PWS, kode backend perlu di-push ke remote PWS; proses `release` menjalankan migrasi dan collectstatic. Verifikasi API root, katalog dan ulasan mengembalikan 200 JSON, endpoint privat tanpa token mengembalikan 401 JSON, lalu uji alur login dengan akun sendiri. Menjalankan server lokal tidak otomatis memperbarui PWS.

## Acuan

Pola serializer, API view, permission, kode status dan pengujian mengikuti Tutorial 07 yang diberikan. Pilihan token mobile mengacu pada [DRF Authentication](https://www.django-rest-framework.org/api-guide/authentication/#tokenauthentication); pemanggilan HTTP dan decoding JSON mengikuti [Flutter networking](https://docs.flutter.dev/cookbook/networking/fetch-data).
