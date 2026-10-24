import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/network/api_client.dart';
import '../../data/models/order.dart';

class AddressController extends GetxController {
  static const _addressesKey = 'user_addresses';
  static const _selectedAddressKey = 'selected_address_id';

  final RxList<Address> addresses = <Address>[].obs;
  final Rx<Address?> selectedAddress = Rx<Address?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
    refreshFromApi(); // 尝试从 API 刷新
  }

  void _loadFromStorage() {
    try {
      final box = GetStorage();
      final data = box.read<List>(_addressesKey);
      if (data != null && data.isNotEmpty) {
        addresses.value = data
            .map((e) => Address.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        _initDefaultAddresses();
      }
      final selectedId = box.read<String>(_selectedAddressKey);
      if (selectedId != null) {
        selectedAddress.value =
            addresses.firstWhereOrNull((a) => a.id == selectedId);
      }
      if (selectedAddress.value == null && addresses.isNotEmpty) {
        selectedAddress.value =
            addresses.firstWhereOrNull((a) => a.isDefault) ?? addresses.first;
      }
    } catch (e) {
      _initDefaultAddresses();
    }
  }

  void _initDefaultAddresses() {
    final defaultAddr = Address(
      id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
      receiverName: '白噪音',
      phone: '138****8888',
      province: '山东省',
      city: '济南市',
      district: '历下区',
      detail: 'XX路XX号XX小区1号楼101',
      isDefault: true,
    );
    addresses.value = [defaultAddr];
    selectedAddress.value = defaultAddr;
    _saveToStorage();
  }

  void _saveToStorage() {
    try {
      final box = GetStorage();
      box.write(_addressesKey, addresses.map((e) => e.toJson()).toList());
      if (selectedAddress.value != null) {
        box.write(_selectedAddressKey, selectedAddress.value!.id);
      }
    } catch (e) {
      // ignore
    }
  }

  /// 从 API 刷新地址列表
  Future<void> refreshFromApi() async {
    try {
      final resp = await ApiClient.get('/addresses');
      final list = resp.data['items'] as List;
      if (list.isNotEmpty) {
        addresses.value = list.map((a) => Address.fromJson(a)).toList();
        selectedAddress.value ??=
            addresses.firstWhereOrNull((a) => a.isDefault) ?? addresses.first;
        _saveToStorage();
      }
    } catch (_) {
      // API 不可用，保持本地数据
    }
  }

  /// 添加地址
  Future<void> addAddress(Address address) async {
    if (address.isDefault) _clearDefault();
    // 尝试 API
    try {
      final resp = await ApiClient.post('/addresses', data: address.toJson());
      final addr = Address.fromJson(resp.data);
      addresses.add(addr);
      selectedAddress.value = addr;
      _saveToStorage();
      return;
    } catch (_) {}
    // 本地回退
    addresses.add(address);
    selectedAddress.value = address;
    _saveToStorage();
  }

  /// 更新地址
  Future<void> updateAddress(Address address) async {
    final idx = addresses.indexWhere((a) => a.id == address.id);
    if (idx < 0) return;
    if (address.isDefault) _clearDefault(exceptId: address.id);
    // 尝试 API
    try {
      await ApiClient.put('/addresses/${address.id}', data: address.toJson());
    } catch (_) {}
    // 本地更新
    addresses[idx] = address;
    addresses.refresh();
    if (selectedAddress.value?.id == address.id) {
      selectedAddress.value = address;
    }
    _saveToStorage();
  }

  /// 删除地址
  Future<void> deleteAddress(String id) async {
    // 尝试 API
    try {
      await ApiClient.delete('/addresses/$id');
    } catch (_) {}
    // 本地删除
    addresses.removeWhere((a) => a.id == id);
    if (selectedAddress.value?.id == id) {
      selectedAddress.value = addresses.isNotEmpty
          ? (addresses.firstWhereOrNull((a) => a.isDefault) ?? addresses.first)
          : null;
    }
    _saveToStorage();
  }

  /// 设为默认
  Future<void> setDefault(String id) async {
    _clearDefault(exceptId: id);
    // 尝试 API
    try {
      await ApiClient.put('/addresses/$id/default');
    } catch (_) {}
    final idx = addresses.indexWhere((a) => a.id == id);
    if (idx >= 0) {
      addresses[idx] = Address(
        id: addresses[idx].id,
        receiverName: addresses[idx].receiverName,
        phone: addresses[idx].phone,
        province: addresses[idx].province,
        city: addresses[idx].city,
        district: addresses[idx].district,
        detail: addresses[idx].detail,
        isDefault: true,
      );
      addresses.refresh();
      _saveToStorage();
    }
  }

  /// 选择地址（用于下单）
  void selectAddress(Address address) {
    selectedAddress.value = address;
    _saveToStorage();
  }

  void _clearDefault({String? exceptId}) {
    for (var i = 0; i < addresses.length; i++) {
      if (exceptId != null && addresses[i].id == exceptId) continue;
      if (addresses[i].isDefault) {
        addresses[i] = Address(
          id: addresses[i].id,
          receiverName: addresses[i].receiverName,
          phone: addresses[i].phone,
          province: addresses[i].province,
          city: addresses[i].city,
          district: addresses[i].district,
          detail: addresses[i].detail,
          isDefault: false,
        );
      }
    }
    addresses.refresh();
  }

  Address? get defaultAddress {
    return addresses.firstWhereOrNull((a) => a.isDefault) ??
        (addresses.isNotEmpty ? addresses.first : null);
  }

  String? validateAddress(Address address) {
    if (address.receiverName.trim().isEmpty) return '请输入收货人姓名';
    if (address.phone.trim().isEmpty) return '请输入手机号';
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(address.phone.trim())) {
      return '请输入正确的手机号';
    }
    if (address.province.trim().isEmpty) return '请选择省份';
    if (address.city.trim().isEmpty) return '请选择城市';
    if (address.district.trim().isEmpty) return '请选择区县';
    if (address.detail.trim().isEmpty) return '请输入详细地址';
    if (address.detail.trim().length < 5) return '详细地址至少5个字';
    return null;
  }
}
