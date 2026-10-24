import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/network/api_client.dart';
import '../../data/models/user.dart';

class UserController extends GetxController {
  static const _userKey = 'current_user';
  static const _tokenKey = 'auth_token';

  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoggedIn = false.obs;
  final RxString token = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  void _loadFromStorage() {
    try {
      final box = GetStorage();
      // 恢复 token
      final savedToken = box.read<String>(_tokenKey);
      if (savedToken != null && savedToken.isNotEmpty) {
        token.value = savedToken;
      }
      // 恢复用户信息
      final data = box.read<Map<String, dynamic>>(_userKey);
      if (data != null) {
        currentUser.value = User(
          id: data['id'] ?? '',
          username: data['username'] ?? '',
          phone: data['phone'] ?? '',
          email: data['email'] ?? '',
          avatar: data['avatar'] ?? '',
          points: data['points'] ?? 0,
          role: data['role'] ?? 'user',
        );
        isLoggedIn.value = true;
      }
    } catch (e) {
      currentUser.value = null;
      isLoggedIn.value = false;
    }
  }

  void _saveToStorage() {
    try {
      final box = GetStorage();
      box.write(_tokenKey, token.value);
      if (currentUser.value != null) {
        box.write(_userKey, {
          'id': currentUser.value!.id,
          'username': currentUser.value!.username,
          'phone': currentUser.value!.phone,
          'email': currentUser.value!.email,
          'avatar': currentUser.value!.avatar,
          'points': currentUser.value!.points,
          'role': currentUser.value!.role,
        });
      }
    } catch (e) {
      // ignore
    }
  }

  /// 登录 — 调用真实 API，失败时回退到本地校验
  Future<bool> login(String username, String password) async {
    if (username.isEmpty || password.length < 6) return false;

    try {
      final resp = await ApiClient.post('/auth/login', data: {
        'username': username,
        'password': password,
      });
      final data = resp.data;
      token.value = data['token'];
      _applyUserData(data['user']);
      _saveToStorage();
      return true;
    } catch (e) {
      // API 不可用时回退到本地 Mock 登录
      return _localLogin(username, password);
    }
  }

  /// 注册 — 调用真实 API
  Future<bool> register(String username, String password,
      {String? phone}) async {
    try {
      final resp = await ApiClient.post('/auth/register', data: {
        'username': username,
        'password': password,
        if (phone != null) 'phone': phone,
      });
      final data = resp.data;
      token.value = data['token'];
      _applyUserData(data['user']);
      _saveToStorage();
      return true;
    } catch (e) {
      Get.snackbar('注册失败', '请检查网络连接');
      return false;
    }
  }

  void _applyUserData(Map<String, dynamic> userData) {
    currentUser.value = User(
      id: userData['id'] ?? '',
      username: userData['username'] ?? '',
      phone: userData['phone'] ?? '',
      email: userData['email'] ?? '',
      avatar: userData['avatar'] ?? '',
      points: userData['points'] ?? 0,
      role: userData['role'] ?? 'user',
    );
    isLoggedIn.value = true;
  }

  /// 本地 Mock 登录（离线回退）
  bool _localLogin(String username, String password) {
    final isAdmin = username.toLowerCase() == 'admin';
    if (isAdmin && password != 'admin123') return false;
    currentUser.value = User(
      id: isAdmin
          ? 'admin_001'
          : 'user_${DateTime.now().millisecondsSinceEpoch}',
      username: isAdmin ? '管理员' : username,
      phone: isAdmin
          ? '13800000000'
          : '138****${username.length >= 4 ? username.substring(0, 4) : '0000'}',
      email: isAdmin ? 'admin@example.com' : '',
      avatar: '',
      points: isAdmin ? 99999 : 100,
      role: isAdmin ? 'admin' : 'user',
    );
    isLoggedIn.value = true;
    token.value = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    _saveToStorage();
    return true;
  }

  Future<void> logout() async {
    currentUser.value = null;
    isLoggedIn.value = false;
    token.value = '';
    try {
      final box = GetStorage();
      box.remove(_userKey);
      box.remove(_tokenKey);
    } catch (_) {}
  }
}
