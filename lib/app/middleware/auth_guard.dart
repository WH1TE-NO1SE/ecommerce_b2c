import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../../presentation/controllers/user_controller.dart';

/// 认证守卫：检查是否已登录
class AuthGuard extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // 获取 UserController 的方式
    try {
      final userController = Get.find<UserController>();
      if (!userController.isLoggedIn.value) {
        return const RouteSettings(name: AppRoutes.login);
      }
    } catch (_) {
      // Controller 未初始化，重定向到登录
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}

/// 管理员守卫：检查是否为管理员
class AdminGuard extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    try {
      final userController = Get.find<UserController>();
      if (!userController.isLoggedIn.value) {
        return const RouteSettings(name: AppRoutes.login);
      }
      final user = userController.currentUser.value;
      if (user == null || !user.isAdmin) {
        return const RouteSettings(name: AppRoutes.home);
      }
    } catch (_) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}
