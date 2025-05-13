import 'package:price_pk/beans/unit_class.dart';

abstract class VolumeUnit extends UnitClass {
  VolumeUnit({required double value, required String unit})
      : super(value: value, unit: unit);

  factory VolumeUnit.fromLiters(double liters) => Liter(liters);

  factory VolumeUnit.fromMilliliters(double milliliters) =>
      Milliliter(milliliters);

  double toMilliliters(); // 抽象方法：将当前单位转换为毫升

  @override
  UnitClass prePrice(double? priceYuan) {
    var mls = toMilliliters();
    var price = priceYuan ?? 0;

    var prePrice = 0.0;
    if (0.0 == mls) {
      prePrice = price * double.maxFinite;
    } else {
      prePrice = price / mls;
    }
    return Milliliter(prePrice);
  }

  @override
  factory VolumeUnit.fromString(String unitName, double value) {
    if ("l" == unitName) {
      return VolumeUnit.fromLiters(value);
    } else if ("ml" == unitName) {
      return VolumeUnit.fromMilliliters(value);
    } else {
      throw UnsupportedError("$unitName 不支持");
    }
  }

  @override
  set value(double v) => super.value = v;
}

class Liter extends VolumeUnit {
  Liter(double value) : super(value: value, unit: 'l');

  @override
  double toMilliliters() => value * 1000;

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'type': 'Liter',
      };
}

class Milliliter extends VolumeUnit {
  Milliliter(double value) : super(value: value, unit: 'ml');

  @override
  double toMilliliters() => value;

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'type': 'Milliliter',
      };
}
