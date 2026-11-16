class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.condition,
    required this.seller,
    required this.category,
    required this.imageUrl,
  });
  final int id, price, stock;
  final String name, description, condition, seller, category, imageUrl;
  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as int,
    name: json['name'] as String,
    description: json['description'] as String,
    price: json['price'] as int,
    stock: json['stock'] as int,
    condition: json['condition_display'] as String,
    seller: json['seller_name'] as String,
    category:
        (json['category'] as Map<String, dynamic>?)?['name'] as String? ??
        'Lainnya',
    imageUrl: json['image_url'] as String? ?? '',
  );
}

class ProfileData {
  const ProfileData({
    required this.username,
    required this.email,
    required this.fullName,
    required this.faculty,
    required this.studentId,
    required this.phone,
    required this.bio,
    required this.address,
    required this.isStaff,
  });
  final String username,
      email,
      fullName,
      faculty,
      studentId,
      phone,
      bio,
      address;
  final bool isStaff;
  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
    username: json['username'] as String,
    email: json['email'] as String,
    fullName: json['full_name'] as String,
    faculty: json['faculty'] as String,
    studentId: json['student_id'] as String,
    phone: json['phone_number'] as String,
    bio: json['bio'] as String,
    address: json['address'] as String,
    isStaff: json['is_staff'] as bool,
  );
}

class CartItemData {
  const CartItemData({
    required this.product,
    required this.quantity,
    required this.total,
    required this.available,
    required this.reason,
  });
  final Product? product;
  final int quantity, total;
  final bool available;
  final String reason;
  factory CartItemData.fromJson(Map<String, dynamic> json) => CartItemData(
    product: json['product'] == null
        ? null
        : Product.fromJson(json['product'] as Map<String, dynamic>),
    quantity: json['quantity'] as int,
    total: json['line_total'] as int,
    available: json['available'] as bool,
    reason: json['unavailable_reason'] as String,
  );
}

class CartData {
  const CartData(this.items, this.subtotal, this.totalItems);
  final List<CartItemData> items;
  final int subtotal, totalItems;
  factory CartData.fromJson(Map<String, dynamic> json) => CartData(
    (json['items'] as List)
        .map((row) => CartItemData.fromJson(row as Map<String, dynamic>))
        .toList(),
    json['subtotal'] as int,
    json['total_items'] as int,
  );
}

class OrderData {
  const OrderData({
    required this.number,
    required this.status,
    required this.delivery,
    required this.total,
    required this.itemNames,
    required this.createdAt,
  });
  final String number, status, delivery;
  final int total;
  final List<String> itemNames;
  final DateTime createdAt;
  factory OrderData.fromJson(Map<String, dynamic> json) => OrderData(
    number: json['number'] as String,
    status: json['status_display'] as String,
    delivery: json['delivery_method_display'] as String,
    total: json['total'] as int,
    itemNames: (json['items'] as List)
        .map((row) => '${row['product_name']} × ${row['quantity']}')
        .toList(),
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}

class ReviewData {
  const ReviewData({
    required this.productName,
    required this.username,
    required this.rating,
    required this.comment,
    required this.edited,
  });
  final String productName, username, comment;
  final int rating;
  final bool edited;
  factory ReviewData.fromJson(Map<String, dynamic> json) => ReviewData(
    productName: json['product_name'] as String,
    username: json['username'] as String,
    rating: json['rating'] as int,
    comment: json['comment'] as String,
    edited: json['edited'] as bool,
  );
}

String rupiah(int value) =>
    'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
