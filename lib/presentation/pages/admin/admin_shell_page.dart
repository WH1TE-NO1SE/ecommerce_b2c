import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../../app/theme/app_theme.dart';

/// 管理后台主页面 — 响应式布局（Web侧边栏 / 手机TabBar）
class AdminShellPage extends StatelessWidget {
  const AdminShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AdminController());
    final isWide = MediaQuery.of(context).size.width > 800;

    return isWide ? _WideLayout(ctrl: ctrl) : _NarrowLayout(ctrl: ctrl);
  }
}

// ==================== Web/大屏：侧边栏 + 内容区 ====================
class _WideLayout extends StatefulWidget {
  final AdminController ctrl;
  const _WideLayout({required this.ctrl});

  @override
  State<_WideLayout> createState() => _WideLayoutState();
}

class _WideLayoutState extends State<_WideLayout> {
  int _selectedIndex = 0;

  final _tabs = const [
    {'icon': Icons.dashboard, 'label': '数据中心'},
    {'icon': Icons.inventory_2, 'label': '商品管理'},
    {'icon': Icons.receipt_long, 'label': '订单管理'},
    {'icon': Icons.people, 'label': '用户管理'},
    {'icon': Icons.card_giftcard, 'label': '优惠券'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBgColor,
      body: Row(
        children: [
          // 侧边栏
          Container(
            width: 200,
            color: const Color(0xFF1A1A2E),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text('管理后台',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                ...List.generate(_tabs.length, (i) {
                  final tab = _tabs[i];
                  final selected = i == _selectedIndex;
                  return ListTile(
                    leading: Icon(tab['icon'] as IconData,
                        color:
                            selected ? AppTheme.primaryColor : Colors.white54),
                    title: Text(tab['label'] as String,
                        style: TextStyle(
                            color: selected ? Colors.white : Colors.white54,
                            fontSize: 14)),
                    selected: selected,
                    selectedTileColor: Colors.white.withOpacity(0.1),
                    onTap: () {
                      setState(() => _selectedIndex = i);
                      _loadTabData(i);
                    },
                  );
                }),
                const Spacer(),
                ListTile(
                  leading: const Icon(Icons.arrow_back, color: Colors.white54),
                  title: const Text('返回前台',
                      style: TextStyle(color: Colors.white54, fontSize: 14)),
                  onTap: () => Get.back(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // 内容区
          Expanded(child: _buildContent(_selectedIndex)),
        ],
      ),
    );
  }

  void _loadTabData(int index) {
    switch (index) {
      case 0:
        widget.ctrl.loadDashboard();
        break;
      case 1:
        widget.ctrl.loadProducts();
        break;
      case 2:
        widget.ctrl.loadOrders();
        break;
      case 3:
        widget.ctrl.loadUsers();
        break;
      case 4:
        widget.ctrl.loadCoupons();
        break;
    }
  }

  Widget _buildContent(int index) {
    switch (index) {
      case 0:
        return DashboardTab(ctrl: widget.ctrl);
      case 1:
        return ProductsTab(ctrl: widget.ctrl);
      case 2:
        return OrdersTab(ctrl: widget.ctrl);
      case 3:
        return UsersTab(ctrl: widget.ctrl);
      case 4:
        return CouponsTab(ctrl: widget.ctrl);
      default:
        return const SizedBox();
    }
  }
}

// ==================== 手机/小屏：顶部TabBar ====================
class _NarrowLayout extends StatefulWidget {
  final AdminController ctrl;
  const _NarrowLayout({required this.ctrl});

  @override
  State<_NarrowLayout> createState() => _NarrowLayoutState();
}

class _NarrowLayoutState extends State<_NarrowLayout>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('管理后台'),
        leading: BackButton(onPressed: () => Get.back()),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: '数据'),
            Tab(icon: Icon(Icons.inventory_2), text: '商品'),
            Tab(icon: Icon(Icons.receipt_long), text: '订单'),
            Tab(icon: Icon(Icons.people), text: '用户'),
            Tab(icon: Icon(Icons.card_giftcard), text: '优惠券'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DashboardTab(ctrl: widget.ctrl),
          ProductsTab(ctrl: widget.ctrl),
          OrdersTab(ctrl: widget.ctrl),
          UsersTab(ctrl: widget.ctrl),
          CouponsTab(ctrl: widget.ctrl),
        ],
      ),
    );
  }
}

