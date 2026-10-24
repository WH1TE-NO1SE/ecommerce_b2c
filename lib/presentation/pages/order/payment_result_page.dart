import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/order.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/cart_controller.dart';

class PaymentResultPage extends StatefulWidget {
  const PaymentResultPage({super.key});

  @override
  State<PaymentResultPage> createState() => _PaymentResultPageState();
}

class _PaymentResultPageState extends State<PaymentResultPage> {
  bool _isSuccess = true;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _isSuccess = args?['success'] ?? true;

    // 支付成功后立即更新订单状态为"已支付"，并清理购物车
    if (_isSuccess) {
      final orderId = args?['orderId'] as String?;
      final cartItemIds = (args?['cartItemIds'] as List?)?.cast<String>() ?? [];
      if (orderId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // 确保 OrderController 已注册
          if (!Get.isRegistered<OrderController>()) {
            Get.put(OrderController());
          }
          try {
            final orderController = Get.find<OrderController>();
            orderController.updateOrderStatus(orderId, OrderStatus.paid);
          } catch (_) {}
          // v1.3: 支付成功后才删除购物车商品
          if (cartItemIds.isNotEmpty && Get.isRegistered<CartController>()) {
            try {
              final cartController = Get.find<CartController>();
              for (final id in cartItemIds) {
                cartController.removeFromCart(id);
              }
            } catch (_) {}
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // 结果图标
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _isSuccess ? Colors.green[100] : Colors.red[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isSuccess ? Icons.check_circle : Icons.cancel,
                size: 60,
                color: _isSuccess ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _isSuccess ? '支付成功' : '支付失败',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              _isSuccess ? '感谢您的购买，商品正在准备中' : '请检查支付方式后重试',
              style:
                  const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const Spacer(),
            // 操作按钮
            if (_isSuccess)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.scaffoldBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ActionItem(
                      icon: Icons.receipt_long,
                      label: '查看订单',
                      onTap: () => Get.offNamed(AppRoutes.orderList),
                    ),
                    Container(width: 1, height: 40, color: Colors.grey[300]),
                    _ActionItem(
                      icon: Icons.home,
                      label: '返回首页',
                      onTap: () => Get.offAllNamed(AppRoutes.home),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Text('返回订单',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.offAllNamed(AppRoutes.home),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Text('返回首页',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionItem(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 28, color: AppTheme.primaryColor),
          const SizedBox(height: 6),
          Text(label,
              style:
                  const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
