class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final String image;
  final List<String> images;
  final String category;
  final double rating;
  final int sales;
  final int stock;
  final List<ProductSku> skus;
  final List<Review> reviews;
  final String tags; // 商品标签，逗号分隔（如"热卖,包邮,新品"）

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.image,
    required this.images,
    required this.category,
    required this.rating,
    required this.sales,
    required this.stock,
    required this.skus,
    required this.reviews,
    this.tags = '',
  });

  // v1.3: 统一序列化
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'originalPrice': originalPrice,
        'image': image,
        'images': images,
        'category': category,
        'rating': rating,
        'sales': sales,
        'stock': stock,
        'skus': skus.map((s) => s.toJson()).toList(),
        'tags': tags,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? 0,
        image: json['image'] ?? '',
        images: (json['images'] as List?)?.cast<String>() ?? [],
        category: json['category'] ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        sales: json['sales'] ?? 0,
        stock: json['stock'] ?? 0,
        skus: (json['skus'] as List?)
                ?.map((e) => ProductSku.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            [],
        reviews: [],
        tags: json['tags'] ?? '',
      );
}

class ProductSku {
  final String id;
  final String specName;
  final String specValue;
  final double price;
  final int stock;

  ProductSku({
    required this.id,
    required this.specName,
    required this.specValue,
    required this.price,
    required this.stock,
  });

  // v1.3: 统一序列化
  Map<String, dynamic> toJson() => {
        'id': id,
        'specName': specName,
        'specValue': specValue,
        'price': price,
        'stock': stock,
      };

  factory ProductSku.fromJson(Map<String, dynamic> json) => ProductSku(
        id: json['id'] ?? '',
        specName: json['specName'] ?? '',
        specValue: json['specValue'] ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        stock: json['stock'] ?? 0,
      );
}

class Review {
  final String id;
  final String userId;
  final String username;
  final String avatar;
  final int rating;
  final String content;
  final DateTime createTime;
  final String productSpec;

  Review({
    required this.id,
    required this.userId,
    required this.username,
    required this.avatar,
    required this.rating,
    required this.content,
    required this.createTime,
    required this.productSpec,
  });
}

class Category {
  final String id;
  final String name;
  final String icon;

  Category({required this.id, required this.name, required this.icon});
}