// ==================== Tab 1: 数据中心 ====================
class DashboardTab extends StatelessWidget {
  final AdminController ctrl;
  const DashboardTab({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final d = ctrl.dashboard;
      return RefreshIndicator(
        onRefresh: ctrl.loadDashboard,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 统计卡片
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatCard(
                    title: '商品总数',
                    value: '${d['totalProducts'] ?? 0}',
                    icon: Icons.inventory_2,
                    color: Colors.blue),
                _StatCard(
                    title: '订单总数',
                    value: '${d['totalOrders'] ?? 0}',
                    icon: Icons.receipt_long,
                    color: Colors.green),
                _StatCard(
                    title: '总销售额',
                    value: '¥${(d['totalSales'] ?? 0).toStringAsFixed(0)}',
                    icon: Icons.attach_money,
                    color: Colors.orange),
                _StatCard(
                    title: '待处理',
                    value: '${d['pendingOrders'] ?? 0}',
                    icon: Icons.pending_actions,
                    color: Colors.red),
                _StatCard(
                    title: '用户数',
                    value: '${d['totalUsers'] ?? 0}',
                    icon: Icons.people,
                    color: Colors.purple),
              ],
            ),
            const SizedBox(height: 24),
            // 热销TOP10
            const Text('🔥 热销商品 TOP10',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...ctrl.topProducts.asMap().entries.map((e) {
              final p = e.value;
              return ListTile(
                leading: CircleAvatar(child: Text('${e.key + 1}')),
                title: Text(p['name'] ?? ''),
                subtitle: Text('¥${p['price']}'),
                trailing: Text('已售${p['sales']}',
                    style: const TextStyle(color: AppTheme.priceColor)),
              );
            }),
          ],
        ),
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 24)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ]),
      ]),
    );
  }
}

// ==================== Tab 2: 商品管理 ====================
class ProductsTab extends StatefulWidget {
  final AdminController ctrl;
  const ProductsTab({super.key, required this.ctrl});

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  @override
  void initState() {
    super.initState();
    widget.ctrl.loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(children: [
        // 搜索栏
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(
                child: TextField(
              decoration: const InputDecoration(
                  hintText: '搜索商品...',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder()),
              onSubmitted: (v) {
                widget.ctrl.productKeyword.value = v;
                widget.ctrl.loadProducts();
              },
            )),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: widget.ctrl.productStatusFilter.value.isEmpty
                  ? null
                  : widget.ctrl.productStatusFilter.value,
              hint: const Text('状态'),
              items: const [
                DropdownMenuItem(value: '', child: Text('全部')),
                DropdownMenuItem(value: 'active', child: Text('上架')),
                DropdownMenuItem(value: 'inactive', child: Text('下架')),
              ],
              onChanged: (v) {
                widget.ctrl.productStatusFilter.value = v ?? '';
                widget.ctrl.loadProducts();
              },
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _showProductDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('添加'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white),
            ),
          ]),
        ),
        // 商品列表
        Expanded(
          child: widget.ctrl.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : widget.ctrl.products.isEmpty
                  ? const Center(child: Text('暂无商品'))
                  : ListView.builder(
                      itemCount: widget.ctrl.products.length,
                      itemBuilder: (ctx, i) =>
                          _buildProductCard(widget.ctrl.products[i]),
                    ),
        ),
      ]);
    });
  }

  Widget _buildProductCard(Map<String, dynamic> p) {
    final isActive = p['isActive'] == true;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(p['image'] ?? '',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image))),
        ),
        title:
            Text(p['name'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('¥${p['price']}  库存:${p['stock']}  销量:${p['sales']}'),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          // 上下架
          Switch(
            value: isActive,
            onChanged: (v) => widget.ctrl.toggleProductStatus(p['id'], v),
            activeColor: AppTheme.primaryColor,
          ),
          IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _showProductDialog(context, product: p)),
          IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _confirmDelete(p['id'])),
        ]),
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('确认删除'),
              content: const Text('删除后无法恢复，确定要删除这件商品吗？'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('取消')),
                TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      widget.ctrl.deleteProduct(id);
                    },
                    child:
                        const Text('删除', style: TextStyle(color: Colors.red))),
              ],
            ));
  }

  void _showProductDialog(BuildContext context,
      {Map<String, dynamic>? product}) {
    final nameCtrl = TextEditingController(text: product?['name'] ?? '');
    final descCtrl = TextEditingController(text: product?['description'] ?? '');
    final priceCtrl = TextEditingController(text: '${product?['price'] ?? ''}');
    final stockCtrl =
        TextEditingController(text: '${product?['stock'] ?? 100}');
    final imageCtrl = TextEditingController(text: product?['image'] ?? '');
    final tagsCtrl = TextEditingController(text: product?['tags'] ?? '');

    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text(product == null ? '添加商品' : '编辑商品'),
              content: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: '商品名称')),
                  TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(labelText: '描述'),
                      maxLines: 2),
                  TextField(
                      controller: priceCtrl,
                      decoration: const InputDecoration(labelText: '价格'),
                      keyboardType: TextInputType.number),
                  TextField(
                      controller: stockCtrl,
                      decoration: const InputDecoration(labelText: '库存'),
                      keyboardType: TextInputType.number),
                  TextField(
                      controller: imageCtrl,
                      decoration: const InputDecoration(labelText: '图片URL')),
                  TextField(
                      controller: tagsCtrl,
                      decoration: const InputDecoration(labelText: '标签(逗号分隔)')),
                ]),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('取消')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      final data = {
                        'name': nameCtrl.text,
                        'description': descCtrl.text,
                        'price': double.tryParse(priceCtrl.text) ?? 0,
                        'stock': int.tryParse(stockCtrl.text) ?? 0,
                        'image': imageCtrl.text,
                        'tags': tagsCtrl.text,
                      };
                      if (product == null) {
                        widget.ctrl.addProduct(data);
                      } else {
                        widget.ctrl.updateProduct(product['id'], data);
                      }
                    },
                    child: const Text('保存')),
              ],
            ));
  }
}

