class User {
  final String id;
  final String username;
  final String phone;
  final String email;
  final String avatar;
  final int points;
  final String role; // user=普通用户, admin=管理员

  User({
    required this.id,
    required this.username,
    required this.phone,
    required this.email,
    required this.avatar,
    required this.points,
    this.role = 'user',
  });

  bool get isAdmin => role == 'admin';

  factory User.mock() => User(
        id: 'user_001',
        username: '测试用户',
        phone: '138****8888',
        email: 'test@example.com',
        avatar: '',
        points: 520,
        role: 'user',
      );
}
