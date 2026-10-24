import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/product.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/user_controller.dart';
import '../../../core/exceptions/stock_exception.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Product product;
  int quantity = 1;
  int selectedSkuIndex = 0;

  @override
  void initState() {
    super.initState();
    product = Get.arguments as Product;
  }

  /// v1.1: 立即购买 → 显示确认 BottomSheet（地址+运费+优惠券）
  void _showBuyConfirmSheet() {
    final sku = product.skus.isNotEmpty ? product.skus[selectedSkuIndex] : null;
    final unitPrice = sku?.price ?? product.price;
    const freight = 10.0; // 模拟运费
    final total = unitPrice * quantity;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BuyConfirmSheet(
        productName: product.name,
        sku: sku?.specValue,
        quantity: quantity,
        unitPrice: unitPrice,
        freight: freight,
        total: total + freight,
        onConfirm: () {
          Navigator.pop(context);
          // 模拟创建订单
          Get.snackbar(
            '下单成功',
            '订单已提交！',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
          // 跳转到订单列表
          Get.offNamed(AppRoutes.orderList);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBgColor,
      appBar: AppBar(
        title: const Text('商品详情'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 商品图片
            AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                product.image,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[100],
                    child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 64),
                ),
              ),
            ),

            // 基本信息
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 价格行
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '¥${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.priceColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '¥${product.originalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 商品名
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 评分销量
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(' ${product.rating}',
                          style:
                              const TextStyle(color: AppTheme.textSecondary)),
                      const SizedBox(width: 16),
                      Text('${product.sales}人付款',
                          style:
                              const TextStyle(color: AppTheme.textSecondary)),
                      const SizedBox(width: 16),
                      Text('库存: ${product.stock}',
                          style:
                              const TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // SKU选择
            if (product.skus.isNotEmpty)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '选择规格',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(
                        product.skus.length,
                        (index) {
                          final sku = product.skus[index];
                          final isSelected = index == selectedSkuIndex;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => selectedSkuIndex = index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryColor.withOpacity(0.1)
                                    : Colors.grey[100],
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                sku.specValue,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // 商品详情
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '商品详情',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 评价列表
            if (product.reviews.isNotEmpty)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '商品评价',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${product.reviews.length}条评价',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...product.reviews.map((review) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.grey[300],
                                    child: const Icon(Icons.person, size: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(review.username,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  const Spacer(),
                                  Row(
                                    children: List.generate(
                                        5,
                                        (i) => Icon(
                                              Icons.star,
                                              size: 14,
                                              color: i < review.rating
                                                  ? Colors.amber
                                                  : Colors.grey[300],
                                            )),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(review.content,
                                  style: const TextStyle(fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(
                                '${review.productSpec} | ${review.createTime.toString().split(' ')[0]}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: Colors.white,
        child: Row(
          children: [
            const SizedBox(width: 16),
            // 数量选择
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed:
                      quantity > 1 ? () => setState(() => quantity--) : null,
                ),
                Text('$quantity',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: quantity < product.stock
                      ? () => setState(() => quantity++)
                      : null,
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
                final cartController = Get.find<CartController>();
                final sku = product.skus.isNotEmpty
                    ? product.skus[selectedSkuIndex]
                    : null;
                try {
                  cartController.addToCart(product, sku, quantity);
                  Get.snackbar(
                    '已加入购物车',
                    '${product.name} x$quantity',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppTheme.primaryColor,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                    duration: const Duration(seconds: 2),
                  );
                } on StockException catch (e) {
                  Get.snackbar('库存不足', e.message,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16));
                }
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('加入购物车'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (!Get.find<UserController>().isLoggedIn.value) {
                  Get.toNamed(AppRoutes.login);
                  return;
                }
                _showBuyConfirmSheet();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('立即购买'),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

/// v1.1: 购买确认 BottomSheet（地址+运费+优惠券）
class _BuyConfirmSheet extends StatelessWidget {
  final String productName;
  final String? sku;
  final int quantity;
  final double unitPrice;
  final double freight;
  final double total;
  final VoidCallback onConfirm;

  const _BuyConfirmSheet({
    required this.productName,
    this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.freight,
    required this.total,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部指示条
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 标题
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    '确认订单',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 收货地址
            ListTile(
              leading:
                  const Icon(Icons.location_on, color: AppTheme.primaryColor),
              title: const Text('白噪音',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text('138****8888  山东省济南市历下区XX路XX号'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Get.snackbar('地址管理', '地址管理功能开发中',
                    snackPosition: SnackPosition.BOTTOM);
              },
            ),
            const Divider(height: 1),
            // 商品信息
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(productName,
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        if (sku != null) ...[
                          const SizedBox(height: 4),
                          Text(sku!,
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 12)),
                        ],
                        const SizedBox(height: 4),
                        Text('x$quantity  ¥${unitPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 优惠券行
            ListTile(
              leading: const Icon(Icons.local_offer_outlined,
                  color: AppTheme.primaryColor),
              title: const Text('优惠券'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '暂无可用',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
              onTap: () {
                Get.snackbar('优惠券', '优惠券功能开发中',
                    snackPosition: SnackPosition.BOTTOM);
              },
            ),
            const Divider(height: 1),
            // 金额明细
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('商品总额',
                          style: TextStyle(color: AppTheme.textSecondary)),
                      Text('¥${(unitPrice * quantity).toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('运费',
                          style: TextStyle(color: AppTheme.textSecondary)),
                      Text('¥${freight.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('优惠',
                          style: TextStyle(color: AppTheme.textSecondary)),
                      Text('-¥0.00', style: TextStyle(color: Colors.green)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('实付款',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        '¥${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.priceColor,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 确认按钮
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('提交订单 (¥${total.toStringAsFixed(2)})'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