// ==================== Tab 3: 订单管理 ====================
class OrdersTab extends StatefulWidget {
  final AdminController ctrl;
  const OrdersTab({super.key, required this.ctrl});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  @override
  void initState() {
    super.initState();
    widget.ctrl.loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(children: [
        // 状态筛选
        Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _filterChip('全部', ''),
              _filterChip('待支付', 'pending'),
              _filterChip('已支付', 'paid'),
              _filterChip('已发货', 'shipped'),
              _filterChip('已完成', 'completed'),
              _filterChip('已取消', 'cancelled'),
            ]),
          ),
        ),
        // 订单列表
        Expanded(
          child: widget.ctrl.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : widget.ctrl.orders.isEmpty
                  ? const Center(child: Text('暂无订单'))
                  : ListView.builder(
                      itemCount: widget.ctrl.orders.length,
                      itemBuilder: (ctx, i) =>
                          _buildOrderCard(widget.ctrl.orders[i]),
                    ),
        ),
      ]);
    });
  }

  Widget _filterChip(String label, String status) {
    final selected = widget.ctrl.orderStatusFilter.value == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          widget.ctrl.orderStatusFilter.value = status;
          widget.ctrl.loadOrders();
        },
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> o) {
    final statusColors = {
      'pending': Colors.grey,
      'paid': Colors.orange,
      'shipped': Colors.blue,
      'completed': Colors.green,
      'cancelled': Colors.red
    };
    final statusLabels = {
      'pending': '待支付',
      'paid': '已支付',
      'shipped': '已发货',
      'completed': '已完成',
      'cancelled': '已取消'
    };
    final status = o['status'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('订单号: ${o['orderNo']}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color:
                      (statusColors[status] ?? Colors.grey).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12)),
              child: Text(statusLabels[status] ?? status,
                  style: TextStyle(
                      color: statusColors[status] ?? Colors.grey,
                      fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 8),
          ...(o['items'] as List? ?? []).map((item) {
            final product = item['product'] ?? {};
            return Text('${product['name'] ?? ''} x${item['quantity']}',
                style: const TextStyle(fontSize: 13));
          }),
          const SizedBox(height: 8),
          Row(children: [
            Text('¥${(o['actualAmount'] ?? 0).toStringAsFixed(2)}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppTheme.priceColor)),
            const Spacer(),
            if (status == 'paid')
              ElevatedButton(
                onPressed: () => widget.ctrl.shipOrder(o['id']),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8)),
                child: const Text('发货'),
              ),
          ]),
        ]),
      ),
    );
  }
}

