import 'package:get_storage/get_storage.dart';
import '../models/product.dart';
import '../providers/mock_data_provider.dart';

/// 商品存储服务（v1.2）
/// 所有商品由管理员添加，统一存储在 GetStorage 中
/// v1.2: 初始化时从 MockDataProvider.products 种子数据写入，不再维护独立列表
class ProductStorageService {
  static const String _productsKey = 'admin_products';
  static const String _initializedKey = 'admin_products_initialized';

  final _box = GetStorage();

  /// 获取所有商品（从 storage 读取）
  List<Product> getAllProducts() {
    final data = _box.read<List>(_productsKey);
    if (data == null || data.isEmpty) return [];
    return data
        .map((e) => _productFromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// 初始化默认商品（仅当 storage 为空时调用一次）
  /// v1.2: 对齐 MockDataProvider 的 33 个商品，解决双数据源商品数量不一致问题
  void initializeDefaultProducts() {
    final initialized = _box.read<bool>(_initializedKey) ?? false;
    if (initialized) return;

    // 从 MockDataProvider 获取完整商品列表
    final defaultProducts = MockDataProvider.products;
    _saveProducts(defaultProducts);
    _box.write(_initializedKey, true);
  }

  /// 添加商品（管理员操作）
  void addProduct(Product product) {
    final products = getAllProducts();
    products.add(product);
    _saveProducts(products);
  }

  /// 更新商品
  void updateProduct(String productId, Product updated) {
    final products = getAllProducts();
    final index = products.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      products[index] = updated;
      _saveProducts(products);
    }
  }

  /// 删除商品
  void deleteProduct(String productId) {
    final products = getAllProducts();
    products.removeWhere((p) => p.id == productId);
    _saveProducts(products);
  }

  /// 切换商品上下架状态
  void toggleStatus(String productId) {
    final products = getAllProducts();
    final index = products.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      final p = products[index];
      final newStock = p.stock > 0 ? 0 : 100;
      products[index] = Product(
        id: p.id,
        name: p.name,
        description: p.description,
        price: p.price,
        originalPrice: p.originalPrice,
        image: p.image,
        images: p.images,
        category: p.category,
        rating: p.rating,
        sales: p.sales,
        stock: newStock,
        skus: p.skus,
        reviews: p.reviews,
      );
      _saveProducts(products);
    }
  }

  /// 保存商品列表到 storage
  void _saveProducts(List<Product> products) {
    _box.write(_productsKey, products.map((p) => _productToJson(p)).toList());
  }

  /// 将 Product 转 Map（用于存储）
  Map<String, dynamic> _productToJson(Product p) => {
        'id': p.id,
        'name': p.name,
        'description': p.description,
        'price': p.price,
        'originalPrice': p.originalPrice,
        'image': p.image,
        'images': p.images,
        'category': p.category,
        'rating': p.rating,
        'sales': p.sales,
        'stock': p.stock,
        'skus': p.skus
            .map((s) => {
                  'id': s.id,
                  'specName': s.specName,
                  'specValue': s.specValue,
                  'price': s.price,
                  'stock': s.stock,
                })
            .toList(),
        'reviews': p.reviews
            .map((r) => {
                  'id': r.id,
                  'userId': r.userId,
                  'username': r.username,
                  'avatar': r.avatar,
                  'rating': r.rating,
                  'content': r.content,
                  'createTime': r.createTime.toIso8601String(),
                  'productSpec': r.productSpec,
                })
            .toList(),
      };

  /// 从 Map 转 Product（用于读取）
  Product _productFromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      image: json['image'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      category: json['category'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      sales: json['sales'] ?? 0,
      stock: json['stock'] ?? 0,
      skus: (json['skus'] as List? ?? [])
          .map((s) => ProductSku(
                id: s['id'] ?? '',
                specName: s['specName'] ?? '',
                specValue: s['specValue'] ?? '',
                price: (s['price'] ?? 0).toDouble(),
                stock: s['stock'] ?? 0,
              ))
          .toList(),
      reviews: (json['reviews'] as List? ?? [])
          .map((r) => Review(
                id: r['id'] ?? '',
                userId: r['userId'] ?? '',
                username: r['username'] ?? '',
                avatar: r['avatar'] ?? '',
                rating: r['rating'] ?? 0,
                content: r['content'] ?? '',
                createTime: r['createTime'] != null
                    ? DateTime.parse(r['createTime'])
                    : DateTime.now(),
                productSpec: r['productSpec'] ?? '',
              ))
          .toList(),
    );
  }
}
