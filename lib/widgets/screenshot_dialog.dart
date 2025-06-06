import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:price_pk/price_input_box_logic.dart';
import 'package:price_pk/widgets/share_screenshot_widget.dart';
import 'dart:js' as js;
import 'dart:html' as html;

import 'goods_card.dart';

class ScreenshotDialog extends StatefulWidget {
  const ScreenshotDialog({super.key});

  @override
  State<ScreenshotDialog> createState() => _ScreenshotDialogState();
}

class _ScreenshotDialogState extends State<ScreenshotDialog> {
  Uint8List? pngBytes;
  bool generating = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateImage();
    });
  }

  Future<void> _generateImage() async {
    final logic = Get.find<PriceInputBoxLogic>();
    final tabIndex = logic.currentTabIndex;
    final tab = logic.tabs[tabIndex];
    final goodsList = tab.goods;
    final units = tab.units;
    final shareUrl = await logic.getShareUrl();
    String baseUrl = html.window.location.href;
    baseUrl = baseUrl.replaceAll(RegExp(r'\?(?=#|$)'), '');

    final repaintKey = GlobalKey();
    final content = Material(
      color: Colors.transparent,
      child: ShareScreenshotWidget(
        shareUrl: shareUrl.toString(),
        baseUrl: baseUrl,
        content: Column(
          children: goodsList.map((goods) {
            var isHighlight = goods.prePrice.value == tab.minPrePrice.value &&
                0 != goods.prePrice.value &&
                double.maxFinite != goods.prePrice.value;
            return GoodsCard(
              key: ValueKey(goods.id),
              data: goods,
              unitList: units,
              isHighlight: isHighlight,
              onChange: (_) {},
              onDelete: () {},
              fromString: tab.fromString,
            );
          }).toList(),
        ),
      ),
    );
    final shareWidget = Material(
      color: Colors.transparent,
      child: RepaintBoundary(
        key: repaintKey,
        child: content,
      ),
    );

    final overlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: UnconstrainedBox(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  child: shareWidget,
                ),
              ),
            ),
          ),
          Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(child: Text("正在截图...")),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(overlay);

    await Future.delayed(const Duration(milliseconds: 16));
    await Future.delayed(const Duration(milliseconds: 16));

    RenderRepaintBoundary? boundary;
    int retry = 0;
    while (retry < 30) {
      await Future.delayed(const Duration(milliseconds: 33));
      final renderObject = repaintKey.currentContext?.findRenderObject();
      if (renderObject is RenderRepaintBoundary) {
        boundary = renderObject;
        break;
      } else {
        boundary = null;
      }
      retry++;
    }
    if (boundary == null) {
      overlay.remove();
      throw Exception('截图渲染失败，请重试');
    }
    overlay.remove();

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    setState(() {
      pngBytes = byteData!.buffer.asUint8List();
      generating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return generating
        ? const SizedBox()
        : AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        child: Image.memory(
                          pngBytes!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final canRow = screenWidth > 400;
                    final buttons = [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.copy),
                        label: const Text('复制到剪贴板'),
                        onPressed: () {
                          js.context.callMethod('copyImageToClipboard', [pngBytes]);
                          Navigator.pop(context);
                          Get.snackbar('成功', '截图已复制到剪贴板');
                        },
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text('保存到本地'),
                        onPressed: () {
                          final blob = html.Blob([pngBytes!]);
                          final url = html.Url.createObjectUrlFromBlob(blob);
                          final anchor = html.AnchorElement(href: url)
                            ..setAttribute('download', 'pk_screenshot.png')
                            ..click();
                          html.Url.revokeObjectUrl(url);
                          Navigator.pop(context);
                          Get.snackbar('成功', '截图已保存到本地');
                        },
                      ),
                    ];
                    if (canRow) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: buttons,
                      );
                    } else {
                      return Column(
                        children: [
                          ...buttons.map((b) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: b,
                              )),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          );
  }
}
