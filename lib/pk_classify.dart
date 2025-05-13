import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:price_pk/beans/input_box_state.dart';
import 'package:price_pk/beans/unit_class.dart';

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
