import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../data/models/product.dart';
import '../../data/providers/mock_data_provider.dart';
import '../../data/services/product_storage_service.dart';

/// 极简版 HomeController
/// v1.3: 优先从 API 加载，回退到本地 Mock
class HomeControllerSimple extends GetxController {
  final RxList<Category> categories = <Category>[].obs;
  final RxList<Product> products = <Product>[].obs;
  final RxList<Product> searchResults = <Product>[].obs;
  final RxString searchKeyword = ''.obs;
  final RxBool isSearching = false.obs;
  final RxInt selectedCategoryIndex = 0.obs;
  final RxBool isLoading = false.obs;

  final _storageService = ProductStorageService();

  // v1.3: 缓存过滤结果
  List<Product>? _cachedDisplayProducts;
  int _cacheCategoryIndex = -1;
  bool _cacheIsSearching = false;
  String _cacheSearchKeyword = '';

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    await _initCategories();
    await _initProducts();
    isLoading.value = false;
  }

  @override
  Future<void> refresh() async {
    _cachedDisplayProducts = null;
    await _loadData();
  }

  Future<void> _initCategories() async {
    try {
      final resp = await ApiClient.get('/categories');
      final list = resp.data as List;
      categories.value = list
          .map((c) => Category(
                id: c['id'],
                name: c['name'],
                icon: c['icon'] ?? '',
              ))
          .toList();
    } catch (e) {
      // 回退到 Mock
      categories.value = MockDataProvider.categories;
    }
  }

  Future<void> _initProducts() async {
    try {
      final resp = await ApiClient.get('/products', query: {'size': 100});
      final data = resp.data;
      final list = data['items'] as List;
      products.value = list.map((p) => Product.fromJson(p)).toList();
    } catch (e) {
      // 回退到本地 Storage
      products.value = _storageService.getAllProducts();
      if (products.isEmpty) {
        _storageService.initializeDefaultProducts();
        products.value = _storageService.getAllProducts();
      }
    }
  }

  void search(String keyword) {
    searchKeyword.value = keyword;
    _cachedDisplayProducts = null;
    if (keyword.isEmpty) {
      searchResults.clear();
      isSearching.value = false;
    } else {
      isSearching.value = true;
      searchResults.value = products
          .where((p) =>
              p.name.contains(keyword) || p.description.contains(keyword))
          .toList();
    }
  }

  void clearSearch() {
    searchKeyword.value = '';
    searchResults.clear();
    isSearching.value = false;
    _cachedDisplayProducts = null;
  }

  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
    _cachedDisplayProducts = null;
  }

  List<Product> get displayProducts {
    final catIdx = selectedCategoryIndex.value;
    final searching = isSearching.value;
    final kw = searchKeyword.value;
    if (_cachedDisplayProducts != null &&
        _cacheCategoryIndex == catIdx &&
        _cacheIsSearching == searching &&
        _cacheSearchKeyword == kw) {
      return _cachedDisplayProducts!;
    }
    _cacheCategoryIndex = catIdx;
    _cacheIsSearching = searching;
    _cacheSearchKeyword = kw;
    if (searching) {
      _cachedDisplayProducts = searchResults;
    } else if (catIdx == 0) {
      _cachedDisplayProducts = products;
    } else if (categories.isEmpty) {
      _cachedDisplayProducts = products;
    } else {
      final catId = categories[catIdx - 1].id;
      _cachedDisplayProducts =
          products.where((p) => p.category == catId).toList();
    }
    return _cachedDisplayProducts!;
  }

  String formatPrice(double price) => '¥${price.toStringAsFixed(2)}';
  String formatSales(int sales) =>
      sales >= 10000 ? '${(sales / 10000).toStringAsFixed(1)}万+' : '$sales';
}
