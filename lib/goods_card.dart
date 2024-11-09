import 'package:flutter/material.dart';
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
      required this.unitList});

  final InputBoxState data;
  final Function(InputBoxState state) onChange;
  final Function onDelete;
  final String defaultUnitString;
  final List<String> unitList;

  @override
  Widget build(BuildContext context) {
    var firstPrePrice = data.prePrice;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Column(
              children: [
                Text(
                  data.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text.rich(TextSpan(text: "商品均价 ", children: [
                  const TextSpan(
                    text: "¥",
                    style: TextStyle(color: Colors.green),
                  ),
                  TextSpan(
                    text:
                        "${firstPrePrice?.value.toCurrencyString() ?? "0.00"}",
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w900, color: Colors.green),
                  ),
                  TextSpan(text: "（元/${firstPrePrice?.unit}）")
                ])),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(label: Text("商品总价")),
                        onChanged: (value) {
                          onChange(data.copyWith(
                              price: double.tryParse(value) ?? 0.0));
                        },
                      ),
                    ),
                    const Text("元")
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(label: Text("商品总量")),
                        onChanged: (value) {
                          onChange(data.copyWith(
                              unit: WeightUnit.fromString(
                                  data.unit?.unit ?? defaultUnitString,
                                  double.tryParse(value) ?? 0.0)));
                        },
                      ),
                    ),
                    DropdownButton(
                      value: data.unit?.unit ?? defaultUnitString,
                      items: unitList
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(growable: false),
                      onChanged: (unit) {
                        onChange(data.copyWith(
                            unit: WeightUnit.fromString(
                                unit ?? "g", data.unit?.value ?? 0.0)));
                      },
                    ),
                  ],
                ),
                TextField(
                  decoration: const InputDecoration(label: Text("商品名称")),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    onChange(data.copyWith(name: value));
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
                onPressed: () {
                  onDelete.call();
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
