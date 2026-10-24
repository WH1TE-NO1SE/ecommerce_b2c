import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/order.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/order_controller.dart';
import '../../widgets/skeleton_widgets.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final OrderController controller = Get.find<OrderController>();

  final List<_OrderTab> _tabs = const [
    _OrderTab(label: '全部', status: null),
    _OrderTab(label: '待支付', status: OrderStatus.pending),
    _OrderTab(label: '待发货', status: OrderStatus.paid),
    _OrderTab(label: '待收货', status: OrderStatus.delivered),
    _OrderTab(label: '已完成', status: OrderStatus.completed),
    _OrderTab(label: '已取消', status: null), // cancelled + refunded
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;

      setState(() {});
    });
    // 初始化时刷新一次
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshOrders();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      controller.refreshOrders();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  List<Order> _getFilteredOrders() {
    final index = _tabController.index;
    final tab = _tabs[index];
    if (tab.status == null) {
      // 特殊处理"已取消"：合并 cancelled + refunded
      if (index == 5) {
        return controller.orders
            .where((o) =>
                o.status == OrderStatus.cancelled ||
                o.status == OrderStatus.refunded)
            .toList();
      }
      return controller.orders;
    }
    return controller.orders.where((o) => o.status == tab.status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBgColor,
      appBar: AppBar(
        title: const Text('我的订单'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 2,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          tabs: _tabs
              .map((t) => Tab(
                    text: t.label,
                  ))
              .toList(),
        ),
      ),
      body: Obx(() {
        // v1.2: 骨架屏加载状态
        if (!Get.find<UserController>().isLoggedIn.value) {
          return _buildNotLoggedIn(context);
        }
        if (controller.isLoading.value) {
          return const SkeletonOrderList(itemCount: 3);
        }
        final orders = _getFilteredOrders();
        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text('暂无订单',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => controller.refreshOrders(),
          color: AppTheme.primaryColor,
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _OrderCard(order: order, controller: controller);
            },
          ),
        );
      }),
    );
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
          const Text('登录后可查看订单',
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

class _OrderTab {
  final String label;
  final OrderStatus? status;

  const _OrderTab({required this.label, required this.status});
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final OrderController controller;

  const _OrderCard({required this.order, required this.controller});

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.paid:
      case OrderStatus.shipped:
        return Colors.blue;
      case OrderStatus.delivering:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
      case OrderStatus.refunding:
      case OrderStatus.refunded:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 订单头部
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.dividerColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '订单号: ${order.orderNo}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status.label,
                    style: TextStyle(
                      color: _statusColor(order.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 商品列表
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
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
                                child: const Icon(Icons.image, size: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                if (item.sku != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    item.sku!.specValue,
                                    style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 11),
                                  ),
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
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'x${item.quantity}',
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
                // 金额行
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '共${order.items.fold(0, (sum, i) => sum + i.quantity)}件商品，实付款 ',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                    Text(
                      '¥${order.actualAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.priceColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 底部操作
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.dividerColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (order.status == OrderStatus.pending)
                  TextButton(
                    onPressed: () {
                      _showCancelDialog(context, order, controller);
                    },
                    child: const Text('取消订单',
                        style: TextStyle(color: AppTheme.textSecondary)),
                  ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () =>
                      Get.toNamed(AppRoutes.orderDetail, arguments: order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  ),
                  child: const Text('查看详情', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(
      BuildContext context, Order order, OrderController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('取消订单'),
        content: const Text('确定要取消该订单吗？取消后无法恢复。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('否')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.updateOrderStatus(order.id, OrderStatus.cancelled);
              Get.snackbar('提示', '订单已取消', snackPosition: SnackPosition.BOTTOM);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('是', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
