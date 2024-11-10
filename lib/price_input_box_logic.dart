import 'dart:math';

import 'package:get/get.dart';
import 'package:price_pk/pk_classify.dart';

class PriceInputBoxLogic extends GetxController {
  late List<PKClassify> tabs = [
    PKClassify(
        name: "重量",
        units: ["mg", "g", "kg", "t"],
        goods: weightGoods,
        defaultUnit: Milligram(0.0),
        minPrePrice: weightMinValue,
        fromString: WeightUnit.fromString),
    PKClassify(
        name: "体积",
        units: ["ml", "l"],
        goods: volumeGoods,
        minPrePrice: volumeMinValue,
        defaultUnit: Milliliter(0.0),
        fromString: VolumeUnit.fromString),
  ];

  RxList<InputBoxState> weightGoods = List<InputBoxState>.generate(
      2, (index) => InputBoxState(name: "商品${index + 1}", unit: Gram(0.0))).obs;

  RxList<InputBoxState> volumeGoods = List<InputBoxState>.generate(
      2,
      (index) =>
          InputBoxState(name: "商品${index + 1}", unit: Milliliter(0.0))).obs;

  final RxDouble weightMinValue = RxDouble(double.maxFinite);
  final RxDouble volumeMinValue = RxDouble(double.maxFinite);

  @override
  void onInit() {
    super.onInit();

    ever(weightGoods, (callback) {
      weightMinValue.value = double.maxFinite;
      for (var element in callback) {
        weightMinValue.value =
            min(weightMinValue.value, element.prePrice.value);
      }
    });

    ever(volumeGoods, (callback) {
      volumeMinValue.value = double.maxFinite;

      for (var element in callback) {
        volumeMinValue.value =
            min(volumeMinValue.value, element.prePrice.value);
      }
    });
  }

  void sort() {
    weightGoods.sort((a, b) => a.prePrice.value.compareTo(b.prePrice.value));
    volumeGoods.sort((a, b) => a.prePrice.value.compareTo(b.prePrice.value));
    refresh();
  }
}

class InputBoxState {
  String name;
  double? price;
  UnitClass unit;

  late int id = DateTime.now().millisecondsSinceEpoch;

  UnitClass get prePrice => unit.prePrice(price);

  InputBoxState({this.price = 0.0, required this.unit, this.name = ""});

  InputBoxState copyWith({double? price, UnitClass? unit, String? name}) {
    return InputBoxState(
      price: price ?? this.price,
      unit: unit ?? this.unit,
      name: name ?? this.name,
    );
  }
}
