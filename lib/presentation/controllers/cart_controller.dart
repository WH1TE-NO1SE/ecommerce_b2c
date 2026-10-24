import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/exceptions/stock_exception.dart';
import '../../data/models/cart.dart';
import '../../data/models/product.dart';

class CartController extends GetxController {
  static const _cartKey = 'cart_items';

  final RxList<CartItem> items = <CartItem>[].obs;

  double get totalAmount => items
      .where((item) => item.isSelected)
      .fold(0, (sum, item) => sum + item.totalPrice);

  int get totalCount => items
      .where((item) => item.isSelected)
      .fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  void _loadFromStorage() {
    try {
      final box = GetStorage();
      final data = box.read<List>(_cartKey);
      if (data != null) {
        items.value = data
            .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      items.clear();
    }
  }

  void _saveToStorage() {
    try {
      final box = GetStorage();
      box.write(_cartKey, items.map((e) => e.toJson()).toList());
    } catch (e) {
      // ignore
    }
  }

  void addToCart(Product product, ProductSku? sku, int quantity) {
    // v1.1 修复：库存校验（模拟 409 冲突）
    final stock = sku?.stock ?? product.stock;
    final existIdx = items
        .indexWhere((i) => i.product.id == product.id && i.sku?.id == sku?.id);
    final existQty = existIdx >= 0 ? items[existIdx].quantity : 0;
    if (stock > 0 && existQty + quantity > stock) {
      throw StockException('该商品仅剩 $stock 件', available: stock);
    }

    if (existIdx >= 0) {
      items[existIdx].quantity += quantity;
    } else {
      items.add(CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        product: product,
        sku: sku,
        quantity: quantity,
        isSelected: true,
        addTime: DateTime.now(),
      ));
    }
    _saveToStorage();
  }

  void removeFromCart(String itemId) {
    items.removeWhere((i) => i.id == itemId);
    _saveToStorage();
  }

  void updateQuantity(String itemId, int quantity) {
    final idx = items.indexWhere((i) => i.id == itemId);
    if (idx >= 0) {
      if (quantity <= 0) {
        removeFromCart(itemId);
      } else {
        items[idx].quantity = quantity;
        _saveToStorage();
      }
    }
  }

  void toggleSelection(String itemId) {
    final idx = items.indexWhere((i) => i.id == itemId);
    if (idx >= 0) {
      items[idx].isSelected = !items[idx].isSelected;
      _saveToStorage();
    }
  }

  void selectAll(bool selected) {
    for (var item in items) {
      item.isSelected = selected;
    }
    items.refresh();
    _saveToStorage();
  }

  void clearCart() {
    items.clear();
    _saveToStorage();
  }
}
