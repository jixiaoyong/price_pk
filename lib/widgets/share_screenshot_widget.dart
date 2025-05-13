import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:qr_flutter/qr_flutter.dart';

class ShareScreenshotWidget extends StatelessWidget {
  final Widget content;
  final String shareUrl;
  final String baseUrl;

  const ShareScreenshotWidget({
    super.key,
    required this.content,
    required this.shareUrl,
    required this.baseUrl,
  });

  @override
  Widget build(BuildContext context) {
    // 判断二维码内容长度，动态调整布局和二维码尺寸
    final isLong = shareUrl.length > 450;
    final qrSize = isLong ? 200.0 : 80.0;
    final qrWidget = QrImageView(
      data: shareUrl,
      size: qrSize,
      backgroundColor: material.Colors.white,
    );
    Widget qrAndText;
    if (isLong) {
      // 上下布局，二维码大
      qrAndText = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          qrWidget,
          const SizedBox(height: 8),
          const material.Text(
            '扫码打开当前比价',
            style: material.TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: material.Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          material.SelectableText(
            baseUrl,
            style: const material.TextStyle(
                fontSize: 12, color: cupertino.CupertinoColors.activeBlue),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      // 原有布局
      qrAndText = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          qrWidget,
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const material.Text(
                '扫码打开当前比价',
                style: material.TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: material.Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              material.SelectableText(
                baseUrl,
                style: const material.TextStyle(
                    fontSize: 12, color: cupertino.CupertinoColors.activeBlue),
              ),
            ],
          ),
        ],
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: cupertino.CupertinoColors.systemGroupedBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: material.Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: material.Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: qrAndText,
          ),
          content,
        ],
      ),
    );
  }
}
