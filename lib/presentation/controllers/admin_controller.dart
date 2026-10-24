import 'package:get/get.dart';
import '../../core/network/api_client.dart';

/// 管理后台统一控制器
class AdminController extends GetxController {
  // 数据中心
  final RxMap<String, dynamic> dashboard = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> topProducts = <Map<String, dynamic>>[].obs;

  // 商品
  final RxList<Map<String, dynamic>> products = <Map<String, dynamic>>[].obs;
  final RxInt productTotal = 0.obs;
  final RxString productKeyword = ''.obs;
  final RxString productStatusFilter = ''.obs;

  // 订单
  final RxList<Map<String, dynamic>> orders = <Map<String, dynamic>>[].obs;
  final RxInt orderTotal = 0.obs;
  final RxString orderStatusFilter = ''.obs;

  // 用户
  final RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;
  final RxInt userTotal = 0.obs;
  final RxString userKeyword = ''.obs;

  // 优惠券
  final RxList<Map<String, dynamic>> coupons = <Map<String, dynamic>>[].obs;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  // ========== 数据中心 ==========
  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;
      final resp = await ApiClient.get('/admin/dashboard');
      dashboard.value = Map<String, dynamic>.from(resp.data);
      topProducts.value = (resp.data['topProducts'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [];
    } catch (e) {
      Get.snackbar('错误', '加载统计数据失败');
    } finally {
      isLoading.value = false;
    }
  }

  // ========== 商品管理 ==========
  Future<void> loadProducts({int page = 1}) async {
    try {
      isLoading.value = true;
      final params = <String, dynamic>{'page': page, 'size': 20};
      if (productKeyword.isNotEmpty) params['keyword'] = productKeyword.value;
      if (productStatusFilter.isNotEmpty) {
        params['status'] = productStatusFilter.value;
      }
      final resp = await ApiClient.get('/admin/products', query: params);
      products.value = (resp.data['items'] as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      productTotal.value = resp.data['total'] ?? 0;
    } catch (e) {
      Get.snackbar('错误', '加载商品列表失败');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addProduct(Map<String, dynamic> data) async {
    try {
      await ApiClient.post('/admin/products', data: data);
      await loadProducts();
      Get.snackbar('成功', '商品已添加');
      return true;
    } catch (e) {
      Get.snackbar('失败', '添加商品失败');
      return false;
    }
  }

  Future<bool> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      await ApiClient.put('/admin/products/$id', data: data);
      await loadProducts();
      Get.snackbar('成功', '商品已更新');
      return true;
    } catch (e) {
      Get.snackbar('失败', '更新商品失败');
      return false;
    }
  }

  Future<void> toggleProductStatus(String id, bool isActive) async {
    try {
      await ApiClient.put('/admin/products/$id/status',
          data: {'isActive': isActive});
      await loadProducts();
      Get.snackbar('成功', isActive ? '商品已上架' : '商品已下架');
    } catch (e) {
      Get.snackbar('失败', '操作失败');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await ApiClient.delete('/admin/products/$id');
      await loadProducts();
      Get.snackbar('成功', '商品已删除');
    } catch (e) {
      Get.snackbar('失败', '删除失败');
    }
  }

  // ========== 订单管理 ==========
  Future<void> loadOrders({int page = 1}) async {
    try {
      isLoading.value = true;
      final params = <String, dynamic>{'page': page, 'size': 20};
      if (orderStatusFilter.isNotEmpty) {
        params['status'] = orderStatusFilter.value;
      }
      final resp = await ApiClient.get('/admin/orders', query: params);
      orders.value = (resp.data['items'] as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      orderTotal.value = resp.data['total'] ?? 0;
    } catch (e) {
      Get.snackbar('错误', '加载订单列表失败');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> shipOrder(String orderId,
      {String company = '顺丰速运', String? trackingNo}) async {
    try {
      await ApiClient.put('/admin/orders/$orderId/ship', data: {
        'company': company,
        if (trackingNo != null) 'trackingNo': trackingNo,
      });
      await loadOrders();
      Get.snackbar('成功', '已发货');
    } catch (e) {
      Get.snackbar('失败', '发货失败');
    }
  }

  // ========== 用户管理 ==========
  Future<void> loadUsers({int page = 1}) async {
    try {
      isLoading.value = true;
      final params = <String, dynamic>{'page': page, 'size': 20};
      if (userKeyword.isNotEmpty) params['keyword'] = userKeyword.value;
      final resp = await ApiClient.get('/admin/users', query: params);
      users.value = (resp.data['items'] as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      userTotal.value = resp.data['total'] ?? 0;
    } catch (e) {
      Get.snackbar('错误', '加载用户列表失败');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserRole(String userId, String role) async {
    try {
      await ApiClient.put('/admin/users/$userId/role', data: {'role': role});
      await loadUsers();
      Get.snackbar('成功', '角色已更新');
    } catch (e) {
      Get.snackbar('失败', '更新角色失败');
    }
  }

  // ========== 优惠券管理 ==========
  Future<void> loadCoupons() async {
    try {
      isLoading.value = true;
      final resp = await ApiClient.get('/admin/coupons');
      coupons.value = (resp.data['items'] as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (e) {
      Get.snackbar('错误', '加载优惠券失败');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addCoupon(Map<String, dynamic> data) async {
    try {
      await ApiClient.post('/admin/coupons', data: data);
      await loadCoupons();
      Get.snackbar('成功', '优惠券已创建');
      return true;
    } catch (e) {
      Get.snackbar('失败', '创建失败');
      return false;
    }
  }

  Future<void> deleteCoupon(String id) async {
    try {
      await ApiClient.delete('/admin/coupons/$id');
      await loadCoupons();
      Get.snackbar('成功', '优惠券已删除');
    } catch (e) {
      Get.snackbar('失败', '删除失败');
    }
  }
}
