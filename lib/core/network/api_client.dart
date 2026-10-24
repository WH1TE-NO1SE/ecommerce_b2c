import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import '../../data/providers/mock_data_provider.dart';
import '../../presentation/controllers/user_controller.dart';

/// API 客户端封装
class ApiClient {
  /// 根据运行平台自动选择后端地址
  static String get _baseUrl {
    const configuredUrl = String.fromEnvironment('API_BASE_URL');
    if (configuredUrl.isNotEmpty) return configuredUrl;
    if (kIsWeb) {
      // Web 浏览器：直接用 localhost
      return 'http://localhost:8000/api';
    }
    // Android 模拟器用 10.0.2.2，真机用电脑 IP
    return 'http://10.0.2.2:8000/api';
  }

  static final dio.Dio _dio = dio.Dio(dio.BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  static bool _initialized = false;

  static void initialize() {
    if (_initialized) return;
    _initialized = true;

    _dio.interceptors.add(dio.InterceptorsWrapper(
      onRequest: (options, handler) {
        try {
          final userCtrl = Get.find<UserController>();
          final token = userCtrl.token.value;
          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (e) {
          // Token 未就绪
        }
        debugPrint('[API] ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onError: (error, handler) async {
        // 401: Token 过期，跳转登录
        if (error.response?.statusCode == 401) {
          Get.snackbar('登录过期', '请重新登录', snackPosition: SnackPosition.BOTTOM);
          try {
            final userCtrl = Get.find<UserController>();
            userCtrl.logout();
          } catch (_) {}
          Get.offAllNamed('/login');
          return;
        }

        // 409: 库存不足
        if (error.response?.statusCode == 409) {
          final msg = error.response?.data?['message'] ?? '操作冲突，请稍后重试';
          Get.snackbar('库存不足', msg,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white);
          return handler.next(error);
        }

        // 网络超时/连接失败：重试 1 次后回退 Mock
        if (error.type == dio.DioExceptionType.connectionTimeout ||
            error.type == dio.DioExceptionType.receiveTimeout ||
            error.type == dio.DioExceptionType.connectionError) {
          final retryCount =
              (error.requestOptions.extra['retryCount'] ?? 0) as int;

          if (retryCount < 1) {
            error.requestOptions.extra['retryCount'] = retryCount + 1;
            await Future.delayed(const Duration(milliseconds: 500));
            return handler.resolve(await _dio.fetch(error.requestOptions));
          }

          final mockData =
              MockDataProvider.getFallback(error.requestOptions.path);
          if (mockData != null) {
            Get.snackbar('网络异常', '已切换为离线模式',
                snackPosition: SnackPosition.BOTTOM);
            return handler.resolve(dio.Response(
              requestOptions: error.requestOptions,
              data: mockData,
              statusCode: 200,
            ));
          }
        }

        // 422: 请求参数校验失败（静默处理）
        if (error.response?.statusCode == 422) {
          return handler.next(error);
        }

        // 其他错误
        final msg = error.response?.data?['message'] ?? error.message ?? '请求失败';
        Get.snackbar('错误', msg, snackPosition: SnackPosition.BOTTOM);
        return handler.next(error);
      },
    ));
  }

  static Future<dio.Response> get(String path,
      {Map<String, dynamic>? query}) async {
    return await _dio.get(path, queryParameters: query);
  }

  static Future<dio.Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  static Future<dio.Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  static Future<dio.Response> delete(String path) async {
    return await _dio.delete(path);
  }
}
