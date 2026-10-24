import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/order.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/address_controller.dart';

class AddressEditPage extends StatefulWidget {
  const AddressEditPage({super.key});

  @override
  State<AddressEditPage> createState() => _AddressEditPageState();
}

class _AddressEditPageState extends State<AddressEditPage> {
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
          const Text('登录后可编辑收货地址',
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

  final AddressController controller = Get.find<AddressController>();
  final _formKey = GlobalKey<FormState>();

  late bool _isEdit;
  late String _addressId;
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _provinceCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _districtCtrl;
  late TextEditingController _detailCtrl;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Address?;
    _isEdit = args != null;
    _addressId = args?.id ?? 'addr_${DateTime.now().millisecondsSinceEpoch}';
    _nameCtrl = TextEditingController(text: args?.receiverName ?? '');
    _phoneCtrl = TextEditingController(text: args?.phone ?? '');
    _provinceCtrl = TextEditingController(text: args?.province ?? '');
    _cityCtrl = TextEditingController(text: args?.city ?? '');
    _districtCtrl = TextEditingController(text: args?.district ?? '');
    _detailCtrl = TextEditingController(text: args?.detail ?? '');
    _isDefault = args?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _provinceCtrl.dispose();
    _cityCtrl.dispose();
    _districtCtrl.dispose();
    _detailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.find<UserController>().isLoggedIn.value) {
      return _buildNotLoggedIn(context);
    }
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBgColor,
      appBar: AppBar(title: Text(_isEdit ? '编辑地址' : '新建地址'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('联系人信息'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _nameCtrl,
              label: '收货人',
              hint: '请输入收货人姓名',
              icon: Icons.person_outline,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? '请输入收货人姓名' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _phoneCtrl,
              label: '手机号',
              hint: '请输入11位手机号',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              maxLength: 11,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return '请输入手机号';
                if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(v.trim())) {
                  return '请输入正确的手机号';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('收货地址'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _provinceCtrl,
                    label: '省份',
                    hint: '如：山东省',
                    icon: Icons.location_city_outlined,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? '请输入省份' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _cityCtrl,
                    label: '城市',
                    hint: '如：济南市',
                    icon: Icons.location_city_outlined,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? '请输入城市' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _districtCtrl,
              label: '区县',
              hint: '如：历下区',
              icon: Icons.map_outlined,
              validator: (v) => v == null || v.trim().isEmpty ? '请输入区县' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _detailCtrl,
              label: '详细地址',
              hint: '街道、楼号、门牌号等',
              icon: Icons.home_outlined,
              maxLines: 2,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return '请输入详细地址';
                if (v.trim().length < 5) return '详细地址至少5个字';
                return null;
              },
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_outline, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('设为默认地址', style: TextStyle(fontSize: 15)),
                  ),
                  Switch(
                    value: _isDefault,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (v) => setState(() => _isDefault = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
            ],
          ),
          child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
            ),
            child: Text(_isEdit ? '保存修改' : '保存地址',
                style: const TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondary),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          icon: Icon(icon, color: AppTheme.primaryColor, size: 20),
          labelText: label,
          hintText: hint,
          border: InputBorder.none,
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final address = Address(
      id: _addressId,
      receiverName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      province: _provinceCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      district: _districtCtrl.text.trim(),
      detail: _detailCtrl.text.trim(),
      isDefault: _isDefault,
    );

    if (_isEdit) {
      controller.updateAddress(address);
      Get.snackbar('成功', '地址已更新', snackPosition: SnackPosition.BOTTOM);
    } else {
      controller.addAddress(address);
      Get.snackbar('成功', '地址已添加', snackPosition: SnackPosition.BOTTOM);
      // 新建地址后自动选中新地址并返回（用于下单选择地址场景）
      Get.back(result: address);
      return;
    }
    Get.back();
  }
}
