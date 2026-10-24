import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/order.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/address_controller.dart';

class AddressListPage extends StatelessWidget {
  /// 如果是从下单页进入，则为选择模式
  final bool isSelectMode;

  const AddressListPage({super.key, this.isSelectMode = false});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddressController());

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBgColor,
      appBar: AppBar(
        title: Text(isSelectMode ? '选择收货地址' : '收货地址'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (!Get.find<UserController>().isLoggedIn.value) {
          return _buildNotLoggedIn(context);
        }
        if (controller.addresses.isEmpty) {
          return _buildEmptyState(controller);
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.addresses.length,
          itemBuilder: (context, index) {
            final address = controller.addresses[index];
            return _buildAddressCard(address, controller, context);
          },
        );
      }),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.addressEdit),
            icon: const Icon(Icons.add),
            label: const Text('新建地址', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AddressController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('暂无收货地址',
              style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.addressEdit),
            icon: const Icon(Icons.add),
            label: const Text('添加地址'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(
      Address address, AddressController controller, BuildContext context) {
    return GestureDetector(
      onTap: isSelectMode
          ? () {
              controller.selectAddress(address);
              Get.back(result: address);
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: address.isDefault
              ? Border.all(color: AppTheme.primaryColor, width: 1.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  address.receiverName,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Text(
                  _formatPhone(address.phone),
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const Spacer(),
                if (address.isDefault)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '默认',
                      style:
                          TextStyle(color: AppTheme.primaryColor, fontSize: 11),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              address.fullAddress,
              style: const TextStyle(fontSize: 14, height: 1.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(height: 24),
            Row(
              children: [
                // 设为默认
                GestureDetector(
                  onTap: address.isDefault
                      ? null
                      : () => controller.setDefault(address.id),
                  child: Row(
                    children: [
                      Icon(
                        address.isDefault
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: address.isDefault
                            ? AppTheme.primaryColor
                            : Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '设为默认',
                        style: TextStyle(
                          fontSize: 13,
                          color: address.isDefault
                              ? AppTheme.primaryColor
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // 编辑
                GestureDetector(
                  onTap: () =>
                      Get.toNamed(AppRoutes.addressEdit, arguments: address),
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text('编辑',
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[600])),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // 删除
                GestureDetector(
                  onTap: () => _showDeleteConfirm(context, address, controller),
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline,
                          size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text('删除',
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPhone(String phone) {
    if (phone.length >= 11) {
      return '${phone.substring(0, 3)}****${phone.substring(7)}';
    }
    return phone;
  }

  void _showDeleteConfirm(
      BuildContext context, Address address, AddressController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除地址'),
        content: const Text('确定要删除该收货地址吗？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteAddress(address.id);
              Get.snackbar('提示', '地址已删除', snackPosition: SnackPosition.BOTTOM);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('您还未登录',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('登录后可管理收货地址',
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
