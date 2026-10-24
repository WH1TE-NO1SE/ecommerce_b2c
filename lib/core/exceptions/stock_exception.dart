/// 库存不足异常（替代 DioException 用于本地库存校验）
class StockException implements Exception {
  final String message;
  final int available;
  StockException(this.message, {this.available = 0});

  @override
  String toString() => message;
}
