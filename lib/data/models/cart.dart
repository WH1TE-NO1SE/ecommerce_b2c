import 'product.dart';

class CartItem {
  final String id;
  final Product product;
  final ProductSku? sku;
  int quantity;
  bool isSelected;
  final DateTime addTime;

  CartItem({
    required this.id,
    required this.product,
    this.sku,
    required this.quantity,
    this.isSelected = true,
    required this.addTime,
  });

  double get totalPrice => (sku?.price ?? product.price) * quantity;

  // v1.3: 统一序列化
  Map<String, dynamic> toJson() => {
        'id': id,
        'product': product.toJson(),
        'sku': sku?.toJson(),
        'quantity': quantity,
        'isSelected': isSelected,
        'addTime': addTime.toIso8601String(),
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'];
    final Product product;
    if (productJson is Map) {
      product = Product.fromJson(Map<String, dynamic>.from(productJson));
    } else {
      // 兼容旧格式（仅存 productId）
      product = Product(
        id: json['productId'] as String? ?? '',
        name: json['productName'] ?? '商品已下架',
        description: '',
        price: (json['productPrice'] as num?)?.toDouble() ?? 0,
        originalPrice: 0,
        image: json['productImage'] ?? '',
        images: [],
        category: '',
        rating: 0,
        sales: 0,
        stock: 0,
        skus: [],
        reviews: [],
      );
    }
    final skuJson = json['sku'];
    return CartItem(
      id: json['id'] ?? '',
      product: product,
      sku: skuJson is Map
          ? ProductSku.fromJson(Map<String, dynamic>.from(skuJson))
          : null,
      quantity: json['quantity'] ?? 1,
      isSelected: json['isSelected'] ?? true,
      addTime: json['addTime'] != null
          ? DateTime.parse(json['addTime'])
          : DateTime.now(),
    );
  }
}

class Cart {
  final List<CartItem> items;

  Cart({required this.items});

  double get totalAmount => items
      .where((item) => item.isSelected)
      .fold(0, (sum, item) => sum + item.totalPrice);

  int get totalCount => items
      .where((item) => item.isSelected)
      .fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;
}
