import 'dart:convert';
import 'dart:html';
import 'dart:math';

import 'package:get/get.dart';
import 'package:price_pk/pk_classify.dart';

class PriceInputBoxLogic extends GetxController {
  int currentTabIndex = 0;

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

    decodeUri();
  }

  void sort() {
    weightGoods.sort((a, b) => a.prePrice.value.compareTo(b.prePrice.value));
    volumeGoods.sort((a, b) => a.prePrice.value.compareTo(b.prePrice.value));
    refresh();
  }

  void cleanAll() {
    if (currentTabIndex == 0) {
      weightGoods.value = List<InputBoxState>.generate(
          2, (index) => InputBoxState(name: "商品${index + 1}", unit: Gram(0.0)));
    } else {
      volumeGoods.value = List<InputBoxState>.generate(
          2,
          (index) =>
              InputBoxState(name: "商品${index + 1}", unit: Milliliter(0.0)));
    }
    refresh();
  }

  bool decodeUri({String? url}) {
    try {
      final uri = Uri.parse(url ?? window.location.href);
      final params = uri.queryParameters;

      // Check if required parameters exist
      if (!params.containsKey('tab') ||
          !params.containsKey('volumeGoods') ||
          !params.containsKey('weightGoods')) {
        return false;
      }

      // Parse active tab
      final tabIndex = int.tryParse(params['tab'] ?? '0') ?? 0;
      currentTabIndex = tabIndex;

      // Clear existing goods
      weightGoods.value = [];
      volumeGoods.value = [];

      final goodsData = jsonDecode(params['volumeGoods'] ?? "[]") ?? [];
      final weightData = jsonDecode(params['weightGoods'] ?? "[]") ?? [];
      if (goodsData.isNotEmpty) {
        for (var i = 0; i < goodsData.length; i++) {
          volumeGoods.add(InputBoxState.fromJson(goodsData[i]));
        }
      } else {
        volumeGoods.value = List<InputBoxState>.generate(
            2,
            (index) =>
                InputBoxState(name: "商品${index + 1}", unit: Milliliter(0.0)));
      }

      if (weightData.isNotEmpty) {
        for (var i = 0; i < weightData.length; i++) {
          weightGoods.add(InputBoxState.fromJson(weightData[i]));
        }
      } else {
        weightGoods.value = List<InputBoxState>.generate(2,
            (index) => InputBoxState(name: "商品${index + 1}", unit: Gram(0.0)));
      }

      refresh();
      return true;
    } catch (e) {
      print('Error decoding URI: $e');
      return false;
    }
  }

  void share() {
    final url = Uri.parse(window.location.href).replace(queryParameters: {
      'tab': "$currentTabIndex",
      'weightGoods': jsonEncode(weightGoods.value ?? []),
      'volumeGoods': jsonEncode(volumeGoods.value ?? [])
    });

    window.navigator.clipboard
        ?.writeText(url.toString())
        .then((_) => Get.snackbar('成功', '链接已经复制到剪贴板'));
  }
}

class InputBoxState {
  String name;
  double? price;
  UnitClass unit;
  late int id;

  static int _id = 0;

  UnitClass get prePrice => unit.prePrice(price);

  InputBoxState(
      {this.price = 0.0, required this.unit, this.name = "", int? id}) {
    this.id = id ?? ++_id;
  }

  /// Convert the InputBoxState to a JSON-serializable map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'unit': unit.toJson(),
      'id': id,
    };
  }

  /// Create an InputBoxState from a JSON map
  factory InputBoxState.fromJson(Map<String, dynamic> json) {
    final unitData = json['unit'] as Map<String, dynamic>;
    final unitType = unitData['type'] as String;
    final unitValue = unitData['value'] as double;

    UnitClass unit;

    // Handle different unit types
    switch (unitType) {
      case 'Milligram':
        unit = Milligram(unitValue);
        break;
      case 'Gram':
        unit = Gram(unitValue);
        break;
      case 'Kilogram':
        unit = Kilogram(unitValue);
        break;
      case 'Ton':
        unit = Ton(unitValue);
        break;
      case 'Liter':
        unit = Liter(unitValue);
        break;
      case 'Milliliter':
        unit = Milliliter(unitValue);
        break;
      default:
        throw UnsupportedError('Unsupported unit type: $unitType');
    }

    return InputBoxState(
      name: json['name'] as String? ?? '',
      price: json['price'] as double?,
      unit: unit,
      id: json['id'] as int? ?? 0,
    );
  }

  InputBoxState copyWith(
      {double? price, UnitClass? unit, String? name, int? id}) {
    return InputBoxState(
      price: price ?? this.price,
      unit: unit ?? this.unit,
      name: name ?? this.name,
      id: id ?? this.id,
    );
  }
}
