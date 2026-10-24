import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/order.dart';
import '../../../data/models/cart.dart';
import '../../../data/models/coupon.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/address_controller.dart';

class OrderConfirmPage extends StatefulWidget {
  const OrderConfirmPage({super.key});

  @override
  State<OrderConfirmPage> createState() => _OrderConfirmPageState();
}

class _OrderConfirmPageState extends State<OrderConfirmPage> {
  final OrderController orderController = Get.find<OrderController>();
  final CartController cartController = Get.find<CartController>();
  final AddressController addressController = Get.put(AddressController());
  final List<Coupon> coupons = Coupon.getMockCoupons();
  Coupon? selectedCoupon;

  @override
  Widget build(BuildContext context) {
    final List<CartItem> items = Get.arguments?['items'] ?? [];
    final selectedItems = items.where((item) => item.isSelected).toList();

    if (!Get.find<UserController>().isLoggedIn.value) {
      return _buildNotLoggedIn(context);
    }
    if (selectedItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('确认订单')),
        body: const Center(child: Text('请选择要结算的商品')),
      );
    }

    final subtotal =
        selectedItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    final freight = subtotal >= 99 ? 0.0 : 10.0;
    // v1.1: 优惠券折扣计算
    final discount = selectedCoupon?.apply(subtotal) ?? subtotal;
    final couponDiscount = subtotal - discount;
    final total = discount + freight;

    // v1.2: 使用真实地址
    final currentAddress = addressController.selectedAddress.value ??
        addressController.defaultAddress;

    return Scaffold(
      appBar: AppBar(title: const Text('确认订单')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildAddressSection(currentAddress),
                const SizedBox(height: 16),
                _buildCouponSection(subtotal),
                const SizedBox(height: 16),
                _buildItemList(selectedItems),
                const SizedBox(height: 16),
                _buildFeeSection(subtotal, freight, couponDiscount, total),
              ],
            ),
          ),
          _buildSubmitBar(
            total: total,
            selectedItems: selectedItems,
            defaultAddress: currentAddress,
            subtotal: subtotal,
            freight: freight,
            discount: couponDiscount,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(Address? address) {
    if (address == null) {
      return GestureDetector(
        onTap: () => _navigateToAddressSelect(),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.add_location_alt_outlined,
                  color: AppTheme.primaryColor),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '请选择收货地址',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
              ),
              Icon(Icons.chevron_right),
            ],
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () => _navigateToAddressSelect(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${address.receiverName}  ${_formatPhone(address.phone)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(address.fullAddress,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  void _navigateToAddressSelect() async {
    final result = await Get.toNamed(
      AppRoutes.addressList,
      arguments: {'selectMode': true},
    );
    if (result != null && result is Address) {
      addressController.selectAddress(result);
    }
  }

  String _formatPhone(String phone) {
    if (phone.length >= 11) {
      return '${phone.substring(0, 3)}****${phone.substring(7)}';
    }
    return phone;
  }

  Widget _buildCouponSection(double subtotal) {
    final validCoupons =
        coupons.where((c) => c.isValid && subtotal >= c.threshold).toList();
    final hasSelected = selectedCoupon != null;

    return GestureDetector(
      onTap: () => _showCouponPicker(validCoupons, subtotal),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_offer_outlined,
                color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: hasSelected
                  ? Text(
                      '${selectedCoupon!.name} (${selectedCoupon!.displayValue})',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.priceColor))
                  : const Text('优惠券',
                      style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Text(
              hasSelected
                  ? '-¥${(subtotal - selectedCoupon!.apply(subtotal)).toStringAsFixed(2)}'
                  : validCoupons.isNotEmpty
                      ? '${validCoupons.length}张可用'
                      : '暂无可用',
              style: TextStyle(
                color: hasSelected ? AppTheme.priceColor : Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  void _showCouponPicker(List<Coupon> validCoupons, double subtotal) {
    if (validCoupons.isEmpty) {
      Get.snackbar('提示', '暂无可用优惠券', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('选择优惠券',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...validCoupons.map((coupon) {
              final isSelected = selectedCoupon?.id == coupon.id;
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? AppTheme.primaryColor : Colors.grey,
                ),
                title: Text(coupon.name),
                subtitle: Text(coupon.description),
                trailing: Text(
                  coupon.displayValue,
                  style: const TextStyle(
                    color: AppTheme.priceColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  setState(() => selectedCoupon = isSelected ? null : coupon);
                  Navigator.pop(context);
                },
              );
            }),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildItemList(List<CartItem> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('商品列表', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.product.image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.product.name,
                              maxLines: 2,
                              style: const TextStyle(fontSize: 13)),
                          if (item.sku != null)
                            Text('规格: ${item.sku!.specValue}',
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11)),
                        ],
                      ),
                    ),
                    Text('¥${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFeeSection(
      double subtotal, double freight, double discount, double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildFeeRow('商品小计', '¥${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildFeeRow(
              '运费', freight == 0 ? '免运费' : '¥${freight.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildFeeRow('优惠', '-¥${discount.toStringAsFixed(2)}'),
          const Divider(height: 24),
          _buildFeeRow('合计', '¥${total.toStringAsFixed(2)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildFeeRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppTheme.priceColor : null,
              fontSize: isTotal ? 18 : 14,
            )),
      ],
    );
  }

  Widget _buildSubmitBar({
    required double total,
    required List<CartItem> selectedItems,
    required Address? defaultAddress,
    required double subtotal,
    required double freight,
    required double discount,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('合计:', style: TextStyle(fontSize: 14)),
                  Text('¥${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.priceColor)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (defaultAddress == null) {
                  Get.snackbar('提示', '请先选择收货地址',
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(16));
                  return;
                }
                // v1.3: 创建订单（调用真实 API，回退到本地）
                final orderId = orderController.addOrder(
                  selectedItems,
                  subtotal,
                  freight,
                  discount,
                  defaultAddress,
                );
                // 同步到后端（异步，不阻塞）
                orderController.createOrder(
                  items: selectedItems,
                  subtotal: subtotal,
                  freight: freight,
                  discount: discount,
                  address: defaultAddress.toJson(),
                );
                // 跳转到支付页面
                Get.toNamed(AppRoutes.payment, arguments: {
                  'total': total,
                  'orderId': orderId,
                  'cartItemIds': selectedItems.map((i) => i.id).toList(),
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('提交订单', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // Login guard method
  Widget _buildNotLoggedIn(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('您还未登录',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('请先登录以继续下单',
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
