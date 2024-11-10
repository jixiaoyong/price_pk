import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:price_pk/ext.dart';
import 'package:price_pk/pk_classify.dart';
import 'package:price_pk/price_input_box_logic.dart';

class GoodsCard extends StatelessWidget {
  const GoodsCard(
      {super.key,
      required this.data,
      required this.onChange,
      required this.onDelete,
      required this.defaultUnitString,
      required this.unitList,
      required this.fromString});

  final InputBoxState data;
  final Function(InputBoxState state) onChange;
  final Function onDelete;
  final String defaultUnitString;
  final List<String> unitList;

  final UnitClass Function(String unitName, double value) fromString;

  @override
  Widget build(BuildContext context) {
    var prePrice = data.prePrice;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Column(
              children: [
                TextFormField(
                  initialValue: data.name,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  style: Theme.of(context).textTheme.headlineSmall,
                  onChanged: (value) {
                    onChange(data.copyWith(name: value));
                  },
                ),
                Text.rich(TextSpan(text: "商品均价 ", children: [
                  const TextSpan(
                    text: "¥",
                    style: TextStyle(color: Colors.green),
                  ),
                  TextSpan(
                    text: prePrice.value.toCurrencyString(),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w900, color: Colors.green),
                  ),
                  TextSpan(text: "（元/${prePrice.unit}）")
                ])),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                        initialValue: "${data.price}",
                        inputFormatters: [
                          RemoveLeadingZerosFormatter(decimalPlaces: 2)
                        ],
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(label: Text("商品总价")),
                        onChanged: (value) {
                          onChange(data.copyWith(
                              price: double.tryParse(value) ?? 0.0));
                        },
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: Text("元"),
                    )
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                        initialValue: "${data.unit.value}",
                        inputFormatters: [RemoveLeadingZerosFormatter()],
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(label: Text("商品总量")),
                        onChanged: (value) {
                          onChange(data.copyWith(
                              unit: fromString(
                                  data.unit.unit ?? defaultUnitString,
                                  double.tryParse(value) ?? 0.0)));
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: DropdownButton(
                        value: data.unit.unit,
                        isExpanded: true,
                        underline: Container(),
                        items: unitList
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  alignment: Alignment.center,
                                  child: Text(e),
                                ))
                            .toList(growable: false),
                        onChanged: (unitName) {
                          onChange(data.copyWith(
                              unit: fromString(unitName ?? defaultUnitString,
                                  data.unit.value)));
                        },
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
                onPressed: () {
                  showCupertinoDialog(
                      context: context,
                      builder: (context) {
                        return CupertinoAlertDialog(
                          title: const Text("是否删除"),
                          content: Text(data.name),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text("取消"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoDialogAction(
                              child: const Text(
                                "删除",
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () {
                                onDelete.call();
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      });
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                )),
          )
        ],
      ),
    );
  }
}

class RemoveLeadingZerosFormatter extends TextInputFormatter {
  RemoveLeadingZerosFormatter({this.decimalPlaces = 0});

  final int decimalPlaces;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 去除前导零
    var newText = newValue.text.replaceAll(RegExp(r'^0+'), '');

    // 根据输入数字决定保留的小数位数
    newText = double.parse(newText).toStringAsFixed(decimalPlaces);

    // 获取旧值和新值
    final oldText = oldValue.text;
    final delta = newText.length - oldText.length;

    // 计算新的光标位置
    int newCursorPosition;
    if (delta != 0) {
      // 新增字符或减少字符
      // 判断是末尾还是中间
      if (oldValue.selection.baseOffset == oldText.length) {
        // 末尾，光标置于末尾
        newCursorPosition = newText.length;
      } else {
        // 中间新增，光标置于新增文本的末尾;删除中间字符，光标向前移动
        newCursorPosition = oldValue.selection.baseOffset + delta;
      }
    } else {
      // 修改字符
      // 保持光标位置不变
      newCursorPosition = oldValue.selection.baseOffset;
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }
}
