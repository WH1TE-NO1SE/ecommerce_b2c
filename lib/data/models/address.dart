/// 收货地址模型
class Address {
  final String id;
  final String receiverName;
  final String phone;
  final String province;
  final String city;
  final String district;
  final String detail;
  final bool isDefault;

  Address({
    required this.id,
    required this.receiverName,
    required this.phone,
    required this.province,
    required this.city,
    required this.district,
    required this.detail,
    required this.isDefault,
  });

  String get fullAddress => '$province $city $district $detail';

  // v1.3: 统一序列化
  Map<String, dynamic> toJson() => {
        'id': id,
        'receiverName': receiverName,
        'phone': phone,
        'province': province,
        'city': city,
        'district': district,
        'detail': detail,
        'isDefault': isDefault,
      };

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json['id'] ?? '',
        receiverName: json['receiverName'] ?? '',
        phone: json['phone'] ?? '',
        province: json['province'] ?? '',
        city: json['city'] ?? '',
        district: json['district'] ?? '',
        detail: json['detail'] ?? '',
        isDefault: json['isDefault'] ?? false,
      );
}
