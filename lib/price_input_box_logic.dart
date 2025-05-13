import 'dart:convert';
import 'dart:js_interop';
import 'dart:math';
import 'package:price_pk/beans/input_box_state.dart';
import 'package:price_pk/beans/volume_unit.dart';
import 'package:price_pk/beans/weight_unit.dart';
import 'package:web/web.dart';

import 'package:get/get.dart';
import 'package:price_pk/pk_classify.dart';
import 'package:lzstring/lzstring.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'widgets/screenshot_dialog.dart';

class PriceInputBoxLogic extends GetxController {
  int currentTabIndex = 0;

  late List<PKClassify> tabs = [
    PKClassify(
        name: "重量",
        units: ["mg", "g", "kg", "t"],
        goods: weightGoods,
        defaultUnit: Gram(0.0),
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

  Future<bool> decodeUri({String? url}) async {
    try {
      final uri = Uri.parse(url ?? window.location.href);
      final compressed = uri.queryParameters['data'];
      if (compressed != null && compressed.isNotEmpty) {
        final jsonStr =
            await LZString.decompressFromEncodedURIComponent(compressed);
        if (jsonStr != null && jsonStr.isNotEmpty) {
          final data = jsonDecode(jsonStr);
          final tabIndex = int.tryParse(data['tab'] ?? '0') ?? 0;
          currentTabIndex = tabIndex;

          weightGoods.value = [];
          volumeGoods.value = [];

          final goodsData = data['volumeGoods'] ?? [];
          final weightData = data['weightGoods'] ?? [];
          if (goodsData.isNotEmpty) {
            for (var i = 0; i < goodsData.length; i++) {
              volumeGoods.add(InputBoxState.fromJson(goodsData[i]));
            }
          } else {
            volumeGoods.value = List<InputBoxState>.generate(
                2,
                (index) => InputBoxState(
                    name: "商品${index + 1}", unit: Milliliter(0.0)));
          }

          if (weightData.isNotEmpty) {
            for (var i = 0; i < weightData.length; i++) {
              weightGoods.add(InputBoxState.fromJson(weightData[i]));
            }
          } else {
            weightGoods.value = List<InputBoxState>.generate(
                2,
                (index) =>
                    InputBoxState(name: "商品${index + 1}", unit: Gram(0.0)));
          }

          refresh();
          return true;
        }
        return false;
      }
      // 兼容老版本参数
      final params = uri.queryParameters;

      if (!params.containsKey('tab') ||
          !params.containsKey('volumeGoods') ||
          !params.containsKey('weightGoods')) {
        return false;
      }

      final tabIndex = int.tryParse(params['tab'] ?? '0') ?? 0;
      currentTabIndex = tabIndex;

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

  Future<void> share() async {
    final data = {
      'tab': "$currentTabIndex",
      'weightGoods': weightGoods.value.map((e) => e.toJson()).toList(),
      'volumeGoods': volumeGoods.value.map((e) => e.toJson()).toList(),
    };
    final jsonStr = jsonEncode(data);
    final compressed = await LZString.compressToEncodedURIComponent(jsonStr);

    final url = Uri.parse(window.location.href)
        .replace(queryParameters: {'data': compressed});

    window.navigator.clipboard
        .writeText(url.toString())
        .toDart
        .then((_) => Get.snackbar('成功', '链接已经复制到剪贴板'));
  }

  Future<void> shareByScreenshot(
      BuildContext context, TabController tabController) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ScreenshotDialog(tabController: tabController),
    );
  }
}
