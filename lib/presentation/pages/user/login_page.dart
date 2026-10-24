import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../controllers/user_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegisterMode = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isRegisterMode ? '注册账号' : '欢迎登录',
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '电商B2C平台',
                style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 48),

              // 手机号
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: '手机号',
                  hintText: '请输入手机号',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // 密码
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '密码',
                  hintText: '请输入密码（至少6位）',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 32),

              // 登录/注册按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_phoneController.text.isEmpty ||
                        _passwordController.text.isEmpty) {
                      Get.snackbar('提示', '请输入手机号和密码',
                          snackPosition: SnackPosition.BOTTOM);
                      return;
                    }
                    if (_passwordController.text.length < 6) {
                      Get.snackbar('提示', '密码至少6位',
                          snackPosition: SnackPosition.BOTTOM);
                      return;
                    }

                    bool success;
                    if (_isRegisterMode) {
                      success = await controller.register(
                        _phoneController.text,
                        _passwordController.text,
                        phone: _phoneController.text,
                      );
                    } else {
                      success = await controller.login(
                        _phoneController.text,
                        _passwordController.text,
                      );
                    }

                    if (!success) {
                      Get.snackbar(
                        _isRegisterMode ? '注册失败' : '登录失败',
                        _isRegisterMode ? '用户名可能已存在' : '用户名或密码错误',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                      );
                      return;
                    }
                    Get.back();
                    Get.snackbar(
                      _isRegisterMode ? '注册成功' : '登录成功',
                      '欢迎！',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(_isRegisterMode ? '注册' : '登录',
                      style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),

              // 切换登录/注册
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isRegisterMode ? '已有账号？' : '还没有账号？',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  TextButton(
                    onPressed: () =>
                        setState(() => _isRegisterMode = !_isRegisterMode),
                    child: Text(
                      _isRegisterMode ? '去登录' : '立即注册',
                      style: const TextStyle(color: AppTheme.primaryColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
