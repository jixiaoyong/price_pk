import 'package:get/get_rx/src/rx_types/rx_types.dart';

import 'price_input_box_logic.dart';

/// @author : jixiaoyong
/// @description ：单位类定义
///
/// @email : jixiaoyong1995@gmail.com
/// @date : 8/11/2024
class PKClassify {
  String name;
  List<String> units;
  RxList<InputBoxState> goods;
  RxDouble minPrePrice;
  UnitClass defaultUnit;

  UnitClass Function(String unitName, double value) fromString;

  PKClassify(
      {required this.name,
      required this.units,
      required this.goods,
      required this.minPrePrice,
      required this.defaultUnit,
      required this.fromString});
}

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
}

abstract class WeightUnit extends UnitClass {
  double value;
  final String unit;

  WeightUnit({required this.value, required this.unit})
      : super(value: value, unit: unit);

  factory WeightUnit.fromKilograms(double kg) => Kilogram(kg);

  factory WeightUnit.fromGrams(double g) => Gram(g);

  factory WeightUnit.fromMilligrams(double mg) => Milligram(mg);

  factory WeightUnit.fromTons(double t) => Ton(t);

  double toGrams(); // 所有子类都必须实现的抽象方法，将当前单位转换为克

  @override
  UnitClass prePrice(double? priceYuan) {
    var grams = toGrams();
    var price = priceYuan ?? 0;

    var prePrice = price / grams;
    if (0 == grams) {
      prePrice = price * double.maxFinite;
    }
    return Gram(prePrice);
  }

  @override
  factory WeightUnit.fromString(String unitName, double value) {
    if ("mg" == unitName) {
      return WeightUnit.fromMilligrams(value);
    } else if ("g" == unitName) {
      return WeightUnit.fromGrams(value);
    } else if ("kg" == unitName) {
      return WeightUnit.fromKilograms(value);
    } else if ("t" == unitName) {
      return WeightUnit.fromTons(value);
    } else {
      throw UnsupportedError("$unitName 不支持");
    }
  }
}

class Milligram extends WeightUnit {
  Milligram(double value) : super(value: value, unit: 'mg');

  @override
  double toGrams() => value / 1000;
}

class Gram extends WeightUnit {
  Gram(double value) : super(value: value, unit: 'g');

  @override
  double toGrams() => value;
}

class Kilogram extends WeightUnit {
  Kilogram(double value) : super(value: value, unit: 'kg');

  @override
  double toGrams() => value * 1000;
}

class Ton extends WeightUnit {
  Ton(double value) : super(value: value, unit: 't');

  @override
  double toGrams() => value * 1000000;
}

abstract class VolumeUnit extends UnitClass {
  double value;
  final String unit;

  VolumeUnit({required this.value, required this.unit})
      : super(value: value, unit: unit);

  factory VolumeUnit.fromLiters(double liters) => Liter(liters);

  factory VolumeUnit.fromMilliliters(double milliliters) =>
      Milliliter(milliliters);

  double toMilliliters(); // 抽象方法：将当前单位转换为毫升

  @override
  UnitClass prePrice(double? priceYuan) {
    var mls = toMilliliters();
    var price = priceYuan ?? 0;

    var prePrice = price / mls;
    if (0.0 == mls) {
      prePrice = price * double.maxFinite;
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
}

class Liter extends VolumeUnit {
  Liter(double value) : super(value: value, unit: 'l');

  @override
  double toMilliliters() => value * 1000;
}

class Milliliter extends VolumeUnit {
  Milliliter(double value) : super(value: value, unit: 'ml');

  @override
  double toMilliliters() => value;
}
