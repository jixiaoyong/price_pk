import 'package:price_pk/beans/unit_class.dart';

abstract class WeightUnit extends UnitClass {
  WeightUnit({required double value, required String unit})
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

    var prePrice = 0.0;
    if (0 == grams) {
      prePrice = double.maxFinite;
    } else {
      prePrice = price / grams;
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

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'type': 'Milligram',
      };
}

class Gram extends WeightUnit {
  Gram(double value) : super(value: value, unit: 'g');

  @override
  double toGrams() => value;

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'type': 'Gram',
      };
}

class Kilogram extends WeightUnit {
  Kilogram(double value) : super(value: value, unit: 'kg');

  @override
  double toGrams() => value * 1000;

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'type': 'Kilogram',
      };
}

class Ton extends WeightUnit {
  Ton(double value) : super(value: value, unit: 't');

  @override
  double toGrams() => value * 1000000;

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'type': 'Ton',
      };
}
