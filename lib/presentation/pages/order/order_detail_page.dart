import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/order.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/order_controller.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Order order = Get.arguments as Order;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBgColor,
      appBar: AppBar(
        title: const Text('订单详情'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: !Get.find<UserController>().isLoggedIn.value
          ? _buildNotLoggedIn(context)
          : SingleChildScrollView(
              child: Column(
                children: [
                  // 状态头部
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    color: AppTheme.primaryColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.status.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _statusHint(order.status),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  // 收货地址
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: AppTheme.primaryColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${order.address.receiverName}  ${order.address.phone}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                order.address.fullAddress,
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 物流信息
                  if (order.logistics != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${order.logistics!.company} ${order.logistics!.trackingNo}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  order.logistics!.status,
                                  style: const TextStyle(
                                      color: Colors.blue, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          ...order.logistics!.nodes.take(3).map((node) =>
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: AppTheme.primaryColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Container(
                                            width: 1,
                                            height: 24,
                                            color: Colors.grey[300]),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(node.content,
                                              style: const TextStyle(
                                                  fontSize: 13)),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${node.time} ${node.location}',
                                            style: const TextStyle(
                                                color: AppTheme.textSecondary,
                                                fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // 商品列表
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('商品列表',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const Divider(height: 24),
                        ...order.items.map((item) => Padding(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item.product.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                const TextStyle(fontSize: 13)),
                                        if (item.sku != null) ...[
                                          const SizedBox(height: 4),
                                          Text(item.sku!.specValue,
                                              style: const TextStyle(
                                                  color: AppTheme.textSecondary,
                                                  fontSize: 12)),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                          '¥${item.product.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500)),
                                      Text('x${item.quantity}',
                                          style: const TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 订单信息
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('订单信息',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const Divider(height: 24),
                        _infoRow('订单编号', order.orderNo),
                        _infoRow('下单时间', _formatTime(order.createTime)),
                        if (order.payTime != null)
                          _infoRow('支付时间', _formatTime(order.payTime!)),
                        if (order.shipTime != null)
                          _infoRow('发货时间', _formatTime(order.shipTime!)),
                        if (order.receiveTime != null)
                          _infoRow('收货时间', _formatTime(order.receiveTime!)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 金额明细
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('金额明细',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const Divider(height: 24),
                        _infoRow(
                            '商品总额', '¥${order.totalAmount.toStringAsFixed(2)}'),
                        _infoRow('运费', '¥${order.freight.toStringAsFixed(2)}'),
                        _infoRow(
                            '优惠', '-¥${order.discount.toStringAsFixed(2)}'),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('实付款',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              '¥${order.actualAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.priceColor,
                                  fontSize: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 底部操作按钮
                  _buildActionButtons(order),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Order order) {
    final controller = Get.find<OrderController>();
    if (order.status == OrderStatus.paid) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: ElevatedButton.icon(
          onPressed: () {
            controller.remindShipment(order.id);
            Get.snackbar('催发货', '已提醒商家尽快发货',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
                backgroundColor: Colors.orange,
                colorText: Colors.white);
          },
          icon: const Icon(Icons.notifications_active_outlined),
          label: const Text('催发货'),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 14)),
        ),
      );
    }
    if (order.status == OrderStatus.shipped ||
        order.status == OrderStatus.delivering) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: ElevatedButton.icon(
          onPressed: () {
            Get.dialog(
              AlertDialog(
                title: const Text('确认收货'),
                content: const Text('确认已收到商品？确认后订单将标记为已完成。'),
                actions: [
                  TextButton(
                      onPressed: () => Get.back(), child: const Text('取消')),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      controller.updateOrderStatus(
                          order.id, OrderStatus.delivered);
                      Get.snackbar('成功', '已确认收货',
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                          backgroundColor: Colors.green,
                          colorText: Colors.white);
                      Get.offAllNamed(AppRoutes.orderDetail,
                          arguments: controller.orders
                              .firstWhere((o) => o.id == order.id));
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('确认'),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('确认收货'),
          style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              padding: const EdgeInsets.symmetric(vertical: 14)),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  String _formatTime(DateTime time) =>
      '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  String _statusHint(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return '请尽快完成支付';
      case OrderStatus.paid:
        return '支付成功，等待商家发货';
      case OrderStatus.shipped:
        return '商家已发货，等待配送';
      case OrderStatus.delivering:
        return '配送中，请注意查收';
      case OrderStatus.delivered:
        return '已签收，确认收货完成交易';
      case OrderStatus.completed:
        return '交易已完成，感谢购买';
      case OrderStatus.cancelled:
        return '订单已取消';
      case OrderStatus.refunding:
        return '退款处理中';
      case OrderStatus.refunded:
        return '退款已完成';
    }
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('您还未登录',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('登录后可查看订单详情',
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
