import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/routes/app_routes.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final selectedMethod = 'wechat'.obs;

  double get total => (Get.arguments?['total'] ?? 0.0) as double;
  String? get orderId => Get.arguments?['orderId'] as String?;
  List<String> get cartItemIds =>
      (Get.arguments?['cartItemIds'] as List?)?.cast<String>() ?? [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('选择支付方式')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 订单金额
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text('支付金额', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text('¥${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.priceColor)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 支付方式
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildPaymentMethod(
                          'wechat', '微信支付', Icons.wechat, selectedMethod),
                      const Divider(height: 1),
                      _buildPaymentMethod('alipay', '支付宝',
                          Icons.account_balance_wallet, selectedMethod),
                      const Divider(height: 1),
                      _buildPaymentMethod(
                          'card', '银行卡', Icons.credit_card, selectedMethod),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 底部确认按钮
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 模拟支付成功，跳转到结果页
                    Get.offNamed(AppRoutes.paymentResult, arguments: {
                      'success': true,
                      'total': total,
                      'orderId': orderId,
                      'cartItemIds': cartItemIds,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('确认支付 ¥${total.toStringAsFixed(2)}',
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(
      String value, String label, IconData icon, RxString selected) {
    return Obx(() => ListTile(
          leading: Icon(icon, color: AppTheme.primaryColor),
          title: Text(label),
          trailing: Radio<String>(
            value: value,
            groupValue: selected.value,
            onChanged: (v) => selected.value = v!,
            activeColor: AppTheme.primaryColor,
          ),
          onTap: () => selected.value = value,
        ));
  }
}
