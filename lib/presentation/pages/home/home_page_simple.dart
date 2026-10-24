import '../../../core/exceptions/stock_exception.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/product.dart';
import '../../controllers/home_controller_simple.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/user_controller.dart';
import '../../widgets/product_card.dart';
import '../../widgets/banner_carousel.dart';
import '../../widgets/skeleton_widgets.dart';
import '../../widgets/search_bar_widget.dart';
import '../cart/cart_page.dart';
import '../order/order_list_page.dart';
import '../user/user_center_page.dart';

class HomePageSimple extends StatefulWidget {
  const HomePageSimple({super.key});

  @override
  State<HomePageSimple> createState() => _HomePageSimpleState();
}

class _HomePageSimpleState extends State<HomePageSimple>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _drawerAnimController;
  late Animation<Offset> _drawerSlideAnimation;
  late Animation<double> _coverOpacityAnimation;

  // v1.3: Tab 懒加载 — 仅首次访问时构建，之后缓存
  final Map<int, Widget> _tabCache = {};

  @override
  void initState() {
    super.initState();
    // v1.1 修复：通过 lazyPut 避免重复注册，确保生命周期由 GetX 管理
    Get.lazyPut(() => HomeControllerSimple());
    Get.lazyPut(() => CartController());
    Get.lazyPut(() => OrderController());
    Get.lazyPut(() => UserController());

    _drawerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _drawerSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _drawerAnimController,
      curve: Curves.easeOut,
    ));
    _coverOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _drawerAnimController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _drawerAnimController.dispose();
    super.dispose();
  }

  void _openDrawer() {
    _drawerAnimController.forward();
  }

  void _closeDrawer() {
    _drawerAnimController.reverse();
  }

  void _onBottomNavTap(int index) {
    // index 0=首页 1=购物车 2=订单 3=我的（删除了分类tab，侧栏功能保留在左侧图标栏）
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeControllerSimple>();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBgColor,
      body: Stack(
        children: [
          // 主体内容
          Row(
            children: [
              // 左侧分类栏（始终可见）
              _CategorySidebar(
                controller: homeController,
                onCategoryTap: (categoryId) {
                  final index = homeController.categories
                      .indexWhere((c) => c.id == categoryId);
                  if (index >= 0) homeController.selectCategory(index + 1);
                  setState(() => _currentIndex = 0);
                },
                onMenuTap: _openDrawer,
              ),

              // 主内容区（4个页面 — 懒加载）
              Expanded(
                child: _buildTab(_currentIndex),
              ),
            ],
          ),

          // 分类侧栏抽屉（遮罩 + 滑动）
          _buildDrawerOverlay(context, homeController),
        ],
      ),
      // 侧栏分类图标已满足分类需求，不再需要独立的分类tab
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '首页'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined), label: '购物车'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined), label: '订单'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: '我的'),
        ],
      ),
    );
  }

  Widget _buildTab(int index) {
    return _tabCache.putIfAbsent(index, () {
      switch (index) {
        case 0:
          return _HomeContent(onOpenDrawer: _openDrawer);
        case 1:
          return const CartPage();
        case 2:
          return const OrderListPage();
        case 3:
          return const UserCenterPage();
        default:
          return const SizedBox.shrink();
      }
    });
  }

  Widget _buildDrawerOverlay(
      BuildContext context, HomeControllerSimple controller) {
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth * 0.75;

    return AnimatedBuilder(
      animation: _drawerAnimController,
      builder: (context, child) {
        if (_drawerAnimController.isDismissed) return const SizedBox.shrink();

        return Stack(
          children: [
            // 遮罩
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeDrawer,
                child: Container(
                    color: Colors.black
                        .withOpacity(0.4 * _coverOpacityAnimation.value)),
              ),
            ),
            // 抽屉主体
            Positioned(
              left: 50 + (drawerWidth * _drawerSlideAnimation.value.dx),
              top: 0,
              bottom: 0,
              width: drawerWidth,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    // 抽屉头部
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: const Border(
                            bottom: BorderSide(color: AppTheme.dividerColor)),
                      ),
                      child: Row(
                        children: [
                          const Text('商品分类',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: _closeDrawer),
                        ],
                      ),
                    ),
                    // 分类列表
                    Expanded(
                      child: Obx(() => ListView(
                            padding: const EdgeInsets.all(8),
                            children: controller.categories.map((cat) {
                              return _DrawerCategoryItem(
                                emoji: cat.icon,
                                name: cat.name,
                                children: const [],
                                onTap: () {
                                  final index = controller.categories
                                      .indexWhere((c) => c.id == cat.id);
                                  if (index >= 0) {
                                    controller.selectCategory(index + 1);
                                  }
                                  _closeDrawer();
                                },
                              );
                            }).toList(),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CategorySidebar extends StatelessWidget {
  final HomeControllerSimple controller;
  final Function(String categoryId) onCategoryTap;
  final VoidCallback onMenuTap;

  const _CategorySidebar({
    required this.controller,
    required this.onCategoryTap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // 顶部菜单图标（打开抽屉）
          GestureDetector(
            onTap: onMenuTap,
            child: const Icon(Icons.menu, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          // 分类图标列表（动态从controller读取，撑满整列）
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    final cat = controller.categories[index];
                    return _CategoryIconItem(
                      emoji: cat.icon,
                      label: cat.name,
                      onTap: () => onCategoryTap(cat.id),
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }
}

class _CategoryIconItem extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _CategoryIconItem(
      {required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 9),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _DrawerCategoryItem extends StatefulWidget {
  final String emoji;
  final String name;
  final List<Widget> children;
  final VoidCallback onTap;

  const _DrawerCategoryItem({
    required this.emoji,
    required this.name,
    required this.children,
    required this.onTap,
  });

  @override
  State<_DrawerCategoryItem> createState() => _DrawerCategoryItemState();
}

class _DrawerCategoryItemState extends State<_DrawerCategoryItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Text(widget.emoji, style: const TextStyle(fontSize: 24)),
          title: Text(widget.name,
              style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: widget.children.isEmpty
              ? null
              : Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
          onTap: () {
            if (widget.children.isEmpty) {
              widget.onTap();
            } else {
              setState(() => _isExpanded = !_isExpanded);
            }
          },
        ),
        if (_isExpanded && widget.children.isNotEmpty)
          Container(
              color: Colors.grey[50], child: Column(children: widget.children)),
      ],
    );
  }
}

/// 首页内容
class _HomeContent extends StatelessWidget {
  final VoidCallback onOpenDrawer;

  const _HomeContent({required this.onOpenDrawer});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeControllerSimple>();
    final cartController = Get.find<CartController>();

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // 顶部栏
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onOpenDrawer,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('B2C',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SearchBarWidget(
                    onSearch: controller.search,
                    onClear: controller.clearSearch,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.cart),
                  child: Stack(
                    children: [
                      const Icon(Icons.shopping_cart_outlined,
                          color: AppTheme.textPrimary, size: 26),
                      Obx(() {
                        final count = cartController.items.length;
                        if (count == 0) return const SizedBox.shrink();
                        return Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                                color: AppTheme.priceColor,
                                shape: BoxShape.circle),
                            child: Text(count > 99 ? '99+' : '$count',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10)),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Banner 轮播（v1.1 新增）
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: BannerCarousel(
              height: 180,
              items: [
                BannerItem(
                  imageUrl:
                      'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800&h=400&fit=crop',
                  label: '🎉 618年中大促 全场满减',
                ),
                BannerItem(
                  imageUrl:
                      'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&h=400&fit=crop',
                  label: '📱 数码新品季 限时折扣',
                ),
                BannerItem(
                  imageUrl:
                      'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=400&fit=crop',
                  label: '👗 夏日穿搭 新品上架',
                ),
                BannerItem(
                  imageUrl:
                      'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&h=400&fit=crop',
                  label: '🍎 生鲜直供 产地直发',
                ),
              ],
              onTap: (item) {
                Get.snackbar('Banner', '点击了: ${item.label}',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 1));
              },
            ),
          ),
          // 商品列表
          Expanded(
            child: Obx(() {
              // v1.2: 骨架屏加载状态
              if (controller.isLoading.value) {
                return const SkeletonProductGrid(itemCount: 6);
              }
              final products = controller.displayProducts;
              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off,
                          size: 64, color: AppTheme.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        controller.isSearching.value ? '未找到相关商品' : '暂无商品',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: controller.refresh,
                color: AppTheme.primaryColor,
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () => Get.toNamed(AppRoutes.productDetail,
                          arguments: product),
                      onAddToCart: () {
                        if (!Get.find<UserController>().isLoggedIn.value) {
                          Get.toNamed(AppRoutes.login);
                          return;
                        }
                        try {
                          cartController.addToCart(product, null, 1);
                          Get.snackbar('已加入购物车', product.name,
                              snackPosition: SnackPosition.BOTTOM,
                              margin: const EdgeInsets.all(16),
                              duration: const Duration(seconds: 1));
                        } on StockException catch (e) {
                          Get.snackbar('库存不足', e.message,
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.orange,
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(16));
                        }
                      },
                      onBuyNow: () {
                        if (!Get.find<UserController>().isLoggedIn.value) {
                          Get.toNamed(AppRoutes.login);
                          return;
                        }
                        if (product.skus.isNotEmpty) {
                          _showSkuSheet(context, product, cartController);
                        } else {
                          // v1.3 修复：用 try-catch 包裹，只传当前商品到结算
                          try {
                            cartController.addToCart(product, null, 1);
                            final newItem = cartController.items.lastWhere(
                              (i) => i.product.id == product.id,
                            );
                            Get.toNamed(AppRoutes.orderConfirm, arguments: {
                              'items': [newItem],
                            });
                          } on StockException catch (e) {
                            Get.snackbar('库存不足', e.message,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.orange,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16));
                          }
                        }
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// v1.1 新增：规格选择底部 Sheet，用于「立即购买」流程
  void _showSkuSheet(
      BuildContext context, Product product, CartController cartController) {
    ProductSku? selectedSku;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 商品信息头部
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.image,
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          Text(
                            '¥${(selectedSku?.price ?? product.price).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.priceColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                // 规格选择
                const Text('选择规格',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: product.skus.map((sku) {
                    final isSelected = selectedSku?.id == sku.id;
                    return GestureDetector(
                      onTap: () => setState(() => selectedSku = sku),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.grey[100],
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
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // 确认按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!Get.find<UserController>().isLoggedIn.value) {
                        Navigator.pop(context);
                        Get.toNamed(AppRoutes.login);
                        return;
                      }
                      if (product.skus.isNotEmpty && selectedSku == null) {
                        Get.snackbar('提示', '请选择规格',
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16));
                        return;
                      }
                      Navigator.pop(context);
                      try {
                        cartController.addToCart(product, selectedSku, 1);
                        // 只传刚加入的这一件商品，不混入购物车中其他已选商品
                        final newItem = cartController.items.lastWhere(
                          (i) =>
                              i.product.id == product.id &&
                              i.sku?.id == selectedSku?.id,
                        );
                        Get.toNamed(AppRoutes.orderConfirm, arguments: {
                          'items': [newItem],
                        });
                      } on StockException catch (e) {
                        Get.snackbar('库存不足', e.message,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(16));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('立即购买',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
