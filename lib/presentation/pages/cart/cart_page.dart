import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/cart.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/user_controller.dart';
import '../../../core/exceptions/stock_exception.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBgColor,
      appBar: AppBar(
        title: const Text('购物车'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        actions: [
          Obx(() => controller.items.isNotEmpty
              ? TextButton(
                  onPressed: () => _showClearDialog(context, controller),
                  child: const Text('清空',
                      style: TextStyle(color: AppTheme.textSecondary)),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (!Get.find<UserController>().isLoggedIn.value) {
          return _buildNotLoggedIn(context);
        }
        if (controller.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined,
                    size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text('购物车是空的',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('去逛逛'),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            // 全选行
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      final allSelected =
                          controller.items.every((item) => item.isSelected);
                      controller.selectAll(!allSelected);
                    },
                    child: Row(
                      children: [
                        Obx(() {
                          final allSelected =
                              controller.items.every((item) => item.isSelected);
                          return Icon(
                            allSelected
                                ? Icons.check_circle
                                : Icons.radio_button_off,
                            color: allSelected
                                ? AppTheme.primaryColor
                                : Colors.grey,
                          );
                        }),
                        const SizedBox(width: 8),
                        const Text('全选'),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // 已选商品数量（种类数）
                  Obx(() {
                    final selectedCount = controller.items
                        .where((item) => item.isSelected)
                        .length;
                    return Text(
                      '已选 $selectedCount 种',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    );
                  }),
                ],
              ),
            ),
            const Divider(height: 1),
            // 商品列表
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: controller.items.length,
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // 选择框
                        GestureDetector(
                          onTap: () => controller.toggleSelection(item.id),
                          child: Icon(
                            item.isSelected
                                ? Icons.check_circle
                                : Icons.radio_button_off,
                            color: item.isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 商品图片
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.product.image,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 商品信息
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              if (item.sku != null) ...[
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => _showSpecSheet(context, item),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          item.sku!.specValue,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.textSecondary),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.arrow_drop_down,
                                            size: 14),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    '¥${(item.sku?.price ?? item.product.price).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        color: AppTheme.priceColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 18),
                                    onPressed: () {
                                      if (item.quantity > 1) {
                                        controller.updateQuantity(
                                            item.id, item.quantity - 1);
                                      } else {
                                        controller.removeFromCart(item.id);
                                      }
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Text('${item.quantity}'),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 18),
                                    onPressed: () {
                                      controller.updateQuantity(
                                          item.id, item.quantity + 1);
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // 删除按钮
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppTheme.textSecondary),
                          onPressed: () => controller.removeFromCart(item.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // 底部结算栏
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(() => Text(
                              '合计: ¥${controller.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.priceColor,
                              ),
                            )),
                        Text(
                          '共${controller.totalCount}件商品',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        if (!Get.find<UserController>().isLoggedIn.value) {
                          Get.toNamed(AppRoutes.login);
                          return;
                        }
                        final selectedItems = controller.items
                            .where((item) => item.isSelected)
                            .toList();
                        if (selectedItems.isEmpty) {
                          Get.snackbar('提示', '请选择要结算的商品',
                              snackPosition: SnackPosition.BOTTOM,
                              margin: const EdgeInsets.all(16));
                          return;
                        }
                        Get.toNamed(AppRoutes.orderConfirm,
                            arguments: {'items': selectedItems});
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text('去结算'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showClearDialog(BuildContext context, CartController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('清空购物车'),
        content: const Text('确定要清空购物车吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              controller.clearCart();
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showSpecSheet(BuildContext context, CartItem item) {
    if (item.product.skus.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '选择规格',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item.product.skus.map((sku) {
                final isSelected = sku.id == item.sku?.id;
                return GestureDetector(
                  onTap: () {
                    final controller = Get.find<CartController>();
                    final qty = item.quantity;
                    try {
                      controller.removeFromCart(item.id);
                      controller.addToCart(item.product, sku, qty);
                      Navigator.pop(context);
                    } on StockException catch (e) {
                      // 切换失败，恢复原商品
                      controller.addToCart(item.product, item.sku, qty);
                      Get.snackbar('库存不足', e.message,
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(16));
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppTheme.primaryColor : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Text(
                      sku.specValue,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_circle_outlined,
              size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('您还未登录',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('登录后可查看购物车',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.toNamed(AppRoutes.login),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor),
            child: const Text('去登录'),
          ),
        ],
      ),
    );
  }
}
