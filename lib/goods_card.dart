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
                    text: prePrice.value.toCurrencyString(),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w900, color: Colors.green),
                  ),
                  TextSpan(text: "（元/${prePrice.unit}）")
                ])),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: "${data.price}",
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
                      child: TextFormField(
                        initialValue: "${data.unit.value}",
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
                    DropdownButton(
                      value: data.unit.unit,
                      items: unitList
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(growable: false),
                      onChanged: (unitName) {
                        onChange(data.copyWith(
                            unit: fromString(unitName ?? defaultUnitString,
                                data.unit.value)));
                      },
                    ),
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