// ==================== Tab 4: 用户管理 ====================
class UsersTab extends StatefulWidget {
  final AdminController ctrl;
  const UsersTab({super.key, required this.ctrl});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  @override
  void initState() {
    super.initState();
    widget.ctrl.loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
                hintText: '搜索用户名/手机号...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder()),
            onSubmitted: (v) {
              widget.ctrl.userKeyword.value = v;
              widget.ctrl.loadUsers();
            },
          ),
        ),
        Expanded(
          child: widget.ctrl.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: widget.ctrl.users.length,
                  itemBuilder: (ctx, i) {
                    final u = widget.ctrl.users[i];
                    final isAdmin = u['role'] == 'admin';
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              isAdmin ? AppTheme.primaryColor : Colors.grey,
                          child: Icon(
                              isAdmin
                                  ? Icons.admin_panel_settings
                                  : Icons.person,
                              color: Colors.white),
                        ),
                        title: Text(u['username'] ?? ''),
                        subtitle: Text(
                            '手机: ${u['phone'] ?? '-'}  积分: ${u['points'] ?? 0}'),
                        trailing: DropdownButton<String>(
                          value: u['role'] ?? 'user',
                          items: const [
                            DropdownMenuItem(
                                value: 'user', child: Text('普通用户')),
                            DropdownMenuItem(
                                value: 'admin', child: Text('管理员')),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              widget.ctrl.updateUserRole(u['id'], v);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ]);
    });
  }
}

// ==================== Tab 5: 优惠券管理 ====================
class CouponsTab extends StatefulWidget {
  final AdminController ctrl;
  const CouponsTab({super.key, required this.ctrl});

  @override
  State<CouponsTab> createState() => _CouponsTabState();
}

class _CouponsTabState extends State<CouponsTab> {
  @override
  void initState() {
    super.initState();
    widget.ctrl.loadCoupons();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCouponDialog(context),
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: widget.ctrl.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : widget.ctrl.coupons.isEmpty
                ? const Center(child: Text('暂无优惠券'))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: widget.ctrl.coupons.length,
                    itemBuilder: (ctx, i) {
                      final c = widget.ctrl.coupons[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(c['type'] == 'fixed' ? '满减' : '折扣',
                                style: const TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ),
                          title: Text(c['name'] ?? ''),
                          subtitle: Text(
                              '${c['description'] ?? ''}\n有效期: ${c['startTime']?.substring(0, 10) ?? ''} ~ ${c['endTime']?.substring(0, 10) ?? ''}'),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => widget.ctrl.deleteCoupon(c['id']),
                          ),
                        ),
                      );
                    },
                  ),
      );
    });
  }

  void _showCouponDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final thresholdCtrl = TextEditingController(text: '0');
    final discountCtrl = TextEditingController();
    String type = 'fixed';

    showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) {
              return AlertDialog(
                title: const Text('创建优惠券'),
                content: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: '名称')),
                    TextField(
                        controller: descCtrl,
                        decoration: const InputDecoration(labelText: '描述')),
                    Row(children: [
                      Expanded(
                          child: InputDecorator(
                        decoration: const InputDecoration(labelText: '类型'),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: type,
                            isDense: true,
                            items: const [
                              DropdownMenuItem(
                                  value: 'fixed', child: Text('满减')),
                              DropdownMenuItem(
                                  value: 'percent', child: Text('折扣')),
                            ],
                            onChanged: (v) =>
                                setDialogState(() => type = v ?? 'fixed'),
                          ),
                        ),
                      )),
                      const SizedBox(width: 12),
                      Expanded(
                          child: TextField(
                              controller: thresholdCtrl,
                              decoration:
                                  const InputDecoration(labelText: '门槛金额'),
                              keyboardType: TextInputType.number)),
                    ]),
                    TextField(
                        controller: discountCtrl,
                        decoration: InputDecoration(
                            labelText: type == 'fixed' ? '减免金额' : '折扣(%)'),
                        keyboardType: TextInputType.number),
                  ]),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('取消')),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        final now = DateTime.now();
                        widget.ctrl.addCoupon({
                          'name': nameCtrl.text,
                          'description': descCtrl.text,
                          'type': type,
                          'threshold': double.tryParse(thresholdCtrl.text) ?? 0,
                          'discount': double.tryParse(discountCtrl.text) ?? 0,
                          'startTime': now.toIso8601String(),
                          'endTime': now
                              .add(const Duration(days: 90))
                              .toIso8601String(),
                        });
                      },
                      child: const Text('创建')),
                ],
              );
            }));
  }
}
