import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/network/api_client.dart';
import '../../data/models/order.dart';
import '../../data/models/cart.dart';

class OrderController extends GetxController {
  static const _ordersKey = 'orders';

  final RxList<Order> orders = <Order>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<OrderStatus?> selectedStatus = Rx<OrderStatus?>(null);

  List<Order> get filteredOrders {
    final s = selectedStatus.value;
    if (s == null) return orders;
    return orders.where((o) => o.status == s).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
    refreshOrders(); // 尝试从 API 刷新
  }

  void _loadFromStorage() {
    try {
      isLoading.value = true;
      final box = GetStorage();
      final data = box.read<List>(_ordersKey);
      if (data != null && data.isNotEmpty) {
        orders.value = data
            .map((e) => Order.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      isLoading.value = false;
    } catch (e) {
      orders.clear();
      isLoading.value = false;
    }
  }

  void _saveToStorage() {
    try {
      final box = GetStorage();
      box.write(_ordersKey, orders.map((e) => e.toJson()).toList());
    } catch (e) {
      // ignore
    }
  }

  /// 创建订单 — 调用真实 API，回退到本地
  Future<String?> createOrder({
    required List<CartItem> items,
    required double subtotal,
    required double freight,
    required double discount,
    required Map<String, dynamic> address,
  }) async {
    try {
      final resp = await ApiClient.post('/orders', data: {
        'items': items
            .map((i) => {
                  'productId': i.product.id,
                  'skuId': i.sku?.id,
                  'quantity': i.quantity,
                })
            .toList(),
        'freight': freight,
        'discount': discount,
        'address': address,
      });
      final data = resp.data;
      final orderId = data['orderId'] as String;
      // 刷新订单列表
      await refreshOrders();
      return orderId;
    } catch (e) {
      // 回退到本地创建
      return addOrder(
          items, subtotal, freight, discount, _addressFromMap(address));
    }
  }

  /// 本地创建订单（离线回退）
  String addOrder(List<CartItem> items, double totalAmount, double freight,
      double discount, Address address) {
    final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
    final order = Order(
      id: orderId,
      orderNo: 'DD${DateTime.now().millisecondsSinceEpoch}',
      items: items,
      totalAmount: totalAmount,
      freight: freight,
      discount: discount,
      status: OrderStatus.pending,
      address: address,
      payment: Payment(
        id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
        orderId: orderId,
        amount: totalAmount + freight - discount,
        payMethod: '微信支付',
        status: 'pending',
      ),
      logistics: null,
      createTime: DateTime.now(),
    );
    orders.insert(0, order);
    _saveToStorage();
    return orderId;
  }

  /// 从 API 刷新订单列表
  Future<void> refreshOrders() async {
    try {
      isLoading.value = true;
      final resp = await ApiClient.get('/orders');
      final list = resp.data['items'] as List;
      orders.value = list.map((o) => Order.fromJson(o)).toList();
      _saveToStorage();
      isLoading.value = false;
    } catch (e) {
      // API 不可用，保持本地数据
      isLoading.value = false;
    }
  }

  /// v1.3: 合法的订单状态转换表
  static const _validTransitions = {
    OrderStatus.pending: [OrderStatus.paid, OrderStatus.cancelled],
    OrderStatus.paid: [
      OrderStatus.shipped,
      OrderStatus.cancelled,
      OrderStatus.refunding
    ],
    OrderStatus.shipped: [OrderStatus.delivering, OrderStatus.delivered],
    OrderStatus.delivering: [OrderStatus.delivered],
    OrderStatus.delivered: [OrderStatus.completed, OrderStatus.refunding],
    OrderStatus.completed: [],
    OrderStatus.cancelled: [],
    OrderStatus.refunding: [OrderStatus.refunded],
    OrderStatus.refunded: [],
  };

  /// 更新订单状态 — 调用真实 API，回退到本地
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx < 0) return;

    final old = orders[idx];
    final allowed = _validTransitions[old.status] ?? [];
    if (!allowed.contains(status)) {
      debugPrint('非法状态转换: ${old.status.name} → ${status.name}');
      Get.snackbar('操作失败',
          '订单状态不允许从"${_statusLabel(old.status)}"变为"${_statusLabel(status)}"',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // 尝试 API
    try {
      await ApiClient.put('/orders/$orderId/status',
          data: {'status': status.name});
    } catch (_) {
      // API 不可用，本地更新
    }

    // 本地更新
    orders[idx] = Order(
      id: old.id,
      orderNo: old.orderNo,
      items: old.items,
      totalAmount: old.totalAmount,
      freight: old.freight,
      discount: old.discount,
      status: status,
      address: old.address,
      payment: old.payment,
      logistics: old.logistics,
      createTime: old.createTime,
      payTime: status == OrderStatus.paid ? DateTime.now() : old.payTime,
      shipTime: status == OrderStatus.shipped ? DateTime.now() : old.shipTime,
      receiveTime:
          status == OrderStatus.delivered ? DateTime.now() : old.receiveTime,
      completeTime:
          status == OrderStatus.completed ? DateTime.now() : old.completeTime,
    );
    orders.refresh(); // 强制通知 Obx 刷新
    _saveToStorage();
  }

  /// 模拟支付 — 调用真实 API
  Future<bool> payOrder(String orderId, {String payMethod = '微信支付'}) async {
    try {
      await ApiClient.post('/orders/$orderId/pay',
          data: {'payMethod': payMethod});
      await updateOrderStatus(orderId, OrderStatus.paid);
      return true;
    } catch (e) {
      // 回退到本地
      await updateOrderStatus(orderId, OrderStatus.paid);
      return true;
    }
  }

  void filterByStatus(OrderStatus? status) {
    selectedStatus.value = status;
  }

  String _statusLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return '待支付';
      case OrderStatus.paid:
        return '已支付';
      case OrderStatus.shipped:
        return '已发货';
      case OrderStatus.delivering:
        return '配送中';
      case OrderStatus.delivered:
        return '已收货';
      case OrderStatus.completed:
        return '已完成';
      case OrderStatus.cancelled:
        return '已取消';
      case OrderStatus.refunding:
        return '退款中';
      case OrderStatus.refunded:
        return '已退款';
    }
  }

  Address _addressFromMap(Map<String, dynamic> m) => Address(
        id: m['id'] ?? '',
        receiverName: m['receiverName'] ?? '',
        phone: m['phone'] ?? '',
        province: m['province'] ?? '',
        city: m['city'] ?? '',
        district: m['district'] ?? '',
        detail: m['detail'] ?? '',
        isDefault: m['isDefault'] ?? false,
      );

  /// 催发货
  void remindShipment(String orderId) {
    debugPrint('[$orderId] 用户催发货');
    Get.snackbar('已提醒', '已通知卖家尽快发货', snackPosition: SnackPosition.BOTTOM);
  }
}
