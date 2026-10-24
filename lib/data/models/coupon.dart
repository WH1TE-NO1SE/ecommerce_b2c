/// 优惠券模型
class Coupon {
  final String id;
  final String name; // 优惠券名称
  final String description; // 描述
  final double threshold; // 使用门槛（满多少可用）
  final double discount; // 优惠金额
  final CouponType type; // 类型：满减/折扣
  final DateTime startTime;
  final DateTime endTime;
  final bool isUsed; // 是否已使用

  Coupon({
    required this.id,
    required this.name,
    required this.description,
    required this.threshold,
    required this.discount,
    required this.type,
    required this.startTime,
    required this.endTime,
    this.isUsed = false,
  });

  bool get isValid {
    final now = DateTime.now();
    return !isUsed && now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// 计算优惠后的金额
  double apply(double amount) {
    if (!isValid || amount < threshold) return amount;
    if (type == CouponType.percent) {
      return amount * (1 - discount / 100);
    }
    return (amount - discount).clamp(0, double.infinity);
  }

  String get displayValue {
    if (type == CouponType.percent) {
      return '${discount.toInt()}折';
    }
    return '¥${discount.toStringAsFixed(0)}';
  }

  static List<Coupon> getMockCoupons() {
    final now = DateTime.now();
    return [
      Coupon(
        id: 'coupon_001',
        name: '新用户专享',
        description: '满100减20',
        threshold: 100,
        discount: 20,
        type: CouponType.fixed,
        startTime: now.subtract(const Duration(days: 30)),
        endTime: now.add(const Duration(days: 30)),
      ),
      Coupon(
        id: 'coupon_002',
        name: '全场9折券',
        description: '无门槛9折',
        threshold: 0,
        discount: 10,
        type: CouponType.percent,
        startTime: now.subtract(const Duration(days: 30)),
        endTime: now.add(const Duration(days: 30)),
      ),
      Coupon(
        id: 'coupon_003',
        name: '满299减50',
        description: '满299可用',
        threshold: 299,
        discount: 50,
        type: CouponType.fixed,
        startTime: now.subtract(const Duration(days: 30)),
        endTime: now.add(const Duration(days: 30)),
      ),
    ];
  }
}

enum CouponType {
  fixed('满减'),
  percent('折扣');

  final String label;
  const CouponType(this.label);
}
