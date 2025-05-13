abstract class UnitClass {
  double value;
  final String unit;

  UnitClass({required this.value, required this.unit});

  /// 均价，返回该单位的均价，一般为该定量单位的最基础的单位
  /// 计算方式为 总价元/单位
  UnitClass prePrice(double? priceYuan);

  factory UnitClass.fromString(String unitName, double value) {
    throw UnsupportedError("$unitName 不支持");
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'unit': unit,
      'type': runtimeType.toString(),
    };
  }
}
