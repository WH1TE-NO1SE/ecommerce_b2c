import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../presentation/pages/home/home_page_simple.dart';
import '../../presentation/pages/product/product_detail_page.dart';
import '../../presentation/pages/cart/cart_page.dart';
import '../../presentation/pages/order/order_list_page.dart';
import '../../presentation/pages/order/order_detail_page.dart';
import '../../presentation/pages/order/order_confirm_page.dart';
import '../../presentation/pages/order/payment_page.dart';
import '../../presentation/pages/order/payment_result_page.dart';
import '../../presentation/pages/user/login_page.dart';
import '../../presentation/pages/user/user_center_page.dart';
import '../../presentation/pages/user/address_list_page.dart';
import '../../presentation/pages/user/address_edit_page.dart';
import '../../presentation/pages/admin/admin_shell_page.dart';
import '../bindings/user_binding.dart';
import '../bindings/cart_binding.dart';
import '../bindings/order_binding.dart';
import '../bindings/address_binding.dart';
import '../../presentation/controllers/user_controller.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String login = '/login';
  static const String userCenter = '/user/center';
  static const String productDetail = '/product/detail';
  static const String cart = '/cart';
  static const String orderList = '/order/list';
  static const String orderDetail = '/order/detail';
  static const String orderConfirm = '/order/confirm';
  static const String payment = '/payment';
  static const String paymentResult = '/payment/result';
  static const String addressList = '/address/list';
  static const String addressEdit = '/address/edit';
  static const String adminHome = '/admin';
  static const String adminProducts = '/admin/products';
  static const String adminOrders = '/admin/orders';
  static const String adminUsers = '/admin/users';

  static final List<GetPage> pages = [
    GetPage(
      name: home,
      page: () => const HomePageSimple(),
    ),
    GetPage(
      name: login,
      page: () => const LoginPage(),
      binding: UserBinding(),
    ),
    GetPage(
      name: userCenter,
      page: () => const UserCenterPage(),
      binding: UserBinding(),
    ),
    GetPage(
      name: productDetail,
      page: () => const ProductDetailPage(),
    ),
    GetPage(
      name: cart,
      page: () => const CartPage(),
      binding: CartBinding(),
    ),
    GetPage(
      name: orderList,
      page: () => const OrderListPage(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: orderDetail,
      page: () => const OrderDetailPage(),
    ),
    GetPage(
      name: orderConfirm,
      page: () => const OrderConfirmPage(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: payment,
      page: () => const PaymentPage(),
    ),
    GetPage(
      name: paymentResult,
      page: () => const PaymentResultPage(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: addressList,
      page: () => const AddressListPage(isSelectMode: false),
      binding: AddressBinding(),
    ),
    GetPage(
      name: addressEdit,
      page: () => const AddressEditPage(),
      binding: AddressBinding(),
    ),
    GetPage(
      name: adminHome,
      page: () => const AdminShellPage(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: adminProducts,
      page: () => const AdminShellPage(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: adminOrders,
      page: () => const AdminShellPage(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: adminUsers,
      page: () => const AdminShellPage(),
      middlewares: [AdminMiddleware()],
    ),
  ];
}

class AdminMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    try {
      final user = Get.find<UserController>().currentUser.value;
      if (user == null) {
        return const RouteSettings(name: AppRoutes.login);
      }
      if (!user.isAdmin) {
        Get.snackbar('权限不足', '您无权访问该页面');
        return const RouteSettings(name: AppRoutes.home);
      }
    } catch (e) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}
