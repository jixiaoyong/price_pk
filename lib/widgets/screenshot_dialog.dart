import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:price_pk/price_input_box_logic.dart';
import 'dart:js' as js;
import 'dart:html' as html;

import 'goods_card.dart';
import 'share_screenshot_widget.dart';

class ScreenshotDialog extends StatefulWidget {
  final TabController tabController;
  const ScreenshotDialog({super.key, required this.tabController});

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
    final shareUrl = Uri.base.toString();
    final baseUrl = Uri.base.replace(queryParameters: {}).toString();

    final repaintKey = GlobalKey();
    final content = Material(
      color: Colors.transparent,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: goodsList.length,
        itemBuilder: (context, index) {
          var goods = goodsList[index];
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
        },
      ),
    );
    final shareWidget = Material(
      color: Colors.transparent,
      child: RepaintBoundary(
        key: repaintKey,
        child: ShareScreenshotWidget(
          content: content,
          shareUrl: shareUrl,
          baseUrl: baseUrl,
        ),
      ),
    );

    // 用Offstage隐藏渲染
    final boundary =
        await _captureWidgetAsBoundary(shareWidget, repaintKey, context);
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    setState(() {
      pngBytes = byteData!.buffer.asUint8List();
      generating = false;
    });
  }

  Future<RenderRepaintBoundary> _captureWidgetAsBoundary(
      Widget widget, GlobalKey key, BuildContext context) async {
    final completer = Completer<RenderRepaintBoundary>();
    final overlay = OverlayEntry(
      builder: (_) => Offstage(
        offstage: false,
        child: Center(child: widget),
      ),
    );
    Overlay.of(context).insert(overlay);

    // 等待至少两帧，确保渲染
    await Future.delayed(const Duration(milliseconds: 16));
    await Future.delayed(const Duration(milliseconds: 16));

    // 等待paint完成
    RenderRepaintBoundary? boundary;
    int retry = 0;
    while (retry < 30) {
      await Future.delayed(const Duration(milliseconds: 33));
      boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null && !boundary.debugNeedsPaint) {
        break;
      }
      retry++;
    }
    if (boundary == null || boundary.debugNeedsPaint) {
      overlay.remove();
      throw Exception('截图渲染失败，请重试');
    }
    overlay.remove();
    completer.complete(boundary);
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: generating
          ? const SizedBox(
              height: 200, child: Center(child: CircularProgressIndicator()))
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.memory(pngBytes!),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.copy),
                        label: const Text('复制到剪贴板'),
                        onPressed: () {
                          js.context
                              .callMethod('copyImageToClipboard', [pngBytes]);
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
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
