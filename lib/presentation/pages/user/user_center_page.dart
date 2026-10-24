import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/user.dart';
import '../../controllers/user_controller.dart';

class UserCenterPage extends StatelessWidget {
  const UserCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBgColor,
      body: Obx(() {
        final user = controller.currentUser.value;
        if (user == null) {
          return _buildNotLoggedIn();
        }
        return _buildUserCenter(user, controller);
      }),
    );
  }

  Widget _buildNotLoggedIn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('未登录',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.toNamed(AppRoutes.login),
            child: const Text('去登录'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCenter(User user, UserController controller) {
    return CustomScrollView(
      slivers: [
        // 用户信息头部
        SliverToBoxAdapter(
          child: Container(
            color: AppTheme.primaryColor,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: user.avatar.isNotEmpty
                      ? ClipOval(
                          child: Image.network(user.avatar, fit: BoxFit.cover))
                      : const Icon(Icons.person,
                          size: 36, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.phone,
                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 功能菜单
        SliverList(
          delegate: SliverChildListDelegate([
            const SizedBox(height: 16),
            _buildMenuCard([
              _MenuItem(
                icon: Icons.receipt_long_outlined,
                title: '我的订单',
                onTap: () => Get.toNamed(AppRoutes.orderList),
              ),
              _MenuItem(
                icon: Icons.location_on_outlined,
                title: '收货地址',
                onTap: () => Get.toNamed(AppRoutes.addressList),
              ),
              _MenuItem(
                icon: Icons.local_offer_outlined,
                title: '优惠券',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 16),
            _buildMenuCard([
              _MenuItem(
                icon: Icons.settings_outlined,
                title: '设置',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.help_outline,
                title: '帮助与反馈',
                onTap: () {},
              ),
            ]),

            // v1.1 新增：管理员入口（仅管理员可见）
            if (user.isAdmin) ...[
              const SizedBox(height: 16),
              _buildMenuCard([
                _MenuItem(
                  icon: Icons.admin_panel_settings,
                  title: '管理员后台',
                  iconColor: Colors.orange,
                  onTap: () => Get.toNamed(AppRoutes.adminHome),
                ),
              ]),
            ],

            const SizedBox(height: 16),
            // v1.1: 退出登录
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(controller),
                icon: const Icon(Icons.logout),
                label: const Text('退出登录'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ]),
        ),
      ],
    );
  }

  Widget _buildMenuCard(List<_MenuItem> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final item = entry.value;
          final isLast = entry.key == items.length - 1;
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon,
                    color: item.iconColor ?? AppTheme.primaryColor),
                title: Text(item.title),
                trailing: const Icon(Icons.chevron_right),
                onTap: item.onTap,
              ),
              if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showLogoutDialog(UserController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('确认退出？'),
        content: const Text('退出后将清除登录状态'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await controller.logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
  });
}
