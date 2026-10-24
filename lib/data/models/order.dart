import 'cart.dart';
import 'address.dart';

export 'address.dart';

enum OrderStatus {
  pending('待支付'),
  paid('已支付'),
  shipped('已发货'),
  delivering('配送中'),
  delivered('已收货'),
  completed('已完成'),
  cancelled('已取消'),
  refunding('退款中'),
  refunded('已退款');

  final String label;
  const OrderStatus(this.label);
}

class Order {
  final String id;
  final String orderNo;
  final List<CartItem> items;
  final double totalAmount;
  final double freight;
  final double discount;
  final OrderStatus status;
  final Address address;
  final Payment payment;
  final Logistics? logistics;
  final DateTime createTime;
  final DateTime? payTime;
  final DateTime? shipTime;
  final DateTime? receiveTime;
  final DateTime? completeTime;

  Order({
    required this.id,
    required this.orderNo,
    required this.items,
    required this.totalAmount,
    required this.freight,
    required this.discount,
    required this.status,
    required this.address,
    required this.payment,
    this.logistics,
    required this.createTime,
    this.payTime,
    this.shipTime,
    this.receiveTime,
    this.completeTime,
  });

  double get actualAmount => totalAmount + freight - discount;

  // v1.3: 统一序列化
  Map<String, dynamic> toJson() => {
        'id': id,
        'orderNo': orderNo,
        'totalAmount': totalAmount,
        'freight': freight,
        'discount': discount,
        'status': status.name,
        'createTime': createTime.toIso8601String(),
        'payTime': payTime?.toIso8601String(),
        'shipTime': shipTime?.toIso8601String(),
        'receiveTime': receiveTime?.toIso8601String(),
        'completeTime': completeTime?.toIso8601String(),
        'items': items.map((item) => item.toJson()).toList(),
        'address': address.toJson(),
        'payment': payment.toJson(),
      };

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsData = json['items'] as List? ?? [];
    return Order(
      id: json['id'] ?? '',
      orderNo: json['orderNo'] ?? '',
      items: itemsData
          .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      freight: (json['freight'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      status: OrderStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      address: json['address'] != null
          ? Address.fromJson(Map<String, dynamic>.from(json['address']))
          : Address(
              id: '',
              receiverName: '',
              phone: '',
              province: '',
              city: '',
              district: '',
              detail: '',
              isDefault: false),
      payment: json['payment'] != null
          ? Payment.fromJson(Map<String, dynamic>.from(json['payment']))
          : Payment(
              id: '',
              orderId: json['id'] ?? '',
              amount: 0,
              payMethod: '微信支付',
              status: 'pending'),
      logistics: null,
      createTime: json['createTime'] != null
          ? DateTime.parse(json['createTime'])
          : DateTime.now(),
      payTime: json['payTime'] != null ? DateTime.parse(json['payTime']) : null,
      shipTime:
          json['shipTime'] != null ? DateTime.parse(json['shipTime']) : null,
      receiveTime: json['receiveTime'] != null
          ? DateTime.parse(json['receiveTime'])
          : null,
      completeTime: json['completeTime'] != null
          ? DateTime.parse(json['completeTime'])
          : null,
    );
  }
}

class Payment {
  final String id;
  final String orderId;
  final double amount;
  final String payMethod;
  final String status;

  Payment({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.payMethod,
    required this.status,
  });

  // v1.3: 统一序列化
  Map<String, dynamic> toJson() => {
        'id': id,
        'orderId': orderId,
        'amount': amount,
        'payMethod': payMethod,
        'status': status,
      };

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json['id'] ?? '',
        orderId: json['orderId'] ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        payMethod: json['payMethod'] ?? '微信支付',
        status: json['status'] ?? 'pending',
      );
}

class Logistics {
  final String id;
  final String company;
  final String trackingNo;
  final String status;
  final List<LogisticsNode> nodes;

  Logistics({
    required this.id,
    required this.company,
    required this.trackingNo,
    required this.status,
    required this.nodes,
  });
}

class LogisticsNode {
  final String time;
  final String content;
  final String location;

  LogisticsNode({
    required this.time,
    required this.content,
    required this.location,
  });
}
