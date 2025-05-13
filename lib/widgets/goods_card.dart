import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:price_pk/beans/input_box_state.dart';
import 'package:price_pk/beans/unit_class.dart';
import 'package:price_pk/ext.dart';
import 'package:price_pk/widgets/price_input_formatter.dart';

class GoodsCard extends StatefulWidget {
  const GoodsCard(
      {super.key,
      required this.data,
      this.isHighlight = false,
      required this.onChange,
      required this.onDelete,
      required this.unitList,
      required this.fromString});

  final bool isHighlight;

  final InputBoxState data;
  final Function(InputBoxState state) onChange;
  final Function onDelete;
  final List<String> unitList;

  final UnitClass Function(String unitName, double value) fromString;

  @override
  State<GoodsCard> createState() => _GoodsCardState();
}

class _GoodsCardState extends State<GoodsCard> {
  late final TextEditingController unitController;
  late final TextEditingController goodsPriceController;
  late final FocusNode goodsPriceFocusNode;

  @override
  void initState() {
    super.initState();
    unitController = TextEditingController(
      text:
          widget.data.unit.value == 0 ? '' : widget.data.unit.value.toString(),
    );
    goodsPriceController = TextEditingController(
      text: "${widget.data.price == 0 ? '' : widget.data.price}",
    );
    goodsPriceFocusNode = FocusNode();
    goodsPriceFocusNode.addListener(() {
      if (!goodsPriceFocusNode.hasFocus &&
          goodsPriceController.text.isNotEmpty) {
        goodsPriceController.text =
            double.parse(goodsPriceController.text).toCurrencyString();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    unitController.dispose();
    goodsPriceFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var prePrice = widget.data.prePrice;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: widget.isHighlight
              ? CupertinoColors.activeBlue
              : CupertinoColors.systemGrey4,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: TextFormField(
                    initialValue: widget.data.name,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.activeBlue,
                        ),
                    onChanged: (value) {
                      widget.onChange(widget.data.copyWith(name: value));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '均价 ',
                          style: TextStyle(
                            color: CupertinoColors.secondaryLabel
                                .resolveFrom(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextSpan(
                          text: '¥',
                          style: TextStyle(
                            color: CupertinoColors.label.resolveFrom(context),
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: double.maxFinite == prePrice.value
                              ? '--'
                              : prePrice.value.toCurrencyString(),
                          style: TextStyle(
                            color: CupertinoColors.label.resolveFrom(context),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' 元/${prePrice.unit}',
                          style: TextStyle(
                            color: CupertinoColors.tertiaryLabel
                                .resolveFrom(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 5,
                      fit: FlexFit.loose,
                      child: TextFormField(
                        controller: goodsPriceController,
                        focusNode: goodsPriceFocusNode,
                        inputFormatters: [PriceInputFormatter(decimalRange: 2)],
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          label: const Text("请输入商品总价"),
                          hintText: "比如10.00",
                          hintStyle: const TextStyle(
                              color: CupertinoColors.systemGrey,
                              fontWeight: FontWeight.normal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: CupertinoColors.activeBlue,
                              width: 2,
                            ),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                        ),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.label,
                        ),
                        textAlign: TextAlign.right,
                        minLines: 1,
                        maxLines: 1,
                        onChanged: (value) {
                          widget.onChange(widget.data
                              .copyWith(price: double.tryParse(value) ?? 0.0));
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text("元", style: TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                        controller: unitController,
                        inputFormatters: [PriceInputFormatter(decimalRange: 3)],
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          label: Text("请输入商品总量"),
                          hintText: "比如100",
                          hintStyle: TextStyle(
                              color: CupertinoColors.systemGrey,
                              fontWeight: FontWeight.normal),
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                        ),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.label,
                        ),
                        textAlign: TextAlign.right,
                        minLines: 1,
                        maxLines: 1,
                        onChanged: (value) {
                          final double doubleValue =
                              double.tryParse(value) ?? 0.0;
                          widget.onChange(widget.data.copyWith(
                            unit: widget.fromString(
                              widget.data.unit.unit,
                              doubleValue,
                            ),
                          ));
                        },
                        onTap: () {
                          if (unitController.text == '0') {
                            unitController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: unitController.text.length);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      height: 40,
                      margin: const EdgeInsets.only(left: 0),
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: CupertinoColors.systemGrey4,
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: widget.data.unit.unit,
                          icon: const Icon(CupertinoIcons.chevron_down,
                              size: 18, color: CupertinoColors.systemGrey),
                          dropdownColor: CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(10),
                          style: const TextStyle(
                            color: CupertinoColors.label,
                            fontSize: 16,
                          ),
                          items: widget.unitList
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    alignment: Alignment.center,
                                    child: Text(
                                      e,
                                      style: TextStyle(
                                        color: e == widget.data.unit.unit
                                            ? CupertinoColors.activeBlue
                                            : CupertinoColors.label,
                                        fontWeight: e == widget.data.unit.unit
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ))
                              .toList(growable: false),
                          onChanged: (unitName) {
                            widget.onChange(widget.data.copyWith(
                                unit: widget.fromString(
                                    unitName!, widget.data.unit.value)));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 15,
            right: 20,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 36,
              child: const Icon(
                CupertinoIcons.delete,
                color: CupertinoColors.systemRed,
                size: 24,
              ),
              onPressed: () {
                showCupertinoDialog(
                  context: context,
                  builder: (context) {
                    return CupertinoAlertDialog(
                      title: const Text("删除此商品？"),
                      content: Text(
                        '确定要删除"${widget.data.name}"吗？\n此操作无法撤销。',
                        style: TextStyle(
                          color: CupertinoColors.secondaryLabel
                              .resolveFrom(context),
                        ),
                      ),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text("取消",
                              style: TextStyle(
                                  color: CupertinoColors.secondaryLabel)),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          child: const Text("删除"),
                          onPressed: () {
                            widget.onDelete.call();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
