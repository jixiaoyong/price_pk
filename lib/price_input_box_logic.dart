import 'package:get/get.dart';
import 'package:price_pk/pk_classify.dart';

class PriceInputBoxLogic extends GetxController {
  late List<PKClassify> tabs = [
    PKClassify(
        name: "重量",
        units: {Milligram(0.0), Gram(0.0), Kilogram(0.0), Ton(0.0)},
        goods: weightGoods),
    PKClassify(
        name: "体积",
        units: {
          Milliliter(0.0),
          Liter(0.0),
        },
        goods: volumeGoods),
  ];

  RxList<InputBoxState> weightGoods = List<InputBoxState>.generate(
      2, (index) => InputBoxState(name: "商品${index + 1}", unit: Gram(0.0))).obs;

  RxList<InputBoxState> volumeGoods = List<InputBoxState>.generate(
      2,
      (index) =>
          InputBoxState(name: "商品${index + 1}", unit: Milliliter(0.0))).obs;

  var first = InputBoxState().obs;
  var second = InputBoxState().obs;
}

class InputBoxState {
  String name;
  double price;
  UnitClass? unit;

  UnitClass? get prePrice => unit?.prePrice(price);

  InputBoxState({this.price = 0.0, this.unit, this.name = ""});

  InputBoxState copyWith({double? price, UnitClass? unit, String? name}) {
    return InputBoxState(
      price: price ?? this.price,
      unit: unit ?? this.unit,
      name: name ?? this.name,
    );
  }
}
